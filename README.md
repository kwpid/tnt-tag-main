# Roblox Matchmaking Game

A professional Roblox game with queue system, matchmaking, and multi-place teleportation.

## 🎮 Features

- **Queue System** - Players can queue for matches with animated UI
- **Matchmaking** - Region-based matchmaking with configurable player counts
- **Professional UI** - Smooth animations, blur effects, camera zoom, sounds
- **Multi-Place Support** - Teleports players to a sub-place for actual gameplay
- **Highly Configurable** - All settings in one easy-to-edit config file
- **Production Ready** - Clean code, error handling, debug mode

## 📁 Project Structure

### Lobby_Game (Main Place)
The lobby where players queue for matches.

**Key Components:**
- `GameConfig.lua` - Main configuration file
- `QueueManager.lua` - Server-side matchmaking system
- `QueueUIController.lua` - Client-side UI controller with animations
- `CreateQueueGUI.lua` - Programmatic UI creation

### Actual_Game (Sub-Place)
The game place where actual matches happen. This is a separate Roblox place that players get teleported to.

## 🚀 Quick Setup

1. **Create your sub-place** in Roblox Studio and publish it
2. **Configure** `Lobby_Game/ReplicatedStorage/GameConfig.lua` with your sub-place ID
3. **Copy files** to the appropriate Roblox Studio locations (see SETUP_GUIDE.md)
4. **Test** with multiple players!

For detailed setup instructions, see [`Lobby_Game/SETUP_GUIDE.md`](Lobby_Game/SETUP_GUIDE.md)

## ⚙️ Configuration

All settings are in `GameConfig.lua`:

```lua
-- Sub-Place Configuration
GameConfig.SubPlace.PlaceId = YOUR_PLACE_ID  -- ⚠️ REQUIRED

-- Queue Settings
MinPlayersPerMatch = 2
MaxPlayersPerMatch = 10
MaxQueueTime = 120

-- UI Animations
OpenDuration = 0.3
CameraZoomOffset = 10
BlurSize = 24
```

## 🎨 UI Features

- **Queue Button** - Click to open menu or leave queue
- **Animated Menu** - Smooth scale animation with blur background
- **Camera Zoom** - Subtle zoom when menu is open
- **Sound Effects** - Hover and click sounds
- **Queue Status** - Animated "QUEUING..." with dots
- **Visual Feedback** - Color changes for different states

## 🔧 How It Works

```
Player clicks QUEUE
    ↓
Menu opens (animation + blur + zoom)
    ↓
Player selects CASUAL
    ↓
Menu closes, button shows "QUEUING..."
    ↓
Server finds match (region-based)
    ↓
Players teleport to Actual_Game place
```

## 📋 File Locations for Roblox Studio

```
ReplicatedStorage/
├── GameConfig
├── QueueService  
└── RemoteEvents

ServerScriptService/
├── InitializeServer
└── QueueManager

StarterGui/
└── CreateQueueGUI (LocalScript)

StarterPlayer/StarterPlayerScripts/
└── QueueUIController (LocalScript)
```

## 🐛 Debug Mode

Enable in `GameConfig.lua`:

```lua
GameConfig.Debug = {
    Enabled = true,
    TestMode = true,  -- Skip teleportation for testing
}
```

## 🎯 Game Modes

### Casual (Active)
- Quick matchmaking
- No skill requirements
- 2-10 players per match

### Ranked (Coming Soon)
- MMR-based matchmaking
- Competitive play
- Skill brackets

## 📊 Matchmaking Logic

1. Players join queue with mode and region
2. Server checks every 5 seconds for matches
3. Match created when min players reached
4. Players auto-matched after max wait time
5. Teleportation to sub-place server

## 🔐 Server-Client Communication

Uses RemoteEvents for:
- `QueueJoin` - Player joins queue
- `QueueLeave` - Player leaves queue
- `QueueStatusUpdate` - Server updates player status
- `MatchFound` - Notify player of match
- `GetQueueStatus` - Client checks current status

## 🌍 Regions

Available regions:
- NA-East
- NA-West
- EU
- Asia
- Auto (default)

## 💡 Tips

✅ **DO:**
- Set your sub-place ID before testing
- Test with at least 2 players
- Check Output window for debug info
- Customize colors and sounds

❌ **DON'T:**
- Forget to publish your sub-place
- Set TestMode = false until sub-place is ready
- Modify player states directly (use RemoteEvents)

## 🚧 Customization

Easy to modify:
- **Colors** - Edit in CreateQueueGUI.lua
- **Sounds** - Add your own sound IDs
- **Queue times** - Adjust in GameConfig
- **Player counts** - Min/max in GameConfig
- **Animations** - Tweak speeds and styles

## 📝 Development Notes

This project uses:
- ModuleScripts for shared code
- RemoteEvents for client-server communication
- TweenService for smooth animations
- Professional code structure and error handling
- Extensive documentation and comments

## 🎓 Learning Resources

This code demonstrates:
- Roblox matchmaking systems
- Client-server architecture
- UI animation with TweenService
- Multi-place teleportation
- State management
- Professional Lua practices

## 📄 License

Feel free to use this code for your Roblox games!

---

**Need help?** Read the [`SETUP_GUIDE.md`](Lobby_Game/SETUP_GUIDE.md) for detailed instructions.
