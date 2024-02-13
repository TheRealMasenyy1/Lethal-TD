 
		
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local FireSpider = {}
FireSpider.__index = setmetatable(FireSpider,UnitManager)


function FireSpider.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,FireSpider)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["Spider"].Attack);
		Idle = self:LoadAnimation(EntityInfo["Spider"].Idle);
	}
	
	self.AttackSound = self:LoadSound(EntityInfo["Spider"].Sound)
	
	--- Empty Constructor
	return self
end

function FireSpider:Attack()
	
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

function FireSpider:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return FireSpider	