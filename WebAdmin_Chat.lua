Messages = {}

function WebAdmin_Chat(Request)
	local Content = ""
	if Request.PostParams["Message"] ~= "" and Request.PostParams["Message"] ~= nil then
		--  ToDo: More Commands
		if string.sub(Request.PostParams["Message"], 1, 1) == "/" then
			-- Commands:
			if string.sub(Request.PostParams["Message"], 2, string.len(Request.PostParams["Message"])) == "reload" then
				PluginManager:ReloadPlugins()
				cRoot:Get():BroadcastChat("Reloading the server")
				AddMessage("Reloading the server")
			end
		else
			cRoot:Get():BroadcastChat("[" .. Request.Username .. "] " .. Request.PostParams["Message"])
			AddMessage("[WebAdmin] " .. Request.PostParams["Message"])
		end
	end
	Content = Content .. [[<table>]]
	for I, k in pairs(Messages) do
		Content = Content .. [[
		<tr>
			<td>]] .. k .. [[</td>
		</tr>]]
	end
	Content = Content .. [[</table>
	<form method="POST"><input type="text" name="Message"><input type="submit" value="Submit" name="submit"></form>
	<META HTTP-EQUIV="refresh" CONTENT="5">]]
	return Content
end

function AddMessage(Message)
	table.insert(Messages, Message)
	while #Messages > 50 do
		table.remove(Messages, 1)
	end
end