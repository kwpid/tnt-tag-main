local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local winnerLabel = nil
local countdownLabel = nil

local function createWinnerUI()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "EndGameUI"
        screenGui.ResetOnSpawn = false
        screenGui.DisplayOrder = 100
        screenGui.Parent = playerGui
        
        winnerLabel = Instance.new("TextLabel")
        winnerLabel.Name = "WinnerLabel"
        winnerLabel.Size = UDim2.new(1, 0, 0.2, 0)
        winnerLabel.Position = UDim2.new(0, 0, 0.3, 0)
        winnerLabel.BackgroundTransparency = 1
        winnerLabel.Text = ""
        winnerLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        winnerLabel.TextScaled = true
        winnerLabel.Font = Enum.Font.GothamBold
        winnerLabel.TextStrokeTransparency = 0
        winnerLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        winnerLabel.Parent = screenGui
        
        countdownLabel = Instance.new("TextLabel")
        countdownLabel.Name = "CountdownLabel"
        countdownLabel.Size = UDim2.new(1, 0, 0.1, 0)
        countdownLabel.Position = UDim2.new(0, 0, 0.55, 0)
        countdownLabel.BackgroundTransparency = 1
        countdownLabel.Text = ""
        countdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        countdownLabel.TextScaled = true
        countdownLabel.Font = Enum.Font.Gotham
        countdownLabel.TextStrokeTransparency = 0.5
        countdownLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        countdownLabel.Parent = screenGui
end

local function removeWinnerUI()
        local existingUI = playerGui:FindFirstChild("EndGameUI")
        if existingUI then
                existingUI:Destroy()
        end
        winnerLabel = nil
        countdownLabel = nil
end

RemoteEvents.ShowWinner.OnClientEvent:Connect(function(winnerName)
        removeWinnerUI()
        createWinnerUI()
        
        if winnerLabel then
                winnerLabel.Text = winnerName .. " WINS!"
        end
end)

RemoteEvents.ReturnCountdown.OnClientEvent:Connect(function(timeLeft)
        if not countdownLabel then
                createWinnerUI()
        end
        
        if countdownLabel then
                countdownLabel.Text = "Returning to lobby in " .. timeLeft .. "s"
        end
        
        if timeLeft <= 1 then
                task.wait(1)
                removeWinnerUI()
        end
end)

RemoteEvents.GameStartIntermission.OnClientEvent:Connect(function()
        removeWinnerUI()
end)

Players.LocalPlayer.CharacterRemoving:Connect(function()
        removeWinnerUI()
end)

print("[EndGameUI] Initialized")
