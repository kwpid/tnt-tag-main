local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainGUI = playerGui:WaitForChild("MainGUI")
local roundTimerLabel = mainGUI:WaitForChild("RoundTimer")

local roundActive = false
local roundTimeRemaining = 0
local tntDelayRemaining = 0
local intermissionThread = nil

local function updateRoundTimer()
        if not roundActive then
                return
        end
        
        if tntDelayRemaining > 0 then
                roundTimerLabel.Text = "Round starts in: " .. math.floor(tntDelayRemaining + 0.99) .. "s"
                roundTimerLabel.Visible = true
        elseif roundTimeRemaining > 0 then
                roundTimerLabel.Text = "Round: " .. math.floor(roundTimeRemaining + 0.99) .. "s"
                roundTimerLabel.Visible = true
        else
                roundTimerLabel.Visible = false
        end
end

RemoteEvents.RoundStart.OnClientEvent:Connect(function(roundTime, tntDelay)
        print("[RoundUI] Round started! Time: " .. roundTime .. "s, TNT Delay: " .. (tntDelay or 0) .. "s")
        
        if intermissionThread then
                task.cancel(intermissionThread)
                intermissionThread = nil
        end
        
        roundActive = true
        roundTimeRemaining = roundTime
        tntDelayRemaining = tntDelay or 0
        
        task.spawn(function()
                while roundActive and tntDelayRemaining > 0 do
                        updateRoundTimer()
                        task.wait(0.1)
                        tntDelayRemaining = tntDelayRemaining - 0.1
                end
                
                tntDelayRemaining = 0
                
                while roundActive and roundTimeRemaining > 0 do
                        updateRoundTimer()
                        task.wait(0.1)
                        roundTimeRemaining = roundTimeRemaining - 0.1
                end
                
                if roundActive then
                        roundTimerLabel.Text = "Round: 0s"
                        roundTimerLabel.Visible = true
                        task.wait(0.5)
                        roundTimerLabel.Visible = false
                end
        end)
end)

RemoteEvents.RoundEnd.OnClientEvent:Connect(function(intermissionTime)
        print("[RoundUI] Round ended! Intermission: " .. (intermissionTime or 3) .. "s")
        roundActive = false
        roundTimeRemaining = 0
        tntDelayRemaining = 0
        
        local actualIntermissionTime = intermissionTime or 3
        local timeRemaining = actualIntermissionTime
        roundTimerLabel.Visible = true
        
        if intermissionThread then
                task.cancel(intermissionThread)
        end
        
        intermissionThread = task.spawn(function()
                while timeRemaining > 0 do
                        roundTimerLabel.Text = "Next round: " .. math.floor(timeRemaining + 0.99) .. "s"
                        task.wait(0.1)
                        timeRemaining = timeRemaining - 0.1
                end
                if not roundActive then
                        roundTimerLabel.Visible = false
                end
                intermissionThread = nil
        end)
end)

RemoteEvents.GameStartIntermission.OnClientEvent:Connect(function(intermissionTime)
        print("[RoundUI] Game starting intermission: " .. intermissionTime .. "s")
        
        if intermissionThread then
                task.cancel(intermissionThread)
                intermissionThread = nil
        end
        
        roundActive = false
        local timeRemaining = intermissionTime
        roundTimerLabel.Visible = true
        
        intermissionThread = task.spawn(function()
                while timeRemaining > 0 do
                        roundTimerLabel.Text = "Game Starting in: " .. math.floor(timeRemaining + 0.99) .. "s"
                        task.wait(0.1)
                        timeRemaining = timeRemaining - 0.1
                end
                roundTimerLabel.Text = "Game Starting..."
                task.wait(1)
                if not roundActive then
                        roundTimerLabel.Visible = false
                end
                intermissionThread = nil
        end)
end)

roundTimerLabel.Visible = false

print("[RoundUI] Round UI initialized")
