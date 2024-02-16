
local difficulties = {}

local function getPropertyValue(parent, name)
	local object = parent:FindFirstChild(name)
	if object ~= nil then
		if object:IsA("Folder") then
			local alltheitems = {}
			for _,items in pairs(object:GetChildren()) do
				table.insert(alltheitems,{Name = items.Name, Percentage = items.Value})
			end
			return alltheitems
		else
			return object.Value
		end
	end
end

local function convertWaves(waves)
	local convertedWaves = {}
	
	for i = 1, #waves:GetChildren() do
		local wave = waves:FindFirstChild(i)
		if wave == nil then
			return false, `Wave #{i} does not exist.`
		end
		convertedWaves[i] = {}
		
		-- TODO: add a check to see whether the actual enemy name is valid (when the location of where the enemies are stored is known)
		for _, enemy in wave:GetChildren() do
			local amount = enemy:GetAttribute("Amount")
			local hp = enemy:GetAttribute("HP")
			local Speed = enemy:GetAttribute("Speed")
			local Priority = enemy:GetAttribute("Priority")
			local Direction = enemy:GetAttribute("Direction")
			local IsBoss_ = enemy:GetAttribute("IsBoss")
			local spawnlocation = enemy:GetAttribute("SpawnLocation")
			
			if amount == nil or tonumber(amount) == nil then
				return false, `Wave #{i}, Enemy "{enemy.Name}": "Amount" does not exist or is not a number.`
			end
			
			if hp == nil or tonumber(hp) == nil then
				return false, `Wave #{i}, Enemy "{enemy.Name}": "HP" does not exist or is not a number.`
			end
			
			table.insert(convertedWaves[i], {
				Enemy = enemy.Name,
				Amount = tonumber(amount),
				HP = tonumber(hp),
				IsBoss = IsBoss_,
				Speed = tonumber(Speed),
				Direction = Direction,
				Priority = Priority or 1,
				Spawnlocation = spawnlocation or nil;
			})
		end
	end
	
	return true, convertedWaves
end

local function getBoss(waves : Folder)
	
	for _,Entities in pairs(waves:GetDescendants()) do
		local IsBoss = Entities:GetAttribute("IsBoss")
		if IsBoss then
			return Entities
		end
	end
	
	return nil
end

local function convertDifficulty(difficulty)
	local convertedDifficulty = {}
	
	local startingCash = getPropertyValue(difficulty, "StartingCash")
	local cashPerWave = getPropertyValue(difficulty, "CashPerWave")
	local maxplacement = getPropertyValue(difficulty, "MaxPlacement")

	if startingCash == nil then
		return false, "\"StartingCash\" does not exist."
	end
	if cashPerWave == nil then
		return false, "\"CashPerWave\" does not exist."
	end
	
	local completionRewards = difficulty:FindFirstChild("CompletionRewards")
	local difficultyCompletionReward = getPropertyValue(completionRewards, "Difficulty")
	local waveCompletionReward = getPropertyValue(completionRewards, "Wave")
	local expCompletionReward = getPropertyValue(completionRewards, "Exp")
	local extraRewards = getPropertyValue(completionRewards,"ChanceToGet")
	--local cashfailedrewards = getPropertyValue(failedRewards,"Cash")
	--local Expfailedrewards = getPropertyValue(failedRewards,"Exp")
	
	if difficultyCompletionReward == nil then
		return false, "\"Difficulty\" in \"CompletionRewards\" does not exist."
	end
	if waveCompletionReward == nil then
		return false, "\"Wave\" in \"CompletionRewards\" does not exist."
	end
	
	local waves = difficulty:FindFirstChild("Waves")
	if waves == nil then
		return false, "\"Waves\" does not exist."
	end
	
	local valid, wavesOutput = convertWaves(waves)
	if not valid then
		return false, wavesOutput
	end
	
	convertedDifficulty = {
		StartingCash = startingCash,
		CashPerWave = cashPerWave,
		MaxPlacement = maxplacement,
		Boss = getBoss(waves),
		
		CompletionRewards = {
			Difficulty = difficultyCompletionReward,
			Wave = waveCompletionReward,
			Exp = expCompletionReward,
			ChanceToGet = extraRewards,
		},
		Waves = wavesOutput
	}
	
	return true, convertedDifficulty
end


for _,Floor in script:GetChildren() do
	difficulties[Floor.Name] = {}
	for _, difficulty in Floor:GetChildren() do
		if not difficulty:IsA("Folder") then
			continue
		end
		
		local valid, output = convertDifficulty(difficulty)
		if valid then
			difficulties[Floor.Name][difficulty.Name] = output
		else
			warn(`Difficulty "{difficulty.Name}" is invalid!\n{output}`)
		end
	end	
end

return difficulties