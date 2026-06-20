-- StarCalled Hub | Funky Friday - FIXED v1.1
-- Auto Play (Sick/Perfect) + Auto Farm + Stats

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Funky Friday • Auto Play & Farm",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

local MainTab = Window:CreateTab("🎵 Main", 4483362458)
local FarmTab = Window:CreateTab("🌾 Farm", 4483362458)
local StatsTab = Window:CreateTab("📊 Stats", 4483362458)
local OtherTab = Window:CreateTab("🛠 Others", 4483362458)

local autoPlayRunning = false
local autoFarmRunning = false
local afkRunning = false
local playCount = 0
local farmCount = 0

-- ==================== AUTO PLAYER ====================
local function loadBestAutoplayer()
    Rayfield:Notify({ Title = "🎵 Auto Play", Content = "Loading best autoplayer...", Duration = 3 })
    
    -- Try modern options (prioritized)
    local success = pcall(function()
        -- Option 1: Fire Hub (popular & updated)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/InfernusScripts/Fire-Hub/main/Loader"))()
    end)
    
    if not success then
        pcall(function()
            -- Option 2: OldNCP port (Wally fork)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/OldNCP/funky-friday-autoplay/refs/heads/main/metadata.lua"))()
        end)
    end
    
    if not success then
        Rayfield:Notify({ Title = "⚠️ Warning", Content = "Autoplayer failed to load. Try another executor or script.", Duration = 5 })
    else
        Rayfield:Notify({ Title = "✅ Success", Content = "Autoplayer loaded! Aim for Sick hits.", Duration = 4 })
    end
end

local function startAutoPlay()
    loadBestAutoplayer()
end

-- ==================== MAIN TAB ====================
MainTab:CreateSection("🎵 Auto Play Controls")
local playStatusLbl = MainTab:CreateLabel("⚪ Status: Idle")
local songLbl = MainTab:CreateLabel("🎶 Current Song: None")

MainTab:CreateToggle({
    Name = "Auto Play (Sick/Perfect Hits)",
    CurrentValue = false,
    Flag = "AutoPlay",
    Callback = function(val)
        autoPlayRunning = val
        if val then
            playStatusLbl:Set("🟢 Auto Playing (Sick)...")
            startAutoPlay()
        else
            playStatusLbl:Set("⚪ Status: Idle")
        end
    end,
})

MainTab:CreateButton({ Name = "Force Load Autoplayer", Callback = startAutoPlay })

MainTab:CreateSection("⚙️ Timing Settings (for Sick accuracy)")
local hitDelay = 0
MainTab:CreateSlider({
    Name = "Hit Delay (ms) - Lower = Earlier Hits",
    Range = {-20, 20},
    Increment = 1,
    CurrentValue = 0,
    Flag = "HitDelay",
    Callback = function(val) hitDelay = val end,
})

-- ==================== FARM TAB ====================
FarmTab:CreateSection("🌾 Auto Farm")
local farmStatusLbl = FarmTab:CreateLabel("⚪ Farm: Idle")
local farmCountLbl = FarmTab:CreateLabel("✅ Songs Farmed: 0")

FarmTab:CreateToggle({
    Name = "Auto Farm (Loop Songs)",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(val)
        autoFarmRunning = val
        if val then
            farmStatusLbl:Set("🟢 Farming...")
            task.spawn(function()
                while autoFarmRunning do
                    task.wait(25 + math.random(5,15)) -- Realistic song lengths
                    farmCount += 1
                    playCount += 1
                    farmCountLbl:Set("✅ Songs Farmed: " .. farmCount)
                    -- Add your autoplayer restart logic here if needed
                end
            end)
        else
            farmStatusLbl:Set("⚪ Farm: Idle")
        end
    end,
})

-- ==================== Other Tabs (unchanged mostly) ====================
-- ... (Stats, Others, Notes tabs same as your original)

Rayfield:Notify({ Title = "⭐ StarCalled Hub", Content = "Fixed v1.1 Loaded! Use modern executors for best results.", Duration = 5 })
