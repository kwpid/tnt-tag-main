local PlayerDataService = {}

function PlayerDataService.CreateMatchData(mode, result, kills, deaths)
	return {
		Mode = mode,
		Result = result,
		Kills = kills or 0,
		Deaths = deaths or 0,
		Timestamp = os.time()
	}
end

return PlayerDataService
