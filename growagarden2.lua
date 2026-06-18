-- 🌱 Grow a Garden 2 | StarCalled Hub v7 (Anti-Blank Fix)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

task.wait(2)

-- ==================== RAYFIELD LOADER ====================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Extra safety wait
task.wait(1.2)

-- ==================== WINDOW + DELAYED GUI ====================
task.spawn(function()
    task.wait(1.8)  -- This delay is critical for blank tab fix

    local Window = Rayfield:CreateWindow({
        Name = "🌱 Grow a Garden 2 | StarCalled Hub",
        LoadingTitle = "StarCalled Hub",
        LoadingSubtitle = "Auto Buy • Plant • Harvest • Sell",
        ConfigurationSaving = { Enabled = false },
        Discord = { Enabled = false },
        KeySystem = false,
    })

    local State = {
        autoBuy = false, autoPlant = false, autoHarvest = false, autoSell = false,
        debug = true, selectedSeed = "Carrot", remoteEvent = nil, harvestToggleRef = nil,
    }

    local seedList = {"Carrot","Strawberry","Blueberry","Tulip","Tomato","Apple","Bamboo","Mushroom","Pumpkin","Rose","Sunflower","Watermelon","Grape","Mango","Cactus","Beanstalk"}

    local function log(...) if State.debug then print("[StarCalled GAG2]", ...) end end
    local function notify(t, c, d) pcall(function() Rayfield:Notify({Title=t, Content=c, Duration=d or 4}) end) end
    local function safeCall(l, fn) pcall(fn) end  -- simplified

    -- ==================== YOUR FUNCTIONS (add the full ones) ====================
    local function resolveRemote()
        -- paste full resolveRemote + scanForRemotes from previous script
        local sm = ReplicatedStorage:FindFirstChild("SharedModules")
        if sm then
            local packet = sm:FindFirstChild("Packet")
            if packet then local re = packet:FindFirstChild("RemoteEvent") if re then return re end end
        end
        -- ... rest of remote logic
    end

    -- Add the rest: getPlayerPlot, equipTool, fireRemote, teleportAndFire, etc.

    -- ==================== GUI CREATION ====================
    local MainTab = Window:CreateTab("🌱 Farm", 4483362458)
    MainTab:CreateSection("🌱 Auto Farm")

    MainTab:CreateDropdown({
        Name = "Select Seed",
        Options = seedList,
        CurrentOption = {"Carrot"},
        Callback = function(sel) State.selectedSeed = sel[1] log("Seed:", State.selectedSeed) end,
    })

    MainTab:CreateToggle({Name = "Auto Buy Seed", CurrentValue = false, Callback = function(v) State.autoBuy = v end})
    MainTab:CreateToggle({Name = "Auto Plant", CurrentValue = false, Callback = function(v) State.autoPlant = v end})
    
    State.harvestToggleRef = MainTab:CreateToggle({Name = "Auto Harvest", CurrentValue = false, Callback = function(v) State.autoHarvest = v end})
    MainTab:CreateToggle({Name = "Auto Sell", CurrentValue = false, Callback = function(v) State.autoSell = v end})

    MainTab:CreateButton({Name = "⚡ Manual Harvest (Once)", Callback = function() 
        -- your manual harvest logic
    end})

    local DebugTab = Window:CreateTab("🐛 Debug", 4483362458)
    DebugTab:CreateToggle({Name = "Verbose Logging", CurrentValue = true, Callback = function(v) State.debug = v end})

    -- Add more debug buttons as needed...

    -- ==================== BACKGROUND LOOPS ====================
    task.spawn(function()
        task.wait(2)
        State.remoteEvent = resolveRemote()
        notify("✅ Ready", "Auto farm loaded!", 5)
    end)

    -- Paste the 4 main task.spawn loops (autoBuy, autoPlant, autoHarvest, autoSell) here

    notify("🌱 GAG2 Loaded", "UI should now be fully visible", 6)
end)
