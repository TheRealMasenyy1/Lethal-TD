local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local IrisModule = require(ReplicatedStorage.Resources.Iris)
local maid = require

local Iris = IrisModule.Init()
local AdminController = Knit.CreateController { Name = "AdminController", Client = {}}

local player = game.Players.LocalPlayer
local Mouse = player:GetMouse()

local AdminService;
local Fps = 60;

function AdminController:DisplayStats(Target)
    local TargetInfo = AdminService:SelectAndDisplayAttributs(Target)  
    local Entity_States = {}

    TargetInfo:andThen(function(Attributes)
        for name,value in pairs(Attributes) do
            Entity_States[name] = {Object = nil, Value = Iris.State(value)}
        end

        Iris.Separator()
        Iris.Table({3,20,3})
            for Attribute,status in pairs(Entity_States) do
                local valuetype = typeof(status.Value:get())
                Iris.Text({Attribute})
                
                Iris.NextColumn()
                Iris.Text({valuetype})
                Iris.NextColumn()
                if valuetype == "number" then
                    status.Object = Iris.InputNum({ "" }, {number = status.Value, editingText = true})
                elseif valuetype == "boolean" then
                    status.Object = Iris.Checkbox({""}, {isChecked = status.Value})
                end
                Iris.NextColumn()
            end
        Iris.End()   
    end)
    
end

function AdminController:CreateWindow()
    local WindowSize = Iris.State(Vector2.new(300,400))
    local waitingForSelection = false
    
    local Target;

    task.spawn(function()
        RunService.RenderStepped:Connect(function()
            Fps = workspace:GetRealPhysicsFPS()
        end)
    end)

    Iris.Window({"Admin Panel"}, {size = WindowSize })
        Iris.Text({"FPS: " .. Fps})
        Iris.Tree({"Select Attacker"})
            if Iris.Button({"Select Target"}).clicked() then
                waitingForSelection = not waitingForSelection

                while waitingForSelection do
                    Target = Mouse.Target

                    if Target then
                        local RootPart = Target.Parent:FindFirstChild("RootPart") or Target.Parent:FindFirstChild("HumanoidRootPart")
                        print("Looking for an attacker --> ", Target.Name)
                        if RootPart then
                            Target = RootPart.Parent
                            break;
                        -- else

                        end
                    end
                    task.wait()
                end
                
                warn("Target is selected ---> ", Target)
                self:DisplayStats(Target)
            end
        Iris.End()
    Iris.End()
end

function AdminController:StartIris()
    print("WELCOME TO THE ADMINPANEL")
    Iris:Connect(function()
        self:CreateWindow()
    end)
end

function AdminController:KnitStart()
    AdminService = Knit.GetService("AdminService")

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        local HasAcces = AdminService:GrantAccess()
        if HasAcces and input.KeyCode == Enum.KeyCode.M then
            self:StartIris()
        end
    end)
   
end

function AdminController:KnitInit()
end

return AdminController