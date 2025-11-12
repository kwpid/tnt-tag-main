local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainGUI = playerGui:WaitForChild("MainGUI")
local roundTimerLabel = mainGUI:WaitForChild("RoundTimer")

local roundActive = false
local roundTimeRemaining = 0
local intermissionThread = nil

local function updateRoundTimer()
        if roundActive and roundTimeRemaining > 0 then
                roundTimerLabel.Text = "Round: " .. math.ceil(roundTimeRemaining) .. "s"
                roundTimerLabel.Visible = true
        else
                roundTimerLabel.Visible = false
        end
end

RemoteEvents.RoundStart.OnClientEvent:Connect(function(roundTime)
        print("[RoundUI] Round started! Time: " .. roundTime .. "s")
        
        if intermissionThread then
                task.cancel(intermissionThread)
                intermissionThread = nil
        end
        
        roundActive = true
        roundTimeRemaining = roundTime
        
        task.spawn(function()
                while roundActive and roundTimeRemaining > 0 do
                        updateRoundTimer()
                        task.wait(0.1)
                        roundTimeRemaining = roundTimeRemaining - 0.1
                end
                
                if roundActive then
                        updateRoundTimer()
                end
        end)
end)

RemoteEvents.RoundEnd.OnClientEvent:Connect(function()
        print("[RoundUI] Round ended!")
        roundActive = false
        roundTimeRemaining = 0
        roundTimerLabel.Text = "Intermission..."
        roundTimerLabel.Visible = true
        
        if intermissionThread then
                task.cancel(intermissionThread)
        end
        
        intermissionThread = task.spawn(function()
                task.wait(5)
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
                        roundTimerLabel.Text = "Game Starting in: " .. math.ceil(timeRemaining) .. "s"
                        task.wait(0.1)
                        timeRemaining = timeRemaining - 0.1
                end
                roundTimerLabel.Text = "Game Starting..."
                task.wait(0.5)
                if not roundActive then
                        roundTimerLabel.Visible = false
                end
                intermissionThread = nil
        end)
end)

roundTimerLabel.Visible = false

print("[RoundUI] Round UI initialized")
