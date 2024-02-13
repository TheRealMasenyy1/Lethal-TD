local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)


local Bracken = {}
Bracken.__index = Bracken
setmetatable(Bracken,UnitManager)


function Bracken.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,Bracken)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["Bracken"].Attack);
		Idle = self:LoadAnimation(EntityInfo["Bracken"].Idle);
	}
	--- Empty Constructor
	return self
end

function Bracken:Attack()

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

function Bracken:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return Bracken
