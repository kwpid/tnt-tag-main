local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local lastHitTime = 0
local currentHighlight = nil
local armSwingAnimation = nil
local armSwingTrack = nil
local hitSound = nil

local function getCharacterFromMouse()
        local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {player.Character}
        
        local result = workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
        
        if result and result.Instance then
                local character = result.Instance:FindFirstAncestorOfClass("Model")
                if character and character:FindFirstChild("Humanoid") then
                        local targetPlayer = Players:GetPlayerFromCharacter(character)
                        if targetPlayer and targetPlayer ~= player then
                                return targetPlayer, character
                        end
                end
        end
        
        return nil, nil
end

local function loadArmSwingAnimation()
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        local animationsFolder = ReplicatedStorage:FindFirstChild("Animations")
        if animationsFolder then
                armSwingAnimation = animationsFolder:FindFirstChild("ArmSwing")
                if armSwingAnimation then
                        armSwingTrack = humanoid:LoadAnimation(armSwingAnimation)
                else
                        warn("[PVPClient] ArmSwing animation not found in ReplicatedStorage.Animations")
                end
        else
                warn("[PVPClient] Animations folder not found in ReplicatedStorage")
        end
        
        if not hitSound then
                hitSound = Instance.new("Sound")
                hitSound.SoundId = GameConfig.PVP.HitSoundId
                hitSound.Volume = 0.5
                hitSound.Parent = character:WaitForChild("Head")
        end
end

local function playArmSwing()
        if armSwingTrack then
                armSwingTrack:Play()
        end
end

local function playHitSound()
        if hitSound then
                hitSound:Play()
        end
end

local function highlightCharacter(character)
        if currentHighlight then
                currentHighlight:Destroy()
                currentHighlight = nil
        end
        
        local highlight = Instance.new("Highlight")
        highlight.FillColor = GameConfig.PVP.HighlightColor
        highlight.OutlineColor = GameConfig.PVP.HighlightColor
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = character
        
        currentHighlight = highlight
        
        task.delay(GameConfig.PVP.HighlightDuration, function()
                if highlight and highlight.Parent then
                        highlight:Destroy()
                end
                if currentHighlight == highlight then
                        currentHighlight = nil
                end
        end)
end

local function handleHit()
        if tick() - lastHitTime < GameConfig.PVP.HitCooldown then
                return
        end
        
        local targetPlayer, targetCharacter = getCharacterFromMouse()
        
        if targetPlayer and targetCharacter then
                local myCharacter = player.Character
                if not myCharacter then return end
                
                local myHRP = myCharacter:FindFirstChild("HumanoidRootPart")
                local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")
                
                if myHRP and targetHRP then
                        local distance = (myHRP.Position - targetHRP.Position).Magnitude
                        
                        if distance <= GameConfig.PVP.HitRange then
                                RemoteEvents.PlayerHit:FireServer(targetPlayer)
                                highlightCharacter(targetCharacter)
                                playArmSwing()
                                playHitSound()
                                lastHitTime = tick()
                        end
                end
        end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                handleHit()
        end
end)

UserInputService.TouchTap:Connect(function(touchPositions, gameProcessed)
        if gameProcessed then return end
        handleHit()
end)

RemoteEvents.TNTTransfer.OnClientEvent:Connect(function(newIT)
        if newIT == player then
                print("[PVPClient] You are now IT!")
        else
                print("[PVPClient] " .. newIT.Name .. " is now IT!")
        end
end)

player.CharacterAdded:Connect(loadArmSwingAnimation)
if player.Character then
        loadArmSwingAnimation()
end

print("[PVPClient] PVP system initialized")
