NeedsReload = false

function WebAdmin_Manage_Plugins(Request)
	local Content = ""
	local SettingsIni = cIniFile("settings.ini")
	SettingsIni:ReadFile()
		
	if (Request.PostParams["reload"] ~= nil) then
		Content = Content .. "<head><meta http-equiv=\"refresh\" content=\"2;\"></head>"
		Content = Content .. "<p>Reloading plugins... This can take a while depending on the plugins you're using.</p>"
		cRoot:Get():GetPluginManager():ReloadPlugins()
		return Content
	end

	if (Request.PostParams["DisablePlugin"] ~= nil) and (Request.PostParams["PluginName"] ~= nil) then
		if DisablePlugin(Request.PostParams["PluginName"], SettingsIni) then
			Content = Content .. '<td><b style="color: green;">You disabled plugin: "'.. Request.PostParams["PluginName"] .. '"</b>'
		end
	elseif (Request.PostParams["EnablePlugin"] ~= nil) and (Request.PostParams["PluginName"] ~= nil) then
		if EnablePlugin(Request.PostParams["PluginName"], SettingsIni) then
			Content = Content .. '<td><b style="color: green;">You enabled plugin: "'.. Request.PostParams["PluginName"] .. '"</b>'
		end
	elseif (Request.PostParams["RemovePlugin"] ~= nil) and (Request.PostParams["PluginName"] ~= nil) then
		if RemovePlugin(Request.PostParams["PluginName"], SettingsIni) then
			Content = Content .. '<td><b style="color: green;">You removed plugin: "'.. Request.PostParams["PluginName"] .. '"</b>'
		end
	end
	
	local PluginsKeyID = SettingsIni:FindKey("Plugins")
	local InSettingsIni = {}
	for I=0, SettingsIni:NumValues("Plugins") - 1 do
		table.insert(InSettingsIni, SettingsIni:GetValue(PluginsKeyID, I))
	end
	
	if (Request.PostParams["Move"] ~= nil) then
		if (Request.PostParams["Move_UP"] ~= nil) then
			local Exist, ID = table.contains(InSettingsIni, Request.PostParams["Move_UP"])
			InSettingsIni[ID - 1], InSettingsIni[ID] = InSettingsIni[ID], InSettingsIni[ID - 1] -- Swap the plugins in the table.
			SettingsIni:DeleteKey("Plugins")
			for I, k in pairs(InSettingsIni) do
				SettingsIni:SetValue("Plugins", "Plugin", k)
			end
			SettingsIni:WriteFile()
			NeedsReload = true
		elseif (Request.PostParams["Move_DOWN"] ~= nil) then
			local Exist, ID = table.contains(InSettingsIni, Request.PostParams["Move_DOWN"])
			InSettingsIni[ID + 1], InSettingsIni[ID] = InSettingsIni[ID], InSettingsIni[ID + 1] -- Swap the plugins in the table.
			SettingsIni:DeleteKey("Plugins")
			for I, k in pairs(InSettingsIni) do
				SettingsIni:SetValue("Plugins", "Plugin", k)
			end
			SettingsIni:WriteFile()
			NeedsReload = true
		end
	end
	
	-- We store it if there were changes otherwise the apply button would disappear when disabling/enabling an plugin.
	if NeedsReload then
		Content = Content .. [[<form method='POST'>Apply the changes: <input type='submit' name='reload' value='Apply!'></form>]]
	end
	
	Content = Content .. [[<h4>Currently installed plugins</h4>
		<table>]]

	PluginManager:FindPlugins()
	local PluginList = PluginManager:GetAllPlugins()
	
	local ActivatedPlugins = InSettingsIni
	local ErrorPlugins = {}
	local DisabledPlugins = {}
	
	for Name, Plugin in pairs(PluginList) do
		if Plugin then
			-- We can't insert the plugin in a table because it would not be sorted in the order the plugins get loaded.
		elseif table.contains(InSettingsIni, Name) then
			table.insert(ErrorPlugins, Name)
		else
			table.insert(DisabledPlugins, Name)
		end
	end
	
	-- Remove plugins that are not loaded because something went wrong while loading the plugin.
	for I, k in pairs(ActivatedPlugins) do
		if not PluginManager:GetPlugin(k) then
			table.remove(ActivatedPlugins, I)
		end
	end

	table.sort(ErrorPlugins)
	table.sort(DisabledPlugins)
	
	Content = Content .. "<th colspan='5'>Activated Plugins</th>"
	for I, Name in pairs(ActivatedPlugins) do
		Content = Content .. "<tr>"
		Content = Content .. "<td>" .. Name .. "</td>"
		Content = Content .. '<td><b style="color: green;">Enabled</b>'
		Content = Content .. '<td><form method="POST"><input type="hidden" name="PluginName" value="'.. Name ..'"><input type="submit" name="DisablePlugin" value="Disable"></form></td>'
		if InSettingsIni[1] == Name then
			Content = Content .. '<td><button type="button" disabled>Move Up</button> </td>'
		else
			Content = Content .. '<td><form method="POST"><input type="hidden" name="Move_UP" value="' .. Name .. '"><input type="submit" name="Move" value="Move Up"></form></td>'
		end
		if InSettingsIni[#InSettingsIni] == Name then
			Content = Content .. '<td><button type="button" disabled>Move Down</button> </td>'
		else
			Content = Content .. '<td><form method="POST"><input type="hidden" name="Move_DOWN" value="' .. Name .. '"><input type="submit" name="Move" value="Move Down"></form></td>'
		end
		
		Content = Content .. "<tr>"
	end
	if #ErrorPlugins ~= 0 then
		Content = Content .. [[</table><br /><table> <th colspan=3>Error</th>]]
		for I, Name in pairs(ErrorPlugins) do
			Content = Content .. "<tr>"
			Content = Content .. "<td>" .. Name .. "</td>"
			Content = Content .. '<td><b style="color: red;">Error</b>'
			Content = Content .. "<td><form method='POST'><input type='hidden' name='PluginName' value='"..Name.."'><input type='submit' name='RemovePlugin' value='Remove'></form></td>"
			Content = Content .. "<tr>"
		end
	end
	if #DisabledPlugins ~= 0 then
	Content = Content .. [[</table><br /><table> <th colspan=3>Disabled Plugins</th>]]
		for I, Name in pairs(DisabledPlugins) do
			Content = Content .. "<tr>"
			Content = Content .. "<td>" .. Name .. "</td>"
			Content = Content .. '<td><b style="color: Orange;">Disabled</b>'
			Content = Content .. '<td><form method="POST"><input type="hidden" name="PluginName" value="'.. Name ..'"><input type="submit" name="EnablePlugin" value="Enable"></form></td>'
			Content = Content .. "<tr>"	
		end
	end
	
	Content = Content .. [[</table>
	<h4>Reload</h4>
	<form method='POST'>
	<p>Click the reload button to reload all plugins according to <strong>settings.ini</strong>!
	<input type='submit' name='reload' value='Reload!'></p>
	</form>]]
	return Content
end