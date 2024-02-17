local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local Worm = {}
Worm.__index = setmetatable(Worm,UnitManager)


function Worm.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,Worm)

	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["Worm"].Attack);
		Idle = self:LoadAnimation(EntityInfo["Worm"].Idle);
	}

	self.AttackSound = self:LoadSound(EntityInfo["Worm"].Sound)

	--- Empty Constructor
	return self
end

function Worm:Hitbox(Position : Vector3)
	local Detector = Instance.new("Part")
	Detector.Size = Vector3.new(15,10,15)
	Detector.Position = Position
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
			
			if Health then
				Models_Key:SetAttribute("Health",Health - self.Damage)
			end
		end
	end
	
	Detector:Destroy()
end

function Worm:Attack()

	if not self.InCooldown then --- If not in Cooldown Attack
		local TargetHealth = self.Target:GetAttribute("Health")
		self.AttackSound:Play()
		self.Animations.Attack:Play()
		
		self:Hitbox(self.Target.RootPart.Position)
		task.spawn(function()
			self:SetCooldown()
		end)

		task.wait(self.Animations.Attack.Length)
		self.Animations.Attack:Stop()
	else
		--warn("[ UNIT ] - IS IN COOLDOWN....")
	end 
end

function Worm:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return Worm	