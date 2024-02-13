local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedPackages = ReplicatedStorage.SharedPackage
local Animations = SharedPackages.Viewports

-- Create a new toolbar section titled "Custom Script Tools"
local toolbar = plugin:CreateToolbar("Create ONLY ViewPort")

-- Add a toolbar button named "Create Empty Script"
local newScriptButton = toolbar:CreateButton("Create ViewPort", "Create ViewPort of selected Object", "rbxassetid://14978048121")

-- Make button clickable even if 3D viewport is hidden
newScriptButton.ClickableWhenViewportHidden = false

function CreateViewPort(Object)
	local OldViewPort = Animations:FindFirstChild(Object.Name)
	local Camera = workspace.CurrentCamera
	
	if OldViewPort then
		OldViewPort:Destroy()
	end
	
	local Viewport = Instance.new("ViewportFrame")
	Viewport.BackgroundTransparency = 1
	Viewport.AnchorPoint = Vector2.new(.5,.5)
	Viewport.Position = UDim2.new(.5,0,.5,0)
	Viewport.Size = UDim2.new(1.282, 0,1.08, 0)
	Viewport.Name = Object.Name
	Viewport.Parent = Animations
	
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = Viewport
	
	local newObject = Object:Clone()
	newObject.Parent = worldModel
	
	local newCamera = Camera:Clone()
	newCamera.Parent = Viewport
	
	Viewport.CurrentCamera = newCamera
	
--	local Class = Instance.new("ModuleScript")
--	Class.Parent = ReplicatedStorage.UnitClasses
--	Class.Name = newObject.Name
--	Class.Source = [[
--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local EntityInfo = require(ReplicatedStorage.SharedPackage.Animations)

--local UnitManager = require(ReplicatedStorage.Resources.UnitManager)

--local ]].. newObject.Name ..[[ = {}
--]].. newObject.Name ..[[.__index = setmetatable(]].. newObject.Name ..[[,UnitManager)


--function ]].. newObject.Name ..[[.Setup(Unit)
--	local self = UnitManager.new(Unit)
--	setmetatable(self,]].. newObject.Name ..[[)
	
--	self.Animations = {
--		Attack = self:LoadAnimation(EntityInfo["]].. newObject.Name..[["].Attack);
--		Idle = self:LoadAnimation(EntityInfo["]].. newObject.Name..[["].Idle);
--	}
	
--	self.AttackSound = self:LoadSound(EntityInfo["]].. newObject.Name..[["].Sound)
	
--	--- Empty Constructor
--	return self
--end

--function ]].. newObject.Name ..[[:Attack()
	
--	if not self.InCooldown then --- If not in Cooldown Attack
--		local TargetHealth = self.Target:GetAttribute("Health")
		
--		self.Animations.Attack:Play()
--		self.AttackSound:Play()
		
--		self.Target:SetAttribute("Health", TargetHealth - self.Damage)
--		--self.Target.Humanoid:TakeDamage(self.Damage)

--		task.spawn(function()
--			self:SetCooldown()
--		end)
		
--		task.wait(self.Animations.Attack.Length)
--		self.Animations.Attack:Stop()
--	else
--		--warn("[ UNIT ] - IS IN COOLDOWN....")
--	end 
--end

--function ]].. newObject.Name ..[[:Run()
--	self.Animations.Idle:Play()

--	self:OnZoneTouched(function(Enemy)
--		self:Attack(Enemy)
--	end)
--end

--return ]].. newObject.Name ..[[
--	]]
	
	print(`[ VIEWPORT {newObject.Name} OF HAS BEEN CREATED IN STARTERGUI SET SIZE TO: 1.282, 0,1.08, 0 ]`)
end

function CheckType(Object)
	return Object:IsA("Model")
end

local function onNewScriptButtonClicked()
	local selectedObjects = Selection:Get()
	local Object
	if #selectedObjects > 0 then
		
		if #selectedObjects == 1 and CheckType(selectedObjects[1]) then
			Object = selectedObjects[1]
		else
			warn("[ SELECTED A NONE MODEL OBJECT ]")
		end
	else
		return warn("[ NOTHING IS SELECTED ]")
	end
		
	CreateViewPort(Object)
end

newScriptButton.Click:Connect(onNewScriptButtonClicked)