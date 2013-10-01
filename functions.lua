function GetMessage(Message)
	if (UsePrefix) then
		return (cChatColor.Yellow .. "[INFO] " .. cChatColor.White .. Message)
	else
		return (Message)
	end
end

function GetMessageSucces(Message)
	if (UsePrefix) then
		return (cChatColor.Green .. "[INFO] " .. cChatColor.White .. Message)
	else
		return (Message)
	end
end

function GetMessageFailure(Message)
	if (UsePrefix) then
		return (cChatColor.Red .. "[INFO] " .. cChatColor.White .. Message)
	else
		return (Message)
	end
end

function LoadBans()
	local PlayerFile = io.open("banned-players.txt", "r")
	local IPFile = io.open("banned-ips.txt", "r")
	local PlayerTable = {}
	local IPTable = {}
	if PlayerFile then
		for I in PlayerFile:lines() do
			PlayerTable[I] = true
		end
		PlayerFile:close()
	end

	if IPFile then
		for I in IPFile:lines() do
			IPTable[I] = true
		end
		IPFile:close()
	end
	
	local Object = {}
	function Object:IsPlayerBanned(PlayerName)
		if PlayerTable[PlayerName] then
			return true
		end
		return false
	end
	
	function Object:BanPlayer(PlayerName)
		if PlayerTable[PlayerName] then
			return false
		end
		PlayerTable[PlayerName] = true
		return true
	end
	
	function Object:UnBanPlayer(PlayerName)
		if PlayerTable[PlayerName] then
			PlayerTable[PlayerName] = nil
			return true
		end
		return false
	end
	
	function Object:IsIPBanned(IP)
		if IPTable[IP] then
			return true
		end
		return false
	end
	
	function Object:BanIP(IP)
		if IPTable[IP] then
			return false
		end
		IPTable[IP] = true
		return true
	end
	
	function Object:UnBanIP(IP)
		if IPTable[IP] then
			IPTable[IP] = nil
			return true
		end
		return false
	end
	
	function Object:SavePlayerList()
		local File = io.open("banned-players.txt", "w")
		for I, k in pairs(PlayerTable) do
			File:write(I .. "\n")
		end
		File:close()
	end
	
	function Object:SaveIPList()
		local File = io.open("banned-ips.txt", "w")
		for I, k in pairs(IPTable) do
			File:write(I .. "\n")
		end
		File:close()
	end
	return Object
end

function LoadWhiteList()
	local WhiteListFile = io.open("white-list.txt")
	local Table = {}
	if File then
		for I in WhiteListFile:lines() do
			Table[I] = true
		end
	end
	
	local Object = {}
	function Object:IsWhiteListed(PlayerName)
		if Table[PlayerName] then
			return true
		end
		return false
	end
	
	return Object
end