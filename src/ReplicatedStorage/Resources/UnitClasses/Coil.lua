local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local Coil = {}
Coil.__index = Coil
setmetatable(Coil,UnitManager)


function Coil.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,Coil)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["Coil"].Attack);
		Idle = self:LoadAnimation(EntityInfo["Coil"].Idle);
	}
	--- Empty Constructor
	return self
end

function Coil:Attack()

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

function Coil:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return Coil
