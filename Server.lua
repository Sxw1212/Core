function HandleReloadCommand(Split, Player)
	cRoot:Get():BroadcastChat(cChatColor.Rose .. "Plugins are reloading")
	PluginManager:ReloadPlugins()
	return true
end

function HandlePluginsCommand(Split, Player)
	local PluginList = PluginManager:GetAllPlugins()
	local Table = {}
	for I, k in pairs(PluginList) do
		table.insert(Table, cChatColor.LightGreen .. I)
	end
	Player:SendMessage("Plugins (" .. #Table .. "): " .. table.concat(Table, cChatColor.White .. ", "))
	return true
end
