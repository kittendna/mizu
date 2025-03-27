local RunService = game:GetService("RunService")
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/utils.lua"))()
local Button = {}

local function animateProperty(instance, property, start, goal, duration)
	local startTime = tick()
	local connection
	connection = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		local alpha = math.min(elapsed / duration, 1)

		if typeof(start) == "Color3" and typeof(goal) == "Color3" then
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

function Button.new(parent, data)
	assert(type(data.name) == "string", "Button name must be a string")
	assert(type(data.text) == "string", "Button text must be a string")

	local buttonFrame = Utils.createInstance("TextLabel", {
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

	local actionButton = Utils.createInstance("TextButton", {
		Parent = buttonFrame,
		Size = UDim2.new(0, 176, 0, 16),
		Position = UDim2.new(0.13043, -24, 0.04167, 3),
		Text = data.text,
		BackgroundColor3 = Color3.fromRGB(48, 48, 48),
		TextColor3 = Color3.fromRGB(154, 154, 154),
		FontFace = Font.new("rbxassetid://12187607287", Enum.FontWeight.SemiBold),
		TextSize = 14,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		TextTransparency = 1
	})
	Utils.applyGradient(actionButton, ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(131, 131, 131))
	}, 90)
	local stroke = Utils.applyStroke(actionButton, Color3.fromRGB(48, 48, 48))
	stroke.Transparency = 1
	Utils.applyCorner(actionButton, 4)

	local callback = data.callback or function() end

	actionButton.MouseButton1Click:Connect(function()
		actionButton.TextColor3 = Color3.fromRGB(194, 164, 164)
		task.wait(0.1)
		animateProperty(actionButton, "TextColor3", Color3.fromRGB(194, 164, 164), Color3.fromRGB(154, 154, 154), 0.1)
		callback()
	end)

	return {
		frame = buttonFrame,
		Show = function(self)
			local duration = 0.1
			animateProperty(buttonFrame, "TextTransparency", 1, 0, duration)
			animateProperty(actionButton, "BackgroundTransparency", 1, 0, duration)
			animateProperty(actionButton, "TextTransparency", 1, 0, duration)
			animateProperty(stroke, "Transparency", 1, 0, duration)
		end,
		Hide = function(self)
			local duration = 0.1
			animateProperty(buttonFrame, "TextTransparency", 0, 1, duration)
			animateProperty(actionButton, "BackgroundTransparency", 0, 1, duration)
			animateProperty(actionButton, "TextTransparency", 0, 1, duration)
			animateProperty(stroke, "Transparency", 0, 1, duration)
		end
	}
end

return Button