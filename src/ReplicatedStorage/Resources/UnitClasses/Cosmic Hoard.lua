 
		
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local CosmicHoard = {}
CosmicHoard.__index = setmetatable(CosmicHoard,UnitManager)


function CosmicHoard.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,CosmicHoard)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["Hoard"].Attack);
		Idle = self:LoadAnimation(EntityInfo["Hoard"].Idle);
	}
	
	--self.AttackSound = self:LoadSound(EntityInfo["Hoard"].Sound)
	
	--- Empty Constructor
	return self
end

function CosmicHoard:Attack()
	
	if not self.InCooldown then --- If not in Cooldown Attack
		local TargetHealth = self.Target:GetAttribute("Health")
		
		self.Animations.Attack:Play()
		self.Animations.Attack.Looped = false
		--self.AttackSound:Play()
		
		self.Target:SetAttribute("Health", TargetHealth - self.Damage)
		--self.Target.Humanoid:TakeDamage(self.Damage)

		task.spawn(function()
			self:SetCooldown()
		end)
		
		task.wait(self.Animations.Attack.Length)
		--self.Animations.Attack:Stop()
	else
		--warn("[ UNIT ] - IS IN COOLDOWN....")
	end 
end

function CosmicHoard:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return CosmicHoard	