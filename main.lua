-- Rewrite in progress

PLUGIN = nil

function Initialize(Plugin)
	PLUGIN = Plugin
	
	Plugin:SetName("Core")
	Plugin:SetVersion(1)
	
	PluginManager = cRoot:Get():GetPluginManager()
	PluginManager:BindCommand("/tell",           "core.tell",           HandleTellCommand,           " - Used to send a private message")
	PluginManager:BindCommand("/me",             "core.me",             HandleMeCommand,             " - ")
	PluginManager:BindCommand("/spawn",          "core.spawn",          HandleSpawnCommand,          " - Command that returns you to the worlds spawn")
	PluginManager:BindCommand("/reload",         "core.reload",         HandleReloadCommand,         " - Command that reloads all the plugins")
	PluginManager:BindCommand("/help",           "core.help",           HandleHelpCommand,           " - Shows the help menu")
	PluginManager:BindCommand("/clear",          "core.clear",          HandleClearCommand,          " - Clears the inventory of the given playername")
	PluginManager:BindCommand("/toggledownfall", "core.toggledownfall", HandleToggleDownfallCommand, " - Toggles the Weather")
	PluginManager:BindCommand("/time",           "core.time",           HandleTimeCommand,           " - Change the time in the world you are currently in")
	PluginManager:BindCommand("/kill",           "core.kill",           HandleKillCommand,           " - Kill a player")
	PluginManager:BindCommand("/gamemode",       "core.gamemode",       HandleGamemodeCommand,       " - Change your or others gamemode")
	PluginManager:BindCommand("/tp",             "core.teleport",       HandleTeleportCommand,       " - Teleport to a player or coordinates")
	
	local SettingsIni = cIniFile("Core.ini")
	SettingsIni:ReadFile()
	UsePrefix = SettingsIni:GetValueSetB("General", "UsePrefixes", false)
	SettingsIni:WriteFile()
	return true
end

function HandleSpawnCommand(Split, Player)
	local World = Player:GetWorld()
	Player:TeleportToCoords(World:GetSpawnX(), World:GetSpawnY(), World:GetSpawnZ())
	Player:SendMessage(GetMessageSucces(cChatColor.Green .. "You teleported to spawn"))
	return true
end

function HandleReloadCommand(Split, Player)
	cRoot:Get():BroadcastChat(cChatColor.Rose .. "Plugins are reloading")
	PluginManager:ReloadPlugins()
	return true
end

function HandleMeCommand(Split, Player)
	if #Split < 2 then
		Player:SendMessage("Usage /me [Message]")
		return true
	end
	
	local World = Player:GetWorld()
	
	table.remove(Split, 1)
	World:BroadcastChat("* " .. Player:GetName() .. " " .. table.concat(Split, " "))
	return true
end

function HandleTellCommand(Split, Player)
	if #Split < 3 then
		Player:SendMessage(GetMessageFailure("Usage /tell [Target Player] [Message]"))
		return true
	end
	
	if cRoot:Get():FindAndDoWithPlayer(Split[2], function(TargetPlayer)
		-- Player is found. Remove /tell and the target player from Split and concat it.
		table.remove(Split, 1)
		table.remove(Split, 2)
		TargetPlayer:SendMessage(GetMessageSucces(Player:GetName() .. " -> " .. "me " .. table.concat(Split)))
		Player:SendMessage(GetMessageSucces("me" .. " -> " .. Player:GetName() .. " " .. table.concat(Split)))
		return true
	end) then
		return true
	end
	
	-- No Player found
	Player:SendMessage(GetMessageFailure("Player not found"))
	return true
end

function HandleHelpCommand(Split, Player)
	local PageRequested = 1

	if (#Split == 2) then
		if tonumber(Split[2]) == nil then
			
		else
			PageRequested = tonumber(Split[2])
		end
	end
	
	local LinesPerPage = 8
	local CurrentPage = 1
	local CurrentLine = 0
	local Output = {}

	local Process = function(Command, Permission, HelpString)
		if not (Player:HasPermission(Permission)) then
			return false
		end
		if (HelpString == "") then
			return false
		end

		CurrentLine = CurrentLine + 1
		CurrentPage = math.floor(CurrentLine / LinesPerPage) + 1
		if (CurrentPage ~= PageRequested) then
			return false
		end
		table.insert(Output, Command .. HelpString)
	end

	PluginManager:ForEachCommand(Process)

	-- CurrentPage now contains the total number of pages, and Output has the individual help lines to be sent

	Player:SendMessage("Page " .. PageRequested .. " out of " .. CurrentPage .. ".")
	Player:SendMessage("'-' means no prefix, '~' means a value is required.")
	for idx, msg in ipairs(Output) do
		Player:SendMessage(msg)
	end

	return true
end

function HandleClearCommand(Split, Player)
	if #Split ~= 2 then
		Player:SendMessage(GetMessageFailure(cChatColor.Rose .. "Usage: /clear [Playername]"))
		return true
	end
	
	if cRoot:Get():FindAndDoWithPlayer(Split[2], function(OtherPlayer)
		OtherPlayer:GetInventory():Clear()
		OtherPlayer:SendMessage(GetMessageSucces(cChatColor.LightGray .. "Inventory cleared"))
		Player:SendMessage(GetMessageSucces(cChatColor.LightGray .. "Player ".. OtherPlayer:GetName() .. "'s Inventory cleared"))
		return true
	end) then
		return true
	end
	
	Player:SendMessage(GetMessageFailure(cChatColor.Rose .. "Player not found"))
	return true
end

function HandleToggleDownfallCommand(Split, Player)
	if #Split ~= 1 then
		Player:SendMessage(GetMessageFailure(cChatColor.Rose .. "Usage: /toggledownfall"))
		return true
	end
	local World = Player:GetWorld()
	local Weather = World:GetWeather()
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
	Split[2] = string.upper(Split[2])
	if tonumber(Split[3]) == nil then
		Split[3] = string.upper(Split[3])
	else
		Split[3] = tonumber(Split[3])
	end
	
	if Split[2] == "SET" then
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
	elseif Split[2] == "ADD" then
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

function HandleKillCommand(Split, Player)
	if #Split ~= 2 then
		Player:SendMessage(GetMessageFailure(cChatColor.Rose .. "Usage: /kill [TargetPlayer]"))
		return true
	end
	if cRoot:Get():FindAndDoWithPlayer(Split[2], function(TargetPlayer)
		TargetPlayer:TakeDamage(dtAdmin, Player, 1000, 0)
		TargetPlayer:SendMessage(GetMessageSucces("Ouch. That looks like it hurt."))
		return true
	end) then
		return true
	end
	Player:SendMessage(GetMessageFailure("Player not found"))
	return true
end

function HandleGamemodeCommand(Split, Player)
	if #Split == 1 then
		Player:SendMessage(GetMessageFailure("Usage: /gamemode <Player> [Gamemode]"))
		return true
	end
	
	if #Split == 3 then
		if tonumber(Split[3]) == nil then
			local Gamemode = string.upper(Split[3])
			local GM = 0
			if Gamemode == "SURVIVAL" then
				GM = 0
			elseif Gamemode == "CREATIVE" then
				GM = 1
			elseif Gamemode == "ADVENTURE" then
				GM = 2
			else
				Player:SendMessage(GetMessageFailure("Usage: /gamemode <Player> [creative|survival|adventure]"))
				return true
			end
			if cRoot:Get():FindAndDoWithPlayer(Split[2], function(TargetPlayer)
				TargetPlayer:SetGameMode(GM)
				Player:SendMessage(GetMessageSucces("Player " .. TargetPlayer:GetName() .. " has his gamemode set to " .. GM))
				return true
			end) then
				return true
			end
			Player:SendMessage(GetMessageFailure("Player not found"))
			return true
		end
		local Gamemode = tonumber(Split[3])
		if ((Gamemode < 0) or (Gamemode > 2)) then
			Player:SendMessage(GetMessageFailure("Usage: /gamemode <Player> [creative|survival|adventure]"))
			return true
		end
		if cRoot:Get():FindAndDoWithPlayer(Split[2], function(TargetPlayer)
			TargetPlayer:SetGameMode(Gamemode)
			Player:SendMessage(GetMessageSucces("Player " .. TargetPlayer:GetName() .. " has his gamemode set to " .. Gamemode))
			return true
		end) then
			return true
		end
		Player:SendMessage(GetMessageFailure("Player not found"))
		return true
	end
	
	if tonumber(Split[2]) == nil then
		local Gamemode = string.upper(Split[2])
		local GM = 0
		if Gamemode == "SURVIVAL" then
			GM = 0
		elseif Gamemode == "CREATIVE" then
			GM = 1
		elseif Gamemode == "ADVENTURE" then
			GM = 2
		else
			Player:SendMessage(GetMessageFailure("Usage: /gamemode [creative|survival|adventure]"))
			return true
		end
		Player:SetGameMode(GM)
		return true
	else
		local Gamemode = tonumber(Split[2])
		if ((Gamemode < 0) or (Gamemode > 2)) then
			Player:SendMessage(GetMessageFailure("Usage: /gamemode [creative|survival|adventure]"))
			return true
		end
		Player:SetGameMode(Gamemode)
	end
	return true
end

function HandleTeleportCommand(Split, Player)
	if #Split == 2 then
		if cRoot:Get():FindAndDoWithPlayer(Split[2], function(TargetPlayer)
			Player:TeleportToEntity(TargetPlayer)
			Player:SendMessage(GetMessageSucces(Player:GetName() .. " was teleported to " .. TargetPlayer:GetName()))
			return true
		end) then
			return true
		end
		Player:SendMessage(GetMessageFailure("Player not found"))
		return true
	elseif #Split ==  3 then
		if cRoot:Get():FindAndDoWithPlayer(Split[2], function(TargetPlayer)
			if cRoot:Get():FindAndDoWithPlayer(Split[3], function(ToTeleport)
				TargetPlayer:TeleportToEntity(ToTeleport)
				Player:SendMessage(GetMessageSucces("Teleported " .. Split[2] .. " to " .. Split[3]))
				return true
			end) then
				return true
			end
			Player:SendMessage(GetMessageFailure("Player " .. Split[3] .. " was not found"))
			return true
		end) then
			return true
		end
		Player:SendMessage(GetMessageFailure("Player " .. Split[2] .. " was not found"))
		return true
	elseif #Split == 4 then
		local X = tonumber(Split[2])
		local Y = tonumber(Split[3])
		local Z = tonumber(Split[4])
		if X == nil or Y == nil or Z == nil then
			Player:SendMessage(GetMessageFailure(cChatColor.Rose .. "Usage: /tp [target player] <destination player> OR /tp [target player] <x> <y> <z>"))
			return true
		end
		local XInt, Xfractional = math.modf(X)
		local YInt, Yfractional = math.modf(Y)
		local ZInt, Zfractional = math.modf(Z)
		if math.abs(Xfractional) == -0 then
			Xfractional = 0.5
		end
		if math.abs(Yfractional) == -0 then
			Yfractional = 0.5
		end
		if math.abs(Zfractional) == -0 then
			Zfractional = 0.5
		end
		X = XInt + Xfractional
		Y = YInt + Yfractional
		Z = ZInt + Zfractional
		Player:TeleportToCoords(X, Y, Z)
		Player:SendMessage(GetMessageSucces("Teleported " .. Player:GetName() .. " to " .. X .. "," .. Y .. "," .. Z))
		return true
	elseif #Split == 5 then
		local X = tonumber(Split[3])
		local Y = tonumber(Split[4])
		local Z = tonumber(Split[5])
		if X == nil or Y == nil or Z == nil then
			Player:SendMessage(GetMessageFailure(cChatColor.Rose .. "Usage: /tp [target player] <destination player> OR /tp [target player] <x> <y> <z>"))
			return true
		end
		local XInt, Xfractional = math.modf(X)
		local YInt, Yfractional = math.modf(Y)
		local ZInt, Zfractional = math.modf(Z)
		if math.abs(Xfractional) == -0 then
			Xfractional = 0.5
		end
		if math.abs(Yfractional) == -0 then
			Yfractional = 0.5
		end
		if math.abs(Zfractional) == -0 then
			Zfractional = 0.5
		end
		X = XInt + Xfractional
		Y = YInt + Yfractional
		Z = ZInt + Zfractional
		if cRoot:Get():FindAndDoWithPlayer(Split[2], function(TargetPlayer)
			TargetPlayer:TeleportToCoords(X, Y, Z)
			Player:SendMessage(GetMessageSucces("Teleported " .. Player:GetName() .. " to " .. X .. "," .. Y .. "," .. Z))
			return true
		end) then
			return true
		end
		Player:SendMessage(GetMessageFailure("Player not found"))
		return true
	end
end