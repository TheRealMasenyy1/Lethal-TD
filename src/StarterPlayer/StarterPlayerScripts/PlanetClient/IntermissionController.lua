--- HANDLES THE THE GAME WHEN THE PLAYER HAS JOINED ---
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")


local SharedPackages = ReplicatedStorage.SharedPackage
local player = game:GetService("Players").LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local Shortcut = require(ReplicatedStorage.Shortcut)
local Maid = require(ReplicatedStorage.maid)

local Viewports = SharedPackages.Viewports

local Core = player.PlayerGui:WaitForChild("Core")
local Content = Core:WaitForChild("Content")
local IntermissionFrame = Core:WaitForChild("Intermission")
local InterMissionUI = IntermissionFrame:WaitForChild("Content")
local FloorInfoUI = InterMissionUI:WaitForChild("FloorInfo")
local FloorsUI = InterMissionUI:WaitForChild("Floors")
local FloorDisplay = FloorsUI:WaitForChild("Frame")
local RoomsFrame = InterMissionUI:WaitForChild("Rooms")
local ViewportLocation = {}
local ViewportLocationForDifficulties = {}


local Floors_Folder = workspace.Floors
local CheckForUpdate = false
local AlreadyVoted = false

local maid = Maid.new()
local MapMaid = nil;

local DefaultFloor = 1
local Selected = {
	Floor = "Floor1", 
	Room = "Room1",
	MaxPlacement = 0;
	Difficulty = "Easy"
}

local IntermissionController = Knit.CreateController { Name = "IntermissionController"; }

local MapImage = {
	["Experimentation"] = "rbxassetid://16216878734",
	["Mansion"] = "rbxassetid://16216877287",
	["Rend"] = "rbxassetid://16216876750",
	["Vow"] = "rbxassetid://16216876222",
}

function IntermissionController:ShowFloorInfo()
	
end

function IntermissionController:GetFloors()
	local Floors = {}
	
	for _, floor in pairs(Floors_Folder:GetChildren()) do
		Floors[floor.Name] = {}
		for _, room in pairs(floor:GetChildren()) do
			table.insert(Floors[floor.Name],room.Name)
		end
	end
	
	return Floors
end

function IntermissionController:ClearFloorFrame()
	for _,UI in pairs(FloorDisplay:GetChildren()) do
		if UI:IsA("TextButton") then
			UI:Destroy() 
		end
	end
end

function IntermissionController:ClearRoomFrame()
	ViewportLocationForDifficulties = {}
	for _,UI in pairs(RoomsFrame.Frame:GetChildren()) do
		if UI:IsA("TextButton") then
			UI:Destroy() 
		end
	end
end

function IntermissionController:ShowRooms(_,currentFloor,FloorData,RoomsInFloor,_)
	local Rooms = {}
	local MainFrame = RoomsFrame.Frame
	local temp = MainFrame.Temp
	currentFloor = currentFloor or 1
	FloorData = FloorData or {}
	
	self:ClearRoomFrame()
	local Result = {
		Unlocked = Color3.fromRGB(85, 255, 255),
		Locked = Color3.fromRGB(255,0,0)
	}

	local Difficulties = {
		[1] = "Easy",
		[2] = "Medium",
		[3] = "Hard",
		[4] = "Insane",
		[5] = "Impossible",
		-- Add one more
	}
	

	--[[
	
		THIS IS WAS THE FLOOR  
	
	
	--]]
	
	
	
	for currentRoom : IntValue, Difficulty : string in pairs(Difficulties) do
		--- This will have to set bro this and that
		if RoomsInFloor[Difficulty] then
			local newBtn = temp.Room:Clone()
			newBtn.Nr.Text = "Act " .. tostring(currentRoom)
			newBtn.Name = "Room" .. tostring(currentRoom)
			newBtn:SetAttribute("Floor","Floor"..currentFloor)
			newBtn.Parent = MainFrame
			newBtn.Visible = true

			--print("FLOOR ", currentFloor, " INFO ", FloorData[tostring(currentFloor)], currentRoom)
			if (FloorData[currentFloor] and FloorData[currentFloor] < currentRoom) or (not FloorData[currentFloor]) then
				newBtn.BackgroundColor3 = Result["Locked"]
				newBtn.UIStroke.Color = Result["Locked"]	
				
			elseif FloorData[currentFloor] and FloorData[currentFloor] >= currentRoom then
				newBtn.BackgroundColor3 = Result["Unlocked"]
				newBtn.UIStroke.Color = Result["Unlocked"]

				maid:GiveTask(newBtn.Activated:Connect(function()
					Shortcut:PlaySound("MouseClick")
					if not AlreadyVoted then
						Selected.Difficulty = Difficulties[currentRoom]
					end
					--warn("[ SELECTED ROOM ] - ", Selected.Difficulty)
					-- = "Room" .. currentRoom
					--- Teleport to room
				end))
			end
			
			table.insert(Rooms,newBtn)
		end
	end
	
	--for currentRoom,Name in ipairs(Info) do
	--	local newBtn = temp.Room:Clone()
	--	newBtn.Nr.Text = "Room " .. currentRoom
	--	newBtn.Parent = MainFrame
	--	newBtn.Visible = true
		
	--	--print("FLOOR ", currentFloor, " INFO ", FloorData[tostring(currentFloor)], currentRoom)
	--	if (FloorData[currentFloor] and FloorData[currentFloor] < currentRoom) or (not FloorData[currentFloor]) then
	--		newBtn.BackgroundColor3 = Result["Locked"]
	--		newBtn.UIStroke.Color = Result["Locked"]	
	--	elseif FloorData[currentFloor] and FloorData[currentFloor] >= currentRoom then
	--		newBtn.BackgroundColor3 = Result["Unlocked"]
	--		newBtn.UIStroke.Color = Result["Unlocked"]
			
	--		maid:GiveTask(newBtn.Activated:Connect(function()
	--			Selected.Difficulty = "Easy"
	--			-- = "Room" .. currentRoom
	--			--- Teleport to room
	--		end))
	--	end
		
	--	table.insert(Rooms,newBtn)
	--end
	
	return Rooms
end

function IntermissionController:CreateViewport()
	local ViewportsHolder = {}
	local ViewportsForRooms = {}
	local function create(Targetplayer)
		-- Function to get the headshot URL of a player
		local function getHeadshotUrl(plr)
			return "https://www.roblox.com/headshot-thumbnail/image?userId=" .. plr.UserId .. "&width=420&height=420&format=png"
		end

		-- Example usage
		local headshotUrl = getHeadshotUrl(Targetplayer) -- Get the headshot URL

		-- Create an ImageLabel to display the headshot
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Size = UDim2.new(1, 0, 1, 0) -- Set the size of the ImageLabel
		imageLabel.Position = UDim2.new(0, 0, 0, 0) -- Set the position of the ImageLabel
		imageLabel.Image = headshotUrl
		imageLabel.BackgroundTransparency = 1		
		
		return imageLabel
	end

	for _, Targetplayer in pairs(game.Players:GetChildren()) do
		local ViewportForPlayer = create(Targetplayer)
		ViewportsHolder[Targetplayer.Name] = ViewportForPlayer 
		ViewportsForRooms[Targetplayer.Name] = ViewportForPlayer:Clone()
	end

	-- Create a ViewportFrame
	return ViewportsHolder,ViewportsForRooms
end

function IntermissionController:ApplyVoteImage(playerViewport : ViewportFrame, Data)
	local RoomHolder = RoomsFrame.Frame
	local FloorBtn = FloorDisplay:FindFirstChild(Data.Floor)
	-- The Floor Holder --> FloorDisplay
	if not playerViewport then return end
	
	local function getEmptySlot(Btn,_)
		for i = 1, 4 do
			local Frame = Btn[i]
			local Viewport = Frame:FindFirstChildWhichIsA("ViewportFrame")
			
			if not Viewport and (not ViewportLocation[playerViewport.Name] or ViewportLocation[playerViewport.Name].Name ~= Btn.Name ) then
				return true,Frame
			end
		end
		
		return false
	end
	
	if FloorBtn then
		local IsEmpty,Frame = getEmptySlot(FloorBtn,"Floor")
		
		if IsEmpty and playerViewport then
			playerViewport.Parent = Frame
			ViewportLocation[playerViewport.Name] = Frame.Parent
		end
	end
end

function IntermissionController:ApplyVoteImageForRooms(playerViewport : ViewportFrame, Data)
	local RoomHolder = RoomsFrame.Frame
	local Difficulties = {
		["Easy"] = 1,
		["Medium"] = 2,
		["Hard"] = 3,
		["Insane"] = 4,
		["Impossible"] = 5,
		-- Add one more
	}
	
--	warn("THE DATA FOR VOTING IN THE ROOM ---->> ", Data) -- 
	if not Difficulties[Data.Difficulty] then return end
	
	local RoomBtn = RoomHolder:FindFirstChild("Room" .. Difficulties[Data.Difficulty])
	
	local function getEmptySlot(Btn,_)
		for i = 1, 4 do
			local Frame = Btn[i]
			local Viewport = Frame:FindFirstChildWhichIsA("ViewportFrame")

			if not Viewport and RoomBtn:GetAttribute("Floor") == Data.Floor  and (not ViewportLocationForDifficulties[playerViewport.Name] or ViewportLocationForDifficulties[playerViewport.Name].Name ~= Btn.Name ) then
				return true,Frame
			end
		end

		return false
	end

	if RoomBtn then
		local IsEmpty,Frame = getEmptySlot(RoomBtn,"Floor")

		--warn("Parenting to ---> ",playerViewport , playerViewport:IsDescendantOf(FloorBtn))
		if IsEmpty and playerViewport then
			playerViewport.Parent = Frame
			ViewportLocationForDifficulties[playerViewport.Name] = Frame.Parent
		end
	end
end

function IntermissionController:StartInter(ChapterData)
	local MatchService = Knit.GetService("MatchService")
	local StartGame_btn = RoomsFrame:WaitForChild("Play")
	local VoteLabel = RoomsFrame:WaitForChild("VoteLabel")
	local Countdown = RoomsFrame:WaitForChild("Countdown")
	
	local StartGameFrame = Content:WaitForChild("StartGame")
	local GameService = Knit.GetService("GameService")

	local ChapterInfo = MatchService:ChapterInfo()
	
	local playerviewports,playerViewportForRooms
	local Difficulties = {
		["Easy"] = 1,
		["Medium"] = 2,
		["Hard"] = 3,
		["Insane"] = 4,
		["Impossible"] = 5,
		-- Add one more
	}
	
	task.spawn(function()
		local succ = pcall(function()
			game:GetService("StarterGui"):SetCore("ResetButtonCallback", false)
		end)
		
		if not succ then
			warn(" COULD NOT DISABLE THE RESETBUTTON ")
		end
	end)
	
	MapMaid = Maid.new()
	InterMissionUI.Visible = true
	
	if UserInputService.GamepadEnabled then
		GuiService:Select(player.PlayerGui)
	end
	
	CheckForUpdate = false
	AlreadyVoted = false

	if not CheckForUpdate then -- This is for updating the Intermission Floor Selection
		local Votes = MatchService:GetVotes()
		CheckForUpdate = true
		task.spawn(function()
			
			while CheckForUpdate do
				Votes = MatchService:GetVotes()
				playerviewports,playerViewportForRooms = self:CreateViewport()

				Votes:andThen(function(VoteInfo)
					local Vote = 0
					for players,playerInfo in pairs(VoteInfo) do
						if players then
							self:ApplyVoteImage(playerviewports[players],playerInfo)
							self:ApplyVoteImageForRooms(playerViewportForRooms[players], playerInfo)
						end
						
						if playerInfo["Floor"] and playerInfo["Floor"] == Selected.Floor then
							Vote += 1
							VoteLabel.Text = Vote .. "/" .. #game.Players:GetChildren()
						elseif playerInfo["Floor"] and playerInfo["Floor"] ~= Selected.Floor then
							VoteLabel.Text = Vote .. "/" .. #game.Players:GetChildren()
						end					
					end
				end)
				task.wait()
			end
		end)
	end
	
	ChapterInfo:andThen(function(Info)
		local FloorName = Floors_Folder["Floor"..DefaultFloor]:GetAttribute("FloorName")
		local BossName = Floors_Folder["Floor"..DefaultFloor]:GetAttribute("BossName")
		local countdown_value = workspace:FindFirstChild("Countdown")
		local Chapter = Info[FloorName];
		--StartGame_btn.Label.Text = "Play"

		VoteLabel.Text =  "0/" .. #game.Players:GetChildren()

		-- Setting the default Floor
		FloorInfoUI:WaitForChild("FloorName").Text = FloorName
		FloorInfoUI:WaitForChild("BossName").Text = BossName
		
		if countdown_value then
			countdown_value.Changed:Connect(function()
				Countdown.Text = string.format("%.1f",countdown_value.Value)
			end)
		end
		
		local function cooldown(Time : number)
			local CountDown_tm = Time

			task.spawn(function()
				while CountDown_tm > 0 and IntermissionFrame.Visible do
					CountDown_tm -= RunService.Heartbeat:Wait()

					--print("COUNT DOWN UNTIL THE FIRST MAPS GETS LOADED")
					if CountDown_tm <= 0 then
						--MatchService.Play:Fire({},true)
						warn("[ INFO ] - GAME HAS STARTED DUE TO COUNTDOWN")
						break
					end

					Countdown.Text = string.format("%.1f",CountDown_tm)
				end
				
				CountDown_tm = 10
				Countdown.Text = CountDown_tm
 				Countdown.Text = string.format("%.1f",CountDown_tm)
			end)
		end

		MatchService.Start:Connect(function()
			--cooldown(12)
		end)

		-- Close intermission
		MatchService.CloseIntermission:Connect(function()
			Content.Visible = true
			StartGameFrame.Visible = true
			IntermissionFrame.Visible = false
			InterMissionUI.Visible = true
			CheckForUpdate = false
			self:ClearFloorFrame()
			self:ClearRoomFrame()
		end)
		
		local Voted = false		
		
		maid:GiveTask(StartGame_btn.Activated:Connect(function() -- VOTE PLAY BUTTON
			if Selected.Room ~= "" and Selected.Floor ~= "" and not Voted then
				Voted = true	
				Shortcut:PlaySound("MouseClick")
				GuiService.SelectedObject = nil
				AlreadyVoted = true
				
				GameService:Vote(Selected.Floor, Difficulties[Selected.Difficulty])
				MatchService.Play:Fire(Selected)
				VoteLabel.Text =  "0/" .. #game.Players:GetChildren()
			end
		end))		

		local function SelectFloor(Name,currentFloor,FloorData)
			FloorName = Floors_Folder[Name]:GetAttribute("FloorName")
			BossName = Floors_Folder[Name]:GetAttribute("BossName")
			Chapter = Info[FloorName]

			local BossImage = Viewports:FindFirstChild(BossName)

			pcall(function()
				FloorInfoUI.MapIcon.Image = MapImage[FloorName]
			end)
			
			FloorInfoUI:WaitForChild("FloorName").Text = FloorName
			FloorInfoUI:WaitForChild("BossName").Text = BossName
			
			if BossImage then
				local OldImage = FloorInfoUI.BossIcon:FindFirstChildWhichIsA("ViewportFrame")

				if OldImage then
					OldImage:Destroy()
				end

				local newImage = BossImage:Clone()
				newImage.Parent = FloorInfoUI.BossIcon
			end
			
			if not AlreadyVoted then
				Selected.Floor = Name
				Selected.Difficulty = "Easy"		
			end
			
			return self:ShowRooms(ChapterData[Name],currentFloor,FloorData,Chapter,FloorName)
		end

		local ProfileService = Knit.GetService("ProfileService")

		local Result = {
			Unlocked = Color3.fromRGB(26, 255, 0),
			Locked = Color3.fromRGB(255,0,0)
		}
		
		
		--[[
		
		function compareTables(...)
			local inputTables = {...}
			local commonValues = {}

			for key, value in pairs(inputTables[1]) do
				local minValue = value 

				local isCommonValue = true
				for i = 2, #inputTables do
					local currentValue = inputTables[i][key]
					if not currentValue or currentValue ~= value + 1 then
						isCommonValue = false
						break
					end
					if currentValue < minValue then
						minValue = currentValue
					end
				end

				if isCommonValue then
					table.insert(commonValues, minValue)
				end
			end

			return commonValues
		end

		local inputTable1 = {
			[1] = 1,
			[2] = 3,
			[3] = 4,
			[4] = 5
		}

		local inputTable2 = {
			[1] = 2,
		}

		local inputTable3 = {
			[1] = 2,
			[2] = 1
		}

		local commonValues = compareTables(inputTable1, inputTable2,inputTable3)
		
		print(commonValues)
		
		--]]
		
	
		ProfileService:OnProfileReady():andThen(function()
			ProfileService:OnProfileReady():await()
			MatchService:GetPlayersFloors():andThen(function(FloorData)
				print("PLAYER HAS LOADED HERE IS THE COMMONFLOORS ---> ",FloorData)

				self:ClearFloorFrame()
				
				for currentFloor = 1,#Floors_Folder:GetChildren() do
					local Name = "Floor"..currentFloor
					local temp = FloorDisplay.Temp
					local Unlocked = false

					local newfloorbtn = temp.Floorbtn:Clone()
					newfloorbtn.Nr.Text = currentFloor
					newfloorbtn.Parent = FloorDisplay
					newfloorbtn.Name = "Floor"..currentFloor
					newfloorbtn.Visible = true

					if currentFloor > (#FloorData) then
						newfloorbtn.BackgroundColor3 = Result["Locked"]
						newfloorbtn.UIStroke.Color = Result["Locked"]	
					else
						newfloorbtn.BackgroundColor3 = Result["Unlocked"]
						newfloorbtn.UIStroke.Color = Result["Unlocked"]
						Unlocked = true
					end

					if not Unlocked then
						maid:GiveTask(newfloorbtn.Activated:Connect(function()
							Shortcut:PlaySound("MouseClick")

							local selectedFloor = SelectFloor(Name)
							if UserInputService.GamepadEnabled then
								GuiService:Select(selectedFloor[1].Parent)
							end
						end))					
					end

					maid:GiveTask(newfloorbtn.Activated:Connect(function()
						Shortcut:PlaySound("MouseClick")

						if not Unlocked then
							StartGame_btn.Visible = false
							VoteLabel.Visible = false
							SelectFloor(Name,currentFloor,FloorData)
						else
							StartGame_btn.Visible = true
							VoteLabel.Visible = true
							SelectFloor(Name,currentFloor,FloorData)
						end
					end))
				end
	
			end)
			
			-- FloorsCompleted:andThen(function(FloorData)
			-- 	warn("[ FLOORS ] -->> ", FloorData) -- , #FloorData
			-- 	if (FloorData == nil) or (FloorData and #FloorData <= 0) then
			-- 		player:Kick("You need to rejoin due to your data being incorrect")
			-- 	end
			
			-- 	self:ClearFloorFrame()
				
			-- 	for currentFloor = 1,#Floors_Folder:GetChildren() do
			-- 		local AmountValue = #FloorData
			-- 		local Name = "Floor"..currentFloor
			-- 		local temp = FloorDisplay.Temp
			-- 		local Unlocked = false

			-- 		local newfloorbtn = temp.Floorbtn:Clone()
			-- 		newfloorbtn.Nr.Text = currentFloor
			-- 		newfloorbtn.Parent = FloorDisplay
			-- 		newfloorbtn.Name = "Floor"..currentFloor
			-- 		newfloorbtn.Visible = true

			-- 		if currentFloor > (#FloorData) then
			-- 			newfloorbtn.BackgroundColor3 = Result["Locked"]
			-- 			newfloorbtn.UIStroke.Color = Result["Locked"]	
			-- 		else
			-- 			newfloorbtn.BackgroundColor3 = Result["Unlocked"]
			-- 			newfloorbtn.UIStroke.Color = Result["Unlocked"]
			-- 			Unlocked = true
			-- 		end

			-- 		if not Unlocked then
			-- 			maid:GiveTask(newfloorbtn.Activated:Connect(function()
			-- 				Shortcut:PlaySound("MouseClick")

			-- 				local selectedFloor = SelectFloor(Name)
			-- 				if UserInputService.GamepadEnabled then
			-- 					GuiService:Select(selectedFloor[1].Parent)
			-- 				end
			-- 			end))					
			-- 		end

			-- 		maid:GiveTask(newfloorbtn.Activated:Connect(function()
			-- 			Shortcut:PlaySound("MouseClick")

			-- 			if not Unlocked then
			-- 				StartGame_btn.Visible = false
			-- 				VoteLabel.Visible = false
			-- 				SelectFloor(Name,currentFloor,FloorData)
			-- 			else
			-- 				StartGame_btn.Visible = true
			-- 				VoteLabel.Visible = true
			-- 				SelectFloor(Name,currentFloor,FloorData)
			-- 			end
			-- 		end))
			-- 	end

			-- end)
		end)
		
		-- CountDown until it starts
		--cooldown(10)
	end)
end

function IntermissionController:KnitStart()
	local ChapterData = self:GetFloors()
	local MatchService = Knit.GetService("MatchService")
	-- Disables the Reset Button
	
	MatchService.Restart:Connect(function()
		maid:Destroy()
		self:StartInter(ChapterData)
	end)

	self:StartInter(ChapterData)
end

function IntermissionController:KnitInit()

end

return IntermissionController
