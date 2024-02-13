 
		
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local YieldPilot = {}
YieldPilot.__index = setmetatable(YieldPilot,UnitManager)


function YieldPilot.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,YieldPilot)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["YieldPilot"].Attack);
		Idle = self:LoadAnimation(EntityInfo["YieldPilot"].Idle);
	}
	
	self.AttackSound = self:LoadSound(EntityInfo["YieldPilot"].Sound)
	
	--- Empty Constructor
	return self
end

function YieldPilot:Attack()
	
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

function YieldPilot:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return YieldPilot	