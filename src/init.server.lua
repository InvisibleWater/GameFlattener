local ChangeHistoryService = game:GetService("ChangeHistoryService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local TextChatService = game:GetService("TextChatService")

local loader = script.Parent:FindFirstChild("LoaderUtils", true).Parent
local require = require(loader).bootstrapPlugin(script)

local BasicPaneUtils = require("BasicPaneUtils")
local Maid = require("Maid")
local OptimizeMenu = require("OptimizeMenu")
local RxBrioUtils = require("RxBrioUtils")
local RxInstanceUtils = require("RxInstanceUtils")
local ServiceBag = require("ServiceBag")
local safeDestroy = require("safeDestroy")

local maid = Maid.new()
local serviceBag = maid:GiveTask(ServiceBag.new())

local PluginSettingsService = serviceBag:GetService(require("PluginSettingsService"))
serviceBag:GetService(require("ThemeService"))

serviceBag:Init()

local pluginSettings = {
	DisableWorkspace = plugin:GetSetting("DisableWorkspace") or false,
	Singleplayer = plugin:GetSetting("Singleplayer") or false,
}

PluginSettingsService:ObserveSettingsBrio():Subscribe(function(brio)
	plugin:SetSetting(brio:GetValue())
end)

for index, child in pluginSettings do
	PluginSettingsService:SetSetting(index, child)
end

serviceBag:Start()

local playerFolderNames = { "PlayerModule", "RbxCharacterSounds", "PlayerScriptsLoader" }

local toolbar = plugin:CreateToolbar("Game Flattener")
local button = toolbar:CreateButton(
	"GameFlattener",
	"Optimize your game for 2D, sprite-based gameplay",
	"rbxassetid://75931739347470",
	"Optimize"
)
button.ClickableWhenViewportHidden = true

local widget = plugin:CreateDockWidgetPluginGui(
	"GameFlattener",
	DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 200, 250, 175, 125)
)

button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

local function basicClean()
	Players.CharacterAutoLoads = false

	StarterPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable
	StarterPlayer.DevTouchMovementMode = Enum.DevTouchMovementMode.Scriptable

	for i = 1, 3 do
		local new = Instance.new("Folder")
		new.Name = playerFolderNames[i]
		new.Parent = StarterPlayer.StarterPlayerScripts
	end

	GuiService.ScreenshotHud.HidePlayerGuiForCaptures = false
end

local function cleanWorkspace()
	game.Workspace.Gravity = 0
	game.Workspace.CurrentCamera.CFrame = CFrame.new()
	game.Workspace.CurrentCamera.Focus = CFrame.new()
	game.Workspace.CurrentCamera.FieldOfView = 0
	game.Workspace.CurrentCamera.DiagonalFieldOfView = 0

	game.Workspace.Terrain:Clear()

	for _, child in ipairs(game.Workspace:GetDescendants()) do
		if child:IsA("PVInstance") and (child ~= game.Workspace.Terrain or child ~= game.Workspace.CurrentCamera) then
			safeDestroy(child)
		end
	end
end

local function cleanLighting()
	Lighting:ClearAllChildren()

	Lighting.Ambient = Color3.new()
	Lighting.Brightness = 0
	Lighting.ExposureCompensation = 0
	Lighting.GeographicLatitude = 0
	Lighting.ClockTime = 0
	Lighting.ColorShift_Bottom = Color3.new()
	Lighting.ColorShift_Top = Color3.new()
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.GlobalShadows = false
	Lighting.OutdoorAmbient = Color3.new()
	Lighting.FogStart = 0
	Lighting.FogEnd = 0
	Lighting.FogColor = Color3.new()

	local sky = Instance.new("Sky")
	sky.CelestialBodiesShown = false
	sky.MoonAngularSize = 0
	sky.SunAngularSize = 0
	sky.StarCount = 0
	sky.SunTextureId = "rbxassetid://398833951"
	sky.MoonTextureId = "rbxassetid://398833951"
	sky.SkyboxBk = "rbxassetid://398833951"
	sky.SkyboxDn = "rbxassetid://398833951"
	sky.SkyboxFt = "rbxassetid://398833951"
	sky.SkyboxLf = "rbxassetid://398833951"
	sky.SkyboxRt = "rbxassetid://398833951"
	sky.SkyboxUp = "rbxassetid://398833951"
	sky.SkyboxOrientation = Vector3.zero
	sky.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Size = 0
	bloom.Intensity = 0
	bloom.Threshold = math.huge
	bloom.Parent = Lighting
end

local function cleanInterface(full)
	if full then
		local clean = script.FullCleanInterface:Clone()
		clean.Enabled = true
		clean.Parent = ReplicatedFirst

		TextChatService.CreateDefaultCommands = false
		TextChatService.CreateDefaultTextChannels = false

		TextChatService.ChatWindowConfiguration.Enabled = false
		TextChatService.ChatInputBarConfiguration.Enabled = false
		TextChatService.ChannelTabsConfiguration.Enabled = false
		TextChatService.BubbleChatConfiguration.Enabled = false
	else
		local clean = script.SimpleCleanInterface:Clone()
		clean.Enabled = true
		clean.Parent = ReplicatedFirst

		TextChatService.CreateDefaultCommands = true
		TextChatService.CreateDefaultTextChannels = true

		TextChatService.ChatWindowConfiguration.Enabled = true
		TextChatService.ChatInputBarConfiguration.Enabled = true
		TextChatService.ChannelTabsConfiguration.Enabled = true
		TextChatService.BubbleChatConfiguration.Enabled = false
	end

	local freecamClean = script.RemoveFreecam:Clone()
	freecamClean.Enabled = true
	freecamClean.Parent = ServerScriptService
end

local function doCleaning()
	print("Beginning flattening process...")

	ChangeHistoryService:TryBeginRecording("CleanUpFor2DGaming")

	basicClean()

	if plugin:GetSetting("DisableWorkspace") then
		cleanWorkspace()
		cleanLighting()
	end

	cleanInterface(plugin:GetSetting("Singleplayer"))

	ChangeHistoryService:FinishRecording("CleanUpFor2DGaming", Enum.FinishRecordingOperation.Commit)

	print("Done! Your game is now ready for sprites!")
end

maid:GiveTask(RxInstanceUtils.observeProperty(widget, "Enabled")
	:Pipe {
		BasicPaneUtils.whenVisibleBrio(function(innerMaid)
			local menu = OptimizeMenu.new(serviceBag)

			innerMaid:GiveTask(menu.Clicked:Connect(doCleaning))

			return menu
		end),
		RxBrioUtils.flattenToValueAndNil,
	}
	:Subscribe(function(gui)
		if gui then
			gui.Parent = widget
		end
	end))

plugin.Unloading:Connect(function()
	maid:DoCleaning()
end)
