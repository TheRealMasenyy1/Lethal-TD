local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local AdminService = Knit.CreateService { Name = "AdminService", Client = {}}

local Access = { 92260968 }

AdminService.Client.GrantAccess = Knit.CreateSignal()
AdminService.Client.PropertyAccess = Knit.CreateSignal()



function AdminService:KnitStart()

    self.Client.GrantAccess:Connect(function(player)
        local HasAccess = table.find(Access,player.UserId)

        if HasAccess then
            --- Do something
            
        else
            --- ADD HIM TO DATASTORE
            player:Kick("YOU HAVE BEEN FLAGGED AND WILL BE INVESTIGATED") 
        end
    end)
    
end

function AdminService:KnitInit()

end

return AdminService