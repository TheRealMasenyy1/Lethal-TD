 
		
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local HellHound = {}
HellHound.__index = setmetatable(HellHound,UnitManager)


function HellHound.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,HellHound)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["FireMonster"].Attack);
		Idle = self:LoadAnimation(EntityInfo["FireMonster"].Idle);
	}
	
	--self.AttackSound = self:LoadSound(EntityInfo["HellHound"].Sound)
	
	--- Empty Constructor
	return self
end

function HellHound:Attack()
	
	if not self.InCooldown then --- If not in Cooldown Attack
		local TargetHealth = self.Target:GetAttribute("Health")
		
		self.Animations.Attack:Play()
		--self.AttackSound:Play()
		
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

function HellHound:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return HellHound	