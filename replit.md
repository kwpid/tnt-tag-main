# Roblox TNT Tag Game Project

## Overview
A professional Roblox game featuring a queue system, matchmaking, player progression with DataStore persistence, and multi-place teleportation. Players queue in a Lobby_Game, get matched, and teleport to Actual_Game to play TNT Tag—a fast-paced elimination game where players avoid being "IT" when the TNT explodes. The last player standing wins, fostering competitive and engaging gameplay.

## Recent Changes (November 13, 2025)
### Level GUI System
- **XP Progression Display:** Added animated Level GUI that appears when players return from matches
- **Cumulative XP Animation:** Shows each XP gain source separately (Game Win/Loss, Kills) with smooth progress bar animations
- **Level-Up Visuals:** Bar resets and animates level-ups during XP application with updated level text
- **Comprehensive Logging:** Added detailed debug logs to track data flow from match end through GUI display
- **Configuration:** All timing and animation settings in `GameConfig.LevelUI` for easy customization

### Previous: Cross-Place Data Synchronization (November 12, 2025)
- **Authoritative Sub-Place:** The `Actual_Game` (sub-place) is now the authoritative source for match results. Stats are updated and saved in the sub-place BEFORE players are teleported back to the lobby.
- **Concurrent-Safe Updates:** Both places now use `UpdateAsync` instead of `SetAsync` to prevent race conditions and data loss during concurrent writes.
- **Match ID System:** Each match is assigned a unique ID to prevent double-application of rewards if teleportation fails or retries occur.
- **Timestamp-Based Ordering:** `LastSaveTimestamp` field ensures that newer data from the authoritative sub-place is always accepted, allowing legitimate stat decreases (XP rollovers, win streak resets) to persist correctly.
- **Fallback Processing:** If the sub-place save fails, the lobby can process match results as a fallback, with proper duplicate detection.
- **Error Resilience:** The `alreadyProcessed` flag is only set if the sub-place successfully saves data, ensuring no rewards are lost due to DataStore failures.

## User Preferences
None specified.

## System Architecture

### UI/UX Decisions
- Professional UI with slide-in animations, background blur (24px), and camera FOV zoom.
- Interactive elements with hover effects, including a red "CANCEL QUEUE" indicator.
- Sound effects for enhanced user feedback.
- **Level GUI:** Animated XP progression display with slide-in/out animations, progress bar filling, and XP gain breakdown showing each reward source.

### Technical Implementations
- **Game Mode:** Elimination-style TNT Tag with a 45-second round timer.
- **PVP System:** Click-to-hit mechanics with arm swing animation, knockback, and visual highlights.
- **TNT Transfer:** Players pass TNT by hitting others.
- **Multi-Place System:** Players queue in `Lobby_Game`, teleport to `Actual_Game` for matches, and results are sent back to `Lobby_Game` for stat updates and auto-teleportation back.
- **Queue System:** Region-based matchmaking, configurable player counts (2-25), auto-matching, and cancel queue functionality.
- **Player Progression:** Tracks Wins, Losses, Win Streaks, Level, XP, and ELO rating.
- **Data Persistence:** Player stats and progression are saved using DataStore with `UpdateAsync` for concurrency safety. Data is saved in the sub-place before teleportation, with auto-save on leave/shutdown. Match IDs and timestamps prevent duplicate stat updates and ensure data consistency across places.
- **Time Synchronization:** RTT-based client-server clock synchronization for accurate in-game timers.
- **Camera System:** Toggle between First/Third person views.
- **Ghost Mode:** Allows eliminated players to spectate or return to the lobby.
- **Map System:** Random map selection for variety.

### Feature Specifications
- **Max Players:** 25 per server in `Actual_Game`.
- **Match History:** Last 10 matches tracked.
- **Leaderstats:** Displays Wins, Level, and Win Streak on the player list.
- **Level GUI:** Post-match XP and level progression display with individual XP source breakdown (Win/Loss XP, Kill XP).
- **GameConfig.lua:** Centralized configuration for queue settings, rewards, UI parameters, Level GUI timing, and DataStore versioning.

### System Design Choices
- **Language & Platform:** Lua (Roblox Luau) on Roblox Studio/Engine.
- **Client-Server Communication:** Utilizes Roblox's `RemoteEvents` for interactions.
- **UI:** Leverages `TweenService` for animations.
- **Data:** `DataStoreService` for persistent player data.
- **Core Systems:**
    - Server-side matchmaking loops for queue management.
    - DataStore with UpdateAsync for concurrent-safe saves and authoritative snapshot merging.
    - Cross-place communication for match results via TeleportData with match IDs and processing flags.
    - Leaderstats are automatically updated in both places.
    - RTT-based clock offset measurement for synchronized countdowns.
    - Timestamp-based data ordering to prevent stale writes from overriding newer data.
- **Architectural Patterns:** Module pattern for shared code, Observer pattern for status updates, State machine for queue states, Event-driven client-server architecture, and a DataStore abstraction layer.
- **Code Quality:** Emphasizes clean code, error handling, professional naming, and separation of concerns.

## External Dependencies
- **Roblox Services:**
    - `DataStoreService`: For player data persistence.
    - `TeleportService`: For multi-place teleportation between `Lobby_Game` and `Actual_Game`.
    - `TweenService`: For UI animations.
    - `RemoteEvents`/`RemoteFunctions`: For client-server communication.