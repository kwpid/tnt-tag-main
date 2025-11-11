--[[
	CreateQueueGUI.lua
	Creates the Queue GUI programmatically
	Place this in StarterGui - it will run once when the player joins
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local queueGUI = Instance.new("ScreenGui")
queueGUI.Name = "QueueGUI"
queueGUI.ResetOnSpawn = false
queueGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
queueGUI.IgnoreGuiInset = false

-- Create Queue Button
local queueButton = Instance.new("TextButton")
queueButton.Name = "Button"
queueButton.Size = UDim2.new(0, 200, 0, 50)
queueButton.Position = UDim2.new(0.5, -100, 1, -70)
queueButton.AnchorPoint = Vector2.new(0.5, 1)
queueButton.Text = "QUEUE"
queueButton.Font = Enum.Font.GothamBold
queueButton.TextSize = 24
queueButton.TextColor3 = Color3.fromRGB(255, 255, 255)
queueButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
queueButton.BorderSizePixel = 0
queueButton.Parent = queueGUI

local queueButtonCorner = Instance.new("UICorner")
queueButtonCorner.CornerRadius = UDim.new(0.2, 0)
queueButtonCorner.Parent = queueButton

-- Create Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 450, 0, 350)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = queueGUI

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0.05, 0)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 3
mainStroke.Color = Color3.fromRGB(70, 70, 80)
mainStroke.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -40, 0, 60)
title.Position = UDim2.new(0, 20, 0, 15)
title.Text = "SELECT GAME MODE"
title.Font = Enum.Font.GothamBold
title.TextSize = 32
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Parent = mainFrame

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.Size = UDim2.new(0, 45, 0, 45)
closeButton.Position = UDim2.new(1, -55, 0, 15)
closeButton.Text = "✕"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 28
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0.3, 0)
closeCorner.Parent = closeButton

-- Casual Button
local casualButton = Instance.new("TextButton")
casualButton.Name = "Casual"
casualButton.Size = UDim2.new(0, 250, 0, 90)
casualButton.Position = UDim2.new(0.5, 0, 0.5, -20)
casualButton.AnchorPoint = Vector2.new(0.5, 0.5)
casualButton.Text = "CASUAL"
casualButton.Font = Enum.Font.GothamBold
casualButton.TextSize = 36
casualButton.TextColor3 = Color3.fromRGB(255, 255, 255)
casualButton.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
casualButton.BorderSizePixel = 0
casualButton.Parent = mainFrame

local casualCorner = Instance.new("UICorner")
casualCorner.CornerRadius = UDim.new(0.15, 0)
casualCorner.Parent = casualButton

-- Ranked Button
local rankedButton = Instance.new("TextButton")
rankedButton.Name = "Ranked"
rankedButton.Size = UDim2.new(0, 250, 0, 90)
rankedButton.Position = UDim2.new(0.5, 0, 0.5, 90)
rankedButton.AnchorPoint = Vector2.new(0.5, 0.5)
rankedButton.Text = "RANKED\n(COMING SOON)"
rankedButton.Font = Enum.Font.GothamBold
rankedButton.TextSize = 28
rankedButton.TextColor3 = Color3.fromRGB(200, 200, 200)
rankedButton.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
rankedButton.BorderSizePixel = 0
rankedButton.Parent = mainFrame

local rankedCorner = Instance.new("UICorner")
rankedCorner.CornerRadius = UDim.new(0.15, 0)
rankedCorner.Parent = rankedButton

-- Add to PlayerGui
queueGUI.Parent = playerGui

print("[QueueGUI] GUI created successfully!")
