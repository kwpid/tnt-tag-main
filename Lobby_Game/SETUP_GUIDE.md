# Roblox Queue System - Setup Guide

## Overview
Professional matchmaking and queue system for Roblox games with animated UI, region-based matchmaking, and sub-place teleportation.

## Project Structure

```
Lobby_Game/
├── ReplicatedStorage/
│   ├── GameConfig.lua          # Main configuration
│   ├── QueueService.lua        # Queue utilities
│   └── RemoteEvents.lua        # Client-server events
│
├── ServerScriptService/
│   ├── InitializeServer.lua    # Server startup
│   └── QueueManager.lua        # Matchmaking logic
│
└── StarterPlayer/StarterPlayerScripts/
    └── QueueUIController.lua   # Client UI controller
```

## Quick Start

### 1. Create Your Sub-Place
- Create a new place in Roblox Studio (Actual_Game)
- Publish it and copy the Place ID

### 2. Configure
Open `ReplicatedStorage/GameConfig.lua`:
```lua
GameConfig.SubPlace = {
    PlaceId = YOUR_ACTUAL_GAME_PLACE_ID
}
```

### 3. Create UI in StarterGui
Create a ScreenGui named "QueueGUI" with:
- **Button** (TextButton) - Main queue button
- **Main** (Frame) - Menu container
  - **Casual** (TextButton)
  - **Ranked** (TextButton)
  - **Close** (TextButton)

### 4. Copy Scripts to Roblox Studio

**ReplicatedStorage:**
- GameConfig, QueueService, RemoteEvents

**ServerScriptService:**
- InitializeServer, QueueManager

**StarterPlayer > StarterPlayerScripts:**
- QueueUIController

### 5. Test
- Start test server with 2+ players
- Click QUEUE → Select CASUAL
- Matchmaking starts automatically

## Configuration

### Queue Settings
```lua
MinPlayersPerMatch = 2
MaxPlayersPerMatch = 10
MaxQueueTime = 120
MatchmakingInterval = 5
```

### UI Settings
```lua
OpenDuration = 0.3
CameraZoomOffset = 10
BlurSize = 24
QueueDotsSpeed = 1.0
```

### Debug Mode
```lua
GameConfig.Debug = {
    Enabled = true,
    TestMode = true,  -- Skip teleportation
}
```

## UI Features

**Queue Button States:**
- `QUEUE` - Default, click to open menu
- `^^^^^^` - Menu is open
- `QUEUING.` / `QUEUING..` / `QUEUING...` - Animated while searching
- `CANCEL QUEUE` - Shows on hover while queuing
- `MATCH FOUND!` - Match ready (green)
- `TELEPORTING...` - Teleporting (yellow)

**Animations:**
- Menu slides from top
- Background blur effect
- Camera zoom
- Smooth transitions

**Interaction:**
- Click queue button while queuing to cancel
- Hover shows "CANCEL QUEUE" hint
- Close button or click queue button again to close menu

## Customization

**Colors:** Edit in your UI creation
**Sounds:** Change IDs in `GameConfig.Sounds`
**Timings:** Adjust in `GameConfig.UI`
**Regions:** Modify in `GameConfig.Queue.AvailableRegions`

## Troubleshooting

**Players not teleporting:**
- Check SubPlace.PlaceId is correct
- Ensure sub-place is published
- Set TestMode = true to test without teleporting

**UI not appearing:**
- Check QueueUIController is in StarterPlayerScripts
- Verify UI structure matches required hierarchy
- Check Output for errors

**Matchmaking not working:**
- Verify MinPlayersPerMatch setting
- Ensure enough players queuing
- Check Output for "[QueueManager]" logs

## Next Steps

1. Set up Actual_Game with game logic
2. Customize UI colors and styling
3. Add custom sound effects
4. Test with real players
5. Adjust matchmaking times as needed
