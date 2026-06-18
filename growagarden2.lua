-- Grow a Garden 2 | StarCalled Hub v8
-- Multi-seed harvest/plant/sell + stronger plant logic

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
task.wait(2)

local Rayfield

local function loadRayfield()
    local urls = {
        "https://sirius.menu/rayfield",
        "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"
    }

    for _, url in ipairs(urls) do
        local success, result = pcall(function()
            return loadstring(game:HttpGet(url, true))()
        end)

        if success and result then
            Rayfield = result
            print("[StarCalled GAG2] Rayfield loaded successfully from:", url)
            return true
        end

        task.wait(1)
    end

    error("[StarCalled GAG2] Rayfield failed to load")
end

loadRayfield()

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

local State = {
    autoBuy = false,
    autoPlant = false,
    autoHarvest = false,
    autoSell = false,
    debug = true,
    selectedSeeds = { Carrot = true },
    remoteEvent = nil,
    harvestToggleRef = nil,
    seedIndex = 1,
}

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

local function safeCall(label, fn)
    local ok, err = pcall(fn)
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

local function instanceHasSelectedSeed(instance)
    local node = instance

    while node do
        if textHasSelectedSeed(node.Name) then
            return true
        end

        for _, attrName in ipairs({ "Seed", "SeedName", "Plant", "PlantName", "Crop", "CropName", "Fruit", "FruitName" }) do
            local attr = node:GetAttribute(attrName)
            if attr and textHasSelectedSeed(tostring(attr)) then
                return true
            end
        end

        node = node.Parent
    end

    return false
end

local function scanForRemotes()
    local found = {}

    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            table.insert(found, v)
        end
    end

    return found
end

local function resolveRemote()
    local sharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

    if sharedModules then
        local packet = sharedModules:FindFirstChild("Packet")
        if packet then
            local remote = packet:FindFirstChild("RemoteEvent")
            if remote and remote:IsA("RemoteEvent") then
                return remote
            end
        end
    end

    local remotes = scanForRemotes()
    return remotes[1]
end

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getCharacterRoot()
    local character = getCharacter()
    return character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local character = getCharacter()
    return character:FindFirstChildOfClass("Humanoid")
end

local function resolvePlotByOwner()
    local gardensRoot =
        Workspace:FindFirstChild("Gardens", true)
        or Workspace:FindFirstChild("Plots", true)
        or Workspace:FindFirstChild("Farm", true)

    if not gardensRoot then
        return nil
    end

    for _, plot in ipairs(gardensRoot:GetChildren()) do
        local owner = plot:FindFirstChild("Owner")

        if owner then
            if owner:IsA("ObjectValue") and owner.Value == player then
                return plot
            end

            if owner:IsA("StringValue") and owner.Value == player.Name then
                return plot
            end
        end
    end

    return nil
end

local function resolvePlotByProximity()
    local root = getCharacterRoot()
    if not root then
        return nil
    end

    local gardensRoot =
        Workspace:FindFirstChild("Gardens", true)
        or Workspace:FindFirstChild("Plots", true)
        or Workspace:FindFirstChild("Farm", true)

    if not gardensRoot then
        return nil
    end

    local bestPlot = nil
    local bestDistance = math.huge

    for _, plot in ipairs(gardensRoot:GetChildren()) do
        local ok, pivot = pcall(function()
            return plot:GetPivot()
        end)

        if ok and pivot then
            local distance = (root.Position - pivot.Position).Magnitude

            if distance < bestDistance then
                bestDistance = distance
                bestPlot = plot
            end
        end
    end

    return bestPlot
end

local function getPlayerPlot()
    return resolvePlotByOwner() or resolvePlotByProximity()
end

local function getPromptPart(prompt)
    local node = prompt.Parent

    while node and not node:IsA("BasePart") do
        node = node.Parent
    end

    return node
end

local function getBackpack()
    return player:FindFirstChild("Backpack")
end

local function findToolMatching(seed)
    local character = getCharacter()
    local backpack = getBackpack()

    local patterns = {
        seed,
        seed .. " Seed",
        "[" .. seed .. "]",
    }

    local containers = { character, backpack }

    for _, container in ipairs(containers) do
        if container then
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") then
                    local toolName = string.lower(tool.Name)

                    for _, pattern in ipairs(patterns) do
                        if string.find(toolName, string.lower(pattern), 1, true) then
                            return tool
                        end
                    end
                end
            end
        end
    end

    return nil
end

local function equipToolMatching(seed)
    local humanoid = getHumanoid()
    local tool = findToolMatching(seed)

    if not humanoid or not tool then
        return nil
    end

    humanoid:EquipTool(tool)
    task.wait(0.15)

    return getCharacter():FindFirstChildOfClass("Tool")
end

local function fireRemote(...)
    if not State.remoteEvent then
        State.remoteEvent = resolveRemote()
    end

    if not State.remoteEvent then
        return false
    end

    local args = { ... }

    local ok = pcall(function()
        State.remoteEvent:FireServer(unpack(args))
    end)

    return ok
end

local function teleportAndFire(root, prompt)
    if not root or not prompt then
        return false
    end

    local part = getPromptPart(prompt)
    if not part then
        return false
    end

    local saved = root.CFrame

    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
    task.wait(0.15)

    pcall(function()
        fireproximityprompt(prompt, prompt.HoldDuration or 0)
    end)

    task.wait(0.15)
    root.CFrame = saved

    return true
end

local function findPromptsMatching(rootInstance, keywords)
    local prompts = {}

    for _, item in ipairs(rootInstance:GetDescendants()) do
        if item:IsA("ProximityPrompt") then
            local text = string.lower((item.ActionText or "") .. " " .. (item.ObjectText or "") .. " " .. item.Name)

            for _, keyword in ipairs(keywords) do
                if string.find(text, string.lower(keyword), 1, true) then
                    table.insert(prompts, item)
                    break
                end
            end
        end
    end

    return prompts
end

local function findPlantPosition(plot)
    local root = getCharacterRoot()

    local preferredNames = {
        "Plant",
        "Soil",
        "Dirt",
        "Plot",
        "Garden",
        "Farm",
        "Ground"
    }

    for _, item in ipairs(plot:GetDescendants()) do
        if item:IsA("BasePart") then
            local lowerName = string.lower(item.Name)

            for _, name in ipairs(preferredNames) do
                if string.find(lowerName, string.lower(name), 1, true) then
                    return item.Position + Vector3.new(0, 2, 0)
                end
            end
        end
    end

    local ok, pivot = pcall(function()
        return plot:GetPivot()
    end)

    if ok and pivot then
        return pivot.Position + Vector3.new(0, 2, 0)
    end

    if root then
        return root.Position + root.CFrame.LookVector * 5
    end

    return Vector3.new(0, 5, 0)
end

local function buySeedOnce(seed)
    fireRemote("BuySeed", seed)
    fireRemote("Buy", seed)
    fireRemote("PurchaseSeed", seed)
    fireRemote("SeedShop", seed)
end

local function plantSeedOnce(seed)
    local plot = getPlayerPlot()
    local root = getCharacterRoot()

    if not plot or not root then
        log("No plot/root found for planting")
        return
    end

    local equipped = equipToolMatching(seed)

    if not equipped then
        log("Could not equip seed tool:", seed)
    end

    local position = findPlantPosition(plot)
    root.CFrame = CFrame.new(position + Vector3.new(0, 2, 0))
    task.wait(0.2)

    fireRemote("Plant", seed, position)
    fireRemote("PlantSeed", seed, position)
    fireRemote("PlaceSeed", seed, position)
    fireRemote("CreatePlant", seed, position)
    fireRemote("Plant", position, seed)
    fireRemote("PlantSeed", position, seed)

    local plantPrompts = findPromptsMatching(plot, {
        "plant",
        "place",
        "seed"
    })

    for _, prompt in ipairs(plantPrompts) do
        if not State.autoPlant then
            break
        end

        teleportAndFire(root, prompt)
        task.wait(0.25)
    end
end

local function harvestOnce()
    local plot = getPlayerPlot()
    local root = getCharacterRoot()

    if not plot or not root then
        log("No plot/root found for harvesting")
        return
    end

    local harvestPrompts = findPromptsMatching(plot, {
        "harvest",
        "collect",
        "pick"
    })

    local harvested = 0

    for _, prompt in ipairs(harvestPrompts) do
        if not State.autoHarvest then
            break
        end

        local promptText = (prompt.ActionText or "") .. " " .. (prompt.ObjectText or "") .. " " .. prompt.Name
        local matched = textHasSelectedSeed(promptText) or instanceHasSelectedSeed(prompt)

        if matched then
            if teleportAndFire(root, prompt) then
                harvested += 1
            end

            task.wait(0.2)
        end
    end

    for seed in pairs(State.selectedSeeds) do
        fireRemote("Harvest", seed)
        fireRemote("Collect", seed)
        fireRemote("HarvestPlant", seed)
        fireRemote("CollectPlant", seed)
    end

    log("Harvest attempt finished. Prompt count:", harvested)
end

local function sellSelectedOnce()
    local character = getCharacter()
    local backpack = getBackpack()
    local humanoid = getHumanoid()

    if not humanoid then
        return
    end

    local soldAny = false
    local containers = { backpack, character }

    for _, container in ipairs(containers) do
        if container then
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") and textHasSelectedSeed(tool.Name) then
                    humanoid:EquipTool(tool)
                    task.wait(0.15)

                    fireRemote("SellItem", tool.Name)
                    fireRemote("SellCrop", tool.Name)
                    fireRemote("Sell", tool.Name)
                    fireRemote("SellInventoryItem", tool.Name)

                    soldAny = true
                    task.wait(0.2)
                end
            end
        end
    end

    for seed in pairs(State.selectedSeeds) do
        fireRemote("SellItem", seed)
        fireRemote("SellCrop", seed)
        fireRemote("Sell", seed)
    end

    if not soldAny then
        log("No selected crop tools found to sell")
    end
end

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
    MainTab:CreateSection("Selected Seeds")

    local multiDropdownOk = pcall(function()
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

                log("Selected seeds updated")
            end,
        })
    end)

    if not multiDropdownOk then
        MainTab:CreateSection("Seed Toggles")

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

    MainTab:CreateSection("Auto Farm")

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

    MainTab:CreateButton({
        Name = "Manual Harvest Selected",
        Callback = function()
            safeCall("ManualHarvest", function()
                State.autoHarvest = true
                harvestOnce()
                State.autoHarvest = false

                if State.harvestToggleRef then
                    State.harvestToggleRef:Set(false)
                end
            end)
        end,
    })

    MainTab:CreateButton({
        Name = "Manual Plant Selected",
        Callback = function()
            safeCall("ManualPlant", function()
                for _, seed in ipairs(selectedSeedArray()) do
                    plantSeedOnce(seed)
                    task.wait(0.5)
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
        Name = "Rescan Remote",
        Callback = function()
            State.remoteEvent = resolveRemote()

            if State.remoteEvent then
                notify("Remote OK", State.remoteEvent:GetFullName(), 5)
                log("Remote:", State.remoteEvent:GetFullName())
            else
                notify("Remote Missing", "No RemoteEvent found", 5)
            end
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
        Name = "Print Plot",
        Callback = function()
            local plot = getPlayerPlot()

            if plot then
                notify("Plot Found", plot:GetFullName(), 5)
                log("Plot:", plot:GetFullName())
            else
                notify("Plot Missing", "Could not find your plot", 5)
            end
        end,
    })

    task.spawn(function()
        task.wait(2)
        State.remoteEvent = resolveRemote()

        if State.remoteEvent then
            notify("Remote OK", "Auto farm ready", 5)
            log("Remote resolved:", State.remoteEvent:GetFullName())
        else
            notify("Remote Missing", "Some actions may not work", 5)
            log("No RemoteEvent found")
        end
    end)

    task.spawn(function()
        while task.wait(0.5) do
            if State.autoBuy then
                safeCall("AutoBuy", function()
                    for _, seed in ipairs(selectedSeedArray()) do
                        buySeedOnce(seed)
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
                    plantSeedOnce(nextSelectedSeed())
                end)
            end
        end
    end)

    task.spawn(function()
        while task.wait(0.8) do
            if State.autoHarvest then
                safeCall("AutoHarvest", harvestOnce)
            end
        end
    end)

    task.spawn(function()
        while task.wait(5) do
            if State.autoSell then
                safeCall("AutoSell", sellSelectedOnce)
            end
        end
    end)

    notify("GAG2 Loaded", "Multi-seed farming ready", 6)
end)
