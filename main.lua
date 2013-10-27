-- Rewrite in progress

PLUGIN = nil

function Initialize(Plugin)
	PLUGIN = Plugin
	
	Plugin:SetName("Core+")
	Plugin:SetVersion(1)
	
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_JOINED, OnPlayerJoined)
	cPluginManager.AddHook(cPluginManager.HOOK_CHAT, OnChat)
	
	PluginManager = cRoot:Get():GetPluginManager()
	PluginManager:BindCommand("/tell",           "core.tell",           HandleTellCommand,           " - Used to send a private message")
	PluginManager:BindCommand("/me",             "core.me",             HandleMeCommand,             " - ")
	PluginManager:BindCommand("/spawn",          "core.spawn",          HandleSpawnCommand,          " - Command that returns you to the worlds spawn")
	PluginManager:BindCommand("/reload",         "core.reload",         HandleReloadCommand,         " - Command that reloads all the plugins")
	PluginManager:BindCommand("/help",           "core.help",           HandleHelpCommand,           " - Shows the help menu")
	PluginManager:BindCommand("/clear",          "core.clear",          HandleClearCommand,          " - Clears the inventory of the given playername")
	PluginManager:BindCommand("/toggledownfall", "core.toggledownfall", HandleToggleDownfallCommand, " - Toggles the Weather")
	PluginManager:BindCommand("/time",           "core.time",           HandleTimeCommand,           " - Change the time in the world you are currently in")
	PluginManager:BindCommand("/kill",           "core.kill",           HandleKillCommand,           " - Kill a player")
	PluginManager:BindCommand("/gamemode",       "core.gamemode",       HandleGamemodeCommand,       " - Change your or others gamemode")
	PluginManager:BindCommand("/tp",             "core.teleport",       HandleTeleportCommand,       " - Teleport to a player or coordinates")
	PluginManager:BindCommand("/plugins",        "core.plugins",        HandlePluginsCommand,        " - Shows a list of all the plugins.")
	PluginManager:BindCommand("/pl",             "core.plugins",        HandlePluginsCommand,        "")
	PluginManager:BindCommand("/weather",        "core.weather",        HandleWeatherCommand,        " - Changes the weather.")
	PluginManager:BindCommand("/ban",            "core.ban",            HandleBanCommand,            " - Ban a certain player from the server.")
	PluginManager:BindCommand("/pardon",         "core.pardon",         HandlePardonCommand,         " - Pardon a certain player from the server.")

	local SettingsIni = cIniFile()
	SettingsIni:ReadFile("Core.ini")
	UsePrefix = SettingsIni:GetValueSetB("General", "UsePrefixes", false)
	SettingsIni:WriteFile("Core.ini")
	
	BanList = LoadBans()
	WhiteList = LoadWhiteList()
	
	Plugin:AddWebTab("Manage Plugins", WebAdmin_Manage_Plugins)
	Plugin:AddWebTab("Chat", WebAdmin_Chat)
	Plugin:AddWebTab("Playerlist", WebAdmin_PlayerList)
	LOG("Initialized " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
end

function OnDisable()
	BanList:SavePlayerList()
	BanList:SaveIPList()
	WhiteList:Save()
end