local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainGUI = playerGui:WaitForChild("MainGUI")
local roundTimerLabel = mainGUI:WaitForChild("RoundTimer")

local roundActive = false
local roundTimeRemaining = 0

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
	roundActive = true
	roundTimeRemaining = roundTime
	
	task.spawn(function()
		while roundActive and roundTimeRemaining > 0 do
			updateRoundTimer()
			task.wait(0.1)
			roundTimeRemaining = roundTimeRemaining - 0.1
		end
		updateRoundTimer()
	end)
end)

RemoteEvents.RoundEnd.OnClientEvent:Connect(function()
	print("[RoundUI] Round ended!")
	roundActive = false
	roundTimeRemaining = 0
	roundTimerLabel.Text = "Intermission..."
	roundTimerLabel.Visible = true
	
	task.wait(5)
	roundTimerLabel.Visible = false
end)

roundTimerLabel.Visible = false

print("[RoundUI] Round UI initialized")
