function OnPlayerJoined(Player)
	if BanList:IsPlayerBanned(Player:GetName()) then
		Player:GetClientHandle():Kick("You are banned")
		return true
	end
	if BanList:IsIPBanned(Player:GetIP()) then
		Player:GetClientHandle():Kick("Your IP is banned")
		return true
	end
end

function OnChat(Player, Message)
	AddMessage(Player:GetName() .. ": " .. Message)
end	