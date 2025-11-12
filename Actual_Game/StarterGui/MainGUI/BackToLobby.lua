local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local player = Players.LocalPlayer
local button = script.Parent

button.Visible = false

button.MouseButton1Click:Connect(function()
        print("[BackToLobby] Requesting return to lobby...")
        RemoteEvents.ReturnToLobby:FireServer()
        button.Visible = false
end)

RemoteEvents.ShowWinner.OnClientEvent:Connect(function(winnerName)
        button.Visible = true
        print("[BackToLobby] Button shown - game ended")
end)

RemoteEvents.GameStartIntermission.OnClientEvent:Connect(function()
        button.Visible = false
        print("[BackToLobby] Button hidden - new game starting")
end)

print("[BackToLobby] Back to Lobby button initialized")
