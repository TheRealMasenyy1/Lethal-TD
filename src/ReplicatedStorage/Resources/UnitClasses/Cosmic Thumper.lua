local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local CosmicThumper = {}
CosmicThumper.__index = setmetatable(CosmicThumper,UnitManager)


function CosmicThumper.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,CosmicThumper)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["CosmicThumper"].Attack);
		Idle = self:LoadAnimation(EntityInfo["CosmicThumper"].Idle);
	}
	
	self.AttackSound = self:LoadSound(EntityInfo["CosmicThumper"].Sound)
	
	--- Empty Constructor
	return self
end

function CosmicThumper:Hitbox(Position : Vector3)
	local Damaged = {}
	local Detector = Instance.new("Part")
	Detector.Size = Vector3.new(10,5,15)	
	Detector.Position = Position
	Detector.CFrame = self.Unit.RootPart.CFrame * CFrame.new(0,0,-((self.Range/2) * 1.1))
	Detector.Transparency = 1
	Detector.CanCollide = false
	Detector.Anchored = true
	Detector.Parent = self.Unit
	
	local Overlaps = OverlapParams.new()
	Overlaps.FilterType = Enum.RaycastFilterType.Exclude
	Overlaps.FilterDescendantsInstances = { self.Unit }
	
	local GetParts = workspace:GetPartBoundsInBox(Detector.CFrame,Detector.Size)
	
	for _,Parts in (GetParts) do
		local Models_Key = Parts.Parent
		
		if Models_Key:IsA("Model") then
			local Health = Models_Key:GetAttribute("Health")
			
			if Health and not Damaged[Models_Key.Name] then
				Damaged[Models_Key.Name] = true
				Models_Key:SetAttribute("Health",Health - self.Damage)
			end
		end
	end
	
	task.delay(1,game.Destroy,Detector)
	-- Detector:Destroy()
end


function CosmicThumper:Attack()
	
	if not self.InCooldown then --- If not in Cooldown Attack
		-- local TargetHealth = self.Target:GetAttribute("Health")
		self.AttackSound:Play()
		self.Animations.Attack:Play()
		
		if self.Cooldown < 1 then
			self.Animations.Attack:AdjustSpeed(1.2)
		end
		
		self:Hitbox(self.Target.RootPart.Position)
		task.spawn(function()
			self:SetCooldown()
		end)

		task.delay(self.Animations.Attack.Length,function()
			self.Animations.Attack:Stop()	
		end)
	else
		--warn("[ UNIT ] - IS IN COOLDOWN....")
	end
end

function CosmicThumper:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return CosmicThumper	