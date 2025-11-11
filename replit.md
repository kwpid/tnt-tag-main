# Roblox Matchmaking Game Project

## Overview
A professional Roblox game featuring a queue system with matchmaking, animated UI, and multi-place teleportation. Players queue in the Lobby_Game and get teleported to Actual_Game for matches.

## Project Type
Roblox game development - contains Lua scripts designed to run within Roblox Studio and the Roblox platform.

## Structure

### Lobby_Game (Main Place)
```
Lobby_Game/
├── ReplicatedStorage/
│   ├── GameConfig.lua          # Main configuration module
│   ├── QueueService.lua        # Shared queue utilities
│   └── RemoteEvents.lua        # Client-server communication
│
├── ServerScriptService/
│   ├── InitializeServer.lua    # Server initialization
│   └── QueueManager.lua        # Matchmaking system
│
├── StarterGui/
│   └── CreateQueueGUI.lua      # UI generation script
│
└── StarterPlayer/StarterPlayerScripts/
    └── QueueUIController.lua   # Client UI controller
```

### Actual_Game (Sub-Place)
Contains the actual game logic - separate Roblox place for matches.

## Key Features

### Queue System
- Region-based matchmaking
- Configurable player counts (2-10 players)
- Auto-matching after timeout
- Debug and test modes

### Professional UI
- Animated queue button with state changes
- Smooth scale animations (Back easing)
- Background blur effect (24px)
- Camera zoom when menu opens
- Sound effects (hover, click, notifications)
- Animated "QUEUING..." with cycling dots

### Server-Client Architecture
- RemoteEvents for communication
- Centralized state management
- Error handling and validation
- Debug logging system

## Configuration

### Critical Settings (GameConfig.lua)
```lua
SubPlace.PlaceId = 0  -- ⚠️ MUST BE SET TO ACTUAL PLACE ID

Queue Settings:
- MinPlayersPerMatch: 2
- MaxPlayersPerMatch: 10
- MaxQueueTime: 120s
- MatchmakingInterval: 5s

UI Settings:
- OpenDuration: 0.3s
- CameraZoomOffset: 10
- BlurSize: 24
- QueueDotsSpeed: 0.5s
```

### Debug Mode
```lua
GameConfig.Debug = {
    Enabled = true,
    TestMode = true,  -- Skips teleportation for testing
}
```

## Usage Instructions

### For Development in Replit
1. Edit Lua files here
2. Copy files to Roblox Studio when ready
3. Test in Roblox Studio with multiple players

### For Roblox Studio Setup
1. Create sub-place and get Place ID
2. Update `GameConfig.SubPlace.PlaceId`
3. Copy all scripts to appropriate locations
4. Test with 2+ players
5. See `SETUP_GUIDE.md` for detailed instructions

## Technical Details

### Language & Environment
- **Language:** Lua (Roblox Luau)
- **Platform:** Roblox Studio/Engine
- **Client-Server:** RemoteEvents
- **UI Framework:** Roblox GUI with TweenService

### Module Dependencies
- TweenService (animations)
- TeleportService (multi-place)
- Players, ReplicatedStorage (core services)
- Lighting (blur effect)
- SoundService (audio)

## Recent Changes
- **2025-11-11:** Initial GitHub import
- **2025-11-11:** Created queue system with matchmaking
- **2025-11-11:** Built animated UI with sounds and effects
- **2025-11-11:** Implemented teleportation system
- **2025-11-11:** Added comprehensive configuration system
- **2025-11-11:** Created setup documentation

## User Preferences
None specified yet.

## Important Notes

⚠️ **Must Configure:**
- Set `GameConfig.SubPlace.PlaceId` to your actual sub-place ID
- Publish sub-place before testing teleportation
- Replace default sound IDs with your own (optional)

✅ **Testing:**
- Use TestMode = true to test without teleportation
- Requires at least 2 players for matchmaking
- Check Output window for debug messages

🎨 **Customization:**
- Colors in CreateQueueGUI.lua
- Timings in GameConfig.lua
- Sounds in GameConfig.Sounds
- All thoroughly documented with comments

## Architecture Notes

### Design Patterns
- Module pattern for shared code
- Observer pattern for status updates
- State machine for queue states
- Event-driven client-server communication

### Code Quality
- Comprehensive error handling
- Extensive inline documentation
- Configurable debug logging
- Professional naming conventions
- Separation of concerns

### Scalability
- Regional queue organization
- Efficient matchmaking loops
- Minimal server-client traffic
- Easy to extend (ranked mode, parties, etc.)

## Next Steps for User
1. Get sub-place ID from Roblox Studio
2. Configure GameConfig.SubPlace.PlaceId
3. Copy files to Roblox Studio
4. Add game logic to Actual_Game
5. Test and iterate
6. Add custom sounds and styling

## Files for Roblox Studio
All files under `Lobby_Game/` should be copied to the corresponding Roblox Studio locations. See `SETUP_GUIDE.md` for exact placement.

## Main Entry Points
- **Server:** InitializeServer.lua (auto-loads QueueManager)
- **Client:** QueueUIController.lua (handles all UI)
- **Config:** GameConfig.lua (all settings)

## Debug Commands
All debug output prefixed with module name:
- `[QueueManager]` - Server matchmaking logs
- `[QueueUI]` - Client UI logs
- `[Server]` - Initialization logs
