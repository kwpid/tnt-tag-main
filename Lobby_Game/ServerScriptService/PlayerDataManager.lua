local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

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
                local defaultData = self:GetDefaultData()
                for key, value in pairs(defaultData) do
                        if data[key] == nil then
                                data[key] = value
                                print("[PlayerData] Added missing field '" .. key .. "' for " .. player.Name)
                        end
                end
                activePlayerData[userId] = data
                print("[PlayerData] Loaded data for " .. player.Name)
        else
                activePlayerData[userId] = self:GetDefaultData()
                print("[PlayerData] Created new data for " .. player.Name)
        end
        
        self:CreateLeaderstats(player)
        
        task.spawn(function()
                task.wait(0.5)
                
                local joinData = player:GetJoinData()
                if joinData and joinData.TeleportData then
                        print("[PlayerData] Found TeleportData for " .. player.Name)
                        self:ProcessMatchResult(player, joinData.TeleportData)
                end
        end)
end

function PlayerDataManager:ProcessMatchResult(player, matchData)
        if type(matchData) ~= "table" then
                print("[PlayerData] Invalid matchData type for " .. player.Name)
                return
        end
        
        if matchData.isWinner == nil then
                print("[PlayerData] No winner data in matchData for " .. player.Name)
                return
        end
        
        if matchData.alreadyProcessed then
                print("[PlayerData] Match already processed in sub-place for " .. player.Name .. ", skipping duplicate application")
                local data = self:GetPlayerData(player)
                if data then
                        print("[PlayerData] Current stats - Wins: " .. data.Wins .. ", Level: " .. data.Level .. ", XP: " .. data.XP)
                end
                return
        end
        
        local data = self:GetPlayerData(player)
        if not data then
                warn("[PlayerData] ERROR: No player data found when processing match result for " .. player.Name)
                return
        end
        
        if matchData.matchId and data.LastMatchId == matchData.matchId then
                print("[PlayerData] Match ID " .. matchData.matchId .. " already processed for " .. player.Name .. ", skipping")
                return
        end
        
        print("[PlayerData] Processing match result for " .. player.Name .. ": " .. (matchData.isWinner and "WIN" or "LOSS"))
        print("[PlayerData] Current stats - Wins: " .. data.Wins .. ", Level: " .. data.Level .. ", XP: " .. data.XP)
        
        local oldLevel = data.Level
        local oldXP = data.XP
        local xpGains = {}
        
        if matchData.isWinner then
                self:AddWin(player, xpGains)
        else
                self:AddLoss(player, xpGains)
        end
        
        local kills = matchData.kills or 0
        if kills > 0 then
                local killXP = kills * GameConfig.Rewards.KillXP
                table.insert(xpGains, {amount = killXP, reason = kills .. " Kills"})
                self:AddXP(player, killXP)
        end
        
        if matchData.matchId then
                data.LastMatchId = matchData.matchId
                data.LastSaveTimestamp = os.time()
                activePlayerData[player.UserId] = data
        end
        
        local updatedData = self:GetPlayerData(player)
        print("[PlayerData] Updated stats - Wins: " .. updatedData.Wins .. ", Level: " .. updatedData.Level .. ", XP: " .. updatedData.XP)
        
        local mode = matchData.mode or "Casual"
        local recentMatchData = {
                Mode = mode,
                Result = matchData.isWinner and "Win" or "Loss",
                Kills = matchData.kills or 0,
                Deaths = matchData.deaths or 0,
                Timestamp = os.time()
        }
        
        self:AddRecentMatch(player, recentMatchData)
        self:SavePlayerData(player, false)
        
        local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))
        RemoteEvents.ShowLevelUp:FireClient(player, {
                oldLevel = oldLevel,
                newLevel = updatedData.Level,
                oldXP = oldXP,
                newXP = updatedData.XP,
                xpGains = xpGains
        })
        
        print("[PlayerData] Match result processed and saved for " .. player.Name)
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
                        
                        local newTimestamp = data.LastSaveTimestamp or 0
                        local oldTimestamp = oldData.LastSaveTimestamp or 0
                        
                        if newTimestamp >= oldTimestamp then
                                print("[PlayerData] Accepting data snapshot for " .. player.Name .. " (timestamp: " .. newTimestamp .. ")")
                                return data
                        end
                        
                        print("[PlayerData] Merging older lobby data for " .. player.Name)
                        for key, value in pairs(data) do
                                if typeof(oldData[key]) == "number" and typeof(value) == "number" then
                                        if value > oldData[key] then
                                                oldData[key] = value
                                        end
                                else
                                        oldData[key] = value
                                end
                        end
                        
                        return oldData
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

function PlayerDataManager:AddWin(player, xpGains)
        local data = self:GetPlayerData(player)
        if not data then return end
        
        data.Wins = data.Wins + 1
        data.WinStreak = data.WinStreak + 1
        
        if data.WinStreak > data.HighestWinStreak then
                data.HighestWinStreak = data.WinStreak
        end
        
        data.LastSaveTimestamp = os.time()
        
        if xpGains then
                table.insert(xpGains, {amount = GameConfig.Rewards.WinXP, reason = "Game Win"})
        end
        self:AddXP(player, GameConfig.Rewards.WinXP)
        self:UpdateLeaderstats(player)
        
        print("[PlayerData] " .. player.Name .. " won! Win streak: " .. data.WinStreak)
end

function PlayerDataManager:AddLoss(player, xpGains)
        local data = self:GetPlayerData(player)
        if not data then return end
        
        data.Losses = data.Losses + 1
        data.WinStreak = 0
        
        data.LastSaveTimestamp = os.time()
        
        if xpGains then
                table.insert(xpGains, {amount = GameConfig.Rewards.LossXP, reason = "Game Participation"})
        end
        self:AddXP(player, GameConfig.Rewards.LossXP)
        self:UpdateLeaderstats(player)
        
        print("[PlayerData] " .. player.Name .. " lost. Win streak reset.")
end

function PlayerDataManager:AddXP(player, amount)
        local data = self:GetPlayerData(player)
        if not data then return end
        
        data.XP = data.XP + amount
        
        local xpNeeded = self:GetXPForLevel(data.Level)
        while data.XP >= xpNeeded do
                data.XP = data.XP - xpNeeded
                data.Level = data.Level + 1
                xpNeeded = self:GetXPForLevel(data.Level)
                print("[PlayerData] " .. player.Name .. " leveled up to level " .. data.Level .. "!")
        end
        
        self:UpdateLeaderstats(player)
end

function PlayerDataManager:GetXPForLevel(level)
        return 100 + (level * 50)
end

function PlayerDataManager:UpdateRankedElo(player, eloChange)
        local data = self:GetPlayerData(player)
        if not data then return end
        
        data.RankedElo = math.max(0, data.RankedElo + eloChange)
        print("[PlayerData] " .. player.Name .. " ELO: " .. data.RankedElo .. " (" .. (eloChange >= 0 and "+" or "") .. eloChange .. ")")
end

function PlayerDataManager:AddRecentMatch(player, matchData)
        local data = self:GetPlayerData(player)
        if not data then return end
        
        table.insert(data.RecentMatches, 1, matchData)
        
        if #data.RecentMatches > 10 then
                table.remove(data.RecentMatches, #data.RecentMatches)
        end
end

local playerDataManager = PlayerDataManager.new()

return playerDataManager
