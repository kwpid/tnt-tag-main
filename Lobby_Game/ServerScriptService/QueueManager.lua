--[[
        QueueManager.lua
        Server-side matchmaking and queue management system
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

-- Load modules
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local QueueService = require(ReplicatedStorage:WaitForChild("QueueService"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local QueueManager = {}
QueueManager.__index = QueueManager

-- Active queues organized by mode and region
local activeQueues = {
        Casual = {},
        Ranked = {}
}

-- Player states
local playerStates = {} -- {[UserId] = {status, queueData}}

function QueueManager.new()
        local self = setmetatable({}, QueueManager)
        self:Initialize()
        return self
end

function QueueManager:Initialize()
        print("[QueueManager] Initializing...")
        
        -- Set up remote event handlers
        RemoteEvents.QueueJoin.OnServerEvent:Connect(function(player, mode, region)
                self:AddPlayerToQueue(player, mode, region)
        end)
        
        RemoteEvents.QueueLeave.OnServerEvent:Connect(function(player)
                self:RemovePlayerFromQueue(player)
        end)
        
        RemoteEvents.GetQueueStatus.OnServerInvoke = function(player)
                return self:GetPlayerStatus(player)
        end
        
        -- Start matchmaking loop
        task.spawn(function()
                self:MatchmakingLoop()
        end)
        
        -- Handle player leaving
        Players.PlayerRemoving:Connect(function(player)
                self:RemovePlayerFromQueue(player)
        end)
        
        print("[QueueManager] Initialized successfully!")
end

function QueueManager:AddPlayerToQueue(player, mode, region)
        local userId = player.UserId
        
        -- Check if already in queue
        if playerStates[userId] and playerStates[userId].status ~= QueueService.QueueStatus.NotQueued then
                warn("[QueueManager] Player " .. player.Name .. " is already in queue")
                return
        end
        
        -- Validate mode
        if not GameConfig.GameModes[mode] or not GameConfig.GameModes[mode].Enabled then
                warn("[QueueManager] Invalid or disabled mode: " .. tostring(mode))
                return
        end
        
        -- Auto-detect region if needed
        if region == "Auto" then
                region = self:DetectPlayerRegion(player)
        end
        
        -- Create queue data
        local queueData = QueueService.CreateQueueData(player, mode, region)
        
        -- Add to queue
        if not activeQueues[mode][region] then
                activeQueues[mode][region] = {}
        end
        table.insert(activeQueues[mode][region], queueData)
        
        -- Update player state
        playerStates[userId] = {
                status = QueueService.QueueStatus.Queuing,
                queueData = queueData
        }
        
        -- Notify player
        RemoteEvents.QueueStatusUpdate:FireClient(player, QueueService.QueueStatus.Queuing)
        
        if GameConfig.Debug.PrintQueueStatus then
                print(string.format("[QueueManager] %s joined %s queue in %s region", 
                        player.Name, mode, region))
                self:PrintQueueStats()
        end
end

function QueueManager:RemovePlayerFromQueue(player)
        local userId = player.UserId
        local state = playerStates[userId]
        
        if not state or not state.queueData then
                return
        end
        
        local mode = state.queueData.Mode
        local region = state.queueData.Region
        
        -- Remove from queue
        if activeQueues[mode] and activeQueues[mode][region] then
                for i, data in ipairs(activeQueues[mode][region]) do
                        if data.UserId == userId then
                                table.remove(activeQueues[mode][region], i)
                                break
                        end
                end
        end
        
        -- Update player state
        playerStates[userId] = {
                status = QueueService.QueueStatus.NotQueued,
                queueData = nil
        }
        
        -- Notify player
        if player.Parent then -- Check if player still in game
                RemoteEvents.QueueStatusUpdate:FireClient(player, QueueService.QueueStatus.NotQueued)
        end
        
        if GameConfig.Debug.PrintQueueStatus then
                print(string.format("[QueueManager] %s left queue", player.Name))
        end
end

function QueueManager:GetPlayerStatus(player)
        local userId = player.UserId
        local state = playerStates[userId]
        
        if not state then
                return QueueService.QueueStatus.NotQueued
        end
        
        return state.status
end

function QueueManager:MatchmakingLoop()
        while true do
                task.wait(GameConfig.Queue.MatchmakingInterval)
                
                -- Check each mode and region for potential matches
                for mode, regions in pairs(activeQueues) do
                        for region, queue in pairs(regions) do
                                if #queue >= GameConfig.GameModes[mode].MinPlayers then
                                        self:TryCreateMatch(mode, region, queue)
                                end
                        end
                end
                
                -- Check for expired queues (force match if waited too long)
                self:CheckExpiredQueues()
        end
end

function QueueManager:TryCreateMatch(mode, region, queue)
        local maxPlayers = GameConfig.GameModes[mode].MaxPlayers
        local minPlayers = GameConfig.GameModes[mode].MinPlayers
        
        -- Get players for match
        local playersForMatch = {}
        for i = 1, math.min(#queue, maxPlayers) do
                table.insert(playersForMatch, queue[i])
        end
        
        if #playersForMatch >= minPlayers then
                self:CreateMatch(playersForMatch, mode, region)
        end
end

function QueueManager:CreateMatch(queueDataList, mode, region)
        if GameConfig.Debug.PrintMatchmaking then
                print(string.format("[QueueManager] Creating %s match in %s with %d players", 
                        mode, region, #queueDataList))
        end
        
        local players = {}
        local playerIds = {}
        
        -- Collect players and update their states
        for _, queueData in ipairs(queueDataList) do
                local player = queueData.Player
                if player and player.Parent then
                        table.insert(players, player)
                        table.insert(playerIds, player.UserId)
                        
                        -- Remove from active queue (without changing player state)
                        if activeQueues[mode] and activeQueues[mode][region] then
                                for i, data in ipairs(activeQueues[mode][region]) do
                                        if data.UserId == player.UserId then
                                                table.remove(activeQueues[mode][region], i)
                                                break
                                        end
                                end
                        end
                        
                        -- Update state to MatchFound
                        playerStates[player.UserId].status = QueueService.QueueStatus.MatchFound
                        
                        -- Notify player
                        RemoteEvents.MatchFound:FireClient(player)
                        RemoteEvents.QueueStatusUpdate:FireClient(player, QueueService.QueueStatus.MatchFound)
                end
        end
        
        -- Teleport players
        if #players > 0 then
                self:TeleportPlayers(players, mode, region)
        end
end

function QueueManager:TeleportPlayers(players, mode, region)
        if GameConfig.Debug.TestMode then
                print("[QueueManager] TEST MODE - Skipping teleportation")
                -- In test mode, reset player states after a delay
                task.delay(3, function()
                        for _, player in ipairs(players) do
                                if player.Parent then
                                        playerStates[player.UserId] = {
                                                status = QueueService.QueueStatus.NotQueued,
                                                queueData = nil
                                        }
                                        RemoteEvents.QueueStatusUpdate:FireClient(player, QueueService.QueueStatus.NotQueued)
                                        print("[QueueManager] TEST MODE - Reset " .. player.Name .. " to NotQueued")
                                end
                        end
                end)
                return
        end
        
        local placeId = GameConfig.SubPlace.PlaceId
        
        if placeId == 0 then
                warn("[QueueManager] Sub-place ID not configured! Cannot teleport players.")
                return
        end
        
        -- Create teleport options
        local teleportOptions = Instance.new("TeleportOptions")
        teleportOptions:SetTeleportData({
                Mode = mode,
                Region = region,
                Timestamp = os.time()
        })
        
        -- Update player states
        for _, player in ipairs(players) do
                playerStates[player.UserId].status = QueueService.QueueStatus.Teleporting
                RemoteEvents.QueueStatusUpdate:FireClient(player, QueueService.QueueStatus.Teleporting)
        end
        
        -- Teleport
        local success, errorMessage = pcall(function()
                TeleportService:TeleportAsync(placeId, players, teleportOptions)
        end)
        
        if not success then
                warn("[QueueManager] Teleport failed: " .. tostring(errorMessage))
                
                -- Reset player states on failure
                for _, player in ipairs(players) do
                        if player.Parent then
                                playerStates[player.UserId] = {
                                        status = QueueService.QueueStatus.NotQueued,
                                        queueData = nil
                                }
                                RemoteEvents.QueueStatusUpdate:FireClient(player, QueueService.QueueStatus.NotQueued)
                        end
                end
        else
                print("[QueueManager] Successfully teleported " .. #players .. " players")
                -- Clean up player states (they're leaving the server)
                for _, player in ipairs(players) do
                        playerStates[player.UserId] = nil
                end
        end
end

function QueueManager:CheckExpiredQueues()
        local currentTime = os.time()
        
        for mode, regions in pairs(activeQueues) do
                for region, queue in pairs(regions) do
                        for i = #queue, 1, -1 do
                                local queueData = queue[i]
                                local timeInQueue = currentTime - queueData.JoinedAt
                                
                                if timeInQueue >= GameConfig.Queue.MaxQueueTime then
                                        -- Force match with whoever is available
                                        local playersInRegion = {}
                                        for _, data in ipairs(queue) do
                                                table.insert(playersInRegion, data)
                                        end
                                        
                                        if #playersInRegion >= GameConfig.GameModes[mode].MinPlayers then
                                                print("[QueueManager] Forcing match due to queue timeout")
                                                self:CreateMatch(playersInRegion, mode, region)
                                                break
                                        end
                                end
                        end
                end
        end
end

function QueueManager:DetectPlayerRegion(player)
        -- Simple region detection (can be improved with actual ping testing)
        -- For now, return a default region
        return "NA-East"
end

function QueueManager:PrintQueueStats()
        print("=== Queue Statistics ===")
        for mode, regions in pairs(activeQueues) do
                local totalInMode = 0
                for region, queue in pairs(regions) do
                        totalInMode = totalInMode + #queue
                        if #queue > 0 then
                                print(string.format("  %s - %s: %d players", mode, region, #queue))
                        end
                end
                if totalInMode > 0 then
                        print(string.format("  Total in %s: %d", mode, totalInMode))
                end
        end
        print("========================")
end

-- Initialize the queue manager
local queueManager = QueueManager.new()

return queueManager
