local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))
local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
local PlayerDataService = require(ReplicatedStorage:WaitForChild("PlayerDataService"))

print("[MatchResultReceiver] Listening for match results...")

RemoteEvents.MatchResultReceived.OnServerEvent:Connect(function(player, isWinner, kills, deaths, mode)
	print("[MatchResultReceiver] Processing result for " .. player.Name)
	
	if isWinner then
		PlayerDataManager:AddWin(player)
	else
		PlayerDataManager:AddLoss(player)
	end
	
	local matchData = PlayerDataService.CreateMatchData(
		mode or "Casual",
		isWinner and "Win" or "Loss",
		kills,
		deaths
	)
	
	PlayerDataManager:AddRecentMatch(player, matchData)
	PlayerDataManager:SavePlayerData(player)
	
	print("[MatchResultReceiver] Updated stats for " .. player.Name)
end)
