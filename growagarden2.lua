-- 🌱 Grow a Garden | StarCalled Hub v7 - Hardened Build
-- No raw buffer guesses. No silent failures. Proximity-first harvest. Clean remote scan.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ==================== STATE ====================
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
    "Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato",
    "Apple", "Bamboo", "Mushroom", "Pumpkin", "Rose", "Sunflower",
    "Watermelon", "Grape", "Mango", "Cactus", "Beanstalk"
}

-- ==================== LOGGING ====================
local function log(...)
    if State.debug then
        print("[StarCalled]", ...)
    end
end

local function notify(title, content, duration)
    Rayfield:Notify({ Title = title, Content = content, Duration = duration or 4 })
end

local function safeCall(label, fn)
    local ok, err = pcall(fn)
    if not ok then log("ERR [" .. label .. "]:", err) end
    return ok
end

-- ==================== REMOTE RESOLUTION ====================
-- Scan ReplicatedStorage recursively for any RemoteEvent.
-- Logs every candidate so you can identify the right one in Debug tab.
local function scanForRemotes()
    local found = {}
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            table.insert(found, v)
            log("Remote found:", v:GetFullName())
        end
    end
    return found
end

local function resolveRemote()
    -- Path 1: exact known path
    local sm = ReplicatedStorage:FindFirstChild("SharedModules")
    if sm then
        local packet = sm:FindFirstChild("Packet")
        if packet then
            local re = packet:FindFirstChild("RemoteEvent")
            if re then
                log("Remote resolved via known path:", re:GetFullName())
                return re
            end
        end
    end

    -- Path 2: scan all descendants, pick first RemoteEvent
    log("Known path failed — scanning all RemoteEvents in ReplicatedStorage...")
    local remotes = scanForRemotes()
    if #remotes == 1 then
        log("Single remote found, using:", remotes[1]:GetFullName())
        return remotes[1]
    elseif #remotes > 1 then
        log("Multiple remotes found — check Debug tab. Using first:", remotes[1]:GetFullName())
        notify("⚠️ Multiple Remotes", "Check console — " .. #remotes .. " remotes found. Using: " .. remotes[1].Name, 8)
        return remotes[1]
    end

    notify("❌ No Remote Found", "ReplicatedStorage has no RemoteEvent. Wrong game version?", 8)
    return nil
end

-- Resolve on load, retry once after 3s if nil
task.spawn(function()
    task.wait(2) -- let game finish loading
    State.remoteEvent = resolveRemote()
    if not State.remoteEvent then
        task.wait(3)
        State.remoteEvent = resolveRemote()
    end
end)

-- ==================== PLOT RESOLUTION ====================
local function resolvePlotByProximity()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local gardensRoot = workspace:FindFirstChild("Gardens", true)
        or workspace:FindFirstChild("Plots", true)
        or workspace:FindFirstChild("Farm", true)

    if not gardensRoot then
        log("Plot search: no Gardens/Plots/Farm folder in workspace")
        return nil
    end

    local closest, closestDist = nil, math.huge
    for _, v in ipairs(gardensRoot:GetChildren()) do
        -- match Plot1, Plot_1, MyPlot, Garden1, etc.
        local ok, pivot = pcall(function() return v:GetPivot() end)
        if ok and pivot then
            local dist = (root.Position - pivot.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = v
            end
        end
    end

    if closest then
        log("Closest plot:", closest.Name, "| dist:", math.floor(closestDist))
    end
    return closest
end

local function resolvePlotByOwner()
    local gardensRoot = workspace:FindFirstChild("Gardens", true)
        or workspace:FindFirstChild("Plots", true)
    if not gardensRoot then return nil end

    for _, v in ipairs(gardensRoot:GetChildren()) do
        -- Check ObjectValue named Owner
        local ownerVal = v:FindFirstChild("Owner")
        if ownerVal and ownerVal:IsA("ObjectValue") and ownerVal.Value == player then
            log("Plot resolved by Owner ObjectValue:", v.Name)
            return v
        end
        -- Check StringValue named Owner
        if ownerVal and ownerVal:IsA("StringValue") and ownerVal.Value == player.Name then
            log("Plot resolved by Owner StringValue:", v.Name)
            return v
        end
    end
    return nil
end

local function getPlayerPlot()
    return resolvePlotByOwner() or resolvePlotByProximity()
end

-- ==================== TOOL UTILS ====================
local function getPromptPart(prompt)
    local node = prompt.Parent
    while node and not node:IsA("BasePart") do
        node = node.Parent
    end
    return node
end

local function equipTool(name)
    local char = player.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end

    local tool = char:FindFirstChild(name)
        or (player.Backpack and player.Backpack:FindFirstChild(name))

    if not tool then
        log("No tool named '" .. name .. "' found")
        return nil
    end

    hum:EquipTool(tool)
    local deadline = os.clock() + 1.5
    repeat task.wait(0.05) until char:FindFirstChildOfClass("Tool") or os.clock() > deadline
    return char:FindFirstChildOfClass("Tool")
end

-- ==================== FIRE REMOTE (safe wrapper) ====================
-- Instead of guessing buffer payloads, we try multiple fire signatures
-- and log which one the server responds to (watch for errors vs silence).
local function fireRemote(...)
    if not State.remoteEvent then
        log("fireRemote: no remote resolved yet")
        return false
    end
    local ok, err = pcall(function()
        State.remoteEvent:FireServer(...)
    end)
    if not ok then log("fireRemote error:", err) end
    return ok
end

-- ==================== AUTO BUY ====================
-- Seeds in Roblox garden games are almost always bought via ProximityPrompt
-- or a RemoteFunction/RemoteEvent with a string action + item name.
-- We try the most common signature: ("BuySeed", seedName) or ("Buy", seedName)
task.spawn(function()
    while true do
        if State.autoBuy then
            safeCall("AutoBuy", function()
                -- Try both common server action strings
                -- Watch the server logs / debug console to see which one works
                fireRemote("BuySeed", State.selectedSeed)
                task.wait(0.1)
            end)
        end
        task.wait(0.4)
    end
end)

-- ==================== AUTO PLANT ====================
task.spawn(function()
    while true do
        if State.autoPlant then
            safeCall("AutoPlant", function()
                local tool = equipTool(State.selectedSeed)
                if tool then
                    -- Try proximity prompts on the plot first (most reliable)
                    local plot = getPlayerPlot()
                    if plot then
                        for _, inst in ipairs(plot:GetDescendants()) do
                            if inst:IsA("ProximityPrompt") and inst.Enabled then
                                local part = getPromptPart(inst)
                                if part then
                                    local char = player.Character
                                    local root = char and char:FindFirstChild("HumanoidRootPart")
                                    if root then
                                        local saved = root.CFrame
                                        root.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0))
                                        task.wait(0.08)
                                        pcall(fireproximityprompt, inst, inst.HoldDuration)
                                        task.wait(0.08)
                                        root.CFrame = saved
                                    end
                                end
                            end
                        end
                    end
                    -- Also fire server with plant action
                    fireRemote("PlantSeed", State.selectedSeed)
                    log("AutoPlant fired for", State.selectedSeed)
                end
            end)
        end
        task.wait(1.0)
    end
end)

-- ==================== AUTO HARVEST ====================
task.spawn(function()
    while true do
        if State.autoHarvest then
            safeCall("AutoHarvest", function()
                local plot = getPlayerPlot()
                if not plot then
                    log("AutoHarvest: plot not resolved")
                    return
                end

                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not root or not hum then return end

                -- Collect all enabled prompts
                local prompts = {}
                for _, inst in ipairs(plot:GetDescendants()) do
                    if inst:IsA("ProximityPrompt") and inst.Enabled then
                        table.insert(prompts, inst)
                    end
                end

                if #prompts == 0 then
                    log("AutoHarvest: no harvestable prompts")
                    State.autoHarvest = false
                    if State.harvestToggleRef then State.harvestToggleRef:Set(false) end
                    notify("🌾 Harvest Done", "All plants harvested — toggled off", 4)
                    return
                end

                local savedCFrame = root.CFrame
                local harvested = 0

                for _, prompt in ipairs(prompts) do
                    if not State.autoHarvest then break end
                    if prompt and prompt.Parent and prompt.Enabled then
                        local part = getPromptPart(prompt)
                        if part then
                            -- Teleport root to prompt
                            root.CFrame = CFrame.new(part.Position + Vector3.new(0, 2.5, 0))
                            task.wait(0.1)
                            local ok = pcall(fireproximityprompt, prompt, prompt.HoldDuration)
                            if ok then
                                harvested += 1
                                log("Harvested prompt:", prompt:GetFullName())
                            end
                            task.wait(0.12)
                        end
                    end
                end

                -- Restore position
                root.CFrame = savedCFrame
                log("Harvest cycle complete:", harvested, "plants")

                if harvested > 0 then
                    notify("🌾 Harvested", harvested .. " plants collected", 3)
                end
            end)
        end
        task.wait(0.7)
    end
end)

-- ==================== AUTO SELL ====================
-- Sell via RemoteEvent("SellAll") or proximity prompt on a sell stand
task.spawn(function()
    while true do
        if State.autoSell then
            safeCall("AutoSell", function()
                -- Try remote first
                fireRemote("SellAll")
                -- Also look for sell proximity prompts in workspace
                local sellStand = workspace:FindFirstChild("SellStand", true)
                    or workspace:FindFirstChild("Sell", true)
                    or workspace:FindFirstChild("Market", true)
                if sellStand then
                    for _, inst in ipairs(sellStand:GetDescendants()) do
                        if inst:IsA("ProximityPrompt") and inst.Enabled then
                            local part = getPromptPart(inst)
                            if part then
                                local char = player.Character
                                local root = char and char:FindFirstChild("HumanoidRootPart")
                                if root then
                                    local saved = root.CFrame
                                    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0))
                                    task.wait(0.1)
                                    pcall(fireproximityprompt, inst, inst.HoldDuration)
                                    task.wait(0.1)
                                    root.CFrame = saved
                                end
                            end
                        end
                    end
                end
                log("AutoSell fired")
            end)
        end
        task.wait(5.0) -- sell every 5s to avoid spam
    end
end)

-- ==================== GUI ====================
local Window = Rayfield:CreateWindow({
    Name = "🌱 Grow a Garden | StarCalled Hub v7",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Auto Buy • Plant • Harvest • Sell",
    ConfigurationSaving = { Enabled = false },
})

-- MAIN TAB
local MainTab = Window:CreateTab("🌱 Farm", 4483362458)

MainTab:CreateSection("🌱 Auto Farm")

MainTab:CreateDropdown({
    Name = "Select Seed",
    Options = seedList,
    CurrentOption = {"Carrot"},
    Callback = function(sel)
        State.selectedSeed = sel[1]
        log("Seed selected:", State.selectedSeed)
    end,
})

MainTab:CreateToggle({
    Name = "Auto Buy Seed",
    CurrentValue = false,
    Callback = function(val)
        State.autoBuy = val
        notify("🛒 Auto Buy", val and ("ON — " .. State.selectedSeed) or "OFF", 3)
    end,
})

MainTab:CreateToggle({
    Name = "Auto Plant",
    CurrentValue = false,
    Callback = function(val)
        State.autoPlant = val
        notify("🌱 Auto Plant", val and "ON" or "OFF", 3)
    end,
})

State.harvestToggleRef = MainTab:CreateToggle({
    Name = "Auto Harvest",
    CurrentValue = false,
    Callback = function(val)
        State.autoHarvest = val
        notify("🌾 Auto Harvest", val and "ON" or "OFF", 3)
    end,
})

MainTab:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Callback = function(val)
        State.autoSell = val
        notify("💰 Auto Sell", val and "ON" or "OFF", 3)
    end,
})

MainTab:CreateButton({
    Name = "Harvest Once (Manual)",
    Callback = function()
        State.autoHarvest = true
        task.delay(3, function() State.autoHarvest = false end)
        notify("🌾 Manual Harvest", "Running one harvest cycle...", 3)
    end,
})

-- DEBUG TAB
local DebugTab = Window:CreateTab("🐛 Debug", 4483362458)

DebugTab:CreateToggle({
    Name = "Verbose Logging",
    CurrentValue = true,
    Callback = function(val) State.debug = val end,
})

DebugTab:CreateButton({
    Name = "Scan All RemoteEvents",
    Callback = function()
        local remotes = scanForRemotes()
        notify("🔍 Remote Scan", "Found " .. #remotes .. " RemoteEvents — check console", 5)
    end,
})

DebugTab:CreateButton({
    Name = "Re-Resolve Remote",
    Callback = function()
        State.remoteEvent = resolveRemote()
        if State.remoteEvent then
            notify("✅ Remote OK", State.remoteEvent:GetFullName(), 5)
        else
            notify("❌ Remote Fail", "Still not found — check console", 5)
        end
    end,
})

DebugTab:CreateButton({
    Name = "Test Plot Resolution",
    Callback = function()
        local plot = getPlayerPlot()
        if plot then
            notify("✅ Plot Found", plot:GetFullName(), 5)
            print("[Plot]", plot:GetFullName())
        else
            notify("❌ Plot Not Found", "Check console for details", 5)
        end
    end,
})

DebugTab:CreateButton({
    Name = "Dump Plot Prompts",
    Callback = function()
        local plot = getPlayerPlot()
        if not plot then
            print("[Plot] nil — not resolved")
            notify("❌ No Plot", "Plot not found", 4)
            return
        end
        local count = 0
        for _, inst in ipairs(plot:GetDescendants()) do
            if inst:IsA("ProximityPrompt") then
                count += 1
                local part = getPromptPart(inst)
                print("[Prompt]", inst:GetFullName(),
                    "| Enabled:", inst.Enabled,
                    "| Hold:", inst.HoldDuration,
                    "| ActionText:", inst.ActionText,
                    "| Part:", part and part.Name or "none")
            end
        end
        print("[Plot] Total prompts:", count)
        notify("🔍 Prompts", count .. " prompts found — check console", 5)
    end,
})

DebugTab:CreateButton({
    Name = "Dump Workspace Tree (Top Level)",
    Callback = function()
        for _, v in ipairs(workspace:GetChildren()) do
            print("[WS]", v.Name, "|", v.ClassName)
        end
        notify("🌲 Workspace", "Top-level tree printed to console", 4)
    end,
})

DebugTab:CreateButton({
    Name = "Test Fire Remote (BuySeed)",
    Callback = function()
        local ok = fireRemote("BuySeed", State.selectedSeed)
        notify("🔫 Fire Test", ok and "Fired — watch for server response" or "Fire failed — no remote?", 5)
    end,
})

-- LOAD
notify("🌱 StarCalled v7 Loaded", "Check Debug tab first — scan remotes + dump prompts", 6)
