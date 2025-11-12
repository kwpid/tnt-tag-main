local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainGUI = playerGui:WaitForChild("MainGUI")
local roundTimerLabel = mainGUI:WaitForChild("RoundTimer")

local roundActive = false
local roundEndTime = 0
local tntDelayEndTime = 0
local roundThread = nil
local intermissionThread = nil

RemoteEvents.RoundStart.OnClientEvent:Connect(function(roundTime, tntDelay, serverExplosionTime)
        print("[RoundUI] Round started! Time: " .. roundTime .. "s, TNT Delay: " .. (tntDelay or 0) .. "s")
        
        if intermissionThread then
                task.cancel(intermissionThread)
                intermissionThread = nil
        end
        
        if roundThread then
                task.cancel(roundThread)
        end
        
        roundActive = true
        local currentTime = tick()
        local delayTime = tntDelay or 0
        local serverRoundStartTime = serverExplosionTime - delayTime - roundTime
        local elapsed = currentTime - serverRoundStartTime
        
        local remainingDelay = math.max(0, delayTime - elapsed)
        local remainingRound = math.max(0, delayTime + roundTime - elapsed)
        
        tntDelayEndTime = currentTime + remainingDelay
        roundEndTime = currentTime + remainingRound
        
        roundThread = task.spawn(function()
                while roundActive do
                        local timeLeft = math.max(0, roundEndTime - tick())
                        local delayLeft = math.max(0, tntDelayEndTime - tick())
                        
                        if delayLeft > 1 then
                                roundTimerLabel.Text = "Round starts in: " .. math.ceil(delayLeft) .. "s"
                                roundTimerLabel.Visible = true
                        elseif timeLeft > 5 then
                                roundTimerLabel.Text = "Round: " .. math.ceil(timeLeft) .. "s"
                                roundTimerLabel.Visible = true
                        elseif timeLeft > 0.5 then
                                roundTimerLabel.Text = "Round ending soon..."
                                roundTimerLabel.Visible = true
                        else
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

RemoteEvents.GameStartIntermission.OnClientEvent:Connect(function(intermissionTime)
        print("[RoundUI] Game starting intermission: " .. intermissionTime .. "s")
        
        if intermissionThread then
                task.cancel(intermissionThread)
                intermissionThread = nil
        end
        
        roundActive = false
        local endTime = tick() + intermissionTime
        roundTimerLabel.Visible = true
        
        intermissionThread = task.spawn(function()
                while tick() < endTime - 0.1 do
                        local timeLeft = endTime - tick()
                        roundTimerLabel.Text = "Game Starting in: " .. math.ceil(timeLeft) .. "s"
                        task.wait(0.05)
                end
                roundTimerLabel.Text = "Game Starting..."
                task.wait(0.5)
                roundTimerLabel.Visible = false
                intermissionThread = nil
        end)
end)

roundTimerLabel.Visible = false

print("[RoundUI] Round UI initialized")
