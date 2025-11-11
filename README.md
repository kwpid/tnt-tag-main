# Roblox Matchmaking Game

Professional Roblox game with queue system, matchmaking, player progression, and multi-place teleportation.

## Features

- **Queue System** - Animated UI with region-based matchmaking
- **Player Progression** - Wins, losses, levels, XP, win streaks
- **Leaderstats** - Wins, Level, Win Streak visible on player list
- **DataStore** - Persistent player data saves automatically
- **Multi-Place** - Teleportation between Lobby and Game
- **Professional UI** - Slide animations, blur, camera zoom
- **Sound Effects** - Hover, click, notifications
- **Highly Configurable** - Everything in GameConfig.lua

## Project Structure

**Lobby_Game** - Main place where players queue
**Actual_Game** - Sub-place for actual matches

## Quick Setup

1. Create sub-place in Roblox Studio and publish it
2. Configure `GameConfig.lua` with your sub-place ID
3. Create UI in StarterGui (see SETUP_GUIDE.md)
4. Copy scripts to Roblox Studio
5. Test with 2+ players

For detailed setup, see [`Lobby_Game/SETUP_GUIDE.md`](Lobby_Game/SETUP_GUIDE.md)

## UI Features

**Queue Button:**
- Click to open menu
- Click while queuing to cancel
- Hover shows "CANCEL QUEUE" when queuing

**Animations:**
- Menu slides from top
- Background blur (24px)
- Camera zoom (10 studs)
- Animated queuing dots

**States:**
- QUEUE → ^^^^^^ → QUEUING... → MATCH FOUND! → TELEPORTING...

## Configuration

All settings in `GameConfig.lua`:

```lua
-- Queue
MinPlayersPerMatch = 2
MaxPlayersPerMatch = 10
MaxQueueTime = 120

-- UI
OpenDuration = 0.3
CameraZoomOffset = 10
QueueDotsSpeed = 1.0

-- Debug
TestMode = true  -- Skip teleportation
```

## How It Works

```
Player clicks QUEUE
    ↓
Menu slides in (blur + zoom)
    ↓
Player selects CASUAL
    ↓
Button shows "QUEUING..."
    ↓
Server finds match
    ↓
Teleport to Actual_Game
```

## Game Modes

**Casual** - Active, quick matchmaking
**Ranked** - Coming soon

## Regions

- NA-East
- NA-West
- EU
- Asia
- Auto (default)

## Customization

- Colors: Edit in your UI
- Sounds: Change IDs in GameConfig
- Timings: Adjust in GameConfig.UI
- Everything is easily configurable

## Development Notes

Uses:
- ModuleScripts for shared code
- RemoteEvents for client-server communication
- TweenService for animations
- Professional code structure

## License

Free to use for your Roblox games.
