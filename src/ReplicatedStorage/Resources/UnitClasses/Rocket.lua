local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local Rocket = {}
Rocket.__index = setmetatable(Rocket,UnitManager)


function Rocket.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,Rocket)
	
	self.Animations = {
		Land = self:LoadAnimation(EntityInfo["Rocket"].Land);
		TakeOff = self:LoadAnimation(EntityInfo["Rocket"].Attack);
		Idle = self:LoadAnimation(EntityInfo["Rocket"].Idle);
	}
	
	self.AttackSound = self:LoadSound(EntityInfo["Rocket"].Sound)
	
	--- Empty Constructor
	return self
end

function Rocket:Attack()
	
	if not self.InCooldown then --- If not in Cooldown Attack
		self.Animations.Land.Looped = false
		
		self.Animations.TakeOff:Play()
		self.AttackSound:Play()
		
		--self.Target:SetAttribute("Health", TargetHealth - self.Damage)
		--self.Target.Humanoid:TakeDamage(self.Damage)

		task.spawn(function()
			self:SetCooldown()
		end)
		
		task.wait(self.Animations.TakeOff.Length)
		self.Animations.Land:Play()
		self.Animations.TakeOff:Stop()
	else
		--warn("[ UNIT ] - IS IN COOLDOWN....")
	end 
end

function Rocket:Run()
	self.Animations.Idle:Play()
	
	while self.IsActive do
		self:Attack()
		task.wait()
	end
end

return Rocket	