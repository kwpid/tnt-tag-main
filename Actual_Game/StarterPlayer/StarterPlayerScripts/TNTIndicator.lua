local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainGUI = playerGui:WaitForChild("MainGUI")
local hasTntText = mainGUI:WaitForChild("HasTntTxt")

local hasTNT = false

local function updateTNTIndicator()
	if hasTNT then
		hasTntText.Text = "⚠️ YOU HAVE TNT! ⚠️"
		hasTntText.Visible = true
		hasTntText.TextColor3 = Color3.fromRGB(255, 50, 50)
	else
		hasTntText.Visible = false
	end
end

local function checkForTNT()
	local character = player.Character
	if not character then
		hasTNT = false
		updateTNTIndicator()
		return
	end
	
	local foundTNT = false
	for _, accessory in ipairs(character:GetChildren()) do
		if accessory:IsA("Accessory") and accessory.Name == "TNT" then
			foundTNT = true
			break
		end
	end
	
	hasTNT = foundTNT
	updateTNTIndicator()
end

RemoteEvents.TNTTransfer.OnClientEvent:Connect(function(newIT)
	if newIT == player then
		hasTNT = true
		print("[TNTIndicator] You have TNT!")
	else
		hasTNT = false
		print("[TNTIndicator] " .. newIT.Name .. " has TNT")
	end
	updateTNTIndicator()
end)

RemoteEvents.RoundStart.OnClientEvent:Connect(function()
	task.wait(0.5)
	checkForTNT()
end)

RemoteEvents.RoundEnd.OnClientEvent:Connect(function()
	hasTNT = false
	updateTNTIndicator()
end)

player.CharacterAdded:Connect(function()
	task.wait(1)
	checkForTNT()
end)

if player.Character then
	checkForTNT()
end

hasTntText.Visible = false

print("[TNTIndicator] TNT indicator initialized")
