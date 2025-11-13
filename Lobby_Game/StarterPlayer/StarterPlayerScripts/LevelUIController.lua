local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local levelGUI = playerGui:WaitForChild("LevelGUI")
local levelBar = levelGUI:WaitForChild("LevelBar")
local barFill = levelBar:WaitForChild("BarFill")
local currentLevelText = levelBar:WaitForChild("CurrentLevel")
local nextLevelText = levelBar:WaitForChild("NextLevel")
local xpFrame = levelBar:WaitForChild("XPFrame")
local scrollingFrame = xpFrame:WaitForChild("ScrollingFrame")

local XP_GAIN_TEMPLATE = script.XP_Gain

local LevelUIController = {
        isShowing = false,
        currentData = nil
}

function LevelUIController:GetXPForLevel(level)
        return 100 + (level * 50)
end

function LevelUIController:CalculateProgress(currentXP, level)
        local xpNeeded = self:GetXPForLevel(level)
        return math.clamp(currentXP / xpNeeded, 0, 1)
end

function LevelUIController:UpdateBarFill(progress, animate)
        local targetSize = UDim2.new(progress, 0, 1, 0)

        if animate then
                local tween = TweenService:Create(barFill, TweenInfo.new(
                        GameConfig.LevelUI.BarFillDuration,
                        GameConfig.LevelUI.BarFillEasingStyle,
                        GameConfig.LevelUI.BarFillEasingDirection
                ), {
                        Size = targetSize
                })
                tween:Play()
                return tween
        else
                barFill.Size = targetSize
        end
end

function LevelUIController:ShowLevelBar()
        levelBar.Visible = true

        levelBar.Position = UDim2.new(0.5, 0, -0.2, 0)
        local tween = TweenService:Create(levelBar, TweenInfo.new(
                GameConfig.LevelUI.ShowDuration,
                GameConfig.LevelUI.ShowEasingStyle,
                GameConfig.LevelUI.ShowEasingDirection
        ), {
                Position = UDim2.new(0.5, 0, 0.1, 0)
        })

        tween:Play()
        tween.Completed:Wait()
end

function LevelUIController:HideLevelBar()
        local tween = TweenService:Create(levelBar, TweenInfo.new(
                GameConfig.LevelUI.HideDuration,
                GameConfig.LevelUI.HideEasingStyle,
                GameConfig.LevelUI.HideEasingDirection
        ), {
                Position = UDim2.new(0.5, 0, -0.2, 0)
        })

        tween:Play()
        tween.Completed:Wait()

        levelBar.Visible = false
end

function LevelUIController:ClearXPGains()
        for _, child in ipairs(scrollingFrame:GetChildren()) do
                if child:IsA("TextLabel") and child.Name == "XP_Gain" then
                        child:Destroy()
                end
        end

        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

function LevelUIController:AddXPGainEntry(amount, reason)
        local entry = XP_GAIN_TEMPLATE:Clone()
        entry.Text = "+" .. amount .. " XP (" .. reason .. ")"
        entry.Parent = scrollingFrame

        local yOffset = 0
        for i, child in ipairs(scrollingFrame:GetChildren()) do
                if child:IsA("TextLabel") and child.Name == "XP_Gain" then
                        child.Position = UDim2.new(0, 0, 0, yOffset)
                        yOffset = yOffset + child.Size.Y.Offset
                end
        end

        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)

        entry.TextTransparency = 1
        TweenService:Create(entry, TweenInfo.new(0.3), {
                TextTransparency = 0
        }):Play()
end

function LevelUIController:AnimateXPGain(startXP, startLevel, xpAmount)
        local currentXP = startXP
        local currentLevel = startLevel

        currentXP = currentXP + xpAmount

        while currentXP >= self:GetXPForLevel(currentLevel) do
                local xpNeeded = self:GetXPForLevel(currentLevel)

                local progressBefore = self:CalculateProgress(currentXP - xpAmount, currentLevel)
                local tween = self:UpdateBarFill(1.0, true)
                if tween then tween.Completed:Wait() end

                task.wait(0.2)

                currentXP = currentXP - xpNeeded
                currentLevel = currentLevel + 1

                currentLevelText.Text = "Level " .. currentLevel
                nextLevelText.Text = "Level " .. (currentLevel + 1)

                self:UpdateBarFill(0, false)

                task.wait(0.3)
        end

        local finalProgress = self:CalculateProgress(currentXP, currentLevel)
        local tween = self:UpdateBarFill(finalProgress, true)
        if tween then tween.Completed:Wait() end

        return currentXP, currentLevel
end

function LevelUIController:DisplayLevelUp(data)
        if self.isShowing then
                print("[LevelUI] Already showing, ignoring new request")
                return
        end

        self.isShowing = true
        self.currentData = data

        print("[LevelUI] Showing level up GUI")
        print("[LevelUI] Old Level: " .. data.oldLevel .. ", New Level: " .. data.newLevel)
        print("[LevelUI] XP Gains: " .. #data.xpGains)

        self:ClearXPGains()

        currentLevelText.Text = "Level " .. data.oldLevel
        nextLevelText.Text = "Level " .. (data.oldLevel + 1)

        local initialProgress = self:CalculateProgress(data.oldXP, data.oldLevel)
        self:UpdateBarFill(initialProgress, false)

        self:ShowLevelBar()

        task.wait(0.5)

        local currentXP = data.oldXP
        local currentLevel = data.oldLevel

        for i, gain in ipairs(data.xpGains) do
                self:AddXPGainEntry(gain.amount, gain.reason)

                task.wait(GameConfig.LevelUI.XPGainDelay)

                local newXP, newLevel = self:AnimateXPGain(currentXP, currentLevel, gain.amount)
                currentXP = newXP
                currentLevel = newLevel
        end

        task.wait(GameConfig.LevelUI.DisplayTime)

        self:HideLevelBar()

        self.isShowing = false
        self.currentData = nil

        print("[LevelUI] Level up display complete")
end

function LevelUIController:Initialize()
        print("[LevelUI] Initializing...")

        levelBar.Visible = false

        print("[LevelUI] Connecting to ShowLevelUp RemoteEvent...")
        RemoteEvents.ShowLevelUp.OnClientEvent:Connect(function(data)
                print("[LevelUI] *** RECEIVED ShowLevelUp event! ***")
                print("[LevelUI] Data received:", data)

                if not data then
                        warn("[LevelUI] No data received!")
                        return
                end

                print("[LevelUI] Old Level:", data.oldLevel, "New Level:", data.newLevel)
                print("[LevelUI] Old XP:", data.oldXP, "New XP:", data.newXP)
                print("[LevelUI] XP Gains:", data.xpGains and #data.xpGains or 0)

                task.spawn(function()
                        self:DisplayLevelUp(data)
                end)
        end)

        print("[LevelUI] Initialized successfully! Listening for ShowLevelUp events...")
end

LevelUIController:Initialize()

return LevelUIController
