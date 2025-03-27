local UserInputService = game:GetService("UserInputService")
local Utils = {}

function Utils.createInstance(class, props)
	assert(type(class) == "string", "Class must be a string")
	local instance = Instance.new(class)
	for k, v in pairs(props or {}) do
		pcall(function() instance[k] = v end)
	end
	return instance
end

function Utils.makeDraggable(frame)
	assert(typeof(frame) == "Instance", "Frame must be a GUI instance")
	local dragging, dragInput, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then update(input) end
	end)
end

function Utils.applyGradient(instance, colorSequence, rotation, enabled)
	assert(typeof(instance) == "Instance", "Instance must be a GUI object")
	local gradient = instance:FindFirstChild("UIGradient") or Instance.new("UIGradient")
	gradient.Name = "UIGradient"
	gradient.Parent = instance
	gradient.Color = colorSequence
	gradient.Rotation = rotation or 90
	gradient.Enabled = enabled ~= false
	return gradient
end

function Utils.applyStroke(instance, color, thickness)
	assert(typeof(instance) == "Instance", "Instance must be a GUI object")
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = instance
	return stroke
end

function Utils.applyCorner(instance, radius)
	assert(typeof(instance) == "Instance", "Instance must be a GUI object")
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 0)
	corner.Parent = instance
	return corner
end

return Utils