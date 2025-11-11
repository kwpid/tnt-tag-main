--[[
	GameConfig.lua
	Main configuration module for the game
	Contains all settings that can be easily modified
]]

local GameConfig = {}

-- Sub-Place Configuration
GameConfig.SubPlace = {
	PlaceId = 0, -- REPLACE WITH YOUR ACTUAL_GAME PLACE ID
	AccessCode = nil -- Optional access code for reserved servers
}

-- Queue Settings
GameConfig.Queue = {
	-- Matchmaking
	MinPlayersPerMatch = 2,
	MaxPlayersPerMatch = 10,
	DefaultQueueMode = "Casual", -- "Casual" or "Ranked"
	
	-- Timing (in seconds)
	MaxQueueTime = 120, -- Max time before forcing a match
	MatchmakingInterval = 5, -- How often to check for matches
	QueueUpdateInterval = 1, -- How often to update queue status
	
	-- Regions
	AvailableRegions = {
		"NA-East",
		"NA-West", 
		"EU",
		"Asia",
		"Auto" -- Auto-detect based on ping
	},
	DefaultRegion = "Auto",
	
	-- Ranked Settings (for future use)
	RankedEnabled = false,
	RankedMMRRange = 200, -- MMR difference allowed in matches
}

-- UI Settings
GameConfig.UI = {
	-- Animation Durations (in seconds)
	OpenDuration = 0.3,
	CloseDuration = 0.25,
	
	-- Animation Styles
	OpenEasingStyle = Enum.EasingStyle.Back,
	OpenEasingDirection = Enum.EasingDirection.Out,
	CloseEasingStyle = Enum.EasingStyle.Back,
	CloseEasingDirection = Enum.EasingDirection.In,
	
	-- Scale Settings
	ClosedScale = 0.3, -- Scale when closed (for animation)
	OpenScale = 1, -- Normal scale
	
	-- Camera Settings
	CameraZoomOffset = 10, -- How much to zoom in
	CameraTransitionTime = 0.4,
	
	-- Blur Settings
	BlurEnabled = true,
	BlurSize = 24,
	BlurTransitionTime = 0.3,
	
	-- Queue Button Animation
	QueueDotsSpeed = 0.5, -- Time per dot animation cycle
}

-- Sound Settings
GameConfig.Sounds = {
	-- Sound IDs (REPLACE WITH YOUR ACTUAL SOUND IDs FROM ROBLOX LIBRARY)
	ButtonHover = "rbxassetid://10066931761", -- Default UI hover sound
	ButtonClick = "rbxassetid://10066936129", -- Default UI click sound
	QueueJoin = "rbxassetid://10066931761",
	QueueLeave = "rbxassetid://10066936129",
	MatchFound = "rbxassetid://10066936129",
	
	-- Volume Settings
	UIVolume = 0.5,
	NotificationVolume = 0.7,
}

-- Debug Settings
GameConfig.Debug = {
	Enabled = true, -- Set to false in production
	PrintQueueStatus = true,
	PrintMatchmaking = true,
	TestMode = false, -- Skip teleportation in test mode
}

-- Game Modes
GameConfig.GameModes = {
	Casual = {
		Enabled = true,
		Name = "Casual",
		Description = "Play for fun!",
		MinPlayers = 2,
		MaxPlayers = 10,
	},
	Ranked = {
		Enabled = false, -- Not implemented yet
		Name = "Ranked",
		Description = "Compete for rank!",
		MinPlayers = 2,
		MaxPlayers = 10,
	}
}

return GameConfig
