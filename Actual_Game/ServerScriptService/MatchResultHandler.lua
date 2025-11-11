local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

print("[MatchResultHandler] Listening for match results...")

RemoteEvents.MatchResultReceived.OnServerEvent:Connect(function(player, isWinner, kills, deaths)
	print("[MatchResultHandler] " .. player.Name .. " - Win: " .. tostring(isWinner) .. ", K/D: " .. kills .. "/" .. deaths)
end)
