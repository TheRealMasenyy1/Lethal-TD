 
		
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local Slime = {}
Slime.__index = setmetatable(Slime,UnitManager)


function Slime.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,Slime)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["Slime"].Attack);
		Idle = self:LoadAnimation(EntityInfo["Slime"].Idle);
	}
		
	--- Empty Constructor
	return self
end

function Slime:Attack()
	
	if not self.InCooldown then --- If not in Cooldown Attack
		local TargetHealth = self.Target:GetAttribute("Health")
		
		self.Animations.Attack:Play()
		 
		self.Target:SetAttribute("Health", TargetHealth - self.Damage)

		task.spawn(function()
			self:SetCooldown()
		end)
		
		task.wait(self.Animations.Attack.Length)
		self.Animations.Attack:Stop()
	else
		--warn("[ UNIT ] - IS IN COOLDOWN....")
	end 
end

function Slime:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return Slime	