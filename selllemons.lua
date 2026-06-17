-- StarCalled Hub | Sell Lemons 🍋
-- Auto Farm, Auto Upgrade, Auto Rebirth, Auto Click

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Sell Lemons 🍋 • Auto Farm",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

local FarmTab   = Window:CreateTab("🍋 Farm",    4483362458)
local UpgradeTab = Window:CreateTab("⬆️ Upgrade", 4483362458)
local RebirthTab = Window:CreateTab("🔄 Rebirth", 4483362458)
local OtherTab  = Window:CreateTab("🛠 Others",  4483362458)
local NotesTab  = Window:CreateTab("📝 Notes",   4483362458)

local selectedTycoon = 1
local autoClickRunning = false
local autoUpgradeRunning = false
local autoRebirthRunning = false
local afkRunning = false
local clickDelay = 0.5

local function getTycoon()
    return workspace:FindFirstChild("Tycoon" .. selectedTycoon)
end

local function getRemote(name)
    local tycoon = getTycoon()
    if not tycoon then return nil end
    local remotes = tycoon:FindFirstChild("Remotes")
    if not remotes then return nil end
    return remotes:FindFirstChild(name)
end

local function getUpgradeRemote()
    local tycoon = getTycoon()
    if not tycoon then return nil end
    local purchases = tycoon:FindFirstChild("Purchases")
    if not purchases then return nil end
    -- search recursively for any RemoteFunction named Upgrade
    for _, obj in ipairs(purchases:GetDescendants()) do
        if obj.Name == "Upgrade" and obj:IsA("RemoteFunction") then
            return obj
        end
    end
    return nil
end

-- FARM TAB
FarmTab:CreateSection("🎯 Tycoon Selector")
local tycoonLbl = FarmTab:CreateLabel("🏠 Selected: Tycoon1")
local tycoonStatusLbl = FarmTab:CreateLabel("⚪ Status: Not checked")

FarmTab:CreateSlider({
    Name = "Select Your Tycoon Number",
    Range = {1, 12},
    Increment = 1,
    Suffix = "",
    CurrentValue = 1,
    Flag = "TycoonNum",
    Callback = function(val)
        selectedTycoon = val
        tycoonLbl:Set("🏠 Selected: Tycoon" .. val)
        local tycoon = getTycoon()
        if tycoon then
            tycoonStatusLbl:Set("✅ Tycoon" .. val .. " found!")
        else
            tycoonStatusLbl:Set("❌ Tycoon" .. val .. " not found!")
        end
    end,
})

FarmTab:CreateButton({
    Name = "🔍 Check My Tycoon",
    Callback = function()
        local tycoon = getTycoon()
        if tycoon then
            tycoonStatusLbl:Set("✅ Tycoon" .. selectedTycoon .. " found!")
            Rayfield:Notify({ Title = "✅ Found!", Content = "Tycoon" .. selectedTycoon .. " exists!", Duration = 3, Image = 4483362458 })
        else
            tycoonStatusLbl:Set("❌ Tycoon" .. selectedTycoon .. " not found!")
            Rayfield:Notify({ Title = "❌ Not Found", Content = "Tycoon" .. selectedTycoon .. " doesn't exist! Try a different number.", Duration = 4, Image = 4483362458 })
        end
    end,
})

FarmTab:CreateSection("🍋 Auto Click (Income)")
local clickStatusLbl = FarmTab:CreateLabel("⚪ Auto Click: Idle")
local clickCountLbl  = FarmTab:CreateLabel("🍋 Clicks: 0")
local clickCount = 0

FarmTab:CreateToggle({
    Name = "Auto Click Lemon Stand",
    CurrentValue = false,
    Flag = "AutoClick",
    Callback = function(val)
        autoClickRunning = val
        if val then
            clickStatusLbl:Set("🟢 Clicking...")
            Rayfield:Notify({ Title = "🍋 Auto Click", Content = "Started!", Duration = 3, Image = 4483362458 })
        else
            clickStatusLbl:Set("⚪ Auto Click: Idle")
            Rayfield:Notify({ Title = "🍋 Auto Click", Content = "Stopped.", Duration = 2, Image = 4483362458 })
        end
    end,
})

FarmTab:CreateSlider({
    Name = "Click Speed",
    Range = {1, 20},
    Increment = 1,
    Suffix = "x0.1s",
    CurrentValue = 5,
    Flag = "ClickDelay",
    Callback = function(val) clickDelay = val * 0.1 end,
})

FarmTab:CreateButton({
    Name = "Click Once",
    Callback = function()
        local tycoon = getTycoon()
        if not tycoon then
            Rayfield:Notify({ Title = "❌ Error", Content = "Tycoon" .. selectedTycoon .. " not found!", Duration = 3, Image = 4483362458 })
            return
        end
        local remotes = tycoon:FindFirstChild("Remotes")
        if not remotes then
            Rayfield:Notify({ Title = "❌ Error", Content = "No Remotes folder found!", Duration = 3, Image = 4483362458 })
            return
        end
        local wake = remotes:FindFirstChild("WakeIncomeStream")
        if not wake then
            Rayfield:Notify({ Title = "❌ Error", Content = "WakeIncomeStream not found!", Duration = 3, Image = 4483362458 })
            return
        end
        pcall(function() wake:InvokeServer("LemonStand") end)
        clickCount += 1
        clickCountLbl:Set("🍋 Clicks: " .. clickCount)
        Rayfield:Notify({ Title = "✅ Clicked", Content = "Lemon Stand clicked!", Duration = 2, Image = 4483362458 })
    end,
})

-- UPGRADE TAB
UpgradeTab:CreateSection("⬆️ Auto Upgrade")
local upgradeStatusLbl = UpgradeTab:CreateLabel("⚪ Auto Upgrade: Idle")
local upgradeCountLbl  = UpgradeTab:CreateLabel("⬆️ Upgrades: 0")
local upgradeCount = 0
local upgradeDelay = 1

UpgradeTab:CreateToggle({
    Name = "Auto Upgrade",
    CurrentValue = false,
    Flag = "AutoUpgrade",
    Callback = function(val)
        autoUpgradeRunning = val
        if val then
            upgradeStatusLbl:Set("🟢 Upgrading...")
            Rayfield:Notify({ Title = "⬆️ Auto Upgrade", Content = "Started!", Duration = 3, Image = 4483362458 })
        else
            upgradeStatusLbl:Set("⚪ Auto Upgrade: Idle")
            Rayfield:Notify({ Title = "⬆️ Auto Upgrade", Content = "Stopped.", Duration = 2, Image = 4483362458 })
        end
    end,
})

UpgradeTab:CreateSlider({
    Name = "Upgrade Speed",
    Range = {1, 10},
    Increment = 1,
    Suffix = "x0.5s",
    CurrentValue = 2,
    Flag = "UpgradeDelay",
    Callback = function(val) upgradeDelay = val * 0.5 end,
})

UpgradeTab:CreateButton({
    Name = "Upgrade Once",
    Callback = function()
        local remote = getUpgradeRemote()
        if not remote then
            Rayfield:Notify({ Title = "❌ Error", Content = "Upgrade remote not found!", Duration = 3, Image = 4483362458 })
            return
        end
        pcall(function() remote:InvokeServer(1) end)
        upgradeCount += 1
        upgradeCountLbl:Set("⬆️ Upgrades: " .. upgradeCount)
        Rayfield:Notify({ Title = "✅ Upgraded", Content = "Upgrade fired!", Duration = 2, Image = 4483362458 })
    end,
})

-- REBIRTH TAB
RebirthTab:CreateSection("🔄 Auto Rebirth")
local rebirthStatusLbl = RebirthTab:CreateLabel("⚪ Auto Rebirth: Idle")
local rebirthCountLbl  = RebirthTab:CreateLabel("🔄 Rebirths: 0")
local rebirthCount = 0
local rebirthDelay = 5

RebirthTab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Flag = "AutoRebirth",
    Callback = function(val)
        autoRebirthRunning = val
        if val then
            rebirthStatusLbl:Set("🟢 Auto Rebirth: On")
            Rayfield:Notify({ Title = "🔄 Auto Rebirth", Content = "Started!", Duration = 3, Image = 4483362458 })
        else
            rebirthStatusLbl:Set("⚪ Auto Rebirth: Idle")
            Rayfield:Notify({ Title = "🔄 Auto Rebirth", Content = "Stopped.", Duration = 2, Image = 4483362458 })
        end
    end,
})

RebirthTab:CreateSlider({
    Name = "Rebirth Check Interval",
    Range = {1, 20},
    Increment = 1,
    Suffix = "x1s",
    CurrentValue = 5,
    Flag = "RebirthDelay",
    Callback = function(val) rebirthDelay = val end,
})

RebirthTab:CreateButton({
    Name = "Rebirth Once",
    Callback = function()
        local remote = getRemote("Rebirthed")
        if not remote then
            Rayfield:Notify({ Title = "❌ Error", Content = "Rebirth remote not found!", Duration = 3, Image = 4483362458 })
            return
        end
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer()
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer()
            end
        end)
        rebirthCount += 1
        rebirthCountLbl:Set("🔄 Rebirths: " .. rebirthCount)
        Rayfield:Notify({ Title = "✅ Rebirth", Content = "Rebirth fired!", Duration = 2, Image = 4483362458 })
    end,
})

-- OTHERS TAB
OtherTab:CreateSection("🔧 Tools")

OtherTab:CreateButton({
    Name = "🔍 Load Infinite Yield",
    Callback = function()
        Rayfield:Notify({ Title = "🔍 Infinite Yield", Content = "Loading...", Duration = 3, Image = 4483362458 })
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        Rayfield:Notify({ Title = "✅ Infinite Yield", Content = "Loaded!", Duration = 3, Image = 4483362458 })
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
            Rayfield:Notify({ Title = "🚶 Anti AFK", Content = "Enabled!", Duration = 3, Image = 4483362458 })
        else
            afkStatusLbl:Set("⚪ Anti AFK: Off")
            Rayfield:Notify({ Title = "🚶 Anti AFK", Content = "Disabled.", Duration = 2, Image = 4483362458 })
        end
    end,
})

-- NOTES TAB
NotesTab:CreateSection("📝 About")
NotesTab:CreateLabel("★ StarCalled Hub")
NotesTab:CreateLabel("Made by: Jayden")
NotesTab:CreateLabel("Game: Sell Lemons 🍋")
NotesTab:CreateLabel("Version: 1.0.0")
NotesTab:CreateSection("🕐 Session Info")
local timeLbl = NotesTab:CreateLabel("🕐 Loading time...")

local function getTime()
    local ok, result = pcall(function() return os.date("%A %d %B %Y • %H:%M:%S") end)
    return ok and result or "Time unavailable"
end

timeLbl:Set("🕐 Loaded at: " .. getTime())

NotesTab:CreateButton({
    Name = "🔄 Refresh Time",
    Callback = function()
        timeLbl:Set("🕐 Loaded at: " .. getTime())
    end,
})

-- AUTO CLICK LOOP
task.spawn(function()
    while true do
        task.wait(0.1)
        if not autoClickRunning then task.wait(0.3) continue end
        local tycoon = getTycoon()
        if not tycoon then
            clickStatusLbl:Set("❌ Tycoon" .. selectedTycoon .. " not found!")
            task.wait(1) continue
        end
        local remotes = tycoon:FindFirstChild("Remotes")
        if not remotes then task.wait(1) continue end
        local wake = remotes:FindFirstChild("WakeIncomeStream")
        if not wake then task.wait(1) continue end
        pcall(function() wake:InvokeServer("LemonStand") end)
        clickCount += 1
        clickCountLbl:Set("🍋 Clicks: " .. clickCount)
        clickStatusLbl:Set("🟢 Clicked " .. clickCount .. "x")
        task.wait(clickDelay)
    end
end)

-- AUTO UPGRADE LOOP
task.spawn(function()
    while true do
        task.wait(0.1)
        if not autoUpgradeRunning then task.wait(0.3) continue end
        local remote = getUpgradeRemote()
        if not remote then
            upgradeStatusLbl:Set("❌ Upgrade remote not found!")
            task.wait(2) continue
        end
        pcall(function() remote:InvokeServer(1) end)
        upgradeCount += 1
        upgradeCountLbl:Set("⬆️ Upgrades: " .. upgradeCount)
        upgradeStatusLbl:Set("🟢 Upgraded " .. upgradeCount .. "x")
        task.wait(upgradeDelay)
    end
end)

-- AUTO REBIRTH LOOP
task.spawn(function()
    while true do
        task.wait(0.1)
        if not autoRebirthRunning then task.wait(0.3) continue end
        local remote = getRemote("Rebirthed")
        if not remote then
            rebirthStatusLbl:Set("❌ Rebirth remote not found!")
            task.wait(2) continue
        end
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer()
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer()
            end
        end)
        rebirthCount += 1
        rebirthCountLbl:Set("🔄 Rebirths: " .. rebirthCount)
        rebirthStatusLbl:Set("🟢 Rebirths: " .. rebirthCount)
        task.wait(rebirthDelay)
    end
end)

-- ANTI AFK LOOP
task.spawn(function()
    while true do
        task.wait(60)
        if not afkRunning then continue end
        local character = player.Character
        if not character then continue end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 0.1)
        task.wait(0.1)
        hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -0.1)
    end
end)
