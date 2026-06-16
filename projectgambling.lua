-- StarCalled Hub | PROJECT GAMBLING
-- Databrawl Slots + Plinko

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "PROJECT GAMBLING • Slots + Plinko",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

local SlotTab   = Window:CreateTab("🎰 Slots",  4483362458)
local PlinkoTab = Window:CreateTab("🔵 Plinko", 4483362458)
local StatsTab  = Window:CreateTab("📊 Stats",  4483362458)
local NotifTab  = Window:CreateTab("📢 Notifs", 4483362458)

local slotRunning   = false
local plinkoRunning = false
local spinCount     = 0
local plinkoCount   = 0
local totalWon      = 0
local lastWinAmount = 0
local plinkoBet     = 10
local plinkoDelay   = 0.1

local notifEvent     = nil
local dropBallRemote = nil

task.spawn(function()
    local ok, ev = pcall(function()
        return ReplicatedStorage:WaitForChild("PersonalNotificationEvent", 10)
    end)
    if ok then notifEvent = ev end
end)

task.spawn(function()
    local ok, folder = pcall(function()
        return ReplicatedStorage:WaitForChild("PlinkoRemotes", 10)
    end)
    if not ok then return end
    local ok2, remote = pcall(function()
        return folder:WaitForChild("DropBall", 10)
    end)
    if ok2 then dropBallRemote = remote end
end)

local function sendNotif(text, duration)
    if notifEvent then
        firesignal(notifEvent.OnClientEvent, {
            duration = duration or 5,
            text = tostring(text)
        })
    end
end

task.spawn(function()
    local ok, ev = pcall(function()
        return ReplicatedStorage:WaitForChild("PersonalNotificationEvent", 10)
    end)
    if not ok or not ev then return end
    ev.OnClientEvent:Connect(function(data)
        if not data or not data.text then return end
        local text  = tostring(data.text)
        local lower = text:lower()
        if lower:find("won") or lower:find("jackpot") or
           lower:find("coin") or lower:find("cash")   or
           lower:find("prize") or lower:find("%$") then
            local amount = tonumber(
                text:match("%$([%d,]+)") or text:match("(%d+)")
            )
            if amount and amount > 0 then
                totalWon      += amount
                lastWinAmount  = amount
                Rayfield:Notify({
                    Title   = "💰 WIN!",
                    Content = "+" .. amount .. " | Session: $" .. totalWon,
                    Duration = 4,
                    Image   = 4483362458,
                })
            end
        end
    end)
end)

local function getMachines()
    local machines = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "SlotMachine_Databrawl" and obj:IsA("Model") then
            local activation = obj:FindFirstChild("ActivationPart")
            if activation then
                local spinProx = activation:FindFirstChild("SpinProx")
                if spinProx and spinProx:IsA("ProximityPrompt") then
                    table.insert(machines, { model = obj, prompt = spinProx, part = activation })
                end
            end
        end
    end
    return machines
end

local function isReadyToSpin(prompt)
    local text = prompt.ActionText:lower()
    return prompt.Enabled
        and text:find("spin") ~= nil
        and text:find("wait") == nil
end

local function teleportTo(part)
    local character = player.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 5, 0))
    task.wait(0.15)
    return true
end

local function instaPrompt(prompt)
    local origDist = prompt.MaxActivationDistance
    local origLOS  = prompt.RequiresLineOfSight
    local origEn   = prompt.Enabled
    prompt.MaxActivationDistance = 999999
    prompt.RequiresLineOfSight   = false
    prompt.Enabled               = true
    fireproximityprompt(prompt)
    task.delay(0.2, function()
        prompt.MaxActivationDistance = origDist
        prompt.RequiresLineOfSight   = origLOS
        prompt.Enabled               = origEn
    end)
end

-- SLOT TAB
SlotTab:CreateSection("🎮 Controls")
local slotStatusLbl  = SlotTab:CreateLabel("⚪ Status: Idle")
local slotMachineLbl = SlotTab:CreateLabel("🎰 Machines: scanning...")
local slotPromptLbl  = SlotTab:CreateLabel("🔍 Current: —")

SlotTab:CreateToggle({
    Name = "Auto Spin Slots",
    CurrentValue = false,
    Flag = "AutoSpin",
    Callback = function(val)
        slotRunning = val
        if val then
            Rayfield:Notify({ Title = "🎰 Slots", Content = "Auto spin ON!", Duration = 3, Image = 4483362458 })
        else
            slotStatusLbl:Set("⚪ Status: Idle")
            Rayfield:Notify({ Title = "🎰 Slots", Content = "Auto spin OFF.", Duration = 2, Image = 4483362458 })
        end
    end,
})

SlotTab:CreateButton({
    Name = "Spin Once (All Ready)",
    Callback = function()
        local machines = getMachines()
        local fired = 0
        for _, entry in ipairs(machines) do
            if isReadyToSpin(entry.prompt) then
                teleportTo(entry.part)
                instaPrompt(entry.prompt)
                fired     += 1
                spinCount += 1
                task.wait(0.1)
            end
        end
        Rayfield:Notify({ Title = "Spin Once", Content = "Fired " .. fired .. " machines!", Duration = 3, Image = 4483362458 })
    end,
})

SlotTab:CreateSection("📈 Live Info")
local slotSpinLbl  = SlotTab:CreateLabel("🔄 Spins: 0")
local slotReadyLbl = SlotTab:CreateLabel("✅ Ready: 0 / 0")

-- PLINKO TAB
PlinkoTab:CreateSection("🔵 Auto Drop")
local plinkoStatusLbl = PlinkoTab:CreateLabel("⚪ Plinko: Idle")
local plinkoCountLbl  = PlinkoTab:CreateLabel("🔵 Balls Dropped: 0")

PlinkoTab:CreateToggle({
    Name = "Auto Drop Balls",
    CurrentValue = false,
    Flag = "AutoPlinko",
    Callback = function(val)
        plinkoRunning = val
        if val then
            Rayfield:Notify({ Title = "🔵 Plinko", Content = "Auto drop ON! Bet: $" .. plinkoBet, Duration = 3, Image = 4483362458 })
        else
            plinkoStatusLbl:Set("⚪ Plinko: Idle")
            Rayfield:Notify({ Title = "🔵 Plinko", Content = "Auto drop OFF.", Duration = 2, Image = 4483362458 })
        end
    end,
})

PlinkoTab:CreateSlider({
    Name = "Bet Amount",
    Range = {1, 1000},
    Increment = 1,
    Suffix = "$",
    CurrentValue = 10,
    Flag = "PlinkoBet",
    Callback = function(val) plinkoBet = val end,
})

PlinkoTab:CreateSlider({
    Name = "Drop Speed",
    Range = {1, 30},
    Increment = 1,
    Suffix = "x10ms",
    CurrentValue = 10,
    Flag = "PlinkoDelay",
    Callback = function(val) plinkoDelay = val * 0.01 end,
})

PlinkoTab:CreateButton({
    Name = "Drop One Ball Now",
    Callback = function()
        if dropBallRemote then
            dropBallRemote:FireServer(plinkoBet)
            plinkoCount += 1
            plinkoCountLbl:Set("🔵 Balls Dropped: " .. plinkoCount)
            Rayfield:Notify({ Title = "Plinko", Content = "Dropped 1 ball ($" .. plinkoBet .. ")", Duration = 2, Image = 4483362458 })
        else
            Rayfield:Notify({ Title = "Error", Content = "Remote not found yet!", Duration = 3, Image = 4483362458 })
        end
    end,
})

-- STATS TAB
StatsTab:CreateSection("💰 Session Stats")
local s_spins   = StatsTab:CreateLabel("Slot Spins: 0")
local s_plinko  = StatsTab:CreateLabel("Plinko Drops: 0")
local s_won     = StatsTab:CreateLabel("Total Won: $0")
local s_lastwin = StatsTab:CreateLabel("Last Win: —")
local s_mach    = StatsTab:CreateLabel("Machines: 0")

StatsTab:CreateButton({
    Name = "🗑 Reset Stats",
    Callback = function()
        spinCount = 0 plinkoCount = 0 totalWon = 0 lastWinAmount = 0
        slotSpinLbl:Set("🔄 Spins: 0")
        plinkoCountLbl:Set("🔵 Balls Dropped: 0")
        s_spins:Set("Slot Spins: 0")
        s_plinko:Set("Plinko Drops: 0")
        s_won:Set("Total Won: $0")
        s_lastwin:Set("Last Win: —")
        Rayfield:Notify({ Title = "Reset", Content = "Stats cleared!", Duration = 3, Image = 4483362458 })
    end,
})

-- NOTIF TAB
NotifTab:CreateSection("📢 Custom Notification")
NotifTab:CreateLabel("Fires the game notification popup with your text.")

local notifText = ""
local notifDur  = 5

NotifTab:CreateInput({
    Name = "Message",
    PlaceholderText = "Type anything...",
    RemoveTextAfterFocusLost = false,
    Callback = function(val) notifText = val end,
})

NotifTab:CreateSlider({
    Name = "Duration",
    Range = {1, 15},
    Increment = 1,
    Suffix = "s",
    CurrentValue = 5,
    Flag = "NotifDur",
    Callback = function(val) notifDur = val end,
})

NotifTab:CreateButton({
    Name = "📤 Send",
    Callback = function()
        if notifText == "" then
            Rayfield:Notify({ Title = "Oops", Content = "Type something first!", Duration = 2, Image = 4483362458 })
            return
        end
        sendNotif(notifText, notifDur)
        Rayfield:Notify({ Title = "Sent!", Content = '"' .. notifText .. '"', Duration = 3, Image = 4483362458 })
    end,
})

NotifTab:CreateSection("⚡ Quick Messages")
for _, msg in ipairs({"🔥 Double Combo!", "💰 JACKPOT!", "🎰 Lucky Spin!", "⚡ On Fire!", "👑 Big Winner!"}) do
    NotifTab:CreateButton({ Name = msg, Callback = function() sendNotif(msg, 5) end })
end

-- SLOT LOOP
task.spawn(function()
    while true do
        task.wait(0.05)
        local machines   = getMachines()
        local readyCount = 0
        for _, e in ipairs(machines) do
            if isReadyToSpin(e.prompt) then readyCount += 1 end
        end
        slotMachineLbl:Set("🎰 Machines: " .. #machines)
        slotReadyLbl:Set("✅ Ready: " .. readyCount .. " / " .. #machines)
        s_mach:Set("Machines: " .. #machines)
        if not slotRunning then task.wait(0.3) continue end
        local foundAny = false
        for i, entry in ipairs(machines) do
            if not slotRunning then break end
            local prompt = entry.prompt
            if not isReadyToSpin(prompt) then
                slotPromptLbl:Set('⏳ #' .. i .. ': "' .. prompt.ActionText .. '"')
                continue
            end
            foundAny = true
            slotPromptLbl:Set('✅ #' .. i .. ': FIRING')
            slotStatusLbl:Set("🚀 Teleporting → #" .. i)
            local ok = teleportTo(entry.part)
            if not ok or not slotRunning then break end
            slotStatusLbl:Set("🎰 Spinning #" .. i)
            instaPrompt(prompt)
            task.wait(0.3)
            spinCount += 1
            slotSpinLbl:Set("🔄 Spins: " .. spinCount)
            s_spins:Set("Slot Spins: " .. spinCount)
            s_won:Set("Total Won: $" .. totalWon)
            if lastWinAmount > 0 then s_lastwin:Set("Last Win: $" .. lastWinAmount) end
            task.wait(0.05)
        end
        if not foundAny and slotRunning then
            slotStatusLbl:Set("⏳ All cooldown — rescanning...")
            task.wait(0.2)
        elseif slotRunning then
            slotStatusLbl:Set("🟢 Running — " .. spinCount .. " spins")
        end
    end
end)

-- PLINKO LOOP
task.spawn(function()
    while true do
        task.wait(0.05)
        if not plinkoRunning then task.wait(0.3) continue end
        if not dropBallRemote then
            plinkoStatusLbl:Set("❌ Remote not found!")
            task.wait(1) continue
        end
        plinkoStatusLbl:Set("🔵 Dropping... $" .. plinkoBet)
        dropBallRemote:FireServer(plinkoBet)
        plinkoCount += 1
        plinkoCountLbl:Set("🔵 Balls Dropped: " .. plinkoCount)
        s_plinko:Set("Plinko Drops: " .. plinkoCount)
        s_won:Set("Total Won: $" .. totalWon)
        task.wait(plinkoDelay)
    end
end)
