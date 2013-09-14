-- Rewrite in progress

PLUGIN = nil

function Initialize(Plugin)
	PLUGIN = Plugin
	
	Plugin:SetName("Core")
	Plugin:SetVersion(1)
	
	PluginManager = cRoot:Get():GetPluginManager()
	PluginManager:BindCommand("/tell",   "core.tell",   HandleTellCommand,   " - Used to send a private message")
	PluginManager:BindCommand("/me",     "core.me",     HandleMeCommand,     " - ")
	PluginManager:BindCommand("/spawn",  "core.spawn",  HandleSpawnCommand,  " - Command that returns you to the worlds spawn")
	PluginManager:BindCommand("/reload", "core.reload", HandleReloadCommand, " - Command that reloads all the plugins")
	PluginManager:BindCommand("/help",   "core.help",   HandleHelpCommand,   " - Shows the help menu")
	
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
		table.remove(Split, 1)
		table.remove(Split, 2)
		TargetPlayer:SendMessage(GetMessageSucces(Player:GetName() .. " -> " .. "me " .. table.concat(Split)))
		Player:SendMessage(GetMessageSucces("me" .. " -> " .. Player:GetName() .. " " .. table.concat(Split)))
		return true
	end) then
		return true
	end
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