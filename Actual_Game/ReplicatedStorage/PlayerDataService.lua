local PlayerDataService = {}

function PlayerDataService.CreateDefaultData()
        return {
                Wins = 0,
                Losses = 0,
                Level = 1,
                XP = 0,
                WinStreak = 0,
                HighestWinStreak = 0,
                TotalMatches = 0,
                MatchHistory = {}
        }
end

function PlayerDataService.CalculateXPForLevel(level)
        return 100 * level
end

function PlayerDataService.AddXP(data, amount)
        data.XP = (data.XP or 0) + amount
        data.Level = data.Level or 1
        
        while data.XP >= PlayerDataService.CalculateXPForLevel(data.Level) do
                data.XP = data.XP - PlayerDataService.CalculateXPForLevel(data.Level)
                data.Level = data.Level + 1
        end
        
        return data
end

function PlayerDataService.RecordMatch(data, isWin, deaths)
        data.Wins = data.Wins or 0
        data.Losses = data.Losses or 0
        data.WinStreak = data.WinStreak or 0
        data.HighestWinStreak = data.HighestWinStreak or 0
        data.TotalMatches = (data.TotalMatches or 0) + 1
        data.MatchHistory = data.MatchHistory or {}
        
        if isWin then
                data.Wins = data.Wins + 1
                data.WinStreak = data.WinStreak + 1
                
                if data.WinStreak > data.HighestWinStreak then
                        data.HighestWinStreak = data.WinStreak
                end
        else
                data.Losses = data.Losses + 1
                data.WinStreak = 0
        end
        
        table.insert(data.MatchHistory, 1, {
                Result = isWin and "Win" or "Loss",
                Deaths = deaths or 0,
                Timestamp = os.time()
        })
        
        if #data.MatchHistory > 10 then
                table.remove(data.MatchHistory)
        end
        
        return data
end

return PlayerDataService
