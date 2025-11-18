local require = require(script.Parent.loader).load(script)

local BasicPane = require("BasicPane")
local Blend = require("Blend")
local BoolSlider = require("BoolSlider")
local Maid = require("Maid")
local ObservableMapList = require("ObservableMapList")
local PluginSettingsService = require("PluginSettingsService")
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")
local ThemeService = require("ThemeService")
local ValueObject = require("ValueObject")

local OptimizeMenu = setmetatable({}, BasicPane)
OptimizeMenu.__index = OptimizeMenu

export type OptimizeMenu =
	typeof(setmetatable(
		{} :: {
			_maid: Maid.Maid,
			Gui: GuiObject,
			_highlightedOption: ValueObject.ValueObject<string>,
			_highlightText: ObservableMapList.ObservableMapList<string, string>,
			_disableWorkspace: BoolSlider.BoolSlider,
			_singleplayer: BoolSlider.BoolSlider,
			_settingsService: PluginSettingsService.PluginSettingsService,
			_themeService: ThemeService.ThemeService,
			Clicked: Signal.Signal<()>,
		},
		{} :: typeof({ __index = OptimizeMenu })
	))
	& BasicPane.BasicPane

function OptimizeMenu.new(serviceBag: ServiceBag.ServiceBag): OptimizeMenu
	local self = setmetatable(BasicPane.new(), OptimizeMenu)

	self._highlightedOption = self._maid:Add(ValueObject.new("", "string"))
	self._highlightText = self._maid:Add(ObservableMapList.new())
	self._settingsService = serviceBag:GetService(PluginSettingsService)
	self._themeService = serviceBag:GetService(ThemeService)
	self.Clicked = self._maid:Add(Signal.new())

	self._disableWorkspace =
		self._maid:Add(BoolSlider.new(self._settingsService:GetSetting("DisableWorkspace"), serviceBag))
	self._disableWorkspace.Gui.Position = UDim2.fromScale(0.75, 0)
	self._disableWorkspace.Gui.Size = UDim2.fromScale(0.25, 1)

	self._singleplayer = self._maid:Add(BoolSlider.new(self._settingsService:GetSetting("Singleplayer"), serviceBag))
	self._singleplayer.Gui.Position = UDim2.fromScale(0.75, 0)
	self._singleplayer.Gui.Size = UDim2.fromScale(0.25, 1)

	self._maid:GiveTask(self._disableWorkspace.ActiveChanged:Connect(function(new)
		self._settingsService:SetSetting("DisableWorkspace", new)
	end))

	self._maid:GiveTask(self._singleplayer.ActiveChanged:Connect(function(new)
		self._settingsService:SetSetting("Singleplayer", new)
	end))

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function OptimizeMenu._render(self: OptimizeMenu)
	return Blend.New "Frame" {
		Position = UDim2.new(),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = self._themeService:ObserveThemeColor(Enum.StudioStyleGuideColor.MainBackground),
		Blend.New "TextButton" {
			Position = UDim2.new(),
			Size = UDim2.fromScale(1, 0.25),
			BackgroundTransparency = 1,
			Blend.New "TextLabel" {
				Position = UDim2.new(),
				Size = UDim2.fromScale(0.75, 1),
				BackgroundTransparency = 1,
				Text = "Clear Workspace",
				TextColor3 = self._themeService:ObserveThemeColor(Enum.StudioStyleGuideColor.BrightText),
				TextXAlignment = Enum.TextXAlignment.Left,
			},
			[Blend.OnEvent "MouseEnter"] = function()
				self._maid._currentOption = self._highlightedOption:SetValue("DisableWorkspace")
			end,
			[Blend.OnEvent "MouseButton1Click"] = function()
				self._disableWorkspace:Toggle()
			end,
			self._disableWorkspace.Gui,
		},
		Blend.New "TextButton" {
			Position = UDim2.fromScale(0, 0.25),
			Size = UDim2.fromScale(1, 0.25),
			BackgroundTransparency = 1,
			Blend.New "TextLabel" {
				Position = UDim2.new(),
				Size = UDim2.fromScale(0.75, 1),
				BackgroundTransparency = 1,
				Text = "Single Player",
				TextColor3 = self._themeService:ObserveThemeColor(Enum.StudioStyleGuideColor.BrightText),
				TextXAlignment = Enum.TextXAlignment.Left,
			},
			[Blend.OnEvent "MouseEnter"] = function()
				self._maid._currentOption = self._highlightedOption:SetValue("Singleplayer")
			end,
			[Blend.OnEvent "MouseButton1Click"] = function()
				self._singleplayer:Toggle()
			end,
			self._singleplayer.Gui,
		},
		Blend.New "TextLabel" {
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(1, 2 / 6),
			BackgroundTransparency = 1,
			TextColor3 = self._themeService:ObserveThemeColor(Enum.StudioStyleGuideColor.BrightText),
			Text = Blend.Computed(
				self._highlightedOption,
				self._disableWorkspace,
				self._singleplayer,
				function(option, a, b)
					local index = 1
					if option == "DisableWorkspace" then
						index += a and 1 or 0
					elseif option == "Singleplayer" then
						index += b and 1 or 0
					else
						return ""
					end

					return self._highlightText:GetAtListIndex(option, index)
				end
			),
			TextWrapped = true,
		},
		Blend.New "TextButton" {
			Position = UDim2.fromScale(0, 5 / 6),
			Size = UDim2.fromScale(1, 1 / 6),
			BackgroundColor3 = self._themeService:ObserveThemeColor(Enum.StudioStyleGuideColor.MainButton),
			TextColor3 = self._themeService:ObserveThemeColor(Enum.StudioStyleGuideColor.ButtonText),
			Text = "Optimize",
			Font = Enum.Font.SourceSansBold,
			AutoButtonColor = true,
			Blend.New "UICorner" {
				CornerRadius = UDim.new(0.1, 0),
			},
			[Blend.OnEvent "MouseButton1Click"] = self.Clicked,
		},
		Blend.New "UIPadding" {
			PaddingBottom = UDim.new(0.05, 0),
			PaddingTop = UDim.new(0.05, 0),
			PaddingLeft = UDim.new(0.05, 0),
			PaddingRight = UDim.new(0.05, 0),
		},
		[Blend.OnEvent "MouseLeave"] = function()
			self._maid._currentOption = nil
		end,
		[Blend.Attached(function()
			local maid = Maid.new()

			maid:GiveTask(
				self._highlightText:Push(
					"DisableWorkspace",
					"Leave Workspace and Lighting untouched.\nUseful if 3D backgrounds are needed and ViewportFrames aren't enough for that."
				)
			)
			maid:GiveTask(
				self._highlightText:Push(
					"DisableWorkspace",
					"Modifies Workspace and Lighting so that the 3D environment does as little work as possible."
				)
			)
			maid:GiveTask(
				self._highlightText:Push(
					"Singleplayer",
					"Disable interface elements that aren't needed for a 2D, sprite-based experience."
				)
			)
			maid:GiveTask(
				self._highlightText:Push(
					"Singleplayer",
					"Disable interface elements that aren't needed for a 2D, sprite-based experience, including the player list and chat."
				)
			)

			return maid
		end)] = true,
	}
end

return OptimizeMenu
