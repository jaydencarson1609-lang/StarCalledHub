```lua
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

local FarmTab    = Window:CreateTab("🍋 Farm",    4483362458)
local UpgradeTab = Window:CreateTab("⬆️ Upgrade", 4483362458)
local RebirthTab = Window:CreateTab("🔄 Rebirth", 4483362458)
local OtherTab   = Window:CreateTab("🛠 Others",  4483362458)
local NotesTab   = Window:CreateTab("📝 Notes",   4483362458)

local selectedTycoon       = 1
local autoClickRunning     = false
local autoUpgradeRunning   = false
local autoRebirthRunning   = false
local afkRunning           = false
local clickDelay           = 0.5
local upgradeDelay         = 1
local rebirthDelay         = 5
local clickCount           = 0
local upgradeCount         = 0
local rebirthCount         = 0

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

-- gets ALL Purchase remotes inside Purchases folder recursively
local function getAllPurchaseRemotes()
    local tycoon = getTycoon()
    if not tycoon then return {} end
    local purchases = tycoon:FindFirstChild("Purchases")
    if not purchases then return {} end
    local found = {}
    for _, obj in ipairs(purchases:GetDescendants()) do
        if obj.Name == "Purchase" and (obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent")) then
            table.insert(found, obj)
        end
    end
    return found
end

-- FARM TAB
FarmTab:CreateSection("🎯 Tycoon Selector")
local tycoonLbl       = FarmTab:CreateLabel("🏠 Selected: Tycoon1")
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
            Rayfield:Notify({ Title = "❌ Not Found", Content = "Tycoon" .. selectedTycoon .. " not found! Try another number.", Duration = 4, Image = 4483362458 })
        end
    end,
})

FarmTab:CreateSection("🍋 Auto Click (Income)")
local clickStatusLbl = FarmTab:CreateLabel("⚪ Auto Click: Idle")
local clickCountLbl  = FarmTab:CreateLabel("🍋 Clicks: 0")

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

FarmTab:CreateSection("🍋 Click Lemons")
local clickLemonStatusLbl = FarmTab:CreateLabel("⚪ Click Lemons: Idle")

FarmTab:CreateButton({
    Name = "Click Lemons",
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
        local event = remotes:FindFirstChild("SpecialIncome")
        if not event then
            Rayfield:Notify({ Title = "❌ Error", Content = "SpecialIncome event not found!", Duration = 3, Image = 4483362458 })
            return
        end
        pcall(function()
            event:FireServer("ClickFruit", 7.6392762609385)
        end)
        clickLemonStatusLbl:Set("🟢 Clicked Lemons!")
        Rayfield:Notify({ Title = "✅ Clicked", Content = "Lemons clicked!", Duration = 2, Image = 4483362458 })
    end,
})

-- UPGRADE TAB
UpgradeTab:CreateSection("⬆️ Auto Buy All Upgrades")
local upgradeStatusLbl = UpgradeTab:CreateLabel("⚪ Auto Upgrade: Idle")
local upgradeCountLbl  = UpgradeTab:CreateLabel("⬆️ Purchases: 0")
local upgradeFoundLbl  = UpgradeTab:CreateLabel("🔍 Purchase Remotes Found: 0")

UpgradeTab:CreateToggle({
    Name = "Auto Buy All Upgrades",
    CurrentValue = false,
    Flag = "AutoUpgrade",
    Callback = function(val)
        autoUpgradeRunning = val
        if val then
            upgradeStatusLbl:Set("🟢 Buying upgrades...")
            Rayfield:Notify({ Title = "⬆️ Auto Upgrade", Content = "Started buying all upgrades!", Duration = 3, Image = 4483362458 })
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
    Name = "Buy All Upgrades Once",
    Callback = function()
        local remotes = getAllPurchaseRemotes()
        if #remotes == 0 then
            Rayfield:Notify({ Title = "❌ Error", Content = "No Purchase remotes found!", Duration = 3, Image = 4483362458 })
            return
        end
        local bought = 0
        for _, remote in ipairs(remotes) do
            pcall(function()
                if remote:IsA("RemoteFunction") then
                    remote:InvokeServer(false)
                elseif remote:IsA("RemoteEvent") then
                    remote:FireServer(false)
                end
            end)
            bought += 1
            task.wait(0.1)
        end
        upgradeCount += bought
        upgradeCountLbl:Set("⬆️ Purchases: " .. upgradeCount)
        Rayfield:Notify({ Title = "✅ Done", Content = "Bought " .. bought .. " upgrades!", Duration = 3, Image = 4483362458 })
    end,
})

UpgradeTab:CreateButton({
    Name = "🔍 Scan Purchase Remotes",
    Callback = function()
        local remotes = getAllPurchaseRemotes()
        upgradeFoundLbl:Set("🔍 Purchase Remotes Found: " .. #remotes)
        Rayfield:Notify({ Title = "🔍 Scan", Content = "Found " .. #remotes .. " purchase remotes!", Duration = 3, Image = 4483362458 })
    end,
})

-- REBIRTH TAB
RebirthTab:CreateSection("🔄 Auto Rebirth")
local rebirthStatusLbl = RebirthTab:CreateLabel("⚪ Auto Rebirth: Idle")
local rebirthCountLbl  = RebirthTab:CreateLabel("🔄 Rebirths: 0")

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
        local tycoon = getTycoon()
        if not tycoon then
            Rayfield:Notify({ Title = "❌ Error", Content = "Tycoon" .. selectedTycoon .. " not found!", Duration = 3, Image = 4483362458 })
            return
        end
        local rebirth = tycoon:FindFirstChild("Rebirth")
        if not rebirth then
            Rayfield:Notify({ Title = "❌ Error", Content = "Rebirth folder not found!", Duration = 3, Image = 4483362458 })
            return
        end
        -- try to find a Purchase or remote inside Rebirth
        for _, obj in ipairs(rebirth:GetDescendants()) do
            if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
                pcall(function()
                    if obj:IsA("RemoteFunction") then
                        obj:InvokeServer(false)
                    else
                        obj:FireServer()
                    end
                end)
                rebirthCount += 1
                rebirthCountLbl:Set("🔄 Rebirths: " .. rebirthCount)
                Rayfield:Notify({ Title = "✅ Rebirth", Content = "Rebirth fired!", Duration = 2, Image = 4483362458 })
                return
            end
        end
        -- fallback to Remotes
        local remote = getRemote("Rebirthed")
        if remote then
            pcall(function()
                if remote:IsA("RemoteFunction") then
                    remote:InvokeServer()
                else
                    remote:FireServer()
                end
            end)
            rebirthCount += 1
            rebirthCountLbl:Set("🔄 Rebirths: " .. rebirthCount)
            Rayfield:Notify({ Title = "✅ Rebirth", Content = "Rebirth fired!", Duration = 2, Image = 4483362458 })
        else
            Rayfield:Notify({ Title = "❌ Error", Content = "No rebirth remote found!", Duration = 3, Image = 4483362458 })
        end
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
NotesTab:CreateLabel("Version: 1.0.1")
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
        local remotes = getAllPurchaseRemotes()
        upgradeFoundLbl:Set("🔍 Purchase Remotes Found: " .. #remotes)
        if #remotes == 0 then
            upgradeStatusLbl:Set("❌ No purchase remotes found!")
            task.wait(2) continue
        end
        for _, remote in ipairs(remotes) do
            if not autoUpgradeRunning then break end
            pcall(function()
                if remote:IsA("RemoteFunction") then
                    remote:InvokeServer(false)
                elseif remote:IsA("RemoteEvent") then
                    remote:FireServer(false)
                end
            end)
            upgradeCount += 1
            upgradeCountLbl:Set("⬆️ Purchases: " .. upgradeCount)
            upgradeStatusLbl:Set("🟢 Buying... " .. upgradeCount .. " total")
            task.wait(upgradeDelay)
        end
    end
end)

-- AUTO REBIRTH LOOP
task.spawn(function()
    while true do
        task.wait(0.1)
        if not autoRebirthRunning then task.wait(0.3) continue end
        local tycoon = getTycoon()
        if not tycoon then
            rebirthStatusLbl:Set("❌ Tycoon not found!")
            task.wait(2) continue
        end
        local rebirth = tycoon:FindFirstChild("Rebirth")
        if rebirth then
            for _, obj in ipairs(rebirth:GetDescendants()) do
                if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
                    pcall(function()
                        if obj:IsA("RemoteFunction") then
                            obj:InvokeServer(false)
                        else
                            obj:FireServer()
                        end
                    end)
                    rebirthCount += 1
                    rebirthCountLbl:Set("🔄 Rebirths: " .. rebirthCount)
                    rebirthStatusLbl:Set("🟢 Rebirths: " .. rebirthCount)
                    break
                end
            end
        else
            local remote = getRemote("Rebirthed")
            if remote then
                pcall(function()
                    if remote:IsA("RemoteFunction") then
                        remote:InvokeServer()
                    else
                        remote:FireServer()
                    end
                end)
                rebirthCount += 1
                rebirthCountLbl:Set("🔄 Rebirths: " .. rebirthCount)
                rebirthStatusLbl:Set("🟢 Rebirths: " .. rebirthCount)
            end
        end
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
```
