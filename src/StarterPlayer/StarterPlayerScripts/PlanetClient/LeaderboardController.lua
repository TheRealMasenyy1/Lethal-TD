local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LeaderboardController = Knit.CreateController { Name = "LeaderboardController" }

local LeaderboardService;
local player = game:GetService("Players").LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")
local Core = playerGui:WaitForChild("Core")
local Intermission = Core:WaitForChild("Intermission")
local IntermissionContent = Intermission:WaitForChild("Content")

local Leaderboard = IntermissionContent:WaitForChild("Leaderboard")
local LeaderboardFrame = Leaderboard:WaitForChild("Frame")

function LeaderboardController:ShowLeaderboard(Info)
    local function createImage(UserId)
        -- Function to get the headshot URL of a player
        local function getHeadshotUrl(Id)
            return "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Id .. "&width=420&height=420&format=png"
        end
    
        -- Example usage
        local headshotUrl = getHeadshotUrl(UserId) -- Get the headshot URL
    
        -- Create an ImageLabel to display the headshot
        local imageLabel = Instance.new("ImageLabel")
        imageLabel.Size = UDim2.new(0.12, 0, 1, 0) -- Set the size of the ImageLabel
        imageLabel.Position = UDim2.new(0.16, 0, 0, 0) -- Set the position of the ImageLabel
        imageLabel.Image = headshotUrl
        imageLabel.BackgroundTransparency = 1		
        
        return imageLabel
    end
 
    for position,playerInfo in Info do
        local playerUI = LeaderboardFrame.Temp:WaitForChild("Players"):Clone()
        local playerImage = createImage(playerInfo.key)
        
        playerUI.Nr.Text = position.. "."
        playerUI.WaveInfo.Text = `Wave: {playerInfo.value} `
        playerUI.playerName.Text = playerInfo.playerName 
        playerImage.Parent = playerUI
        playerUI.Parent = LeaderboardFrame
        playerUI.BackgroundTransparency = 1
        playerUI.Visible = true
    end
end

function LeaderboardController:KnitStart()
    local GlobalLeaderboard = LeaderboardService:RetriveLeaderboard("Experimentation Inside")
    
    GlobalLeaderboard:andThen(function(value)
        print("[ THE GLOBAL LEADERBOARD WE GOT BACK ---> ] ", value)
        self:ShowLeaderboard(value)

    end)
end

function LeaderboardController:KnitInit()
    LeaderboardService = Knit.GetService("LeaderboardService")    
end

return LeaderboardController