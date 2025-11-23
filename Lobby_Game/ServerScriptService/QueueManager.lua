local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local QueueService = require(ReplicatedStorage:WaitForChild("QueueService"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local QueueManager = {}
QueueManager.__index = QueueManager

local activeQueues = {Casual = {}, Ranked = {}}
local playerStates = {}

function QueueManager.new()
        local self = setmetatable({}, QueueManager)
        self:Initialize()
        return self
end

function QueueManager:Initialize()
        print("[QueueManager] Initializing...")
        
        RemoteEvents.QueueJoin.OnServerEvent:Connect(function(player, mode, region)
                self:AddPlayerToQueue(player, mode, region)
        end)
        
        RemoteEvents.QueueLeave.OnServerEvent:Connect(function(player)
                self:RemovePlayerFromQueue(player)
        end)
        
        RemoteEvents.GetQueueStatus.OnServerInvoke = function(player)
                return self:GetPlayerStatus(player)
        end
        
        task.spawn(function()
                self:MatchmakingLoop()
        end)
        
        Players.PlayerRemoving:Connect(function(player)
                self:RemovePlayerFromQueue(player)
        end)
        
        TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
                warn("[QueueManager] Teleport failed for " .. player.Name .. ": " .. tostring(errorMessage) .. " (" .. tostring(teleportResult) .. ")")
                
                if playerStates[player.UserId] then
                        playerStates[player.UserId] = {
                                status = QueueService.QueueStatus.NotQueued,
                                queueData = nil
                        }
                        RemoteEvents.QueueStatusUpdate:FireClient(player, QueueService.QueueStatus.NotQueued)
                end
        end)
        
        print("[QueueManager] Initialized successfully!")
end

function QueueManager:AddPlayerToQueue(player, mode, region)
        local userId = player.UserId
        
        if playerStates[userId] and playerStates[userId].status ~= QueueService.QueueStatus.NotQueued then
                warn("[QueueManager] Player " .. player.Name .. " is already in queue")
                return
        end
        
        if not GameConfig.GameModes[mode] or not GameConfig.GameModes[mode].Enabled then
                warn("[QueueManager] Invalid or disabled mode: " .. tostring(mode))
                return
        end
        
        if region == "Auto" then
                region = self:DetectPlayerRegion(player)
        end
        
        local queueData = QueueService.CreateQueueData(player, mode, region)
        
        if not activeQueues[mode][region] then
                activeQueues[mode][region] = {}
        end
        table.insert(activeQueues[mode][region], queueData)
        
        playerStates[userId] = {
                status = QueueService.QueueStatus.Queuing,
                queueData = queueData
        }
        
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
        
        if activeQueues[mode] and activeQueues[mode][region] then
                for i, data in ipairs(activeQueues[mode][region]) do
                        if data.UserId == userId then
                                table.remove(activeQueues[mode][region], i)
                                break
                        end
                end
        end
        
        playerStates[userId] = {
                status = QueueService.QueueStatus.NotQueued,
                queueData = nil
        }
        
        if player.Parent then
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
                
                for mode, regions in pairs(activeQueues) do
                        for region, queue in pairs(regions) do
                                if #queue >= GameConfig.GameModes[mode].MinPlayers then
                                        self:TryCreateMatch(mode, region, queue)
                                end
                        end
                end
                
                self:CheckExpiredQueues()
        end
end

function QueueManager:TryCreateMatch(mode, region, queue)
        local maxPlayers = GameConfig.GameModes[mode].MaxPlayers
        local minPlayers = GameConfig.GameModes[mode].MinPlayers
        
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
        
        for _, queueData in ipairs(queueDataList) do
                local player = queueData.Player
                if player and player.Parent then
                        table.insert(players, player)
                        table.insert(playerIds, player.UserId)
                        
                        if activeQueues[mode] and activeQueues[mode][region] then
                                for i, data in ipairs(activeQueues[mode][region]) do
                                        if data.UserId == player.UserId then
                                                table.remove(activeQueues[mode][region], i)
                                                break
                                        end
                                end
                        end
                        
                        playerStates[player.UserId].status = QueueService.QueueStatus.MatchFound
                        RemoteEvents.MatchFound:FireClient(player)
                        RemoteEvents.QueueStatusUpdate:FireClient(player, QueueService.QueueStatus.MatchFound)
                end
        end
        
        if #players > 0 then
                self:TeleportPlayers(players, mode, region)
        end
end

function QueueManager:TeleportPlayers(players, mode, region)
        if GameConfig.Debug.TestMode then
                print("[QueueManager] TEST MODE - Skipping teleportation")
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
        
        for _, player in ipairs(players) do
                playerStates[player.UserId].status = QueueService.QueueStatus.Teleporting
                RemoteEvents.QueueStatusUpdate:FireClient(player, QueueService.QueueStatus.Teleporting)
        end
        
        local teleportOptions = Instance.new("TeleportOptions")
        teleportOptions:SetTeleportData({
                Mode = mode,
                Region = region,
                Timestamp = os.time()
        })
        
        local success, errorMessage = pcall(function()
                TeleportService:TeleportAsync(placeId, players, teleportOptions)
        end)
        
        if success then
                print("[QueueManager] Successfully teleported " .. #players .. " players in batch")
                for _, player in ipairs(players) do
                        if playerStates[player.UserId] then
                                playerStates[player.UserId] = nil
                        end
                end
        else
                warn("[QueueManager] Batch teleport failed: " .. tostring(errorMessage) .. " - Retrying individually...")
                task.wait(0.5)
                self:TeleportPlayersIndividually(players, mode, region, placeId)
        end
end

function QueueManager:TeleportPlayersIndividually(players, mode, region, placeId)
        for _, player in ipairs(players) do
                if player and player.Parent and playerStates[player.UserId] then
                        local teleportOptions = Instance.new("TeleportOptions")
                        teleportOptions:SetTeleportData({
                                Mode = mode,
                                Region = region,
                                Timestamp = os.time()
                        })
                        
                        local maxRetries = 3
                        local teleported = false
                        
                        for attempt = 1, maxRetries do
                                local success, errorMessage = pcall(function()
                                        TeleportService:TeleportAsync(placeId, {player}, teleportOptions)
                                end)
                                
                                if success then
                                        print("[QueueManager] Successfully teleported " .. player.Name .. " (attempt " .. attempt .. ")")
                                        if playerStates[player.UserId] then
                                                playerStates[player.UserId] = nil
                                        end
                                        teleported = true
                                        break
                                else
                                        warn("[QueueManager] Failed to teleport " .. player.Name .. " (attempt " .. attempt .. "): " .. tostring(errorMessage))
                                        if attempt < maxRetries then
                                                task.wait(1)
                                        end
                                end
                        end
                        
                        if not teleported then
                                warn("[QueueManager] All teleport attempts failed for " .. player.Name .. " - Resetting to queue")
                                if player.Parent and playerStates[player.UserId] then
                                        playerStates[player.UserId] = {
                                                status = QueueService.QueueStatus.NotQueued,
                                                queueData = nil
                                        }
                                        RemoteEvents.QueueStatusUpdate:FireClient(player, QueueService.QueueStatus.NotQueued)
                                end
                        end
                elseif player and playerStates[player.UserId] then
                        warn("[QueueManager] Player " .. player.Name .. " already teleported or disconnected, skipping")
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

local queueManager = QueueManager.new()

return queueManager
