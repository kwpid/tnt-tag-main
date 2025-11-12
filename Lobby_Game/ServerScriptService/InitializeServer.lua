print("=========================================")
print("   Lobby Game Server - Initializing")
print("=========================================")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))
local QueueService = require(ReplicatedStorage:WaitForChild("QueueService"))

print("[Server] Modules loaded successfully")

local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
local QueueManager = require(script.Parent:WaitForChild("QueueManager"))

print("[Server] Player Data Manager initialized")
print("[Server] Queue Manager initialized")

print("=========================================")
print("   Configuration Summary")
print("=========================================")
print("Sub-Place ID: " .. tostring(GameConfig.SubPlace.PlaceId))
print("Min Players: " .. tostring(GameConfig.Queue.MinPlayersPerMatch))
print("Max Players: " .. tostring(GameConfig.Queue.MaxPlayersPerMatch))
print("Debug Mode: " .. tostring(GameConfig.Debug.Enabled))
print("Test Mode: " .. tostring(GameConfig.Debug.TestMode))
print("=========================================")

if GameConfig.SubPlace.PlaceId == 0 then
        warn("⚠️ WARNING: Sub-place ID not configured!")
        warn("⚠️ Set GameConfig.SubPlace.PlaceId to your Actual_Game place ID")
        warn("⚠️ Players will not be able to teleport until this is set")
end

game.Players.PlayerAdded:Connect(function(player)
        local joinData = player:GetJoinData()
        local teleportData = joinData.TeleportData
        
        if teleportData and teleportData.isWinner ~= nil then
                print("[Server] " .. player.Name .. " returned from match with results")
                print("[Server] Win: " .. tostring(teleportData.isWinner) .. ", Deaths: " .. tostring(teleportData.deaths))
                
                task.wait(2)
                
                local success, err = pcall(function()
                        if teleportData.isWinner then
                                PlayerDataManager:AddWin(player)
                        else
                                PlayerDataManager:AddLoss(player)
                        end
                        
                        local PlayerDataService = require(ReplicatedStorage:WaitForChild("PlayerDataService"))
                        local matchData = PlayerDataService.CreateMatchData(
                                teleportData.mode or "Casual",
                                teleportData.isWinner and "Win" or "Loss",
                                teleportData.kills or 0,
                                teleportData.deaths or 0
                        )
                        
                        PlayerDataManager:AddRecentMatch(player, matchData)
                        PlayerDataManager:SavePlayerData(player)
                        
                        print("[Server] Updated stats for " .. player.Name)
                end)
                
                if not success then
                        warn("[Server] Failed to process match results for " .. player.Name .. ": " .. tostring(err))
                end
        end
end)

print("[Server] Initialization complete!")
print("=========================================")
