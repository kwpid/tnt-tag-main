# Roblox TNT Tag Game Project

## Overview
A professional Roblox game featuring a queue system, matchmaking, player progression with DataStore persistence, and multi-place teleportation. Players queue in a Lobby_Game, get matched, and teleport to Actual_Game to play TNT Tag—a fast-paced elimination game where players avoid being "IT" when the TNT explodes. The last player standing wins, fostering competitive and engaging gameplay.

## User Preferences
None specified.

## System Architecture

### UI/UX Decisions
- Professional UI with slide-in animations, background blur (24px), and camera FOV zoom.
- Interactive elements with hover effects, including a red "CANCEL QUEUE" indicator.
- Sound effects for enhanced user feedback.

### Technical Implementations
- **Game Mode:** Elimination-style TNT Tag with a 45-second round timer.
- **PVP System:** Click-to-hit mechanics with arm swing animation, knockback, and visual highlights.
- **TNT Transfer:** Players pass TNT by hitting others.
- **Multi-Place System:** Players queue in `Lobby_Game`, teleport to `Actual_Game` for matches, and results are sent back to `Lobby_Game` for stat updates and auto-teleportation back.
- **Queue System:** Region-based matchmaking, configurable player counts (2-25), auto-matching, and cancel queue functionality.
- **Player Progression:** Tracks Wins, Losses, Win Streaks, Level, XP, and ELO rating.
- **Data Persistence:** Player stats and progression are saved using DataStore, with auto-save on leave/shutdown and match completion.
- **Time Synchronization:** RTT-based client-server clock synchronization for accurate in-game timers.
- **Camera System:** Toggle between First/Third person views.
- **Ghost Mode:** Allows eliminated players to spectate or return to the lobby.
- **Map System:** Random map selection for variety.

### Feature Specifications
- **Max Players:** 25 per server in `Actual_Game`.
- **Match History:** Last 10 matches tracked.
- **Leaderstats:** Displays Wins, Level, and Win Streak on the player list.
- **GameConfig.lua:** Centralized configuration for queue settings, rewards, UI parameters, and DataStore versioning.

### System Design Choices
- **Language & Platform:** Lua (Roblox Luau) on Roblox Studio/Engine.
- **Client-Server Communication:** Utilizes Roblox's `RemoteEvents` for interactions.
- **UI:** Leverages `TweenService` for animations.
- **Data:** `DataStoreService` for persistent player data.
- **Core Systems:**
    - Server-side matchmaking loops for queue management.
    - DataStore with an auto-save mechanism for player data.
    - Cross-place communication for match results.
    - Leaderstats are automatically updated.
    - RTT-based clock offset measurement for synchronized countdowns.
- **Architectural Patterns:** Module pattern for shared code, Observer pattern for status updates, State machine for queue states, Event-driven client-server architecture, and a DataStore abstraction layer.
- **Code Quality:** Emphasizes clean code, error handling, professional naming, and separation of concerns.

## External Dependencies
- **Roblox Services:**
    - `DataStoreService`: For player data persistence.
    - `TeleportService`: For multi-place teleportation between `Lobby_Game` and `Actual_Game`.
    - `TweenService`: For UI animations.
    - `RemoteEvents`/`RemoteFunctions`: For client-server communication.