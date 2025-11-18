local require = require(script.Parent.loader).load(script)

local ObservableMap = require("ObservableMap")

local PluginSettingsService = {}
PluginSettingsService.ServiceName = "PluginSettingsService"

export type PluginSettingsService = typeof(setmetatable(
	{} :: {
		_settingsMap: ObservableMap.ObservableMap<string, any>,
	},
	{} :: typeof({ __index = PluginSettingsService })
))

function PluginSettingsService.Init(self: PluginSettingsService)
	self._settingsMap = ObservableMap.new()
end

function PluginSettingsService.Start() end

function PluginSettingsService.SetSetting(self: PluginSettingsService, key: string, value: any)
	return self._settingsMap:Set(key, value)
end

function PluginSettingsService.GetSetting(self: PluginSettingsService, key: string, default: any?)
	return self._settingsMap:Get(key) or default
end

function PluginSettingsService.ObserveSettingsBrio(self: PluginSettingsService)
	return self._settingsMap:ObservePairsBrio()
end

function PluginSettingsService.Destroy(self: PluginSettingsService)
	self._settingsMap:Destroy()
end

return PluginSettingsService
