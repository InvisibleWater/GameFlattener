local require = require(script.Parent.loader).load(script)

local BasicPane = require("BasicPane")
local Blend = require("Blend")
local Maid = require("Maid")
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")
local ThemeService = require("ThemeService")
local ValueObject = require("ValueObject")

local BoolSlider = setmetatable({}, BasicPane)
BoolSlider.__index = BoolSlider

export type BoolSlider =
	typeof(setmetatable(
		{} :: {
			_maid: Maid.Maid,
			Gui: GuiObject,
			_active: ValueObject.ValueObject<boolean>,
			_themes: ThemeService.ThemeService,
			ActiveChanged: Signal.Signal<(boolean, boolean, ...any)>,
		},
		{} :: typeof({ __index = BoolSlider })
	))
	& BasicPane.BasicPane

function BoolSlider.new(default: boolean, serviceBag: ServiceBag.ServiceBag): BoolSlider
	local self = setmetatable(BasicPane.new(), BoolSlider)

	self._active = self._maid:Add(ValueObject.new(default or false, "boolean"))
	self._themes = serviceBag:GetService(ThemeService)

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	self.ActiveChanged = self._active.Changed

	return self
end

function BoolSlider._render(self: BoolSlider)
	return Blend.New "Frame" {
		BackgroundTransparency = 1,
		Blend.New "TextButton" {
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.75, 0.75),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = self._themes:ObserveThemeColor(Enum.StudioStyleGuideColor.MainButton),
			[Blend.OnEvent "MouseButton1Click"] = function()
				self:Toggle()
			end,
			Blend.New "UICorner" {
				CornerRadius = UDim.new(1, 0),
			},
			Blend.New "UIAspectRatioConstraint" {
				AspectRatio = 2,
			},
			Blend.New "Frame" {
				Position = Blend.Computed(self._active, function(active)
					return UDim2.fromScale(active and 1 or 0, 0.5)
				end),
				Size = UDim2.fromScale(1.5, 1.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = self._themes:ObserveThemeColor(Enum.StudioStyleGuideColor.MainButton),
				Blend.New "UICorner" {
					CornerRadius = UDim.new(1, 0),
				},
				Blend.New "UIAspectRatioConstraint" {
					AspectRatio = 1,
				},
			},
		},
	}
end

function BoolSlider.Toggle(self: BoolSlider)
	self._active.Value = not self._active.Value
end

function BoolSlider.Observe(self: BoolSlider)
	return self._active:Observe()
end

return BoolSlider
