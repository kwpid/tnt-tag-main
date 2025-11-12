# Roblox TNT Tag Game Project

## Overview
A professional Roblox game featuring queue system, matchmaking, player progression with DataStore persistence, and multi-place teleportation. Players queue in Lobby_Game, get matched, and teleport to Actual_Game to play TNT Tag - a fast-paced elimination game where players try to avoid being "IT" when the TNT explodes. The last player standing wins!

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
├── ReplicatedStorage/
│   ├── GameConfig.lua              # TNT Tag game configuration
│   ├── RemoteEvents.lua            # Client-server events
│   └── PlayerDataService.lua       # Data helper functions
│
├── ServerScriptService/
│   ├── GameManager.lua             # TNT Tag match management
│   ├── PVPMain.lua                 # TNT Tag game logic
│   └── MatchResultHandler.lua      # Result processing
│
├── StarterPlayer/StarterPlayerScripts/
│   ├── MatchResultClient.lua       # Client result handler
│   ├── PVPClient.lua               # PVP hitbox system with arm swing
│   ├── GhostSystem.lua             # Ghost mode & Back to Lobby
│   ├── RoundUI.lua                 # Round timer UI controller
│   ├── TNTIndicator.lua            # TNT indicator UI controller
│   └── CameraController.lua        # First/Third person camera toggle
│
└── StarterGui/MainGUI/
    └── BackToLobby (TextButton)    # Return to lobby UI
        └── BackToLobby.lua         # UI handler script
```

## Key Features

### TNT Tag Gameplay
- **Game Mode:** Elimination-style TNT Tag
- **Max Players:** 25 per server
- **Round Timer:** 45 seconds until TNT explodes (displayed on-screen)
- **PVP System:** Click to hit players (arm swing animation, knockback, red highlight)
- **TNT Transfer:** Hit other players to pass the TNT
- **TNT Indicator:** On-screen warning when you have TNT
- **Win Condition:** Last player alive wins
- **Ghost Mode:** Dead players can spectate or return to lobby
- **Map System:** Random map selection from ServerStorage.Maps
- **Camera System:** Press Q to switch between First/Third person (fixed 10 stud distance)

### Queue System
- Region-based matchmaking
- Configurable player counts (2-25)
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
- **2025-11-11:** TNT Tag game implementation (PVP system, TNT mechanics)
- **2025-11-11:** Team system (Lobby/Game) with auto-assignment
- **2025-11-11:** Map loading and player spawning system
- **2025-11-11:** Ghost system with Back to Lobby UI
- **2025-11-11:** Round management and game flow
- **2025-11-11:** Arm swing animation on player hits
- **2025-11-11:** Round timer UI (countdown display)
- **2025-11-11:** TNT indicator UI (shows when player has TNT)
- **2025-11-11:** Camera controller (Q to switch First/Third person)
- **2025-11-12:** Added 15s game start intermission timer before first round
- **2025-11-12:** Added hover size tween effect to Casual/Ranked buttons (1.05x scale)
- **2025-11-12:** Fixed critical game start bug - game now waits for players to teleport in before starting
- **2025-11-12:** Implemented proper game lifecycle with countdown/cleanup state management
- **2025-11-12:** Added cleanupInProgress flag to prevent race conditions during match cleanup
- **2025-11-12:** Fixed EndGame to only teleport game participants, preserving lobby joiners for next match

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

### Lobby_Game
- **Server:** InitializeServer.lua
- **Client:** QueueUIController.lua
- **Config:** GameConfig.lua
- **Data:** PlayerDataManager.lua

### Actual_Game (TNT Tag)
- **Server:** GameManager.lua
- **Game Logic:** PVPMain.lua
- **Config:** GameConfig.lua (Actual_Game)
- **Client:** PVPClient.lua, GhostSystem.lua

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
