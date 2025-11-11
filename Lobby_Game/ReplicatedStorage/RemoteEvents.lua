--[[
	RemoteEvents.lua
	Creates and manages all RemoteEvents/RemoteFunctions for client-server communication
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = {}

-- Create folder for remote events
local remoteFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteFolder then
	remoteFolder = Instance.new("Folder")
	remoteFolder.Name = "RemoteEvents"
	remoteFolder.Parent = ReplicatedStorage
end

-- Helper function to create RemoteEvent
local function createRemoteEvent(name)
	local event = remoteFolder:FindFirstChild(name)
	if not event then
		event = Instance.new("RemoteEvent")
		event.Name = name
		event.Parent = remoteFolder
	end
	return event
end

-- Helper function to create RemoteFunction
local function createRemoteFunction(name)
	local func = remoteFolder:FindFirstChild(name)
	if not func then
		func = Instance.new("RemoteFunction")
		func.Name = name
		func.Parent = remoteFolder
	end
	return func
end

-- Queue Events
RemoteEvents.QueueJoin = createRemoteEvent("QueueJoin")
RemoteEvents.QueueLeave = createRemoteEvent("QueueLeave")
RemoteEvents.QueueStatusUpdate = createRemoteEvent("QueueStatusUpdate")
RemoteEvents.MatchFound = createRemoteEvent("MatchFound")

-- Functions
RemoteEvents.GetQueueStatus = createRemoteFunction("GetQueueStatus")

return RemoteEvents
