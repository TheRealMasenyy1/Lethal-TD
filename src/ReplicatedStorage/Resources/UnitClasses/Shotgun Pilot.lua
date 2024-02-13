local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local ShotgunPilot = {}
ShotgunPilot.__index = setmetatable(ShotgunPilot,UnitManager)


function ShotgunPilot.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,ShotgunPilot)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["ShotgunPilot"].Attack);
		Idle = self:LoadAnimation(EntityInfo["ShotgunPilot"].Idle);
	}
	
	self.AttackSound = self:LoadSound(EntityInfo["ShotgunPilot"].Sound)
	
	--- Empty Constructor
	return self
end

function ShotgunPilot:Attack()
	
	if not self.InCooldown then --- If not in Cooldown Attack
		local TargetHealth = self.Target:GetAttribute("Health")
		local RootPart = self.Unit.RootPart
		local ShootEmitter = RootPart["Attachment"].ShootEmitter
		
		self.Animations.Attack:Play()
		self.AttackSound:Play()
		
		ShootEmitter:Emit(100)
		self.Target:SetAttribute("Health", TargetHealth - self.Damage)

		task.spawn(function()
			self:SetCooldown()
		end)
		
		task.wait(self.Animations.Attack.Length)
		self.Animations.Attack:Stop()
	else
		--warn("[ UNIT ] - IS IN COOLDOWN....")
	end 
end

function ShotgunPilot:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return ShotgunPilot	