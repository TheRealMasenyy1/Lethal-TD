local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local AdminService = Knit.CreateService { Name = "AdminService", Client = {}}

local Access = { 92260968 }

AdminService.Client.GrantAccess = Knit.CreateSignal()
AdminService.Client.AccessCommands = Knit.CreateSignal()

function HasAccess(player)
    local AccessToCommands = table.find(Access,player.UserId)

    if AccessToCommands then
        return true
    else
        return false
        -- player:Kick("You have been Flagged and will be investigated")
    end
end

function AdminService.Client:GrantAccess(player)
    local GiveAccess = HasAccess(player)
    return GiveAccess
end

function AdminService.Client:SelectAndDisplayAttributs(player,Target : Model)
    local GiveAccess = HasAccess(player)

    if GiveAccess then
        local Attributes = Target:GetAttributes()
        return Attributes
    end

    return warn("Can't find the Target")
end

function AdminService:GetEntity(Id,Info : {Name : string, Value : any})
    local Folder = workspace.Floors:GetDescendants()

    for _,Models in pairs(Folder) do
        local ModelId = Models:GetAttributes("Id")

        if ModelId == Id then
            return Models
        end
    end
    return nil
end

function AdminService:KnitStart()
    self.Client.AccessCommands:Connect(function(player,Prompt,Args)
        local Admin = HasAccess(player)
        
        if Admin then
            if Prompt == "Change" then
                local Entity = self:GetEntity(Args.Id,Args)

                if Entity then
                    Entity:SetAttribute(Args.Name,Args.Value)
                end
            end
            --- Fire Commands
        end
    end)  
end

function AdminService:KnitInit()

end

return AdminService