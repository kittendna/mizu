local RunService = game:GetService("RunService")
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/utils.lua"))()
local Selection = {}

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

function Selection.new(parent, data, Animation)
	assert(type(data.name) == "string", "Selection name must be a string")
	assert(type(data.variants) == "table" and #data.variants > 0, "Variants must be a non-empty table")
	assert(type(data.multiSelect) == "boolean", "multiSelect must be a boolean")

	local selectionFrame = Utils.createInstance("Frame", {
		Parent = parent,
		Name = data.name,
		Size = UDim2.new(0, 184, 0, 24),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y
	})

	local uiListLayout = Utils.createInstance("UIListLayout", {
		Parent = selectionFrame,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local label = Utils.createInstance("TextLabel", {
		Parent = selectionFrame,
		Name = "Label",
		Size = UDim2.new(0, 184, 0, 24),
		Text = data.name,
		TextColor3 = Color3.fromRGB(131, 131, 131),
		BackgroundTransparency = 1,
		TextSize = 14,
		FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTransparency = 1
	})

	local variantsList = Utils.createInstance("Frame", {
		Parent = selectionFrame,
		Name = "variantslist",
		Size = UDim2.new(0, 154, 0, 100),
		Position = UDim2.new(0.09239, 0, 0.28571, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1
	})
	Utils.applyGradient(variantsList, ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 25))
	}, 90)
	Utils.applyCorner(variantsList, 4)

	local variantListLayout = Utils.createInstance("UIListLayout", {
		Parent = variantsList,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local selectedVariants = {}
	local variantButtons = {}
	local callback = data.callback or function(value) selected = value end

	for _, variantName in ipairs(data.variants) do
		local isActive = false
		if data.default then
			for _, defaultVariant in ipairs(data.default) do
				if defaultVariant == variantName then
					isActive = true
					table.insert(selectedVariants, variantName)
					break
				end
			end
		end

		local variantButton = Utils.createInstance("TextButton", {
			Parent = variantsList,
			Name = variantName .. "_Variant",
			Size = UDim2.new(1, 0, 0, 24),
			Text = "  " .. variantName,
			TextColor3 = isActive and Color3.fromRGB(194, 164, 164) or Color3.fromRGB(131, 131, 131),
			BackgroundTransparency = 1,
			TextSize = 14,
			FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold),
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false,
			TextTransparency = 1
		})
		variantButtons[variantName] = {button = variantButton, active = isActive}

		variantButton.MouseButton1Click:Connect(function()
			if data.multiSelect then
				local index = table.find(selectedVariants, variantName)
				if index then
					table.remove(selectedVariants, index)
					variantButton.TextColor3 = Color3.fromRGB(131, 131, 131)
					variantButtons[variantName].active = false
				else
					table.insert(selectedVariants, variantName)
					variantButton.TextColor3 = Color3.fromRGB(194, 164, 164)
					variantButtons[variantName].active = true
				end
			else
				if not variantButtons[variantName].active then
					for otherName, otherData in pairs(variantButtons) do
						otherData.active = false
						otherData.button.TextColor3 = Color3.fromRGB(131, 131, 131)
					end
					selectedVariants = {variantName}
					variantButton.TextColor3 = Color3.fromRGB(194, 164, 164)
					variantButtons[variantName].active = true
				end
			end
			callback(selectedVariants)
		end)
	end

	return {
		frame = selectionFrame,
		GetValue = function(self)
			return selectedVariants
		end,
		SetValue = function(self, newValues)
			assert(type(newValues) == "table", "New values must be a table")
			selectedVariants = {}
			for name, buttonData in pairs(variantButtons) do
				buttonData.active = false
				buttonData.button.TextColor3 = Color3.fromRGB(131, 131, 131)
			end
			for _, value in ipairs(newValues) do
				if variantButtons[value] then
					table.insert(selectedVariants, value)
					variantButtons[value].button.TextColor3 = Color3.fromRGB(194, 164, 164)
					variantButtons[value].active = true
				end
			end
			callback(selectedVariants)
		end,
		Show = function(self)
			local duration = 0.1
			animateProperty(label, "TextTransparency", 1, 0, duration)
			animateProperty(variantsList, "BackgroundTransparency", 1, 0, duration)
			for _, variantData in pairs(variantButtons) do
				animateProperty(variantData.button, "TextTransparency", 1, 0, duration)
			end
		end,
		Hide = function(self)
			local duration = 0.1
			animateProperty(label, "TextTransparency", 0, 1, duration)
			animateProperty(variantsList, "BackgroundTransparency", 0, 1, duration)
			for _, variantData in pairs(variantButtons) do
				animateProperty(variantData.button, "TextTransparency", 0, 1, duration)
			end
		end
	}
end

return Selection