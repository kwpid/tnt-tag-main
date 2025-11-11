local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local player = Players.LocalPlayer

local function setupGhostMode()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	
	humanoid.Died:Connect(function()
		task.wait(2)
		
		local playerGui = player:WaitForChild("PlayerGui")
		local mainGUI = playerGui:FindFirstChild("MainGUI")
		
		if mainGUI then
			local backToLobby = mainGUI:FindFirstChild("BackToLobby")
			if backToLobby then
				backToLobby.Visible = true
			end
		end
		
		print("[GhostSystem] You are now a ghost. Press 'Back to Lobby' to return.")
	end)
end

player.CharacterAdded:Connect(setupGhostMode)
if player.Character then
	setupGhostMode()
end

RemoteEvents.ReturnToLobby.OnClientEvent:Connect(function()
	print("[GhostSystem] Returning to lobby...")
end)

print("[GhostSystem] Ghost system initialized")
