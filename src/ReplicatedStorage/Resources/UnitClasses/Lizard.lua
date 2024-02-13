 
		
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local Lizard = {}
Lizard.__index = setmetatable(Lizard,UnitManager)


function Lizard.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,Lizard)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["Lizard"].Attack);
		Idle = self:LoadAnimation(EntityInfo["Lizard"].Idle);
	}
	
	--self.AttackSound = self:LoadSound(EntityInfo["Lizard"].Sound)
	
	--- Empty Constructor
	return self
end

function Lizard:Attack()
	
	if not self.InCooldown then --- If not in Cooldown Attack
		local TargetHealth = self.Target:GetAttribute("Health")
		
		self.Animations.Attack:Play()
		--self.AttackSound:Play()
		
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

function Lizard:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return Lizard	