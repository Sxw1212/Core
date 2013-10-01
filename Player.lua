function HandleClearCommand(Split, Player)
	if #Split ~= 2 then
		Player:SendMessage(GetMessageFailure(cChatColor.Rose .. "Usage: /clear [Playername]"))
		return true
	end
	
	if cRoot:Get():FindAndDoWithPlayer(Split[2], function(OtherPlayer)
		-- Get the inventory, clear it and send both players a message that the inventory is cleared.
		OtherPlayer:GetInventory():Clear()
		OtherPlayer:SendMessage(GetMessageSucces(cChatColor.LightGray .. "Inventory cleared"))
		Player:SendMessage(GetMessageSucces(cChatColor.LightGray .. "Player ".. OtherPlayer:GetName() .. "'s Inventory cleared"))
		return true
	end) then
		-- The player was found and his inventory is cleared so there isn't anything todo now.
		return true
	end
	
	Player:SendMessage(GetMessageFailure(cChatColor.Rose .. "Player not found"))
	return true
end

function HandleKillCommand(Split, Player)
	if #Split ~= 2 then
		Player:SendMessage(GetMessageFailure(cChatColor.Rose .. "Usage: /kill [TargetPlayer]"))
		return true
	end
	
	if cRoot:Get():FindAndDoWithPlayer(Split[2], function(TargetPlayer)
		-- Make the target player take 1000 damage. 
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
	
	-- There are two parameters so he propably wants to give someone else a different gamemode.
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
	else
		Player:SendMessage(GetMessageFailure(cChatColor.Rose .. "Usage: /tp [target player] <destination player> OR /tp [target player] <x> <y> <z>"))
		return true
	end
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

function HandleBanCommand(Split, Player)
	if #Split == 2 then
		local TargetPlayer = Split[2]
		if not BanList:BanPlayer(TargetPlayer) then
			Player:SendMessage("Player " .. TargetPlayer .. " is already banned")
			return true
		end
		cRoot:Get():FindAndDoWithPlayer(TargetPlayer, function(OtherPlayer)
			OtherPlayer:GetClientHandle():Kick("You are banned")
		end)
		Player:SendMessage("Banned player " .. TargetPlayer)
		return true
	elseif #Split > 2 then
		local TargetPlayer = Split[2]
		if not BanList:BanPlayer(TargetPlayer) then
			Player:SendMessage("Player " .. TargetPlayer .. " is already banned")
			return true
		end
		cRoot:Get():FindAndDoWithPlayer(TargetPlayer, function(OtherPlayer)
			table.remove(Split, 1)
			table.remove(Split, 1)
			OtherPlayer:GetClientHandle():Kick(table.concat(Split, " "))
		end)
		Player:SendMessage("Banned player " .. TargetPlayer)
		return true
	end
	Player:SendMessage(cChatColor.Rose .. "usage: /ban <name> [reason]")
	return true
end

function HandleUnBanCommand(Split, Player)
	if #Split == 2 then
		if not BanList:UnBanPlayer(Split[2]) then
			Player:SendMessage("Player " .. Split[2] .. " already wasn't banned.")
			return true
		end
		Player:SendMessage("Unbanned player " .. Split[2])
		return true
	end
	Player:SendMessage(cChatColor.Rose .. "usage: /pardon <name> ")
end