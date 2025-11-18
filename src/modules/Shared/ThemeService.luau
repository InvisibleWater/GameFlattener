local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local ObservableMap = require("ObservableMap")
local ThrottledFunction = require("ThrottledFunction")

local ThemeService = {}
ThemeService.ServiceName = "ThemeService"

export type ThemeService = typeof(setmetatable(
	{} :: {
		_maid: Maid.Maid,
		_themeMap: ObservableMap.ObservableMap<Enum.StudioStyleGuideColor, Color3>,
		_applyTheme: ThrottledFunction.ThrottledFunction<any?>,
	},
	{} :: typeof({ __index = ThemeService })
))

function ThemeService.Init(self: ThemeService)
	self._maid = Maid.new()
	self._themeMap = self._maid:Add(ObservableMap.new())
	self._applyTheme = self._maid:Add(ThrottledFunction.new(1 / 6, function()
		local theme = settings().Studio.Theme

		for _, child in Enum.StudioStyleGuideColor:GetEnumItems() do
			self._themeMap:Set(child, theme:GetColor(child))
		end
	end, { leading = false, trailing = true, leadingFirstTimeOnly = true }))
end

function ThemeService.Start(self: ThemeService)
	self._applyTheme:Call()

	self._maid:GiveTask(settings().Studio.ThemeChanged:Connect(function()
		self._applyTheme:Call()
	end))
end

function ThemeService.ObserveThemeColor(self: ThemeService, key: Enum.StudioStyleGuideColor)
	return self._themeMap:ObserveAtKey(key)
end

function ThemeService.Destroy(self: ThemeService)
	self._maid:DoCleaning()
end

return ThemeService
