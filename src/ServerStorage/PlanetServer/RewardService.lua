local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local RewardService = Knit.CreateService {Name = "RewardService", Client = {
		SendNotification = Knit.CreateSignal(),
}}
local GameService;
local QuestService;
local GlobalDatastoreService; 
local ProfileService;

local Rewards = {
    ["Experimentation Inside"] = {
        [10] = {
            Name = "Scrap";
            Value = 100
        },
        [20] = {
            Name = "Exp";
            Value = 50
        },
        [30] = {
            Name = "Scrap";
            Value = 200
        },
        [40] = {
            Name = "Exp";
            Value = 150
        },
        [50] = {
            Name = "Gold";
            Value = 5
        },
        [60] = {
            Name = "Exp";
            Value = 200
        },       
        [70] = {
            Name = "Scrap";
            Value = 250
        },
        [80] = {
            Name = "Gold";
            Value = 10
        },
        [90] = {
            Name = "Exp";
            Value = 300
        },
        [100] = {
            Name = "MasterTank";
            Value = "Unit"
        },
        [120] = {
            Name = "Scrap",
            Value = 100
        },
        [150] = {
            Name = "Scrap";
            Value = 350
        },
        [180] = {
            Name = "Scrap",
            Value = 200,
        },
        [200] = {
            Name = "SprayPilot";
            Value = "Unit"
        },
        [250] = {
            Name = "Scrap",
            Value = 550,
        }
    }
}

function RewardService:GiveReward(player,MapName,CurrentWave)
    local Reward = Rewards[MapName][CurrentWave]
    if Reward then
        if Reward.Name == "Exp" then
            QuestService:AddEXP(player,Reward.Value)
        elseif Reward.Name == "Scrap" then
            GameService:RewardScrap(player,Reward.Value)
        elseif Reward.Name == "Gold" then
             ProfileService:Update(player, "Gold", function(Gold)
                return Gold + Reward.Value
            end)           
        else
            local unit = GlobalDatastoreService:CreateUnit(Reward.Name)
            ProfileService:Update(player, "Inventory", function(inventory)
                table.insert(inventory.Units, unit)
                return inventory
            end)
        end
        
        self.Client.SendNotification:Fire(player,`{player.Name} received {Reward.Value} { Reward.Name }`,{Color = Color3.fromRGB(53, 231, 255), Time = 2})
        print(player.Name, " was given ---> ", Reward, " in wave ---> ", CurrentWave)
    end
end

function RewardService.Client:GetRewards()
    return Rewards
end

function RewardService:KnitInit()
    GameService = Knit.GetService("GameService")
    QuestService = Knit.GetService("QuestService")
    GlobalDatastoreService = Knit.GetService("GlobalDatastoreService")
    ProfileService = Knit.GetService("ProfileService")
end

function RewardService:KnitStart()
    
end

return RewardService