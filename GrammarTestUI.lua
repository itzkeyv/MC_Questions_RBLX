-- This is the local script in StarterPlayerScripts
local player = game:GetService("Players").LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for blackboard GUI
local blackboard = workspace:WaitForChild("Blackboard")
local surfaceGui = blackboard:WaitForChild("SurfaceGui")

-- Remote event connections
local answerSelectedConnection
local updateButtonConnection

-- Function to initialize the test UI
local function initializeTest()
	-- Get remote events
	local EnglishRemotes = ReplicatedStorage:WaitForChild("EnglishRemotes")
	local AnswerSelectedEvent = EnglishRemotes:WaitForChild("AnswerSelectedEvent")
	local UpdateButtonEvent = EnglishRemotes:WaitForChild("UpdateButtonEvent")

	-- Get buttons
	local buttons = {
		A = surfaceGui:WaitForChild("AButton"),
		B = surfaceGui:WaitForChild("BButton"),
		C = surfaceGui:WaitForChild("CButton"),
		D = surfaceGui:WaitForChild("DButton")
	}

	-- Set up button click handlers
	for option, button in pairs(buttons) do
		button.MouseButton1Click:Connect(function()
			AnswerSelectedEvent:FireServer(option)
		end)
	end

	-- Handle button visual updates
	updateButtonConnection = UpdateButtonEvent.OnClientEvent:Connect(function(option, isSelected)
		local button = buttons[option]
		if button then
			if isSelected then
				-- Visual feedback for selected answer
				button.BackgroundColor3 = Color3.fromRGB(122, 230, 122) -- Green
				button.TextColor3 = Color3.fromRGB(0, 0, 0) -- Black text
			else
				-- Reset to default appearance
				button.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White
				button.TextColor3 = Color3.fromRGB(0, 0, 0) -- Black text
			end
		end
	end)
end

-- Function to clean up the test UI
local function cleanupTest()
	if answerSelectedConnection then
		answerSelectedConnection:Disconnect()
		answerSelectedConnection = nil
	end

	if updateButtonConnection then
		updateButtonConnection:Disconnect()
		updateButtonConnection = nil
	end
end

-- Initialize when script is enabled
initializeTest()

-- Clean up when script is disabled
script.AncestryChanged:Connect(function()
	if not script:IsDescendantOf(game) then
		cleanupTest()
	end
end)
