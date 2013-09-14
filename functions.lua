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