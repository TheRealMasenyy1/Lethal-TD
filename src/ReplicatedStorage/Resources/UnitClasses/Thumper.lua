 
		
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local Thumper = {}
Thumper.__index = setmetatable(Thumper,UnitManager)


function Thumper.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,Thumper)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["Thumper"].Attack);
		Idle = self:LoadAnimation(EntityInfo["Thumper"].Idle);
	}
	
	self.AttackSound = self:LoadSound(EntityInfo["Thumper"].Sound)
	
	--- Empty Constructor
	return self
end

function Thumper:Attack()
	
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

function Thumper:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return Thumper	