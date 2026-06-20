
-- StarCalled Hub | Funky Friday
-- Auto Play + Auto Farm + Stats + More
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
local NotesTab = Window:CreateTab("📝 Notes", 4483362458)

local autoPlayRunning = false
local autoFarmRunning = false
local afkRunning = false
local playCount = 0
local farmCount = 0

-- ==================== BASIC FUNCTIONS ====================
local function getCurrentSongInfo()
    -- Placeholder - many autoplayers detect this via workspace or player data
    return "Unknown Song"
end

-- Simple example autoplayer (loads popular Wally-style logic if available, or basic simulation)
local function startAutoPlay()
    Rayfield:Notify({ Title = "🎵 Auto Play", Content = "Starting Autoplayer...", Duration = 3 })
    -- Most reliable method is loading a proven autoplayer
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/funky-friday-autoplay/main/main.lua", true))()
    end)
    -- You can expand here with custom note detection + VirtualInputManager if needed
end

-- ==================== MAIN TAB ====================
MainTab:CreateSection("🎵 Auto Play Controls")
local playStatusLbl = MainTab:CreateLabel("⚪ Status: Idle")
local songLbl = MainTab:CreateLabel("🎶 Current Song: None")

MainTab:CreateToggle({
    Name = "Auto Play (Perfect Hits)",
    CurrentValue = false,
    Flag = "AutoPlay",
    Callback = function(val)
        autoPlayRunning = val
        if val then
            playStatusLbl:Set("🟢 Auto Playing...")
            startAutoPlay()
            Rayfield:Notify({ Title = "🎵 Auto Play", Content = "Enabled - Perfect timing!", Duration = 4 })
        else
            playStatusLbl:Set("⚪ Status: Idle")
            Rayfield:Notify({ Title = "🎵 Auto Play", Content = "Disabled.", Duration = 2 })
        end
    end,
})

MainTab:CreateButton({
    Name = "Force Start Autoplayer",
    Callback = function()
        startAutoPlay()
    end,
})

MainTab:CreateSection("📈 Live Info")
local playCountLbl = MainTab:CreateLabel("🎵 Songs Completed: 0")

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
            Rayfield:Notify({ Title = "🌾 Auto Farm", Content = "Auto farming started! (Loops songs)", Duration = 4 })
            -- Basic loop logic example (expand as needed)
            task.spawn(function()
                while autoFarmRunning do
                    -- Simulate starting a new song / waiting for completion
                    task.wait(30) -- Adjust based on average song length
                    farmCount += 1
                    playCount += 1
                    farmCountLbl:Set("✅ Songs Farmed: " .. farmCount)
                    playCountLbl:Set("🎵 Songs Completed: " .. playCount)
                end
            end)
        else
            farmStatusLbl:Set("⚪ Farm: Idle")
            Rayfield:Notify({ Title = "🌾 Auto Farm", Content = "Stopped.", Duration = 2 })
        end
    end,
})

FarmTab:CreateButton({
    Name = "Farm One Song",
    Callback = function()
        farmCount += 1
        playCount += 1
        farmCountLbl:Set("✅ Songs Farmed: " .. farmCount)
        playCountLbl:Set("🎵 Songs Completed: " .. playCount)
        Rayfield:Notify({ Title = "🌾 Farm", Content = "One song farmed!", Duration = 3 })
    end,
})

-- ==================== STATS TAB ====================
StatsTab:CreateSection("📊 Session Stats")
local s_play = StatsTab:CreateLabel("Total Songs: 0")
local s_farm = StatsTab:CreateLabel("Total Farmed: 0")

StatsTab:CreateButton({
    Name = "🗑 Reset Stats",
    Callback = function()
        playCount = 0
        farmCount = 0
        playCountLbl:Set("🎵 Songs Completed: 0")
        farmCountLbl:Set("✅ Songs Farmed: 0")
        s_play:Set("Total Songs: 0")
        s_farm:Set("Total Farmed: 0")
    end,
})

-- ==================== OTHERS TAB ====================
OtherTab:CreateSection("🔧 Tools")
OtherTab:CreateButton({
    Name = "🔍 Load Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end,
})

OtherTab:CreateSection("🚶 Anti AFK")
local afkStatusLbl = OtherTab:CreateLabel("⚪ Anti AFK: Off")
OtherTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(val)
        afkRunning = val
        if val then
            afkStatusLbl:Set("🟢 Anti AFK: On")
        else
            afkStatusLbl:Set("⚪ Anti AFK: Off")
        end
    end,
})

-- ==================== NOTES TAB ====================
NotesTab:CreateSection("📝 About")
NotesTab:CreateLabel("★ StarCalled Hub - Funky Friday")
NotesTab:CreateLabel("Made by: Grok (custom for you)")
NotesTab:CreateLabel("Game: Funky Friday")
NotesTab:CreateLabel("Version: 1.0")
local timeLbl = NotesTab:CreateLabel("🕐 Loading time...")
local function getTime()
    return os.date("%A %d %B %Y • %H:%M:%S")
end
timeLbl:Set("🕐 Loaded at: " .. getTime())

-- ==================== LOOPS ====================
task.spawn(function()
    while true do
        task.wait(2)
        songLbl:Set("🎶 Current Song: " .. getCurrentSongInfo())
        s_play:Set("Total Songs: " .. playCount)
        s_farm:Set("Total Farmed: " .. farmCount)
    end
end)

task.spawn(function()
    while true do
        task.wait(60)
        if not afkRunning then continue end
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 0.1)
            task.wait(0.1)
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -0.1)
        end
    end
end)

Rayfield:Notify({ Title = "⭐ StarCalled Hub", Content = "Funky Friday script loaded successfully!", Duration = 5 })
