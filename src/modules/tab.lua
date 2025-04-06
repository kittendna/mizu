local RunService = game:GetService("RunService")
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/utils.lua"))()
local Tab = {}

local function animateProperty(instance, property, start, goal, duration)
	local startTime = tick()
	local connection
	connection = RunService.Heartbeat:Connect(function()
		local alpha = math.min((tick() - startTime) / duration, 1)
		instance[property] = start:Lerp(goal, alpha)
		if alpha >= 1 then
			connection:Disconnect()
			instance[property] = goal
		end
	end)
end

function Tab.new(parent, name)
	assert(parent.tabbutlist and parent.tabframelist, "Invalid parent structure for Tab")

	local tabButton = Utils.createInstance("TextButton", {
		Parent = parent.tabbutlist,
		Name = name,
		Text = "  " .. name .. "  ",
		Size = UDim2.new(0, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(34, 34, 34),
		TextColor3 = Color3.fromRGB(139, 117, 117),
		FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold),
		TextSize = 14,
		BackgroundTransparency = 1,
		TextTransparency = 1,
		AutoButtonColor = false
	})
	Utils.applyGradient(tabButton, ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))}, 90, true)
	Utils.applyStroke(tabButton, Color3.fromRGB(86, 86, 86))
	Utils.applyCorner(tabButton, 4)

	local tabContent = Utils.createInstance("Frame", {
		Parent = parent.tabframelist,
		Name = name,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false
	})

	local leftScroll = Utils.createInstance("ScrollingFrame", {
		Parent = tabContent,
		Name = "Left",
		Size = UDim2.new(0.5, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Color3.fromRGB(48, 48, 48),
		BackgroundTransparency = 1,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0
	})
	Utils.createInstance("UIListLayout", {Parent = leftScroll, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center})
	Utils.createInstance("UIPadding", {Parent = leftScroll, PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})

	local rightScroll = Utils.createInstance("ScrollingFrame", {
		Parent = tabContent,
		Name = "Right",
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Color3.fromRGB(48, 48, 48),
		BackgroundTransparency = 1,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0
	})
	Utils.createInstance("UIListLayout", {Parent = rightScroll, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center})
	Utils.createInstance("UIPadding", {Parent = rightScroll, PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})

	local function animateColors(targetTextColor, targetBgColor, enableGradient, gradientSequence)
		animateProperty(tabButton, "TextColor3", tabButton.TextColor3, targetTextColor, 0.2)
		animateProperty(tabButton, "BackgroundColor3", tabButton.BackgroundColor3, targetBgColor, 0.2)
		tabButton.BackgroundTransparency = 0
		tabButton.TextTransparency = 0
		local stroke = tabButton:FindFirstChild("UIStroke")
		if stroke then stroke.Transparency = 0 end
		tabButton.UIGradient.Enabled = enableGradient
		if enableGradient and gradientSequence then
			tabButton.UIGradient.Color = gradientSequence
		end
	end

	return {
		button = tabButton,
		content = tabContent,
		leftScroll = leftScroll,
		rightScroll = rightScroll,
		select = function()
			tabContent.Visible = true
			animateColors(
				Color3.fromRGB(47, 47, 47),
				Color3.fromRGB(193, 163, 163),
				true,
				ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(150,150,150))}
			)
		end,
		deselect = function()
			tabContent.Visible = false
			animateColors(
				Color3.fromRGB(193, 163, 163),
				Color3.fromRGB(47, 47, 47),
				true,
				ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))}
			)
		end
	}
end

return Tab