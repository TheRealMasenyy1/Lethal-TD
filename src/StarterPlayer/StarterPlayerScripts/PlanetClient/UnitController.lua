local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local PhysicsService = game:GetService("PhysicsService")
local GamepadService = game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")
local player = game:GetService("Players").LocalPlayer
local SharedPackages = ReplicatedStorage.SharedPackage
local Assets = ReplicatedStorage.Assets
local Particles = Assets.Particles
local Common = ReplicatedStorage.Common
local Viewport = SharedPackages.Viewports
local UnitsFolder = Assets.Units

local Maid = require(ReplicatedStorage.maid)
local Units_Data = require(SharedPackages.Units)
local Shortcut = require(ReplicatedStorage.Shortcut)
local EntityInfo = require(SharedPackages.Animations)
local Knit = require(ReplicatedStorage.Packages.Knit)

local camera = workspace.CurrentCamera
local Mouse = player:GetMouse()

local playerGui = player:WaitForChild("PlayerGui")
local Core = playerGui:WaitForChild("Core")
local Content = Core:WaitForChild("Content")
local ActionFrame = Content:WaitForChild("Actions")
local UpgradeUI : Frame = Content:WaitForChild("Upgrade")
local ToolbarUI = Content:WaitForChild("ToolbarUI")
local Notify_lb = Content:WaitForChild("Notify")
local NotifyFrame = Core:WaitForChild("NotifyFrame")
local Inputs = Core:WaitForChild("Inputs")

local Floors = workspace.Floors
local UnitHighlighter;
local MatchFolder 

local CurrentGamePadSelection = ""
local CountSelection = 1;
local LENGTH = 500
local MaxPlacementDistance = 100

local LatestKey : TextButton;
local canSelect = true
local Cancel = false
local PlacementAllowed = workspace.AllowPlacement

local UnitSelected = false -- Unit Selected debounce
local OnUI = false
local InsideUpgradeUI = false
local UpgradeIsOpened = false
local PhoneSelectedUnit = false
local CharacterTargetId;
local MousePosition;

local UpgradeInputs = Maid.new()

Mouse.TargetFilter = workspace.Detectors

local ControllerInputs = {
	[1] = "One";
	[2] = "Two";
	[3] = "Three";
	[4] = "Four";
	[5] = "Five";
}

local UnitController = Knit.CreateController {
	Name = "UnitController";
}

type UnitType = {
	Name : string; -- For informing the server which character to place, but also just use the InputObject depending on how the Datastore is setup
	MaxPlacement : number; -- nothing than for display
	Range : number; -- it's the radius player can detect a target
	Price : number	-- nothing than for display
}

type Units = {
	[string] : UnitType
	
	--[[
		e.g
		[Enum.KeyCode.One] = {
			Name = ""; -- Unit Name
			MaxPlacement = 20;
			Price = 300.00
		}
	]] 	
}

local UnitService;
local MatchService;

function UnitController:DisplayRange(Unit,Range : number) : BasePart
	local Zone = Instance.new("Part")
	Zone.Material = Enum.Material.ForceField
	Zone.Shape = Enum.PartType.Ball
	Zone.Size = Vector3.new(Range,Range,Range)
	Zone.CFrame = Unit.PrimaryPart.CFrame
	Zone.CanCollide =  false
	Zone.CastShadow = false
	Zone.Parent = Unit
	
	local Weld = Instance.new("WeldConstraint")
	Weld.Part0 = Zone
	Weld.Part1 =  Unit.PrimaryPart
	Weld.Parent = Zone
	
	return Zone
end

function UnitController:Notify(Text : string, Color : Color3)
	Color = Color or Color3.fromRGB(56, 255, 56)

	if not NotifyFrame:FindFirstChild(Text) then
		local newClone : TextLabel = Notify_lb:Clone()
		newClone.Text = Text
		newClone.TextColor3 = Color
		newClone.Name = Text
		newClone.Visible = true
		newClone.Parent = NotifyFrame

		local Prop = {
			TextTransparency = 0
		}
		local Tween = TweenService:Create(newClone,TweenInfo.new(1),Prop)
		Tween:Play()

		task.delay(1,function()
			local Prop1 = {
				TextTransparency = 1
			}
			local Tween2 = TweenService:Create(newClone,TweenInfo.new(1),Prop1)
			Tween2:Play()

			Tween2.Completed:Connect(function()
				newClone:Destroy()
			end)
		end)	
	end
end

function UnitController:SelectPlaceUnit(SelectedUnit : UnitType)
	local Cash = player.Cash
	local PlacementAmount = player.PlacementAmount
	local Unit = UnitsFolder:FindFirstChild(SelectedUnit.Name)
	local Price = Units_Data[SelectedUnit.Name].Price
	local list = {}
	local InputCleaner = Maid.new()
	local LegsOffset = 1.15 -- So that the legs don't clip the ground
	
	local function onDescendantAdded(descendant)
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = "Units"
		end
	end

	local function onCharacterAdded(character)
		for _, descendant in pairs(character:GetDescendants()) do
			onDescendantAdded(descendant)
		end
		character.DescendantAdded:Connect(onDescendantAdded)
	end
	
	local function DisableCollsion(Model)
		for _,Parts : BasePart in pairs(Model:GetChildren()) do
			if Parts:IsA("BasePart") then
				Parts.CanCollide = false
			end
		end
	end
	
	if Unit and Cash.Value >= Price then
		local UnitService = Knit.GetService("UnitService")
		local Map = MatchFolder.Parent.Map
		local SpawnSpot : CFrame = CFrame.new() 
		local Placed = false
		local canPlace = false
		local PhonePosition = Vector3.new(0,0,0)
		local TargetColor;
		Cancel = false
		
		UnitSelected = true
		
		if UserInputService.TouchEnabled then
			ActionFrame.Visible = true
		end

		local newUnit = Unit:Clone()
		newUnit.Parent = workspace.Detectors -- Just because
		
		pcall(function() -- Just in case player.Character
			newUnit:PivotTo(player.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,2))
		end)
		
		onCharacterAdded(newUnit) -- Sets CollisionGroup
		
		local Zone = self:DisplayRange(newUnit,Units_Data[SelectedUnit.Name].Upgrades[0].Range)
		local NormalColor = Zone.Color
		
		local Animation = self:PlayAnimation(newUnit,EntityInfo[newUnit.Name].Idle)
		Animation:Play()
		
		Inputs.Visible = true
		DisableCollsion(newUnit)
		
		InputCleaner:GiveTask(UserInputService.InputChanged:Connect(function()
			local lastInput = UserInputService:GetLastInputType()

			if UserInputService.GamepadEnabled and UserInputService.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition and lastInput ~= Enum.UserInputType.MouseMovement then
				Inputs.Mouse.Visible = false
				Inputs.Controller.Visible = true
			elseif UserInputService.KeyboardEnabled and UserInputService.MouseBehavior == Enum.MouseBehavior.Default and lastInput == Enum.UserInputType.MouseMovement then
				Inputs.Mouse.Visible = true
				Inputs.Controller.Visible = false
				ActionFrame.Visible = true
			elseif UserInputService.TouchEnabled and lastInput ~= Enum.UserInputType.MouseMovement then
				ActionFrame.Visible = true
			end

			Inputs.Position = UDim2.new(0,Mouse.X + 20,0,Mouse.Y + (Inputs.AbsoluteSize.Y / 2))
		end))
		
		InputCleaner:GiveTask(UserInputService.TouchTapInWorld:Connect(function()
			if PhoneSelectedUnit then
				Placed = true
				--warn("TAPPED IN THE WORLD")
			end
		end))
		
		local function PlaceParticle(CFRAME : CFrame ,Color : Color3)
			
			local part = Instance.new("Part")
			part.Size = Vector3.new(1,1,1)
			part.CFrame = CFRAME
			part.Anchored = true
			part.Transparency = 1
			part.Parent = workspace
			
			local Attachment = Instance.new("Attachment")
			Attachment.Parent = part

			local Particle = Particles.PlaceParticle:Clone()
			Particle.Parent = Attachment
			
			if Color then
				pcall(function()
					Particle.Color = ColorSequence.new(Color)
				end)
			end
			
			Particle:Emit(50)
			task.delay(1,game.Destroy,part)
		end



		local function GetPosition(position, processedByUI)
			if processedByUI then
				return
			end

			local unitRay = camera:ViewportPointToRay(position.X, position.Y)
			local ray = Ray.new(unitRay.Origin, unitRay.Direction * LENGTH)
			local hitPart, worldPosition = workspace:FindPartOnRay(ray)

			if hitPart then
				PhonePosition = worldPosition
				TargetColor = hitPart.Color
				Placed = true
				return hitPart
			end
		end

		UserInputService.TouchTapInWorld:Connect(GetPosition)
		
		InputCleaner:GiveTask(ActionFrame.Cancel.Activated:Connect(function()
			Cancel = true
			UnitSelected = false
			
			if UserInputService.TouchEnabled then
				--disableCameraMovement()
			end
			InputCleaner:Destroy()
		end))
		
		
		--- IMPROVE PLEASE QUICK FIX FOR THE RELEASE
		for _, Players in pairs(game:GetService("Players"):GetPlayers()) do
			for _, q in pairs(Players.Character:GetDescendants()) do
				if q:IsA("BasePart") then
					table.insert(list, q)
				end
			end
		end
		
		local function IgnoreLocation(MousePosition)
			local Params = RaycastParams.new()
			Params.FilterDescendantsInstances = {workspace.Ship,MatchFolder.Path,MatchFolder.Units,MatchFolder.Entities,Map.Restricted,list}
			Params.FilterType = Enum.RaycastFilterType.Include
			
			local Ray_Cast = Shortcut.RayCast(MousePosition - Vector3.new(0,-2.5,0),Vector3.new(0,-100,0),Params)
			
--			warn("THE PLACEMENT ---> ", Ray_Cast)
			
			if Ray_Cast then
				local partInstance = Ray_Cast.Instance
				return true
			end
			
			return false
		end
		
		InputCleaner:GiveTask(UserInputService.InputBegan:Connect(function(input,gameProcessedEvent)
			if gameProcessedEvent then
				return 
			end
			
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2) and canPlace then
				if not OnUI then
					Placed = true
					
					if LatestKey ~= nil then
						--LatestKey.Heighlight.Visible = false
					end
				else
					Cancel = true
				end
				
				CountSelection = 1
				Inputs.Visible = false
			end
			
			if (input.KeyCode == Enum.KeyCode.ButtonB) then -- Cancel placement

				if LatestKey ~= nil then
					--LatestKey.Heighlight.Visible = false
				end

				CountSelection = 1
				Cancel = true
				canSelect = true
				Inputs.Visible = false
			end
			
			if input.KeyCode == Enum.KeyCode.ButtonX and UnitSelected then
				Cancel = true
				canSelect = true
				UnitSelected = false
				--warn("THE PLACEMENT HAS BEEN CANCELLED --> ",Cancel)
			end
		end))
						
		
		local OldCFrame : CFrame;
		
		while not Placed and newUnit do
			local Distance = (newUnit.PrimaryPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
			local MouseTarget
			local IsPlaceAble
			
			if SpawnSpot then
				IsPlaceAble = IgnoreLocation((SpawnSpot * CFrame.new(0,2,0).Position))
			end
			
			local succ,err = pcall(function()
				MouseTarget = Mouse.Target or GetPosition(PhonePosition):IsDescendantOf(MatchFolder.Path) 
			end)
			
			if succ and (IsPlaceAble or MouseTarget:IsDescendantOf(MatchFolder.Units) or Distance > 60) then
				canPlace = false
				Zone.Color = Color3.fromRGB(255,0,0)
				--warn("[ INFO ] - CAN'T PLACE HERE FOR SOME REASON BUT I'M STILL ABLE TO DO THAT")
			else
				if not UserInputService.TouchEnabled and MouseTarget then
					TargetColor = MouseTarget.Color
				end
				
				Zone.Color = NormalColor
				canPlace = true
			end
		
			pcall(function()	
				SpawnSpot = CFrame.new(Mouse.Hit.Position) --+ Vector3.new(0,(newUnit:GetExtentsSize().Y / 2) ,0) --CFrame.new(Vector3.new(0,(newUnit:GetExtentsSize().Y / 2) ,0))

				if UserInputService.TouchEnabled then
					if PhonePosition.Magnitude > 0 then
						SpawnSpot = PhonePosition
					end
				end
				
				newUnit:PivotTo(SpawnSpot)
			end)
			
			if Cancel then
				newUnit:Destroy()
				break;
			end

			task.wait()
		end
		
		----warn("THE PRESS BOOLEAN IS: ---> ", Placed)
		
		if Placed and canPlace then
			local Distance = (SpawnSpot.Position - player.Character.HumanoidRootPart.Position).Magnitude
			-- Place Unit(Send Signal to server)
			if Distance <= 60 then
				ActionFrame.Visible = false
				Shortcut:PlaySound("Place")
				PlaceParticle(SpawnSpot,TargetColor)
				UnitService.Place:Fire({Spot = SpawnSpot, Name = newUnit.Name, Floor = MatchFolder.Parent.Name, Room = MatchFolder.Name})				
			else
				self:Notify(`Unit place to far away`,Color3.fromRGB(255,0,0))
			end
		end
		
		UnitSelected = false
		Cancel = false
		Inputs.Visible = false
		ActionFrame.Visible = false
		PhoneSelectedUnit = false
		
		Mouse.TargetFilter = workspace.Detectors
		
		InputCleaner:Destroy()
		if newUnit then 
			newUnit:Destroy() 
		end
	else
		self:Notify(`You don't have enough money`,Color3.fromRGB(255,0,0))
		Shortcut:PlaySound("Buzz",true)
		--warn(" YOU HAVE SPENT ALL OF YOUR MONEY FOR ", SelectedUnit.Name)
	end
end

function UnitController:GetUpgrades(Unit, StatsFrame, Level : number, UpgradeData, UpgradeContainer, ActionFrame, TheUnitsData)
	local List = UpgradeContainer:WaitForChild("List")
	local Damage = Unit:GetAttribute("Damage")
	local NextLevel = Level + 1
	
	if Units_Data[Unit.Name].Upgrades[NextLevel] then
		ActionFrame.Upgrade.Content.Cost.Text = "-"..Units_Data[Unit.Name].Upgrades[NextLevel].Cost
	end
	
	if TheUnitsData then
		ActionFrame.Sell.Content.Earn.Text = "+"..TheUnitsData.Moneyspent	
	end
	
	for _,Frames in pairs(List:GetChildren()) do

		if Frames:IsA("Frame") then
			local Frame_Destroy = StatsFrame:FindFirstChild(Frames.Name)
			
			Frames.Visible = false
			
			if Frame_Destroy then
				Frame_Destroy.Visible = false
			end
		end
	end

	for StatsName, Values in pairs(Units_Data[Unit.Name].Upgrades[Level]) do
		local Frame = StatsFrame:FindFirstChild(StatsName)
		local UpgradeStats = List:FindFirstChild(StatsName)
		
		if Frame and UpgradeStats then
			UpgradeStats.Visible = true
			Frame.Visible = true
			if StatsName == "Damage" and Damage and Damage > 0 then
				Values *= Damage
			end
			--local 
			
			Frame.Labels.Label.Text = StatsName
			Frame.Labels.Value.Text = string.format("%.2f",Values)
			
			if StatsName ~= "Cost" then
				local Upgrades = #UpgradeData
				local NextLevel = if Level < Upgrades then Level + 1 else Level
				
				if NextLevel ~= Level then
					
					UpgradeStats.Labels.CurrentValue.Text = string.format("%.2f",Values)
					UpgradeStats.Labels.NewValue.Text = "→ " .. UpgradeData[NextLevel][StatsName]
					UpgradeStats.Labels.NewValue.Visible = true
				else
					
					UpgradeStats.Labels.CurrentValue.Text = string.format("%.2f",Values)
					UpgradeStats.Labels.NewValue.Visible = false
				end
			else
				--print("[ LOG ] - The player has gotten his stuff ---> ", Units_Data[Unit].Upgrades[Level])
			end		
		end
	end
end



function UnitController:ClearLevel(LevelFrame, UnitInformation)
	local UpgradedLevel = UnitInformation.Level + 1

	if LevelFrame:FindFirstChild(UpgradedLevel) then
		local NextLevel = UpgradedLevel + 1

		LevelFrame[UpgradedLevel].ImageColor3 = Color3.fromRGB(87, 210, 87)
		LevelFrame[UpgradedLevel].ImageTransparency = 0

		if LevelFrame:FindFirstChild(NextLevel) then
			LevelFrame[NextLevel].ImageColor3 = Color3.fromRGB(87, 210, 87)
			LevelFrame[NextLevel].ImageTransparency = 0.7
		end
	end
end

function UnitController:OpenInteraction(Unit)
	local UnitId = Unit:GetAttribute("Id")
	local IsShiny = Unit:GetAttribute("Shiny")
	local IsOwner = Unit:GetAttribute("Owner") == player.Name
	local MaxUpgrades = 5
	local MaxInteractionDistance = 100
	
	local Detector = workspace.Detectors:FindFirstChild(UnitId)
	local Center = UpgradeUI:WaitForChild("Center")
	local UnitInfo = UpgradeUI:WaitForChild("UnitInfo")
	local UpgradeInfo = UpgradeUI:WaitForChild("UpgradeInfo")
	
	if Detector and player.Character:FindFirstChild("HumanoidRootPart") and not UnitSelected then
		local UnitName = UnitInfo:WaitForChild("UnitName")
		local UnitInfoContainer = UnitInfo:WaitForChild("Container")
		local Shiny_lb = UnitInfoContainer:WaitForChild("Shiny")
		local CenterContainer = Center:WaitForChild("Container")
		local LevelFrame = CenterContainer:WaitForChild("Level")
		local ActionFrame = CenterContainer:WaitForChild("Actions")
		local StatsFrame = CenterContainer:WaitForChild("Stats")
		local UpgradeContainer = UpgradeInfo:WaitForChild("Container")		
		--local Frame = UnitInfo:WaitForChild("Frame")
		
		if UnitHighlighter then UnitHighlighter:Destroy() end
		local Distance = (Detector.Position - player.Character.HumanoidRootPart.Position).Magnitude
		-- #UnitInformation.Upgrades
		local function SetLevelUI(UnitInformation)
			local CurrentLevel = UnitInformation.Level
			local NextLevel = CurrentLevel + 1
			local FutureLevel = NextLevel + 1
			
			for n = 1, MaxUpgrades do
				LevelFrame[n].ImageColor3 = Color3.fromRGB(0, 0, 0)
				LevelFrame[n].ImageTransparency = 0.5
			end
			
			for nr = 1, MaxUpgrades do
				----warn("[ LOG ] -  CURRENT LEVEL: ", CurrentLevel, CurrentLevel >= nr)
				if LevelFrame:FindFirstChild(nr) and UnitInformation.Upgrades[nr] then
					LevelFrame[nr].Visible = true
				end
				
				if LevelFrame:FindFirstChild(nr) and not UnitInformation.Upgrades[nr] then
					LevelFrame[nr].Visible = false
				end 
				
				if CurrentLevel >= nr then
					if LevelFrame:FindFirstChild(nr) and UnitInformation.Upgrades[nr] then
						LevelFrame[nr].ImageColor3 = Color3.fromRGB(87, 210, 87)
						LevelFrame[nr].ImageTransparency = 0
					end
				elseif CurrentLevel < nr then
					if LevelFrame:FindFirstChild(NextLevel) and UnitInformation.Upgrades[NextLevel] then
						LevelFrame[NextLevel].ImageColor3 = Color3.fromRGB(87, 210, 87)
						LevelFrame[NextLevel].ImageTransparency = 0.7
					end
					
					if LevelFrame:FindFirstChild(FutureLevel) and UnitInformation.Upgrades[FutureLevel] then
						LevelFrame[FutureLevel].ImageColor3 = Color3.fromRGB(0, 0, 0)
						LevelFrame[FutureLevel].ImageTransparency = 0.5
					end														
				end
					
			end
		end
		
		--print(" DISTANCE: ", Distance , MaxInteractionDistance)

		if Distance <= MaxInteractionDistance and Unit:GetAttribute("Id") ~= CharacterTargetId then
			Shortcut:PlaySound("MouseClick")
			local UnitData = UnitService:GetUnitInfo(UnitId)
			
			-- Show highlighter --
			UnitHighlighter = Instance.new("Highlight")
			UnitHighlighter.FillColor = Color3.fromRGB(255, 255, 255)
			UnitHighlighter.Parent = Unit
			
			if IsShiny then
				Shiny_lb.Visible = true
			else
				Shiny_lb.Visible = false
			end
			
			UnitData:andThen(function(UnitInformation)
				local Upgrades = #UnitInformation.Upgrades
				local UnitViewport = Viewport:FindFirstChild(UnitInformation.Name)
				local NextLevel = if UnitInformation.Level < Upgrades then UnitInformation.Level + 1 else Upgrades
				
				UpgradeInputs:DoCleaning()
				UpgradeInputs = Maid.new()
				--UnitInfoContainer.UnitName.Text = EntityInfo
				
				Detector.Transparency = 0
				
				SetLevelUI(UnitInformation)
				self:GetUpgrades(Unit, StatsFrame, UnitInformation.Level, UnitInformation.Upgrades, UpgradeContainer, ActionFrame, UnitInformation)		
				
				if UnitViewport then
					local oldViewport = UnitInfoContainer:FindFirstChildWhichIsA("ViewportFrame")
					
					if oldViewport then
						oldViewport:Destroy()
					end
					
					local newPort = UnitViewport:Clone()
					newPort.Size = UDim2.new(1,0,1,0)
					newPort.Parent = UnitInfoContainer
					
					local WorldModel = newPort:FindFirstChild("WorldModel")

					if WorldModel then
						local Model = WorldModel:FindFirstChildWhichIsA("Model")

						if Model then
							-- print("THE MODEL ---> ", Model.Name)
							
							local Animation = self:PlayAnimation(Model,EntityInfo[Model.Name].Idle)
							Animation:Play()
						end				
					end
					
					UnitName.Container.Label.Text = UnitInformation.Name
				end
				
				ActionFrame.Upgrade.Visible = false
				ActionFrame.Sell.Visible = false
				ActionFrame.Targeting.Visible = false
						
				if IsOwner then
					ActionFrame.Sell.Visible = true
					ActionFrame.Upgrade.Visible = true
					ActionFrame.Targeting.Visible = true
					ActionFrame.Targeting.Content.Mode.Text = `[ {UnitInformation.Targeting} ]`

					if UnitInformation.Level >= Upgrades then 
						ActionFrame.Upgrade.Visible = false
					elseif Unit:GetAttribute("UnitType") == "Buff" then
						ActionFrame.Targeting.Visible = false
					end
				
					UpgradeInputs:GiveTask(ActionFrame.Targeting.MouseButton1Down:Connect(function()
						local UpdateOnUpgrade = UnitService:ChangeTargeting(UnitId) -- ,UnitInformation.Targeting
						UpdateOnUpgrade:andThen(function(newTargeting)
							warn("[ INFO ] - THE UNIT HAS ", newTargeting)
							ActionFrame.Targeting.Content.Mode.Text = `[ {newTargeting} ]`
						end)
						-- UICleaner:Destroy()
					end))
	

					UpgradeInputs:GiveTask(ActionFrame.Sell.Activated:Connect(function()
						Shortcut:PlaySound("MouseClick")
						UnitService:Sell(UnitId)
						UpgradeUI.Visible = false
						ToolbarUI.Visible = true
						UpgradeIsOpened = false
						UnitSelected = false
						CharacterTargetId = ""
						
						UnitHighlighter:Destroy()
					end))
					
					UpgradeInputs:GiveTask(ActionFrame.Upgrade.Activated:Connect(function()
						Shortcut:PlaySound("MouseClick")
						local PromiseData = UnitService:UpgradeUnit(UnitId)
						
						PromiseData:andThen(function(HasBeenUpgraded,Data)
							if HasBeenUpgraded then
								Shortcut:PlaySound("Upgrade")								
								--warn("[ LOG ] - UNIT INFO ---> ", Data, HasBeenUpgraded)
								
								if Data.Level >= #Data.Upgrades then
									ActionFrame.Upgrade.Visible = false
								end
								
								SetLevelUI(Data)
								self:GetUpgrades(Unit, StatsFrame, Data.Level, Data.Upgrades, UpgradeContainer, ActionFrame, Data)

							else
								self:Notify(`You don't have enough money`,Color3.fromRGB(255,0,0))
							end					
						end)
						
						--ToolbarUI.Visible = true
						--UpgradeUI.Visible = false
					end))
				end
			
				ToolbarUI.Visible = false 
				UpgradeUI.Visible = true -- ENABLE UI AFTER EVERYTHING HAS BEEN APPLIED
				CharacterTargetId = Unit:GetAttribute("Id")
			end)
		end 
	end
end

function UnitController:PlayAnimation(Unit,Animation)
	local AnimationController = Unit.AnimationController
	local AnimationTrack = AnimationController:LoadAnimation(Animation)
	return AnimationTrack
end

function UnitController:ApplyImages(ToolbarUI,EquippedUnits) -- This shouldn't actually be here, but it's just for testing
	-- print("[ INFO ] - THE EQUIPPED TABLE --> ", EquippedUnits)
	
	for _,Btn in pairs(ToolbarUI:GetChildren()) do
		if Btn:IsA("ImageButton") and EquippedUnits[Btn.Name] then
			local UnitTable = EquippedUnits[Btn.Name]
			Btn:SetAttribute("UnitName",UnitTable.Name)
			--Btn:SetAttribute("Key",Btn.Name)
			
			--warn("SETTING PRICE --> ", UnitTable)
			local ViewportImage = Viewport[UnitTable.Name]:Clone()
			ViewportImage.Parent = Btn
			
			Btn.Cost.Text = "$".. UnitTable.Price
			
			if UnitTable.Shiny then
				Btn.Cost.TextColor3 = Color3.fromRGB(220, 229, 44)
			end
			
			local _,err = pcall(function()
				local WorldModel = ViewportImage:FindFirstChild("WorldModel")

				if WorldModel then
					local Model = WorldModel:FindFirstChildWhichIsA("Model")

					if Model then
						-- print("[ INFO ] - PLAYING ANIMATION FOR ", EntityInfo ,Model.Name)
						local Animation = self:PlayAnimation(Model,EntityInfo[Model.Name].Idle)
						Animation:Play()
					end				
				end
			end)
			
			if err then
				warn(`[Could not load the Idle animation for {UnitTable.Name} ]`)
			end
			
			Btn.SelectionGained:Connect(function(testbtn)
				-- print("THE SELECTION OF THIS UI ---> ", testbtn)
				CurrentGamePadSelection = Btn.Name
			end)
			
			self:ActivateBtn(EquippedUnits,Btn)
		end
	end
	
end

local LatestHoveredKey;

function disableCameraMovement()
	-- Disable camera movement
	camera.CameraType = Enum.CameraType.Scriptable
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	--UserInputService.TouchPan = Enum.UserInputState.Cancel
	--UserInputService.TouchRotate = Enum.UserInputState.Cancel
	--UserInputService.TouchPinch = Enum.UserInputState.Cancel
	
	if player.Character then
		player.Character.Humanoid.WalkSpeed = 0
	end
end

function enableCameraMovement()
	-- Re-enable camera movement
	camera.CameraType = Enum.CameraType.Custom
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default

	if player.Character then
		player.Character.Humanoid.WalkSpeed = 16
	end
end

--return {
--	disableCameraMovement = disableCameraMovement,
--	enableCameraMovement = enableCameraMovement
--}

function UnitController:ActivateBtn(EquippedUnits,Btn : TextButton)
	local Position

	local function Reverse()
		if LatestHoveredKey then
			local PropReturn = {
				Size = UDim2.new(0.084, 0,1, 0),
				Position = LatestHoveredKey.Position
			} 
			
			local Tween = TweenService:Create(LatestHoveredKey,TweenInfo.new(.3),PropReturn)
			Tween:Play()
		end
	end
	
	local function OnEntry()
		local Prop = {
			Size = UDim2.new(0.204, 0,1.103, 0),
			Position = Btn.Position
		}

		local Tween = TweenService:Create(Btn,TweenInfo.new(.3),Prop)
		Tween:Play()

		if LatestHoveredKey and LatestHoveredKey.Name ~= Btn.Name then
			Reverse()
		end

		LatestHoveredKey = Btn			

		OnUI = true
	end
	
	Btn.Activated:Connect(function()
		-- warn("HAS BEEN ACTIVATED FOR SOME REASON --->  ",UnitSelected)
		
		if PlacementAllowed.Value and not UnitSelected then
			if UserInputService.GamepadEnabled then
				GuiService.SelectedObject = nil
			end
			--warn(" PLACEMENT ---> COMES ---> ")
			task.delay(.2,function()
				PhoneSelectedUnit = true
			end)
			
			--self:Select(Btn.Name,EquippedUnits)
			if UserInputService.TouchEnabled then
				--enableCameraMovement()
			end
			
			Cancel = true
			self:SelectPlaceUnit(EquippedUnits[Btn.Name])
		end
	end)	
		
	Btn.MouseMoved:Connect(function()
		OnEntry()
	end)
	
	Btn.MouseEnter:Connect(function()
		OnEntry()
	end)
	
	Btn.MouseLeave:Connect(function()
		OnUI = false
		Reverse()
	end)		

end

local CurrentSelection = 1

function UnitController:Select(Key,EquippedUnits)
	local KeyBtn = ToolbarUI:FindFirstChild(Key)
	
	if KeyBtn then
		local Prop = {
			Thickness = 5
		}
		
		--KeyBtn.Heighlight.Visible = true
		
		if LatestKey and LatestKey.Name ~= KeyBtn.Name then
			--LatestKey.Heighlight.Visible = false
		end
		
		Cancel = true
		LatestKey = KeyBtn
		
		task.spawn(function()
			self:SelectPlaceUnit(EquippedUnits[Key])		
		end)
	end
end

function UnitController:GetInputs(EquippedUnits)
	local UnitInfo : BillboardGui = playerGui:WaitForChild("UnitInfo")
	local InputCleaner = Maid.new() -- Gets removed when player leaves ends the game
	local UICleaner = Maid.new()

	
	local SelectedTarget;
	local Inputs = {
		["One"] = true;
		["Two"] = true;
		["Three"] = true;
		["Four"] = true;
		["Five"] = true;
	}
	
	local Counter = 1
	
	--self:BindToToolbar(EquippedUnits)
	local StorageUI = {}
	for _,pack in pairs(ToolbarUI:GetChildren()) do
		if pack:IsA("ImageButton") then
			table.insert(StorageUI,pack)
		end
	end
	
	GuiService:AddSelectionTuple("Toolbar",unpack(StorageUI))
	
	local function GetUnit(position, processedByUI)
		if processedByUI then
			return
		end

		local unitRay = camera:ViewportPointToRay(position.X, position.Y)
		local ray = Ray.new(unitRay.Origin, unitRay.Direction * LENGTH)
		local hitPart : BasePart, worldPosition = workspace:FindPartOnRay(ray)

		if hitPart then -- and hitPart:IsDescendantOf(MatchFolder.Units)
			--warn("GET THE HITBOX --> ", hitPart.Name)
			return hitPart
		end
	end
	
	InputCleaner:GiveTask(UserInputService.TouchTapInWorld:Connect(function(position)
		MousePosition = position
	end))
	
	InputCleaner:GiveTask(UserInputService.InputBegan:Connect(function(input,gameProcessedEvent)
		local IsKeydown = UserInputService:IsKeyDown(input.KeyCode.Name)
		
		if gameProcessedEvent then
			return
		end
		
		if PlacementAllowed.Value then
			if input.KeyCode == Enum.KeyCode.ButtonX then -- Custom Selection
				canSelect = false
				
				task.delay(.1,function()
					self:Select(ControllerInputs[CountSelection],EquippedUnits)	
					
					CountSelection += 1
					
					if CountSelection > #ControllerInputs then
						CountSelection = 1
					end
				end)
			end
			
			-- SHOULD DELETE THE UNIT BUT IT'S LATE
			
			if IsKeydown == Inputs[input.KeyCode.Name] and not UnitSelected and not UpgradeIsOpened then
				--GuiService:Select(player.PlayerGui)
				--self:Select(input.KeyCode.Name,EquippedUnits)
				
				Cancel = true
				self:SelectPlaceUnit(EquippedUnits[input.KeyCode.Name])
			end
			
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2 or input.UserInputType == Enum.UserInputType.Touch) then
				local Target;
				
				local succ,err = pcall(function()
					Target = Mouse.Target.Parent or GetUnit(MousePosition, true)
				end)
								
				if succ and Target and Target:FindFirstChild("RootPart") and Target.Name ~= "Detector" and Target:IsDescendantOf(MatchFolder.Units) then
					if SelectedTarget and SelectedTarget:GetAttribute("Id") ~= Target:GetAttribute("Id") then
						local Detector = workspace.Detectors:FindFirstChild(SelectedTarget:GetAttribute("Id"))
						if Detector then
							--if UICleaner then  end
							UICleaner:Destroy()
							Detector.Transparency = 1;
							SelectedTarget = nil
						end
						--return 
					end
					UpgradeIsOpened = true
					
					UICleaner = Maid.new()						
					SelectedTarget = Target

					UICleaner:GiveTask(UpgradeUI.MouseEnter:Connect(function() -- Don't remember if this is even needed
						InsideUpgradeUI = true
					end))
					
					UICleaner:GiveTask(UpgradeUI.MouseLeave:Connect(function() -- Don't remember if this is even needed
						InsideUpgradeUI = false
					end))
					
					self:OpenInteraction(Target)
				elseif SelectedTarget and not InsideUpgradeUI then
					local Detector = workspace.Detectors:FindFirstChild(SelectedTarget:GetAttribute("Id"))
					
					-- CharacterTargetId and SelectedTarget:GetAttribute("Id") ~= CharacterTargetId
					--	SelectedTarget = nil
					--UICleaner:Destroy()
					--
					ToolbarUI.Visible = true
					UpgradeUI.Visible = false
					CharacterTargetId = ""
					
					UpgradeIsOpened = false
					
					Shortcut:PlaySound("MouseClick")
					if UnitHighlighter then UnitHighlighter:Destroy() end
					if Detector then Detector.Transparency = 1; end
					if UICleaner then UICleaner:Destroy() end
					if UpgradeInputs then UpgradeInputs:Destroy() end
					
					SelectedTarget = nil	
				end	
			end
		end
		
		
	end))
	-- print("[ LOG ] - AWAITING THE INPUTS")
end

function UnitController:KnitStart()
	MatchService = Knit.GetService("MatchService")
	UnitService = Knit.GetService("UnitService")
	local ProfileService = Knit.GetService("ProfileService")
	local InputLayout = {} -- This holds the local player units
	
	local function GetInfo(Name,UnitInfo) -- Temp function
		for RealName,Data in pairs(Units_Data) do
			if RealName == Name then
				local newData = table.clone(Data)
				newData.Name = RealName
				if UnitInfo["Shiny"] then
					newData["Shiny"] = UnitInfo["Shiny"]
				end				
				return newData
			elseif Data.Name == Name then
				local newData = table.clone(Data)
				if UnitInfo["Shiny"] then
					newData["Shiny"] = UnitInfo["Shiny"]
				end

				newData.Name = RealName				
				return newData
			end
		end
	end
	
	ProfileService:OnProfileReady():andThen(function() -- Check if the player really has the unit in the server
		local EquippedUnits = ProfileService:Get("Equipped")

		EquippedUnits:andThen(function(value)
			--if #value == 0 then player:Kick("REJOIN") end
			--warn("THE PLAYERS EQUIPPED DATA ---> ", value)
			for i,Info in ipairs(value) do
				local Key = ControllerInputs[i]
				InputLayout[Key] = GetInfo(Info.Unit,Info) 
			end		
			
			self:ApplyImages(ToolbarUI,InputLayout)
		end)
	end)

	PlacementAllowed.Changed:Connect(function()
		if not PlacementAllowed.Value then
			Cancel = true
		end 
	end)

	MatchService.AllowPlacement:Connect(function(HasStarted,FloorInfo)
		--warn("We recieved the value ", HasStarted, EquippedUnits)
		MatchFolder = Floors[FloorInfo.Floor][FloorInfo.Room]
		self:GetInputs(InputLayout)
	end)
end

function UnitController:KnitInit()

end

return UnitController
