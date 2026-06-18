-- 🌱 Grow a Garden 2 | StarCalled Hub v7.2 (Icon Error Fixed)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

task.wait(4) -- Extra stability wait

-- ==================== ROBUST RAYFIELD LOADER ====================
local Rayfield = nil
local function loadRayfield()
    local urls = {
        "https://sirius.menu/rayfield",
        "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua",
        "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/Rayfield.lua"
    }
    
    for _, url in ipairs(urls) do
        local success, result = pcall(function()
            return loadstring(game:HttpGet(url, true))()
        end)
        if success and typeof(result) == "table" and result.CreateWindow then
            Rayfield = result
            print("[StarCalled GAG2] ✅ Rayfield loaded from:", url)
            return true
        end
        task.wait(1.5)
    end
    error("❌ Failed to load Rayfield")
end

loadRayfield()

-- ==================== DELAYED GUI (Critical for fixing icon spam) ====================
task.spawn(function()
    task.wait(5) -- Increased delay = main fix for "X Loading" icon error + blank tabs

    local success, Window = pcall(function()
        return Rayfield:CreateWindow({
            Name = "🌱 Grow a Garden 2 | StarCalled Hub",
            LoadingTitle = "StarCalled Hub",
            LoadingSubtitle = "v7.2 - Stable",
            ConfigurationSaving = { Enabled = false },
            Discord = { Enabled = false },
            KeySystem = false,
        })
    end)

    if not success or not Window then
        warn("[StarCalled] Window creation failed, retrying...")
        task.wait(2)
        Window = Rayfield:CreateWindow({ ... }) -- fallback
    end

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
    local function notify(t, c, d) 
        pcall(function() 
            Rayfield:Notify({Title = t, Content = c, Duration = d or 5}) 
        end) 
    end

    -- ==================== REMOTE & PLOT UTILS ====================
    local function resolveRemote()
        local paths = {
            ReplicatedStorage:FindFirstChild("SharedModules", true),
            ReplicatedStorage:FindFirstChild("Remotes", true),
            ReplicatedStorage:FindFirstChild("Network", true)
        }
        for _, container in ipairs(paths) do
            if container then
                local re = container:FindFirstChildOfClass("RemoteEvent") or container:FindFirstChild("RemoteEvent", true)
                if re then return re end
            end
        end
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then return v end
        end
        return nil
    end

    local function getPlayerPlot()
        local gardens = Workspace:FindFirstChild("Gardens", true) or Workspace:FindFirstChild("Plots", true) or Workspace:FindFirstChild("Farm", true)
        if not gardens then return nil end

        -- Owner check
        for _, plot in ipairs(gardens:GetChildren()) do
            local owner = plot:FindFirstChild("Owner")
            if owner and ((owner:IsA("ObjectValue") and owner.Value == player) or (owner:IsA("StringValue") and owner.Value == player.Name)) then
                return plot
            end
        end

        -- Proximity fallback
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local best, dist = nil, math.huge
            for _, plot in ipairs(gardens:GetChildren()) do
                local ok, pivot = pcall(function() return plot:GetPivot() end)
                if ok then
                    local d = (hrp.Position - pivot.Position).Magnitude
                    if d < dist then dist = d; best = plot end
                end
            end
            return best
        end
        return nil
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
        if State.remoteEvent then
            pcall(function() State.remoteEvent:FireServer(action, ...) end)
        end
    end

    -- ==================== GUI ====================
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

    MainTab:CreateButton({Name = "⚡ Manual Harvest All", Callback = function()
        State.autoHarvest = true
        task.delay(6, function() State.autoHarvest = false; if State.harvestToggleRef then State.harvestToggleRef:Set(false) end end)
    end})

    local DebugTab = Window:CreateTab("🐛 Debug", 4483362458)
    DebugTab:CreateToggle({Name = "Verbose Logging", CurrentValue = true, Callback = function(v) State.debug = v end})

    -- ==================== BACKGROUND LOOPS ====================
    task.spawn(function()
        task.wait(2)
        State.remoteEvent = resolveRemote()
        if State.remoteEvent then
            notify("✅ Remote Connected", "Auto farm is ready!", 6)
        else
            notify("⚠️ No Remote Found", "Some features may need manual adjustment", 8)
        end
    end})

    -- Auto Buy
    task.spawn(function()
        while true do
            if State.autoBuy then fireRemote("BuySeed", State.selectedSeed) end
            task.wait(0.5)
        end
    end)

    -- Auto Plant
    task.spawn(function()
        while true do
            if State.autoPlant then
                local plot = getPlayerPlot()
                if plot then
                    for _, prompt in ipairs(getProximityPrompts(plot)) do
                        if prompt.ActionText:lower():find("plant") or prompt.ObjectText:lower():find("seed") then
                            pcall(function() fireproximityprompt(prompt, prompt.HoldDuration or 0) end)
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
                    for _, prompt in ipairs(getProximityPrompts(plot)) do
                        if prompt.ActionText:lower():find("harvest") or prompt.ActionText:lower():find("collect") then
                            pcall(function() fireproximityprompt(prompt, prompt.HoldDuration or 0) end)
                        end
                    end
                end
            end
            task.wait(0.6)
        end
    end)

    -- Auto Sell
    task.spawn(function()
        while true do
            if State.autoSell then
                fireRemote("SellAll")
                task.wait(5)
            end
            task.wait(7)
        end
    end)

    notify("🌱 StarCalled Hub v7.2", "Loaded successfully! Icon spam should be minimized.", 8)
end)
