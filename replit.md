# Roblox Matchmaking Game Project

## Overview
A professional Roblox game featuring queue system, matchmaking, player progression with DataStore persistence, and multi-place teleportation. Players queue in Lobby_Game, get matched, teleport to Actual_Game for matches, and earn XP/levels/stats.

## Project Type
Roblox game development - Lua scripts for Roblox Studio.

## Structure

### Lobby_Game (Main Place)
```
Lobby_Game/
├── ReplicatedStorage/
│   ├── GameConfig.lua          # Configuration (queue, rewards, UI)
│   ├── QueueService.lua        # Queue utilities
│   ├── PlayerDataService.lua   # Data helper functions
│   └── RemoteEvents.lua        # Client-server communication
│
├── ServerScriptService/
│   ├── InitializeServer.lua        # Server initialization
│   ├── QueueManager.lua            # Matchmaking system
│   ├── PlayerDataManager.lua       # Player stats & DataStore
│   └── MatchResultReceiver.lua     # Receives match results
│
└── StarterPlayer/StarterPlayerScripts/
    └── QueueUIController.lua       # Client UI controller
```

### Actual_Game (Sub-Place)
```
Actual_Game/
├── ServerScriptService/
│   ├── GameManager.lua             # Match management
│   ├── MatchResultHandler.lua      # Result processing
│   └── PVPMain                     # Game logic (empty)
│
└── StarterPlayer/StarterPlayerScripts/
    └── MatchResultClient.lua       # Client result handler
```

## Key Features

### Queue System
- Region-based matchmaking
- Configurable player counts (2-10)
- Auto-matching after timeout
- Cancel queue functionality
- Test mode for development

### Player Progression
- **Stats:** Wins, Losses, Win Streak, Highest Win Streak
- **Leveling:** Level + XP system with configurable rewards
- **Ranked:** ELO rating (1000 start)
- **Match History:** Last 10 matches tracked
- **DataStore:** Auto-save on leave/shutdown

### Leaderstats (Visible on Player List)
- Wins
- Level
- Win Streak

### Professional UI
- Slide-in animation from top
- Background blur (24px)
- Camera FOV zoom
- Queue button states with hover effects
- Red "CANCEL QUEUE" hover indicator
- Sound effects

### Multi-Place System
- Queue in Lobby_Game
- Teleport to Actual_Game for matches
- Results sent back to Lobby_Game
- Stats updated and saved
- Auto-teleport back to lobby

## Configuration

### GameConfig.lua Settings
```lua
SubPlace.PlaceId = 0  # SET TO YOUR ACTUAL_GAME ID

Queue:
- MinPlayersPerMatch: 2
- MaxPlayersPerMatch: 10
- MaxQueueTime: 120s
- MatchmakingInterval: 5s

Rewards:
- WinXP: 100
- LossXP: 25
- KillXP: 10

UI:
- OpenDuration: 0.3s
- CameraZoomOffset: 10 (FOV)
- BlurSize: 24

Debug:
- TestMode: true (skip teleportation)
```

## Usage

### For Development in Replit
1. Edit Lua files here
2. Copy to Roblox Studio when ready
3. Test in Roblox Studio

### For Roblox Studio Setup
1. Create sub-place, get Place ID
2. Update `GameConfig.SubPlace.PlaceId`
3. Copy all scripts to appropriate locations
4. Create UI in StarterGui (QueueGUI)
5. Test with 2+ players
6. See `SETUP_GUIDE.md` and `PLAYER_DATA_GUIDE.md`

## Technical Details

### Language & Platform
- **Language:** Lua (Roblox Luau)
- **Platform:** Roblox Studio/Engine
- **Client-Server:** RemoteEvents
- **UI:** TweenService animations
- **Data:** DataStoreService

### Core Systems
- **Queue Management:** Server-side matchmaking loops
- **Player Data:** DataStore with auto-save
- **Match Results:** Cross-place communication
- **Leaderstats:** Auto-updated on stat changes

## Recent Changes
- **2025-11-11:** Initial GitHub import
- **2025-11-11:** Queue system with matchmaking
- **2025-11-11:** Animated UI (slide, blur, FOV zoom)
- **2025-11-11:** Sound effects and hover interactions
- **2025-11-11:** Player data system with DataStore
- **2025-11-11:** Leaderstats (Wins, Level, Win Streak)
- **2025-11-11:** XP/Level progression system
- **2025-11-11:** Match result handling across places
- **2025-11-11:** Cancel queue with red hover indicator

## User Preferences
None specified.

## Important Notes

### Must Configure
- Set `GameConfig.SubPlace.PlaceId` to Actual_Game ID
- Publish sub-place before testing teleportation
- Enable DataStore in game settings

### Testing
- Use TestMode = true to test without teleportation
- Requires 2+ players for matchmaking
- Check Output for debug messages
- Verify leaderstats appear on join
- Test data persistence (leave/rejoin)

### Customization
- XP rewards in `GameConfig.Rewards`
- UI timings in `GameConfig.UI`
- Queue settings in `GameConfig.Queue`
- Sounds in `GameConfig.Sounds`

## Architecture

### Design Patterns
- Module pattern for shared code
- Observer pattern for status updates
- State machine for queue states
- Event-driven client-server
- DataStore abstraction layer

### Code Quality
- Minimal comments, clean code
- Error handling and validation
- Professional naming conventions
- Separation of concerns
- Auto-save data management

### Data Flow
```
Player Join → Load Data → Create Leaderstats
Queue → Match → Teleport → Play → Results
Results → Update Stats → Save Data → Return to Lobby
```

## Files for Roblox Studio

**Lobby_Game:** All scripts in corresponding Roblox locations
**Actual_Game:** GameManager, result handlers, shared modules

See `SETUP_GUIDE.md` for exact file placement.

## Main Entry Points
- **Server:** InitializeServer.lua
- **Client:** QueueUIController.lua
- **Config:** GameConfig.lua
- **Data:** PlayerDataManager.lua

## Debug Output
- `[Server]` - Initialization
- `[QueueManager]` - Matchmaking
- `[QueueUI]` - Client UI
- `[PlayerData]` - Data operations
- `[GameManager]` - Match management
- `[MatchResultReceiver]` - Result processing

## DataStore
- **Name:** PlayerData_v1
- **Key:** Player_{UserId}
- **Auto-save:** On leave, shutdown, after matches
