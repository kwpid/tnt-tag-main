--[[
	InitializeServer.lua
	Main server initialization script
	Loads all necessary server modules and systems
]]

print("=========================================")
print("   Lobby Game Server - Initializing")
print("=========================================")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for modules to load
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))
local QueueService = require(ReplicatedStorage:WaitForChild("QueueService"))

print("[Server] Modules loaded successfully")

-- Initialize Queue Manager (it auto-initializes)
local QueueManager = require(script.Parent:WaitForChild("QueueManager"))

print("[Server] Queue Manager initialized")

-- Print configuration
print("=========================================")
print("   Configuration Summary")
print("=========================================")
print("Sub-Place ID: " .. tostring(GameConfig.SubPlace.PlaceId))
print("Min Players: " .. tostring(GameConfig.Queue.MinPlayersPerMatch))
print("Max Players: " .. tostring(GameConfig.Queue.MaxPlayersPerMatch))
print("Debug Mode: " .. tostring(GameConfig.Debug.Enabled))
print("Test Mode: " .. tostring(GameConfig.Debug.TestMode))
print("=========================================")

if GameConfig.SubPlace.PlaceId == 0 then
	warn("⚠️ WARNING: Sub-place ID not configured!")
	warn("⚠️ Set GameConfig.SubPlace.PlaceId to your Actual_Game place ID")
	warn("⚠️ Players will not be able to teleport until this is set")
end

print("[Server] Initialization complete!")
print("=========================================")
