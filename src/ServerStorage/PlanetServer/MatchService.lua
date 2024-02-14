--- HANDLES THE THE GAME WHEN THE PLAYER HAS JOINED ---
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local SharedPackages = ReplicatedStorage.SharedPackage

local Assets = ServerStorage.Assets
local Entities = Assets.Entities -- The ones attacking
local Particles = ReplicatedStorage.Assets.Particles
local Units = require(SharedPackages.Units)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Shortcut = require(ReplicatedStorage.Shortcut)
local Difficulties_Modules = ReplicatedStorage.Difficulties
local Difficulties = require(Difficulties_Modules)
local Zone = require(ReplicatedStorage.Zone)
local Maid = require(ReplicatedStorage.maid)

local Floors = workspace.Floors
local MatchFolder = workspace.MatchFolder
local GameService;
local AutoActivated = false
local CountDownOnGoing = false
local WaveIsRunning = false
local gameStop = false
local AllowPlacement = workspace.AllowPlacement
local Skipped = workspace.Skip
local CurrentWave = workspace.CurrentWave
local ValueFolder = workspace.Values
local MapautoPicked = false
local GameIsPaused = false
local RevivePlayer = false --- This is true when the game starts, but then becomes false if the offer to revive gets decline
local SkippedSaved = {}

local MatchService = Knit.CreateService {
	Name = "MatchService";
	Client = {
		HealthUpdate = Knit.CreateSignal(),
		Start = Knit.CreateSignal(),
		AllowPlacement = Knit.CreateSignal(),
		SpawnAmount = Knit.CreateSignal(),
		GameCompleted = Knit.CreateSignal(),
		Play = Knit.CreateSignal(), -- This is fired whilst selecting a room in intermission
		CloseIntermission = Knit.CreateSignal(),
		StartCountDown = Knit.CreateSignal(),
		PlayAnimation = Knit.CreateSignal(),
		UpdateWave = Knit.CreateSignal(),
		DamageIndicator = Knit.CreateSignal(),
		GetVotes = Knit.CreateSignal(),
		MatchEnded = Knit.CreateSignal(),
		ActivateBoss = Knit.CreateSignal(),
		Restart = Knit.CreateSignal(),
		SkipWave = Knit.CreateSignal(),
		DisableShipVelocity = Knit.CreateSignal(),
		ContinueRequest = Knit.CreateSignal(),
		SendToLobby = Knit.CreateSignal(),
		SendNotification = Knit.CreateSignal(),
		ReviveRequest = Knit.CreateSignal(),
		ReviveRequestAccepted = Knit.CreateSignal(),
		GetPlayersFloors = Knit.CreateSignal()
	}
}

type profile = {
	[string] : {Money : number, MaxPlacement : number}
}

local LatestVote = {}
local DefaultProfile = { Money = 0, MaxPlacement = 0 }
local DeadAttackers = 0

local playerProfiles : profile = {}

local canRestart = true
local Debug = false
local IsDefending = workspace.IsDefending
local DefaultWaitUntilNextWave = 5 -- seconds
local lost_match = workspace.MatchLost
local reviveId = 1754721725


-- local Difficulties_nr = {
-- 	[1] = "Easy";
-- 	[2] = "Medium";
-- 	[3] = "Hard";
-- }

function MatchService.Client:SendToLobby(player)
	TeleportService:TeleportAsync(tonumber(15696748025),{player})
end


function MatchService:GetNodes(Room)
	local Node_Folder = Room.Nodes:FindFirstChildWhichIsA("Folder")
	local Nodes = {}
	
	if not Node_Folder then -- if the room only has one directional path
		for i = 1, #Room.Nodes:GetChildren() do
			local part = Room.Nodes[i]

			if Debug then
				part.Material = Enum.Material.Neon
				part.Color = Color3.fromRGB(255,0,0)
			end		
			Nodes[i] = part.Position
		end
		
		table.insert(Nodes,MatchFolder.End.Position)
	else
		for i = 1, #Room.Nodes:GetChildren() do
			local Folder = Room.Nodes:GetChildren()[i]
			Nodes[Folder.Name] = {}
			
			----warn("[ Folder ] - ", Folder)
			for x = 1, #Folder:GetChildren() do
				local part = Folder[x]

				if Debug then
					part.Material = Enum.Material.Neon
					part.Color = Color3.fromRGB(255,0,0)
				end

				Nodes[Folder.Name][x] = part.Position
			end

			Nodes[Folder.Name][#Nodes[Folder.Name] + 1] = MatchFolder.End.Position
		end
	end

	--warn("[ INFO ] - ",Nodes, Room.Nodes:GetChildren())

	return Nodes
end

function MatchService:CreateNodes(Waypoints)
	local function Node(Position,Name)
		local node = Instance.new("Part")
		node.Size = Vector3.new(1,1,1)
		node.Position = Position
		node.Name = Name
		node.Anchored = true
		node.Parent = workspace.Nodes
	end	

	for i = 1,#Waypoints do
		Node(Waypoints[i].Position,i)
	end
end

function MatchService.Client:ChapterInfo(player)
	return Difficulties
end

function MatchService:KeepGroundLevel(RootPart : BasePart,RayVector: Vector3)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { MatchFolder.Path }
	raycastParams.IgnoreWater = true

	RayVector = RayVector or Vector3.new(0, -50, 0)

	local Ray_Cast = Shortcut.RayCast(RootPart.Position, RayVector, raycastParams)

	if Ray_Cast then
		if Ray_Cast.Position.Magnitude > 0 then
			return Ray_Cast.Position,Ray_Cast.Normal,Ray_Cast.Instance
		else
			--warn("ERROR COULD NOT FIND THE PROBLEM ", Ray_Cast)
			return RootPart.Position
		end
	end
end

function MatchService:FollowNodes(Entity,Nodes,WaveInfo,OptinalPath)
	local Speed = .1
	local CurrentNode = 1
	local Offset = 1
	local HeightOffset = Entity:GetAttribute("HeightOffset") or .25
	local Position,RayNormal,_ = self:KeepGroundLevel(Entity.RootPart)
	local Normal
	
	local function getAngle(NormalVector : Vector3)
		if not Entity:GetAttribute("RotateRot") or Entity:GetAttribute("Ignore") == MatchFolder.Parent:GetAttribute("FloorName") then return 0 end
		local Angle = math.deg(math.acos(NormalVector:Dot(Vector3.yAxis)))
		
		if NormalVector:Dot(Entity:GetPivot().Position) < 0 then
			Angle = -math.deg(math.acos(NormalVector:Dot(Vector3.yAxis)))
		end
				
		return Angle
	end
	
	local function ChoosenPath(Direction)
		for _,path in pairs(Nodes) do
			if typeof(path) == "table" and (not Direction or Direction == "") then
				return path
			elseif typeof(path) == "table" and Direction then
				return Nodes[Direction]
			else
				return Nodes
			end
		end
	end

	local Direction = OptinalPath or WaveInfo["Direction"]

	Nodes = ChoosenPath(Direction)
	while Entity:GetAttribute("IsActive") do
		if Entity:FindFirstChild("RootPart") and IsDefending.Value then
			local Distance = (Vector3.new(Entity.RootPart.Position.X, Nodes[CurrentNode].Y,Entity.RootPart.Position.Z) - Nodes[CurrentNode]).Magnitude
			Position,RayNormal = self:KeepGroundLevel(Entity.RootPart)
			Normal = getAngle(RayNormal) -- needs some tweaks
			
			local TweenProp 
			local Walkspeed = Entity:GetAttribute("Speed")
			local useAngle = if Entity:GetAttribute("Inverted") then CFrame.Angles(math.rad(Normal),math.rad(180),0) else CFrame.Angles(math.rad(Normal),0,0)
			--Speed = tonumber(Entity:GetAttribute("Speed"))
			
			if Walkspeed < 0 then 
				Entity:SetAttribute("Speed",0) 
				Walkspeed = 0 
			end
			
			TweenProp = {
				CFrame = CFrame.new(
					Vector3.new(
						Entity.RootPart.Position.X,
						Position.Y + (Entity.RootPart.Size.Y / 2) + HeightOffset, --- Keeps the attacker on the ground and not hovering
						Entity.RootPart.Position.Z
					),
					Vector3.new(
						Nodes[CurrentNode].X,
						Entity.RootPart.Position.Y, --+ math.clamp(Normal,-10,10),
						Nodes[CurrentNode].Z
					)
				) * useAngle + Entity.RootPart:GetPivot().LookVector * (Walkspeed/10),
			}

			local Movement : TweenBase = TweenService:Create(Entity.RootPart,TweenInfo.new(Speed),TweenProp)
			Movement:Play()

			if Distance <= Offset then
				CurrentNode += 1
			elseif CurrentNode > #Nodes then
				Entity:SetAttribute("IsActive", false)
			end	
		end

		task.wait()
	end
end

function checkForHealth()
	local Children = MatchFolder.Entities:GetChildren()

	if #Children > 1 then --- Added for the waves not ending
		for _,entities in pairs(Children) do
			local Health = entities:GetAttribute("Health")
			if (Health <= 0) or (not entities:GetAttribute("IsActive")) then
				task.delay(1,game.Destroy,entities)
			end
		end
	end
end

function MatchService:SpawnEntity(Name : string, WaveInfo, Nodes) 	--- Get the entities data & apply it
	local Entity = Entities:FindFirstChild(Name)

	local function onDescendantAdded(descendant)
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = "Attackers"
		end
	end

	local function onCharacterAdded(character)
		for _, descendant in pairs(character:GetDescendants()) do
			onDescendantAdded(descendant)
		end
		character.DescendantAdded:Connect(onDescendantAdded)
	end

	if Entity then
		local SpawnLocation = WaveInfo["Spawnlocation"] or "Start"
		local Id = math.random(-10000,10000)
		local newEntity = Entity:Clone()
		local Map = MatchFolder.Parent:FindFirstChild("Map")		
		local SpawnCheck;
		
		local _,err = pcall(function()
			SpawnCheck = MatchFolder[SpawnLocation]
		end)
		
		if err then return end
		
		-- local Position = self:KeepGroundLevel(SpawnCheck)
		local Dead = false
		local AmountOfplayers = #game.Players:GetPlayers()
		local Health;
		
		newEntity:PivotTo(SpawnCheck.CFrame + Vector3.new(0,newEntity:GetAttribute("HeightOffset") or 0 ,0))
		newEntity:SetAttribute("Id",Id)
		newEntity:SetAttribute("IsActive", true)

		newEntity:SetAttribute("Health",WaveInfo["HP"] * AmountOfplayers)
		newEntity:SetAttribute("MaxHealth",WaveInfo["HP"] * AmountOfplayers)
		newEntity:SetAttribute("Speed",WaveInfo["Speed"])
		newEntity:SetAttribute("Original",newEntity.Name)
		newEntity:AddTag("Entities")

		newEntity.Name = Id
		newEntity.Parent = MatchFolder.Entities

		onCharacterAdded(newEntity)

		local HealthGui = newEntity.HealthGui
		local HealthFrame = HealthGui.HealthFrame
		local HealthLabel = HealthFrame.HealthLabel
		local HealthBar = HealthFrame.Frame.bar
		local Damagelabel = HealthGui.DamageTag
		local OnDeathParticle = Particles:FindFirstChild("OnDeath")
		
		local Attachment
		local DebugUI = ReplicatedStorage.DebugUI:Clone()
		DebugUI.InfoLabel.Text = "Id : " .. newEntity:GetAttribute("Id")
		DebugUI.Parent = newEntity.RootPart
		DebugUI.Enabled = Debug

		local function OnDeath()
			for _,parts in pairs(newEntity:GetChildren()) do
				if parts:IsA("BasePart") then
					parts.Transparency = 1
				end
			end
			
			for _,particlesEmitter : ParticleEmitter in pairs(Attachment:GetChildren()) do
				if particlesEmitter:IsA("ParticleEmitter") then
					particlesEmitter:Emit(15)
				end
			end
			
			task.delay(.5,function()
				newEntity:Destroy()
			end)
		end
	
		if OnDeathParticle then
			Attachment = OnDeathParticle.Attachment:Clone()
			Attachment.Parent = newEntity.RootPart
		end

		HealthLabel.Text = newEntity:GetAttribute("Health") .. "/" .. newEntity:GetAttribute("MaxHealth")
		
		if Map and WaveInfo["IsBoss"] then
			local FloorMusic = Map:FindFirstChild("Floor")
			
			if FloorMusic then
				FloorMusic:Destroy()
			end
			
			newEntity:SetAttribute("IsBoss",true)
			self.Client.ActivateBoss:FireAll(newEntity:GetAttribute("Health"),newEntity:GetAttribute("MaxHealth"))
		end
		
		newEntity:GetAttributeChangedSignal("Health"):Connect(function()
			local Health = newEntity:GetAttribute("Health")
			local MaxHealth = newEntity:GetAttribute("MaxHealth")
			
			HealthLabel.Text = Health .. "/" .. MaxHealth
			
			if WaveInfo["IsBoss"] then
				self.Client.ActivateBoss:FireAll(Health,newEntity:GetAttribute("MaxHealth"))
				
				if Health <= 0 then 
					newEntity:SetAttribute("Health",0) 
				end
			end
			
			if WaveInfo["IsBoss"] and Health <= 0 then -- This is for the match not ending
				warn("[ BOSS HAS BEEN DEFEATED ]")
				checkForHealth()
			end
			
			if Health > 0 then
				self.Client.DamageIndicator:FireAll(newEntity)	
				
				if WaveInfo["IsBoss"] and Health >= 0 then
					self.Client.ActivateBoss:FireAll(Health,newEntity:GetAttribute("MaxHealth"))
				end
			end

			task.delay(.2,function()
				if Health <= 0 and not Dead then
					OnDeath()
					Dead = true
					DeadAttackers += 1
					newEntity:SetAttribute("IsActive", false)
					--newEntity:Destroy()
				end
			end)
		end)

		self.Client.PlayAnimation:FireAll(Id,newEntity:GetAttribute("Original"),"Walk",MatchFolder.Parent.Name)
		
		task.spawn(function()
			if MatchFolder:FindFirstChild(SpawnLocation) then
				local PathToTake = MatchFolder[SpawnLocation]:GetAttribute("Path")
				self:FollowNodes(newEntity,Nodes,WaveInfo,PathToTake)
			end	
		end)
		
		return newEntity
	end
end

function MatchService:FindRoomOrFloor(Data,ToFind)
	for key,value in pairs(Data) do
		if key == ToFind then
			return true
		end
	end
	return false
end

function MatchService:SelectItemByPercentage(items)
    local totalPercentage = 0
    for _, item in ipairs(items) do
        totalPercentage = totalPercentage + item.Percentage
    end
    
	local randomPercentage = math.random() * 100 
    local accumulatedPercentage = 0
    
    for _, item in ipairs(items) do
        accumulatedPercentage = accumulatedPercentage + item.Percentage
        if randomPercentage <= accumulatedPercentage then
            return item
        end
    end
    
    return nil
end

function MatchService:GameEnded(Info)
	-- Show reward depending if the player has finished the map
	local ProfileService = Knit.GetService("ProfileService")
	local QuestService = Knit.GetService("QuestService")
	local FloorName = Floors["Floor" .. Info.Floor]:GetAttribute("FloorName")
	local RescievedReward = {}
	local HasResponed = nil
	
	local DifficultiesValues = {
		["Easy"] = 1,
		["Medium"] = 2,
		["Hard"] = 3,
		["Insane"] = 4,
		["Impossible"] = 5,
		-- Add one more
	}

	local ClearFolders = {
		"Entities","Units","Detectors"
	}
	
	local ClearFoldersForRevive = {
		"Entities"
	}
	
	local function ClearTheMap()
		for i = 1, #ClearFoldersForRevive do
			local Folder = MatchFolder:FindFirstChild(ClearFoldersForRevive[i])
			
			if Folder then
				Folder:ClearAllChildren()
			end
		end
	end

	local function GetUnitsCount()
		local count = 0
		local UnitsFolder =MatchFolder:FindFirstChild("Units")
		if UnitsFolder then
			for _ = 1, #UnitsFolder:GetChildren() do
				count += 1			
			end
			
			return count
		end

		return 0
	end

	if Info.result == "Lose" and GetUnitsCount() >= 1 and canRestart then --- Check if player has placed a  unit else If player lose then ask if he wants to revive
		local ReviveConnection : RBXScriptConnection;
		-- local dt_time = 0
		local MaxWaitTime = 10
		GameIsPaused = true
		canRestart = false
		
		local ReviveCountdown = Instance.new("NumberValue")
		ReviveCountdown.Name = "ReviveCountdown"
		ReviveCountdown.Parent = workspace
		ReviveCountdown.Value = MaxWaitTime

		--- This is so that only one player in a multiplayer lobby buys the gamePass
		local EnteredReviveUI = Instance.new("IntValue")
		EnteredReviveUI.Name = "EnteredReviveUI"
		EnteredReviveUI.Parent = workspace
		EnteredReviveUI.Value = 0

		self.Client.ReviveRequest:FireAll(true)

		ReviveConnection = self.Client.ReviveRequest:Connect(function(sender,Answer)
			
			if Answer == "OnProgress" then
				EnteredReviveUI.Value += 1
			end
			
			if Answer then
				print("[ THIS SHOULD BE FLAGGED AS A HACKER ]")
				HasResponed = false
				sender:Kick("You have been flagged as a hacker")
			end
		end)
		
		MarketplaceService.ProcessReceipt = function(receiptInfo)
			local buyer = Players:GetPlayerByUserId(receiptInfo.PlayerId)
			if not buyer then
				HasResponed = false
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end

			if receiptInfo.ProductId == reviveId then
				
				if #game.Players:GetChildren() > 1 then
					self.Client.SendNotification:FireAll(`{buyer.Name} revived everyone`,{Color = Color3.fromRGB(238, 255, 0), Time = 2})
				end

				HasResponed = true
				MarketplaceService.ProcessReceipt = nil
			end
		end

		repeat 
			if ReviveCountdown.Value <= 0 then
				HasResponed = false;
				break;
			end
			
			ReviveCountdown.Value -= RunService.Heartbeat:Wait()			
			ClearTheMap()
		until HasResponed ~= nil
		
		EnteredReviveUI:Destroy()
		ReviveCountdown:Destroy()

		if HasResponed then
			ValueFolder.Health.Value = 100
			AllowPlacement.Value = true
			lost_match.Value = false
			RevivePlayer = true
			GameIsPaused = false

			self.Client.ReviveRequestAccepted:FireAll(true)
			ReviveConnection:Disconnect()
			return "Continue"
		else
			GameIsPaused = false
		 	MarketplaceService.ProcessReceipt = nil
			self.Client.ReviveRequestAccepted:FireAll(false)
			ReviveConnection:Disconnect()
		end
	end

	for i = 1, #ClearFolders do
		local Folder = MatchFolder:FindFirstChild(ClearFolders[i])
		if Folder then
			Folder:ClearAllChildren()
		end
	end

	IsDefending.Value = false
	Skipped.Value = false
	
	local Blur = Instance.new("BlurEffect")
	Blur.Parent = game.Lighting
	
	if Info.result == "Win" then
		GameService:RewardWinToAllPlayers()
	end

	-- Give rewards and save map if completed
	for _,player in pairs(game.Players:GetChildren()) do		
		task.spawn(function()
			local CurrentPlayerData = ProfileService:Get(player,"Floors")
			
			if Info.result == "Win" then
				local Room = CurrentPlayerData[tonumber(Info.Floor)] -- This is the 
				
				if not Room then
					CurrentPlayerData[tonumber(Info.Floor)] = 1

					ProfileService:Update(player, "Floors", function(FloorsData)
						FloorsData = CurrentPlayerData
						warn("FLOOR HAS BEEN SAVED  FOR A WHILE --> ", FloorsData)
						return FloorsData
					end)
				end
				 if Room >= tonumber(DifficultiesValues[Info.Room]) then --- This makes the other acts optional, should change
					local succ,_ = pcall(function()
						CurrentPlayerData = ProfileService:Get(player,"Floors")
					end)
					
					if succ then
						local RoomAmount = #Difficulties_Modules[FloorName]:GetChildren() -- Fix this to the amount of Difficulties
						CurrentPlayerData[tonumber(Info.Floor)] = CurrentPlayerData[tonumber(Info.Floor)] + 1
						
						if CurrentPlayerData[tonumber(Info.Floor)] > tonumber(RoomAmount) and not CurrentPlayerData[tonumber(Info.Floor + 1)] then
							CurrentPlayerData[tonumber(Info.Floor + 1)] = 1
						end
						
						ProfileService:Update(player, "Floors", function()
							return CurrentPlayerData
						end)
					else
						warn("Could not get the players data --> ", player.UserId)
					end
				end				
			end
		end)

		if not RescievedReward[player.Name] then
			RescievedReward[player.Name] = true
			local AmountScrap = GameService:RewardScrap(player,Info.Coins)
			Info["Coins"] = AmountScrap
			Info["Exp"] = math.ceil(Info.Exp)
		
			QuestService:AddEXP(player, Info.Exp)
		
			self.Client.MatchEnded:Fire(player,Info)
		end

		--player.Character.Humanoid.WalkSpeed = 0
	end
	--warn("[ THE GAME WAS ENDED ]")
end

function MatchService:OrderByPriority(CurrentWaveTable)
	local waitTable = {}
	local AmountForWave = 0
	--warn("ORDER BEFORE SORT: ", CurrentWave.Value)

	table.sort(CurrentWaveTable,function(a,b)
		return a["Priority"] < b["Priority"]
	end)

	for i = 1,#CurrentWaveTable do
		local Entity = CurrentWaveTable[i]
		local fraction = tonumber(Entity["Priority"]) % 1
		AmountForWave += Entity["Amount"]
		if fraction ~= 0 then
			waitTable[i] = fraction * 100 -- Gets the fraction and turns it into seconds
		else
			waitTable[i] = DefaultWaitUntilNextWave
		end
	end

	--warn("ORDER AFTER SORT: ", CurrentWave.Value,waitTable)
	return CurrentWaveTable,waitTable,AmountForWave
end

function MatchService:GiveMoney(Amount : number,Info)
	local QuestService = Knit.GetService("QuestService")
	local RescievedReward = {}

	for _,player in pairs(game.Players:GetChildren()) do
		local Cash = player:FindFirstChild("Cash")
		
		if Cash then
			QuestService:AddToQuestType(player, "DefeatEnemies", DeadAttackers)
			Cash.Value += Amount
			
			if not RescievedReward[player.Name] then
				RescievedReward[player.Name] = true
				GameService:RewardScrap(player,Info.CompletionRewards.Wave)
			end
			
		end
	end
end

function MatchService:GetFloorAndRoom(MapInfo)
	local nrFloor = string.match(MapInfo.Floor,"%d+")
	local nrRoom = string.match(MapInfo.Room,"%d+")
	
	return tonumber(nrFloor), tonumber(nrRoom)
end

function MatchService:StartGame(MapInfo)
	if WaveIsRunning then return end
	
	WaveIsRunning = true
	
	local CurrentFloor = Floors[MapInfo.Floor]
	local Room = CurrentFloor[MapInfo.Room]
	MatchFolder = Room
	--warn("[ INFO ] - THE DIFFICULTY ", Difficulties, CurrentFloor:GetAttribute("FloorName"), MapInfo)

	local Heart = Room.End
	local Nodes = self:GetNodes(Room)
	local Health = ValueFolder.Health
	local dmg = 10 -- Temp
	local Room_Difficulty = Difficulties[CurrentFloor:GetAttribute("FloorName")][MapInfo.Difficulty]
	local Waves = Room_Difficulty["Waves"]
	local Attackers = 1
	local Map = CurrentFloor:FindFirstChild("Map")
	local players = #game.Players:GetChildren()
	local Ship = workspace.Ship
	local Detector : MeshPart = Ship.Detector
	
	--- OverLaps ----
	local overlapsForShip = OverlapParams.new()
	overlapsForShip.FilterType = Enum.RaycastFilterType.Exclude
	overlapsForShip.MaxParts = 5
	overlapsForShip.FilterDescendantsInstances = { Ship }
	
	local overlaps = OverlapParams.new()
	overlaps.FilterType = Enum.RaycastFilterType.Include
	overlaps.MaxParts = 5
	overlaps.FilterDescendantsInstances = { MatchFolder.Entities }
	
	-----------------
	
	MatchFolder:SetAttribute("MaxPlacement", Room_Difficulty.MaxPlacement)
	self.Client.UpdateWave:FireAll({Wave = CurrentWave.Value,MaxWave = #Waves})
	AllowPlacement.Value = true
	warn("TELLING THE AMOUNT OF PLAYERS ---> ", players)
	
	if Map then
		local FloorMusic = Map:FindFirstChild("Floor")
		if FloorMusic then
			FloorMusic:Play()
		end
	end
	
	GameService:SetMap(string.lower(CurrentFloor:GetAttribute("FloorName")))
	lost_match.Value = false	
	Health.Value = 100

	local GetPartsInShip = workspace:GetPartsInPart(Detector,overlapsForShip)
	
	for i, part in pairs(GetPartsInShip) do
		local HumanoidRootPart = part.Parent:FindFirstChild("HumanoidRootPart")
		if HumanoidRootPart then
			HumanoidRootPart.CFrame = Ship["p"..i].CFrame
			---Humanoid.WalkSpeed = 16
		end
	end
	
	--- DAMAGE DETECTOR ---
	task.spawn(function()
		while IsDefending.Value do
			local heartZone = workspace:GetPartsInPart(Heart,overlaps)
			for _,Parts in pairs(heartZone) do
				local RootPart = Parts.Parent:FindFirstChild("RootPart")
				----warn("[ HEART ] - ENTERED ", Parts)
				if RootPart then
					local Character = RootPart.Parent
					Character:SetAttribute("IsActive", false)
					if game.Players:GetPlayerFromCharacter(Character) then return end --- so that the players character doesn't get deleted

					Health.Value -= dmg
					DeadAttackers += 1
					
					--self.Client.HealthUpdate:FireAll(Health.Value)
					
					if Health.Value <= 0 or Character:GetAttribute("IsBoss") then
						-- Game completed
						gameStop = true
						lost_match.Value = true
						AllowPlacement.Value = false
						WaveIsRunning = false
						CountDownOnGoing = false
						self:GameEnded({Coins = Room_Difficulty.CompletionRewards.Difficulty * 0.10, Exp = Room_Difficulty.CompletionRewards.Exp * 0.10, result = "Lose", Color = Color3.fromRGB(255,0,0),Room = MapInfo.Difficulty, Floor = string.match(MapInfo.Floor,"%d+")})
					end
					Character:Destroy()

					break;
				end
			end
			task.wait()
		end
	end)

	local lastPlayerAction = {}  -- Table to store the timestamp of the last action for each player

	local function playerFunction(player, autoSkip)
		if not IsDefending.Value then return end
		
		local Votes = workspace:FindFirstChild("Votes")
		local currentTime = tick()  -- Get the current time
		local cooldownDuration = 1  


		if Votes and Votes.Value > #game.Players:GetChildren() then
			Votes.Value = game.Players:GetChildren()
		end
		
		if not lastPlayerAction[player] or currentTime - lastPlayerAction[player] >= cooldownDuration then
			if Votes and table.find(SkippedSaved, player.Name) then
				local playerPos = table.find(SkippedSaved, player.Name)
				Votes.Value -= 1
				warn("Removing", player.Name, "from the skip list.")

				task.delay(.5, function()
					table.remove(SkippedSaved, playerPos)
				end)
			elseif Votes and table.find(SkippedSaved, player.Name) == nil then
				Votes.Value += 1
				table.insert(SkippedSaved, player.Name)
				warn("Adding", player.Name, "to the skip list.")
			end

			lastPlayerAction[player] = currentTime  -- Update the last action timestamp for this player
		else
			-- If the cooldown has not expired, do nothing
			warn("Cooldown active for", player.Name)
		end
		
		if CurrentWave.Value ~= #Waves and players == 1 then
			Skipped.Value = autoSkip
			print("Solo player has voted to autoskip" , autoSkip)
		elseif Votes and CurrentWave.Value ~= #Waves and players >= 1 and Votes.Value >= players then
			-- Send the Skipwave signal back 
			Skipped.Value = true
			print("WE HAVE STARTED SKIPPING")

		elseif Votes and CurrentWave.Value ~= #Waves and players >= 1 and Votes.Value < players then
			Skipped.Value = false
			print("WE HAVE STOPPED SKIPPING")
		end
	end
	
	if not AutoActivated then
		AutoActivated = true	
		self.Client.SkipWave:Connect(playerFunction)
	end

	--[[
		AutoSkip
		AutoSkip set to true
		
		If AutoSkip and #Entities >= 0 and CurrentWave.Value == #Waves then
			--- Don't complete until #Entities is == 0
		elseif AutoSkip and CurrentWave.Value ~= #Waves then
			-- Skip into the next wave
		end
	--]]
	
	local function getBoss()
		local EntitiesInMatch = MatchFolder.Entities:GetChildren()
		
		for _,monsters in pairs(EntitiesInMatch) do
			local IsBoss = monsters:GetAttribute("IsBoss")
			
			if IsBoss then
				return true
			end
		end
		
		return false
	end
	
	self.Client.UpdateWave:FireAll({Wave = CurrentWave.Value,MaxWave = #Waves})
	
	while CurrentWave.Value < (#Waves + 1) and IsDefending.Value do  ---- WORKING ON THE REVIVE SYSTEM
		local PlacementOrder,waitTable,_ = self:OrderByPriority(Waves[CurrentWave.Value])
		local TimeToSkip = 0
		local SavedBeforeRestart
		self.Client.UpdateWave:FireAll({Wave = CurrentWave.Value,MaxWave = #Waves})
		
		DeadAttackers = 0 -- Resets the counter
	
		if GameIsPaused then
			repeat
				task.wait(.1)
			until not GameIsPaused
		end
		
		if RevivePlayer then
			CurrentWave.Value -= 1	
			SavedBeforeRestart = CurrentWave.Value
			PlacementOrder,waitTable,_ = self:OrderByPriority(Waves[CurrentWave.Value])
			
			RevivePlayer = false
		end

		if not GameIsPaused then
			for i = 1,#PlacementOrder do
				local Entity = PlacementOrder[i]
				local SpawnAmount = 0
				local dt = 0
	
				for _ = 1, Entity["Amount"] do
					if SpawnAmount < Entity["Amount"] and not GameIsPaused then
						SpawnAmount += 1
						self:SpawnEntity(Entity["Enemy"],Entity,Nodes)
					end
					task.wait(1)					
				end
	
				if Attackers < #waitTable then
					while dt < waitTable[Attackers] do
						dt += RunService.Heartbeat:Wait()
					end			
				end
	
				Attackers += 1
			end
		end

		if #MatchFolder.Entities:GetChildren() >= 0 and CurrentWave.Value == #Waves then
			warn("[ WAVES ] - LAST WAVE OF THE ENTITIES")
			repeat 
				task.wait(.1) 
				checkForHealth() 
			until #MatchFolder.Entities:GetChildren() <= 0 
		elseif CurrentWave.Value ~= #Waves then
			warn("[ WAVES ] - NORMAL WAVE OF THE ENTITIES")
			repeat 
				task.wait(.1)
				checkForHealth()  
			until (#MatchFolder.Entities:GetChildren() <= 0) or Skipped.Value -- or if wave Skipped.Value
		end
		
		if CurrentWave.Value < #Waves then
			CurrentWave.Value += 1
		end
		
		
		if CurrentWave.Value > #Waves and not getBoss() then
			warn(" FAILED BECAUSE THE WAVE IS GREATER THA NTHE LIMIT ")
			IsDefending.Value = false
			break;
		end
		
		if lost_match.Value and not GameIsPaused then
			warn(" FAILED BECAUSE MATCH WAS LOST HERE ")
			IsDefending.Value = false
			break;
		end

		self:GiveMoney(Room_Difficulty.CashPerWave,Room_Difficulty)

		local _,err = pcall(function()
			GameService:WaveCompleted()
		end)
		
		if err then
			warn("[ COULD'T GIVE WAVECOMPLETION ] --> ", err)
		end
		
		while (TimeToSkip < DefaultWaitUntilNextWave) and Skipped.Value do
			TimeToSkip += RunService.Heartbeat:Wait()
		end
		
		--Skipped.Value = false
	end
	
	local Votes = workspace:FindFirstChild("Votes")
	
	if Votes then
		Votes.Value = 0
	end
	
	AllowPlacement.Value = false
	WaveIsRunning = false
	CountDownOnGoing = false
	
	if lost_match.Value then
		return
	end

	if CurrentWave.Value >= #Waves and not lost_match.Value then -- CurrentWave >= #Waves 
		self:GameEnded({Coins = Room_Difficulty.CompletionRewards.Difficulty, Exp = Room_Difficulty.CompletionRewards.Exp, result = "Win", Color = Color3.fromRGB(255, 221, 48), Room = MapInfo.Difficulty, Floor = string.match(MapInfo.Floor,"%d+")})
		gameStop = true
		lost_match.Value = false
	end
end

type FloorInfo = {
	Floor : string,
	Room : string,
	MapName : string,
	Difficulty : string,
}

function MatchService:Unload(Model,To)
	for _,parts in pairs(Model:GetChildren()) do
		parts.Parent = To
	end
end

function MatchService:SetupMap(FloorData : FloorInfo,FloorFolder)
	--warn("TRYING TO LOAD MAP --> ", FloorData.MapName, FloorData.Room)
	local MapFolder = Assets.Maps:FindFirstChild(FloorData.MapName) -- The actual Map
	local SpawnShip = false

	if MapFolder and not FloorFolder:FindFirstChild("Map") then
		local newMap = MapFolder.Map:Clone()
		newMap.Parent = FloorFolder
		
		local ActivateClouds = newMap:GetAttribute("Clouds")
		workspace.Terrain.Clouds.Enabled = ActivateClouds
		
		
		local Terrain = newMap:FindFirstChild("Terrain")
		Lighting:ClearAllChildren()
		workspace.Terrain:Clear()

		for _,Properties in pairs(MapFolder.Lighting:GetChildren()) do		
			if not Properties:IsA("Folder") then
				Lighting[Properties.Name] = Properties.Value
			end
		end
		
		for _,Child in pairs(MapFolder.Lighting.Child:GetChildren()) do		
			if Child then
				Child:Clone().Parent = Lighting
			end
		end
		
		if Terrain and Terrain:IsA("TerrainRegion") then
			workspace.Terrain:PasteRegion(Terrain, workspace.Terrain.MaxExtents.Min, true)
		end
		
		for _,models in pairs(newMap:GetChildren()) do
			if models.Name:find("Room") then
				local FindEquivelentInFolder = FloorFolder:FindFirstChild(models.Name)
				-- Add the Start and End
				
				if FindEquivelentInFolder then
					local ShipSpawn = models:FindFirstChild("ShipSpawn")
					
					-- Get all the start points
					for _,parts in pairs(models:GetChildren()) do
						if parts.Name:find("Start") then
							parts.Parent = FindEquivelentInFolder
						end						
					end

					local End = models.End
					End.Parent = FindEquivelentInFolder
					
					if ShipSpawn then
						ShipSpawn.Parent = FindEquivelentInFolder
						SpawnShip = true
					end
					
					for _,child : Model in pairs(models:GetChildren()) do
						local EquivelentChild = FindEquivelentInFolder:FindFirstChild(child.Name)
						if EquivelentChild then
							child.Parent = EquivelentChild
							self:Unload(child,EquivelentChild)
							child:Destroy()
						end
					end
				end
			end
		end
		
		task.wait(1)
		return true,SpawnShip
	end
	
	return false,false
end

function MatchService:StartShip(Room_Difficulty,Room, SpawnShip)
	--local ShipStop = Start:GetAttribute("ShipStop")
	if SpawnShip then
		local Ship = workspace.Ship
		local RootPart = Ship.PrimaryPart
		local AlignOrientation = RootPart.AlignOrientation
		local PositionAlign : AlignPosition = RootPart.PositionAlign
		local Start = Room.Start
		local End = Room.End
		local EndPosition : CFrame = End.CFrame * CFrame.new(0,0,30)
		
		RootPart.Anchored = false
		RootPart.HealthGui.Enabled = false
		
		Ship.Spaceship.TimePosition = 0
		Ship.Spaceship:Play()
		
		PositionAlign.Position = Room.ShipSpawn.Position
		Ship:PivotTo(Room.ShipSpawn.CFrame)
				
		for i, player in pairs(game.Players:GetChildren()) do
			if player:FindFirstChild("Cash") then
				player.Cash.Value = Room_Difficulty.StartingCash
			end
			player.Character.HumanoidRootPart.CFrame = Ship["p"..i].CFrame
			player.Character.Humanoid.WalkSpeed = 16
		end

		PositionAlign.Enabled = true
		AlignOrientation.CFrame = CFrame.new(RootPart.Attachment.WorldCFrame.Position,Vector3.new(End.Position.X,RootPart.Attachment.WorldCFrame.Position.Y,End.Position.Z)) -- 
		PositionAlign.Position = EndPosition.Position
		
		local Distance : number = 10000;
		
		-- It was at 7
		
		while Distance > 7 do
			Distance = (RootPart.Position - End.Position).Magnitude
			task.wait()	
		end
		
		RootPart.HealthGui.Enabled = true
		RootPart.Anchored = true
		PositionAlign.Enabled = false
		PositionAlign.Position = Vector3.new(0,0,0)
		
		for _,parts in pairs(Ship:GetChildren()) do
			if parts:IsA("BasePart") or parts:IsA("TrussPart") or parts:IsA("MeshPart") then
				parts.AssemblyLinearVelocity = Vector3.new(0,0,0)
			end
		end
		
		Ship.Spaceship:Stop()
		self.Client.DisableShipVelocity:FireAll()
	else
		for i, player in pairs(game.Players:GetChildren()) do

			if player:FindFirstChild("Cash") then
				player.Cash.Value = Room_Difficulty.StartingCash
			end

			player.Character.HumanoidRootPart.CFrame = Room.End.CFrame
			player.Character.Humanoid.WalkSpeed = 16
		end
	end
end

function MatchService:Teleport(Data : FloorInfo)
	local Floor = Floors:FindFirstChild(Data.Floor)
	if Floor then
		local Room = Floor[Data.Room]
		local Room_Difficulty = Difficulties[Floor:GetAttribute("FloorName")][Data.Difficulty]
		Data["MapName"] = Floor:GetAttribute("FloorName")
		--- Add the map stuff first		
		
		local HasSpawned,SpawnShip = self:SetupMap(Data,Floor)
		--- Then teleport the players
		if HasSpawned then
			-- Send them into the ship and start the descend of the ship 
			--warn("SHOULD BE ROOM DATA ----> ", Difficulties,Floor:GetAttribute("FloorName"),Data.Difficulty , Room_Difficulty)
			task.spawn(function()
				self:StartShip(Room_Difficulty,Room,SpawnShip)
			end)
			
			self.Client.SkipWave:FireAll(false)
			self.Client.CloseIntermission:FireAll()
			self.Client.StartCountDown:FireAll(Room_Difficulty)			
		end
	end
end

function MatchService.Client:GetVotes()
	----warn("[ SERVER ] - GETTING VOTES --> ", LatestVote)
	return LatestVote
end

function MatchService:ClearMap()
	local SpawnLoc = workspace.SpawnLocaitionForPlayers.SpawnLocation
	local UnitService = Knit.GetService("UnitService")
	
	warn("[ INFO ] - CLEARING THE MAP ")
	UnitService:ResetTable()
	
	for _,player in pairs(game.Players:GetPlayers()) do
		if player then
			player.Character.HumanoidRootPart.CFrame = SpawnLoc.CFrame * CFrame.new(0,2,0)
		end
	end
	
	for _, Parts in pairs(workspace.Detectors:GetDescendants()) do
		if Parts:IsA("BasePart") or Parts:IsA("Model") then
			Parts:Destroy()
		end
	end
	
	for _, Parts in pairs(workspace.Floors:GetDescendants()) do
		if Parts:IsA("BasePart") or Parts:IsA("Model") then
			Parts:Destroy()
		end
	end
	
	if game.Lighting:FindFirstChild("Blur") then
		game.Lighting.Blur:Destroy()
	end
end

function MatchService:GetPlayableMap()
	if IsDefending.Value then return end 
	
	local ProfileService = Knit.GetService("ProfileService")
	
	-- local function getlength(Table)
	-- 	local count = 0
	-- 	for name, _ in pairs(Table) do
	-- 		count += 1
	-- 	end
		
	-- 	return count
	-- end
	
	local function countMatchingFloorsAndDifficulties(TheTable)
		local count = {}
		warn("THE DIFFICULTY AND MAP: ", TheTable)
		for _, data in pairs(TheTable) do
			local floor = data["Floor"]
			local difficulty = data["Difficulty"]

			floor = floor
			difficulty = difficulty

			local key = floor .. "_" .. difficulty  
			
			print("THE SCANNED DATA ----> ", data, TheTable)
			
			if count[key] then
				count[key] = count[key] + 1
			else
				count[key] = 1
			end
		end
		print("THE COUNT ----> ", count)
		return count
	end

	local function highestVotedFloorAndDifficulty(counts)
		local maxCount = 0
		local highestCombos = {}
		local allEqual = true

		for combo, count in pairs(counts) do
			if count > maxCount then
				maxCount = count
				highestCombos = {combo}
				allEqual = false
			elseif count == maxCount then
				table.insert(highestCombos, combo)
			else
				allEqual = false
			end
		end

		if allEqual then
			return "Equal"
		else
			return highestCombos
		end
	end

	local function getHighestDifficulty(data)
		local difficultyValues = {
			["Easy"] = 1,
			["Medium"] = 2,
			["Hard"] = 3,
			["Insane"] = 4
		}
		
		local maxDifficulty = "Insane"
		for difficulty, count in pairs(data) do
			if difficulty ~= "count" and difficulty ~= "floor" then
				if count > data[maxDifficulty] and difficultyValues[difficulty] > data[maxDifficulty] then
					maxDifficulty = difficulty
				end
			end
		end
		return maxDifficulty
	end
	
	local function highestCountTableTex(DATA)
		local maxCount = 0
		local highestTables = {}
		local allEqual = true

		for _, data in pairs(DATA) do
			local count = data["count"]
			if count > maxCount then
				maxCount = count
				highestTables = {{
					["Difficulty"] = getHighestDifficulty(data),
					["Floor"] = data["floor"]
				}}
				allEqual = false
			elseif count == maxCount then
				table.insert(highestTables, {
					["Difficulty"] = getHighestDifficulty(data),
					["Floor"] = data["floor"]
				})
			else
				allEqual = false
			end
		end

		if allEqual then
			return "Equal"
		else
			return highestTables
		end
	end
	
	warn("THE LATEST VOTE FROM THE PLAYERS ---> ", LatestVote)
	local result = countMatchingFloorsAndDifficulties(LatestVote)
	local highest = highestVotedFloorAndDifficulty(result)-- if getlength(LatestVote) > 1 then highestVotedFloorAndDifficulty(result) else nil

	--print("Highest Voted Floor and Difficulty (Example 1):", highest[1],result)

	local FloorMap = {
		Experimentation = 1;
		Vow = 2,
		Rend = 3,
		Mansion = 4,
	}
	
	
	local DifficultiesToNumber = {
		["Easy"] = 1,
		["Medium"] = 2,
		["Hard"] = 3,
		["Insane"] = 4,
		["Impossible"] = 5,
		-- Add one more
	}

	local DifficultiesToString = {
		[1] = "Easy",
		[2] = "Medium",
		[3] = "Hard",
		[4] = "Insane",
		[5] = "Impossible",
		-- Add one more
	}


	local playerHasMap = {}
	local mapWithmostPlayer

	local function parseTex(tex)
		local difficulty, floor = tex:match("_(%w+)$"), tex:match("^(.-)_")
		return {
			["Difficulty"] = difficulty,
			["Floor"] = floor,
			["Room"] = "Room1"
		}
	end

	local function Autopick()
		local processedPlayers = {}
		mapWithmostPlayer =  {}
		playerHasMap = {}


		for map,_ in pairs(FloorMap) do
			playerHasMap[map] = { floor = "Floor"..FloorMap[map], count = 0 }
			for Diff,_ in pairs(DifficultiesToNumber) do
				playerHasMap[map][Diff] = 0
			end
		end

		for _, player in pairs(game.Players:GetChildren()) do
			if not processedPlayers[player] then -- Check if the player has already been processed
				local CurrentFloorData = ProfileService:Get(player, "Floors")
				processedPlayers[player] = true -- Mark the player as processed

				for mapsName, value in pairs(FloorMap) do
					local FloorInTable
					local succ,_ = pcall(function()
						FloorInTable = CurrentFloorData[value]
					end)

					if succ and CurrentFloorData[value] then
						playerHasMap[mapsName].count = playerHasMap[mapsName].count + 1

						for Difficulty = 1, #Difficulties_Modules[mapsName]:GetChildren() do
							local DiffInMap = DifficultiesToString[Difficulty]

							if DiffInMap then
								if CurrentFloorData[value] >= Difficulty then
									playerHasMap[mapsName][DiffInMap] = playerHasMap[mapsName][DiffInMap] + 1
								end
							end
						end
					end
				end
			end
		end
		
		mapWithmostPlayer = highestCountTableTex(playerHasMap)
	end

	if highest and highest[1] ~= nil then
		warn("Highest Voted Floor and Difficulty (Example 1):", highest[1])
		local StopTheSearch = false
	
		for map,_ in pairs(FloorMap) do
			playerHasMap[map] = { floor = "Floor"..FloorMap[map], count = 0 }
			for Diff,_ in pairs(DifficultiesToNumber) do
				playerHasMap[map][Diff] = 0
			end
		end

		for _,FloorInfo in ipairs(highest) do
			local Split = string.split(FloorInfo,"_")
			local Floor = Split[1]
			local Difficulty = Split[2]

			local FloorName = Floors[Floor]:GetAttribute("FloorName")
			local Floor_Nr = tonumber(string.match(Floor,"%d+"))
			local Difficulty_Nr = DifficultiesToNumber[Difficulty]

			for _,players in pairs(game.Players:GetChildren()) do
				local CurrentFloorData = ProfileService:Get(players,"Floors")			
				
				if CurrentFloorData[Floor_Nr] then
					playerHasMap[FloorName].count += 1 
					
					local DiffInMap = DifficultiesToString[Difficulty_Nr]

					if DiffInMap then
						if CurrentFloorData[Floor_Nr] >= Difficulty_Nr then -- if the value is greater than Diff nr then player has it
							playerHasMap[FloorName][DiffInMap] += 1
						end
					end
				else 
					warn(players.Name, "doesn't have map ",FloorName)
					self.Client.SendNotification:FireAll(`{players.Name} does not have {FloorName}`,{Color = Color3.fromRGB(255,0,0), Time = 2})
					StopTheSearch = true
				end
				
				if StopTheSearch then
					warn("We stopped the search and autopicked a planet")
					break;
				end
			end
		end
		
		mapWithmostPlayer = highestCountTableTex(playerHasMap)

		if typeof(mapWithmostPlayer) == "string" then
			Autopick()
		end
	else
		Autopick()
	end

	warn("THIS IS WITH THE VOTES ACCOUNTED ---> ", highest, mapWithmostPlayer)
	
	--warn("THE NEW SORTED TABLE",)
	
	for mapName,info in pairs(playerHasMap) do
		print("------ ", mapName , " ------")
		for name, diff in pairs(info) do
			print(name,": ", diff)
		end
		print("------------------------------")
	end

	if #game.Players:GetChildren() <= 1 then
		local LastMap = #mapWithmostPlayer
		
		local _,err = pcall(function()
			mapWithmostPlayer[LastMap]["Room"] = "Room1"
		end)
		
		if err then 
			Autopick()
			LastMap = #mapWithmostPlayer

			mapWithmostPlayer[LastMap]["Room"] = "Room1"
		end
		
		return mapWithmostPlayer[LastMap]
	end

	if typeof(mapWithmostPlayer) == "table" and #mapWithmostPlayer > 1 then
		-- warn("THE MAPS ---> ", playerHasMap , mapWithmostPlayer)
	
		mapWithmostPlayer[1]["Room"] = "Room1"
		return mapWithmostPlayer[1]
	else -- if map shore is equal		
		
		for _, Info in pairs(mapWithmostPlayer) do
			print("THE INFO --> ", Info.Floor,Info.Difficulty)
		end
		
		mapWithmostPlayer[1]["Room"] = "Room1"
		return mapWithmostPlayer[1]
	end
end

function compareTables(inputTables)
	local commonValues = {}

	warn(inputTables,inputTables[1])

	for key, value in pairs(inputTables[1]) do
		local minValue = value 

		local isCommonValue = true
		for i = 2, #inputTables do
			warn("WE COMPARING")
			local currentValue = inputTables[i][key]
			if not currentValue or currentValue ~= value then
				isCommonValue = false
				break
			end
			if currentValue < minValue then
				minValue = currentValue
			end
		end

		if isCommonValue then
			table.insert(commonValues, minValue)
		end
	end

	return commonValues
end

function MatchService.Client:GetPlayersFloors()
	local ProfileService = Knit.GetService("ProfileService")
	local AllFloors = {}

	for _,player in pairs(game.Players:GetPlayers()) do
		ProfileService:OnProfileReady(player):await()
		local PlayerFloors = ProfileService:Get(player,"Floors")
		table.insert(AllFloors,PlayerFloors)	
	end 
	
	local commonFloors = compareTables(AllFloors)
	
	if #AllFloors > 1 then
		self.Server.Client.SendNotification:FireAll(`You can only pick a planet & act that everyone has`,{Color = Color3.fromRGB(255, 238, 0), Time = 5})
	end

	return commonFloors
end




function MatchService:KnitStart()
	local RequiredToStart = #game.Players:GetChildren()
	local ProfileService = Knit.GetService("ProfileService")
	GameService = Knit.GetService("GameService")
	
	local VotedToRestart = {}
	local Restarted = false
	local MapStarted = false
	local WantsToStart = 0
	local Voted = {}
	local WantsToRestart = 0
	local intermission_countdown = 40 
	local MapInfo : FloorInfo;

	local MatchStartCountDown = Instance.new("NumberValue")
	MatchStartCountDown.Name = "MatchStartCountDown"
	MatchStartCountDown.Value = 30
	MatchStartCountDown.Parent = workspace

	local function onDescendantAdded(descendant)
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = "players"
		end
	end

	local function onCharacterAdded(character)
		for _, descendant in pairs(character:GetDescendants()) do
			onDescendantAdded(descendant)
		end
		character.DescendantAdded:Connect(onDescendantAdded)
	end	
	
	GameService:StartVoting()
	
	local function startMatchcooldown()
		task.spawn(function() -- this is for the match cooldown
			repeat task.wait(.1) until #game.Players:GetChildren() >= 1

			MatchStartCountDown.Value = 30
			--warn("WE'RE ARE HERE ---> ", MatchStartCountDown.Value)
			while MatchStartCountDown.Value > 0 and not IsDefending.Value do
				--warn("THE LOOP IS ON ---> ", MatchStartCountDown.Value)
				MatchStartCountDown.Value -= RunService.Heartbeat:Wait()
				--Start += t	

				-- if MapStarted then
				-- 	break;
				-- end

				if MatchStartCountDown.Value <= 0 then
					if not IsDefending.Value then
						--- Start -- This is for if the count down ends before player votes
						local ValueToStart = workspace:FindFirstChild("VoteToStartGame")
						
						if ValueToStart then
							ValueToStart.Value = #game.Players:GetChildren()
						end
						--- Ends ---
						
						IsDefending.Value = true
						VotedToRestart = {}
						self.Client.AllowPlacement:FireAll(true,MapInfo)
						self:StartGame(MapInfo) -- This just teleports the player to the selected room and Difficulty
					end

					break;
				end
			end
		end)
	end
	
	local function StartGame(Data, SkipAllVotes)
		local FindVotes = workspace:FindFirstChild("MapVotes")
		local DifficultiesToNumber = {
			["Easy"] = 1,
			["Medium"] = 2,
			["Hard"] = 3,
			["Insane"] = 4,
			["Impossible"] = 5,
			-- Add one more
		}
		
		if workspace:FindFirstChild("Votes") then
			workspace.Votes.Value = 0
			SkippedSaved = {}
		end
		
		if ((FindVotes and FindVotes.Value >= #game.Players:GetChildren()) or SkipAllVotes) and not MapStarted then
			Data = self:GetPlayableMap() --results
			MapInfo = Data
			
			--- Teleport to the floor			
			if RequiredToStart > 1 and not workspace:FindFirstChild("VoteToStartGame") then
				local VoteToStartGame = Instance.new("IntValue")
				VoteToStartGame.Parent = workspace
				VoteToStartGame.Name = "VoteToStartGame"
			end
		
			self.Client.SendNotification:FireAll(`| Planet {string.match(Data.Floor,"%d+")} | Act {DifficultiesToNumber[Data.Difficulty]} |`,{Color = Color3.fromRGB(0, 208, 255), Time = 5})

			MapStarted = true
			startMatchcooldown()
			self:Teleport(Data)
		end
	end
	
	local function startintermissioncountDown() --- Sync this to client
		if CountDownOnGoing then return end
		task.spawn(function()
			repeat task.wait(.1) until #game.Players:GetChildren() > 0
			
			local Countdown_value = workspace:FindFirstChild("Countdown")

			if Countdown_value then
				Countdown_value.Value = intermission_countdown
				CountDownOnGoing = true
				while Countdown_value.Value > 0 and not IsDefending.Value do
					Countdown_value.Value -= RunService.Heartbeat:Wait()
					
					if MapStarted then
						break;
					end

					--print("COUNT DOWN UNTIL THE FIRST MAPS GETS LOADED")
					if Countdown_value.Value <= 0 then
						warn("[ INFO ] - GAME HAS STARTED DUE TO COUNTDOWN")
						CountDownOnGoing = false
						StartGame(nil, true)
						break
					end

				end

				Countdown_value.Value = intermission_countdown
			end
		end)
	end
	
	startintermissioncountDown()
	
	game.Players.PlayerAdded:Connect(function(player) -- Lazy but works
		playerProfiles[player.Name] = DefaultProfile
		
		local StartingCash = Instance.new("IntValue") -- This is the money that's going to be used for supply
		StartingCash.Name = "Cash"
		StartingCash.Value = 0
		StartingCash.Parent = player

		local PlacementAmount = Instance.new("IntValue") -- MaxPlacement don't actually need it here but it's easier
		PlacementAmount.Name = "PlacementAmount"
		PlacementAmount.Value = 0 
		PlacementAmount.Parent = player
		
		playerProfiles[player.Name].Money = StartingCash

		-- This is a fix for the player that has Floor 2 >= 3
		ProfileService:OnProfileReady(player):andThen(function(value)
			if value["Floors"][2] and value["Floors"][2] >= 3 and not value["Floors"][3] then
				local newFloors = value["Floors"]
				newFloors[3] = 1
					warn("PLLAYER HAS JOINED THE GAME ---> ", value)
				
				ProfileService:Update(player, "Floors", function()
					warn("GAVE THE PlAYER --> ", player.Name ," AN EXTRA FLOOR",value, newFloors)
					return newFloors
				end)	
			else
				warn("THE PLAYERS FLOORS ---> ", Floors)
			end		
		end)
		
		player.CharacterAdded:Connect(onCharacterAdded)
	end)
	
	local VotesTest = 0

	self.Client.Play:Connect(function(player,Data : FloorInfo,SkipAllVotes) -- This is for starting the actual match
		local FindVotes = workspace:FindFirstChild("MapVotes")
		RequiredToStart = #game.Players:GetChildren()
		
		warn("THIS FIRED THANKS TO THE CLIENT", FindVotes)
		
		if FindVotes and not LatestVote[player.Name] then
			print("WE FOUDN THE VALUE BUT NOTHING IS HAPPENING")
			FindVotes.Value += 1
			print(FindVotes.Value)
		end

		if not SkipAllVotes then
			if Voted[Data.Floor] and Voted[Data.Room] then
				-- if LatestVote[player.Name] then
				-- 	local latestFloor = LatestVote[player.Name].Floor
				-- 	local latestDifficulty = LatestVote[player.Name].Difficulty
					
				-- 	Voted[latestFloor] -= 1
				-- 	Voted[latestDifficulty] -= 1
				-- end
				
				-- Voted[Data.Floor] += 1
				-- Voted[Data.Difficulty] += 1
				
				LatestVote[player.Name] = {
					Room = Data.Room,
					Floor = Data.Floor,
					Difficulty = Data.Difficulty
				}
			else
				--------- fix this ---------
				-- Voted[Data.Floor] = 1
				-- Voted[Data.Difficulty] = 1
				
				LatestVote[player.Name] = {
					Room = Data.Room,
					Floor = Data.Floor,
					Difficulty = Data.Difficulty
				}
				
				VotesTest += 1
			end			
		end
		
		if VotesTest == 1 then
			self.Client.Start:FireAll()	
		end		
	
		StartGame(nil,false)
	end)

	
	self.Client.Restart:Connect(function(player) -- When a player wants to restart the game
		local ValueToStart = workspace:FindFirstChild("VoteToStartGame")
		local Votes = workspace:FindFirstChild("Votes")
		local MapVotes = workspace:FindFirstChild("MapVotes")
		RequiredToStart = #game.Players:GetChildren()
		
		if not VotedToRestart[player.Name] then
			WantsToRestart += 1
			VotedToRestart[player.Name] = true
		end
		
		if MapVotes then
			MapVotes.Value = 0
		end

		if Votes then
			Votes.Value = 0
		end
		
		if ValueToStart then
			ValueToStart.Value = 0 
		end
		
		repeat task.wait(.1) RequiredToStart = #game.Players:GetChildren() until WantsToRestart >= RequiredToStart

		if WantsToRestart >= RequiredToStart and not CountDownOnGoing then
			canRestart = true
			
			WantsToRestart = 0
			GameService:StartVoting()
			startintermissioncountDown()

			self:ClearMap()
			MapStarted = false
			IsDefending.Value = false
			SkippedSaved = {}
			MapInfo = {
				Difficulty = "",
				Floor = "",
				Room = "",
				MapName = ""
			}

			CurrentWave.Value = 1
			
			LatestVote = {}
			Voted = {}
			
			WantsToStart = 0
			
			for _,players in pairs(game.Players:GetChildren()) do
				local MaxPlacement = players:FindFirstChild("PlacementAmount")
				if MaxPlacement then
					MaxPlacement.Value = 0
				end
			end
			
			self.Client.Restart:FireAll()
		end
	end)

	self.Client.Start:Connect(function(player,SkipVote) -- This for the intermission 
		local ValueToStart = workspace:FindFirstChild("VoteToStartGame")
		WantsToStart += 1
		if ValueToStart then
			ValueToStart.Value += 1
		end
		
		task.spawn(function()
			repeat task.wait() 
				RequiredToStart = #game.Players:GetChildren() 
			until IsDefending.Value
		end)
		
		warn("PRESSED START WantsTpStart ", WantsToStart , (WantsToStart >= RequiredToStart) )
		
		if (WantsToStart >= RequiredToStart) and not IsDefending.Value then
			lost_match.Value = false

			Restarted = false
			IsDefending.Value = true
			VotedToRestart = {}
			
			self.Client.AllowPlacement:FireAll(true,MapInfo)
			self:StartGame(MapInfo) -- This just teleports the player to the selected room and Difficulty
		end
		
	end)
end

function MatchService:KnitInit()
	warn("[ MATCHSERVICE INITIATED ] - ", Difficulties)
end

return MatchService
