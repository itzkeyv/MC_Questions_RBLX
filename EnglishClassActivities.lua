-- This is the module script in ReplicationStorage
local module = {}

-- questions table (30 in total, very crazy)
local questions = {
	{
		question = "Which sentence is grammatically correct?", --Q1
		options = {
			"A. She don't like apples.",
			"B. She doesn't likes apples.",
			"C. She doesn't like apples.",
			"D. She is not like apples."
		},
		correctAnswer = "C"
	},

-- Modify the questions and whatever, like this

	{
		question = "Ice cream is made _____ milk.", --Q2
		options = {
			"A. of",
			"B. up of",
			"C. from",
			"D. with"
		},
		correctAnswer = "C"
	},

	{
		question = "Can I call myself a dev for stealing free models from youtube and call 'em mine?", --Q3
		options = {
			"A. Ofc Idk how to code at all",
			"B. Yeah I never learnt from them",
			"C. No I do study from free models",
			"D. Are you mocking me? 😭😭"
		},
		correctAnswer = "D"
	}
}

-- Cache services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Constants
local QUESTION_TIME_LIMIT = 10
local RESULT_DISPLAY_TIME = 5
local BETWEEN_QUESTION_DELAY = 5

-- Fisher-Yates shuffle algorithm
local function shuffleQuestions(questionList)
	local shuffled = {}
	for i, question in ipairs(questionList) do
		shuffled[i] = question
	end

	for i = #shuffled, 2, -1 do
		local j = math.random(i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end

	return shuffled
end

-- Remote events management
local function setupRemotes()
	local EnglishRemotes = Instance.new("Folder") -- this is to activate the minigame
	EnglishRemotes.Name = "EnglishRemotes"
	EnglishRemotes.Parent = ReplicatedStorage

	local AnswerSelectedEvent = Instance.new("RemoteEvent") --literally what it means
	AnswerSelectedEvent.Name = "AnswerSelectedEvent"
	AnswerSelectedEvent.Parent = EnglishRemotes

	local UpdateButtonEvent = Instance.new("RemoteEvent") --yeah
	UpdateButtonEvent.Name = "UpdateButtonEvent"
	UpdateButtonEvent.Parent = EnglishRemotes

	return {
		AnswerSelectedEvent = AnswerSelectedEvent,
		UpdateButtonEvent = UpdateButtonEvent
	}
end

-- Function to start the English minigame
function module.startGrammarTest(blackboard)
	local EnglishRemotes = setupRemotes()
	local surfaceGui = blackboard:FindFirstChild("SurfaceGui")
	if not surfaceGui then return end

	-- Get UI elements
	local elements = {
		reminderText = surfaceGui:FindFirstChild("ReminderText"),
		questionTitle = surfaceGui:FindFirstChild("QuestionTitle"),
		aButton = surfaceGui:FindFirstChild("AButton"),
		bButton = surfaceGui:FindFirstChild("BButton"),
		cButton = surfaceGui:FindFirstChild("CButton"),
		dButton = surfaceGui:FindFirstChild("DButton")
	}

	-- Hide all interactive elements initially
	for _, element in pairs(elements) do
		if element then element.Visible = false end
	end

	-- Initial countdown
	elements.reminderText.Visible = true
	for i = 10, 1, -1 do
		elements.reminderText.Text = "English Grammar Test starting in "..i.." seconds..."
		task.wait(1)
	end

	-- Prepare questions
	local testQuestions = {}
	local shuffled = shuffleQuestions(questions)
	for i = 1, math.min(6, #shuffled) do
		table.insert(testQuestions, shuffled[i])
	end

	-- Track scores
	local playerScores = {}
	for _, player in ipairs(Players:GetPlayers()) do
		playerScores[player] = 0
	end

	-- Main test loop
	for questionNum, currentQuestion in ipairs(testQuestions) do
		local playerAnswers = {}  -- Reset for each question

		-- Create a new connection for each question
		local connection = EnglishRemotes.AnswerSelectedEvent.OnServerEvent:Connect(function(player, answer)
			if not playerAnswers[player] then
				playerAnswers[player] = answer
				if answer == currentQuestion.correctAnswer then
					playerScores[player] = playerScores[player] + 1
				end
				-- Notify client to update button visuals
				EnglishRemotes.UpdateButtonEvent:FireClient(player, answer, true)
			end
		end)

		-- Show question
		elements.reminderText.Visible = false
		elements.questionTitle.Text = "Question "..questionNum..": "..currentQuestion.question
		elements.questionTitle.Visible = true

		-- Show and update buttons
		local buttons = {
			A = elements.aButton,
			B = elements.bButton,
			C = elements.cButton,
			D = elements.dButton
		}

		for option, button in pairs(buttons) do
			button.Text = currentQuestion.options[table.find({"A","B","C","D"}, option)]
			button.Visible = true
			EnglishRemotes.UpdateButtonEvent:FireAllClients(option, false) -- Reset button visuals
		end

		-- Answer timer
		local answerTime = QUESTION_TIME_LIMIT
		for i = answerTime, 1, -1 do
			elements.questionTitle.Text = "Question "..questionNum..": "..currentQuestion.question.." ("..i.."s remaining)"
			task.wait(1)
		end

		-- Hide question elements
		for _, element in pairs(elements) do
			if element ~= elements.reminderText then
				element.Visible = false
			end
		end

		-- Show results
		local correctCount = 0
		for _, answer in pairs(playerAnswers) do
			if answer == currentQuestion.correctAnswer then
				correctCount = correctCount + 1
			end
		end

		elements.reminderText.Text = string.format(
			"Question %d results:\n%d/%d answered correctly!\nCorrect answer: %s",
			questionNum, correctCount, #Players:GetPlayers(), currentQuestion.correctAnswer
		)
		elements.reminderText.Visible = true

		-- Clean up connection
		connection:Disconnect()

		task.wait(RESULT_DISPLAY_TIME)

		-- Next question countdown
		if questionNum < #testQuestions then
			for i = BETWEEN_QUESTION_DELAY, 1, -1 do
				elements.reminderText.Text = "Next question in "..i.." seconds..."
				task.wait(1)
			end
		end
	end

	-- Show final results
	local resultsText = "Test completed! Final scores:\n"
	for player, score in pairs(playerScores) do
		resultsText = resultsText .. player.Name .. ": " .. score .. "/" .. #testQuestions .. "\n"
	end

	elements.reminderText.Text = resultsText
	elements.reminderText.Visible = true
	task.wait(10)

	-- Clear the board
	elements.reminderText.Text = "Please await for the next English class ^-^"

	-- Clean up remotes
	EnglishRemotes.AnswerSelectedEvent:Destroy()
	EnglishRemotes.UpdateButtonEvent:Destroy()
	EnglishRemotes:Destroy()
end

return module
