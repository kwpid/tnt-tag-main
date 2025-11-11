--[[
	QueueService.lua
	Shared module for queue-related functions and enums
]]

local QueueService = {}

-- Queue Status Enum
QueueService.QueueStatus = {
	NotQueued = "NotQueued",
	Queuing = "Queuing",
	MatchFound = "MatchFound",
	Teleporting = "Teleporting"
}

-- Queue Mode Enum
QueueService.QueueMode = {
	Casual = "Casual",
	Ranked = "Ranked"
}

-- Player Queue Data Structure
function QueueService.CreateQueueData(player, mode, region)
	return {
		Player = player,
		UserId = player.UserId,
		Username = player.Name,
		Mode = mode,
		Region = region,
		JoinedAt = os.time(),
		MMR = 1000, -- Default MMR for ranked (future use)
	}
end

return QueueService
