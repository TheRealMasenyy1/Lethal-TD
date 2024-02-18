local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)

local LeaderboardService = Knit.CreateService { Name = "LeaderboardService", Client = {}}

local Storage = "HighestWaveEndlessLeaderboard"
local GlobalDatastore =  {
    ["Experimentation Inside"] = DataStoreService:GetOrderedDataStore(Storage)
}

type SaveInfo = {
    Wave : string;
    Time : number;
    MapName : string;
}

local maxItems = 10 --- Only show top ten
local minValueDisplayed = 1
local maxValueDisplayed = 10e15
local GrabDelay = 10
local GlobalLeaderboard = {};

local LastGrab = os.time();
local lastSaved = os.time();

LeaderboardService.Client.RetriveLeaderboard = Knit.CreateSignal()

function GrabGlobalLeaderboard(MapName : string)
    local function LoadLeaderboard()
        local EncodedGlobalLeaderboard = GlobalDatastore[MapName]:GetSortedAsync(false,maxItems,minValueDisplayed,maxValueDisplayed)
        
        if EncodedGlobalLeaderboard then
            GlobalLeaderboard[MapName] = EncodedGlobalLeaderboard:GetCurrentPage() 
            
            for _,info in GlobalLeaderboard[MapName] do
                if info.key then
                    -- warn("WE FOUND THE KEY BUT WE'RE NOT DOING ANYTHING")
                    local _,err = pcall(function()
                        info.playerName = Players:GetNameFromUserIdAsync(info.key)
                    end)

                    if err then -- Testing
                        info.playerName = "Player1"
                        warn(err)
                    end
                end
            end

            print("[ THE DATA HAS BEEN LOADED NOW ] --> ", GlobalLeaderboard)
        end
    end
    
    return Promise.new(function(resolve,reject,_)
        local loadCompleted,err = pcall(LoadLeaderboard)
        
        if loadCompleted then
            resolve("Completed the loading")
        else
            reject(err)
        end
    end)
    
end

function LeaderboardService:Save(player,Info : SaveInfo)
    local timePassed = os.time() - lastSaved 

    local function SaveIntoLeaderboard() 
        local GetplayersData = GlobalDatastore[Info.MapName]:GetAsync(player.UserId)
        
        warn("This is the players data ", GetplayersData)
        
        if not GetplayersData then
            GlobalDatastore[Info.MapName]:SetAsync(player.UserId,Info.Wave)
        else
            GlobalDatastore[Info.MapName]:UpdateAsync(player.UserId,function(Value)
                warn("THE UNIT  ---> ", Value)
                if Value and Value < Info.Wave then
                    lastSaved = os.time() - lastSaved
                    print(`{player.Name} saved data --> `, Info.Wave)
                    return Info.Wave
                end
            end)
        end

                           
    end

    return Promise.new(function(resolve,reject,onCancel)      
        if onCancel(function()
            --- Check the time saved
            warn("[ SAVE WAS CANCELLED ] - FOR ", player.Name)
        end) then return end
        
        if lastSaved < timePassed then
            return reject("Save time time didn't pass | Last saved | ", timePassed)
        end
        
        local completed,result = pcall(SaveIntoLeaderboard)

        if completed then
            print("[ WE SAVED THE PLAYERS DATA ] Lastsaved: ", lastSaved, " timePassed: ", timePassed)
            lastSaved = os.time()
            return resolve(result)
        else
            return warn(result)
        end
    end)
end

function LeaderboardService.Client:RetriveLeaderboard(_,MapName)
    local CheckLastGrab = os.time() - LastGrab 
    local sendToPlayer;
    
    local RetrivedLeaderboard = function(...)
        if CheckLastGrab >= GrabDelay then
            LastGrab = os.time()
            GrabGlobalLeaderboard(...)
            sendToPlayer = GlobalLeaderboard[...]
        else
            sendToPlayer = GlobalLeaderboard[...]
        end
    end

    local isCompleted,err = pcall(RetrivedLeaderboard,MapName)

    if isCompleted then
        print("[ THIS IS WHAT WE GOT BACK ] ---> ", sendToPlayer)
        return sendToPlayer
    else
        return err
    end
end

function LeaderboardService:KnitInit()
    
end
    
function LeaderboardService:KnitStart()
   -- Connect RetriveLeaderboard so that the player can get it  
    GrabGlobalLeaderboard("Experimentation Inside")
    warn("THE DATASTORE THAT IS RETURNED ---> ", GlobalDatastore)
end

return LeaderboardService
