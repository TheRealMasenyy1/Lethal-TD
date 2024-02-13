 
		
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local shovsignhaz = {}
shovsignhaz.__index = setmetatable(shovsignhaz,UnitManager)


function shovsignhaz.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,shovsignhaz)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["StopsignPilot"].Attack);
		Idle = self:LoadAnimation(EntityInfo["StopsignPilot"].Idle);
	}
	
	self.AttackSound = self:LoadSound(EntityInfo["StopsignPilot"].Sound)
	
	--- Empty Constructor
	return self
end

function shovsignhaz:Attack()
	
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

function shovsignhaz:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return shovsignhaz	