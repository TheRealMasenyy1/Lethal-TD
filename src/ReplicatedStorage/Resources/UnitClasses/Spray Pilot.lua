local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local SprayPilot = {}
SprayPilot.__index = SprayPilot
setmetatable(SprayPilot,UnitManager)


function SprayPilot.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,SprayPilot)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["SprayPilot"].Attack);
		Idle = self:LoadAnimation(EntityInfo["SprayPilot"].Idle);
	}

	self.AttackSound = self:LoadSound(EntityInfo["SprayPilot"].Sound)	
	--- Empty Constructor
	return self
end

function SprayPilot:Attack()
	
	if not self.InCooldown then --- If not in Cooldown Attack
		local TargetHealth = self.Target:GetAttribute("Health")
		
		self.Animations.Attack:Play()
		self.AttackSound:Play()
		
		--self.Target:SetAttribute("Health", TargetHealth - self.Damage)
		self:SlowUnit(self.Target,2 + self.Level)
		--self.Target.Humanoid:TakeDamage(self.Damage)

		task.spawn(function()
			self:SetCooldown()
		end)
		
		task.wait(self.Animations.Attack.Length)
		self.Animations.Attack:Stop()
	else
		--warn("[ UNIT ] - IS IN COOLDOWN....")
	end 
end

function SprayPilot:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return SprayPilot
