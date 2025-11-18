local Players = game:GetService("Players")

local function handlePlayerAdded(player)
	local playerGui = player:WaitForChild("PlayerGui")

	playerGui:WaitForChild("Freecam"):Destroy()
end

Players.PlayerAdded:Connect(handlePlayerAdded)

for _, player in Players:GetPlayers() do
	task.spawn(handlePlayerAdded, player)
end
