local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local SharedPackages = ReplicatedStorage.SharedPackage

local Assets = ReplicatedStorage.Assets
local Particles = Assets.Particles

local Units = require(SharedPackages.Units)

local UnitManager = {}
UnitManager.__index = UnitManager

-- local Debug = false

function UnitManager.new(Unit)
	local DefaultStats = Units[Unit.Name]
	local self = setmetatable({},UnitManager)
	
	self.Unit = Unit
	self.Name = Unit.Name
	self.Owner = nil
	self.Upgrades = DefaultStats.Upgrades
	self.Moneyspent = DefaultStats.Price * .5 -- The money spent on this unit
	self.Level = 0
	self.Range = self.Upgrades[self.Level].Range;
	self.Cooldown = self.Upgrades[self.Level].Cooldown;
	self.Damage = self.Upgrades[self.Level].Damage or self.Upgrades[self.Level].Profit or self.Upgrades[self.Level].Slowness or self.Upgrades[self.Level].Buff;
	self.DefaultDamage = self.Damage --- This is the damage before gettings a buff
	self.Tags = self.Upgrades.Tags
	self.IsShiny = false
	self.Detector = nil
	self.Target = nil
	self.Targeting = "First"
	self.InsideZone = {}
	self.TargetsInZone = 0
	self.InCooldown = false
	self.Attacked = false
	self.IsActive = true
	self.Priority = {
		First = true; -- First one seen
		Strongest = false; -- The one with most health
		Weakest = false; -- the one with least health
		Last = false; -- the one behind everyone
	}
	
	return self
end

function UnitManager:CreateDetector(Unit,Range : number)
	local Storage = workspace.Detectors
	local AlreadyExists = Storage:FindFirstChild(Unit:GetAttribute("Id"))
	
	if not AlreadyExists then
		local Zone = Instance.new("Part")
		Zone.Material = Enum.Material.ForceField
		Zone.Shape = Enum.PartType.Ball
		Zone.Size = Vector3.new(Range,Range,Range)
		Zone.Color = Color3.fromRGB(0, 145, 255)
		Zone.CFrame = Unit.PrimaryPart.CFrame
		Zone.CanCollide =  false
		Zone.CastShadow = false
		Zone.Anchored = true
		Zone.Transparency = 1
		Zone.Name = Unit:GetAttribute("Id")
		Zone.Parent = Storage
		
		return Zone
	else
		AlreadyExists:Destroy()
		
		local Zone = Instance.new("Part")
		Zone.Material = Enum.Material.ForceField
		Zone.Shape = Enum.PartType.Ball
		Zone.Color = Color3.fromRGB(0, 145, 255)
		Zone.Size = Vector3.new(Range,Range,Range)
		Zone.CFrame = Unit.PrimaryPart.CFrame
		Zone.CanCollide =  false
		Zone.CastShadow = false
		Zone.Anchored = true
		Zone.Transparency = 1
		Zone.Name = Unit:GetAttribute("Id")
		Zone.Parent = Storage
		
		return Zone
	end

end

function UnitManager:SetCooldown() --- Hacky but since the cooldown happens after an attack we can also give the owner money here
	local dt = 0
	
	self.InCooldown = true
	
	self.Owner.Cash.Value += (self.Damage / 10) -- The damage is the money the player gains 
	
	while dt < self.Cooldown do
		dt += RunService.Heartbeat:Wait()
	end
	
	self.InCooldown = false
end

function UnitManager:Sell()
	self.Owner.Cash.Value += self.Moneyspent -- if self.Moneyspent > 1000 then 500 else self.Moneyspent -- What the player gets for selling a unit(TEMP)
	self.IsActive = false
	self.Unit:Destroy()
	self.Detector:Destroy()
end

function UnitManager:GetDictionaryLength(Table)
	local count = 0;
	
	for _,value in pairs(Table) do
		if value ~= nil then
			count += 1
		end
	end
	
	return count
end

function UnitManager:DecideTarget()
	local TargetAmount = #self.InsideZone
	
	if TargetAmount > 1 then
		if self.Priority.First then
			if #self.InsideZone[1].Character:GetChildren() <= 0 then  table.remove(self.InsideZone,1) end
			
			--self.SetTargetingMode.Text = "TargetingMode: ".."First"
			self.Targeting = "First"
				
			return self.InsideZone[1].Character
		elseif self.Priority.Weakest then
			self.SetTargetingMode.Text = "TargetingMode: ".."Weakest"
			self.Targeting = "Weakest"
			local ChoosenTarget = {
				Health = math.huge,
				Target = nil
			}

			for _,Data in ipairs(self.InsideZone) do
				if Data.Health <= ChoosenTarget.Health then
					ChoosenTarget.Health = Data.Health
					ChoosenTarget.Target = Data.Character
				end
			end
			
			--warn("[UNIT ] - THIS IS THE TARGET WITH THE LOWEST HEALTH")
			return ChoosenTarget.Target
		elseif self.Priority.Strongest then
			--self.SetTargetingMode.Text = "TargetingMode: ".."Strongest"
			self.Targeting = "Strongest"

			local ChoosenTarget = {
				Health = 0,
				Target = nil
			}
			
			for _,Data in ipairs(self.InsideZone) do
				if Data.MaxHealth and Data.MaxHealth >= ChoosenTarget.Health then
					ChoosenTarget.Health = Data.MaxHealth
					ChoosenTarget.Target = Data.Character
				end
			end
			
			return ChoosenTarget.Target
		end
		
		
	elseif TargetAmount == 1 then
		--self.SetTargetingMode.Text = "TargetingMode: " .. self.Targeting
		return self.InsideZone[1].Character -- This is wrong
	else
		return nil
	end
end

function UnitManager:RemoveTarget(Id : number) -- Removes the target that has left the zone from InsideZone table
	local table_pos = 0
	
	for key,Data in ipairs(self.InsideZone) do
		if Data.Id == Id then
			table.remove(self.InsideZone,key)
			----warn("[ INFO ] - TARGET WAS REMOVED ---> WANT TO REMOVE | ", Id ," | REMOVED | ", Data.Id, self.InsideZone)
			return
		end
	end
end

function UnitManager:FindTarget(Id : number)
	for _,Data in ipairs(self.InsideZone) do
		if Data.Id == Id then
			return true
		end
	end
	
	return false
end

function UnitManager:LoadSound(SoundFile,Volume)
	local Sound = self.Unit.RootPart:FindFirstChild(SoundFile.Name)
	Volume = Volume or .5
	--Sound.Volume = Volume
	if not Sound then
		Sound = SoundFile:Clone()
		Sound.Parent = self.Unit.RootPart
	end

	return Sound
end

function UnitManager:BuffUnit(BuffInfo)
	local UnitsCollection = CollectionService:GetTagged("Units")
	
	self.Unit:SetAttribute("Distance",self.Range/2)
	for _,Unit in pairs(UnitsCollection) do
		local Distance = (Unit.PrimaryPart.Position - self.Unit.PrimaryPart.Position).Magnitude
		
		if (self.Range/2) >= Distance and Unit.Name ~= self.Unit.Name then -- ask smash
			--warn("[ BOOST ] - BOOSTED --> ", Unit.Name, BuffInfo)
			for name,value in pairs(BuffInfo) do
				if (Unit:GetAttribute(name) and Unit:GetAttribute(name) < value) or not Unit:GetAttribute(name) then
					Unit:SetAttribute(name,value)
					self.Unit:SetAttribute("Buff",true)
				-- elseif not Unit:GetAttribute(name) then
				-- 	-- This sets the value it one doesn't exists
				-- 	Unit:SetAttribute(name,value)
				-- 	self.Unit:SetAttribute("Buff",true)
				end
			end
		end
	end
	
end

function UnitManager:SlowUnit(Target,burnTime : number,Type : string) --- Needs fixing
	--local Particle = Particles:FindFirstChild(Type)
	local t = 0
	warn("TRYING TO SLOW UNIT ",Target.Name, self.Damage , Target:GetAttribute("Speed"))
	task.spawn(function()
		local TargetSpeed = Target:GetAttribute("Speed")
		local Storage = {}
		
		if Type then
			local Particle = Particles:FindFirstChild(Type)

			for _,parts in pairs(Target:GetChildren()) do
				if parts:IsA("BasePart") then
					local newParticle = Particle:Clone()		
					newParticle.Parent = Target.PrimaryPart
					
					table.insert(Storage,newParticle)
				end
			end		
		end

		Target:SetAttribute("Speed", TargetSpeed - self.Damage)
		
		while t < burnTime do
			t += RunService.Heartbeat:Wait()
		end
	
		if #Storage > 0 then --- If there is particles
			for _,particle in ipairs(Storage) do
				particle:Destroy()
			end
		end	

		warn("Effect is completed")
		Target:SetAttribute("Speed",TargetSpeed)
	end)
end

function UnitManager:Burn(Target,burnTime : number,Type : string)
	local Particle = Particles:FindFirstChild(Type)
	local t = 0
	if Particle then
		local Storage = {}
		
		for _,parts in pairs(Target:GetChildren()) do
			if parts:IsA("BasePart") then
				local newParticle = Particle:Clone()		
				newParticle.Parent = Target.PrimaryPart
				
				table.insert(Storage,newParticle)
			end
		end
		
		task.spawn(function()
			while t < burnTime do
				if Target then
					local TargetHealth = Target:GetAttribute("Health")
					Target:SetAttribute("Health", TargetHealth - self.Damage)
				end
				t += 1
				task.wait(.5)
			end
			
			for _,particle in ipairs(Storage) do
				particle:Destroy()
			end
		end)
	else
		
	end
end

function UnitManager:LoadAnimation(Animation, Speed)
	local AnimationController = self.Unit.AnimationController
	Speed = Speed or 1
	
	local AnimationTrack : AnimationTrack = AnimationController:LoadAnimation(Animation)
	AnimationTrack:AdjustSpeed(Speed)
	
	return AnimationTrack
end

function UnitManager:ChangeTargeting()
	local TargetingMode = self.Priority[self.Targeting]
	if TargetingMode then
		local targetingModes =  {
			"First"; -- First one seen
			"Strongest"; -- The one with most health
			"Weakest"; -- the one with least health
			"Last" -- the one behind everyone
		}
		
		self.Priority[self.Targeting] = false -- Disables the old targeting

		for key,value in ipairs(targetingModes) do
			if value == self.Targeting then
				self.Targeting = if key < #targetingModes then targetingModes[key + 1] else  targetingModes[1]
				self.Priority[self.Targeting] = true
				return
			end
		end	
	end
end

function UnitManager:Upgrade(player)
	local CurrentLevel = self.Level
	local Upgrades = self.Upgrades
	local nr_upgrades = #self.Upgrades
	local Cash = player:FindFirstChild("Cash")
	
	if Cash then
		if CurrentLevel < nr_upgrades then -- and Upgrades[CurrentLevel + 1].Cost < playerMoney
			local NextStats = Upgrades[CurrentLevel + 1]
			local Cost = NextStats.Cost
			
			if Cash.Value >= Cost then
				local RootPart = self.Unit:FindFirstChild("RootPart")
				if RootPart then
					local Holder = RootPart:FindFirstChild("Upgrading")
					
					for StatName,StatValue in pairs(NextStats) do
						if self[StatName] then
							if StatName == "Damage" and self.IsShiny then 
								StatValue *= 1.3
							end
							self.DefaultDamage = if StatName == "Damage" then StatValue else self.DefaultDamage --- If there is any damage error this is the cause							
							self[StatName] = StatValue
						elseif StatName == "Buff" or StatName == "Slowness" then
							self["Damage"] = StatValue
						end
					end
					
					if Holder then
						for _,Emitter in pairs(Holder:GetChildren()) do
							Emitter:Emit(5)
						end
					end
					
					--- Take player money
					self.Level += 1
					Cash.Value -= Cost
					--self.Moneyspent += (Cost * .25) 
					
					return true,self
				else
					warn(self.Unit.Name, " Doesn't have a RootPart")
				end
			else
				return false,self -- Could not afford it		
			end
		end			
	end
	
	return false,self
end

function UnitManager:GetTargets(RootPart)
	local AllAttackable = CollectionService:GetTagged("Entities")
	
	for _,Enemies in pairs(AllAttackable) do
		local HumanoidRootPart = Enemies:FindFirstChild("RootPart")
		
		if HumanoidRootPart then
			local Distance = (HumanoidRootPart.Position - RootPart.Position).Magnitude
			local Character = HumanoidRootPart.Parent

			if Distance <= self.Range/2 then
				if Character and Character:GetAttribute("IsActive") then
					local InTable = self:FindTarget(Character:GetAttribute("Id")) --- Checks if the target is already inside self.InsideZone

					if not InTable then 
						local Died = false
						local TargetData = {
							Id = Character:GetAttribute("Id"),
							Character = Character,
							Health = Character:GetAttribute("Health"),
						}						
						
						Character:GetAttributeChangedSignal("Health"):Connect(function() --- If Attacker dies remove him from the table
							local Health = Character:GetAttribute("Health")
							if Health <= 0 then
								self:RemoveTarget(TargetData.Id)
								self.Target = nil
								Died = true
							end
						end)
						
						if not Died then
							table.insert(self.InsideZone,TargetData) -- If not add them inside the table
						end
					end				
				end
			else
				if Character and not game.Players:GetPlayerFromCharacter(Character) then
					local Id = Character:GetAttribute("Id")
					----warn("[ INFO ] - THE TARGET --> ", Id, " HAS LEFT THE ATTACKZONE! ")				
					self:RemoveTarget(Id)
					self.Target = nil					
				end
				
			end
		end
	end
	
end

function UnitManager:GetBuffUnit()
	local UnitsCollection = CollectionService:GetTagged("Units")

	for _,Unit in pairs(UnitsCollection) do
		local Distance = (Unit.PrimaryPart.Position - self.Unit.PrimaryPart.Position).Magnitude
		
		if (Unit:GetAttribute("Buff") and  Unit:GetAttribute("Distance") and Distance <= Unit:GetAttribute("Distance")) or self.Unit:GetAttribute("Shiny") then
			return true
		end
	end
	
	if self.Unit:GetAttribute("Shiny") then
		return true
	end
	
	return false
end

function UnitManager:OnZoneTouched(Attackfunc) -- Check for Attacker inside the Zone
	self.Detector = self:CreateDetector(self.Unit,self.Range)
	local RootPart : BasePart = self.Unit:FindFirstChild("HumanoidRootPart") or self.Unit:FindFirstChild("RootPart")

	-- local LatestTarget = ""

	self.Unit:SetAttribute("IsActive", self.IsActive)
			
	while self.IsActive or self.Unit:SetAttribute("IsActive") do
		RootPart = self.Unit:FindFirstChild("HumanoidRootPart") or self.Unit:FindFirstChild("RootPart")
		if RootPart then
			self:GetTargets(RootPart)
			local Target = self.Target or self:DecideTarget() -- if self.Target and #self.Target:GetChildren() > 0 then 
			
			if Target and Target:FindFirstChild("RootPart") then
				self.Target = Target
				-- LatestTarget = self.Target:GetAttribute("Id")
				
				local Position : Vector3 = Vector3.new(self.Target.RootPart.Position.X,RootPart:GetPivot().Position.Y,self.Target.RootPart.Position.Z)
				
				self.Unit:PivotTo(CFrame.lookAt(RootPart:GetPivot().Position,Position))

				if not self:GetBuffUnit() then
					self.Damage = self.DefaultDamage
				else
					local Boosted = 1;
					
					if self.Unit:GetAttribute("Damage") then
						if self.Unit:GetAttribute("Damage") <= 0 then
							Boosted = 1 
						else
							Boosted = self.Unit:GetAttribute("Damage")
						end
					end
					
					self.Damage = self.DefaultDamage * Boosted
				end

				Attackfunc() --- Calls the self:Attack inside each unit Class
			else						
				if Target then
					self:RemoveTarget(Target:GetAttribute("Id"))
					Target = nil				
				end	
			end
		else
			self.IsActive = false	
		end
		task.wait()
	end
end

function UnitManager:Destroy()
	self.Unit:Destroy()
	self.Detector:Destroy()
	self.IsActive = false
end

return UnitManager
