local ChangeHistoryService = game:GetService("ChangeHistoryService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
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
local serviceBag = maid:Add(ServiceBag.new())

local skySaveSettings =
	{ "SkyboxUp", "SkyboxDn", "SkyboxLf", "SkyboxRt", "SkyboxFt", "SkyboxBk", "SunTextureId", "MoonTextureId" }
local blankPixel = "rbxassetid://398833951"

maid:GiveTask(RxInstanceUtils.observeLastNamedChildBrio(Lighting, "Sky", "Sky"):Subscribe(function(brio)
	local innerMaid, sky = brio:ToMaidAndValue()

	for _, property in skySaveSettings do
		innerMaid:GiveTask(RxInstanceUtils.observeProperty(sky, property):Subscribe(function(value)
			if value ~= blankPixel then
				plugin:SetSetting(property, value)
			end
		end))
	end
end))

maid:GiveTask(RxInstanceUtils.observeDescendants(script, function(x)
	return x:IsA("Script") or x:IsA("LocalScript")
end):Subscribe(function(obj, adding)
	if adding then
		obj.Enabled = false
	end
end))

local PluginSettingsService = serviceBag:GetService(require("PluginSettingsService"))
serviceBag:GetService(require("ThemeService"))

serviceBag:Init()

local pluginSettings = {
	DisableWorkspace = plugin:GetSetting("DisableWorkspace") or false,
	Singleplayer = plugin:GetSetting("Singleplayer") or false,
	LightingCleared = plugin:GetSetting("LightingCleared") or false,
	WorkspaceCleared = plugin:GetSetting("WorkspaceCleared") or false,
	InstanceName = plugin:GetSetting("InstanceName") or HttpService:GenerateGUID(),
}

for index, child in pluginSettings do
	PluginSettingsService:SetSetting(index, child)
end

PluginSettingsService:ObserveSettingsBrio():Subscribe(function(brio)
	plugin:SetSetting(brio:GetValue())
end)

serviceBag:Start()

local playerFolderNames = { "PlayerModule", "RbxCharacterSounds", "PlayerScriptsLoader" }

local toolbar = plugin:CreateToolbar("Game Flattener")
local button = toolbar:CreateButton(
	"GameFlattener",
	"Optimize your game for 2D, sprite-based gameplay",
	"rbxassetid://75931739347470",
	"Game Flattener"
)
button.ClickableWhenViewportHidden = true

local widget = plugin:CreateDockWidgetPluginGui(
	"GameFlattener",
	DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 200, 250, 175, 125)
)
widget.Title = "Game Flattener"
widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
widget.Name = "GameFlattener"

button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

local function basicClean()
	Players.CharacterAutoLoads = false

	StarterPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable
	StarterPlayer.DevTouchMovementMode = Enum.DevTouchMovementMode.Scriptable

	for i = 1, 3 do
		local old = StarterPlayer.StarterPlayerScripts:FindFirstChild(playerFolderNames[i])
		if old then
			old:Destroy()
		end

		local new = Instance.new("Folder")
		new.Name = playerFolderNames[i]
		new.Parent = StarterPlayer.StarterPlayerScripts
	end

	GuiService.ScreenshotHud.HidePlayerGuiForCaptures = false
end

local function cleanLighting(shouldClean)
	if shouldClean then
		local oldSky = Lighting:FindFirstChildOfClass("Sky")
		if oldSky then
			for i = 1, #skySaveSettings do
				local key = skySaveSettings[i]

				if oldSky[key] ~= blankPixel then
					plugin:SetSetting(key, oldSky[key])
				end
			end
		end

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
		sky.SunTextureId = blankPixel
		sky.MoonTextureId = blankPixel
		sky.SkyboxBk = blankPixel
		sky.SkyboxDn = blankPixel
		sky.SkyboxFt = blankPixel
		sky.SkyboxLf = blankPixel
		sky.SkyboxRt = blankPixel
		sky.SkyboxUp = blankPixel
		sky.SkyboxOrientation = Vector3.zero
		sky.Parent = Lighting

		local bloom = Instance.new("BloomEffect")
		bloom.Name = plugin:GetSetting("InstanceName")
		bloom.Size = 0
		bloom.Intensity = 0
		bloom.Threshold = math.huge
		bloom.Parent = Lighting

		plugin:SetSetting("LightingCleared", true)
	elseif plugin:GetSetting("LightingCleared") then
		Lighting:ResetPropertyToDefault("Ambient")
		Lighting:ResetPropertyToDefault("Brightness")
		Lighting:ResetPropertyToDefault("ExposureCompensation")
		Lighting:ResetPropertyToDefault("GeographicLatitude")
		Lighting:ResetPropertyToDefault("ClockTime")
		Lighting:ResetPropertyToDefault("ColorShift_Bottom")
		Lighting:ResetPropertyToDefault("ColorShift_Top")
		Lighting:ResetPropertyToDefault("EnvironmentDiffuseScale")
		Lighting:ResetPropertyToDefault("EnvironmentSpecularScale")
		Lighting:ResetPropertyToDefault("GlobalShadows")
		Lighting:ResetPropertyToDefault("OutdoorAmbient")
		Lighting:ResetPropertyToDefault("FogStart")
		Lighting:ResetPropertyToDefault("FogEnd")
		Lighting:ResetPropertyToDefault("FogColor")

		local bloom = Lighting:FindFirstChild(plugin:GetSetting("InstanceName"))
		if bloom then
			bloom:Destroy()
		end

		local sky = Lighting:FindFirstChildOfClass("Sky")
		if sky then
			sky:ResetPropertyToDefault("CelestialBodiesShown")
			sky:ResetPropertyToDefault("MoonAngularSize")
			sky:ResetPropertyToDefault("SunAngularSize")
			sky:ResetPropertyToDefault("StarCount")
			sky:ResetPropertyToDefault("SkyboxOrientation")

			for i = 1, #skySaveSettings do
				local key = skySaveSettings[i]
				local value = plugin:GetSetting(key)

				if value then
					sky[key] = value
				else
					sky:ResetPropertyToDefault(key)
				end
			end
		else
			sky = Instance.new("Sky")

			for i = 1, #skySaveSettings do
				local key = skySaveSettings[i]
				local value = plugin:GetSetting(key)

				if value then
					sky[key] = value
				end
			end

			sky.Parent = Lighting
		end

		plugin:SetSetting("LightingCleared", false)
	end
end

local function cleanWorkspace(shouldClean)
	if shouldClean then
		game.Workspace.Gravity = 0
		game.Workspace.CurrentCamera.CFrame = CFrame.new()
		game.Workspace.CurrentCamera.Focus = CFrame.new()
		game.Workspace.CurrentCamera.FieldOfView = 0
		game.Workspace.CurrentCamera.DiagonalFieldOfView = 0

		game.Workspace.Terrain:Clear()

		for _, child in ipairs(game.Workspace:GetDescendants()) do
			if child:IsA("Camera") or child:IsA("Terrain") then
				continue
			end

			if child:IsA("PVInstance") then
				safeDestroy(child)
			end
		end

		plugin:SetSetting("WorkspaceCleared", true)
	elseif plugin:GetSetting("WorkspaceCleared") then
		game.Workspace.CurrentCamera:Destroy()
		game.Workspace.Gravity = 196.2

		plugin:SetSetting("WorkspaceCleared", false)
	end

	cleanLighting(shouldClean)
end

local function removeScript(parent, base)
	local result = parent:FindFirstChild(base.Name, true)
	local destroyed = false

	while not destroyed do
		if result then
			if result:IsA("LuaSourceContainer") and result.Source == base.Source then
				safeDestroy(result)

				destroyed = true
			end

			result = parent:FindFirstChild(base.Name, true)
		else
			destroyed = true
		end
	end
end

local function cleanInterface(full)
	removeScript(ReplicatedFirst, script.FullCleanInterface)
	removeScript(ReplicatedFirst, script.SimpleCleanInterface)
	removeScript(ServerScriptService, script.ServerSimpleCleanInterface)
	removeScript(ServerScriptService, script.ServerFullCleanInterface)

	if full then
		local clean = script.FullCleanInterface:Clone()
		clean.Enabled = true
		clean.Parent = ReplicatedFirst

		local freecamClean = script.ServerSimpleCleanInterface:Clone()
		freecamClean.Enabled = true
		freecamClean.Parent = ServerScriptService

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

		local freecamClean = script.ServerFullCleanInterface:Clone()
		freecamClean.Enabled = true
		freecamClean.Parent = ServerScriptService

		TextChatService.CreateDefaultCommands = true
		TextChatService.CreateDefaultTextChannels = true

		TextChatService.ChatWindowConfiguration.Enabled = true
		TextChatService.ChatInputBarConfiguration.Enabled = true
		TextChatService.ChannelTabsConfiguration.Enabled = true
		TextChatService.BubbleChatConfiguration.Enabled = false
	end
end

local function doCleaning()
	if ChangeHistoryService:IsRecordingInProgress() then
		return
	end

	print("Beginning flattening process...")

	local record = ChangeHistoryService:TryBeginRecording("CleanUpFor2DGaming")

	if record == nil then
		return
	end

	basicClean()
	cleanWorkspace(plugin:GetSetting("DisableWorkspace"))
	cleanInterface(plugin:GetSetting("Singleplayer"))

	ChangeHistoryService:FinishRecording(record, Enum.FinishRecordingOperation.Commit)

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
