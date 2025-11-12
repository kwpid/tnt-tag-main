local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")
local Debris = game:GetService("Debris")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local PVPServer = {}
PVPServer.__index = PVPServer

local currentIT = nil
local roundActive = false
local alivePlayers = {}
local hitCooldowns = {}
local roundNumber = 0

function PVPServer.new(gameManager)
        local self = setmetatable({}, PVPServer)
        self.GameManager = gameManager
        self:Initialize()
        return self
end

function PVPServer:Initialize()
        print("[PVPServer] Initializing...")
        
        self:SetupTeams()
        self:SetupHitDetection()
        
        print("[PVPServer] Initialized successfully!")
end

function PVPServer:SetupTeams()
        local lobbyTeam = Teams:FindFirstChild("Lobby")
        if not lobbyTeam then
                lobbyTeam = Instance.new("Team")
                lobbyTeam.Name = "Lobby"
                lobbyTeam.TeamColor = BrickColor.new("Bright blue")
                lobbyTeam.AutoAssignable = true
                lobbyTeam.Parent = Teams
        end
        
        local gameTeam = Teams:FindFirstChild("Game")
        if not gameTeam then
                gameTeam = Instance.new("Team")
                gameTeam.Name = "Game"
                gameTeam.TeamColor = BrickColor.new("Bright red")
                gameTeam.AutoAssignable = false
                gameTeam.Parent = Teams
        end
        
        print("[PVPServer] Teams created")
end

function PVPServer:SetupHitDetection()
        RemoteEvents.PlayerHit.OnServerEvent:Connect(function(player, targetPlayer)
                self:OnPlayerHit(player, targetPlayer)
        end)
end

function PVPServer:OnPlayerHit(attacker, victim)
        if not roundActive then return end
        if not attacker or not victim then return end
        if attacker == victim then return end
        
        local attackerChar = attacker.Character
        local victimChar = victim.Character
        if not attackerChar or not victimChar then return end
        
        local attackerHRP = attackerChar:FindFirstChild("HumanoidRootPart")
        local victimHRP = victimChar:FindFirstChild("HumanoidRootPart")
        if not attackerHRP or not victimHRP then return end
        
        local distance = (attackerHRP.Position - victimHRP.Position).Magnitude
        if distance > GameConfig.PVP.HitRange then return end
        
        local cooldownKey = attacker.UserId .. "_" .. victim.UserId
        if hitCooldowns[cooldownKey] and tick() - hitCooldowns[cooldownKey] < GameConfig.PVP.HitCooldown then
                return
        end
        hitCooldowns[cooldownKey] = tick()
        
        RemoteEvents.HitEffect:FireAllClients(victim, attacker)
        
        if attacker == currentIT then
                self:TransferTNT(attacker, victim)
        end
        
        self:ApplyKnockback(victimChar, attackerHRP.Position)
end

function PVPServer:ApplyKnockback(character, fromPosition)
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local direction = (hrp.Position - fromPosition).Unit
        local velocity = Instance.new("BodyVelocity")
        velocity.Velocity = direction * GameConfig.PVP.KnockbackPower + Vector3.new(0, 20, 0)
        velocity.MaxForce = Vector3.new(50000, 50000, 50000)
        velocity.Parent = hrp
        
        Debris:AddItem(velocity, 0.2)
        print("[PVPServer] Applied knockback to " .. character.Name)
end

function PVPServer:TransferTNT(from, to)
        if currentIT ~= from then return end
        if not alivePlayers[to.UserId] then return end
        
        self:RemoveTNT(from)
        self:GiveTNT(to)
        
        print("[PVPServer] TNT transferred from " .. from.Name .. " to " .. to.Name)
        RemoteEvents.TNTTransfer:FireAllClients(to)
end

function PVPServer:GiveTNT(player)
        currentIT = player
        
        local character = player.Character
        if not character then return end
        
        local tntAccessory = ServerStorage:FindFirstChild("TNT")
        if tntAccessory then
                tntAccessory = tntAccessory:FindFirstChild("TNT")
        end
        
        if tntAccessory then
                local clone = tntAccessory:Clone()
                clone.Parent = character
                print("[PVPServer] Gave TNT to " .. player.Name)
                RemoteEvents.TNTTransfer:FireAllClients(player)
        else
                warn("[PVPServer] TNT accessory not found in ServerStorage.TNT.TNT")
        end
end

function PVPServer:RemoveTNT(player)
        local character = player.Character
        if not character then return end
        
        for _, accessory in ipairs(character:GetChildren()) do
                if accessory:IsA("Accessory") and accessory.Name == "TNT" then
                        accessory:Destroy()
                end
        end
end

function PVPServer:InitializeAlivePlayers()
        alivePlayers = {}
        local gamePlayers = Teams.Game:GetPlayers()
        print("[PVPServer] Game team has " .. #gamePlayers .. " players")
        
        for _, player in ipairs(gamePlayers) do
                alivePlayers[player.UserId] = true
                print("[PVPServer] Added " .. player.Name .. " to alive players")
        end
        
        print("[PVPServer] Initialized " .. self:GetAliveCount() .. " alive players")
end

function PVPServer:StartRound()
        roundActive = true
        roundNumber = roundNumber + 1
        print("[PVPServer] Round " .. roundNumber .. " starting...")
        
        local alivelist = {}
        for userId, _ in pairs(alivePlayers) do
                local player = Players:GetPlayerByUserId(userId)
                if player then
                        table.insert(alivelist, player)
                end
        end
        
        if #alivelist == 0 then
                print("[PVPServer] No alive players")
                roundActive = false
                return
        end
        
        local tntDelay = 0
        if roundNumber == 1 then
                tntDelay = GameConfig.Game.FirstRoundDelay
                print("[PVPServer] First round! TNT will be given in " .. tntDelay .. "s")
        end
        
        RemoteEvents.RoundStart:FireAllClients(GameConfig.Game.RoundTime, tntDelay)
        
        task.delay(tntDelay, function()
                if not roundActive then return end
                
                local currentAlive = {}
                for userId, _ in pairs(alivePlayers) do
                        local player = Players:GetPlayerByUserId(userId)
                        if player and player.Parent then
                                table.insert(currentAlive, player)
                        end
                end
                
                if #currentAlive > 0 then
                        local randomPlayer = currentAlive[math.random(1, #currentAlive)]
                        self:GiveTNT(randomPlayer)
                else
                        warn("[PVPServer] No alive players to give TNT to!")
                end
        end)
        
        task.delay(GameConfig.Game.RoundTime + tntDelay, function()
                if roundActive then
                        self:ExplodeTNT()
                end
        end)
end

function PVPServer:ExplodeTNT()
        roundActive = false
        
        if currentIT then
                local aliveCount = self:GetAliveCount()
                
                if aliveCount == 2 then
                        print("[PVPServer] 1v1 situation - only " .. currentIT.Name .. " dies from TNT explosion")
                else
                        print("[PVPServer] " .. currentIT.Name .. " exploded!")
                end
                
                self:KillPlayer(currentIT)
                self:RemoveTNT(currentIT)
                currentIT = nil
        end
        
        RemoteEvents.RoundEnd:FireAllClients(GameConfig.Game.IntermissionTime)
end

function PVPServer:KillPlayer(player)
        alivePlayers[player.UserId] = nil
        
        local character = player.Character
        if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                        humanoid.Health = 0
                end
        end
        
        player.Team = Teams.Lobby
        
        self.GameManager:RecordDeath(player)
end

function PVPServer:GetAliveCount()
        local count = 0
        for userId, _ in pairs(alivePlayers) do
                local player = Players:GetPlayerByUserId(userId)
                if player then
                        count = count + 1
                end
        end
        return count
end

function PVPServer:GetWinner()
        for userId, _ in pairs(alivePlayers) do
                local player = Players:GetPlayerByUserId(userId)
                if player then
                        return player
                end
        end
        return nil
end

function PVPServer:Reset()
        roundActive = false
        currentIT = nil
        alivePlayers = {}
        hitCooldowns = {}
        roundNumber = 0
end

return PVPServer
