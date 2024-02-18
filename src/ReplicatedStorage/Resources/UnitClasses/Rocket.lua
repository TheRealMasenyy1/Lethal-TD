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
		Attack = self:LoadAnimation(EntityInfo["Rocket"].Attack);
		Idle = self:LoadAnimation(EntityInfo["Rocket"].Idle);
	}
	
	self.AttackSound = self:LoadSound(EntityInfo["Rocket"].Sound)
	
	--- Empty Constructor
	return self
end

function Rocket:Attack(Owner)
	
	if not self.InCooldown then --- If not in Cooldown Attack
		
		self.Unit.Plane.Transparency = 0

		for _,player in pairs(game.Players:GetPlayers()) do
			local Cash = player:FindFirstChild("Cash")

			if Cash and player.Name == Owner then
				Cash.Value += self.Damage --- This turns into profit for this unit
				warn("Gave the player this amount ---> ", self.Damage)
			end
		end

		task.spawn(function()
			self:SetCooldown()
		end)		
	end 
end

function Rocket:Run()
	self.Detector = self:CreateDetector(self.Unit,self.Range)
	local CurrentWave = workspace:FindFirstChild("CurrentWave")
	
	self.Animations.Idle:Play()
	
	if CurrentWave then
		local LastWave = CurrentWave.Value
		local Owner = self.Unit:GetAttribute("Owner")
		
		CurrentWave.Changed:Connect(function()
			if CurrentWave.Value > LastWave and self.IsActive then
				LastWave = CurrentWave.Value
				self.Animations.Land:Play()
				
				self:Attack(Owner) -- giving money


				task.delay(self.Animations.Land.Length,function()
					self.Animations.Land:Stop()	
					self.Unit.Plane.Transparency = 1
				end)
				-- self.Animations.TakeOff:Stop()
			end
		end)
	end

	-- while self.IsActive do
		-- self:Attack()
		task.wait()
	-- end
end

return Rocket	