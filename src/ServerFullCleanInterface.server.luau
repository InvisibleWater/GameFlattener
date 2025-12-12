local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local function handlePlayerAdded(player)
	local playerGui = player:WaitForChild("PlayerGui")

	playerGui:WaitForChild("Freecam"):Destroy()
end

Players.PlayerAdded:Connect(handlePlayerAdded)

for _, player in Players:GetPlayers() do
	task.spawn(handlePlayerAdded, player)
end

local function handleDescendants(descendant)
	if descendant:IsA("TextChatConfigurations") then
		descendant.Enabled = false
	else
		task.defer(descendant.Destroy, descendant)
	end
end

TextChatService.DescendantAdded:Connect(handleDescendants)
