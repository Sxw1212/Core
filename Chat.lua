function HandleMeCommand(Split, Player)
	if #Split < 2 then
		Player:SendMessage("Usage /me [Message]")
		return true
	end
	
	local World = Player:GetWorld()
	
	-- Remove the "/me" from the table. If we don't do that the message gets weird. ( * PLAYER /me This is a message)
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

