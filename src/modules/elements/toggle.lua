local RunService = game:GetService("RunService")
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/utils.lua"))()
local Toggle = {}

local function animateProperty(instance, property, start, goal, duration)
	local startTime = tick()
	local connection
	connection = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		local alpha = math.min(elapsed / duration, 1)
		if typeof(start) == "Color3" then
			instance[property] = start:Lerp(goal, alpha)
		else
			instance[property] = start + (goal - start) * alpha
		end
		if alpha >= 1 then
			connection:Disconnect()
			instance[property] = goal
		end
	end)
end

local function animateColorSequence(gradient, startSequence, goalSequence, duration)
	local startTime = tick()
	local startKeypoints = startSequence.Keypoints
	local goalKeypoints = goalSequence.Keypoints
	local connection
	connection = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		local alpha = math.min(elapsed / duration, 1)
		local newKeypoints = {}
		for i, startKp in ipairs(startKeypoints) do
			local goalKp = goalKeypoints[i]
			local newColor = startKp.Value:Lerp(goalKp.Value, alpha)
			newKeypoints[i] = ColorSequenceKeypoint.new(startKp.Time, newColor)
		end
		gradient.Color = ColorSequence.new(newKeypoints)
		if alpha >= 1 then
			connection:Disconnect()
			gradient.Color = goalSequence
		end
	end)
end

function Toggle.new(parent, data)
	assert(type(data.name) == "string", "Toggle name must be a string")

	local toggleFrame = Utils.createInstance("TextLabel", {
		Parent = parent,
		Name = data.name,
		Size = UDim2.new(0, 184, 0, 24),
		Text = data.name,
		TextColor3 = Color3.fromRGB(131, 131, 131),
		BackgroundTransparency = 1,
		TextSize = 14,
		FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTransparency = 1
	})

	local toggleButton = Utils.createInstance("TextButton", {
		Parent = toggleFrame,
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(1, -24, 0.04167, 3),
		Text = "",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		AutoButtonColor = false
	})
	Utils.applyCorner(toggleButton, 4)

	local gradient = Utils.applyGradient(toggleButton, ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 25)), ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 25))}, 90, true)
	local stroke = Utils.applyStroke(toggleButton, Color3.fromRGB(47, 47, 47))
	stroke.Transparency = 1 

	local state = data.default or false
	local callback = data.callback or function() end
	local enabledGradient = data.enabledGradient or ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(194, 164, 164)), ColorSequenceKeypoint.new(1, Color3.fromRGB(131, 111, 111))}
	local disabledGradient = data.disabledGradient or ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 25)), ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 25))}
	local enabledStroke = data.enabledStroke or Color3.fromRGB(130, 110, 110)
	local disabledStroke = data.disabledStroke or Color3.fromRGB(47, 47, 47)

	local function update()
		local targetGradient = state and enabledGradient or disabledGradient
		local targetStroke = state and enabledStroke or disabledStroke
		animateColorSequence(gradient, gradient.Color, targetGradient, 0.1)
		animateProperty(stroke, "Color", stroke.Color, targetStroke, 0.1)
		callback(state)
	end

	if state then
		gradient.Color = enabledGradient
		stroke.Color = enabledStroke
	end

	toggleButton.MouseButton1Click:Connect(function()
		state = not state
		update()
	end)

	return {
		frame = toggleFrame,
		GetValue = function(self) return state end,
		SetValue = function(self, newState)
			assert(type(newState) == "boolean", "State must be a boolean")
			state = newState
			update()
		end,
		Show = function(self)
			local duration = 0.1
			animateProperty(toggleFrame, "TextTransparency", 1, 0, duration)
			animateProperty(toggleButton, "BackgroundTransparency", 1, 0, duration)
			animateProperty(stroke, "Transparency", 1, 0, duration)
		end,
		Hide = function(self)
			local duration = 0.1
			animateProperty(toggleFrame, "TextTransparency", 0, 1, duration)
			animateProperty(toggleButton, "BackgroundTransparency", 0, 1, duration)
			animateProperty(stroke, "Transparency", 0, 1, duration)
		end
	}
end

return Toggle