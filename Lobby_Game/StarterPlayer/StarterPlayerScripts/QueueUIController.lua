--[[
	QueueUIController.lua
	Client-side UI controller for queue system
	Handles animations, sounds, camera effects, and user interactions
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- Wait for modules and GUI
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local QueueService = require(ReplicatedStorage:WaitForChild("QueueService"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local queueGUI = playerGui:WaitForChild("QueueGUI")
local mainFrame = queueGUI:WaitForChild("Main")
local queueButton = queueGUI:WaitForChild("Button")
local casualButton = mainFrame:WaitForChild("Casual")
local rankedButton = mainFrame:WaitForChild("Ranked")
local closeButton = mainFrame:WaitForChild("Close")

-- Controller state
local QueueUIController = {
	isOpen = false,
	isQueued = false,
	currentStatus = QueueService.QueueStatus.NotQueued,
	originalCameraZoom = 0,
	blur = nil,
	sounds = {},
	dotAnimation = nil
}

-- Initialize blur effect
function QueueUIController:CreateBlur()
	self.blur = Lighting:FindFirstChild("QueueBlur")
	if not self.blur then
		self.blur = Instance.new("BlurEffect")
		self.blur.Name = "QueueBlur"
		self.blur.Size = 0
		self.blur.Parent = Lighting
	end
end

-- Initialize sounds
function QueueUIController:CreateSounds()
	local soundFolder = SoundService:FindFirstChild("QueueSounds")
	if not soundFolder then
		soundFolder = Instance.new("Folder")
		soundFolder.Name = "QueueSounds"
		soundFolder.Parent = SoundService
	end
	
	-- Helper to create sound
	local function createSound(name, soundId, volume)
		local sound = soundFolder:FindFirstChild(name)
		if not sound then
			sound = Instance.new("Sound")
			sound.Name = name
			sound.SoundId = soundId
			sound.Volume = volume
			sound.Parent = soundFolder
		end
		return sound
	end
	
	-- Create all sounds
	self.sounds.Hover = createSound("Hover", GameConfig.Sounds.ButtonHover, GameConfig.Sounds.UIVolume)
	self.sounds.Click = createSound("Click", GameConfig.Sounds.ButtonClick, GameConfig.Sounds.UIVolume)
	self.sounds.QueueJoin = createSound("QueueJoin", GameConfig.Sounds.QueueJoin, GameConfig.Sounds.NotificationVolume)
	self.sounds.QueueLeave = createSound("QueueLeave", GameConfig.Sounds.QueueLeave, GameConfig.Sounds.NotificationVolume)
	self.sounds.MatchFound = createSound("MatchFound", GameConfig.Sounds.MatchFound, GameConfig.Sounds.NotificationVolume)
end

-- Play sound
function QueueUIController:PlaySound(soundName)
	local sound = self.sounds[soundName]
	if sound then
		sound:Play()
	end
end

-- Button hover effect
function QueueUIController:AddHoverEffect(button, hoverColor, normalColor)
	local originalColor = normalColor or button.BackgroundColor3
	
	button.MouseEnter:Connect(function()
		self:PlaySound("Hover")
		TweenService:Create(button, TweenInfo.new(0.2), {
			BackgroundColor3 = hoverColor or originalColor:Lerp(Color3.fromRGB(255, 255, 255), 0.2)
		}):Play()
	end)
	
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {
			BackgroundColor3 = originalColor
		}):Play()
	end)
end

-- Open UI
function QueueUIController:OpenUI()
	if self.isOpen then return end
	self.isOpen = true
	
	-- Play sound
	self:PlaySound("Click")
	
	-- Show frame
	mainFrame.Visible = true
	
	-- Animate blur
	if GameConfig.UI.BlurEnabled then
		TweenService:Create(self.blur, TweenInfo.new(GameConfig.UI.BlurTransitionTime), {
			Size = GameConfig.UI.BlurSize
		}):Play()
	end
	
	-- Animate frame scale (small to normal)
	mainFrame.Size = UDim2.new(0, 450 * GameConfig.UI.ClosedScale, 0, 350 * GameConfig.UI.ClosedScale)
	TweenService:Create(mainFrame, TweenInfo.new(
		GameConfig.UI.OpenDuration,
		GameConfig.UI.OpenEasingStyle,
		GameConfig.UI.OpenEasingDirection
	), {
		Size = UDim2.new(0, 450, 0, 350)
	}):Play()
	
	-- Zoom camera
	self:ZoomCamera(true)
	
	-- Change queue button text
	queueButton.Text = "^^^^^^"
end

-- Close UI
function QueueUIController:CloseUI()
	if not self.isOpen then return end
	self.isOpen = false
	
	-- Play sound
	self:PlaySound("Click")
	
	-- Animate blur
	if GameConfig.UI.BlurEnabled then
		TweenService:Create(self.blur, TweenInfo.new(GameConfig.UI.BlurTransitionTime), {
			Size = 0
		}):Play()
	end
	
	-- Animate frame scale (normal to small)
	local tween = TweenService:Create(mainFrame, TweenInfo.new(
		GameConfig.UI.CloseDuration,
		GameConfig.UI.CloseEasingStyle,
		GameConfig.UI.CloseEasingDirection
	), {
		Size = UDim2.new(0, 450 * GameConfig.UI.ClosedScale, 0, 350 * GameConfig.UI.ClosedScale)
	})
	
	tween.Completed:Connect(function()
		mainFrame.Visible = false
	end)
	
	tween:Play()
	
	-- Reset camera
	self:ZoomCamera(false)
	
	-- Update queue button text
	self:UpdateQueueButtonText()
end

-- Zoom camera
function QueueUIController:ZoomCamera(zoomIn)
	local character = player.Character
	if not character then return end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	if zoomIn then
		self.originalCameraZoom = humanoid.CameraOffset.Z
		TweenService:Create(humanoid, TweenInfo.new(GameConfig.UI.CameraTransitionTime), {
			CameraOffset = Vector3.new(0, 0, -GameConfig.UI.CameraZoomOffset)
		}):Play()
	else
		TweenService:Create(humanoid, TweenInfo.new(GameConfig.UI.CameraTransitionTime), {
			CameraOffset = Vector3.new(0, 0, self.originalCameraZoom)
		}):Play()
	end
end

-- Start queue button dot animation
function QueueUIController:StartDotAnimation()
	if self.dotAnimation then
		self.dotAnimation:Disconnect()
	end
	
	local dots = {".", "..", "..."}
	local index = 1
	
	self.dotAnimation = RunService.Heartbeat:Connect(function()
		task.wait(GameConfig.UI.QueueDotsSpeed)
		queueButton.Text = "QUEUING" .. dots[index]
		index = index + 1
		if index > #dots then
			index = 1
		end
	end)
end

-- Stop dot animation
function QueueUIController:StopDotAnimation()
	if self.dotAnimation then
		self.dotAnimation:Disconnect()
		self.dotAnimation = nil
	end
end

-- Update queue button text based on status
function QueueUIController:UpdateQueueButtonText()
	if self.isOpen then
		queueButton.Text = "^^^^^^"
	elseif self.currentStatus == QueueService.QueueStatus.Queuing then
		-- Dot animation handled separately
	elseif self.currentStatus == QueueService.QueueStatus.MatchFound then
		queueButton.Text = "MATCH FOUND!"
		queueButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
	elseif self.currentStatus == QueueService.QueueStatus.Teleporting then
		queueButton.Text = "TELEPORTING..."
		queueButton.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
	else
		queueButton.Text = "QUEUE"
		queueButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
	end
end

-- Join queue
function QueueUIController:JoinQueue(mode)
	if self.isQueued then return end
	
	self.isQueued = true
	self.currentStatus = QueueService.QueueStatus.Queuing
	
	-- Close UI
	self:CloseUI()
	
	-- Play sound
	self:PlaySound("QueueJoin")
	
	-- Start dot animation
	self:StartDotAnimation()
	
	-- Send to server
	RemoteEvents.QueueJoin:FireServer(mode, GameConfig.Queue.DefaultRegion)
	
	print("[QueueUI] Joined " .. mode .. " queue")
end

-- Leave queue
function QueueUIController:LeaveQueue()
	if not self.isQueued then return end
	
	self.isQueued = false
	self.currentStatus = QueueService.QueueStatus.NotQueued
	
	-- Play sound
	self:PlaySound("QueueLeave")
	
	-- Stop dot animation
	self:StopDotAnimation()
	
	-- Update button
	self:UpdateQueueButtonText()
	
	-- Send to server
	RemoteEvents.QueueLeave:FireServer()
	
	print("[QueueUI] Left queue")
end

-- Initialize
function QueueUIController:Initialize()
	print("[QueueUI] Initializing...")
	
	-- Create effects
	self:CreateBlur()
	self:CreateSounds()
	
	-- Set up button hover effects
	self:AddHoverEffect(queueButton)
	self:AddHoverEffect(casualButton, Color3.fromRGB(70, 220, 120), Color3.fromRGB(50, 200, 100))
	self:AddHoverEffect(closeButton, Color3.fromRGB(220, 70, 70), Color3.fromRGB(200, 50, 50))
	
	-- Queue button click
	queueButton.MouseButton1Click:Connect(function()
		if self.isQueued then
			-- Leave queue
			self:LeaveQueue()
		else
			-- Toggle UI
			if self.isOpen then
				self:CloseUI()
			else
				self:OpenUI()
			end
		end
	end)
	
	-- Close button click
	closeButton.MouseButton1Click:Connect(function()
		self:CloseUI()
	end)
	
	-- Casual button click
	casualButton.MouseButton1Click:Connect(function()
		self:PlaySound("Click")
		self:JoinQueue(QueueService.QueueMode.Casual)
	end)
	
	-- Ranked button click (disabled for now)
	rankedButton.MouseButton1Click:Connect(function()
		print("[QueueUI] Ranked mode not yet available")
	end)
	
	-- Listen for queue status updates from server
	RemoteEvents.QueueStatusUpdate.OnClientEvent:Connect(function(status)
		self.currentStatus = status
		
		if status == QueueService.QueueStatus.NotQueued then
			self.isQueued = false
			self:StopDotAnimation()
		elseif status == QueueService.QueueStatus.Queuing then
			self.isQueued = true
		elseif status == QueueService.QueueStatus.MatchFound then
			self:StopDotAnimation()
			self:PlaySound("MatchFound")
		end
		
		self:UpdateQueueButtonText()
	end)
	
	-- Listen for match found
	RemoteEvents.MatchFound.OnClientEvent:Connect(function()
		print("[QueueUI] Match found! Preparing to teleport...")
		self:PlaySound("MatchFound")
	end)
	
	print("[QueueUI] Initialized successfully!")
end

-- Start the controller
QueueUIController:Initialize()

return QueueUIController
