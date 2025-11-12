local TimeSync = {}

local RunService = game:GetService("RunService")

local clockOffset = 0
local lastSyncTime = 0
local SYNC_INTERVAL = 10
local initialized = false

if RunService:IsClient() then
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local TimeSyncFunction = ReplicatedStorage:WaitForChild("TimeSyncRequest")
        
        local function SyncClock()
                local clientSend = tick()
                local success, serverTime = pcall(function()
                        return TimeSyncFunction:InvokeServer()
                end)
                
                if success and serverTime then
                        local clientRecv = tick()
                        local rtt = clientRecv - clientSend
                        local halfRtt = rtt * 0.5
                        local estimatedServerSend = serverTime - halfRtt
                        local newOffset = estimatedServerSend - clientSend
                        
                        if clockOffset == 0 then
                                clockOffset = newOffset
                        else
                                clockOffset = clockOffset * 0.8 + newOffset * 0.2
                        end
                        
                        initialized = true
                        lastSyncTime = tick()
                        print("[TimeSync] Synced! RTT: " .. math.floor(rtt * 1000) .. "ms, Offset: " .. math.floor(clockOffset * 1000) .. "ms")
                else
                        warn("[TimeSync] Failed to sync with server!")
                end
        end
        
        task.spawn(function()
                SyncClock()
                
                while true do
                        task.wait(SYNC_INTERVAL)
                        SyncClock()
                end
        end)
end

function TimeSync.WaitForSync()
        if RunService:IsServer() then
                return
        end
        
        while not initialized do
                task.wait(0.1)
        end
end

function TimeSync.ServerToClientTime(serverTimestamp)
        if RunService:IsServer() then
                return serverTimestamp
        else
                return serverTimestamp - clockOffset
        end
end

function TimeSync.GetServerTime()
        if RunService:IsServer() then
                return workspace:GetServerTimeNow()
        else
                return tick() + clockOffset
        end
end

return TimeSync
