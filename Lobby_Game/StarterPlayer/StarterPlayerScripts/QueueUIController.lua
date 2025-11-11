local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local QueueService = require(ReplicatedStorage:WaitForChild("QueueService"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local queueGUI = playerGui:WaitForChild("QueueGUI")
local mainFrame = queueGUI:WaitForChild("Main")
local queueButton = queueGUI:WaitForChild("Button")
local casualButton = mainFrame:WaitForChild("Casual")
local rankedButton = mainFrame:WaitForChild("Ranked")
local closeButton = mainFrame:WaitForChild("Close")

local QueueUIController = {
        isOpen = false,
        isQueued = false,
        currentStatus = QueueService.QueueStatus.NotQueued,
        originalCameraZoom = 0,
        blur = nil,
        sounds = {}
}

function QueueUIController:CreateBlur()
        self.blur = Lighting:FindFirstChild("QueueBlur")
        if not self.blur then
                self.blur = Instance.new("BlurEffect")
                self.blur.Name = "QueueBlur"
                self.blur.Size = 0
                self.blur.Parent = Lighting
        end
end

function QueueUIController:CreateSounds()
        local soundFolder = SoundService:FindFirstChild("QueueSounds")
        if not soundFolder then
                soundFolder = Instance.new("Folder")
                soundFolder.Name = "QueueSounds"
                soundFolder.Parent = SoundService
        end
        
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
        
        self.sounds.Hover = createSound("Hover", GameConfig.Sounds.ButtonHover, GameConfig.Sounds.UIVolume)
        self.sounds.Click = createSound("Click", GameConfig.Sounds.ButtonClick, GameConfig.Sounds.UIVolume)
        self.sounds.QueueJoin = createSound("QueueJoin", GameConfig.Sounds.QueueJoin, GameConfig.Sounds.NotificationVolume)
        self.sounds.QueueLeave = createSound("QueueLeave", GameConfig.Sounds.QueueLeave, GameConfig.Sounds.NotificationVolume)
        self.sounds.MatchFound = createSound("MatchFound", GameConfig.Sounds.MatchFound, GameConfig.Sounds.NotificationVolume)
end

function QueueUIController:PlaySound(soundName)
        local sound = self.sounds[soundName]
        if sound then
                sound:Play()
        end
end

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

function QueueUIController:OpenUI()
        if self.isOpen then return end
        self.isOpen = true
        
        self:PlaySound("Click")
        
        mainFrame.Visible = true
        
        if GameConfig.UI.BlurEnabled then
                TweenService:Create(self.blur, TweenInfo.new(GameConfig.UI.BlurTransitionTime), {
                        Size = GameConfig.UI.BlurSize
                }):Play()
        end
        
        mainFrame.Position = UDim2.new(0.265, 0, -0.5, 0)
        TweenService:Create(mainFrame, TweenInfo.new(
                GameConfig.UI.OpenDuration,
                GameConfig.UI.OpenEasingStyle,
                GameConfig.UI.OpenEasingDirection
        ), {
                Position = UDim2.new(0.265, 0, 0.069, 0)
        }):Play()
        
        self:ZoomCamera(true)
        queueButton.Text = "^^^^^^"
end

function QueueUIController:CloseUI()
        if not self.isOpen then return end
        self.isOpen = false
        
        self:PlaySound("Click")
        
        if GameConfig.UI.BlurEnabled then
                TweenService:Create(self.blur, TweenInfo.new(GameConfig.UI.BlurTransitionTime), {
                        Size = 0
                }):Play()
        end
        
        local tween = TweenService:Create(mainFrame, TweenInfo.new(
                GameConfig.UI.CloseDuration,
                GameConfig.UI.CloseEasingStyle,
                GameConfig.UI.CloseEasingDirection
        ), {
                Position = UDim2.new(0.265, 0, -0.5, 0)
        })
        
        tween.Completed:Connect(function()
                mainFrame.Visible = false
        end)
        
        tween:Play()
        
        self:ZoomCamera(false)
        self:UpdateQueueButtonText()
end

function QueueUIController:ZoomCamera(zoomIn)
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        if zoomIn then
                self.originalCameraZoom = humanoid.CameraOffset.Z
                TweenService:Create(humanoid, TweenInfo.new(GameConfig.UI.CameraTransitionTime), {
                        CameraOffset = Vector3.new(0, 0, GameConfig.UI.CameraZoomOffset)
                }):Play()
        else
                TweenService:Create(humanoid, TweenInfo.new(GameConfig.UI.CameraTransitionTime), {
                        CameraOffset = Vector3.new(0, 0, self.originalCameraZoom)
                }):Play()
        end
end

function QueueUIController:StartDotAnimation()
        queueButton.Text = "QUEUEING..."
end

function QueueUIController:StopDotAnimation()
end

function QueueUIController:UpdateQueueButtonText()
        if self.isOpen then
                queueButton.Text = "^^^^^^"
        elseif self.currentStatus == QueueService.QueueStatus.Queuing then
                queueButton.Text = "QUEUEING..."
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

function QueueUIController:JoinQueue(mode)
        if self.isQueued then return end
        
        self.isQueued = true
        self.currentStatus = QueueService.QueueStatus.Queuing
        
        self:CloseUI()
        self:PlaySound("QueueJoin")
        self:StartDotAnimation()
        
        RemoteEvents.QueueJoin:FireServer(mode, GameConfig.Queue.DefaultRegion)
        
        print("[QueueUI] Joined " .. mode .. " queue")
end

function QueueUIController:LeaveQueue()
        if not self.isQueued then return end
        
        self.isQueued = false
        self.currentStatus = QueueService.QueueStatus.NotQueued
        
        self:PlaySound("QueueLeave")
        self:StopDotAnimation()
        self:UpdateQueueButtonText()
        
        RemoteEvents.QueueLeave:FireServer()
        
        print("[QueueUI] Left queue")
end

function QueueUIController:Initialize()
        print("[QueueUI] Initializing...")
        
        self:CreateBlur()
        self:CreateSounds()
        
        self:AddHoverEffect(casualButton, Color3.fromRGB(70, 220, 120), Color3.fromRGB(50, 200, 100))
        self:AddHoverEffect(closeButton, Color3.fromRGB(220, 70, 70), Color3.fromRGB(200, 50, 50))
        
        queueButton.MouseEnter:Connect(function()
                if self.isQueued then
                        local originalText = queueButton.Text
                        queueButton.Text = "CANCEL QUEUE"
                        queueButton.MouseLeave:Once(function()
                                if self.isQueued then
                                        self:UpdateQueueButtonText()
                                end
                        end)
                else
                        self:PlaySound("Hover")
                end
        end)
        
        queueButton.MouseButton1Click:Connect(function()
                if self.isQueued then
                        self:LeaveQueue()
                else
                        if self.isOpen then
                                self:CloseUI()
                        else
                                self:OpenUI()
                        end
                end
        end)
        
        closeButton.MouseButton1Click:Connect(function()
                self:CloseUI()
        end)
        
        casualButton.MouseButton1Click:Connect(function()
                self:PlaySound("Click")
                self:JoinQueue(QueueService.QueueMode.Casual)
        end)
        
        rankedButton.MouseButton1Click:Connect(function()
                print("[QueueUI] Ranked mode not yet available")
        end)
        
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
        
        RemoteEvents.MatchFound.OnClientEvent:Connect(function()
                print("[QueueUI] Match found! Preparing to teleport...")
                self:PlaySound("MatchFound")
        end)
        
        print("[QueueUI] Initialized successfully!")
end

QueueUIController:Initialize()

return QueueUIController
