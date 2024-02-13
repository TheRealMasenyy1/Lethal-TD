local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local Hoard = {}
Hoard.__index = Hoard
setmetatable(Hoard,UnitManager)


function Hoard.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,Hoard)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["Hoard"].Attack);
		Idle = self:LoadAnimation(EntityInfo["Hoard"].Idle);
	}
	--- Empty Constructor
	return self
end

function Hoard:Attack()

	if not self.InCooldown then --- If not in Cooldown Attack
		local TargetHealth = self.Target:GetAttribute("Health")

		self.Animations.Attack:Play()
		self.Animations.Attack.Looped = false
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

function Hoard:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return Hoard
