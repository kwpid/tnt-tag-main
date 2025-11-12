local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = {}

local function getOrCreate(name, className)
        local existing = ReplicatedStorage:FindFirstChild(name)
        if existing then
                return existing
        end
        
        local newInstance = Instance.new(className)
        newInstance.Name = name
        newInstance.Parent = ReplicatedStorage
        return newInstance
end

RemoteEvents.MatchResult = getOrCreate("MatchResult", "RemoteEvent")
RemoteEvents.MatchResultReceived = getOrCreate("MatchResultReceived", "RemoteEvent")
RemoteEvents.PlayerHit = getOrCreate("PlayerHit", "RemoteEvent")
RemoteEvents.HitEffect = getOrCreate("HitEffect", "RemoteEvent")
RemoteEvents.ReturnToLobby = getOrCreate("ReturnToLobby", "RemoteEvent")
RemoteEvents.RoundStart = getOrCreate("RoundStart", "RemoteEvent")
RemoteEvents.RoundEnd = getOrCreate("RoundEnd", "RemoteEvent")
RemoteEvents.TNTTransfer = getOrCreate("TNTTransfer", "RemoteEvent")
RemoteEvents.GameStartIntermission = getOrCreate("GameStartIntermission", "RemoteEvent")
RemoteEvents.ShowWinner = getOrCreate("ShowWinner", "RemoteEvent")
RemoteEvents.ReturnCountdown = getOrCreate("ReturnCountdown", "RemoteEvent")

return RemoteEvents
