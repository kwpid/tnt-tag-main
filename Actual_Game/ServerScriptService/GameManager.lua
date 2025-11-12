local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))
local PVPServer = require(script.Parent:WaitForChild("PVPServer"))
local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))

local GameManager = {}
GameManager.__index = GameManager

local activePlayers = {}
local gameActive = false
local cleanupInProgress = false
local currentMap = nil
local countdownThread = nil

function GameManager.new()
        local self = setmetatable({}, GameManager)
        self:Initialize()
        return self
end

function GameManager:Initialize()
        print("[GameManager] Initializing...")
        
        self.PVP = PVPServer.new(self)
        
        Players.PlayerAdded:Connect(function(player)
                self:OnPlayerJoin(player)
        end)
        
        Players.PlayerRemoving:Connect(function(player)
                self:OnPlayerLeave(player)
        end)
        
        RemoteEvents.ReturnToLobby.OnServerEvent:Connect(function(player)
                self:TeleportToLobby(player)
        end)
        
        print("[GameManager] Initialized successfully! Waiting for players to join...")
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
        
        self:CheckStartGame()
end

function GameManager:CheckStartGame()
        if countdownThread or gameActive or cleanupInProgress then
                return
        end
        
        local lobbyPlayerCount = #Teams.Lobby:GetPlayers()
        print("[GameManager] Lobby has " .. lobbyPlayerCount .. " players")
        
        if lobbyPlayerCount >= 2 then
                print("[GameManager] Enough players joined! Loading map and starting intermission...")
                
                if not self:LoadMap() then
                        warn("[GameManager] Failed to load map, aborting game start")
                        return
                end
                
                print("[GameManager] Map loaded! Starting " .. GameConfig.Game.StartIntermissionTime .. "s intermission...")
                RemoteEvents.GameStartIntermission:FireAllClients(GameConfig.Game.StartIntermissionTime)
                
                countdownThread = task.spawn(function()
                        task.wait(GameConfig.Game.StartIntermissionTime)
                        
                        local currentLobbyCount = #Teams.Lobby:GetPlayers()
                        if currentLobbyCount < 2 then
                                warn("[GameManager] Not enough players remained during intermission (have " .. currentLobbyCount .. "), aborting...")
                                if currentMap then
                                        currentMap:Destroy()
                                        currentMap = nil
                                end
                                countdownThread = nil
                                return
                        end
                        
                        if gameActive then
                                warn("[GameManager] Game already active, skipping...")
                                countdownThread = nil
                                return
                        end
                        
                        countdownThread = nil
                        self:StartGame()
                end)
        end
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
        print("[GameManager] ========================================")
        print("[GameManager] Starting TNT Tag game...")
        print("[GameManager] ========================================")
        gameActive = true
        
        if not currentMap then
                warn("[GameManager] Map not loaded, aborting game")
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
        
        print("[GameManager] Starting rounds with " .. playerCount .. " players!")
        
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
        cleanupInProgress = true
        self.PVP:Reset()
        
        local winnerName = winner and winner.Name or "No one"
        print("[GameManager] Winner: " .. winnerName)
        
        RemoteEvents.ShowWinner:FireAllClients(winnerName)
        
        for userId, playerData in pairs(activePlayers) do
                local player = playerData.Player
                if player and player.Parent then
                        local isWinner = (player == winner)
                        RemoteEvents.MatchResult:FireClient(player, isWinner, 0, playerData.Deaths)
                end
        end
        
        for i = GameConfig.Game.EndGameWaitTime, 1, -1 do
                RemoteEvents.ReturnCountdown:FireAllClients(i)
                task.wait(1)
        end
        
        for userId, playerData in pairs(activePlayers) do
                local player = playerData.Player
                if player and player.Parent and player.Team == Teams.Game then
                        local isWinner = (player == winner)
                        print("[GameManager] Teleporting " .. player.Name .. " back to lobby")
                        player.Team = Teams.Lobby
                        self:TeleportToLobby(player, isWinner, playerData.Deaths)
                end
        end
        
        if currentMap then
                currentMap:Destroy()
                currentMap = nil
        end
        
        cleanupInProgress = false
        print("[GameManager] Cleanup complete, ready for next match")
        self:CheckStartGame()
end

function GameManager:TeleportToLobby(player, isWinner, deaths)
        local lobbyPlaceId = GameConfig.LobbyPlaceId or game.PlaceId
        
        local teleportOptions = Instance.new("TeleportOptions")
        teleportOptions.ShouldReserveServer = false
        
        if isWinner ~= nil then
                local matchData = {
                        isWinner = isWinner,
                        kills = 0,
                        deaths = deaths or 0,
                        mode = "Casual"
                }
                teleportOptions:SetTeleportData(matchData)
                print("[GameManager] Sending match data: Win=" .. tostring(isWinner) .. ", Deaths=" .. (deaths or 0))
        end
        
        local success, err = pcall(function()
                TeleportService:TeleportAsync(lobbyPlaceId, {player}, teleportOptions)
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
