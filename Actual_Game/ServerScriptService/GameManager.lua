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
local intermissionStartTime = 0
local intermissionDuration = 0

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
                local playerData = activePlayers[player.UserId]
                if playerData and playerData.MatchResult then
                        local result = playerData.MatchResult
                        print("[GameManager] Manual return to lobby for " .. player.Name .. " with match data")
                        self:TeleportToLobby(player, result.isWinner, result.deaths, result.matchId, result.saveSuccess, result.levelUpData, result.kills)
                        playerData.MatchResult = nil
                else
                        print("[GameManager] Manual return to lobby for " .. player.Name .. " without match data")
                        self:TeleportToLobby(player)
                end
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
                Survived = 0,
                MatchResult = nil
        }
        
        player.Team = Teams.Lobby
        
        if intermissionStartTime > 0 and not gameActive then
                local intermissionEndTime = intermissionStartTime + intermissionDuration
                local currentTime = workspace:GetServerTimeNow()
                if currentTime < intermissionEndTime then
                        print("[GameManager] Sending intermission UI to late-joiner " .. player.Name .. " (ends at " .. intermissionEndTime .. ")")
                        RemoteEvents.GameStartIntermission:FireClient(player, intermissionEndTime)
                end
        end
        
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
                intermissionStartTime = workspace:GetServerTimeNow()
                intermissionDuration = GameConfig.Game.StartIntermissionTime
                local intermissionEndTime = intermissionStartTime + intermissionDuration
                RemoteEvents.GameStartIntermission:FireAllClients(intermissionEndTime)
                
                countdownThread = task.spawn(function()
                        task.wait(GameConfig.Game.StartIntermissionTime)
                        intermissionStartTime = 0
                        intermissionDuration = 0
                        
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
        local playerData = activePlayers[player.UserId]
        if playerData then
                playerData.MatchResult = nil
        end
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
        
        local isFirstRound = true
        
        while gameActive do
                local aliveCount = self.PVP:GetAliveCount()
                
                if aliveCount <= 1 then
                        local winner = self.PVP:GetWinner()
                        self:EndGame(winner)
                        break
                end
                
                print("[GameManager] Starting round with " .. aliveCount .. " players")
                self.PVP:StartRound()
                
                local roundDuration = GameConfig.Game.RoundTime
                if isFirstRound then
                        roundDuration = roundDuration + GameConfig.Game.FirstRoundDelay
                        isFirstRound = false
                end
                
                task.wait(roundDuration)
                
                if gameActive then
                        task.wait(GameConfig.Game.IntermissionTime)
                end
        end
end

function GameManager:EndGame(winner)
        print("[GameManager] Ending game...")
        gameActive = false
        cleanupInProgress = true
        self.PVP:Reset()
        
        local winnerName = winner and winner.Name or "No one"
        print("[GameManager] Winner: " .. winnerName)
        
        local playerMatchIds = {}
        local playerSaveStatus = {}
        
        for userId, playerData in pairs(activePlayers) do
                local player = playerData.Player
                if player and player.Parent then
                        local isWinner = (player == winner)
                        local kills = playerData.Kills or 0
                        local matchId, saveSuccess, levelUpData = PlayerDataManager:RecordMatchResult(player, isWinner, playerData.Deaths, kills)
                        playerMatchIds[userId] = matchId
                        playerSaveStatus[userId] = saveSuccess
                        
                        playerData.MatchResult = {
                                isWinner = isWinner,
                                deaths = playerData.Deaths,
                                kills = kills,
                                matchId = matchId,
                                saveSuccess = saveSuccess,
                                levelUpData = levelUpData
                        }
                        
                        RemoteEvents.MatchResult:FireClient(player, isWinner, kills, playerData.Deaths)
                end
        end
        
        RemoteEvents.ShowWinner:FireAllClients(winnerName)
        
        for i = GameConfig.Game.EndGameWaitTime, 1, -1 do
                RemoteEvents.ReturnCountdown:FireAllClients(i)
                task.wait(1)
        end
        
        for userId, playerData in pairs(activePlayers) do
                local player = playerData.Player
                if player and player.Parent and player.Team == Teams.Game then
                        local isWinner = (player == winner)
                        local matchId = playerMatchIds[userId]
                        local saveSuccess = playerSaveStatus[userId]
                        local levelUpData = playerData.MatchResult and playerData.MatchResult.levelUpData or nil
                        local kills = playerData.MatchResult and playerData.MatchResult.kills or 0
                        print("[GameManager] Teleporting " .. player.Name .. " back to lobby (Save: " .. tostring(saveSuccess) .. ")")
                        player.Team = Teams.Lobby
                        self:TeleportToLobby(player, isWinner, playerData.Deaths, matchId, saveSuccess, levelUpData, kills)
                        playerData.MatchResult = nil
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

function GameManager:TeleportToLobby(player, isWinner, deaths, matchId, saveSuccess, levelUpData, kills)
        local lobbyPlaceId = GameConfig.LobbyPlaceId or game.PlaceId
        
        local teleportOptions = Instance.new("TeleportOptions")
        teleportOptions.ShouldReserveServer = false
        
        if isWinner ~= nil then
                local matchData = {
                        isWinner = isWinner,
                        kills = kills or 0,
                        deaths = deaths or 0,
                        mode = "Casual",
                        matchId = matchId,
                        alreadyProcessed = saveSuccess == true
                }
                
                if levelUpData and levelUpData.oldLevel and levelUpData.newLevel then
                        matchData.levelUpData = levelUpData
                        print("[GameManager] Including level-up data: " .. tostring(levelUpData.oldLevel) .. "->" .. tostring(levelUpData.newLevel) .. ", XP: " .. tostring(levelUpData.oldXP) .. "->" .. tostring(levelUpData.newXP))
                else
                        warn("[GameManager] No valid levelUpData to include in teleport")
                end
                
                teleportOptions:SetTeleportData(matchData)
                print("[GameManager] Sending match data: Win=" .. tostring(isWinner) .. ", Kills=" .. (kills or 0) .. ", Deaths=" .. (deaths or 0) .. ", MatchID=" .. tostring(matchId) .. ", Processed=" .. tostring(saveSuccess))
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
