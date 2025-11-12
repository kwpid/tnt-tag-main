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
│   ├── GameConfig.lua              # TNT Tag game configuration (with DataStore version)
│   ├── RemoteEvents.lua            # Client-server events
│   ├── PlayerDataService.lua       # Data helper functions
│   └── TimeSync.lua                # RTT-based time synchronization
│
├── ServerScriptService/
│   ├── GameManager.lua             # TNT Tag match management
│   ├── PVPServer.lua               # TNT Tag game logic (server-side hit effects)
│   ├── PlayerDataManager.lua       # Player data loading & leaderstats
│   ├── MatchResultHandler.lua      # Result processing
│   └── TimeSyncServer.lua          # Time sync RemoteFunction handler
│
├── StarterPlayer/StarterPlayerScripts/
│   ├── MatchResultClient.lua       # Client result handler
│   ├── PVPClient.lua               # PVP hitbox system with arm swing
│   ├── GhostSystem.lua             # Ghost mode & Back to Lobby
│   ├── RoundUI.lua                 # Round timer UI controller
│   ├── TNTIndicator.lua            # TNT indicator UI controller
│   ├── CameraController.lua        # First/Third person camera toggle
│   └── EndGameUI.lua               # Winner announcement & countdown
│
└── StarterGui/MainGUI/
    └── BackToLobby (TextButton)    # Return to lobby UI
        └── BackToLobby.lua         # UI handler script
```

## Key Features

### TNT Tag Gameplay
- **Game Mode:** Elimination-style TNT Tag
- **Max Players:** 25 per server
- **Round Timer:** 45 seconds until TNT explodes (synchronized countdown)
- **Time Sync:** RTT-based client-server clock synchronization for accurate timers
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
- **Time Sync:** RTT-based clock offset measurement for synchronized countdowns

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
- **2025-11-12:** Fixed TNT assignment - now fires TNTTransfer event when TNT is given at round start
- **2025-11-12:** Improved PVP knockback system - increased knockback duration to 0.2s for better visibility
- **2025-11-12:** Fixed return to lobby UI - BackToLobby button now shows for all players at game end (including winner)
- **2025-11-12:** Fixed teleport destination - added LobbyPlaceId (76587714865691) to properly return players to lobby
- **2025-11-12:** Restructured game flow - map loads during intermission while players wait in Lobby team
- **2025-11-12:** Lowered hit cooldown to 0.3s to allow for combo attacks
- **2025-11-12:** Added hit sound effect (rbxassetid://8595980577) when players hit each other
- **2025-11-12:** Added mobile support - TouchTap and Touch input detection for hitting players
- **2025-11-12:** Redesigned stats system - uses TeleportData to send match results from Actual_Game to Lobby
- **2025-11-12:** Lobby server now processes match results via TeleportData on PlayerAdded
- **2025-11-12:** Added DataStore version tag system (GameConfig.DataStore) for easy data resets
- **2025-11-12:** Created PlayerDataManager in Actual_Game - leaderstats now show during matches
- **2025-11-12:** Fixed match result persistence - TeleportData is properly validated and processed on lobby join
- **2025-11-12:** Moved hit effects to server-side - highlight and sound now consistent across all clients
- **2025-11-12:** Added winner announcement UI with player name display
- **2025-11-12:** Added "Returning to lobby in [X]s" countdown display after match ends
- **2025-11-12:** Ensured 1v1 TNT explosion only kills the holder, not both players
- **2025-11-12:** Added proper UI cleanup on teleport and countdown completion
- **2025-11-12:** Refactored PVP system to use PVPServer.lua and PVPClient.lua
- **2025-11-12:** Fixed round timing - StartRound() is now non-blocking for better game flow
- **2025-11-12:** Removed duplicate InitializeAlivePlayers() calls to prevent dead players from resurrecting
- **2025-11-12:** Added 10s TNT delay for first round only (allows players to spread out before TNT is given)
- **2025-11-12:** Fixed UI timing issues - countdowns now show accurate time (0s instead of stopping at 2s)
- **2025-11-12:** Fixed late-joining players not seeing intermission UI - now receives remaining time
- **2025-11-12:** Reduced intermission between rounds to 3s (from 5s) for better pacing
- **2025-11-12:** Fixed intermission UI to dynamically show correct countdown between rounds
- **2025-11-12:** TNT assignment now re-selects from alive players after delay to prevent assignment failures
- **2025-11-12:** Synchronized reward values (WinXP, LossXP, KillXP) between Lobby and Actual game configs
- **2025-11-12:** Implemented RTT-based time synchronization (TimeSync module) for accurate countdown timers
- **2025-11-12:** Server now uses workspace:GetServerTimeNow() for authoritative timestamps
- **2025-11-12:** Client measures network latency and syncs clock offset every 10 seconds
- **2025-11-12:** Round countdown now recomputes with latest offset each frame for automatic correction
- **2025-11-12:** Added "Round ending soon..." message in final 5 seconds before TNT explodes
- **2025-11-12:** FIXED: UI synchronization issues - all timers now perfectly synced with server events
- **2025-11-12:** FIXED: Removed "Round ending soon..." message - timer now shows countdown to 0s
- **2025-11-12:** FIXED: Round and intermission timers display "0s" exactly when TNT explodes/game starts
- **2025-11-12:** FIXED: Intermission UI now uses server-based timestamps (workspace:GetServerTimeNow())
- **2025-11-12:** FIXED: Late-joining players now see correct intermission countdown via server timestamp
- **2025-11-12:** FIXED: Queue teleport reliability - added retry logic with batch + individual fallback
- **2025-11-12:** FIXED: Teleport failures now retry up to 3 times per player with 1s delay between attempts
- **2025-11-12:** FIXED: Partial batch teleport success properly handled with nil guards
- **2025-11-12:** FIXED: Players who fail all teleport attempts are reset to NotQueued status

## User Preferences
None specified.

## Important Notes

### Must Configure
- Set `GameConfig.SubPlace.PlaceId` to Actual_Game ID
- Publish sub-place before testing teleportation
- Enable DataStore in game settings
- **To reset player data:** Change `GameConfig.DataStore.Version` in both Lobby_Game and Actual_Game (e.g., "v1" → "v2")

### Testing
- Use TestMode = true to test without teleportation
- Requires 2+ players for matchmaking
- Check Output for debug messages
- Verify leaderstats appear on join
- Test data persistence (leave/rejoin)
- **IMPORTANT:** Enable API Services in Game Settings > Security for DataStore to work
- **IMPORTANT:** Set `GameConfig.SubPlace.PlaceId` in Lobby_Game to your Actual_Game Place ID for teleportation to work
- Stats only update when players return to lobby (via TeleportData)

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
- **Game Logic:** PVPServer.lua
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
