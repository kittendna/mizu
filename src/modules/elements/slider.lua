local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/utils.lua"))()
local Slider = {}

local function animateProperty(instance, property, start, goal, duration)
	local startTime = tick()
	local connection
	connection = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		local alpha = math.min(elapsed / duration, 1)
		instance[property] = start + (goal - start) * alpha
		if alpha >= 1 then
			connection:Disconnect()
			instance[property] = goal
		end
	end)
end

local function round(number, decimalPlaces)
	local multiplier = 10 ^ (decimalPlaces or 0)
	return math.floor(number * multiplier + 0.5) / multiplier
end

function Slider.new(parent, data)
	assert(type(data.min) == "number" and type(data.max) == "number" and data.min < data.max, "Min and max must be valid numbers with min < max")
	assert(type(data.default) == "number", "Default must be a number")

	local sliderFrame = Utils.createInstance("Frame", {
		Parent = parent,
		Name = data.name,
		Size = UDim2.new(0, 184, 0, 48),
		BackgroundTransparency = 1
	})

	local nameLabel = Utils.createInstance("TextLabel", {
		Parent = sliderFrame,
		Size = UDim2.new(0, 184, 0, 24),
		Text = data.name,
		TextColor3 = Color3.fromRGB(131, 131, 131),
		BackgroundTransparency = 1,
		TextSize = 14,
		FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTransparency = 1 
	})

	local barFrame = Utils.createInstance("TextButton", {
		Parent = sliderFrame,
		Size = UDim2.new(1, -16, 0, 16),
		Position = UDim2.new(0, 8, 0.429, 5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false 
	})
	Utils.applyGradient(barFrame, data.barGradient or ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(48, 48, 48)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(31, 31, 31))
	}, 90, true)
	local barStroke = Utils.applyStroke(barFrame, Color3.fromRGB(48, 48, 48))
	barStroke.Transparency = 1 
	Utils.applyCorner(barFrame, 3)

	local fillButton = Utils.createInstance("Frame", {
		Parent = barFrame,
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1 
	})
	Utils.applyGradient(fillButton, data.fillGradient or ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(194, 164, 164)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(131, 111, 111))
	}, 90, true)
	Utils.applyCorner(fillButton, 3)

	local valueLabel = Utils.createInstance("TextLabel", {
		Parent = barFrame,
		Size = UDim2.new(1, 0, 1, 0),
		Text = string.format("%." .. (data.decimalPlaces or 0) .. "f", data.default),
		TextColor3 = Color3.fromRGB(86, 86, 86),
		BackgroundTransparency = 1,
		TextSize = 14,
		FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.ExtraBold),
		TextTransparency = 1 
	})

	local min, max, callback = data.min, data.max, data.callback or function() end
	local decimalPlaces = data.decimalPlaces or 0 
	local value = math.clamp(data.default, min, max)
	local dragging = false

	local function updateValue(newValue)
		value = round(math.clamp(newValue, min, max), decimalPlaces)
		fillButton.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
		valueLabel.Text = string.format("%." .. decimalPlaces .. "f", value)
		callback(value)
	end

	updateValue(value)

	local function onInputBegan(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			local x = math.clamp(input.Position.X - barFrame.AbsolutePosition.X, 0, barFrame.AbsoluteSize.X)
			local newValue = min + (x / barFrame.AbsoluteSize.X) * (max - min)
			updateValue(newValue)
		end
	end

	barFrame.InputBegan:Connect(onInputBegan)
	fillButton.InputBegan:Connect(onInputBegan)
	valueLabel.InputBegan:Connect(onInputBegan)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local x = math.clamp(input.Position.X - barFrame.AbsolutePosition.X, 0, barFrame.AbsoluteSize.X)
			updateValue(min + (x / barFrame.AbsoluteSize.X) * (max - min))
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	return {
		frame = sliderFrame,
		GetValue = function(self) 
			return value 
		end,
		SetValue = function(self, newValue)
			assert(type(newValue) == "number", "Value must be a number")
			updateValue(newValue)
		end,
		Show = function(self)
			local duration = 0.1
			animateProperty(nameLabel, "TextTransparency", 1, 0, duration)
			animateProperty(barFrame, "BackgroundTransparency", 1, 0, duration)
			animateProperty(barStroke, "Transparency", 1, 0, duration)
			animateProperty(fillButton, "BackgroundTransparency", 1, 0, duration)
			animateProperty(valueLabel, "TextTransparency", 1, 0, duration)
		end,
		Hide = function(self)
			local duration = 0.1
			animateProperty(nameLabel, "TextTransparency", 0, 1, duration)
			animateProperty(barFrame, "BackgroundTransparency", 0, 1, duration)
			animateProperty(barStroke, "Transparency", 0, 1, duration)
			animateProperty(fillButton, "BackgroundTransparency", 0, 1, duration)
			animateProperty(valueLabel, "TextTransparency", 0, 1, duration)
		end
	}
end

return Slider