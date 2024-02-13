local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local UnitManager = require(ReplicatedStorage.Resources.UnitManager)
local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

local FlameThrowerPilot = {}
FlameThrowerPilot.__index = FlameThrowerPilot
setmetatable(FlameThrowerPilot,UnitManager)


function FlameThrowerPilot.Setup(Unit)
	local self = UnitManager.new(Unit)
	setmetatable(self,FlameThrowerPilot)
	
	self.Animations = {
		Attack = self:LoadAnimation(EntityInfo["FlamethrowerPilot"].Attack);
		Idle = self:LoadAnimation(EntityInfo["FlamethrowerPilot"].Idle);
	}
	
	self.AttackSound = self:LoadSound(EntityInfo["FlamethrowerPilot"].Sound)
	--- Empty Constructor
	return self
end

function FlameThrowerPilot:Attack()
	
	if not self.InCooldown then --- If not in Cooldown Attack	
		local t = 0
		local Target = self.Target
		self.AttackSound:Play()
		self.Animations.Attack:Play()
		
		task.spawn(function()
			self:SetCooldown()
		end)
				
		self:Burn(Target,3,"Fire")
		
		while self.Animations.Attack.Length > t do
			local RootPart = Target:FindFirstChild("Target")
			if RootPart then
				local Position : Vector3 = Vector3.new(Target.RootPart.Position.X,self.Unit.RootPart:GetPivot().Position.Y,Target.RootPart.Position.Z)
				self.Unit:PivotTo(CFrame.lookAt(self.Unit.RootPart:GetPivot().Position,Position))
			end			
			t += RunService.Heartbeat:Wait()
		end
		
		self.AttackSound:Stop()
		self.Animations.Attack:Stop()	
		--task.wait(self.Animations.Attack.Length)
	else
		--warn("[ UNIT ] - IS IN COOLDOWN....")
	end 
end

function FlameThrowerPilot:Run()
	self.Animations.Idle:Play()

	self:OnZoneTouched(function(Enemy)
		self:Attack(Enemy)
	end)
end

return FlameThrowerPilot
