local StarterGui = game:GetService("StarterGui")

--For a singleplayer game, most of the core interface is unnecessary, so we're disabling it.
--Captures gets to stay, though.

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Captures, true)

--Remove the topbar, too.
for i = 1, 10 do
	local ok = pcall(StarterGui.SetCore, StarterGui, "TopbarEnabled", false)

	if ok then
		break
	end

	task.wait(i)
end
