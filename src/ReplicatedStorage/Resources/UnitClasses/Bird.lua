local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local Bird = {}
Bird.__index = Bird
setmetatable(Bird,UnitManager)


function Bird.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,Bird)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["Bird"].Attack);
		Idle = self:LoadAnimation(EntityInfo["Bird"].Idle);
	}
	
	--- Empty Constructor
	return self
end

function Bird:Attack()

	if not self.InCooldown then --- If not in Cooldown Attack
		local TargetHealth = self.Target:GetAttribute("Health")

		self.Animations.Attack:Play()
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

function Bird:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return Bird
