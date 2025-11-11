local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local PVPMain = {}
PVPMain.__index = PVPMain

local currentIT = nil
local roundActive = false
local alivePlayers = {}
local hitCooldowns = {}

function PVPMain.new(gameManager)
        local self = setmetatable({}, PVPMain)
        self.GameManager = gameManager
        self:Initialize()
        return self
end

function PVPMain:Initialize()
        print("[PVPMain] Initializing...")
        
        self:SetupTeams()
        self:SetupHitDetection()
        
        print("[PVPMain] Initialized successfully!")
end

function PVPMain:SetupTeams()
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
        
        print("[PVPMain] Teams created")
end

function PVPMain:SetupHitDetection()
        RemoteEvents.PlayerHit.OnServerEvent:Connect(function(player, targetPlayer)
                self:OnPlayerHit(player, targetPlayer)
        end)
end

function PVPMain:OnPlayerHit(attacker, victim)
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
        
        if attacker == currentIT then
                self:TransferTNT(attacker, victim)
        end
        
        self:ApplyKnockback(victimChar, attackerHRP.Position)
end

function PVPMain:ApplyKnockback(character, fromPosition)
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local direction = (hrp.Position - fromPosition).Unit
        local velocity = Instance.new("BodyVelocity")
        velocity.Velocity = direction * GameConfig.PVP.KnockbackPower + Vector3.new(0, 20, 0)
        velocity.MaxForce = Vector3.new(50000, 50000, 50000)
        velocity.Parent = hrp
        
        game:GetService("Debris"):AddItem(velocity, 0.1)
end

function PVPMain:TransferTNT(from, to)
        if currentIT ~= from then return end
        if not alivePlayers[to.UserId] then return end
        
        self:RemoveTNT(from)
        self:GiveTNT(to)
        
        print("[PVPMain] TNT transferred from " .. from.Name .. " to " .. to.Name)
        RemoteEvents.TNTTransfer:FireAllClients(to)
end

function PVPMain:GiveTNT(player)
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
        else
                warn("[PVPMain] TNT accessory not found in ServerStorage.TNT.TNT")
        end
end

function PVPMain:RemoveTNT(player)
        local character = player.Character
        if not character then return end
        
        for _, accessory in ipairs(character:GetChildren()) do
                if accessory:IsA("Accessory") and accessory.Name == "TNT" then
                        accessory:Destroy()
                end
        end
end

function PVPMain:InitializeAlivePlayers()
        alivePlayers = {}
        for _, player in ipairs(Teams.Game:GetPlayers()) do
                alivePlayers[player.UserId] = true
        end
        print("[PVPMain] Initialized " .. self:GetAliveCount() .. " alive players")
end

function PVPMain:StartRound()
        roundActive = true
        print("[PVPMain] Round starting...")
        
        self:InitializeAlivePlayers()
        
        local alivelist = {}
        for userId, _ in pairs(alivePlayers) do
                local player = Players:GetPlayerByUserId(userId)
                if player then
                        table.insert(alivelist, player)
                end
        end
        
        if #alivelist == 0 then
                print("[PVPMain] No alive players")
                return
        end
        
        local randomPlayer = alivelist[math.random(1, #alivelist)]
        self:GiveTNT(randomPlayer)
        
        RemoteEvents.RoundStart:FireAllClients(GameConfig.Game.RoundTime)
        
        task.wait(GameConfig.Game.RoundTime)
        
        self:ExplodeTNT()
end

function PVPMain:ExplodeTNT()
        roundActive = false
        
        if currentIT then
                print("[PVPMain] " .. currentIT.Name .. " exploded!")
                self:KillPlayer(currentIT)
                self:RemoveTNT(currentIT)
                currentIT = nil
        end
        
        RemoteEvents.RoundEnd:FireAllClients()
end

function PVPMain:KillPlayer(player)
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

function PVPMain:GetAliveCount()
        local count = 0
        for userId, _ in pairs(alivePlayers) do
                local player = Players:GetPlayerByUserId(userId)
                if player then
                        count = count + 1
                end
        end
        return count
end

function PVPMain:GetWinner()
        for userId, _ in pairs(alivePlayers) do
                local player = Players:GetPlayerByUserId(userId)
                if player then
                        return player
                end
        end
        return nil
end

function PVPMain:Reset()
        roundActive = false
        currentIT = nil
        alivePlayers = {}
        hitCooldowns = {}
end

return PVPMain
