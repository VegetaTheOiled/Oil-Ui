local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- GUI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Create a GUI button
local function createButton(name, position, color)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 150, 0, 40)
	button.Position = position
	button.Text = name
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 20
	button.Draggable = true
	button.Active = true
	button.Parent = screenGui
	return button
end

-- Teleport to a BasePart
local function teleportTo(part)
	if character and character:FindFirstChild("HumanoidRootPart") and part then
		character:MoveTo(part.Position)
	end
end

-- Get the closest floor model (works for any number of floors)
local function getCurrentFloor()
	local map = workspace:FindFirstChild("Map")
	if not map then return nil end

	local closestFloor = nil
	local closestDist = math.huge
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return nil end

	for _, child in pairs(map:GetChildren()) do
		if child:IsA("Model") and child.Name:lower():match("^floor") then
			local base = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
			if base then
				local dist = math.abs(rootPart.Position.Y - base.Position.Y)
				if dist < closestDist then
					closestDist = dist
					closestFloor = child
				end
			end
		end
	end

	return closestFloor
end

-- Simulate "E" key press using VirtualInputManager
local function simulateEKey()
	task.wait(0.1)
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
end

-- Button: Teleport to Pipe
local pipeButton = createButton("Teleport to Pipe", UDim2.new(0, 100, 0, 100), Color3.fromRGB(0, 170, 255))
pipeButton.MouseButton1Click:Connect(function()
	local floor = getCurrentFloor()
	if floor then
		local geometry = floor:FindFirstChild("Geometry")
		if geometry then
			local pipe = geometry:FindFirstChild("Pipe")
			if pipe and pipe:IsA("BasePart") then
				teleportTo(pipe)
			end
		end
	end
end)

-- Button: Teleport to Enemy & simulate "E"
local enemyButton = createButton("Teleport to Enemy", UDim2.new(0, 100, 0, 160), Color3.fromRGB(255, 85, 85))
enemyButton.MouseButton1Click:Connect(function()
	local enemies = workspace:FindFirstChild("Enemies")
	if enemies then
		for _, enemy in pairs(enemies:GetChildren()) do
			if enemy:IsA("Actor") then
				local part = enemy.PrimaryPart or enemy:FindFirstChildWhichIsA("BasePart")
				if part then
					teleportTo(part)
					simulateEKey()
					break
				end
			end
		end
	end
end)