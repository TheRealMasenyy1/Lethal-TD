local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local CosmicDollPilot = {}
CosmicDollPilot.__index = CosmicDollPilot
setmetatable(CosmicDollPilot,UnitManager)


function CosmicDollPilot.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,CosmicDollPilot)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["CosmicDollPilot"].Attack);
		Idle = self:LoadAnimation(EntityInfo["CosmicDollPilot"].Idle);
	}
	
	self.AttackSound = self:LoadSound(EntityInfo["CosmicDollPilot"].Sound)
	
	--- Empty Constructor
	return self
end

function CosmicDollPilot:Attack()
	
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

function CosmicDollPilot:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return CosmicDollPilot
