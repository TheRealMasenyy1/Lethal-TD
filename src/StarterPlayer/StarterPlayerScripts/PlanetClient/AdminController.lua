local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local AdminController = Knit.CreateController { Name = "AdminController", Client = {}}

function AdminController:KnitStart()
    
end

function AdminController:KnitInit()

end

return AdminController