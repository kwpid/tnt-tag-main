local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local TimeSync = require(ReplicatedStorage:WaitForChild("TimeSync"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainGUI = playerGui:WaitForChild("MainGUI")
local roundTimerLabel = mainGUI:WaitForChild("RoundTimer")

local roundActive = false
local roundEndTime = 0
local tntDelayEndTime = 0
local roundThread = nil
local intermissionThread = nil

RemoteEvents.RoundStart.OnClientEvent:Connect(function(serverExplosionTime, tntDelay)
        print("[RoundUI] Round started! Explosion at: " .. serverExplosionTime .. ", TNT Delay: " .. (tntDelay or 0) .. "s")
        
        TimeSync.WaitForSync()
        
        if intermissionThread then
                task.cancel(intermissionThread)
                intermissionThread = nil
        end
        
        if roundThread then
                task.cancel(roundThread)
        end
        
        roundActive = true
        local delayTime = tntDelay or 0
        local serverRoundEndTime = serverExplosionTime
        local serverTntDelayEndTime = serverExplosionTime - GameConfig.Game.RoundTime
        
        roundThread = task.spawn(function()
                while roundActive do
                        roundEndTime = TimeSync.ServerToClientTime(serverRoundEndTime)
                        tntDelayEndTime = TimeSync.ServerToClientTime(serverTntDelayEndTime)
                        
                        local currentTime = tick()
                        local timeLeft = math.max(0, roundEndTime - currentTime)
                        local delayLeft = math.max(0, tntDelayEndTime - currentTime)
                        
                        if delayLeft > 0 then
                                roundTimerLabel.Text = "Round starts in: " .. math.ceil(delayLeft) .. "s"
                                roundTimerLabel.Visible = true
                        elseif timeLeft > 0 then
                                roundTimerLabel.Text = "Round: " .. math.ceil(timeLeft) .. "s"
                                roundTimerLabel.Visible = true
                        else
                                roundTimerLabel.Text = "Round: 0s"
                                roundTimerLabel.Visible = true
                                task.wait(0.1)
                                roundTimerLabel.Visible = false
                                break
                        end
                        
                        task.wait(0.05)
                end
        end)
end)

RemoteEvents.RoundEnd.OnClientEvent:Connect(function(intermissionTime)
        print("[RoundUI] Round ended!")
        roundActive = false
        
        if roundThread then
                task.cancel(roundThread)
                roundThread = nil
        end
        
        if intermissionThread then
                task.cancel(intermissionThread)
                intermissionThread = nil
        end
        
        roundTimerLabel.Visible = false
end)

RemoteEvents.GameStartIntermission.OnClientEvent:Connect(function(serverIntermissionEndTime)
        print("[RoundUI] Game starting intermission, ends at: " .. serverIntermissionEndTime)
        
        TimeSync.WaitForSync()
        
        if intermissionThread then
                task.cancel(intermissionThread)
                intermissionThread = nil
        end
        
        roundActive = false
        roundTimerLabel.Visible = true
        
        intermissionThread = task.spawn(function()
                while true do
                        local clientEndTime = TimeSync.ServerToClientTime(serverIntermissionEndTime)
                        local currentTime = tick()
                        local timeLeft = math.max(0, clientEndTime - currentTime)
                        
                        if timeLeft > 0 then
                                roundTimerLabel.Text = "Game Starting in: " .. math.ceil(timeLeft) .. "s"
                        else
                                roundTimerLabel.Text = "Game Starting in: 0s"
                                task.wait(0.1)
                                roundTimerLabel.Text = "Game Starting..."
                                task.wait(0.5)
                                roundTimerLabel.Visible = false
                                intermissionThread = nil
                                break
                        end
                        
                        task.wait(0.05)
                end
        end)
end)

roundTimerLabel.Visible = false

print("[RoundUI] Round UI initialized")
