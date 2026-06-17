-- 🌱 Grow a Garden 2 | StarCalled Hub v7
-- Push this file to: StarCalledHub/growagarden2.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ==================== STATE ====================
local State = {
    autoBuy     = false,
    autoPlant   = false,
    autoHarvest = false,
    autoSell    = false,
    debug       = true,
    selectedSeed = "Carrot",
    remoteEvent  = nil,
    harvestToggleRef = nil,
}

local seedList = {
    "Carrot","Strawberry","Blueberry","Tulip","Tomato",
    "Apple","Bamboo","Mushroom","Pumpkin","Rose","Sunflower",
    "Watermelon","Grape","Mango","Cactus","Beanstalk"
}

-- ==================== UTILS ====================
local function log(...)
    if State.debug then print("[StarCalled GAG2]", ...) end
end

local function notify(title, content, duration)
    Rayfield:Notify({ Title = title, Content = content, Duration = duration or 4 })
end

local function safeCall(label, fn)
    local ok, err = pcall(fn)
    if not ok then log("ERR ["..label.."]:", err) end
    return ok
end

-- ==================== REMOTE RESOLUTION ====================
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
    -- Path 2: scan all
    log("Known path failed — scanning...")
    local remotes = scanForRemotes()
    if #remotes >= 1 then
        if #remotes > 1 then
            notify("⚠️ Multiple Remotes", #remotes.." found — using first. Check console.", 8)
        end
        log("Using remote:", remotes[1]:GetFullName())
        return remotes[1]
    end
    notify("❌ No Remote", "No RemoteEvent found in ReplicatedStorage", 8)
    return nil
end

task.spawn(function()
    task.wait(2)
    State.remoteEvent = resolveRemote()
    if not State.remoteEvent then
        task.wait(3)
        State.remoteEvent = resolveRemote()
    end
end)

-- ==================== PLOT RESOLUTION ====================
local function resolvePlotByOwner()
    local root = workspace:FindFirstChild("Gardens", true)
        or workspace:FindFirstChild("Plots", true)
    if not root then return nil end
    for _, v in ipairs(root:GetChildren()) do
        local ov = v:FindFirstChild("Owner")
        if ov then
            if (ov:IsA("ObjectValue") and ov.Value == player)
            or (ov:IsA("StringValue") and ov.Value == player.Name) then
                log("Plot by owner:", v.Name)
                return v
            end
        end
    end
    return nil
end

local function resolvePlotByProximity()
    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local gardensRoot = workspace:FindFirstChild("Gardens", true)
        or workspace:FindFirstChild("Plots", true)
        or workspace:FindFirstChild("Farm", true)
    if not gardensRoot then
        log("No Gardens/Plots/Farm folder found")
        return nil
    end
    local best, bestDist = nil, math.huge
    for _, v in ipairs(gardensRoot:GetChildren()) do
        local ok, pivot = pcall(function() return v:GetPivot() end)
        if ok and pivot then
            local d = (hrp.Position - pivot.Position).Magnitude
            if d < bestDist then bestDist = d; best = v end
        end
    end
    if best then log("Closest plot:", best.Name, "dist:", math.floor(bestDist)) end
    return best
end

local function getPlayerPlot()
    return resolvePlotByOwner() or resolvePlotByProximity()
end

-- ==================== TOOL / PROMPT UTILS ====================
local function getPromptPart(prompt)
    local node = prompt.Parent
    while node and not node:IsA("BasePart") do node = node.Parent end
    return node
end

local function equipTool(name)
    local char = player.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local tool = char:FindFirstChild(name)
        or (player.Backpack and player.Backpack:FindFirstChild(name))
    if not tool then log("No tool:", name); return nil end
    hum:EquipTool(tool)
    local deadline = os.clock() + 1.5
    repeat task.wait(0.05) until char:FindFirstChildOfClass("Tool") or os.clock() > deadline
    return char:FindFirstChildOfClass("Tool")
end

local function fireRemote(...)
    if not State.remoteEvent then log("fireRemote: no remote"); return false end
    local ok, err = pcall(function() State.remoteEvent:FireServer(...) end)
    if not ok then log("fireRemote err:", err) end
    return ok
end

local function teleportAndFire(root, prompt)
    local part = getPromptPart(prompt)
    if not part then return false end
    local saved = root.CFrame
    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 2.5, 0))
    task.wait(0.1)
    local ok = pcall(fireproximityprompt, prompt, prompt.HoldDuration)
    task.wait(0.1)
    root.CFrame = saved
    return ok
end

-- ==================== AUTO BUY ====================
task.spawn(function()
    while true do
        if State.autoBuy then
            safeCall("AutoBuy", function()
                fireRemote("BuySeed", State.selectedSeed)
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
                local plot = getPlayerPlot()
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")

                if plot and root then
                    for _, inst in ipairs(plot:GetDescendants()) do
                        if inst:IsA("ProximityPrompt") and inst.Enabled then
                            teleportAndFire(root, inst)
                        end
                    end
                end

                if tool then
                    fireRemote("PlantSeed", State.selectedSeed)
                    log("AutoPlant fired:", State.selectedSeed)
                else
                    log("AutoPlant: tool not found for", State.selectedSeed)
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
                if not plot then log("AutoHarvest: no plot"); return end

                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local prompts = {}
                for _, inst in ipairs(plot:GetDescendants()) do
                    if inst:IsA("ProximityPrompt") and inst.Enabled then
                        table.insert(prompts, inst)
                    end
                end

                if #prompts == 0 then
                    log("AutoHarvest: nothing to harvest")
                    State.autoHarvest = false
                    if State.harvestToggleRef then State.harvestToggleRef:Set(false) end
                    notify("🌾 Done", "All harvested — toggled off", 4)
                    return
                end

                local harvested = 0
                for _, prompt in ipairs(prompts) do
                    if not State.autoHarvest then break end
                    if prompt and prompt.Parent and prompt.Enabled then
                        if teleportAndFire(root, prompt) then
                            harvested += 1
                        end
                    end
                end

                log("Harvest cycle:", harvested, "plants")
                if harvested > 0 then
                    notify("🌾 Harvested", harvested.." plants", 3)
                end
            end)
        end
        task.wait(0.7)
    end
end)

-- ==================== AUTO SELL ====================
task.spawn(function()
    while true do
        if State.autoSell then
            safeCall("AutoSell", function()
                fireRemote("SellAll")
                local sellNode = workspace:FindFirstChild("SellStand", true)
                    or workspace:FindFirstChild("Sell", true)
                    or workspace:FindFirstChild("Market", true)
                if sellNode then
                    local char = player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, inst in ipairs(sellNode:GetDescendants()) do
                            if inst:IsA("ProximityPrompt") and inst.Enabled then
                                teleportAndFire(root, inst)
                            end
                        end
                    end
                end
                log("AutoSell fired")
            end)
        end
        task.wait(5.0)
    end
end)

-- ==================== GUI ====================
local Window = Rayfield:CreateWindow({
    Name = "🌱 Grow a Garden 2 | StarCalled Hub",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Auto Buy • Plant • Harvest • Sell",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
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
        notify("🛒 Auto Buy", val and ("ON — "..State.selectedSeed) or "OFF", 3)
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
    Name = "⚡ Manual Harvest (Once)",
    Callback = function()
        State.autoHarvest = true
        task.delay(4, function()
            State.autoHarvest = false
            if State.harvestToggleRef then State.harvestToggleRef:Set(false) end
        end)
        notify("🌾 Manual Harvest", "Running one cycle...", 3)
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
        notify("🔍 Remote Scan", "Found "..#remotes.." remotes — check console", 5)
    end,
})

DebugTab:CreateButton({
    Name = "Re-Resolve Remote",
    Callback = function()
        State.remoteEvent = resolveRemote()
        if State.remoteEvent then
            notify("✅ Remote OK", State.remoteEvent:GetFullName(), 5)
        else
            notify("❌ Remote Fail", "Not found — check console", 5)
        end
    end,
})

DebugTab:CreateButton({
    Name = "Test Plot Resolution",
    Callback = function()
        local plot = getPlayerPlot()
        if plot then
            print("[Plot]", plot:GetFullName())
            notify("✅ Plot Found", plot:GetFullName(), 5)
        else
            notify("❌ No Plot", "Check console", 5)
        end
    end,
})

DebugTab:CreateButton({
    Name = "Dump Plot Prompts",
    Callback = function()
        local plot = getPlayerPlot()
        if not plot then
            notify("❌ No Plot", "Plot not resolved", 4)
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
                    "| Action:", inst.ActionText,
                    "| Part:", part and part.Name or "none")
            end
        end
        print("[Plot] Total prompts:", count)
        notify("🔍 Prompts", count.." prompts — check console", 5)
    end,
})

DebugTab:CreateButton({
    Name = "Dump Workspace (Top Level)",
    Callback = function()
        for _, v in ipairs(workspace:GetChildren()) do
            print("[WS]", v.Name, "|", v.ClassName)
        end
        notify("🌲 Workspace", "Top-level dumped to console", 4)
    end,
})

DebugTab:CreateButton({
    Name = "Test Fire Remote (BuySeed)",
    Callback = function()
        local ok = fireRemote("BuySeed", State.selectedSeed)
        notify("🔫 Fire Test", ok and "Fired — watch server" or "No remote resolved", 5)
    end,
})

-- LOAD NOTIFY
notify("🌱 GAG2 Loaded", "StarCalled Hub v7 — check Debug tab first", 6)
