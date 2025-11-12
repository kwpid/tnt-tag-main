local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local datastoreName = GameConfig.DataStore.Name .. "_" .. GameConfig.DataStore.Version
local PlayerDataStore = DataStoreService:GetDataStore(datastoreName)
print("[PlayerData] Using DataStore: " .. datastoreName)

local PlayerDataManager = {}
PlayerDataManager.__index = PlayerDataManager

local DEFAULT_DATA = {
        Wins = 0,
        Losses = 0,
        WinStreak = 0,
        HighestWinStreak = 0,
        Level = 1,
        XP = 0,
        RankedElo = 1000,
        RecentMatches = {}
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
        
        print("[PlayerData] Initialized successfully!")
end

function PlayerDataManager:LoadPlayerData(player)
        local userId = player.UserId
        local success, data = pcall(function()
                return PlayerDataStore:GetAsync("Player_" .. userId)
        end)
        
        if success and data then
                print("[PlayerData] Loaded data for " .. player.Name)
                self:CreateLeaderstats(player, data)
        else
                print("[PlayerData] Using default data for " .. player.Name)
                self:CreateLeaderstats(player, self:GetDefaultData())
        end
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

function PlayerDataManager:CreateLeaderstats(player, data)
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

local playerDataManager = PlayerDataManager.new()

return playerDataManager
