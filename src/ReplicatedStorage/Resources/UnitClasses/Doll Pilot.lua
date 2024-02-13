local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)
local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local ShovelPilot = {}
ShovelPilot.__index = ShovelPilot
setmetatable(ShovelPilot,UnitManager)


function ShovelPilot.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,ShovelPilot)
	
	self.Animations = {
		Attack = self:LoadAnimation("rbxassetid://15952643248");
		Idle = self:LoadAnimation("rbxassetid://15952646142");
	}
	
	self.AttackSound = self:LoadSound(EntityInfo["DollPilot"].Attack)
	
	return self
end

function ShovelPilot:Attack()
	
	if not self.InCooldown then --- If not in Cooldown Attack
		task.spawn(function()
			self:SetCooldown()
		end)
		
		self.AttackSound:Play()
		task.wait(1)
		
		local TargetHealth = self.Target:GetAttribute("Health")
		self.Animations.Attack:Play()
		
		self.Target:SetAttribute("Health", TargetHealth - self.Damage)
		--self.Target.Humanoid:TakeDamage(self.Damage)
		
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
