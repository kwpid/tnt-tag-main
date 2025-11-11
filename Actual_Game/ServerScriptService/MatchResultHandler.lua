local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

print("[MatchResultHandler] Listening for match results...")

RemoteEvents.MatchResultReceived.OnServerEvent:Connect(function(player, isWinner, kills, deaths)
	print("[MatchResultHandler] " .. player.Name .. " - Win: " .. tostring(isWinner) .. ", Deaths: " .. deaths)
	
	local xpGained = 0
	if isWinner then
		xpGained = 150
	else
		xpGained = 50
	end
	
	print("[MatchResultHandler] XP awarded: " .. xpGained)
end)
