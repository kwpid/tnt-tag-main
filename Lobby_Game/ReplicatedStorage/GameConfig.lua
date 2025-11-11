local GameConfig = {}

GameConfig.SubPlace = {
        PlaceId = 0,
        AccessCode = nil
}

GameConfig.Queue = {
        MinPlayersPerMatch = 2,
        MaxPlayersPerMatch = 10,
        DefaultQueueMode = "Casual",
        MaxQueueTime = 120,
        MatchmakingInterval = 5,
        QueueUpdateInterval = 1,
        AvailableRegions = {"NA-East", "NA-West", "EU", "Asia", "Auto"},
        DefaultRegion = "Auto",
        RankedEnabled = false,
        RankedMMRRange = 200,
}

GameConfig.UI = {
        OpenDuration = 0.3,
        CloseDuration = 0.25,
        OpenEasingStyle = Enum.EasingStyle.Back,
        OpenEasingDirection = Enum.EasingDirection.Out,
        CloseEasingStyle = Enum.EasingStyle.Back,
        CloseEasingDirection = Enum.EasingDirection.In,
        ClosedScale = 0.3,
        OpenScale = 1,
        CameraZoomOffset = 10,
        CameraTransitionTime = 0.4,
        BlurEnabled = true,
        BlurSize = 24,
        BlurTransitionTime = 0.3,
}

GameConfig.Sounds = {
        ButtonHover = "rbxassetid://10066931761",
        ButtonClick = "rbxassetid://10066936129",
        QueueJoin = "rbxassetid://10066931761",
        QueueLeave = "rbxassetid://10066936129",
        MatchFound = "rbxassetid://10066936129",
        UIVolume = 0.5,
        NotificationVolume = 0.7,
}

GameConfig.Rewards = {
        WinXP = 100,
        LossXP = 25,
        KillXP = 10,
}

GameConfig.Debug = {
        Enabled = true,
        PrintQueueStatus = true,
        PrintMatchmaking = true,
        TestMode = false,
}

GameConfig.GameModes = {
        Casual = {
                Enabled = true,
                Name = "Casual",
                Description = "Play for fun!",
                MinPlayers = 2,
                MaxPlayers = 10,
        },
        Ranked = {
                Enabled = false,
                Name = "Ranked",
                Description = "Compete for rank!",
                MinPlayers = 2,
                MaxPlayers = 10,
        }
}

return GameConfig
