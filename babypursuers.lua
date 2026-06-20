-- StarCalled Hub | Baby Pursuers
-- Auto Spawn + Auto Pick Up & Drop + Saved Pos + Shake Baby to Death

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Baby Pursuers • Auto Farm",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

local SpawnTab = Window:CreateTab("👶 Spawner", 4483362458)
local FarmTab = Window:CreateTab("🔄 Farm", 4483362458)
local StatsTab = Window:CreateTab("📊 Stats", 4483362458)
local OtherTab = Window:CreateTab("🛠 Others", 4483362458)
local NotesTab = Window:CreateTab("📝 Notes", 4483362458)

local spawnRunning = false
local farmRunning = false
local afkRunning = false

local spawnCount = 0
local farmCount = 0
local spawnDelay = 0.1
local savedPosition = nil

local GrabEvent = ReplicatedStorage:WaitForChild("GrabEvent")

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

local function getBabies() -- Free babies only (for auto farm)
    local found = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name:find("Baby") and obj:IsA("Model") then
            local hitbox = obj:FindFirstChild("Hitbox")
            if hitbox then
                local isHeld = hitbox:FindFirstChildOfClass("WeldConstraint")
                    or hitbox:FindFirstChildOfClass("RigidConstraint")
                    or obj:FindFirstChildOfClass("WeldConstraint")
                    or obj:FindFirstChildOfClass("RigidConstraint")
                if not isHeld then
                    table.insert(found, { model = obj, hitbox = hitbox })
                end
            end
        end
    end
    return found
end

local function getAnyBaby() -- NEW: Finds any baby (held or not)
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name:find("Baby") and obj:IsA("Model") then
            local hitbox = obj:FindFirstChild("Hitbox")
            if hitbox then
                return hitbox
            end
        end
    end
    return nil
end

local function getVent()
    return workspace:FindFirstChild("Vent")
end

local function teleportTo(part)
    local character = player.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 5, 0))
    task.wait(0.2)
    return true
end

-- ==================== SPAWN TAB ====================
SpawnTab:CreateSection("👶 Auto Spawn Controls")
local spawnStatusLbl = SpawnTab:CreateLabel("⚪ Status: Idle")
local spawnerLbl = SpawnTab:CreateLabel("🔍 Spawners Found: 0")

SpawnTab:CreateToggle({
    Name = "Auto Spawn Baby",
    CurrentValue = false,
    Flag = "AutoSpawnBaby",
    Callback = function(val)
        spawnRunning = val
        if val then
            spawnStatusLbl:Set("🟢 Running...")
            Rayfield:Notify({ Title = "👶 Auto Spawn", Content = "Started!", Duration = 3 })
        else
            spawnStatusLbl:Set("⚪ Status: Idle")
            Rayfield:Notify({ Title = "👶 Auto Spawn", Content = "Stopped.", Duration = 2 })
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
        Rayfield:Notify({ Title = "Spawn Once", Content = "Clicked " .. #spawners .. " spawners!", Duration = 3 })
    end,
})

SpawnTab:CreateSection("📈 Live Info")
local spawnCountLbl = SpawnTab:CreateLabel("👶 Total Spawned: 0")

-- ==================== FARM TAB ====================
FarmTab:CreateSection("🔄 Auto Pick Up & Drop")
local farmStatusLbl = FarmTab:CreateLabel("⚪ Farm: Idle")
local babyCountLbl = FarmTab:CreateLabel("👶 Babies Found: 0")
local farmCountLbl = FarmTab:CreateLabel("✅ Dropped: 0")

FarmTab:CreateToggle({
    Name = "Auto Farm (Grab → Vent → Drop)",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(val)
        farmRunning = val
        if val then
            local vent = getVent()
            if not vent then
                Rayfield:Notify({ Title = "❌ Error", Content = "Vent part not found!", Duration = 4 })
                farmRunning = false
                return
            end
            farmStatusLbl:Set("🟢 Farming...")
            Rayfield:Notify({ Title = "🔄 Farm", Content = "Auto farm started!", Duration = 3 })
        else
            farmStatusLbl:Set("⚪ Farm: Idle")
            Rayfield:Notify({ Title = "🔄 Farm", Content = "Stopped.", Duration = 2 })
        end
    end,
})

FarmTab:CreateButton({
    Name = "Grab & Drop Once (Vent)",
    Callback = function()
        local babies = getBabies()
        if #babies == 0 then
            Rayfield:Notify({ Title = "❌ No Babies", Content = "No free babies found!", Duration = 3 })
            return
        end
        local vent = getVent()
        if not vent then return end
        local baby = babies[1]
        teleportTo(baby.hitbox)
        GrabEvent:FireServer("Grab", baby.hitbox)
        task.wait(0.5)
        teleportTo(vent)
        task.wait(0.3)
        GrabEvent:FireServer("Drop")
        farmCount += 1
        farmCountLbl:Set("✅ Dropped: " .. farmCount)
    end,
})

FarmTab:CreateSection("📍 Drop at Saved Position")
local savedPosLbl = FarmTab:CreateLabel("📍 No position saved yet")

FarmTab:CreateButton({
    Name = "📍 Save Current Position",
    Callback = function()
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        savedPosition = hrp.CFrame
        local pos = hrp.Position
        savedPosLbl:Set(string.format("📍 Saved: %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
    end,
})

FarmTab:CreateButton({
    Name = "👶 Grab Baby → Drop at Saved Pos",
    Callback = function()
        if not savedPosition then return end
        local babies = getBabies()
        if #babies == 0 then return end
        local baby = babies[1]
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        teleportTo(baby.hitbox)
        GrabEvent:FireServer("Grab", baby.hitbox)
        task.wait(0.5)
        hrp.CFrame = savedPosition
        task.wait(0.3)
        GrabEvent:FireServer("Drop")
        farmCount += 1
        farmCountLbl:Set("✅ Dropped: " .. farmCount)
    end,
})

-- ==================== SHAKE BABY TO DEATH ====================
FarmTab:CreateSection("☠️ Shake to Death")
FarmTab:CreateButton({
    Name = "Shake the Baby to Death",
    Callback = function()
        local babyHitbox = getAnyBaby()
        if not babyHitbox then
            Rayfield:Notify({ Title = "❌ No Baby Found", Content = "No babies in the workspace!", Duration = 4 })
            return
        end

        Rayfield:Notify({ Title = "☠️ Shaking Baby", Content = "Spamming Grab/Drop for 10 seconds...", Duration = 5 })

        local startTime = tick()
        while (tick() - startTime) < 10 do
            GrabEvent:FireServer("Drop")
            task.wait(0.012)
            GrabEvent:FireServer("Grab", babyHitbox)
            task.wait(0.012)
        end

        Rayfield:Notify({ Title = "✅ Finished", Content = "10 seconds of shaking completed!", Duration = 3 })
    end,
})

-- ==================== STATS TAB ====================
StatsTab:CreateSection("📊 Session Stats")
local s_spawns = StatsTab:CreateLabel("Total Spawns: 0")
local s_farm = StatsTab:CreateLabel("Total Dropped: 0")
local s_babies = StatsTab:CreateLabel("Babies in World: 0")

StatsTab:CreateButton({
    Name = "🗑 Reset Stats",
    Callback = function()
        spawnCount = 0
        farmCount = 0
        spawnCountLbl:Set("👶 Total Spawned: 0")
        farmCountLbl:Set("✅ Dropped: 0")
        s_spawns:Set("Total Spawns: 0")
        s_farm:Set("Total Dropped: 0")
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
NotesTab:CreateLabel("★ StarCalled Hub")
NotesTab:CreateLabel("Made by: Jayden")
NotesTab:CreateLabel("Game: Baby Pursuers")
NotesTab:CreateLabel("Version: 1.3.2")

local timeLbl = NotesTab:CreateLabel("🕐 Loading time...")
local function getTime()
    return os.date("%A %d %B %Y • %H:%M:%S")
end
timeLbl:Set("🕐 Loaded at: " .. getTime())

-- ==================== LOOPS ====================

task.spawn(function()
    while true do
        task.wait(0.05)
        local spawners = getSpawners()
        spawnerLbl:Set("🔍 Spawners Found: " .. #spawners)
        if spawnRunning then
            for _, entry in ipairs(spawners) do
                if not spawnRunning then break end
                fireclickdetector(entry.cd)
                spawnCount += 1
                spawnCountLbl:Set("👶 Total Spawned: " .. spawnCount)
                s_spawns:Set("Total Spawns: " .. spawnCount)
                task.wait(spawnDelay)
            end
        else
            task.wait(0.3)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        local babies = getBabies()
        babyCountLbl:Set("👶 Babies Found: " .. #babies)
        s_babies:Set("Babies in World: " .. #babies)
        
        if not farmRunning then task.wait(0.3) continue end
        
        local vent = getVent()
        if not vent then task.wait(1) continue end
        if #babies == 0 then
            local spawners = getSpawners()
            for _, entry in ipairs(spawners) do
                if not farmRunning then break end
                fireclickdetector(entry.cd)
                spawnCount += 1
                spawnCountLbl:Set("👶 Total Spawned: " .. spawnCount)
                s_spawns:Set("Total Spawns: " .. spawnCount)
                task.wait(0.05)
            end
            task.wait(0.3) continue
        end
        
        for _, baby in ipairs(babies) do
            if not farmRunning then break end
            if not baby.hitbox or not baby.hitbox.Parent then continue end
            farmStatusLbl:Set("🚀 Grabbing " .. baby.model.Name)
            teleportTo(baby.hitbox)
            GrabEvent:FireServer("Grab", baby.hitbox)
            task.wait(0.5)
            farmStatusLbl:Set("📦 Dropping at Vent...")
            teleportTo(vent)
            task.wait(0.3)
            GrabEvent:FireServer("Drop")
            farmCount += 1
            farmCountLbl:Set("✅ Dropped: " .. farmCount)
            s_farm:Set("Total Dropped: " .. farmCount)
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(60)
        if not afkRunning then continue end
        local character = player.Character
        if not character then continue end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 0.1)
            task.wait(0.1)
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -0.1)
        end
    end
end)
