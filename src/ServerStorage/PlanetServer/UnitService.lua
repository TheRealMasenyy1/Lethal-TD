local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local SharedPackages = ReplicatedStorage.SharedPackage
local Particles = ReplicatedStorage.Assets.Particles

local Assets = ReplicatedStorage.Assets
local Units_Folder = Assets.Units

local UnitClasses = ReplicatedStorage.Resources.UnitClasses

local Knit = require(ReplicatedStorage.Packages.Knit)
local Units = require(SharedPackages.Units)
local Shortcut = require(ReplicatedStorage.Shortcut)

local MatchFolder;

local UnitService = Knit.CreateService {
	Name = "UnitService",
	Client = {
		Place = Knit.CreateSignal(),
		GetUnitInfo = Knit.CreateSignal(),
		Upgrade = Knit.CreateSignal(),
		Sell = Knit.CreateSignal(),
		UpgradeUnit = Knit.CreateSignal(),
	},
}

local unitAmount = {}

type PlaceInfo = {
	Spot : CFrame;
	Name : string; -- which npc 
	Floor : string;
	Room : string;
}
local Room

local function GetTheMapFolder()
	for _,Map in pairs(workspace.Floors:GetDescendants()) do
		if Map:IsA("Model") and Map.Name == "Map" then
			return Map.Parent.Room1
		end
	end

	return nil
end


function UnitService:PlaceUnit(player, Info : PlaceInfo) 
	local Unit_Model = Units_Folder:FindFirstChild(Info.Name)
	
	local function DisableCollsion(Model)
		for _,Parts : BasePart in pairs(Model:GetChildren()) do
			if Parts:IsA("BasePart") then
				Parts.CanCollide = false
			end
		end
	end
	
	if Unit_Model then
		local newUnit = Unit_Model:Clone()
		newUnit:PivotTo(Info.Spot)
		newUnit:SetAttribute("Id",math.random(-10000,10000))
		newUnit:SetAttribute("Shiny", Info["Shiny"])
		newUnit:SetAttribute("Spawntime", os.time())
		
		if Info["Shiny"] then
			newUnit:SetAttribute("Damage",1.3)
		end
		
		newUnit.PrimaryPart.Anchored = true
		newUnit.Parent = MatchFolder.Units
		newUnit:AddTag("Units")
		
		local hitbox = Instance.new("Part")
		hitbox.Size = Vector3.new(5,10,5)
		hitbox.CFrame = newUnit:GetPivot()
		hitbox.Anchored = true
		hitbox.CanCollide = false
		hitbox.Transparency = 1
		hitbox.CollisionGroup = "Units"
		hitbox.Parent = newUnit

		local Holder = Instance.new("Attachment")
		Holder.Name = "Upgrading"
		Holder.Parent = newUnit.RootPart

		for _,UpgradeEmitter in pairs(Particles.Upgrading:GetChildren()) do
			UpgradeEmitter:Clone().Parent = Holder
		end

		local Unit_Class = UnitClasses:FindFirstChild(Units[Info.Name].Name)
			
		if Unit_Class then
			local Unit = require(Unit_Class).Setup(newUnit)	-- Load Class
			Unit.IsShiny = Info["Shiny"]
			Unit.Owner = player
			newUnit:SetAttribute("Owner",player.Name)
			
			self.Units[newUnit:GetAttribute("Id")] = Unit
			--Unit.Moneyspent += (Units[Info.Name].Price * .25) 
			
			DisableCollsion(newUnit)
			
			if not unitAmount[player.Name][Info.Name] then
				unitAmount[player.Name][Info.Name] = 1
			else
				unitAmount[player.Name][Info.Name] += 1
			end
			
			task.spawn(function()
				Unit:Run()
			end)	

		else
			warn("[ CLASS ] - CLASS WAS NOT FOUND...", Units[Info.Name].Name)
		end	
	end
end

function UnitService.Client:GetUnitInfo(_,UnitId)
	return self.Server.Units[UnitId]
end

function UnitService.Client:ChangeTargeting(_,UnitId)
	local Unit = self.Server.Units[UnitId]
	Unit:ChangeTargeting()
end

function UnitService.Client:Sell(player,UnitId)
	local Unit = self.Server.Units[UnitId]
	player.PlacementAmount.Value -= 1
	if unitAmount[player.Name][Unit.Name] then
		unitAmount[player.Name][Unit.Name] -= 1
	end

	--Unit.IsActive = false
	Unit:Sell()
end

function UnitService.Client:UpgradeUnit(player,UnitId)
	local Unit = self.Server.Units[UnitId]
	local hasBeenUpgraded,UnitData = Unit:Upgrade(player)
	
	if hasBeenUpgraded then
		Unit.IsActive = false -- Temp stop for updating stats	
		task.delay(.1,function()
			Unit.IsActive = true -- Activated the Unit
			
			task.spawn(function() -- And run again
				Unit:Run()
			end)
		end)		
	end
	return hasBeenUpgraded, UnitData
end

function UnitService:ResetTable()
	local Unit = self.Units
	
	--warn("RESETING THE UNITS AND EVERYTHING", Unit)
	for _,UnitInfo in pairs(Unit) do
		if UnitInfo then
			UnitInfo.IsActive = false
		end
	end
	
	for _, player in pairs(game.Players:GetChildren()) do
		unitAmount[player.Name] = {}
	end
	
	Room = nil
	--warn("THE UNIT AMOUNT ", unitAmount)

end

function UnitService:KnitStart()
	local ProfileService = Knit.GetService("ProfileService")
	local playerUnits = {}
	self.Units = {}	
	
	local function ChangeTableFormat(Table)
		local newtable = {}
		for _,Data in pairs(Table) do
			newtable[Data.Unit] = Data
		end
		return newtable
	end
	
	game.Players.PlayerAdded:Connect(function(player)
		ProfileService:OnProfileReady(player):andThen(function(value)
			playerUnits[player.Name] = ChangeTableFormat(value["Equipped"])	
		end)
	end)
	
	
	self.Client.Place:Connect(function(player,Data : PlaceInfo)
		local Cash = player:FindFirstChild("Cash") -- InGame Money For Units and Upgrade
		local PlacementAmount = player:FindFirstChild("PlacementAmount")
		local Price;
		MatchFolder = workspace.Floors[Data.Floor][Data.Room]
		
		if not Room then
			Room = GetTheMapFolder()
		end
		
		local _,_ = pcall(function()
			Price = Units[Data.Name].Price
		end)
		
		if not unitAmount[player.Name] then
			unitAmount[player.Name] = {}
		end	
		
		local Params = RaycastParams.new()
		Params.FilterType = Enum.RaycastFilterType.Include
		Params.FilterDescendantsInstances = { Room.Path,Room.Units }
		
		if Price and playerUnits[player.Name][Data.Name] and Cash.Value >= Price and PlacementAmount.Value < MatchFolder:GetAttribute("MaxPlacement") and
			(not unitAmount[player.Name][Data.Name] 
			or unitAmount[player.Name][Data.Name] < Units[Data.Name].MaxPlacement) then --- Check How many of this unit you can place and total amount
			
			local Distance = (Data.Spot.Position - player.Character.HumanoidRootPart.Position).Magnitude
			local IsOnPath = Shortcut.RayCast(Data.Spot.Position + Vector3.new(0,10,0),Vector3.new(0,-100,0), Params)

			if Distance <= 60 and not IsOnPath then
				Data["Shiny"] = playerUnits[player.Name][Data.Name]["Shiny"] or false
				
				self:PlaceUnit(player,Data)
				player.PlacementAmount.Value += 1
				Cash.Value -= Price				
			end
		end
	end)
end

function UnitService:KnitInit()
end

return UnitService

