local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local PlayerDataService = require(ReplicatedStorage:WaitForChild("PlayerDataService"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local GameManager = {}
GameManager.__index = GameManager

local activePlayers = {}
local gameActive = false

function GameManager.new()
	local self = setmetatable({}, GameManager)
	self:Initialize()
	return self
end

function GameManager:Initialize()
	print("[GameManager] Initializing...")
	
	Players.PlayerAdded:Connect(function(player)
		self:OnPlayerJoin(player)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		self:OnPlayerLeave(player)
	end)
	
	task.wait(5)
	self:StartGame()
	
	print("[GameManager] Initialized successfully!")
end

function GameManager:OnPlayerJoin(player)
	local joinData = player:GetJoinData()
	local teleportData = joinData.TeleportData
	
	if teleportData then
		print("[GameManager] " .. player.Name .. " joined from queue")
		print("  Mode: " .. tostring(teleportData.Mode))
		print("  Region: " .. tostring(teleportData.Region))
	end
	
	activePlayers[player.UserId] = {
		Player = player,
		Kills = 0,
		Deaths = 0
	}
end

function GameManager:OnPlayerLeave(player)
	activePlayers[player.UserId] = nil
end

function GameManager:StartGame()
	print("[GameManager] Starting game...")
	gameActive = true
end

function GameManager:EndGame(winners)
	print("[GameManager] Ending game...")
	gameActive = false
	
	for userId, playerData in pairs(activePlayers) do
		local player = playerData.Player
		if player and player.Parent then
			local isWinner = table.find(winners or {}, player)
			
			if isWinner then
				RemoteEvents.MatchResult:FireClient(player, true, playerData.Kills, playerData.Deaths)
			else
				RemoteEvents.MatchResult:FireClient(player, false, playerData.Kills, playerData.Deaths)
			end
		end
	end
	
	task.wait(5)
	
	for userId, playerData in pairs(activePlayers) do
		local player = playerData.Player
		if player and player.Parent then
			self:TeleportToLobby(player)
		end
	end
end

function GameManager:TeleportToLobby(player)
	local lobbyPlaceId = game.PlaceId
	
	local success, err = pcall(function()
		TeleportService:Teleport(lobbyPlaceId, player)
	end)
	
	if not success then
		warn("[GameManager] Failed to teleport " .. player.Name .. " to lobby: " .. tostring(err))
	end
end

function GameManager:RecordKill(killer, victim)
	if activePlayers[killer.UserId] then
		activePlayers[killer.UserId].Kills = activePlayers[killer.UserId].Kills + 1
	end
	
	if activePlayers[victim.UserId] then
		activePlayers[victim.UserId].Deaths = activePlayers[victim.UserId].Deaths + 1
	end
end

local gameManager = GameManager.new()

return gameManager
