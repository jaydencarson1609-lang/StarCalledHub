-- StarCalled Hub | Baby Pursuers
-- Auto Spawn Baby

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Baby Pursuers • Auto Spawner",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

local SpawnTab = Window:CreateTab("👶 Spawner", 4483362458)
local StatsTab = Window:CreateTab("📊 Stats",   4483362458)

local spawnRunning = false
local spawnCount   = 0
local spawnDelay   = 0.1

local function getSpawners()
    local found = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Spawner" and obj:IsA("Model") then
            local button = obj:FindFirstChild("Button")
            if button then
                local cd = button:FindFirstChildOfClass("ClickDetector")
                if cd then
                    table.insert(found, { model = obj, button = button, cd = cd })
                end
            end
        end
    end
    return found
end

-- SPAWN TAB
SpawnTab:CreateSection("👶 Auto Spawn Controls")
local statusLbl  = SpawnTab:CreateLabel("⚪ Status: Idle")
local spawnerLbl = SpawnTab:CreateLabel("🔍 Spawners Found: 0")

SpawnTab:CreateToggle({
    Name = "Auto Spawn Baby",
    CurrentValue = false,
    Flag = "AutoSpawnBaby",
    Callback = function(val)
        spawnRunning = val
        if val then
            statusLbl:Set("🟢 Running...")
            Rayfield:Notify({ Title = "👶 Auto Spawn", Content = "Started!", Duration = 3, Image = 4483362458 })
        else
            statusLbl:Set("⚪ Status: Idle")
            Rayfield:Notify({ Title = "👶 Auto Spawn", Content = "Stopped.", Duration = 2, Image = 4483362458 })
        end
    end,
})

SpawnTab:CreateSlider({
    Name = "Spawn Speed",
    Range = {1, 50},
    Increment = 1,
    Suffix = "x10ms",
    CurrentValue = 10,
    Flag = "SpawnDelay",
    Callback = function(val) spawnDelay = val * 0.01 end,
})

SpawnTab:CreateButton({
    Name = "Spawn Once (All Spawners)",
    Callback = function()
        local spawners = getSpawners()
        for _, entry in ipairs(spawners) do
            fireclickdetector(entry.cd)
            spawnCount += 1
            task.wait(0.05)
        end
        Rayfield:Notify({ Title = "Spawn Once", Content = "Clicked " .. #spawners .. " spawners!", Duration = 3, Image = 4483362458 })
    end,
})

SpawnTab:CreateSection("📈 Live Info")
local spawnCountLbl = SpawnTab:CreateLabel("👶 Total Spawned: 0")

-- STATS TAB
StatsTab:CreateSection("📊 Session Stats")
local s_spawns = StatsTab:CreateLabel("Total Spawns: 0")

StatsTab:CreateButton({
    Name = "🗑 Reset Stats",
    Callback = function()
        spawnCount = 0
        spawnCountLbl:Set("👶 Total Spawned: 0")
        s_spawns:Set("Total Spawns: 0")
        Rayfield:Notify({ Title = "Reset", Content = "Stats cleared!", Duration = 3, Image = 4483362458 })
    end,
})

-- SPAWN LOOP
task.spawn(function()
    while true do
        task.wait(0.05)
        local spawners = getSpawners()
        spawnerLbl:Set("🔍 Spawners Found: " .. #spawners)
        if not spawnRunning then task.wait(0.3) continue end
        for _, entry in ipairs(spawners) do
            if not spawnRunning then break end
            fireclickdetector(entry.cd)
            spawnCount += 1
            spawnCountLbl:Set("👶 Total Spawned: " .. spawnCount)
            s_spawns:Set("Total Spawns: " .. spawnCount)
            task.wait(spawnDelay)
        end
    end
end)
