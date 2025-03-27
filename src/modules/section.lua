local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/utils.lua"))()
local Section = {}

function Section.new(scrollFrame, name, options)
	options = options or {}
	local sectionFrame = Utils.createInstance("TextLabel", {
		Parent = scrollFrame,
		Name = name .. "_SectionFrame",
		Size = UDim2.new(0, options.width or 200, 0, 24),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = name,
		TextColor3 = options.textColor or Color3.fromRGB(131, 111, 111),
		BackgroundTransparency = 1,
		TextSize = options.textSize or 16,
		FontFace = Font.new("rbxassetid://12187607287", Enum.FontWeight.SemiBold),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top
	})

	local elementList = Utils.createInstance("Frame", {
		Parent = sectionFrame,
		Name = "ElementListFrame",
		Size = UDim2.new(0, options.width or 200, 0, 0),
		Position = UDim2.new(0, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1
	})
	Utils.createInstance("UIListLayout", {
		Parent = elementList,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, options.padding or 4)
	})

	return {
		elementList = elementList,
		addElement = function(element)
			element.Parent = elementList
		end,
		setTextColor = function(color)
			sectionFrame.TextColor3 = color
		end
	}
end

return Section