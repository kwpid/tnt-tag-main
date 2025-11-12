local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local player = Players.LocalPlayer

print("[MatchResultClient] Listening for match results...")

RemoteEvents.MatchResult.OnClientEvent:Connect(function(isWinner, kills, deaths)
        print("[MatchResultClient] Match ended!")
        print("  Result: " .. (isWinner and "VICTORY" or "DEFEAT"))
        print("  K/D: " .. kills .. "/" .. deaths)
        
        task.wait(2)
        
        local playerGui = player:WaitForChild("PlayerGui")
        local mainGUI = playerGui:FindFirstChild("MainGUI")
        
        if mainGUI then
                local backToLobby = mainGUI:FindFirstChild("BackToLobby")
                if backToLobby then
                        backToLobby.Visible = true
                        print("[MatchResultClient] Showing 'Back to Lobby' button")
                end
        end
end)
