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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
					lastHitTime = tick()
				end
			end
		end
	end
end)

RemoteEvents.TNTTransfer.OnClientEvent:Connect(function(newIT)
	if newIT == player then
		print("[PVPClient] You are now IT!")
	else
		print("[PVPClient] " .. newIT.Name .. " is now IT!")
	end
end)

print("[PVPClient] PVP system initialized")
