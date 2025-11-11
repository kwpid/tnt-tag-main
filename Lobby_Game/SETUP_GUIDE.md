# Roblox Queue System - Setup Guide

## 📋 Overview
This is a professional matchmaking and queue system for Roblox games. Players can queue for matches, get matched with others in their region, and be teleported to a sub-place for gameplay.

## 🏗️ Project Structure

```
Lobby_Game/
├── ReplicatedStorage/
│   ├── GameConfig.lua          # Main configuration (EDIT THIS FIRST!)
│   ├── QueueService.lua        # Shared queue utilities
│   └── RemoteEvents.lua        # Client-server communication
│
├── ServerScriptService/
│   ├── InitializeServer.lua    # Server initialization
│   ├── QueueManager.lua        # Matchmaking logic
│   └── File.lua                # (can be deleted)
│
├── StarterGui/
│   ├── CreateQueueGUI.lua      # Creates the UI
│   └── README.txt              # GUI setup instructions
│
└── StarterPlayer/
    └── StarterPlayerScripts/
        └── QueueUIController.lua   # Client UI controller
```

## 🚀 Quick Start

### Step 1: Set Up Your Sub-Place
1. Create a new place in Roblox Studio (this will be your Actual_Game)
2. Publish it
3. Copy the Place ID from the browser URL or game settings

### Step 2: Configure the System
Open `ReplicatedStorage/GameConfig.lua` and update:

```lua
GameConfig.SubPlace = {
    PlaceId = YOUR_ACTUAL_GAME_PLACE_ID, -- Replace with actual ID!
    AccessCode = nil
}
```

### Step 3: Add Sound Effects (Optional but Recommended)
In `GameConfig.Sounds`, replace the sound IDs with your own:

```lua
GameConfig.Sounds = {
    ButtonHover = "rbxassetid://YOUR_HOVER_SOUND",
    ButtonClick = "rbxassetid://YOUR_CLICK_SOUND",
    -- etc...
}
```

You can find free sounds in the Roblox Library or use the defaults.

### Step 4: Copy Files to Roblox Studio

**In Roblox Studio:**

1. **ReplicatedStorage:**
   - Create a folder in ReplicatedStorage (if you want organization)
   - Copy all 3 module scripts from `Lobby_Game/ReplicatedStorage/`

2. **ServerScriptService:**
   - Copy `InitializeServer.lua` and `QueueManager.lua`
   - Delete or ignore `File.lua`

3. **StarterGui:**
   - Copy `CreateQueueGUI.lua` as a LocalScript

4. **StarterPlayer > StarterPlayerScripts:**
   - Copy `QueueUIController.lua` as a LocalScript

### Step 5: Test!
1. Start a test server with at least 2 players
2. Click the "QUEUE" button
3. Select "CASUAL"
4. Wait for matchmaking (should take 5-10 seconds with min players)

## ⚙️ Configuration Options

### Queue Settings
Edit in `GameConfig.Queue`:

```lua
MinPlayersPerMatch = 2,        -- Minimum players needed
MaxPlayersPerMatch = 10,       -- Maximum players per match
MaxQueueTime = 120,            -- Force match after this many seconds
MatchmakingInterval = 5,       -- Check for matches every X seconds
```

### UI Customization
Edit in `GameConfig.UI`:

```lua
OpenDuration = 0.3,            -- Animation speed
CameraZoomOffset = 10,         -- Camera zoom amount
BlurSize = 24,                 -- Background blur intensity
QueueDotsSpeed = 0.5,          -- "QUEUING..." animation speed
```

### Debug Mode
For testing without teleportation:

```lua
GameConfig.Debug = {
    Enabled = true,
    TestMode = true,  -- Set to true to skip teleportation
}
```

## 🎨 UI Customization

The UI is created in `CreateQueueGUI.lua`. You can modify:
- Colors (search for `Color3.fromRGB`)
- Sizes (search for `UDim2.new`)
- Font (change `Enum.Font.GothamBold`)
- Text (change any `Text = "..."` property)

## 🔧 How It Works

### Client Side:
1. Player clicks QUEUE button
2. UI opens with animations (blur, zoom, scale)
3. Player selects mode (Casual/Ranked)
4. UI closes, button shows "QUEUING..."
5. Receives match status updates from server

### Server Side:
1. Receives queue join request
2. Adds player to regional queue
3. Matchmaking loop checks for enough players
4. Creates match when conditions met
5. Teleports players to sub-place

## 📝 Important Notes

⚠️ **Required Configuration:**
- You MUST set `GameConfig.SubPlace.PlaceId` or teleportation will fail
- The sub-place must be published and under the same universe

💡 **Regions:**
- Currently uses "Auto" which defaults to NA-East
- You can implement ping-based detection in `QueueManager:DetectPlayerRegion()`

🎵 **Sounds:**
- Default sounds are from Roblox library
- Replace with your own for better branding

## 🐛 Troubleshooting

**Players not teleporting:**
- Check SubPlace.PlaceId is correct
- Ensure sub-place is published
- Check Output for error messages
- Set TestMode = true to test without teleporting

**UI not appearing:**
- Check CreateQueueGUI.lua is in StarterGui
- Check QueueUIController.lua is in StarterPlayerScripts
- Look for errors in Output window

**Matchmaking not working:**
- Check MinPlayersPerMatch setting
- Ensure enough players are queuing
- Check server Output for "[QueueManager]" messages

## 🔍 Debug Output

When `GameConfig.Debug.Enabled = true`, you'll see messages like:

```
[QueueManager] PlayerName joined Casual queue in NA-East region
=== Queue Statistics ===
  Casual - NA-East: 2 players
========================
[QueueManager] Creating Casual match in NA-East with 2 players
```

## 📈 Future Enhancements

Easy additions you can make:
- [ ] Ranked mode with MMR tracking
- [ ] Party system (queue with friends)
- [ ] Queue time estimates
- [ ] Map voting
- [ ] Skill-based matchmaking
- [ ] Cross-region matching after timeout

## 🎯 Next Steps

1. Set up your Actual_Game place with game logic
2. Receive teleport data in Actual_Game:
```lua
local teleportData = player:GetJoinData().TeleportData
print(teleportData.Mode) -- "Casual" or "Ranked"
print(teleportData.Region) -- Player's region
```

3. Customize the UI to match your game's theme
4. Add sound effects for better polish
5. Test with real players!

---

**Need help?** Check the code comments - every module is thoroughly documented!
