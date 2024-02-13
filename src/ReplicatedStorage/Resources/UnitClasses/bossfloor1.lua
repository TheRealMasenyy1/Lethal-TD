 
		
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local bossfloor1 = {}
bossfloor1.__index = setmetatable(bossfloor1,UnitManager)


function bossfloor1.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,bossfloor1)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["bossfloor1"].Attack);
		Idle = self:LoadAnimation(EntityInfo["bossfloor1"].Idle);
	}
	
	self.AttackSound = self:LoadSound(EntityInfo["bossfloor1"].Sound)
	
	--- Empty Constructor
	return self
end

function bossfloor1:Attack()
	
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

function bossfloor1:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return bossfloor1	