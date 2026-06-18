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

local FarmTab = Window:CreateTab("🍋 Farm", 4483362458)
local UpgradeTab = Window:CreateTab("⬆️ Upgrade", 4483362458)
local RebirthTab = Window:CreateTab("🔄 Rebirth", 4483362458)
local OtherTab = Window:CreateTab("🛠 Others", 4483362458)
local NotesTab = Window:CreateTab("📝 Notes", 4483362458)

local selectedTycoon = 1
local autoDetectTycoon = true
local autoClickRunning = false
local autoUpgradeRunning = false
local autoRebirthRunning = false
local afkRunning = false

local clickDelay = 0.5
local upgradeDelay = 1
local rebirthDelay = 5

local clickCount = 0
local upgradeCount = 0
local rebirthCount = 0

local function getOwnerTycoon()
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Name:match("^Tycoon%d+$") and v:FindFirstChild("Owner") and v.Owner.Value == player then
            return v
        end
    end
    return nil
end

local function getTycoon()
    if autoDetectTycoon then
        local ownerTycoon = getOwnerTycoon()
        if ownerTycoon then
            selectedTycoon = tonumber(ownerTycoon.Name:match("^Tycoon(%d+)$")) or selectedTycoon
            return ownerTycoon
        end
    end

    return workspace:FindFirstChild("Tycoon" .. selectedTycoon)
end

local function getTycoonName(tycoon)
    return tycoon and tycoon.Name or ("Tycoon" .. selectedTycoon)
end

local function findFruitClickDetectors(tycoon)
    local detectors = {}
    for _, desc in ipairs(tycoon:GetDescendants()) do
        if desc:IsA("ClickDetector") then
            local parent = desc.Parent
            if parent then
                local name = string.lower(parent.Name)
                local valid = name:find("fruit") or name:find("lemon") or name:find("click") or name:find("tree")
                if not valid then
                    local ancestor = parent.Parent
                    while ancestor and ancestor ~= tycoon do
                        local aname = string.lower(ancestor.Name)
                        if aname:find("fruit") or aname:find("lemon") or aname:find("tree") or aname:find("click") then
                            valid = true
                            break
                        end
                        ancestor = ancestor.Parent
                    end
                end
                if valid then
                    table.insert(detectors, desc)
                end
            end
        end
    end
    return detectors
end

local function getDetectorTargetPart(detector)
    local parent = detector.Parent
    if parent then
        if parent:IsA("BasePart") then
            return parent
        end
        if parent:IsA("Model") then
            if parent.PrimaryPart then
                return parent.PrimaryPart
            end
            for _, descendant in ipairs(parent:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    return descendant
                end
            end
        end
        for _, descendant in ipairs(parent:GetDescendants()) do
            if descendant:IsA("BasePart") then
                return descendant
            end
        end
    end
    return nil
end

local function clickAllLemonsOnTrees()
    local tycoon = getTycoon()
    if not tycoon then
        Rayfield:Notify({Title = "❌ Error", Content = "Tycoon not found!", Duration = 3, Image = 4483362458})
        return 0
    end

    local clicked = 0
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local origCFrame = hrp and hrp.CFrame
    local detectors = findFruitClickDetectors(tycoon)

    for _, detector in ipairs(detectors) do
        local targetPart = getDetectorTargetPart(detector)
        if targetPart then
            if hrp then
                hrp.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 2, 0))
                task.wait(0.05)
            end

            local ok = pcall(function()
                fireclickdetector(detector)
            end)
            if ok then
                clicked += 1
            end
            task.wait(0.06)
        end
    end

    if hrp and origCFrame then
        hrp.CFrame = origCFrame
    end

    return clicked
end

-- ==================== FARM TAB ====================
FarmTab:CreateSection("🎯 Tycoon Selector")
local tycoonLbl = FarmTab:CreateLabel("🏠 Selected: Tycoon1")
local tycoonStatusLbl = FarmTab:CreateLabel("⚪ Status: Not checked")
local autoDetectLbl = FarmTab:CreateLabel("🔎 Auto Detect: Enabled")

FarmTab:CreateToggle({
    Name = "Auto Detect My Tycoon",
    CurrentValue = autoDetectTycoon,
    Flag = "AutoDetectTycoon",
    Callback = function(val)
        autoDetectTycoon = val
        autoDetectLbl:Set(val and "🔎 Auto Detect: Enabled" or "🔎 Auto Detect: Disabled")
        if val then
            local tycoon = getTycoon()
            tycoonLbl:Set("🏠 Selected: " .. getTycoonName(tycoon))
            tycoonStatusLbl:Set(tycoon and "✅ Owner tycoon found!" or "❌ Owner tycoon not found!")
        end
    end,
})

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
            tycoonStatusLbl:Set("✅ " .. getTycoonName(tycoon) .. " found!")
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
            tycoonLbl:Set("🏠 Selected: " .. getTycoonName(tycoon))
            tycoonStatusLbl:Set("✅ " .. getTycoonName(tycoon) .. " found!")
            Rayfield:Notify({ Title = "✅ Found!", Content = getTycoonName(tycoon) .. " exists!", Duration = 3, Image = 4483362458 })
        else
            tycoonStatusLbl:Set("❌ Tycoon" .. selectedTycoon .. " not found!")
            Rayfield:Notify({ Title = "❌ Not Found", Content = "Try another number.", Duration = 4, Image = 4483362458 })
        end
    end,
})

FarmTab:CreateSection("🍋 Auto Click (Income)")
local clickStatusLbl = FarmTab:CreateLabel("⚪ Auto Click: Idle")
local clickCountLbl = FarmTab:CreateLabel("🍋 Clicks: 0")

FarmTab:CreateToggle({
    Name = "Auto Click Lemon Stand",
    CurrentValue = false,
    Flag = "AutoClick",
    Callback = function(val)
        autoClickRunning = val
        clickStatusLbl:Set(val and "🟢 Clicking..." or "⚪ Auto Click: Idle")
        Rayfield:Notify({ Title = "🍋 Auto Click", Content = val and "Started!" or "Stopped.", Duration = 2, Image = 4483362458 })
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

FarmTab:CreateSection("🍋 Click Lemons")
local lemonClickStatusLbl = FarmTab:CreateLabel("⚪ Status: Idle")

FarmTab:CreateButton({
    Name = "🌳 Click All Lemons on Trees",
    Callback = function()
        lemonClickStatusLbl:Set("🟡 Clicking lemons...")
        local count = clickAllLemonsOnTrees()
        if count > 0 then
            lemonClickStatusLbl:Set("✅ Clicked " .. count .. " lemons!")
            Rayfield:Notify({
                Title = "✅ Success!",
                Content = "Clicked " .. count .. " lemons!",
                Duration = 5,
                Image = 4483362458
            })
        else
            lemonClickStatusLbl:Set("❌ No lemons found")
            Rayfield:Notify({
                Title = "❌ No Lemons Detected",
                Content = "No Fruit objects found.\nMake sure lemons are visible on trees.",
                Duration = 6,
                Image = 4483362458
            })
        end
    end,
})

-- ==================== UPGRADE, REBIRTH, OTHERS ====================
-- NOTE: getRemote() and getAllPurchaseRemotes() are not defined anywhere.
-- These tabs are left as-is per your request to fix ONLY the lemon-click bug.
-- They will still error if used until those functions are implemented.

UpgradeTab:CreateSection("⬆️ Auto Buy All Upgrades")
local upgradeStatusLbl = UpgradeTab:CreateLabel("⚪ Auto Upgrade: Idle")
local upgradeCountLbl = UpgradeTab:CreateLabel("⬆️ Purchases: 0")
local upgradeFoundLbl = UpgradeTab:CreateLabel("🔍 Purchase Remotes Found: 0")

UpgradeTab:CreateToggle({
    Name = "Auto Buy All Upgrades",
    CurrentValue = false,
    Flag = "AutoUpgrade",
    Callback = function(val)
        autoUpgradeRunning = val
        upgradeStatusLbl:Set(val and "🟢 Buying upgrades..." or "⚪ Auto Upgrade: Idle")
        Rayfield:Notify({ Title = "⬆️ Auto Upgrade", Content = val and "Started!" or "Stopped.", Duration = 3, Image = 4483362458 })
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

RebirthTab:CreateSection("🔄 Auto Rebirth")
local rebirthStatusLbl = RebirthTab:CreateLabel("⚪ Auto Rebirth: Idle")
local rebirthCountLbl = RebirthTab:CreateLabel("🔄 Rebirths: 0")

RebirthTab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Flag = "AutoRebirth",
    Callback = function(val)
        autoRebirthRunning = val
        rebirthStatusLbl:Set(val and "🟢 Auto Rebirth: On" or "⚪ Auto Rebirth: Idle")
        Rayfield:Notify({ Title = "🔄 Auto Rebirth", Content = val and "Started!" or "Stopped.", Duration = 3, Image = 4483362458 })
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
        afkStatusLbl:Set(val and "🟢 Anti AFK: On" or "⚪ Anti AFK: Off")
        Rayfield:Notify({ Title = "🚶 Anti AFK", Content = val and "Enabled!" or "Disabled.", Duration = 3, Image = 4483362458 })
    end,
})

-- NOTES TAB
NotesTab:CreateSection("📝 About")
NotesTab:CreateLabel("★ StarCalled Hub")
NotesTab:CreateLabel("Made by: Jayden")
NotesTab:CreateLabel("Game: Sell Lemons 🍋")
NotesTab:CreateLabel("Version: 1.0.7 - Lemon Click Fixed")
NotesTab:CreateSection("🕐 Session Info")
local timeLbl = NotesTab:CreateLabel("🕐 Loading time...")
local function getTime()
    local ok, result = pcall(function() return os.date("%A %d %B %Y • %H:%M:%S") end)
    return ok and result or "Time unavailable"
end
timeLbl:Set("🕐 Loaded at: " .. getTime())

NotesTab:CreateButton({
    Name = "🔄 Refresh Time",
    Callback = function() timeLbl:Set("🕐 Loaded at: " .. getTime()) end,
})

-- Auto Click Loop
task.spawn(function()
    while true do
        if not autoClickRunning then
            task.wait(0.3)
            continue
        end
        -- NOTE: getRemote() not defined — Auto Click Lemon Stand toggle will not function until implemented
        task.wait(clickDelay)
    end
end)

-- Auto Upgrade Loop
task.spawn(function()
    while true do
        if not autoUpgradeRunning then
            task.wait(0.3)
            continue
        end
        -- NOTE: getAllPurchaseRemotes() not defined — Auto Upgrade will not function until implemented
        task.wait(upgradeDelay)
    end
end)

-- Auto Rebirth Loop
task.spawn(function()
    while true do
        if not autoRebirthRunning then
            task.wait(rebirthDelay)
            continue
        end
        local tycoon = getTycoon()
        if tycoon then
            local success = false
            local rebirthFolder = tycoon:FindFirstChild("Rebirth")
            if rebirthFolder then
                for _, obj in ipairs(rebirthFolder:GetDescendants()) do
                    if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
                        pcall(function()
                            if obj:IsA("RemoteFunction") then obj:InvokeServer(false) else obj:FireServer() end
                        end)
                        success = true
                        break
                    end
                end
            end
            if success then
                rebirthCount += 1
                rebirthCountLbl:Set("🔄 Rebirths: " .. rebirthCount)
                rebirthStatusLbl:Set("🟢 Rebirths: " .. rebirthCount)
            end
        end
        task.wait(rebirthDelay)
    end
end)

-- Anti AFK Loop
task.spawn(function()
    while true do
        task.wait(60)
        if not afkRunning then continue end
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 0.1)
            task.wait(0.1)
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -0.1)
        end
    end
end)
