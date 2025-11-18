local StarterGui = game:GetService("StarterGui")

--For a singleplayer game, most of the core interface is unnecessary, so we're disabling it.
--Captures gets to stay, though.
local typesToDisable = {
	Enum.CoreGuiType.Chat,
	Enum.CoreGuiType.PlayerList,
	Enum.CoreGuiType.Backpack,
	Enum.CoreGuiType.Health,
	Enum.CoreGuiType.EmotesMenu,
	Enum.CoreGuiType.SelfView,
}

for _, coreGuiType in typesToDisable do
	StarterGui:SetCoreGuiEnabled(coreGuiType, false)
end

--Remove the topbar, too.
for i = 1, 10 do
	local ok = pcall(StarterGui.SetCore, StarterGui, "TopbarEnabled", false)

	if ok then
		break
	end

	task.wait(i)
end
