local Core = {}
Core.Modules = {}
Core.Config = {}
Core.UI = nil

function Core:initConfig()
    local configPath = "uv_config.json"
    if isfile(configPath) then
        local content = readfile(configPath)
        for line in content:gmatch("[^\r\n]+") do
            local k, v = line:match("^(%w+)=(.*)$")
            if k then 
                self.Config[k] = v == "true" and true or (v == "false" and false or v) 
            end
        end
    else
        self.Config = {
            mod_highlight = true,
            mod_fov = false,
            fov_value = 80,
            mod_skybox = false,
            skybox_preset = "default",
            mod_weather = false,
            weather_type = "fog"
        }
        self:saveConfig()
    end
end

function Core:saveConfig()
    local lines = {}
    for k, v in pairs(self.Config) do
        table.insert(lines, k .. "=" .. tostring(v))
    end
    writefile(configPath, table.concat(lines, "\n"))
end

function Core:registerModule(name, moduleInstance)
    self.Modules[name] = moduleInstance
    moduleInstance:apply(self.Config)
end

function Core:startUI()
    self:initConfig()
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "UniversalVisualsUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game:GetService("CoreGui")
    self.UI = gui

    local wm = Instance.new("TextLabel")
    wm.Name = "Watermark"
    wm.Size = UDim2.fromScale(0, 1)
    wm.Position = UDim2.fromScale(0, 0)
    wm.BackgroundTransparency = 1
    wm.Text = "Universal Visuals | " .. game:GetService("Players").LocalPlayer.Name
    wm.TextColor3 = Color3.fromRGB(255, 255, 255)
    wm.TextScaled = true
    wm.Font = Enum.Font.GothamBold
    wm.Parent = gui

    local listFrame = Instance.new("Frame")
    listFrame.Name = "Arraylist"
    listFrame.Size = UDim2.fromOffset(200, 0)
    listFrame.Position = UDim2.fromScale(1, 0)
    listFrame.AnchorPoint = Vector2.new(1, 0)
    listFrame.BackgroundTransparency = 1
    listFrame.Parent = gui

    local listUIList = Instance.new("UIListLayout")
    listUIList.SortOrder = Enum.SortOrder.LayoutOrder
    listUIList.Padding = UDim.new(0, 5)
    listUIList.Parent = listFrame

    local function createListItem(name, displayName)
        local item = Instance.new("Frame")
        item.Size = UDim2.fromOffset(200, 30)
        item.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        item.BorderSizePixel = 0
        item.Parent = listFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = item
        
        local grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
        })
        grad.Parent = item

        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = displayName
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.Gotham
        label.TextScaled = true
        label.Parent = item

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.fromOffset(40, 20)
        toggle.Position = UDim2.new(1, -45, 0.5, -10)
        toggle.BackgroundColor3 = self.Config[name] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        toggle.Text = self.Config[name] and "ON" or "OFF"
        toggle.TextColor3 = Color3.new()
        toggle.Font = Enum.Font.GothamBold
        toggle.TextScaled = true
        toggle.Parent = item

        toggle.MouseButton1Down:Connect(function()
            self.Config[name] = not self.Config[name]
            toggle.BackgroundColor3 = self.Config[name] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
            toggle.Text = self.Config[name] and "ON" or "OFF"
            
            local modKey = name:gsub("mod_", "")
            if self.Modules[modKey] then
                self.Modules[modKey]:update(self.Config)
            end
            self:saveConfig()
        end)
        
        return item
    end

    local moduleDefs = {
        {key = "mod_highlight", display = "Player Highlight"},
        {key = "mod_fov", display = "FOV Modifier"},
        {key = "mod_skybox", display = "Skybox"},
        {key = "mod_weather", display = "Weather/Fog"}
    }

    for _, def in ipairs(moduleDefs) do
        createListItem(def.key, def.display)
    end

    local dragging, dragInput, dragPosition, framePosition
    local function update(input)
        local delta = input.Position - dragPosition
        listFrame.Position = UDim2.new(framePosition.X.Scale, framePosition.X.Offset + delta.X, framePosition.Y.Scale, framePosition.Y.Offset + delta.Y)
    end

    listFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragPosition = input.Position
            framePosition = listFrame.Position
        end
    end)
    
    listFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            dragInput = input
            update(dragInput)
        end
    end)
end

return Core
