local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Cmdr = require(game:GetService("ReplicatedStorage"):WaitForChild("CmdrClient"))
local PlaceIds = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"):WaitForChild("PlaceIds"))

Knit.Modules = script.Parent:WaitForChild("Client"):WaitForChild("Modules")
Knit.Shared = game:GetService("ReplicatedStorage"):WaitForChild("Common")

Cmdr:SetActivationKeys({Enum.KeyCode.RightBracket})

if game.PlaceId ~= PlaceIds.Update then
	Knit.AddControllersDeep(script.Parent:WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Global"))
end
if game.PlaceId == PlaceIds.Planet or game.PlaceId == PlaceIds.PlanetEndless then
	Knit.AddControllersDeep(script.Parent:WaitForChild("PlanetClient"))
end
-- if game.PlaceId == 15485926725 then -- Testing Lobby
-- 	Knit.AddControllersDeep(script.Parent:WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("TestingLobby"))
-- end
Knit.AddControllersDeep(script.Parent:WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild(if PlaceIds[game.PlaceId] == "PlanetEndless" then "Planet" else PlaceIds[game.PlaceId]))
Knit.Start()