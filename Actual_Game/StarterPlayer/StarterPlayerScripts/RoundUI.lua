local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local player = Players.LocalPlayer

RemoteEvents.RoundStart.OnClientEvent:Connect(function(roundTime)
	print("[RoundUI] Round started! Time: " .. roundTime .. "s")
end)

RemoteEvents.RoundEnd.OnClientEvent:Connect(function()
	print("[RoundUI] Round ended!")
end)

print("[RoundUI] Round UI initialized")
