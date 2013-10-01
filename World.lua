function HandleSpawnCommand(Split, Player)
	-- Get the players World object to teleport to the spawn.
	local World = Player:GetWorld()
	
	Player:TeleportToCoords(World:GetSpawnX(), World:GetSpawnY(), World:GetSpawnZ())
	Player:SendMessage(GetMessageSucces(cChatColor.Green .. "You teleported to spawn"))
	return true
end

function HandleToggleDownfallCommand(Split, Player)
	-- You don't need any parameters.
	if #Split ~= 1 then
		Player:SendMessage(GetMessageFailure(cChatColor.Rose .. "Usage: /toggledownfall"))
		return true
	end
	
	local World = Player:GetWorld()
	local Weather = World:GetWeather()
	
	-- If the weather is sunny then change it to rain if not change it to sunny.
	if Weather == eWeather_Sunny then
		World:SetWeather(eWeather_Rain)
	else
		World:SetWeather(eWeather_Sunny)
	end
	
	Player:SendMessage(GetMessage(cChatColor.LightGray .. "Toggled downfall"))
	
	return true
end

function HandleTimeCommand(Split, Player)
	if #Split ~= 3 then
		Player:SendMessage(GetMessageFailure(cChatColor.Rose .. "Usage: /time Set|Add <number|day|night>"))
		return true
	end
	
	local World = Player:GetWorld()
	local Parameter1 = string.upper(Split[2])
	
	-- If the third parameter is a number then convert the string to a number. Else change it to an all upper case string.
	if tonumber(Split[3]) == nil then
		Split[3] = string.upper(Split[3])
	else
		Split[3] = tonumber(Split[3])
	end
	
	-- Set the time or Add time.
	if Parameter1 == "SET" then
		if type(Split[3]) == 'number' then
			World:SetTimeOfDay(Split[3])
			Player:SendMessage(GetMessageSucces("Set the time to " .. Split[3]))
			return true
		elseif Split[3] == "DAY" then
			World:SetTimeOfDay(1000)
			Player:SendMessage(GetMessageSucces("Set the time to 1000"))
			return true
		elseif Split[3] == "NIGHT" then
			World:SetTimeOfDay(12500)
			Player:SendMessage(GetMessageSucces("Set the time to 12500"))
			return true
		end
		Player:SendMessage(GetMessageFailure(cChatColor.Rose .. "Usage: /time Set <number|day|night>"))
		return true
	elseif Parameter1 == "ADD" then
		if type(Split[3]) ~= 'number' then
			Player:SendMessage(GetMessageFailure(cChatColor.Rose .. "Usage: /time Add <number>"))
			return true
		end
		local NewTime = World:GetTimeOfDay() + Split[3]
		World:SetTimeOfDay(NewTime)
		Player:SendMessage(GetMessageSucces("Set the time to " .. NewTime))
		return true
	end
	Player:SendMessage(GetMessageFailure(cChatColor.Rose .. "Usage: /time Set|Add <number|day|night>"))
	return true
end

function HandleWeatherCommand(Split, Player)
	LOGWARN("Not Implented Yet")
	return true
end