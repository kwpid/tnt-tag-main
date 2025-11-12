local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TimeSyncRequest = Instance.new("RemoteFunction")
TimeSyncRequest.Name = "TimeSyncRequest"
TimeSyncRequest.Parent = ReplicatedStorage

TimeSyncRequest.OnServerInvoke = function(player)
	return workspace:GetServerTimeNow()
end

print("[TimeSyncServer] Time synchronization service initialized")
