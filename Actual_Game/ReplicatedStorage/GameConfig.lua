local GameConfig = {}

GameConfig.DataStore = {
        Version = "v1",
        Name = "PlayerData"
}

GameConfig.LobbyPlaceId = 76587714865691

GameConfig.Game = {
        MaxPlayers = 25,
        RoundTime = 45,
        IntermissionTime = 5,
        EndGameWaitTime = 30,
        FirstRoundDelay = 10,
        StartIntermissionTime = 15,
}

GameConfig.TNT = {
        ExplosionRadius = 20,
        ExplosionDamage = 100,
        AccessoryPath = "ServerStorage.TNT.TNT",
}

GameConfig.PVP = {
        HitCooldown = 0.3,
        KnockbackPower = 50,
        HighlightColor = Color3.fromRGB(255, 100, 100),
        HighlightDuration = 0.3,
        HitRange = 10,
        HitSoundId = "rbxassetid://8595980577",
}

GameConfig.Rewards = {
        WinXP = 150,
        SurvivalXP = 50,
}

GameConfig.Debug = {
        Enabled = true,
        PrintGameFlow = true,
}

return GameConfig
