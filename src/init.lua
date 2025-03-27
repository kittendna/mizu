local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/utils.lua"))()
local Tab = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/tab.lua"))()
local Section = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/section.lua"))()
local Slider = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/elements/slider.lua"))()
local Toggle = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/elements/toggle.lua"))()
local Bind = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/elements/bind.lua"))()
local Selection = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/elements/selection.lua"))()
local Button = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/elements/button.lua"))()
local Watermark = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/watermark.lua"))()

local UILibrary = {}

local defaultTheme = {
    mainFrameColor = Color3.fromRGB(31, 31, 31),
    tabFrameColor = Color3.fromRGB(25, 25, 25),
    textColor = Color3.fromRGB(255, 255, 255),
    accentGradient = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(194, 164, 164)), ColorSequenceKeypoint.new(1, Color3.fromRGB(131, 111, 111))},
    defaultGradient = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 100))}
}

local Animation = {}
function Animation.new(instance, property, start, goal, duration)
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
    return connection
end

function UILibrary:Init(config)
    assert(type(config) == "table", "Invalid config: must be a table")
    assert(config.username and config.build and config.tree, "Config missing required fields: username, build, or tree")
    assert(type(config.tree) == "table" and next(config.tree), "Config tree must be a non-empty table")

    local theme = defaultTheme

    local screenGui = Utils.createInstance("ScreenGui", {
        Name = "UILibrary",
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Enabled = false
    })

    local mainFrame = Utils.createInstance("Frame", {
        Parent = screenGui,
        Name = "Main",
        BackgroundColor3 = theme.mainFrameColor,
        Size = UDim2.new(0, 480, 0, 320),
        Position = UDim2.new(0.317, 0, 0.127, 0),
        BorderSizePixel = 0,
        BackgroundTransparency = 1
    })
    Utils.applyCorner(mainFrame, 2)
    Utils.makeDraggable(mainFrame)

    local topLabel = Utils.createInstance("TextLabel", {
        Parent = mainFrame,
        Size = UDim2.new(0, 120, 0, 32),
        Position = UDim2.new(0, 8, 0, 0),
        Text = string.format('<font color="#c1a3a3">%s</font> <font color="#656565">-></font> <font color="#999999">%s</font>', config.name or "Unnamed", config.build),
        TextColor3 = theme.textColor,
        BackgroundTransparency = 1,
        TextSize = 14,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold),
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.X,
        TextTransparency = 1
    })
    Utils.applyGradient(topLabel, theme.defaultGradient, 90, true)

    local tabbutlist = Utils.createInstance("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(0, 344, 0, 32),
        Position = UDim2.new(0, 128, 0, 0),
        BackgroundTransparency = 1
    })
    Utils.createInstance("UIListLayout", {
        Parent = tabbutlist,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Horizontal
    })

    local tabframelist = Utils.createInstance("Frame", {
        Parent = mainFrame,
        Name = "Frame",
        BackgroundColor3 = theme.tabFrameColor,
        Size = UDim2.new(0, 480, 0, 256),
        Position = UDim2.new(0, 0, 0.1, 0),
        BorderSizePixel = 0,
        BackgroundTransparency = 1
    })

    local bottomLabel = Utils.createInstance("TextLabel", {
        Parent = mainFrame,
        Size = UDim2.new(0, 120, 0, 32),
        Position = UDim2.new(0, 8, 1, -32),
        Text = string.format('<font color="#c1a3a3">%s</font>  <font color="#656565">|</font>  <font color="#999999">%s</font>  <font color="#656565">|</font>  <font color="#999999">%s</font>', config.username, config.placename or "Unknown", config.otherinfo or "N/A"),
        TextColor3 = theme.textColor,
        BackgroundTransparency = 1,
        TextSize = 14,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold),
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.X,
        TextTransparency = 1
    })
    Utils.applyGradient(bottomLabel, theme.defaultGradient, 90, true)

    local watermark = Watermark.new(screenGui, config)

    local tabs = {}
    local tabOrder = {}
    local window = {}
    local connections = {}
    local elements = {}
    local sections = {}
    local currentTab = nil
    local isAnimating = false

    local configNames = {"autoload", "legit", "rage", "secret"}
    local configStrings = {}
    for _, name in ipairs(configNames) do
        configStrings[name] = "{}"
    end
    local selectedConfig = "autoload"

    local function loadConfig()
        local success, result = pcall(function()
            return HttpService:JSONDecode(configStrings["autoload"] or "{}")
        end)
        return success and result or {}
    end

    local function saveConfig()
        local configTable = {}
        local success, result = pcall(function()
            for tabName, sections in pairs(window) do
                if type(sections) == "table" then
                    configTable[tabName] = {}
                    for sectionName, elements in pairs(sections) do
                        configTable[tabName][sectionName] = {}
                        for elemName, elem in pairs(elements) do
                            local value
                            if type(elem.GetValue) == "function" then
                                local success, result = pcall(elem.GetValue, elem)
                                if success then
                                    value = result
                                else
                                    warn("Failed to get value for element " .. elemName .. ": " .. result)
                                    value = nil
                                end
                            else
                                value = nil
                            end
                            if value then
                                if typeof(value) == "EnumItem" then
                                    value = value.Name
                                elseif type(value) == "table" then
                                    value = value
                                end
                                configTable[tabName][sectionName][elemName] = value
                            end
                        end
                    end
                end
            end
            return HttpService:JSONEncode(configTable)
        end)
        if success then
            return result
        else
            warn("Failed to save config: " .. result)
            return nil
        end
    end

    local function loadSpecificConfig(configName)
        if configStrings[configName] then
            local success, result = pcall(function()
                return HttpService:JSONDecode(configStrings[configName])
            end)
            if success then
                return result
            else
                warn("Failed to decode config:", configName)
                return nil
            end
        else
            warn("Config not found:", configName)
            return nil
        end
    end

    local function applyConfig(configTable)
        for tabName, sections in pairs(configTable) do
            for sectionName, elements in pairs(sections) do
                for elemName, value in pairs(elements) do
                    local element = window[tabName] and window[tabName][sectionName] and window[tabName][sectionName][elemName]
                    if element and type(element.SetValue) == "function" then
                        pcall(function()
                            if element.type == "bind" then
                                element:SetValue(Enum.KeyCode[value])
                            else
                                element:SetValue(value)
                            end
                        end)
                    end
                end
            end
        end
    end

    local configTable = loadConfig()
    for tabName, tabData in pairs(config.tree) do
        local tab = Tab.new({tabbutlist = tabbutlist, tabframelist = tabframelist}, tabName)
        tabs[tabName] = tab
        table.insert(tabOrder, tabName)
        tab.button.BackgroundTransparency = 1
        tab.button.TextTransparency = 1
        local stroke = tab.button:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Transparency = 1 end
        window[tabName] = {}

        for sectionName, sectionData in pairs(tabData) do
            local scrollFrame = sectionData.side == "Right" and tab.rightScroll or tab.leftScroll
            local section = Section.new(scrollFrame, sectionName)
            window[tabName][sectionName] = {}
            table.insert(sections, {label = section.label, tab = tabName})

            for _, elementData in ipairs(sectionData.elements) do
                local element
                local elementType = elementData.type:lower()
                if elementType == "slider" then
                    element = Slider.new(section.elementList, elementData)
                elseif elementType == "toggle" then
                    element = Toggle.new(section.elementList, elementData)
                elseif elementType == "bind" then
                    element = Bind.new(section.elementList, elementData, window)
                elseif elementType == "selection" then
                    element = Selection.new(section.elementList, elementData)
                elseif elementType == "button" then
                    element = Button.new(section.elementList, elementData)
                else
                    warn("Unknown element type: " .. tostring(elementData.type))
                    continue
                end
                element.type = elementType
                section.addElement(element.frame)
                window[tabName][sectionName][elementData.name] = element
                table.insert(elements, {element = element, tab = tabName})

                local savedValue = configTable[tabName] and configTable[tabName][sectionName] and configTable[tabName][sectionName][elementData.name]
                if savedValue ~= nil and elementType ~= "button" then
                    pcall(function()
                        if elementType == "bind" then
                            element:SetValue(Enum.KeyCode[savedValue])
                        else
                            element:SetValue(savedValue)
                        end
                    end)
                end
            end
        end
    end 

    local function hideTabElements(tabName)
        local animDuration = 0.1
        local elementDuration = 0.03

        local tabElements = {}
        for _, element in ipairs(elements) do
            if element.tab == tabName then
                table.insert(tabElements, element.element)
            end
        end

        for _, element in ipairs(tabElements) do
            element:Hide()
        end
        task.wait(elementDuration)

        for _, section in ipairs(sections) do
            if section.tab == tabName then
                local label = section.label
                if label then
                    Animation.new(label, "TextTransparency", 0, 1, animDuration)
                end
            end
        end
        task.wait(animDuration)
    end

    local function showTabElements(tabName)
        local animDuration = 0.1
        local elementDuration = 0.03

        for _, section in ipairs(sections) do
            if section.tab == tabName then
                local label = section.label
                if label then
                    Animation.new(label, "TextTransparency", 1, 0, animDuration)
                end
            end
        end
        task.wait(animDuration)

        for _, element in ipairs(elements) do
            if element.tab == tabName then
                element.element:Show()
            end
        end
        task.wait(elementDuration)
    end

    for tabName, tab in pairs(tabs) do
        table.insert(connections, tab.button.MouseButton1Click:Connect(function()
            if currentTab and currentTab ~= tabName then
                local oldTab = tabs[currentTab]
                oldTab:deselect()
                hideTabElements(currentTab)
                tab:select()
                showTabElements(tabName)
                currentTab = tabName
            elseif not currentTab then
                tab:select()
                showTabElements(tabName)
                currentTab = tabName
            end
        end))
    end
    if next(tabs) then
        tabs[tabOrder[1]]:select()
        currentTab = tabOrder[1]
    end

    local function animateOpen()
        if isAnimating then return end
        isAnimating = true

        local animDuration = 0.1
        local tabButtonDelay = 0.05
        local elementDuration = 0.03

        screenGui.Enabled = true
        mainFrame.Visible = true
        Animation.new(mainFrame, "BackgroundTransparency", 1, 0, animDuration)
        Animation.new(tabframelist, "BackgroundTransparency", 1, 0, animDuration)
        Animation.new(topLabel, "TextTransparency", 1, 0, animDuration)
        Animation.new(bottomLabel, "TextTransparency", 1, 0, animDuration)
        task.wait(animDuration)

        for i = 1, #tabOrder do
            local tabName = tabOrder[i]
            local button = tabs[tabName].button
            Animation.new(button, "BackgroundTransparency", 1, 0, animDuration)
            Animation.new(button, "TextTransparency", 1, 0, animDuration)
            local stroke = button:FindFirstChildOfClass("UIStroke")
            if stroke then Animation.new(stroke, "Transparency", 1, 0, animDuration) end
            task.wait(tabButtonDelay)
        end

        if currentTab then
            showTabElements(currentTab)
        end

        isAnimating = false
    end

    local function animateClose()
        if isAnimating then return end
        isAnimating = true

        local animDuration = 0.1
        local tabButtonDuration = 0.05
        local elementDuration = 0.05

        task.wait(animDuration)

        if currentTab then
            hideTabElements(currentTab)
        end

        for i = #tabOrder, 1, -1 do
            local tabName = tabOrder[i]
            local button = tabs[tabName].button
            Animation.new(button, "BackgroundTransparency", 0, 1, tabButtonDuration)
            Animation.new(button, "TextTransparency", 0, 1, tabButtonDuration)
            local stroke = button:FindFirstChildOfClass("UIStroke")
            if stroke then Animation.new(stroke, "Transparency", 0, 1, tabButtonDuration) end
        end
        task.wait(tabButtonDuration)

        Animation.new(mainFrame, "BackgroundTransparency", 0, 1, animDuration)
        Animation.new(tabframelist, "BackgroundTransparency", 0, 1, animDuration)
        Animation.new(topLabel, "TextTransparency", 0, 1, animDuration)
        Animation.new(bottomLabel, "TextTransparency", 0, 1, animDuration)
        task.wait(animDuration)
        mainFrame.Visible = false

        isAnimating = false
    end

    window.Open = function()
        if not mainFrame.Visible then
            animateOpen()
        end
    end

    window.Close = function()
        if mainFrame.Visible then
            animateClose()
        end
    end

    window.ToggleVisibility = function()
        if isAnimating then return end
        if mainFrame.Visible then
            window:Close()
        else
            window:Open()
        end
    end

    window.SaveConfig = saveConfig
    window.LoadConfig = loadConfig
    window.Destroy = function()
        for _, conn in pairs(connections) do conn:Disconnect() end
        watermark:Destroy()
        screenGui:Destroy()
    end

    animateOpen()
    watermark:Show()
    return window
end

return UILibrary