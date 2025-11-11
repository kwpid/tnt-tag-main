# TNT Tag Game Setup Guide

## Overview
TNT Tag is a fast-paced elimination game where players try to avoid being "IT" when the TNT explodes. Players can tag each other to transfer the TNT, and the last player standing wins!

## Game Rules
- **Max Players**: 25 per match
- **Round Time**: 45 seconds until TNT explodes
- **Win Condition**: Last player alive wins
- **PVP System**: Click to hit players, knockback effect + red highlight

## Setup Checklist

### 1. Create Teams (In Roblox Studio)
Create two teams in the Teams service:

**Lobby Team:**
- Name: "Lobby"
- TeamColor: Bright blue
- AutoAssignable: ✓ (checked)

**Game Team:**
- Name: "Game"
- TeamColor: Bright red
- AutoAssignable: ✗ (unchecked)

### 2. Create TNT Accessory
In **ServerStorage**, create this structure:
```
ServerStorage
└── TNT (Folder)
    └── TNT (Accessory)
        └── Handle (Part with TNT mesh/model)
```

The TNT accessory will be cloned and placed on the "IT" player's head.

### 3. Create Maps
In **ServerStorage**, create maps:
```
ServerStorage
└── Maps (Folder)
    └── YourMapName (Model)
        ├── MapSpawn (Part or SpawnLocation)
        └── [Other map parts]
```

**Important:** Each map MUST have a "MapSpawn" part where players will spawn.

### 4. Create UI
In **StarterGui**, create:
```
StarterGui
└── MainGUI (ScreenGui)
    └── BackToLobby (TextButton)
        └── BackToLobby (LocalScript)
```

**BackToLobby Button Properties:**
- Visible: false (will show when player dies)
- Text: "Return to Lobby"
- Position your button where you want it

### 5. Copy Scripts to Roblox Studio

**ReplicatedStorage:**
- GameConfig.lua
- RemoteEvents.lua
- PlayerDataService.lua

**ServerScriptService:**
- GameManager.lua
- PVPMain.lua
- MatchResultHandler.lua

**StarterPlayer > StarterPlayerScripts:**
- MatchResultClient.lua
- PVPClient.lua
- GhostSystem.lua
- RoundUI.lua

**StarterGui > MainGUI > BackToLobby:**
- BackToLobby.lua (the script)

### 6. Configure Settings
Edit **GameConfig.lua** in ReplicatedStorage:

```lua
GameConfig.Game = {
    MaxPlayers = 25,         -- Server capacity
    RoundTime = 45,          -- Seconds until TNT explodes
    IntermissionTime = 5,    -- Break between rounds
    EndGameWaitTime = 30,    -- Wait before teleporting back
    FirstRoundDelay = 10,    -- Initial delay for players to load
}

GameConfig.PVP = {
    HitCooldown = 0.5,       -- Cooldown between hits
    KnockbackPower = 50,     -- Knockback force
    HitRange = 10,           -- Maximum hit distance
}
```

### 7. Enable Required Services
In Roblox Studio settings:
- ✓ Enable Studio Access to API Services
- ✓ Enable "Allow Third Party Teleports" (Game Settings > Security)

### 8. Set Place ID
If using the lobby system, set the lobby Place ID in GameConfig:
```lua
GameConfig.LobbyPlaceId = YOUR_LOBBY_PLACE_ID
```

## How to Play

### For Players:
1. Join from queue (or join Actual_Game directly for testing)
2. Wait for first round to start (10s delay)
3. One random player becomes "IT" with TNT on their head
4. Click other players to hit them and transfer the TNT (if you're IT)
5. Avoid having TNT when the 45-second timer runs out
6. Last player standing wins!
7. Dead players can click "Return to Lobby" to go back

### Game Flow:
```
Players Join → First Round Delay (10s)
    ↓
Map Loads from ServerStorage.Maps
    ↓
Players Spawn at MapSpawn
    ↓
Random player gets TNT
    ↓
45-second countdown begins
    ↓
TNT explodes, IT player dies
    ↓
5-second intermission
    ↓
Next round starts (new random IT)
    ↓
Repeat until 1 player remains
    ↓
Winner announced, 30s wait
    ↓
All players teleport back to lobby
```

## Testing

### Single Place Testing (Without Queue):
1. Set `GameConfig.LobbyPlaceId` to the same Place ID as Actual_Game
2. Start a test server with 2+ players
3. Players will join Lobby team automatically
4. After 10 seconds, game starts

### With Queue System:
1. Publish both Lobby_Game and Actual_Game
2. Set Actual_Game Place ID in Lobby's GameConfig
3. Set Lobby Place ID in Actual_Game's GameConfig
4. Test with 2+ players queuing in lobby

## Troubleshooting

**TNT doesn't appear:**
- Check that ServerStorage.TNT.TNT exists
- Ensure it's an Accessory with a Handle part

**Players don't spawn:**
- Verify MapSpawn exists in your map model
- Check that Maps folder is in ServerStorage

**Game doesn't start:**
- Check Output for errors
- Ensure at least 2 players joined
- Verify FirstRoundDelay passed

**PVP doesn't work:**
- Check that Teams are set up correctly
- Verify PVPClient.lua is in StarterPlayerScripts
- Make sure characters are R6 (not R15)

**Back to Lobby doesn't show:**
- Verify MainGUI exists in StarterGui
- Check that BackToLobby button is inside MainGUI
- Ensure GhostSystem.lua is running

## Configuration Tips

**Shorter Rounds:**
```lua
GameConfig.Game.RoundTime = 30  -- 30 second rounds
```

**More Intense Knockback:**
```lua
GameConfig.PVP.KnockbackPower = 100
```

**Faster Gameplay:**
```lua
GameConfig.Game.IntermissionTime = 3  -- Shorter breaks
GameConfig.Game.RoundTime = 30        -- Faster rounds
```

## Stats Tracking
The game tracks:
- **Deaths**: How many times a player exploded
- **Wins**: If player won the match
- **XP Rewards**:
  - Winner: 150 XP
  - Survivor: 50 XP

Stats are sent back to the lobby and saved to DataStore automatically.

## Advanced Customization

### Custom TNT Explosion Effect:
Edit PVPMain.lua in the `ExplodeTNT()` function to add visual effects.

### Custom Hit Effects:
Edit PVPClient.lua to change highlight colors or add sounds.

### Different Round Times Per Round:
Modify GameManager.lua to adjust `GameConfig.Game.RoundTime` dynamically.

## Support

If you encounter issues:
1. Check Output window for errors
2. Verify all setup steps completed
3. Test with Debug mode: `GameConfig.Debug.Enabled = true`
4. Check that all scripts are in correct locations

## Notes
- Game requires R6 characters for proper hitbox detection
- Minimum 2 players required to start
- Dead players become spectators (ghost mode)
- Maps are randomly selected each game
- PVP only works between Game team members
