local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local Monster = {}
Monster.__index = setmetatable(Monster,UnitManager)


function Monster.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,Monster)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["Monster"].Attack);
		Idle = self:LoadAnimation(EntityInfo["Monster"].Idle);
	}
	
	self.AttackSound = self:LoadSound(EntityInfo["Monster"].Sound)
	
	--- Empty Constructor
	return self
end

function Monster:Attack()
	
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

function Monster:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return Monster	