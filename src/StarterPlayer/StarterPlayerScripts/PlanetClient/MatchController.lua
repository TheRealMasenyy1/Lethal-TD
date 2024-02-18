--- CONTROLLS THE THE GAME WHEN THE PLAYER HAS JOINED ---
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local player = game:GetService("Players").LocalPlayer

local SharedPackage = ReplicatedStorage.SharedPackage
local Knit = require(ReplicatedStorage.Packages.Knit)
local Shortcut = require(ReplicatedStorage.Shortcut)
local EntityInfo = require(SharedPackage.Animations)
local Maid = require(ReplicatedStorage.maid)

local PlayerGui = player:WaitForChild("PlayerGui")
local Core = player.PlayerGui:WaitForChild("Core")
local BaseHealth = Core.BaseHealth
local AllowPlacement = workspace.AllowPlacement

local MatchController = Knit.CreateController {
	Name = "MatchController";
}

local MatchService

local HealthFrame = Core:WaitForChild("HealthFrame")
local Content = Core:WaitForChild("Content")
local ToolbarUI = Content:WaitForChild("ToolbarUI")
local IntermissionUI = Core:WaitForChild("Intermission")
local IntermissionFrame = IntermissionUI:WaitForChild("Content")
local UpgradeUI = Content:WaitForChild("Upgrade")
local SkipWave = Content:WaitForChild("SkipWave")
local VoteSkip = SkipWave:WaitForChild("VoteSkip")
local BaseHealthUI = Content:WaitForChild("BaseHealth")
local Notify_lb = Content:WaitForChild("Notify")
local NotifyFrame = Core:WaitForChild("NotifyFrame")

local OnDeathUI = Core:WaitForChild("OnDeath") 

local ExtraUI = Core.ExtraUI
local Wave = BaseHealthUI:WaitForChild("Wave")
local BtnCleaner = Maid.new()
local Floors = workspace.Floors;
local ValueFolder = workspace.Values
local ShipHealth = ValueFolder.Health
local CurrentWave = workspace.CurrentWave
local SkipBtnLoaded = false
local autoSkip = false
local IsDefending = false

local MaxWave = 10
local reviveId = 1754721725

function Skip(value)
	SkipWave.Check_lb.Visible = value

	if value then
		SkipWave.BackgroundColor3 = Color3.fromRGB(68, 231, 73)
		SkipWave.UIStroke.Color = Color3.fromRGB(34, 115, 35)
	else
		SkipWave.BackgroundColor3 = Color3.fromRGB(231, 5, 9)
		SkipWave.UIStroke.Color = Color3.fromRGB(115, 9, 10)
	end
end

function MatchController:StartGame()
	local Foreground = HealthFrame:WaitForChild("Foreground")
	local Healthbar = Foreground:WaitForChild("Bar")
	local TextFrame = HealthFrame:WaitForChild("TextFrame")
	local PressedSkip = false

	--if BtnCleaner then BtnCleaner:Destroy() end
	if not SkipBtnLoaded then
		SkipBtnLoaded = true
		
		BtnCleaner:GiveTask(SkipWave.Activated:Connect(function()
			warn("THE SKIP BUTTON WAS PRESSED HERE ", AllowPlacement.Value)
			if not AllowPlacement.Value then return end
			
			if not PressedSkip then
				PressedSkip = true
				autoSkip = not autoSkip
				
				--warn("PRESSED THE SKIP BUTTON ON THE PLAYER")
				Skip(autoSkip)
				MatchService.SkipWave:Fire(autoSkip)
				
				task.delay(1,function()
					PressedSkip = false
				end)			
			end
		end))
	end
	
	Wave.Text = "Wave: " .. CurrentWave.Value .."/" .. "∞"
	
	CurrentWave.Changed:Connect(function()
		Wave.Visible = true	
		if CurrentWave.Value > 0 and workspace.IsDefending.Value then
			self:Notify(`Wave {CurrentWave.Value} starting!`)
			Wave.Text = "Wave: " .. CurrentWave.Value .. "/" .. "∞"			
		end
	end)

	ShipHealth.Changed:Connect(function(Health)
		local HealthGui = workspace.Ship.PrimaryPart.HealthGui
		local HealthFrameForShip = HealthGui.HealthFrame
		local HealthBar = HealthFrameForShip.Frame.bar
		
		local Prop = {
			Value = Health/100
		}
		
		Shortcut:PlaySound("Tookdamage",true)

		local Prop1 = {
			Size = UDim2.new(Health/100,0,1,0)
		}
		
		if Health >= 100 then
			HealthBar.Size = UDim2.new(1,0,1,0)
		-- elseif Health <= 0 then
			
		end

		local Tween1 = TweenService:Create(HealthBar,TweenInfo.new(.5),Prop1)
		local Tween = TweenService:Create(BaseHealth,TweenInfo.new(1),Prop)
		
		Tween1:Play()
		Tween:Play()
		
		--HealthGui.Enabled = true
	end)
	
	if #game.Players:GetChildren() > 1 then
		local VotesValue = workspace:WaitForChild("Votes",30)
		warn("Activated CHECK FOR THE VALUES --> ", VotesValue)

		if VotesValue then 
			VoteSkip.Visible = true
			VoteSkip.TitleLabel.Text = VotesValue.Value.."/"..#game.Players:GetChildren()

			warn("WARN IF THIS VOTES DO ANYTHING ---> ", VotesValue.Value)
			VotesValue.Changed:Connect(function()
				VoteSkip.TitleLabel.Text = VotesValue.Value.."/"..#game.Players:GetChildren()
			end)
		end		
	end
	--self:ActivatePlacement()
end

function MatchController:KeepGroundLevel(Entity,RayVector: Vector3)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { workspace.Path }
	raycastParams.IgnoreWater = true

	RayVector = RayVector or Vector3.new(0, -15, 0)

	local Ray = Shortcut.RayCast(Entity.HumanoidRootPart.Position + Vector3.new(0,5,0), RayVector, raycastParams)

	if Ray then
		return Ray.Position
	end
end

function MatchController:GetEntity(Id,FloorName)
	local Floor  = Floors:FindFirstChild(FloorName)
	
	if Floor then
		local Entities = Floor.Room1.Entities
		
		for _,Entity in pairs(Entities:GetChildren()) do
			local EntityId = Entity:GetAttribute("Id")
			if EntityId == Id then
				return Entity
			end
		end
	end
end

function MatchController:PlayAnimation(Id,Animation,FloorName)
	local Npc = self:GetEntity(Id,FloorName)
	
	if Npc then
		local AnimationController = Npc.AnimationController
		local RootPart =  Npc:FindFirstChild("RootPart")
		
		if RootPart then		
			local AnimationTrack = AnimationController:LoadAnimation(Animation)
			AnimationTrack:Play()		
		end	
	else
		return warn("ANIMATION COULD NOT BE PLAYED")
	end
end

function MatchController:Notify(Text : string, Info : {Color : Color3, Time : number})
	Info = Info or {Time = 1, Color = Color3.fromRGB(56, 255, 56)}
	Info.Color = Info.Color or Color3.fromRGB(56, 255, 56)
	Info.Time = Info.Time or 1
	
	if not NotifyFrame:FindFirstChild(Text) then
		local newClone : TextLabel = Notify_lb:Clone()
		newClone.Text = Text
		newClone.TextColor3 = Info.Color
		newClone.Name = Text
		newClone.Visible = true
		newClone.Parent = NotifyFrame
		
		local Prop = {
			TextTransparency = 0
		}
		local Tween = TweenService:Create(newClone,TweenInfo.new(Info.Time),Prop)
		Tween:Play()
		
		task.delay(Info.Time,function()
			local Prop1 = {
				TextTransparency = 1
			}
			local Tween2 = TweenService:Create(newClone,TweenInfo.new(Info.Time),Prop1)
			Tween2:Play()
			
			Tween2.Completed:Connect(function()
				newClone:Destroy()
			end)
		end)	
	end
end

function MatchController:UpdateWave(Info) -- Can be improved, BUT WE NEED SPEED
	Wave.Visible = true
	
	MaxWave = Info.MaxWave
	-- self:Notify(`Wave {Info.Wave} starting!`)
	--Wave.Text = "Wave: " .. Info.Wave .. "/" .. Info.MaxWave
end

function MatchController:GiveReward(Frame, Rewards)
	--- THE FIRST TWO ARE EXCLUSIVE FOR MONEY AND EXP

	warn("YOU WON SO THIS IS YOUR REWARDS")
	Frame[1].Amount.Text = Rewards.Coins
	Frame[2].Amount.Text = Rewards.Exp
	
	for i = 3, #Frame:GetChildren() do
		local Slot = Frame:FindFirstChild(i)
		
		if Slot then
			-- ADD THE REST OF THE REWARDS
		end
	end
end

function MatchController:MatchEnded(Info)
	local EndFrame = if Info.result == "Win" then Core:WaitForChild("EndFrame") else Core:WaitForChild("Lost")
	local Buttons = EndFrame:WaitForChild("Buttons")
	local MainFrame = EndFrame:WaitForChild("Rewards")
	local Title = EndFrame:WaitForChild("Title")
	local BossMusic : Sound = workspace:FindFirstChild("BossMusic")
	local maid = Maid.new()

	local Prop = {
		Position = UDim2.new(0.5,0,0.5,0)
	}
	
	if BossMusic then
		BossMusic:Pause()
	end
	
	if Info.result == "Win" then
		Shortcut:PlaySound("Win",true)
	else
		Shortcut:PlaySound("Lost",true)
	end
	
	ToolbarUI.Visible = false
	Content.Visible = false
	--IntermissionFrame.Visible = false
	
	UpgradeUI.Visible = false
	EndFrame.Visible = true
	IntermissionUI.Visible = true

	-- Should display the rewards first
	warn("THE UI SHOULD SHOW UP: ", Info)
	self:GiveReward(MainFrame,Info)
	
	local Tween = TweenService:Create(EndFrame,TweenInfo.new(.5),Prop)
	Tween:Play()
	
	
	Title.Text = Info.result
	Title.TextColor3 = Info.Color
	
	--MainFrame.TempLabel.Text 
	maid:GiveTask(Buttons.Lobby.Activated:Connect(function()
		-- Teleport to lobby
		ToolbarUI.Visible = false
		EndFrame.Visible = false
		MatchService:SendToLobby()
		maid:Destroy()
	end))
	
	maid:GiveTask(Buttons.Play.Activated:Connect(function()
		-- Send remote(restart the game)
		BossMusic = workspace:FindFirstChild("BossMusic")
		
		for _,UI in pairs(ExtraUI:GetChildren()) do
			UI.Visible = false
		end
		
		if BossMusic then
			BossMusic:Stop()
		end
		
		Content.Visible = false
		ToolbarUI.Visible = false
--		IntermissionFrame.Visible = false
		EndFrame.Visible = false
		HealthFrame.Visible = false
		BaseHealth.Value = 1
		
		MatchService.Restart:Fire()
		maid:Destroy()
	end))
end

function MatchController:ShowDamageIndicator(Entity)
	local Health = Entity:GetAttribute("Health")
	local MaxHealth = Entity:GetAttribute("MaxHealth")

	local HealthGui = Entity.HealthGui
	local HealthFrameForEntity = HealthGui.HealthFrame
	local HealthBar = HealthFrameForEntity.Frame.bar 
	local Damagelabel = HealthGui.DamageTag

	local DamageClone = Damagelabel:Clone()

	local Prop = {
		Size = UDim2.new(Health/MaxHealth,0,1,0)
	}

	local DamageProp = {
		Size = UDim2.new(.2,0,.05,0),
		Position = UDim2.new(.5,0,.1,0),
		TextTransparency = 1
	}

	local Tween = TweenService:Create(HealthBar,TweenInfo.new(.5),Prop)
	Tween:Play()

	DamageClone.Text = MaxHealth - Health
	DamageClone.Parent = HealthGui
	DamageClone.Visible = true

	local DamageTween = TweenService:Create(DamageClone,TweenInfo.new(1.5),DamageProp)
	DamageTween:Play()

	DamageTween.Completed:Connect(function()
		DamageClone:Destroy()
	end)
end

function OnDeath(value : boolean)
	if value then
		OnDeathUI.Visible = value
		OnDeathUI.Position = UDim2.new(0,0,1,0)
	else
		OnDeathUI.Visible = value
		OnDeathUI.Visible = UDim2.new(0,0,0,0)
	end
end

function MatchController:OnDeath()
	local OnDeathContent = OnDeathUI:WaitForChild("Content")
	local RespawnUI = OnDeathContent:WaitForChild("Respawn")
	local Countdown = RespawnUI:WaitForChild("Countdown")
	local Yes_btn = RespawnUI:WaitForChild("Yes")
	local No_btn = RespawnUI:WaitForChild("No")
	local ReviveCountdown = workspace:WaitForChild("ReviveCountdown")
	local EnteredReviveUI = workspace:WaitForChild("EnteredReviveUI")

	local ReviveBtnCleaner = Maid.new()
	local Responded = nil
	local TweenProp = {
		Position = UDim2.new(0,0,0,0)
	}

	Countdown.Text = ReviveCountdown.Value

	OnDeathUI.Visible = true
	Content.Visible = false
	
	local Tween = TweenService:Create(OnDeathUI,TweenInfo.new(1),TweenProp)  
	Tween:Play()
	
	ReviveCountdown.Changed:Connect(function()
		Countdown.Text = string.format("%.2f",ReviveCountdown.Value)
	end)

	ReviveBtnCleaner:GiveTask(Yes_btn.Activated:Connect(function()
		Responded = true

		MatchService.ReviveRequest:Fire(nil,"OnProgress")	
		
		if EnteredReviveUI.Value <= 0 then
			MarketplaceService:PromptProductPurchase(player,reviveId)
		end
	end))
	
	ReviveBtnCleaner:GiveTask(No_btn.Activated:Connect(function()
		OnDeathUI.Visible = false
		OnDeathUI.Position = UDim2.new(0,0,1,0)
		Responded = false	

		if EnteredReviveUI.Value <= 0 then
			MatchService.ReviveRequest:Fire(Responded)
		end
	end))

	repeat
		task.wait(.1)
	until Responded ~= nil 

	return Responded
end

function MatchController:KnitStart()
	MatchService = Knit.GetService("MatchService")
	-- local Intermission = Core:WaitForChild("Intermission")
	local RewardService = Knit.GetService("RewardService")
	local StartGameFrame = Content:WaitForChild("StartGame")
	local StartGame_btn = Content:WaitForChild("StartGame").Button
	-- CountDown until it starts
	local Money_lb = Content:WaitForChild("Cash")
	
	local CashValue = player:FindFirstChild("Cash")
	local MaxPlacement = player:FindFirstChild("PlacementAmount")

	if CashValue then
		Money_lb.Text = "$ " .. CashValue.Value
		
		CashValue.Changed:Connect(function()
			Money_lb.Text = "$ " .. CashValue.Value
		end)		
	end

	MatchService.SkipWave:Connect(function(Value)
		autoSkip = false
		Skip(Value)
	end)

	MatchService.ReviveRequestAccepted:Connect(function(Accpted : boolean)
		-- Accpted = Accpted or true
		if Accpted then
			OnDeath(Accpted)
			Content.Visible = true
			HealthFrame.Visible = false
		else
			OnDeath(Accpted)
			HealthFrame.Visible = false
			OnDeathUI.Visible = false
			Content.Visible = false
		end
		
	end)

	MatchService.PlayAnimation:Connect(function(Id,OriginalName,AnimationValue,FloorName)
		local _,_ = pcall(function()
			self:PlayAnimation(Id,EntityInfo[OriginalName][AnimationValue],FloorName)
		end)
	end)	
	
	MatchService.DamageIndicator:Connect(function(Entity,_)
		if not Entity:FindFirstChild("HealthGui") then return end
		self:ShowDamageIndicator(Entity)
	end)
	
	MatchService.MatchEnded:Connect(function(Data)
		self:MatchEnded(Data)
	end)
	
	MatchService.ReviveRequest:Connect(function()
		self:OnDeath()
	end) 

	MatchService.StartCountDown:Connect(function(RoomData)
		local HealthGui = workspace.Ship.PrimaryPart.HealthGui
		local HealthFrameForShip = HealthGui.HealthFrame
		local HealthBar = HealthFrameForShip.Frame.bar 
		IsDefending = false
		
		warn("[ ROOMINFO ] - ", RoomData)
		
		if MaxPlacement then
			
			Wave.Text = "Wave: " .. 0 .. "/" .. #RoomData.Waves
			
			ExtraUI:WaitForChild("MaxPlacement").Text = "MaxPlacement: ".. MaxPlacement.Value .." / " .. RoomData.MaxPlacement
			ExtraUI:WaitForChild("MaxPlacementShadow").Text = "MaxPlacement: ".. MaxPlacement.Value .." / " .. RoomData.MaxPlacement
			
			MaxPlacement.Changed:Connect(function()
				if MaxPlacement.Value >= RoomData.MaxPlacement then
					self:Notify(`You have surpassed the placement limit!`,Color3.fromRGB(255,0,0))
				end
				
				ExtraUI:WaitForChild("MaxPlacement").Text = "MaxPlacement: ".. MaxPlacement.Value .." / " .. RoomData.MaxPlacement
				ExtraUI:WaitForChild("MaxPlacementShadow").Text = "MaxPlacement: ".. MaxPlacement.Value .." / " .. RoomData.MaxPlacement
			end)
		end
		
		StartGame_btn.Visible = true
		
		task.spawn(function()
			local Progress = StartGameFrame:WaitForChild("Progress")
			local ValueToStart = workspace:FindFirstChild("VoteToStartGame")
			local MatchCooldown = workspace:FindFirstChild("MatchStartCountDown")
			local Bar = Progress:WaitForChild("Bar")
			local Fill = Bar:WaitForChild("Fill")
			local Amount = Bar:WaitForChild("Amount")
						--- Reset the bars
			Fill.Size = UDim2.new(1,0,1,0)
			HealthBar.Size = UDim2.new(1,0,1,0)
			StartGame_btn.TextLabel.Text = " 0 / " .. #game.Players:GetChildren() .. " START GAME!"
			
			if ValueToStart then
				ValueToStart.Changed:Connect(function()
					StartGame_btn.TextLabel.Text = ValueToStart.Value .. " / " .. #game.Players:GetChildren() .. " START GAME!"
					
					if ValueToStart.Value >= # game.Players:GetChildren() then
						IsDefending = true
						
						UpgradeUI.Visible = false
						StartGameFrame.Visible = false
						IntermissionFrame.Visible = false
						ToolbarUI.Visible = true
						Money_lb.Visible = true
					end	
				end)
			end
			
			if MatchCooldown then
				
				MatchCooldown.Changed:Connect(function()
					local Prop = {
						Size = UDim2.new(MatchCooldown.Value/30,0,1,0)
					}

					local Tween = TweenService:Create(Fill,TweenInfo.new(1),Prop)
					Tween:Play()

					if MatchCooldown.Value <= 0 then
						warn("[ INFO ] - GAME HAS STARTED DUE TO COUNTDOWN")
						StartGameFrame.Visible = false
						IntermissionFrame.Visible = false
						ToolbarUI.Visible = true
						Money_lb.Visible = true
						self:StartGame()
					end
					
					Amount.Text = "" .. string.format("%.2f",MatchCooldown.Value) .. ""			
				end)
				
			end
			
		end)
	end)
	
	MatchService.UpdateWave:Connect(function(Info)
		self:UpdateWave(Info)
	end)
	
	MatchService.DisableShipVelocity:Connect(function()
		for _,parts in pairs(workspace.Ship:GetChildren()) do
			if parts:IsA("BasePart") or parts:IsA("TrussPart") or parts:IsA("MeshPart") then
				parts.AssemblyLinearVelocity = Vector3.new(0,0,0)
			end
		end
	end)
	
	local bossMusic = true
	local SoundForBoss
	
	MatchService.SendNotification:Connect(function(Notice : string, Color : Color3)
		self:Notify(Notice,Color)
	end)
	
	RewardService.SendNotification:Connect(function(Notice : string, Color : Color3)
		self:Notify(Notice,Color)
	end)
	
	MatchService.ActivateBoss:Connect(function(Health,MaxHealth)
		local HealthFrame = Core:WaitForChild("HealthFrame")
		local Foreground = HealthFrame:WaitForChild("Foreground")
		local Healthbar = Foreground:WaitForChild("Bar")
		local TextFrame = HealthFrame:WaitForChild("TextFrame")
		if not HealthFrame.Visible then self:Notify(`Boss arriving!`) SoundForBoss = Shortcut:PlaySound("BossMusic") end
		
		HealthFrame.Visible = true
		
		bossMusic = false
		TextFrame.Health.Text = Health .. " / " .. MaxHealth
		TextFrame.HealthShadow.Text = Health .. " / " .. MaxHealth
		
		local Prop = {
			Size = UDim2.new(Health/MaxHealth,0,1,0)
		}
		
		local Tween = TweenService:Create(Healthbar,TweenInfo.new(1),Prop)
		Tween:Play()
		
		if Health <= 0 then
			--self:Notify(`Defeat the boss!`)
			HealthFrame.Visible = false
			SoundForBoss:Stop()
		end
		
		TextFrame.Health.Text = Health .. " / " .. MaxHealth
		TextFrame.HealthShadow.Text = Health .. " / " .. MaxHealth
	end)
	
	Core:WaitForChild("SpawnAttacker").MouseButton1Down:Connect(function()
		MatchService.SpawnAmount:Fire()
	end)
	--local GameStarted = false 
	
	StartGame_btn.Activated:Connect(function()
		
		if #game.Players:GetChildren() <= 1 then
			StartGameFrame.Visible = false
			IntermissionFrame.Visible = false
			ToolbarUI.Visible = true
			Money_lb.Visible = true
		end
		
		MatchService.Start:Fire()
		GuiService.SelectedObject = nil
		GuiService:AddSelectionParent("Placement",ToolbarUI)
		self:StartGame()
	end)
end

function MatchController:KnitInit()

end

return MatchController
