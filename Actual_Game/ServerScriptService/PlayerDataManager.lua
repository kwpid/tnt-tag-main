local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local PlayerDataService = require(ReplicatedStorage:WaitForChild("PlayerDataService"))

local datastoreName = GameConfig.DataStore.Name .. "_" .. GameConfig.DataStore.Version
local PlayerDataStore = DataStoreService:GetDataStore(datastoreName)
print("[PlayerData] Using DataStore: " .. datastoreName)

local PlayerDataManager = {}
PlayerDataManager.__index = PlayerDataManager

local activePlayerData = {}

local DEFAULT_DATA = {
        Wins = 0,
        Losses = 0,
        WinStreak = 0,
        HighestWinStreak = 0,
        Level = 1,
        XP = 0,
        RankedElo = 1000,
        TotalMatches = 0,
        MatchHistory = {},
        RecentMatches = {},
        LastMatchId = nil,
        LastSaveTimestamp = 0
}

function PlayerDataManager.new()
        local self = setmetatable({}, PlayerDataManager)
        self:Initialize()
        return self
end

function PlayerDataManager:Initialize()
        print("[PlayerData] Initializing...")
        
        Players.PlayerAdded:Connect(function(player)
                self:LoadPlayerData(player)
        end)
        
        Players.PlayerRemoving:Connect(function(player)
                self:SavePlayerData(player, true)
        end)
        
        game:BindToClose(function()
                for _, player in ipairs(Players:GetPlayers()) do
                        self:SavePlayerData(player, true)
                end
        end)
        
        print("[PlayerData] Initialized successfully!")
end

function PlayerDataManager:LoadPlayerData(player)
        local userId = player.UserId
        local success, data = pcall(function()
                return PlayerDataStore:GetAsync("Player_" .. userId)
        end)
        
        if success and data then
                activePlayerData[userId] = data
                print("[PlayerData] Loaded data for " .. player.Name)
        else
                activePlayerData[userId] = self:GetDefaultData()
                print("[PlayerData] Created new data for " .. player.Name)
        end
        
        self:CreateLeaderstats(player)
end

function PlayerDataManager:SavePlayerData(player, clearFromMemory)
        local userId = player.UserId
        local data = activePlayerData[userId]
        
        if not data then return false end
        
        local success, err = pcall(function()
                PlayerDataStore:UpdateAsync("Player_" .. userId, function(oldData)
                        if not oldData then
                                return data
                        end
                        
                        if data.LastMatchId and oldData.LastMatchId == data.LastMatchId then
                                print("[PlayerData] Skipping duplicate match save for " .. player.Name)
                                return oldData
                        end
                        
                        return data
                end)
        end)
        
        if success then
                print("[PlayerData] Saved data for " .. player.Name)
        else
                warn("[PlayerData] Failed to save data for " .. player.Name .. ": " .. tostring(err))
        end
        
        if clearFromMemory then
                activePlayerData[userId] = nil
                print("[PlayerData] Cleared from memory: " .. player.Name)
        end
        
        return success
end

function PlayerDataManager:GetDefaultData()
        local data = {}
        for key, value in pairs(DEFAULT_DATA) do
                if typeof(value) == "table" then
                        data[key] = {}
                else
                        data[key] = value
                end
        end
        return data
end

function PlayerDataManager:GetPlayerData(player)
        return activePlayerData[player.UserId]
end

function PlayerDataManager:CreateLeaderstats(player)
        local data = self:GetPlayerData(player)
        if not data then return end
        
        local leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
        
        local wins = Instance.new("IntValue")
        wins.Name = "Wins"
        wins.Value = data.Wins
        wins.Parent = leaderstats
        
        local level = Instance.new("IntValue")
        level.Name = "Level"
        level.Value = data.Level
        level.Parent = leaderstats
        
        local winStreak = Instance.new("IntValue")
        winStreak.Name = "Win Streak"
        winStreak.Value = data.WinStreak
        winStreak.Parent = leaderstats
end

function PlayerDataManager:UpdateLeaderstats(player)
        local data = self:GetPlayerData(player)
        if not data then return end
        
        local leaderstats = player:FindFirstChild("leaderstats")
        if not leaderstats then return end
        
        local wins = leaderstats:FindFirstChild("Wins")
        if wins then wins.Value = data.Wins end
        
        local level = leaderstats:FindFirstChild("Level")
        if level then level.Value = data.Level end
        
        local winStreak = leaderstats:FindFirstChild("Win Streak")
        if winStreak then winStreak.Value = data.WinStreak end
end

function PlayerDataManager:RecordMatchResult(player, isWin, deaths)
        local data = self:GetPlayerData(player)
        if not data then
                warn("[PlayerData] No data found for " .. player.Name)
                return nil, false
        end
        
        local timestamp = os.time()
        local matchId = tostring(timestamp) .. "_" .. tostring(player.UserId) .. "_" .. tostring(math.random(1000, 9999))
        
        print("[PlayerData] Recording match result for " .. player.Name .. ": " .. (isWin and "WIN" or "LOSS"))
        print("[PlayerData] Match ID: " .. matchId)
        print("[PlayerData] Before - Wins: " .. data.Wins .. ", Level: " .. data.Level .. ", XP: " .. data.XP)
        
        data = PlayerDataService.RecordMatch(data, isWin, deaths)
        
        local xpGained = isWin and GameConfig.Rewards.WinXP or GameConfig.Rewards.LossXP
        data = PlayerDataService.AddXP(data, xpGained)
        
        data.LastMatchId = matchId
        data.LastSaveTimestamp = timestamp
        
        activePlayerData[player.UserId] = data
        
        print("[PlayerData] After - Wins: " .. data.Wins .. ", Level: " .. data.Level .. ", XP: " .. data.XP)
        
        self:UpdateLeaderstats(player)
        local saveSuccess = self:SavePlayerData(player, false)
        
        if saveSuccess then
                print("[PlayerData] Match result saved successfully for " .. player.Name)
        else
                warn("[PlayerData] Failed to save match result for " .. player.Name)
        end
        
        return matchId, saveSuccess
end

local playerDataManager = PlayerDataManager.new()

return playerDataManager
