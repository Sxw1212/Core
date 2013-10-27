NeedsReload = false

function WebAdmin_Manage_Plugins(Request)
	local Content = ""
	local SettingsIni = cIniFile()
	SettingsIni:ReadFile("settings.ini")
		
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
			SettingsIni:WriteFile("settings.ini")
			NeedsReload = true
		elseif (Request.PostParams["Move_DOWN"] ~= nil) then
			local Exist, ID = table.contains(InSettingsIni, Request.PostParams["Move_DOWN"])
			InSettingsIni[ID + 1], InSettingsIni[ID] = InSettingsIni[ID], InSettingsIni[ID + 1] -- Swap the plugins in the table.
			SettingsIni:DeleteKey("Plugins")
			for I, k in pairs(InSettingsIni) do
				SettingsIni:SetValue("Plugins", "Plugin", k)
			end
			SettingsIni:WriteFile("settings.ini")
			NeedsReload = true
		end
	end
	
	-- We store it if there were changes otherwise the apply button would disappear when disabling/enabling an plugin.
	if NeedsReload then
		Content = Content .. [[<form method='POST'>Apply the changes: <input type='submit' name='reload' value='Apply!'></form>]]
	end
	
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
	
	table.sort(ErrorPlugins)
	table.sort(DisabledPlugins)

	-- Remove plugins that are not loaded because something went wrong while loading the plugin.
	for I, k in pairs(ActivatedPlugins) do
		if not PluginManager:GetPlugin(k) then
			ActivatedPlugins[I] = nil -- If we use table.remove the values get editted while we are reading it.
		end
	end

	Content = Content .. [[<h4>Active plugins</h4><p>These plugins have been successfully initialized and are currently running.</p>
		<table style=\"background-color: #efffef\">]]
	
	for I, Name in pairs(ActivatedPlugins) do
		Content = Content .. "<tr>"
		Content = Content .. "<td width=\"100%\" style=\"background-color: #efffef\">" .. Name .. "</td>"

		if InSettingsIni[1] == Name then
			Content = Content .. '<td style=\"background-color: #efffef\"><button type="button" disabled>Move Up</button> </td>'
		else
			Content = Content .. '<td style=\"background-color: #efffef\"><form method="POST"><input type="hidden" name="Move_UP" value="' .. Name .. '"><input type="submit" name="Move" value="Move Up"></form></td>'
		end

		if InSettingsIni[#InSettingsIni] == Name then
			Content = Content .. '<td style=\"background-color: #efffef\"><button type="button" disabled>Move Down</button> </td>'
		else
			Content = Content .. '<td style=\"background-color: #efffef\"><form method="POST"><input type="hidden" name="Move_DOWN" value="' .. Name .. '"><input type="submit" name="Move" value="Move Down"></form></td>'
		end

		Content = Content .. '<td style=\"background-color: #efffef\"><form method="POST"><input type="hidden" name="PluginName" value="'.. Name ..'"><input type="submit" name="DisablePlugin" value="Disable"></form></td>'
		Content = Content .. "<tr>"
	end
	
	if #ErrorPlugins ~= 0 then
		Content = Content .. [[</table><br /><hr /><h4>Errors</h4><p>These plugins are configured to run, but encountered a problem during their initialization. MCServer disabled them temporarily and will try reloading them.</p><table>]]
		for I, Name in pairs(ErrorPlugins) do
			Content = Content .. "<tr>"
			Content = Content .. "<td width=\"100%\" style=\"background-color: #ffefef\">" .. Name .. "</td>"
			Content = Content .. "<td style=\"background-color: #ffefef\"><form method='POST'><input type='hidden' name='PluginName' value='"..Name.."'><input type='submit' name='RemovePlugin' value='Disable'></form></td>"
			Content = Content .. "<tr>"
		end
	end
	
	if #DisabledPlugins ~= 0 then
		Content = Content .. [[</table><br /><hr /><h4>Disabled plugins</h4>
		<p>These plugins are installed, but are disabled in the configuration</p>
		<table>]]
		for I, Name in pairs(DisabledPlugins) do
			Content = Content .. "<tr>"
			Content = Content .. "<td width=\"100%\">" .. Name .. "</td>"
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