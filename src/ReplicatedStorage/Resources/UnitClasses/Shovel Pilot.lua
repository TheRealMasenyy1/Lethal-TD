local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local ShovelPilot = {}
ShovelPilot.__index = ShovelPilot
setmetatable(ShovelPilot,UnitManager)


function ShovelPilot.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,ShovelPilot)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["ShovelPilot"].Attack);
		Idle = self:LoadAnimation(EntityInfo["ShovelPilot"].Idle);
	}
	
	self.AttackSound = self:LoadSound(EntityInfo["ShovelPilot"].Sound)
	
	--- Empty Constructor
	return self
end

function ShovelPilot:Attack()
	
	if not self.InCooldown then --- If not in Cooldown Attack
		local TargetHealth = self.Target:GetAttribute("Health")
		
		self.Animations.Attack:Play()
		self.AttackSound:Play()
		
		self.Target:SetAttribute("Health", TargetHealth - self.Damage)
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

function ShovelPilot:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return ShovelPilot
