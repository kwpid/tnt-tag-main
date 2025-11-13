local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = {}

local remoteFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteFolder then
        remoteFolder = Instance.new("Folder")
        remoteFolder.Name = "RemoteEvents"
        remoteFolder.Parent = ReplicatedStorage
end

local function createRemoteEvent(name)
        local event = remoteFolder:FindFirstChild(name)
        if not event then
                event = Instance.new("RemoteEvent")
                event.Name = name
                event.Parent = remoteFolder
        end
        return event
end

local function createRemoteFunction(name)
        local func = remoteFolder:FindFirstChild(name)
        if not func then
                func = Instance.new("RemoteFunction")
                func.Name = name
                func.Parent = remoteFolder
        end
        return func
end

RemoteEvents.QueueJoin = createRemoteEvent("QueueJoin")
RemoteEvents.QueueLeave = createRemoteEvent("QueueLeave")
RemoteEvents.QueueStatusUpdate = createRemoteEvent("QueueStatusUpdate")
RemoteEvents.MatchFound = createRemoteEvent("MatchFound")
RemoteEvents.MatchResult = createRemoteEvent("MatchResult")
RemoteEvents.MatchResultReceived = createRemoteEvent("MatchResultReceived")
RemoteEvents.ShowLevelUp = createRemoteEvent("ShowLevelUp")
RemoteEvents.GetQueueStatus = createRemoteFunction("GetQueueStatus")

return RemoteEvents
