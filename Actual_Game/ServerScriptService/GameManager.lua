local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))
local PVPMain = require(script.Parent:WaitForChild("PVPMain"))

local GameManager = {}
GameManager.__index = GameManager

local activePlayers = {}
local gameActive = false
local currentMap = nil

function GameManager.new()
        local self = setmetatable({}, GameManager)
        self:Initialize()
        return self
end

function GameManager:Initialize()
        print("[GameManager] Initializing...")
        
        self.PVP = PVPMain.new(self)
        
        Players.PlayerAdded:Connect(function(player)
                self:OnPlayerJoin(player)
        end)
        
        Players.PlayerRemoving:Connect(function(player)
                self:OnPlayerLeave(player)
        end)
        
        RemoteEvents.ReturnToLobby.OnServerEvent:Connect(function(player)
                self:TeleportToLobby(player)
        end)
        
        task.wait(GameConfig.Game.FirstRoundDelay)
        self:StartGame()
        
        print("[GameManager] Initialized successfully!")
end

function GameManager:OnPlayerJoin(player)
        local joinData = player:GetJoinData()
        local teleportData = joinData.TeleportData
        
        if teleportData then
                print("[GameManager] " .. player.Name .. " joined from queue")
        end
        
        activePlayers[player.UserId] = {
                Player = player,
                Deaths = 0,
                Survived = 0
        }
        
        player.Team = Teams.Lobby
end

function GameManager:OnPlayerLeave(player)
        activePlayers[player.UserId] = nil
end

function GameManager:LoadMap()
        if currentMap then
                currentMap:Destroy()
                currentMap = nil
        end
        
        local mapsFolder = ServerStorage:FindFirstChild("Maps")
        if not mapsFolder then
                warn("[GameManager] Maps folder not found in ServerStorage")
                return false
        end
        
        local maps = mapsFolder:GetChildren()
        if #maps == 0 then
                warn("[GameManager] No maps found in ServerStorage.Maps")
                return false
        end
        
        local randomMap = maps[math.random(1, #maps)]
        currentMap = randomMap:Clone()
        currentMap.Parent = workspace
        
        print("[GameManager] Loaded map: " .. currentMap.Name)
        return true
end

function GameManager:SpawnPlayers()
        local mapSpawn = currentMap and currentMap:FindFirstChild("MapSpawn")
        
        if not mapSpawn then
                warn("[GameManager] MapSpawn not found in map")
                return
        end
        
        for userId, playerData in pairs(activePlayers) do
                local player = playerData.Player
                if player and player.Parent and player.Team == Teams.Game then
                        local character = player.Character
                        if character then
                                local hrp = character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                        hrp.CFrame = mapSpawn.CFrame + Vector3.new(
                                                math.random(-10, 10),
                                                5,
                                                math.random(-10, 10)
                                        )
                                end
                        end
                end
        end
        
        print("[GameManager] Players spawned at MapSpawn")
end

function GameManager:StartGame()
        print("[GameManager] Starting TNT Tag game...")
        gameActive = true
        
        if not self:LoadMap() then
                warn("[GameManager] Failed to load map, aborting game")
                gameActive = false
                self:EndGame(nil)
                return
        end
        
        print("[GameManager] Resetting players and assigning to Game team...")
        for userId, playerData in pairs(activePlayers) do
                local player = playerData.Player
                if player and player.Parent then
                        if player.Character then
                                local humanoid = player.Character:FindFirstChild("Humanoid")
                                if humanoid and humanoid.Health > 0 then
                                        humanoid.Health = humanoid.MaxHealth
                                else
                                        player:LoadCharacter()
                                end
                        else
                                player:LoadCharacter()
                        end
                end
        end
        
        task.wait(2)
        
        for userId, playerData in pairs(activePlayers) do
                local player = playerData.Player
                if player and player.Parent then
                        player.Team = Teams.Game
                        print("[GameManager] Assigned " .. player.Name .. " to Game team")
                end
        end
        
        task.wait(0.5)
        self:SpawnPlayers()
        
        self.PVP:InitializeAlivePlayers()
        
        local playerCount = self.PVP:GetAliveCount()
        print("[GameManager] Player count after initialization: " .. playerCount)
        
        if playerCount < 2 then
                warn("[GameManager] Not enough players to start game (need 2+, have " .. playerCount .. ")")
                self:EndGame(nil)
                return
        end
        
        print("[GameManager] Starting " .. GameConfig.Game.StartIntermissionTime .. "s intermission before first round...")
        RemoteEvents.GameStartIntermission:FireAllClients(GameConfig.Game.StartIntermissionTime)
        task.wait(GameConfig.Game.StartIntermissionTime)
        
        while gameActive do
                local aliveCount = self.PVP:GetAliveCount()
                
                if aliveCount <= 1 then
                        local winner = self.PVP:GetWinner()
                        self:EndGame(winner)
                        break
                end
                
                print("[GameManager] Starting round with " .. aliveCount .. " players")
                self.PVP:StartRound()
                
                task.wait(GameConfig.Game.IntermissionTime)
        end
end

function GameManager:EndGame(winner)
        print("[GameManager] Ending game...")
        gameActive = false
        self.PVP:Reset()
        
        for userId, playerData in pairs(activePlayers) do
                local player = playerData.Player
                if player and player.Parent then
                        local isWinner = (player == winner)
                        
                        if isWinner then
                                RemoteEvents.MatchResult:FireClient(player, true, 0, playerData.Deaths)
                                print("[GameManager] Winner: " .. player.Name)
                        else
                                RemoteEvents.MatchResult:FireClient(player, false, 0, playerData.Deaths)
                        end
                end
        end
        
        task.wait(GameConfig.Game.EndGameWaitTime)
        
        for userId, playerData in pairs(activePlayers) do
                local player = playerData.Player
                if player and player.Parent then
                        self:TeleportToLobby(player)
                end
        end
        
        if currentMap then
                currentMap:Destroy()
                currentMap = nil
        end
end

function GameManager:TeleportToLobby(player)
        local lobbyPlaceId = GameConfig.LobbyPlaceId or game.PlaceId
        
        local success, err = pcall(function()
                TeleportService:Teleport(lobbyPlaceId, player)
        end)
        
        if not success then
                warn("[GameManager] Failed to teleport " .. player.Name .. " to lobby: " .. tostring(err))
        end
end

function GameManager:RecordDeath(player)
        if activePlayers[player.UserId] then
                activePlayers[player.UserId].Deaths = activePlayers[player.UserId].Deaths + 1
        end
end

local gameManager = GameManager.new()

return gameManager
