local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

local BoomboxPilot = {}
BoomboxPilot.__index = setmetatable(BoomboxPilot,UnitManager)


function BoomboxPilot.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,BoomboxPilot)
	
	self.Time = 2
	self.Animations = {
	--	Attack = self:LoadAnimation(EntityInfo["BoomboxPilot"].Attack);
		Idle = self:LoadAnimation(EntityInfo["BoomboxPilot"].Idle);
	}
	
	--self.AttackSound = self:LoadSound(EntityInfo["BoomboxPilot"].Sound)
	
	--- Empty Constructor
	return self
end

function BoomboxPilot:Run()
	local Sound = self.Unit:FindFirstChildWhichIsA("Sound")
	self.Animations.Idle:Play()

	if Sound then
		Sound:Play()
	end
	
	self.Detector = self:CreateDetector(self.Unit,self.Range)
	
	task.spawn(function()
		while self.IsActive do
			local _,BuffCooldown = math.modf(self.Damage)
			self:BuffUnit({Damage = self.Damage, Cooldown = self.Damage}) 
			task.wait(1)
		end		
	end)
	
	--self:OnZoneTouched(function(Enemy)
	--	self:Attack(Enemy)
	--end)
end

return BoomboxPilot	