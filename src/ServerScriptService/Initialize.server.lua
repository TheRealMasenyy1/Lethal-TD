local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Cmdr = require(game:GetService("ServerStorage").Packages.Cmdr)
local PlaceIds = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"):WaitForChild("PlaceIds"))

Knit.Modules = game:GetService("ServerStorage"):WaitForChild("Server"):WaitForChild("Modules")
Knit.Shared = game:GetService("ReplicatedStorage"):WaitForChild("Common")

if game.PlaceId ~= PlaceIds.Update then
	Knit.AddServicesDeep(game:GetService("ServerStorage"):WaitForChild("Server"):WaitForChild("Services"):WaitForChild("Global"))
end
if game.PlaceId == PlaceIds.Planet then
	Knit.AddServicesDeep(game:GetService("ServerStorage"):WaitForChild("PlanetServer"))
end
-- if game.PlaceId == 15485926725 then -- Testing Lobby
-- 	Knit.AddServicesDeep(game:GetService("ServerStorage"):WaitForChild("Server"):WaitForChild("Services"):WaitForChild("TestingLobby"))
-- end
Knit.AddServicesDeep(game:GetService("ServerStorage"):WaitForChild("Server"):WaitForChild("Services"):WaitForChild(PlaceIds[game.PlaceId]))
Knit.Start()

if game.PlaceId ~= PlaceIds.Update then
	Cmdr:RegisterHooksIn(game:GetService("ServerStorage"):WaitForChild("Server"):WaitForChild("Cmdr"):WaitForChild("Hooks"):WaitForChild("Global"))
	Cmdr:RegisterCommandsIn(game:GetService("ServerStorage"):WaitForChild("Server"):WaitForChild("Cmdr"):WaitForChild("Commands"):WaitForChild("Global"))
end

local cmdrHooksForPlace = game:GetService("ServerStorage"):WaitForChild("Server"):WaitForChild("Cmdr"):WaitForChild("Hooks"):FindFirstChild(PlaceIds[game.PlaceId])
local cmdrCommandsForPlace = game:GetService("ServerStorage"):WaitForChild("Server"):WaitForChild("Cmdr"):WaitForChild("Commands"):FindFirstChild(PlaceIds[game.PlaceId])
if cmdrHooksForPlace ~= nil then
	Cmdr:RegisterHooksIn(cmdrHooksForPlace)
end
if cmdrCommandsForPlace ~= nil then
	Cmdr:RegisterCommandsIn(cmdrCommandsForPlace)
end