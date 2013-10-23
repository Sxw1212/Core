function WebAdmin_Manage_Plugins(Request)
	local Content = ""
	local SettingsIni = cIniFile("settings.ini")
	SettingsIni:ReadFile()
	
	if( Request.PostParams["reload"] ~= nil ) then
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
	
	Content = Content .. [[<h4>Currently installed plugins</h4>
		<table>]]
		
	local PluginsKeyID = SettingsIni:FindKey("Plugins")
	local InSettingsIni = {}
	for I=1, SettingsIni:NumValues("Plugins") do
		table.insert(InSettingsIni, SettingsIni:GetValue(PluginsKeyID, I))
	end
	local PluginManager = cRoot:Get():GetPluginManager()
	PluginManager:FindPlugins()
	local PluginList = PluginManager:GetAllPlugins()
	Content = Content .. [[
	<tr>
		<td>Plugin</td>
		<td>State</td>
		<td>Interactions</td>
	</tr>]]
	local ActivatedPlugins = {}
	local ErrorPlugins = {}
	local DisabledPlugins = {}
	for Name, Plugin in pairs(PluginList) do
		if Plugin then
			table.insert(ActivatedPlugins, Name)
		elseif table.contains(InSettingsIni, Name) then
			table.insert(ErrorPlugins, Name)
		else
			table.insert(DisabledPlugins, Name)
		end
	end
	table.sort(ActivatedPlugins)
	table.sort(ErrorPlugins)
	table.sort(DisabledPlugins)
	for I, Name in pairs(ActivatedPlugins) do
		Content = Content .. "<tr>"
		Content = Content .. "<td>" .. Name .. "</td>"
		Content = Content .. '<td><b style="color: green;">Enabled</b>'
		Content = Content .. '<td><form method="POST"><input type="hidden" name="PluginName" value="'.. Name ..'"><input type="submit" name="DisablePlugin" value="Disable"></form></td>'
		Content = Content .. "<tr>"
	end
	for I, Name in pairs(ErrorPlugins) do
		Content = Content .. "<tr>"
		Content = Content .. "<td>" .. Name .. "</td>"
		Content = Content .. '<td><b style="color: red;">Error</b>'
		Content = Content .. "<td><form method='POST'><input type='hidden' name='PluginName' value='"..Name.."'><input type='submit' name='RemovePlugin' value='Remove'></form></td>"
		Content = Content .. "<tr>"
	end
	for I, Name in pairs(DisabledPlugins) do
		Content = Content .. "<tr>"
		Content = Content .. "<td>" .. Name .. "</td>"
		Content = Content .. '<td><b style="color: Orange;">Disabled</b>'
		Content = Content .. '<td><form method="POST"><input type="hidden" name="PluginName" value="'.. Name ..'"><input type="submit" name="EnablePlugin" value="Enable"></form></td>'
		Content = Content .. "<tr>"	
	end
	Content = Content .. "</table>"
	
	
	Content = Content .. [[<h4>Reload</h4>
	<form method='POST'>
	<p>Click the reload button to reload all plugins according to <strong>settings.ini</strong>!
	<input type='submit' name='reload' value='Reload!'></p>
	</form>]]
	return Content
end