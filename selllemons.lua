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

local function getTycoon()
    local tycoon = workspace:FindFirstChild("Tycoon" .. selectedTycoon)
    if tycoon then return tycoon end
    
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Name:match("^Tycoon%d+$") and v:FindFirstChild("Owner") and v.Owner.Value == player then
            return v
        end
    end
    return nil
end

-- FIXED & SAFER Lemon Clicker
local function clickAllLemonsOnTrees()
    local tycoon = getTycoon()
    if not tycoon then 
        Rayfield:Notify({Title = "❌ Error", Content = "Tycoon not found!", Duration = 3})
        return 0 
    end

    local clicked = 0

    -- Find remote safely
    local clickRemote = nil
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local core = rs:FindFirstChild("Core") or rs:FindFirstChild("Core", true)
        if core then
            local signal = core:FindFirstChild("RemoteSignal") or core:FindFirstChild("RemoteSignal", true)
            if signal then
                clickRemote = signal:FindFirstChild("ClickFruitService.Clicked")
            end
        end
    end)

    -- Scan for fruits
    for _, fruit in ipairs(tycoon:GetDescendants()) do
        if fruit.Name == "Fruit" then
            -- ClickDetector method
            pcall(function()
                local clickPart = fruit:FindFirstChild("ClickPart", true)
                if clickPart then
                    local detector = clickPart:FindFirstChildOfClass("ClickDetector")
                    if detector then
                        fireclickdetector(detector, 0)
                        clicked += 1
                    end
                end
            end)

            -- Remote method
            if clickRemote then
                pcall(function()
                    local pos = fruit:GetPivot().Position
                    firesignal(clickRemote.OnClientEvent, 9.8242151758424, pos, false)
                    clicked += 1
                end)
            end
        end
    end

    return clicked
end

-- ==================== FARM TAB ====================
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
        tycoonStatusLbl:Set(tycoon and ("✅ Tycoon" .. val .. " found!") or ("❌ Tycoon" .. val .. " not found!"))
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

FarmTab:CreateButton({
    Name = "Click Once",
    Callback = function()
        local wake = getRemote("WakeIncomeStream")
        if wake then
            pcall(function() wake:InvokeServer("LemonStand") end)
            clickCount += 1
            clickCountLbl:Set("🍋 Clicks: " .. clickCount)
            Rayfield:Notify({ Title = "✅ Clicked", Content = "Lemon Stand clicked!", Duration = 2, Image = 4483362458 })
        else
            Rayfield:Notify({ Title = "❌ Error", Content = "WakeIncomeStream not found!", Duration = 3, Image = 4483362458 })
        end
    end,
})

FarmTab:CreateSection("🍋 Click Lemons")
FarmTab:CreateButton({
    Name = "Click Lemons (Special)",
    Callback = function()
        local event = getRemote("SpecialIncome")
        if event then
            pcall(function() event:FireServer("ClickFruit", 7.6392762609385) end)
            Rayfield:Notify({ Title = "✅ Clicked", Content = "Special lemons clicked!", Duration = 2, Image = 4483362458 })
        else
            Rayfield:Notify({ Title = "❌ Error", Content = "SpecialIncome not found!", Duration = 3, Image = 4483362458 })
        end
    end,
})

-- ==================== UPGRADE, REBIRTH, OTHERS ====================
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

UpgradeTab:CreateButton({
    Name = "Buy All Upgrades Once",
    Callback = function()
        local remotes = getAllPurchaseRemotes()
        if #remotes == 0 then
            return Rayfield:Notify({ Title = "❌ Error", Content = "No Purchase remotes found!", Duration = 3, Image = 4483362458 })
        end
        local bought = 0
        for _, remote in ipairs(remotes) do
            pcall(function()
                if remote:IsA("RemoteFunction") then remote:InvokeServer(false)
                elseif remote:IsA("RemoteEvent") then remote:FireServer(false) end
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

RebirthTab:CreateButton({
    Name = "Rebirth Once",
    Callback = function()
        local tycoon = getTycoon()
        if not tycoon then return Rayfield:Notify({ Title = "❌ Error", Content = "Tycoon not found!", Duration = 3, Image = 4483362458 }) end
        -- (Rebirth code same as before)
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
        if not success then
            local remote = getRemote("Rebirthed")
            if remote then
                pcall(function()
                    if remote:IsA("RemoteFunction") then remote:InvokeServer() else remote:FireServer() end
                end)
                success = true
            end
        end
        if success then
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

OtherTab:CreateSection("🌳 Lemon Trees")
OtherTab:CreateButton({
    Name = "🌳 Click All Lemons on Trees",
    Callback = function()
        local count = clickAllLemonsOnTrees()
        if count > 0 then
            Rayfield:Notify({ 
                Title = "✅ Success!", 
                Content = "Clicked " .. count .. " lemons!", 
                Duration = 5, 
                Image = 4483362458 
            })
        else
            Rayfield:Notify({ 
                Title = "❌ No Lemons Detected", 
                Content = "No Fruit objects found.\nMake sure lemons are visible on trees.", 
                Duration = 6, 
                Image = 4483362458 
            })
        end
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

-- Notes & Loops (shortened for space - same as previous versions)
NotesTab:CreateSection("📝 About")
NotesTab:CreateLabel("★ StarCalled Hub")
NotesTab:CreateLabel("Made by: Jayden")
NotesTab:CreateLabel("Game: Sell Lemons 🍋")
NotesTab:CreateLabel("Version: 1.0.6 - Callback Fixed")
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

-- Auto Loops (same)
task.spawn(function()
    while true do
        task.wait(0.1)
        if not autoClickRunning then continue end
        local wake = getRemote("WakeIncomeStream")
        if wake then
            pcall(function() wake:InvokeServer("LemonStand") end)
            clickCount += 1
            clickCountLbl:Set("🍋 Clicks: " .. clickCount)
            clickStatusLbl:Set("🟢 Clicked " .. clickCount .. "x")
        end
        task.wait(clickDelay)
    end
end)

-- (Auto Upgrade, Auto Rebirth, Anti AFK loops remain the same as last version)
-- ... [They are unchanged, just paste from previous if needed]

task.spawn(function()
    while true do
        task.wait(0.2)
        if not autoUpgradeRunning then continue end
        local remotes = getAllPurchaseRemotes()
        upgradeFoundLbl:Set("🔍 Purchase Remotes Found: " .. #remotes)
        if #remotes == 0 then
            upgradeStatusLbl:Set("❌ No purchase remotes!")
            task.wait(2) continue
        end
        for _, remote in ipairs(remotes) do
            if not autoUpgradeRunning then break end
            pcall(function()
                if remote:IsA("RemoteFunction") then remote:InvokeServer(false)
                elseif remote:IsA("RemoteEvent") then remote:FireServer(false) end
            end)
            upgradeCount += 1
            upgradeCountLbl:Set("⬆️ Purchases: " .. upgradeCount)
            upgradeStatusLbl:Set("🟢 Buying... (" .. upgradeCount .. ")")
            task.wait(upgradeDelay)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(rebirthDelay)
        if not autoRebirthRunning then continue end
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
            if not success then
                local remote = getRemote("Rebirthed")
                if remote then
                    pcall(function()
                        if remote:IsA("RemoteFunction") then remote:InvokeServer() else remote:FireServer() end
                    end)
                    success = true
                end
            end
            if success then
                rebirthCount += 1
                rebirthCountLbl:Set("🔄 Rebirths: " .. rebirthCount)
                rebirthStatusLbl:Set("🟢 Rebirths: " .. rebirthCount)
            end
        end
    end
end)

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
