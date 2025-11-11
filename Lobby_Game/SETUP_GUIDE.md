# Roblox Queue System - Setup Guide

## Overview
Professional matchmaking queue system with player progression, DataStore persistence, and leaderstats.

## Project Structure

```
Lobby_Game/
├── ReplicatedStorage/
│   ├── GameConfig.lua          # Main configuration
│   ├── QueueService.lua        # Queue utilities
│   ├── PlayerDataService.lua   # Data helpers
│   └── RemoteEvents.lua        # Client-server events
│
├── ServerScriptService/
│   ├── InitializeServer.lua        # Server startup
│   ├── QueueManager.lua            # Matchmaking logic
│   ├── PlayerDataManager.lua       # Player data & stats
│   └── MatchResultReceiver.lua     # Match result processor
│
└── StarterPlayer/StarterPlayerScripts/
    └── QueueUIController.lua       # Client UI controller

Actual_Game/
├── ServerScriptService/
│   ├── GameManager.lua             # Match manager
│   └── MatchResultHandler.lua      # Result processor
│
└── StarterPlayer/StarterPlayerScripts/
    └── MatchResultClient.lua       # Client result handler
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

**Lobby_Game - ReplicatedStorage:**
- GameConfig, QueueService, PlayerDataService, RemoteEvents

**Lobby_Game - ServerScriptService:**
- InitializeServer, QueueManager, PlayerDataManager, MatchResultReceiver

**Lobby_Game - StarterPlayerScripts:**
- QueueUIController

**Actual_Game - ServerScriptService:**
- GameManager, MatchResultHandler
- Copy GameConfig, RemoteEvents, PlayerDataService to ReplicatedStorage

**Actual_Game - StarterPlayerScripts:**
- MatchResultClient

### 5. Test
- Start test server with 2+ players
- Queue for match
- Complete match in Actual_Game
- Check stats update in Lobby_Game

## Player Stats & Leaderstats

### Visible on Player List
- **Wins** - Total wins
- **Level** - Player level
- **Win Streak** - Current win streak

### Tracked Data
- Wins, Losses
- Win Streak, Highest Win Streak
- Level, XP
- Ranked ELO
- Recent Matches (last 10)

See `PLAYER_DATA_GUIDE.md` for full details.

## Configuration

### Queue Settings
```lua
MinPlayersPerMatch = 2
MaxPlayersPerMatch = 10
MaxQueueTime = 120
MatchmakingInterval = 5
```

### Rewards
```lua
GameConfig.Rewards = {
    WinXP = 100,
    LossXP = 25,
    KillXP = 10,
}
```

### UI Settings
```lua
OpenDuration = 0.3
CameraZoomOffset = 10
BlurSize = 24
```

### Debug Mode
```lua
GameConfig.Debug = {
    Enabled = true,
    TestMode = true,  # Skip teleportation
}
```

## UI Features

**Queue Button States:**
- `QUEUE` - Default
- `^^^^^^` - Menu open
- `QUEUEING...` - Searching
- `CANCEL QUEUE` - Hover while queuing (red background)
- `MATCH FOUND!` - Match ready
- `TELEPORTING...` - Teleporting

**Animations:**
- Menu slides from top
- Background blur effect
- Camera FOV zoom
- Smooth transitions

## Match Flow

```
1. Players queue in Lobby_Game
2. Match found → Teleport to Actual_Game
3. GameManager tracks match
4. Match ends → Results sent to players
5. Stats updated in Lobby_Game
6. Players teleport back to lobby
```

## Actual_Game Setup

### Basic Match Example
```lua
local GameManager = require(ServerScriptService:WaitForChild("GameManager"))

-- Wait for players to load
task.wait(5)

-- Your game logic here
-- Track kills:
GameManager:RecordKill(killer, victim)

-- End match with winners
local winners = {player1, player2}
GameManager:EndGame(winners)
```

## Troubleshooting

**Players not teleporting:**
- Check SubPlace.PlaceId is correct
- Ensure sub-place is published
- Set TestMode = true to test without teleporting

**Stats not saving:**
- Check DataStore is enabled in game settings
- Look for errors in Output
- Verify PlayerDataManager is initialized

**Leaderstats not showing:**
- Ensure PlayerDataManager loads before players join
- Check InitializeServer runs first

## Next Steps

1. Build your game logic in Actual_Game
2. Call `GameManager:EndGame(winners)` when match ends
3. Customize XP rewards in GameConfig
4. Add custom sounds and UI styling
5. Test with real players
