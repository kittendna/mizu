local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/utils.lua"))()
local Watermark = {}

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

function Watermark.new(parent, config)
    local watermarkFrame = Utils.createInstance("Frame", {
        Parent = parent,
        Name = "Watermark",
        AnchorPoint = Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 0, 24),
        Position = UDim2.new(1, -8, 0, 8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1
    })
    Utils.applyGradient(watermarkFrame, ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(48, 48, 48)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(31, 31, 31))
    }, 90)
    Utils.applyCorner(watermarkFrame, 2)
    Utils.createInstance("UIPadding", {
        Parent = watermarkFrame,
        PaddingRight = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8)
    })

    local label = Utils.createInstance("TextLabel", {
        Parent = watermarkFrame,
        Name = "label",
        Size = UDim2.new(0, 0, 0, 24),
        AutomaticSize = Enum.AutomaticSize.X,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        TextSize = 14,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold),
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
        TextTransparency = 1
    })
    Utils.applyGradient(label, ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
    }, 90)
    label.UIGradient.Offset = Vector2.new(0, 0.25)

    local lastUpdate = 0
    local connection
    connection = RunService.Heartbeat:Connect(function(deltaTime)
        local currentTime = tick()
        if currentTime - lastUpdate >= 0.175 then
            local fps = math.floor(1 / deltaTime)
            local time = os.date("%I:%M %p", os.time())
            local username = config.username or "Unknown"
            local build = config.build or "Unknown"
            local placename = config.placename or "Unknown"
            label.Text = string.format(
                '<font color="#c1a3a3">mizu</font> <font color="#656565">|</font> <font color="#999999">%s</font> <font color="#c1a3a3">-></font> <font color="#999999">%s</font> <font color="#656565">/</font> <font color="#999999">%s</font> <font color="#656565">/</font> <font color="#999999">fps: %d</font> <font color="#656565">/</font> <font color="#999999">%s</font>',
                build, username, placename, fps, time
            )
            lastUpdate = currentTime
        end
    end)

    return {
        frame = watermarkFrame,
        Show = function(self)
            if watermarkFrame.BackgroundTransparency ~= 0 then
				local duration = 0.1
            	animateProperty(watermarkFrame, "BackgroundTransparency", 1, 0, duration)
            	animateProperty(label, "TextTransparency", 1, 0, duration)
			end
        end,
        Hide = function(self)
			if watermarkFrame.BackgroundTransparency ~= 1 then
				local duration = 0.1
				animateProperty(watermarkFrame, "BackgroundTransparency", 0, 1, duration)
				animateProperty(label, "TextTransparency", 0, 1, duration)
			end
        end,
        Destroy = function(self)
            if connection then
                connection:Disconnect()
            end
            watermarkFrame:Destroy()
        end
    }
end

return Watermark