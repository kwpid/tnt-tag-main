# Player Data System Guide

## Overview
Complete player progression system with DataStore persistence, leaderstats, and match history tracking.

## Player Stats

### Stored Data
- **Wins** - Total wins
- **Losses** - Total losses
- **Win Streak** - Current win streak
- **Highest Win Streak** - Best streak ever
- **Level** - Player level (starts at 1)
- **XP** - Experience points
- **Ranked ELO** - Ranked matchmaking rating (starts at 1000)
- **Recent Matches** - Last 10 matches with stats

### Leaderstats (Visible on Player List)
- Wins
- Level
- Win Streak

## XP & Leveling

### XP Rewards
- **Win:** 100 XP
- **Loss:** 25 XP
- **Kill:** 10 XP (future)

### Level Calculation
```lua
XP needed = 100 + (Level × 50)

Level 1 → 2: 150 XP
Level 2 → 3: 200 XP
Level 3 → 4: 250 XP
```

Configure in `GameConfig.Rewards`:
```lua
GameConfig.Rewards = {
    WinXP = 100,
    LossXP = 25,
    KillXP = 10,
}
```

## How It Works

### Lobby_Game (Main Place)

**PlayerDataManager.lua** - Core data management
- Loads data when player joins
- Saves data when player leaves
- Creates leaderstats
- Updates wins/losses/XP/level
- Auto-saves on server shutdown

**MatchResultReceiver.lua** - Processes match results
- Receives results from Actual_Game
- Updates player stats
- Saves data after each match

### Actual_Game (Sub-Place)

**GameManager.lua** - Match management
- Tracks player kills/deaths during match
- Ends match and determines winners
- Sends results to all players
- Teleports players back to lobby

**MatchResultClient.lua** - Client-side result handler
- Receives match result from server
- Sends confirmation back to Lobby_Game

## Match Flow

```
1. Players teleport to Actual_Game
2. GameManager tracks kills/deaths
3. Match ends, winners determined
4. GameManager sends results to clients
5. Clients send results to Lobby_Game
6. Lobby_Game updates stats and saves
7. Players teleport back to Lobby_Game
```

## Usage in Actual_Game

### Record Kills
```lua
local GameManager = require(script.Parent:WaitForChild("GameManager"))
GameManager:RecordKill(killerPlayer, victimPlayer)
```

### End Match
```lua
local winners = {player1, player2}
GameManager:EndGame(winners)
```

### Get Match Data
```lua
Players.PlayerAdded:Connect(function(player)
    local joinData = player:GetJoinData()
    local teleportData = joinData.TeleportData
    
    print("Mode:", teleportData.Mode)
    print("Region:", teleportData.Region)
end)
```

## Accessing Player Data

### In Lobby_Game
```lua
local PlayerDataManager = require(ServerScriptService:WaitForChild("PlayerDataManager"))

local data = PlayerDataManager:GetPlayerData(player)
print("Wins:", data.Wins)
print("Level:", data.Level)
print("ELO:", data.RankedElo)
```

### Manual Updates
```lua
-- Add a win
PlayerDataManager:AddWin(player)

-- Add a loss
PlayerDataManager:AddLoss(player)

-- Add XP
PlayerDataManager:AddXP(player, 50)

-- Update ELO (ranked)
PlayerDataManager:UpdateRankedElo(player, 25)  -- +25 ELO
PlayerDataManager:UpdateRankedElo(player, -15) -- -15 ELO
```

## DataStore

**Name:** `PlayerData_v1`
**Key Format:** `Player_{UserId}`

Data is automatically:
- Loaded on player join
- Saved on player leave
- Saved on server shutdown
- Saved after each match

## Future Features

### Recent Matches
```lua
local data = PlayerDataManager:GetPlayerData(player)
for _, match in ipairs(data.RecentMatches) do
    print("Mode:", match.Mode)
    print("Result:", match.Result)
    print("K/D:", match.Kills, "/", match.Deaths)
    print("Time:", match.Timestamp)
end
```

Stores last 10 matches with:
- Mode (Casual/Ranked)
- Result (Win/Loss)
- Kills/Deaths
- Timestamp

### Ranked System
When enabled, use `RankedElo` for matchmaking:
```lua
local data = PlayerDataManager:GetPlayerData(player)
local elo = data.RankedElo
```

## File Structure

```
Lobby_Game/
├── ServerScriptService/
│   ├── PlayerDataManager.lua       # Core data system
│   └── MatchResultReceiver.lua     # Receives match results
│
└── ReplicatedStorage/
    └── PlayerDataService.lua       # Helper functions

Actual_Game/
├── ServerScriptService/
│   ├── GameManager.lua             # Match management
│   └── MatchResultHandler.lua      # Processes results
│
└── StarterPlayer/StarterPlayerScripts/
    └── MatchResultClient.lua       # Client result handler
```

## Testing

1. Join game and check leaderstats appear
2. Queue and complete a match
3. Verify stats update after match
4. Leave and rejoin to test data persistence

## Customization

Edit `GameConfig.Rewards` to change XP amounts:
```lua
GameConfig.Rewards = {
    WinXP = 150,    -- More XP per win
    LossXP = 50,    -- More XP for losing
    KillXP = 15,    -- Future kill rewards
}
```

## Important Notes

- Data saves automatically, no manual saves needed
- Leaderstats update instantly when stats change
- Win streaks reset on any loss
- Level-up is automatic when XP threshold reached
- DataStore version is `v1` (change if data structure changes)
