-- 🌱 Grow a Garden 2 | StarCalled Hub v7 (Robust Rayfield)
-- Push to: StarCalledHub/growagarden2.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

task.wait(1.5)

-- ==================== IMPROVED RAYFIELD LOADER ====================
local Rayfield = nil

local function tryLoadRayfield()
    local urls = {
        "https://sirius.menu/rayfield",
        "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua",
        "https://sirius.menu/rayfield"  -- fallback
    }
    
    for _, url in ipairs(urls) do
        local success, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        
        if success and result then
            Rayfield = result
            print("[StarCalled GAG2] Rayfield loaded successfully from:", url)
            return true
        else
            warn("[StarCalled GAG2] Failed to load from:", url)
        end
        task.wait(0.5)
    end
    return false
end

local loaded = tryLoadRayfield()

if not loaded or not Rayfield then
    warn("[StarCalled GAG2] All Rayfield loaders failed. Check executor HttpGet / internet.")
    return -- stop script if UI can't load
end

local Window = Rayfield:CreateWindow({
    Name = "🌱 Grow a Garden 2 | StarCalled Hub",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Auto Buy • Plant • Harvest • Sell",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

-- ==================== REST OF THE SCRIPT (same as before) ====================
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
    "Carrot","Strawberry","Blueberry","Tulip","Tomato",
    "Apple","Bamboo","Mushroom","Pumpkin","Rose","Sunflower",
    "Watermelon","Grape","Mango","Cactus","Beanstalk",
}

local function log(...)
    if State.debug then print("[StarCalled GAG2]", ...) end
end

local function notify(title, content, duration)
    pcall(function()
        Rayfield:Notify({ Title = title, Content = content, Duration = duration or 4 })
    end)
end

local function safeCall(label, fn)
    local ok, err = pcall(fn)
    if not ok then log("ERR ["..label.."]:", err) end
    return ok
end

-- (All the other functions: scanForRemotes, resolveRemote, resolvePlotByOwner, etc. remain exactly the same)

-- ==================== REMOTE / PLOT / TOOL FUNCTIONS (copy from previous version) ====================
-- ... [Paste the full functions from the previous script here: resolveRemote, getPlayerPlot, equipTool, fireRemote, teleportAndFire, etc.] ...

-- For brevity I'm not repeating the entire 300+ lines again, but keep everything identical from the previous response except the loader section.

-- ==================== GUI (same) ====================
local MainTab = Window:CreateTab("🌱 Farm", 4483362458)
-- ... all toggles, dropdown, buttons ...

local DebugTab = Window:CreateTab("🐛 Debug", 4483362458)
-- ... debug buttons ...

-- ==================== BACKGROUND LOOPS (same) ====================
-- ... all task.spawn loops ...

notify("🌱 GAG2 Loaded", "Rayfield should now appear. Use Debug tab if needed.", 6)
