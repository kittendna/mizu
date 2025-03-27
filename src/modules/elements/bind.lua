local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/utils.lua"))()
local Bind = {}

local shortNames = {
	LeftControl = "LControl", RightControl = "RControl",
	LeftShift = "LShift", RightShift = "RShift",
	LeftAlt = "LAlt", RightAlt = "RAlt",
	LeftSuper = "LSuper", RightSuper = "RSuper",
}
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

function Bind.new(parent, data, context)
	assert(data.default and typeof(data.default) == "EnumItem", "Default must be a KeyCode")

	local bindFrame = Utils.createInstance("TextLabel", {
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

	local bindButton = Utils.createInstance("TextButton", {
		Parent = bindFrame,
		Size = UDim2.new(0, 48, 0, 16),
		Position = UDim2.new(0.826, -24, 0.04167, 3),
		Text = shortNames[data.default.Name] or data.default.Name,
		BackgroundColor3 = Color3.fromRGB(48, 48, 48),
		TextColor3 = Color3.fromRGB(194, 164, 164),
		FontFace = Font.new("rbxassetid://12187607287", Enum.FontWeight.SemiBold),
		TextSize = 14,
		BackgroundTransparency = 1,
		TextTransparency = 1,
		AutoButtonColor = false 
	})
	Utils.applyGradient(bindButton, ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(131, 131, 131))}, 90)
	local stroke = Utils.applyStroke(bindButton, Color3.fromRGB(48, 48, 48))
	stroke.Transparency = 1 
	Utils.applyCorner(bindButton, 4)

	local currentKey = data.default
	local changeCallback = data.callback or function() end
	local pressCallback = data.pressCallback or function() end
	local windowContext = context
	local connections = {}

	table.insert(connections, bindButton.MouseButton1Click:Connect(function()
		bindButton.Text = "..."
		local inputConn
		inputConn = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				currentKey = input.KeyCode
				bindButton.Text = shortNames[currentKey.Name] or currentKey.Name
				changeCallback(currentKey)
				inputConn:Disconnect()
			end
		end)
	end))

	table.insert(connections, UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
			pcall(pressCallback, windowContext)
		end
	end))

	return {
		frame = bindFrame,
		GetValue = function(self) return currentKey end,
		SetValue = function(self, newKey)
			assert(typeof(newKey) == "EnumItem", "New key must be an EnumItem")
			currentKey = newKey
			bindButton.Text = shortNames[newKey.Name] or newKey.Name
			changeCallback(newKey)
		end,
		Show = function(self)
			local duration = 0.1
			animateProperty(bindFrame, "TextTransparency", 1, 0, duration)
			animateProperty(bindButton, "BackgroundTransparency", 1, 0, duration)
			animateProperty(bindButton, "TextTransparency", 1, 0, duration)
			animateProperty(stroke, "Transparency", 1, 0, duration)
		end,
		Hide = function(self)
			local duration = 0.1
			animateProperty(bindFrame, "TextTransparency", 0, 1, duration)
			animateProperty(bindButton, "BackgroundTransparency", 0, 1, duration)
			animateProperty(bindButton, "TextTransparency", 0, 1, duration)
			animateProperty(stroke, "Transparency", 0, 1, duration)
		end,
		Destroy = function()
			for _, conn in pairs(connections) do conn:Disconnect() end
		end
	}
end

return Bind