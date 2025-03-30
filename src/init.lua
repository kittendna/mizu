local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local UILibrary = {}

local defaultTheme = {
    mainFrameColor = Color3.fromRGB(31, 31, 31),
    tabFrameColor = Color3.fromRGB(25, 25, 25),
    textColor = Color3.fromRGB(255, 255, 255),
    accentGradient = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(194, 164, 164)), ColorSequenceKeypoint.new(1, Color3.fromRGB(131, 111, 111))},
    defaultGradient = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 100))}
}

local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/utils.lua"))()

local Animation = {}
function Animation.new(instance, property, start, goal, duration)
    local startTime = tick()
    local connection

    if typeof(start) == "UDim2" and typeof(goal) == "UDim2" then
        local startXScale, startXOffset = start.X.Scale, start.X.Offset
        local startYScale, startYOffset = start.Y.Scale, start.Y.Offset
        local goalXScale, goalXOffset = goal.X.Scale, goal.X.Offset
        local goalYScale, goalYOffset = goal.Y.Scale, goal.Y.Offset

        connection = RunService.Heartbeat:Connect(function()
            local elapsed = tick() - startTime
            local alpha = math.min(elapsed / duration, 1)

            local newXScale = startXScale + (goalXScale - startXScale) * alpha
            local newXOffset = startXOffset + (goalXOffset - startXOffset) * alpha
            local newYScale = startYScale + (goalYScale - startYScale) * alpha
            local newYOffset = startYOffset + (goalYOffset - startYOffset) * alpha

            instance[property] = UDim2.new(newXScale, newXOffset, newYScale, newYOffset)

            if alpha >= 1 then
                connection:Disconnect()
                instance[property] = goal
            end
        end)
    else
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
    return connection
end

function UILibrary:Init(config)
    assert(type(config) == "table", "Invalid config: must be a table")
    assert(config.username and config.build and config.tree, "Config missing required fields: username, build, or tree")
    assert(type(config.tree) == "table" and next(config.tree), "Config tree must be a non-empty table")

    local theme = defaultTheme

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UILibrary"
    screenGui.Parent = game.CoreGui.RobloxGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Enabled = true

    local loader = Instance.new("Frame")
    loader.Parent = screenGui
    loader.Name = "loader"
    loader.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
    loader.Size = UDim2.new(0, 240, 0, 144)
    loader.Position = UDim2.new(0.5, -120, 0.5, -72)
    loader.BorderSizePixel = 0
    loader.BackgroundTransparency = 1
    Utils.makeDraggable(loader)

    local loaderCorner = Instance.new("UICorner")
    loaderCorner.CornerRadius = UDim.new(0, 2)
    loaderCorner.Parent = loader

    local loaderLabel = Instance.new("TextLabel")
    loaderLabel.Parent = loader
    loaderLabel.Size = UDim2.new(0, 120, 0, 24)
    loaderLabel.Position = UDim2.new(0, 8, 0.007, 0)
    loaderLabel.Text = [[<font color="#c1a3a3">rojunkies</font> <font color="#656565">|</font> <font color="#999999">loader</font>]]
    loaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    loaderLabel.BackgroundTransparency = 1
    loaderLabel.TextTransparency = 1
    loaderLabel.TextSize = 14
    loaderLabel.FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold)
    loaderLabel.RichText = true
    loaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    loaderLabel.AutomaticSize = Enum.AutomaticSize.X

    local loaderLabelGradient = Instance.new("UIGradient")
    loaderLabelGradient.Rotation = 90
    loaderLabelGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))}
    loaderLabelGradient.Parent = loaderLabel

    local welcomeText = Instance.new("TextLabel")
    welcomeText.Parent = loader
    welcomeText.Size = UDim2.new(0, 120, 0, 24)
    welcomeText.Position = UDim2.new(0.21667, 8, 0.54167, -24)
    welcomeText.Text = string.format([[<font color="#999999">welcome,</font> <font color="#c1a3a3">%s</font><font color="#999999">.</font>]], config.username or "user")
    welcomeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    welcomeText.BackgroundTransparency = 1
    welcomeText.TextSize = 14
    welcomeText.FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold)
    welcomeText.RichText = true
    welcomeText.AutomaticSize = Enum.AutomaticSize.X
    welcomeText.TextTransparency = 1

    local welcomeTextGradient = Instance.new("UIGradient")
    welcomeTextGradient.Rotation = 90
    welcomeTextGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))}
    welcomeTextGradient.Parent = welcomeText

    local loadingBase = Instance.new("Frame")
    loadingBase.Parent = loader
    loadingBase.Name = "loadingbase"
    loadingBase.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    loadingBase.Size = UDim2.new(1, -16, 0, 16)
    loadingBase.Position = UDim2.new(0, 8, 1, -24)
    loadingBase.BorderSizePixel = 0
    loadingBase.BackgroundTransparency = 1

    local loadingBaseGradient = Instance.new("UIGradient")
    loadingBaseGradient.Rotation = 90
    loadingBaseGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(48, 48, 48)), ColorSequenceKeypoint.new(1, Color3.fromRGB(31, 31, 31))}
    loadingBaseGradient.Parent = loadingBase

    local loadingBaseStroke = Instance.new("UIStroke")
    loadingBaseStroke.Color = Color3.fromRGB(48, 48, 48)
    loadingBaseStroke.Parent = loadingBase
    loadingBaseStroke.Transparency = 1

    local loadingBaseCorner = Instance.new("UICorner")
    loadingBaseCorner.CornerRadius = UDim.new(0, 3)
    loadingBaseCorner.Parent = loadingBase

    local fillFrame = Instance.new("Frame")
    fillFrame.Parent = loadingBase
    fillFrame.Name = "fillframe"
    fillFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fillFrame.Size = UDim2.new(0, 0, 1, 0)
    fillFrame.BorderSizePixel = 0
    fillFrame.BackgroundTransparency = 1

    local fillFrameGradient = Instance.new("UIGradient")
    fillFrameGradient.Rotation = 90
    fillFrameGradient.Color = theme.accentGradient
    fillFrameGradient.Parent = fillFrame

    local fillFrameCorner = Instance.new("UICorner")
    fillFrameCorner.CornerRadius = UDim.new(0, 3)
    fillFrameCorner.Parent = fillFrame

    local loadingStatus = Instance.new("TextLabel")
    loadingStatus.Parent = loader
    loadingStatus.Size = UDim2.new(0, 120, 0, 24)
    loadingStatus.Position = UDim2.new(0.21667, 8, 0.83333, -24)
    loadingStatus.Text = [[<font color="#c1a3a3">loading:</font> <font color="#999999">initializing</font><font color="#999999">...</font>]]
    loadingStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadingStatus.BackgroundTransparency = 1
    loadingStatus.TextSize = 14
    loadingStatus.FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold)
    loadingStatus.RichText = true
    loadingStatus.AutomaticSize = Enum.AutomaticSize.X
    loadingStatus.TextTransparency = 1

    local loadingStatusGradient = Instance.new("UIGradient")
    loadingStatusGradient.Rotation = 90
    loadingStatusGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))}
    loadingStatusGradient.Parent = loadingStatus

    task.wait(0.3)

    local animDuration = 0.15
    Animation.new(loader, "BackgroundTransparency", 1, 0, animDuration)
    Animation.new(loaderLabel, "TextTransparency", 1, 0, animDuration)
    Animation.new(welcomeText, "TextTransparency", 1, 0, animDuration)
    Animation.new(loadingBase, "BackgroundTransparency", 1, 0, animDuration)
    Animation.new(fillFrame, "BackgroundTransparency", 1, 0, animDuration)
    Animation.new(loadingStatus, "TextTransparency", 1, 0, animDuration)
    Animation.new(loadingBaseStroke, "Transparency", 1, 0, animDuration)
    task.wait(animDuration)

    local modules = {
        {name = "Tab", url = "https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/tab.lua"},
        {name = "Section", url = "https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/section.lua"},
        {name = "Slider", url = "https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/elements/slider.lua"},
        {name = "Toggle", url = "https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/elements/toggle.lua"},
        {name = "Bind", url = "https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/elements/bind.lua"},
        {name = "Selection", url = "https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/elements/selection.lua"},
        {name = "Button", url = "https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/elements/button.lua"},
        {name = "Watermark", url = "https://raw.githubusercontent.com/kittendna/mizu/main/src/modules/watermark.lua"}
    }

    local totalModules = #modules
    local loadedModules = 0
    local loaded = {}

    for _, module in ipairs(modules) do
        loadingStatus.Text = string.format([[<font color="#c1a3a3">loading:</font> <font color="#999999">%s</font><font color="#999999">...</font>]], module.name)
        loadedModules = loadedModules + 1
        local progress = loadedModules / (totalModules + 1)
        local startSize = fillFrame.Size
        local goalSize = UDim2.new(progress, 0, 1, 0)
        Animation.new(fillFrame, "Size", startSize, goalSize, 0.15)

        local success, result = pcall(function()
            return loadstring(game:HttpGet(module.url))()
        end)
        if success then
            loaded[module.name] = result
            print("Loaded module:", module.name)
        else
            warn("Failed to load module " .. module.name .. ": " .. result)
        end
        task.wait(0.3)
    end

    local Tab = loaded["Tab"]
    local Section = loaded["Section"]
    local Slider = loaded["Slider"]
    local Toggle = loaded["Toggle"]
    local Bind = loaded["Bind"]
    local Selection = loaded["Selection"]
    local Button = loaded["Button"]
    local Watermark = loaded["Watermark"]

    if not (Utils and Tab and Section and Slider and Toggle and Bind and Selection and Button and Watermark) then
        warn("One or more modules failed to load. Aborting UI initialization.")
        loader:Destroy()
        screenGui:Destroy()
        return nil
    end

    loadingStatus.Text = [[<font color="#c1a3a3">ui:</font> <font color="#999999">initializing</font><font color="#999999">...</font>]]
    local startSize = fillFrame.Size
    local goalSize = UDim2.new(loadedModules / (totalModules + 1), 0, 1, 0)
    Animation.new(fillFrame, "Size", startSize, goalSize, 0.3)
    task.wait(1)

    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.Name = "Main"
    mainFrame.BackgroundColor3 = theme.mainFrameColor
    mainFrame.Size = UDim2.new(0, 480, 0, 320)
    mainFrame.Position = UDim2.new(0.317, 0, 0.127, 0)
    mainFrame.BorderSizePixel = 0
    mainFrame.BackgroundTransparency = 1
    mainFrame.Visible = false

    local mainFrameCorner = Instance.new("UICorner")
    mainFrameCorner.CornerRadius = UDim.new(0, 2)
    mainFrameCorner.Parent = mainFrame

    Utils.makeDraggable(mainFrame)

    local topLabel = Instance.new("TextLabel")
    topLabel.Parent = mainFrame
    topLabel.Size = UDim2.new(0, 120, 0, 32)
    topLabel.Position = UDim2.new(0, 8, 0, 0)
    topLabel.Text = string.format('<font color="#c1a3a3">%s</font> <font color="#656565">-></font> <font color="#999999">%s</font>', config.name or "Unnamed", config.build)
    topLabel.TextColor3 = theme.textColor
    topLabel.BackgroundTransparency = 1
    topLabel.TextSize = 14
    topLabel.FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold)
    topLabel.RichText = true
    topLabel.TextXAlignment = Enum.TextXAlignment.Left
    topLabel.AutomaticSize = Enum.AutomaticSize.X
    topLabel.TextTransparency = 1

    local topLabelGradient = Instance.new("UIGradient")
    topLabelGradient.Rotation = 90
    topLabelGradient.Color = theme.defaultGradient
    topLabelGradient.Parent = topLabel

    local tabbutlist = Instance.new("Frame")
    tabbutlist.Parent = mainFrame
    tabbutlist.Size = UDim2.new(0, 344, 0, 32)
    tabbutlist.Position = UDim2.new(0, 128, 0, 0)
    tabbutlist.BackgroundTransparency = 1

    local tabbutlistLayout = Instance.new("UIListLayout")
    tabbutlistLayout.Parent = tabbutlist
    tabbutlistLayout.Padding = UDim.new(0, 8)
    tabbutlistLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabbutlistLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabbutlistLayout.FillDirection = Enum.FillDirection.Horizontal

    local tabframelist = Instance.new("Frame")
    tabframelist.Parent = mainFrame
    tabframelist.Name = "Frame"
    tabframelist.BackgroundColor3 = theme.tabFrameColor
    tabframelist.Size = UDim2.new(0, 480, 0, 256)
    tabframelist.Position = UDim2.new(0, 0, 0.1, 0)
    tabframelist.BorderSizePixel = 0
    tabframelist.BackgroundTransparency = 1

    local bottomLabel = Instance.new("TextLabel")
    bottomLabel.Parent = mainFrame
    bottomLabel.Size = UDim2.new(0, 120, 0, 32)
    bottomLabel.Position = UDim2.new(0, 8, 1, -32)
    bottomLabel.Text = string.format('<font color="#c1a3a3">%s</font>  <font color="#656565">|</font>  <font color="#999999">%s</font>  <font color="#656565">|</font>  <font color="#999999">%s</font>', config.username, config.placename or "Unknown", config.otherinfo or "N/A")
    bottomLabel.TextColor3 = theme.textColor
    bottomLabel.BackgroundTransparency = 1
    bottomLabel.TextSize = 14
    bottomLabel.FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold)
    bottomLabel.RichText = true
    bottomLabel.TextXAlignment = Enum.TextXAlignment.Left
    bottomLabel.AutomaticSize = Enum.AutomaticSize.X
    bottomLabel.TextTransparency = 1

    local customLabel = bottomLabel
    local customLabelGradient = Instance.new("UIGradient")
    customLabelGradient.Rotation = 90
    customLabelGradient.Color = theme.defaultGradient
    customLabelGradient.Parent = customLabel

    local watermark = Watermark.new(screenGui, config)

    local tabs = {}
    local tabOrder = {}
    local window = {}
    window.watermark = watermark
    local connections = {}
    local elements = {}
    local sections = {}
    local currentTab = nil
    local isAnimating = false

    local totalTabs = 0
    for _ in pairs(config.tree) do
        totalTabs = totalTabs + 1
    end
    local loadedTabs = 0

    -- Извлекаем ключи из config.tree и сортируем их
    local tabNames = {}
    for tabName in pairs(config.tree) do
        table.insert(tabNames, tabName)
    end

    -- Используем отсортированный массив для итерации
    for _, tabName in ipairs(tabNames) do
        local tabData = config.tree[tabName]
        loadedTabs = loadedTabs + 1
        loadingStatus.Text = string.format([[<font color="#c1a3a3">ui:</font> <font color="#999999">loading %s</font><font color="#999999">...</font>]], tabName)
        local progress = (loadedModules + (loadedTabs / totalTabs)) / (totalModules + 1)
        local startSize = fillFrame.Size
        local goalSize = UDim2.new(progress, 0, 1, 0)
        Animation.new(fillFrame, "Size", startSize, goalSize, 0.3)

        local success, tab = pcall(function()
            return Tab.new({tabbutlist = tabbutlist, tabframelist = tabframelist}, tabName)
        end)
        if not success then
            warn("Failed to create tab " .. tabName .. ": " .. tab)
            continue
        end

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
                    element = Selection.new(section.elementList, elementData, window)
                elseif elementType == "button" then
                    element = Button.new(section.elementList, elementData, window)
                else
                    warn("Unknown element type: " .. tostring(elementData.type))
                    continue
                end
                element.type = elementType
                section.addElement(element.frame)
                window[tabName][sectionName][elementData.name] = element
                table.insert(elements, {element = element, tab = tabName})
            end
        end
        task.wait(0.3)
    end

    local function hideLoader()
        local animDuration = 0.3
        Animation.new(loader, "BackgroundTransparency", 0, 1, animDuration)
        Animation.new(loaderLabel, "TextTransparency", 0, 1, animDuration)
        Animation.new(welcomeText, "TextTransparency", 0, 1, animDuration)
        Animation.new(loadingBase, "BackgroundTransparency", 0, 1, animDuration)
        Animation.new(fillFrame, "BackgroundTransparency", 0, 1, animDuration)
        Animation.new(loadingStatus, "TextTransparency", 0, 1, animDuration)
        Animation.new(loadingBaseStroke, "Transparency", 0, 1, animDuration)
        task.wait(animDuration)
        loader:Destroy()
    end

    hideLoader()

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
        Animation.new(customLabel, "TextTransparency", 1, 0, animDuration)
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
        Animation.new(customLabel, "TextTransparency", 0, 1, animDuration)
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

    window.Destroy = function()
        for _, conn in pairs(connections) do conn:Disconnect() end
        watermark:Destroy()
        screenGui:Destroy()
    end

    window.SaveConfig = function(self, configName)
        local configData = {}
        for tabName, tab in pairs(self) do
            if type(tab) == "table" and tabName ~= "watermark" then
                configData[tabName] = {}
                for sectionName, section in pairs(tab) do
                    if type(section) == "table" then
                        configData[tabName][sectionName] = {}
                        for elementName, element in pairs(section) do
                            local value
                            if element.type == "toggle" then
                                value = element:GetValue()
                            elseif element.type == "slider" then
                                value = element:GetValue()
                            elseif element.type == "selection" then
                                value = element:GetValue()
                            elseif element.type == "bind" then
                                local key = element:GetValue()
                                value = key and key.Name or "None"
                            end
                            configData[tabName][sectionName][elementName] = value
                        end
                    end
                end
            end
        end
        local jsonData = HttpService:JSONEncode(configData)
        writefile("mizu/" .. configName .. ".json", jsonData)
    end

    window.LoadConfig = function(self, configName)
        if not isfile("mizu/" .. configName .. ".json") then
            warn("Config file not found: " .. configName)
            return
        end
        local jsonData = readfile("mizu/" .. configName .. ".json")
        local configData = HttpService:JSONDecode(jsonData)
        for tabName, tabData in pairs(configData) do
            if self[tabName] then
                for sectionName, sectionData in pairs(tabData) do
                    if self[tabName][sectionName] then
                        for elementName, value in pairs(sectionData) do
                            local element = self[tabName][sectionName][elementName]
                            if element then
                                if element.type == "toggle" then
                                    element:SetValue(value)
                                elseif element.type == "slider" then
                                    element:SetValue(value)
                                elseif element.type == "selection" then
                                    element:SetValue(value)
                                elseif element.type == "bind" then
                                    local key = value ~= "None" and Enum.KeyCode[value] or nil
                                    element:SetValue(key)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if not isfolder("mizu") then
        makefolder("mizu")
    end

    local configFiles = {"default.json", "legit.json", "rage.json", "secret.json"}

    for _, file in ipairs(configFiles) do
        local filePath = "mizu/" .. file
        if not isfile(filePath) then
            writefile(filePath, "{}")
        end
    end

    animateOpen()
    watermark:Show()
    window:LoadConfig("default") 
    return window
end

return UILibrary