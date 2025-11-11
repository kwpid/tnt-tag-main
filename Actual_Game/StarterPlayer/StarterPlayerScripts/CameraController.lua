local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local cameraMode = "Third"
local THIRD_PERSON_DISTANCE = 10

local function setCameraMode(mode)
	cameraMode = mode
	
	if mode == "First" then
		player.CameraMaxZoomDistance = 0.5
		player.CameraMinZoomDistance = 0.5
		player.CameraMode = Enum.CameraMode.LockFirstPerson
		print("[CameraController] Switched to First Person")
	elseif mode == "Third" then
		player.CameraMaxZoomDistance = THIRD_PERSON_DISTANCE
		player.CameraMinZoomDistance = THIRD_PERSON_DISTANCE
		player.CameraMode = Enum.CameraMode.Classic
		print("[CameraController] Switched to Third Person")
	end
end

local function toggleCameraMode()
	if cameraMode == "Third" then
		setCameraMode("First")
	else
		setCameraMode("Third")
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.Q then
		toggleCameraMode()
	end
end)

player.CharacterAdded:Connect(function()
	task.wait(0.1)
	setCameraMode(cameraMode)
end)

setCameraMode("Third")

print("[CameraController] Camera controller initialized (Press Q to switch between First/Third Person)")
