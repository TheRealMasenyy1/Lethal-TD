 
		
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local Girl = {}
Girl.__index = setmetatable(Girl,UnitManager)


function Girl.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,Girl)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["Girl"].Attack);
		Idle = self:LoadAnimation(EntityInfo["Girl"].Idle);
	}
	
	self.AttackSound = self:LoadSound(EntityInfo["Girl"].Sound)
	
	--- Empty Constructor
	return self
end

function Girl:Attack()
	
	if not self.InCooldown then --- If not in Cooldown Attack
		local TargetHealth = self.Target:GetAttribute("Health")
		
		self.Animations.Attack:Play()
		self.AttackSound:Play()
		
		warn("[ UNITS ] - THE UNITS DAMAGE --> ", self.Unit.Name, " DAMAGE --> ", self.Damage)
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

function Girl:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return Girl	