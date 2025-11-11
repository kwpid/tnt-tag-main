local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

print("[MatchResultClient] Listening for match results...")

RemoteEvents.MatchResult.OnClientEvent:Connect(function(isWinner, kills, deaths)
	print("[MatchResultClient] Match ended!")
	print("  Result: " .. (isWinner and "VICTORY" or "DEFEAT"))
	print("  K/D: " .. kills .. "/" .. deaths)
	
	RemoteEvents.MatchResultReceived:FireServer(isWinner, kills, deaths)
end)
