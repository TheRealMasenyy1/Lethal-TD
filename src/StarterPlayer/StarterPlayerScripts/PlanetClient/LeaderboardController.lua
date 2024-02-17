local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

local GlobalLeaderboard

function LeaderboardController:ShowLeaderboard()
    GlobalLeaderboard = LeaderboardService:RetriveLeaderboard("Experimentation Inside")
 
    local function createImage(UserId)
        local function getHeadshotUrl(Id)
            return "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Id .. "&width=420&height=420&format=png"
        end
    
        local headshotUrl = getHeadshotUrl(UserId) 
    
        local imageLabel = Instance.new("ImageLabel")
        imageLabel.Size = UDim2.new(0.12, 0, 1, 0) 
        imageLabel.Position = UDim2.new(0.16, 0, 0, 0) 
        imageLabel.Image = headshotUrl
        imageLabel.BackgroundTransparency = 1		
        
        return imageLabel
    end
 
    GlobalLeaderboard:andThen(function(Info)
        for position,playerInfo in Info do
            local playerUI = LeaderboardFrame.Temp:WaitForChild("Players"):Clone()
            local playerImage = createImage(playerInfo.key)
            
            playerUI.Nr.Text = position.. "."
            playerUI.WaveInfo.Text = `Wave: {playerInfo.value} `
            
            local _,_ = pcall(function()
                playerUI.playerName.Text = playerInfo.playerName or "Unknown" 
            end)
            
            playerImage.Parent = playerUI
            playerUI.Parent = LeaderboardFrame
            playerUI.BackgroundTransparency = 1
            playerUI.Visible = true
        end
    end)
    
end

function LeaderboardController:KnitStart()
    self:ShowLeaderboard()
end

function LeaderboardController:KnitInit()
    LeaderboardService = Knit.GetService("LeaderboardService")    
end

return LeaderboardController