-- Server Script (place in ServerScriptService)
-- This script activates the mc test when players interact with the blackboard

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local GrammarTestModule = nil -- find the module script urself

-- Look in workspace for a part named "Blackboard" that has the SurfaceGui
local blackboard = nil -- find the blackboard yourself

-- Function to start the test when conditions are met
local function startGrammarGame()
    -- You might want to check if there are enough players or if the game isn't already running
    if -- [Add condition] then
        GrammarTestModule.startGrammarTest(blackboard)
    else
        warn("Cannot start grammar test: conditions not met")
    end
end

-- [Choose an activation method]
-- You can use any of these methods to start the game:

-- Option A: Start when a player clicks the blackboard
-- blackboard.Touched:Connect(function(hit)
--     local player = Players:GetPlayerFromCharacter(hit.Parent)
--     if player then
--         startGrammarGame()
--     end
-- end)

-- Option B: Start automatically when enough players join
-- Players.PlayerAdded:Connect(function(player)
--     if #Players:GetPlayers() >= 1 then
--         wait(5) -- Wait a bit for players to load in
--         startGrammarGame()
--     end
-- end)

-- Option C: Start via remote event (for GUI buttons)
-- local EnglishRemote = blah blah
-- 
-- EnglishRemote.OnServerEvent:Connect(function(player)
--     startGrammarGame()
-- end)

-- [Handle player joining]
-- You might want to initialize something when players join the game
-- Players.PlayerAdded:Connect(function(player)
--     -- [ADD INITIALIZATION CODE HERE]
-- end)

print("[Quiz system] MC test server script loaded - waiting for activation...")
