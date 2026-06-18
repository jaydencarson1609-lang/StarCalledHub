-- Grow a Garden 2 | StarCalled Hub v7.1
-- Fixed: Rayfield loading Icon error + removed blank placeholder loops

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
task.wait(2)

-- ==================== ROBUST RAYFIELD LOADER ====================

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
        else
            warn("[StarCalled GAG2] Rayfield failed from:", url, result)
        end

        task.wait(1)
    end

    error("[StarCalled GAG2] Rayfield failed to load")
end

loadRayfield()

-- ==================== STATE ====================

local State = {
    autoBuy = false,
    autoPlant = false,
    autoHarvest = false,
    autoSell = false,
    debug = true,
    selectedSeed = "Carrot",
    remoteEvent = nil,
    harvestToggleRef = nil,
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

-- ==================== HELPERS ====================

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

local function getCharacterRoot()
    local character = player.Character or player.CharacterAdded:Wait()
    return character:FindFirstChild("HumanoidRootPart")
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

local function equipTool(name)
    local character = player.Character
    if not character then
        return nil
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return nil
    end

    local backpack = player:FindFirstChild("Backpack")
    local tool = character:FindFirstChild(name) or (backpack and backpack:FindFirstChild(name))

    if not tool then
        return nil
    end

    humanoid:EquipTool(tool)
    task.wait(0.1)

    return character:FindFirstChildOfClass("Tool")
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

-- ==================== ACTIONS ====================

local function buySeedOnce()
    fireRemote("BuySeed", State.selectedSeed)
    fireRemote("Buy", State.selectedSeed)
    fireRemote("PurchaseSeed", State.selectedSeed)
end

local function plantOnce()
    local plot = getPlayerPlot()
    local root = getCharacterRoot()

    if not plot or not root then
        log("No plot/root found for planting")
        return
    end

    equipTool(State.selectedSeed)
    fireRemote("Plant", State.selectedSeed)
    fireRemote("PlantSeed", State.selectedSeed)

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

    for _, prompt in ipairs(harvestPrompts) do
        if not State.autoHarvest then
            break
        end

        teleportAndFire(root, prompt)
        task.wait(0.2)
    end

    fireRemote("Harvest")
    fireRemote("Collect")
end

local function sellOnce()
    fireRemote("SellInventory")
    fireRemote("SellAll")
    fireRemote("Sell")
end

-- ==================== GUI ====================

task.spawn(function()
    task.wait(2.5)

    local Window = Rayfield:CreateWindow({
        Name = "Grow a Garden 2 | StarCalled Hub",

        -- Plain loading text avoids Rayfield/Opiunware's broken Loading.Icon lookup.
        LoadingTitle = "StarCalled Hub",
        LoadingSubtitle = "Auto Buy - Plant - Harvest - Sell",

        ConfigurationSaving = {
            Enabled = false,
        },

        Discord = {
            Enabled = false,
        },

        KeySystem = false,
    })

    local MainTab = Window:CreateTab("Farm", 4483362458)
    MainTab:CreateSection("Auto Farm")

    MainTab:CreateDropdown({
        Name = "Select Seed",
        Options = seedList,
        CurrentOption = { "Carrot" },
        Callback = function(selection)
            State.selectedSeed = selection[1] or "Carrot"
            log("Selected seed:", State.selectedSeed)
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Buy Seed",
        CurrentValue = false,
        Callback = function(value)
            State.autoBuy = value
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Plant",
        CurrentValue = false,
        Callback = function(value)
            State.autoPlant = value
        end,
    })

    State.harvestToggleRef = MainTab:CreateToggle({
        Name = "Auto Harvest",
        CurrentValue = false,
        Callback = function(value)
            State.autoHarvest = value
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Sell",
        CurrentValue = false,
        Callback = function(value)
            State.autoSell = value
        end,
    })

    MainTab:CreateButton({
        Name = "Manual Harvest Once",
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

    -- ==================== BACKGROUND LOOPS ====================

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
        while task.wait(0.4) do
            if State.autoBuy then
                safeCall("AutoBuy", buySeedOnce)
            end
        end
    end)

    task.spawn(function()
        while task.wait(1) do
            if State.autoPlant then
                safeCall("AutoPlant", plantOnce)
            end
        end
    end)

    task.spawn(function()
        while task.wait(0.7) do
            if State.autoHarvest then
                safeCall("AutoHarvest", harvestOnce)
            end
        end
    end)

    task.spawn(function()
        while task.wait(5) do
            if State.autoSell then
                safeCall("AutoSell", sellOnce)
            end
        end
    end)

    notify("GAG2 Loaded", "UI loaded successfully", 6)
end)
