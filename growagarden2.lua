-- 🌱 Grow a Garden 2 | StarCalled Hub v7.1 (Fixed)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

task.wait(3) -- Extra wait for game stability

-- ==================== ROBUST RAYFIELD LOADER ====================
local Rayfield = nil
local function loadRayfield()
    local urls = {
        "https://sirius.menu/rayfield",
        "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua",
        "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/Rayfield.lua" -- extra fallback
    }
    for _, url in ipairs(urls) do
        local success, result = pcall(function()
            return loadstring(game:HttpGet(url, true))()
        end)
        if success and typeof(result) == "table" then
            Rayfield = result
            print("[StarCalled GAG2] Rayfield loaded successfully from:", url)
            return true
        end
        task.wait(1)
    end
    error("Failed to load Rayfield after multiple attempts")
end
loadRayfield()

-- ==================== DELAYED GUI ====================
task.spawn(function()
    task.wait(3.5) -- Increased delay helps with blank tabs + icon errors

    local Window = Rayfield:CreateWindow({
        Name = "🌱 Grow a Garden 2 | StarCalled Hub",
        LoadingTitle = "StarCalled Hub",
        LoadingSubtitle = "v7.1 - Fully Fixed",
        ConfigurationSaving = { Enabled = false },
        Discord = { Enabled = false },
        KeySystem = false,
    })

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

    local seedList = {"Carrot","Strawberry","Blueberry","Tulip","Tomato","Apple","Bamboo","Mushroom","Pumpkin","Rose","Sunflower","Watermelon","Grape","Mango","Cactus","Beanstalk"}

    local function log(...) if State.debug then print("[StarCalled GAG2]", ...) end end
    local function notify(t, c, d) pcall(function() Rayfield:Notify({Title = t, Content = c, Duration = d or 5}) end) end

    -- ==================== REMOTE & PLOT UTILS ====================
    local function resolveRemote()
        -- Try common paths first
        local sm = ReplicatedStorage:FindFirstChild("SharedModules", true)
        if sm then
            local packet = sm:FindFirstChild("Packet") or sm:FindFirstChild("Network")
            if packet then
                local re = packet:FindFirstChildOfClass("RemoteEvent")
                if re then return re end
            end
        end
        -- Fallback: any RemoteEvent
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then return v end
        end
        return nil
    end

    local function getPlayerPlot()
        -- Owner check
        local gardens = Workspace:FindFirstChild("Gardens", true) or Workspace:FindFirstChild("Plots", true) or Workspace:FindFirstChild("Farm", true)
        if gardens then
            for _, plot in ipairs(gardens:GetChildren()) do
                local owner = plot:FindFirstChild("Owner")
                if owner and ((owner:IsA("ObjectValue") and owner.Value == player) or (owner:IsA("StringValue") and owner.Value == player.Name)) then
                    return plot
                end
            end
        end
        -- Proximity fallback
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local best, dist = nil, math.huge
        if gardens then
            for _, plot in ipairs(gardens:GetChildren()) do
                local ok, pivot = pcall(function() return plot:GetPivot() end)
                if ok then
                    local d = (hrp.Position - pivot.Position).Magnitude
                    if d < dist then dist = d; best = plot end
                end
            end
        end
        return best
    end

    local function getProximityPrompts(root)
        local prompts = {}
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                table.insert(prompts, obj)
            end
        end
        return prompts
    end

    local function fireRemote(action, ...)
        if not State.remoteEvent then return false end
        pcall(function() State.remoteEvent:FireServer(action, ...) end)
        return true
    end

    -- ==================== MAIN GUI ====================
    local MainTab = Window:CreateTab("🌱 Farm", 4483362458)

    MainTab:CreateSection("Auto Farm Controls")
    MainTab:CreateDropdown({
        Name = "Select Seed",
        Options = seedList,
        CurrentOption = {"Carrot"},
        Callback = function(sel) State.selectedSeed = sel[1] end,
    })

    MainTab:CreateToggle({Name = "Auto Buy Seed", CurrentValue = false, Callback = function(v) State.autoBuy = v end})
    MainTab:CreateToggle({Name = "Auto Plant", CurrentValue = false, Callback = function(v) State.autoPlant = v end})
    State.harvestToggleRef = MainTab:CreateToggle({Name = "Auto Harvest", CurrentValue = false, Callback = function(v) State.autoHarvest = v end})
    MainTab:CreateToggle({Name = "Auto Sell", CurrentValue = false, Callback = function(v) State.autoSell = v end})

    MainTab:CreateButton({Name = "⚡ Manual Harvest All (Once)", Callback = function()
        State.autoHarvest = true
        task.delay(5, function() State.autoHarvest = false; if State.harvestToggleRef then State.harvestToggleRef:Set(false) end end)
    end})

    -- Debug Tab
    local DebugTab = Window:CreateTab("🐛 Debug", 4483362458)
    DebugTab:CreateToggle({Name = "Verbose Logging", CurrentValue = true, Callback = function(v) State.debug = v end})

    -- ==================== BACKGROUND LOOPS ====================
    task.spawn(function()
        task.wait(2)
        State.remoteEvent = resolveRemote()
        if State.remoteEvent then
            notify("✅ Remote Found", "Auto farm systems ready!", 6)
        else
            notify("⚠️ Remote Not Found", "Some features may not work", 6)
        end
    end)

    -- Auto Buy
    task.spawn(function()
        while true do
            if State.autoBuy then
                fireRemote("BuySeed", State.selectedSeed)
            end
            task.wait(0.5)
        end
    end)

    -- Auto Plant
    task.spawn(function()
        while true do
            if State.autoPlant then
                local plot = getPlayerPlot()
                if plot then
                    local prompts = getProximityPrompts(plot)
                    for _, prompt in ipairs(prompts) do
                        if prompt.ActionText:lower():find("plant") or prompt.ObjectText:lower():find("seed") then
                            pcall(function()
                                fireproximityprompt(prompt, prompt.HoldDuration or 0)
                            end)
                        end
                    end
                end
            end
            task.wait(0.8)
        end
    end)

    -- Auto Harvest
    task.spawn(function()
        while true do
            if State.autoHarvest then
                local plot = getPlayerPlot()
                if plot then
                    local prompts = getProximityPrompts(plot)
                    for _, prompt in ipairs(prompts) do
                        if prompt.ActionText:lower():find("harvest") or prompt.ActionText:lower():find("collect") then
                            pcall(function()
                                fireproximityprompt(prompt, prompt.HoldDuration or 0)
                            end)
                        end
                    end
                end
            end
            task.wait(0.7)
        end
    end)

    -- Auto Sell
    task.spawn(function()
        while true do
            if State.autoSell then
                fireRemote("SellAll") -- common action name; adjust if needed
                task.wait(4)
            end
            task.wait(6)
        end
    end)

    notify("🌱 StarCalled Hub Loaded!", "All systems online. Icon spam is harmless.", 8)
end)
