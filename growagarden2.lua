-- Grow a Garden 2 | StarCalled Hub v9
-- For your own Roblox game
-- Multi seed buy / plant / harvest / sell

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local mouse = player:GetMouse()

task.wait(2)

-- ==================== RAYFIELD ====================

local Rayfield

local function getHttp(url)
    if game.HttpGet then
        return game:HttpGet(url, true)
    end

    if game.HttpGetAsync then
        return game:HttpGetAsync(url)
    end

    if syn and syn.request then
        local response = syn.request({Url = url, Method = "GET"})
        if typeof(response) == "string" then
            return response
        end
        return response and response.Body
    end

    if http_request then
        local response = http_request({Url = url, Method = "GET"})
        if typeof(response) == "string" then
            return response
        end
        return response and response.Body
    end

    if request then
        local response = request({Url = url, Method = "GET"})
        if typeof(response) == "string" then
            return response
        end
        return response and response.Body
    end

    error("Your executor does not support HttpGet or http_request")
end

local function createFallbackRayfield()
    local StarterGui = game:GetService("StarterGui")
    local PlayerGui = player:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StarCalledHubFallback"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 440, 0, 520)
    mainFrame.Position = UDim2.new(0.5, -220, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Grow a Garden 2 | StarCalled Hub"
    titleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local tabsFrame = Instance.new("Frame")
    tabsFrame.Name = "TabsFrame"
    tabsFrame.Size = UDim2.new(0, 120, 1, -40)
    tabsFrame.Position = UDim2.new(0, 0, 0, 40)
    tabsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabsFrame.BorderSizePixel = 0
    tabsFrame.Parent = mainFrame

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.Padding = UDim.new(0, 4)
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Parent = tabsFrame

    local tabContent = Instance.new("Frame")
    tabContent.Name = "TabContent"
    tabContent.Size = UDim2.new(1, -120, 1, -40)
    tabContent.Position = UDim2.new(0, 120, 0, 40)
    tabContent.BackgroundTransparency = 1
    tabContent.Parent = mainFrame

    local selectedTab

    local function createToggle(container, opts)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, -12, 0, 34)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = container

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = opts.Name
        label.TextColor3 = Color3.fromRGB(230, 230, 230)
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 80, 0, 24)
        button.Position = UDim2.new(1, -90, 0.5, -12)
        button.BackgroundColor3 = opts.CurrentValue and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(90, 90, 90)
        button.BorderSizePixel = 0
        button.Text = opts.CurrentValue and "ON" or "OFF"
        button.TextColor3 = Color3.fromRGB(240, 240, 240)
        button.TextSize = 14
        button.Font = Enum.Font.GothamBold
        button.Parent = toggleFrame

        local value = opts.CurrentValue or false

        local function update()
            button.Text = value and "ON" or "OFF"
            button.BackgroundColor3 = value and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(90, 90, 90)
        end

        button.MouseButton1Click:Connect(function()
            value = not value
            update()
            if opts.Callback then
                pcall(opts.Callback, value)
            end
        end)

        update()
        return toggleFrame
    end

    local function createButton(container, opts)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -12, 0, 34)
        button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        button.BorderSizePixel = 0
        button.Text = opts.Name
        button.TextColor3 = Color3.fromRGB(240, 240, 240)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 15
        button.Parent = container

        button.MouseButton1Click:Connect(function()
            if opts.Callback then
                pcall(opts.Callback)
            end
        end)

        return button
    end

    local function createSection(container, name)
        local sectionLabel = Instance.new("TextLabel")
        sectionLabel.Size = UDim2.new(1, -12, 0, 24)
        sectionLabel.BackgroundTransparency = 1
        sectionLabel.Text = name
        sectionLabel.TextColor3 = Color3.fromRGB(195, 195, 195)
        sectionLabel.Font = Enum.Font.GothamSemibold
        sectionLabel.TextSize = 15
        sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
        sectionLabel.Parent = container

        return sectionLabel
    end

    local function createDropdown(container, opts)
        local dropFrame = Instance.new("Frame")
        dropFrame.Size = UDim2.new(1, -12, 0, 40)
        dropFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
        dropFrame.BorderSizePixel = 0
        dropFrame.Parent = container

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = opts.Name
        label.TextColor3 = Color3.fromRGB(230, 230, 230)
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = dropFrame

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0.45, -10, 1, 0)
        toggle.Position = UDim2.new(0.5, 0, 0, 0)
        toggle.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
        toggle.BorderSizePixel = 0
        toggle.Text = "Select"
        toggle.TextColor3 = Color3.fromRGB(240, 240, 240)
        toggle.Font = Enum.Font.GothamBold
        toggle.TextSize = 14
        toggle.Parent = dropFrame

        local optionsPanel = Instance.new("Frame")
        optionsPanel.Size = UDim2.new(1, -12, 0, math.min(180, #opts.Options * 30 + 4))
        optionsPanel.Position = UDim2.new(0, 6, 0, 44)
        optionsPanel.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        optionsPanel.BorderSizePixel = 0
        optionsPanel.Visible = false
        optionsPanel.Parent = container

        local optionsLayout = Instance.new("UIListLayout")
        optionsLayout.Padding = UDim.new(0, 2)
        optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        optionsLayout.Parent = optionsPanel

        local selection = {}
        if typeof(opts.CurrentOption) == "table" then
            for _, value in ipairs(opts.CurrentOption) do
                selection[value] = true
            end
        elseif typeof(opts.CurrentOption) == "string" then
            selection[opts.CurrentOption] = true
        end

        local function updateHeader()
            local selected = {}
            for value, active in pairs(selection) do
                if active then
                    table.insert(selected, value)
                end
            end

            if #selected == 0 then
                toggle.Text = "Select"
            else
                toggle.Text = table.concat(selected, ", ")
            end
        end

        for _, value in ipairs(opts.Options) do
            local itemButton = Instance.new("TextButton")
            itemButton.Size = UDim2.new(1, -8, 0, 26)
            itemButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            itemButton.BorderSizePixel = 0
            itemButton.Text = value
            itemButton.TextColor3 = Color3.fromRGB(240, 240, 240)
            itemButton.Font = Enum.Font.Gotham
            itemButton.TextSize = 14
            itemButton.Parent = optionsPanel

            itemButton.MouseButton1Click:Connect(function()
                if opts.MultipleOptions then
                    selection[value] = not selection[value]
                else
                    for key in pairs(selection) do
                        selection[key] = nil
                    end

                    selection[value] = true
                    optionsPanel.Visible = false
                end

                local result = {}
                for key, active in pairs(selection) do
                    if active then
                        table.insert(result, key)
                    end
                end

                if opts.Callback then
                    if opts.MultipleOptions then
                        pcall(opts.Callback, result)
                    else
                        pcall(opts.Callback, result[1])
                    end
                end

                updateHeader()
            end)
        end

        toggle.MouseButton1Click:Connect(function()
            optionsPanel.Visible = not optionsPanel.Visible
        end)

        updateHeader()
        return dropFrame
    end

    local function createTab(name)
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1, -12, 0, 36)
        tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        tabButton.BorderSizePixel = 0
        tabButton.Text = name
        tabButton.TextColor3 = Color3.fromRGB(240, 240, 240)
        tabButton.Font = Enum.Font.GothamBold
        tabButton.TextSize = 14
        tabButton.Parent = tabsFrame

        local tabContainer = Instance.new("ScrollingFrame")
        tabContainer.Name = name .. "Content"
        tabContainer.Size = UDim2.new(1, -10, 1, -10)
        tabContainer.Position = UDim2.new(0, 5, 0, 5)
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContainer.BackgroundTransparency = 1
        tabContainer.BorderSizePixel = 0
        tabContainer.ScrollBarThickness = 6
        tabContainer.Parent = tabContent

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = tabContainer

        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 6)
        padding.PaddingLeft = UDim.new(0, 6)
        padding.PaddingRight = UDim.new(0, 6)
        padding.Parent = tabContainer

        local tab = {}

        function tab:CreateSection(sectionName)
            return createSection(tabContainer, sectionName)
        end

        function tab:CreateToggle(params)
            return createToggle(tabContainer, params)
        end

        function tab:CreateButton(params)
            return createButton(tabContainer, params)
        end

        function tab:CreateDropdown(params)
            return createDropdown(tabContainer, params)
        end

        tabButton.MouseButton1Click:Connect(function()
            if selectedTab then
                selectedTab.Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                selectedTab.Container.Visible = false
            end
            tabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            tabContainer.Visible = true
            selectedTab = {Button = tabButton, Container = tabContainer}
        end)

        tabContainer.Visible = false
        if not selectedTab then
            selectedTab = {Button = tabButton, Container = tabContainer}
            tabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            tabContainer.Visible = true
        end
        return tab
    end

    local window = {}
    function window:CreateTab(name)
        return createTab(name)
    end

    return {
        CreateWindow = function()
            return window
        end,
        Notify = function(params)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = params.Title or "StarCalled Hub",
                    Text = params.Content or "",
                    Duration = params.Duration or 4,
                })
            end)
        end,
    }
end

local function loadRayfield()
    local urls = {
        "https://sirius.menu/rayfield",
        "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"
    }

    for _, url in ipairs(urls) do
        local ok, resultOrErr = pcall(function()
            local source = getHttp(url)
            assert(typeof(source) == "string" and #source > 0, "empty Rayfield source")

            local loader = loadstring or load
            local chunk, compileErr = loader(source)
            assert(chunk, compileErr)

            return chunk()
        end)

        if ok then
            local envRayfield
            local sharedRayfield
            local globalRayfield = _G and rawget(_G, "Rayfield") or nil

            if getgenv then
                envRayfield = getgenv().Rayfield
            end

            if shared then
                sharedRayfield = shared.Rayfield
            end

            local candidate = resultOrErr or envRayfield or sharedRayfield or globalRayfield

            if candidate and typeof(candidate) == "table" and candidate.CreateWindow then
                Rayfield = candidate
                print("[StarCalled GAG2] Rayfield loaded from:", url)
                return true
            end
        end

        warn("[StarCalled GAG2] Rayfield load failed from:", url, resultOrErr)
        task.wait(1)
    end

    return false
end

if not loadRayfield() then
    warn("[StarCalled GAG2] Remote Rayfield failed to load, using fallback UI.")
    Rayfield = createFallbackRayfield()
end

local function waitForChildWithTimeout(parent, name, timeout)
    if not parent then
        return nil
    end

    local start = os.clock()
    local child = parent:FindFirstChild(name)

    while not child and os.clock() - start < timeout do
        task.wait(0.1)
        child = parent:FindFirstChild(name)
    end

    return child
end

-- ==================== CONFIG ====================

local RemoteFolder = waitForChildWithTimeout(ReplicatedStorage, "RemoteEvents", 8)
if not RemoteFolder then
    warn("[StarCalled GAG2] RemoteEvents folder not found in ReplicatedStorage")
end

local Remotes = {
    BuySeed = waitForChildWithTimeout(RemoteFolder, "BuySeed", 5),
    PlantSeed = waitForChildWithTimeout(RemoteFolder, "PlantSeed", 5),
    HarvestSeed = waitForChildWithTimeout(RemoteFolder, "HarvestSeed", 5),
    SellSeed = waitForChildWithTimeout(RemoteFolder, "SellSeed", 5),
    SellAll = waitForChildWithTimeout(RemoteFolder, "SellAll", 5),
    BuyGear = (RemoteFolder and (RemoteFolder:FindFirstChild("BuyGear") or RemoteFolder:FindFirstChild("BuyItem") or RemoteFolder:FindFirstChild("PurchaseGear"))) or nil,
}

local seedList = {
    "Carrot",
    "Strawberry",
    "Blueberry",
    "Tulip",
    "Tomato",
    "Apple",
    "Bamboo",
    "Mushroom",
    "Pumpkin",
    "Rose",
    "Sunflower",
    "Watermelon",
    "Grape",
    "Mango",
    "Cactus",
    "Beanstalk"
}

local gearList = {
    "Watering Can",
    "Trowel",
    "Recall Wrench",
    "Basic Sprinkler",
    "Advanced Sprinkler",
    "Godly Sprinkler",
    "Lightning Rod",
    "Harvest Tool",
    "Favorite Tool"
}

local State = {
    autoBuy = false,
    autoPlant = false,
    autoHarvest = false,
    autoSell = false,
    autoBuyGear = false,
    debug = true,
    selectedSeeds = {
        Carrot = true,
    },
    selectedGears = {
        ["Watering Can"] = true,
    },
    seedIndex = 1,
    harvestToggleRef = nil,
}

-- ==================== HELPERS ====================

local function log(...)
    if State.debug then
        print("[StarCalled GAG2]", ...)
    end
end

local function notify(title, content, duration)
    pcall(function()
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = duration or 4,
        })
    end)
end

local function safeCall(label, callback)
    local ok, err = pcall(callback)

    if not ok then
        warn("[StarCalled GAG2]", label, err)
    end
end

local function selectedSeedArray()
    local result = {}

    for _, seed in ipairs(seedList) do
        if State.selectedSeeds[seed] then
            table.insert(result, seed)
        end
    end

    if #result == 0 then
        State.selectedSeeds.Carrot = true
        table.insert(result, "Carrot")
    end

    return result
end

local function selectedGearArray()
    local result = {}

    for _, gear in ipairs(gearList) do
        if State.selectedGears[gear] then
            table.insert(result, gear)
        end
    end

    if #result == 0 then
        State.selectedGears["Watering Can"] = true
        table.insert(result, "Watering Can")
    end

    return result
end

local function nextSelectedSeed()
    local seeds = selectedSeedArray()

    if State.seedIndex > #seeds then
        State.seedIndex = 1
    end

    local seed = seeds[State.seedIndex]
    State.seedIndex += 1

    return seed
end

local function textHasSelectedSeed(text)
    text = string.lower(text or "")

    for seed in pairs(State.selectedSeeds) do
        if string.find(text, string.lower(seed), 1, true) then
            return true
        end
    end

    return false
end

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getRoot()
    local character = getCharacter()
    return character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local character = getCharacter()
    return character:FindFirstChildOfClass("Humanoid")
end

local function getBackpack()
    return player:FindFirstChild("Backpack")
end

local function getMousePosition()
    if mouse and mouse.Hit then
        return mouse.Hit.Position
    end

    local root = getRoot()

    if root then
        return root.Position + root.CFrame.LookVector * 6
    end

    return Vector3.new(0, 5, 0)
end

local function findToolMatching(seed)
    local character = getCharacter()
    local backpack = getBackpack()

    local containers = {
        character,
        backpack,
    }

    for _, container in ipairs(containers) do
        if container then
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") then
                    local toolName = string.lower(tool.Name)
                    local seedName = string.lower(seed)

                    if string.find(toolName, seedName, 1, true) then
                        return tool
                    end
                end
            end
        end
    end

    return nil
end

local function equipSeedTool(seed)
    local humanoid = getHumanoid()
    local tool = findToolMatching(seed)

    if not humanoid or not tool then
        return nil
    end

    humanoid:EquipTool(tool)
    task.wait(0.15)

    return getCharacter():FindFirstChildOfClass("Tool")
end

local function findSelectedCropTools()
    local tools = {}
    local character = getCharacter()
    local backpack = getBackpack()

    local containers = {
        character,
        backpack,
    }

    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") and textHasSelectedSeed(item.Name) then
                    table.insert(tools, item)
                end
            end
        end
    end

    return tools
end

-- ==================== GAME ACTIONS ====================

local function buySeed(seed)
    log("Buying seed:", seed)
    Remotes.BuySeed:FireServer(seed)
end

local function buyGear(gear)
    if not Remotes.BuyGear then
        notify("Missing BuyGear", "Add RemoteEvents.BuyGear to your game, or rename this script's fallback to your gear remote.", 6)
        warn("[StarCalled GAG2] Missing gear remote. Expected RemoteEvents.BuyGear, BuyItem, or PurchaseGear")
        return
    end

    log("Buying gear:", gear)
    Remotes.BuyGear:FireServer(gear)
end

local function plantSeed(seed)
    local position = getMousePosition()

    log("Planting seed:", seed, position)

    equipSeedTool(seed)

    Remotes.PlantSeed:FireServer(seed, position)
end

local function harvestSeed(seed)
    log("Harvesting seed:", seed)
    Remotes.HarvestSeed:FireServer(seed)
end

local function sellSeed(seed)
    log("Selling seed/crop:", seed)
    Remotes.SellSeed:FireServer(seed)
end

local function sellSelectedTools()
    local humanoid = getHumanoid()
    local tools = findSelectedCropTools()

    for _, tool in ipairs(tools) do
        if humanoid then
            humanoid:EquipTool(tool)
            task.wait(0.1)
        end

        Remotes.SellSeed:FireServer(tool.Name)
        task.wait(0.15)
    end

    for _, seed in ipairs(selectedSeedArray()) do
        sellSeed(seed)
        task.wait(0.1)
    end
end

local function sellAll()
    Remotes.SellAll:FireServer()
end

local function createWindow(params)
    if Rayfield and typeof(Rayfield.CreateWindow) == "function" then
        local ok, result = pcall(function()
            return Rayfield:CreateWindow(params)
        end)

        if ok and result then
            return result
        end

        warn("[StarCalled GAG2] Rayfield CreateWindow failed, switching to fallback UI.")
    end

    Rayfield = createFallbackRayfield()
    return Rayfield:CreateWindow(params)
end

-- ==================== GUI ====================

task.spawn(function()
    task.wait(2.5)

    local Window = createWindow({
        Name = "Grow a Garden 2 | StarCalled Hub",
        LoadingTitle = "StarCalled Hub",
        LoadingSubtitle = "Multi Seed Auto Farm",

        ConfigurationSaving = {
            Enabled = false,
        },

        Discord = {
            Enabled = false,
        },

        KeySystem = false,
    })

    local MainTab = Window:CreateTab("Farm", 4483362458)

    MainTab:CreateSection("Seeds")

    local dropdownWorked = pcall(function()
        MainTab:CreateDropdown({
            Name = "Seeds To Use",
            Options = seedList,
            CurrentOption = { "Carrot" },
            MultipleOptions = true,
            Callback = function(selection)
                State.selectedSeeds = {}

                if typeof(selection) == "table" then
                    for _, seed in ipairs(selection) do
                        State.selectedSeeds[seed] = true
                    end
                elseif typeof(selection) == "string" then
                    State.selectedSeeds[selection] = true
                end

                log("Updated selected seeds")
            end,
        })
    end)

    if not dropdownWorked then
        for _, seed in ipairs(seedList) do
            MainTab:CreateToggle({
                Name = seed,
                CurrentValue = seed == "Carrot",
                Callback = function(value)
                    State.selectedSeeds[seed] = value or nil
                end,
            })
        end
    end

    MainTab:CreateSection("Automation")

    MainTab:CreateToggle({
        Name = "Auto Buy Selected Seeds",
        CurrentValue = false,
        Callback = function(value)
            State.autoBuy = value
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Plant Selected Seeds",
        CurrentValue = false,
        Callback = function(value)
            State.autoPlant = value
        end,
    })

    State.harvestToggleRef = MainTab:CreateToggle({
        Name = "Auto Harvest Selected Seeds",
        CurrentValue = false,
        Callback = function(value)
            State.autoHarvest = value
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Sell Selected Crops",
        CurrentValue = false,
        Callback = function(value)
            State.autoSell = value
        end,
    })

    MainTab:CreateSection("Manual")

    MainTab:CreateButton({
        Name = "Buy Selected Once",
        Callback = function()
            safeCall("BuySelectedOnce", function()
                for _, seed in ipairs(selectedSeedArray()) do
                    buySeed(seed)
                    task.wait(0.15)
                end
            end)
        end,
    })

    MainTab:CreateButton({
        Name = "Plant Selected Once",
        Callback = function()
            safeCall("PlantSelectedOnce", function()
                for _, seed in ipairs(selectedSeedArray()) do
                    plantSeed(seed)
                    task.wait(0.4)
                end
            end)
        end,
    })

    MainTab:CreateButton({
        Name = "Harvest Selected Once",
        Callback = function()
            safeCall("HarvestSelectedOnce", function()
                for _, seed in ipairs(selectedSeedArray()) do
                    harvestSeed(seed)
                    task.wait(0.2)
                end
            end)
        end,
    })

    MainTab:CreateButton({
        Name = "Sell Selected Once",
        Callback = function()
            safeCall("SellSelectedOnce", sellSelectedTools)
        end,
    })

    MainTab:CreateButton({
        Name = "Sell All",
        Callback = function()
            safeCall("SellAll", sellAll)
        end,
    })

    local GearTab = Window:CreateTab("Gear", 4483362458)

    GearTab:CreateSection("Gear")

    local gearDropdownWorked = pcall(function()
        GearTab:CreateDropdown({
            Name = "Gear To Buy",
            Options = gearList,
            CurrentOption = { "Watering Can" },
            MultipleOptions = true,
            Callback = function(selection)
                State.selectedGears = {}

                if typeof(selection) == "table" then
                    for _, gear in ipairs(selection) do
                        State.selectedGears[gear] = true
                    end
                elseif typeof(selection) == "string" then
                    State.selectedGears[selection] = true
                end

                log("Updated selected gear")
            end,
        })
    end)

    if not gearDropdownWorked then
        for _, gear in ipairs(gearList) do
            GearTab:CreateToggle({
                Name = gear,
                CurrentValue = gear == "Watering Can",
                Callback = function(value)
                    State.selectedGears[gear] = value or nil
                end,
            })
        end
    end

    GearTab:CreateSection("Automation")

    GearTab:CreateToggle({
        Name = "Auto Buy Selected Gear",
        CurrentValue = false,
        Callback = function(value)
            State.autoBuyGear = value
        end,
    })

    GearTab:CreateSection("Manual")

    GearTab:CreateButton({
        Name = "Buy Selected Gear Once",
        Callback = function()
            safeCall("BuySelectedGearOnce", function()
                for _, gear in ipairs(selectedGearArray()) do
                    buyGear(gear)
                    task.wait(0.15)
                end
            end)
        end,
    })

    local DebugTab = Window:CreateTab("Debug", 4483362458)

    DebugTab:CreateToggle({
        Name = "Verbose Logging",
        CurrentValue = true,
        Callback = function(value)
            State.debug = value
        end,
    })

    DebugTab:CreateButton({
        Name = "Print Selected Seeds",
        Callback = function()
            for _, seed in ipairs(selectedSeedArray()) do
                log("Selected:", seed)
            end
        end,
    })

    DebugTab:CreateButton({
        Name = "Print Selected Gear",
        Callback = function()
            for _, gear in ipairs(selectedGearArray()) do
                log("Selected gear:", gear)
            end
        end,
    })

    DebugTab:CreateButton({
        Name = "Test Plant Current Mouse Position",
        Callback = function()
            safeCall("TestPlant", function()
                local seed = nextSelectedSeed()
                plantSeed(seed)
            end)
        end,
    })

    -- ==================== LOOPS ====================

    task.spawn(function()
        while task.wait(0.6) do
            if State.autoBuy then
                safeCall("AutoBuy", function()
                    for _, seed in ipairs(selectedSeedArray()) do
                        buySeed(seed)
                        task.wait(0.15)
                    end
                end)
            end
        end
    end)

    task.spawn(function()
        while task.wait(1) do
            if State.autoBuyGear then
                safeCall("AutoBuyGear", function()
                    for _, gear in ipairs(selectedGearArray()) do
                        buyGear(gear)
                        task.wait(0.15)
                    end
                end)
            end
        end
    end)

    task.spawn(function()
        while task.wait(1.2) do
            if State.autoPlant then
                safeCall("AutoPlant", function()
                    local seed = nextSelectedSeed()
                    plantSeed(seed)
                end)
            end
        end
    end)

    task.spawn(function()
        while task.wait(0.8) do
            if State.autoHarvest then
                safeCall("AutoHarvest", function()
                    for _, seed in ipairs(selectedSeedArray()) do
                        harvestSeed(seed)
                        task.wait(0.15)
                    end
                end)
            end
        end
    end)

    task.spawn(function()
        while task.wait(5) do
            if State.autoSell then
                safeCall("AutoSell", sellSelectedTools)
            end
        end
    end)

    notify("GAG2 Loaded", "Multi-seed farm ready", 6)
end)
