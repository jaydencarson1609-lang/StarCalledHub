-- Grow a Garden 2 | StarCalled Hub v9
-- For your own Roblox game
-- Multi seed buy / plant / harvest / sell

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
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
        return response.Body
    end

    if http_request then
        local response = http_request({Url = url, Method = "GET"})
        return response.Body
    end

    if request then
        local response = request({Url = url, Method = "GET"})
        return response.Body
    end

    error("Your executor does not support HttpGet or http_request")
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

        local envRayfield
        local sharedRayfield
        local globalRayfield = _G and rawget(_G, "Rayfield") or nil

        if getgenv then
            envRayfield = getgenv().Rayfield
        end

        if shared then
            sharedRayfield = shared.Rayfield
        end

        local candidate = ok and (resultOrErr or envRayfield or sharedRayfield or globalRayfield)

        if candidate and typeof(candidate) == "table" and candidate.CreateWindow then
            Rayfield = candidate
            print("[StarCalled GAG2] Rayfield loaded from:", url)
            return true
        end

        warn("[StarCalled GAG2] Rayfield load failed from:", url, resultOrErr)
        task.wait(1)
    end

    error("[StarCalled GAG2] Rayfield failed to load. Turn on HTTP requests / use an executor with loadstring + HttpGet support.")
end

loadRayfield()

-- ==================== CONFIG ====================

local RemoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")

local Remotes = {
    BuySeed = RemoteFolder:WaitForChild("BuySeed"),
    PlantSeed = RemoteFolder:WaitForChild("PlantSeed"),
    HarvestSeed = RemoteFolder:WaitForChild("HarvestSeed"),
    SellSeed = RemoteFolder:WaitForChild("SellSeed"),
    SellAll = RemoteFolder:WaitForChild("SellAll"),
    BuyGear = RemoteFolder:FindFirstChild("BuyGear") or RemoteFolder:FindFirstChild("BuyItem") or RemoteFolder:FindFirstChild("PurchaseGear"),
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

-- ==================== GUI ====================

task.spawn(function()
    task.wait(2.5)

    local Window = Rayfield:CreateWindow({
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
