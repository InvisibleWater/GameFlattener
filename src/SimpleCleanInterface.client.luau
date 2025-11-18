local StarterGui = game:GetService("StarterGui")

--Since we're not loading any characters in, some CoreGui options still have to be disabled.
local typesToDisable = {
	Enum.CoreGuiType.Backpack,
	Enum.CoreGuiType.Health,
	Enum.CoreGuiType.EmotesMenu,
	Enum.CoreGuiType.SelfView,
}

for _, coreGuiType in typesToDisable do
	StarterGui:SetCoreGuiEnabled(coreGuiType, false)
end

--Remove topbar. It only gets in the way.
for i = 1, 10 do
	local ok = pcall(StarterGui.SetCore, StarterGui, "TopbarEnabled", false)

	if ok then
		break
	end

	task.wait(i)
end
