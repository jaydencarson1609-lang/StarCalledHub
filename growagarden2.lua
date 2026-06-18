-- 🌱 Grow a Garden 2 | StarCalled Hub v7 (Blank Tab Fix)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

task.wait(2)

-- ==================== RAYFIELD LOADER ====================
local Rayfield = nil
local function tryLoadRayfield()
    local urls = {
        "https://sirius.menu/rayfield",
        "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"
    }
    for _, url in ipairs(urls) do
        local success, lib = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if success and lib then
            Rayfield = lib
            print("[StarCalled] Rayfield loaded from", url)
            return true
        end
        task.wait(0.8)
    end
    return false
end

if not tryLoadRayfield() then
    warn("Rayfield failed to load")
    return
end

-- ==================== DELAYED GUI CREATION (Fix for blank tabs) ====================
task.spawn(function()
    task.wait(1.5) -- Critical delay for Rayfield to fully initialize

    local Window = Rayfield:CreateWindow({
        Name = "🌱 Grow a Garden 2 | StarCalled Hub",
        LoadingTitle = "StarCalled Hub",
        LoadingSubtitle = "Auto Buy • Plant • Harvest • Sell",
        ConfigurationSaving = { Enabled = false },
        Discord = { Enabled = false },
        KeySystem = false,
    })

    -- STATE
    local State = {
        autoBuy = false, autoPlant = false, autoHarvest = false, autoSell = false,
        debug = true, selectedSeed = "Carrot", remoteEvent = nil, harvestToggleRef = nil,
    }

    local seedList = {"Carrot","Strawberry","Blueberry","Tulip","Tomato","Apple","Bamboo","Mushroom","Pumpkin","Rose","Sunflower","Watermelon","Grape","Mango","Cactus","Beanstalk"}

    local function log(...) if State.debug then print("[StarCalled GAG2]", ...) end end
    local function notify(t, c, d) pcall(function() Rayfield:Notify({Title = t, Content = c, Duration = d or 4}) end) end
    local function safeCall(l, fn) local ok, err = pcall(fn) if not ok then log("ERR ["..l.."]:", err) end end

    -- (Paste all your original functions here: resolveRemote, getPlayerPlot, equipTool, fireRemote, teleportAndFire, scanForRemotes, etc.)
    -- I'll keep them short for space — use the full ones from previous messages

    local function resolveRemote() ... end -- [add full function]
    local function getPlayerPlot() ... end
    local function equipTool(name) ... end
    local function fireRemote(...) ... end
    local function teleportAndFire(root, prompt) ... end

    -- ==================== GUI ====================
    local MainTab = Window:CreateTab("🌱 Farm", 4483362458)
    MainTab:CreateSection("🌱 Auto Farm")

    MainTab:CreateDropdown({Name = "Select Seed", Options = seedList, CurrentOption = {"Carrot"}, Callback = function(sel) State.selectedSeed = sel[1] end})

    MainTab:CreateToggle({Name = "Auto Buy Seed", CurrentValue = false, Callback = function(v) State.autoBuy = v notify("Auto Buy", v and "ON" or "OFF", 3) end})
    MainTab:CreateToggle({Name = "Auto Plant", CurrentValue = false, Callback = function(v) State.autoPlant = v end})
    
    State.harvestToggleRef = MainTab:CreateToggle({Name = "Auto Harvest", CurrentValue = false, Callback = function(v) State.autoHarvest = v end})
    MainTab:CreateToggle({Name = "Auto Sell", CurrentValue = false, Callback = function(v) State.autoSell = v end})

    MainTab:CreateButton({Name = "⚡ Manual Harvest (Once)", Callback = function() ... end}) -- your original logic

    local DebugTab = Window:CreateTab("🐛 Debug", 4483362458)
    DebugTab:CreateToggle({Name = "Verbose Logging", CurrentValue = true, Callback = function(v) State.debug = v end})
    -- Add other debug buttons...

    -- ==================== BACKGROUND LOOPS ====================
    task.spawn(function() task.wait(2) State.remoteEvent = resolveRemote() end)
    -- ... rest of your loops (autoBuy, autoPlant, etc.)

    notify("🌱 Loaded", "GUI should now be visible!", 6)
end)
