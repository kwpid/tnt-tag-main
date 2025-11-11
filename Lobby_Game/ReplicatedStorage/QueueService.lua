local QueueService = {}

QueueService.QueueStatus = {
	NotQueued = "NotQueued",
	Queuing = "Queuing",
	MatchFound = "MatchFound",
	Teleporting = "Teleporting"
}

QueueService.QueueMode = {
	Casual = "Casual",
	Ranked = "Ranked"
}

function QueueService.CreateQueueData(player, mode, region)
	return {
		Player = player,
		UserId = player.UserId,
		Username = player.Name,
		Mode = mode,
		Region = region,
		JoinedAt = os.time(),
		MMR = 1000,
	}
end

return QueueService
