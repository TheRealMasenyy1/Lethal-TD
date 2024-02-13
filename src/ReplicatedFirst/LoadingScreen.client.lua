--local ContentProvider = game:GetService("ContentProvider")
--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local Animation = script.Animations

game.ReplicatedFirst:RemoveDefaultLoadingScreen()
local loading = game.Players.LocalPlayer.PlayerGui:WaitForChild("Loading", 25)
--local LoadObjects = Animation:GetDescendants()


if loading ~= nil then
	loading.Enabled = true	
	--for _,Objects in pairs(LoadObjects) do
	--	if not Objects:IsA("Folder") then
	--		ContentProvider:PreloadAsync({Objects})
	--	end
	--end
end