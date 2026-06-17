-- 🌱 Grow a Garden 2 | StarCalled Hub - DIAGNOSTIC BUILD v4

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "🌱 Grow a Garden 2 | StarCalled Hub",
    LoadingTitle = "Grow a Garden 2",
    LoadingSubtitle = "Auto Buy • Plant • Harvest",
    ConfigurationSaving = { Enabled = false },
})

local MainTab = Window:CreateTab("🌱 Main", 4483362458)
local ShopTab = Window:CreateTab("🛒 Shop", 4483362458)
local DebugTab = Window:CreateTab("🐛 Debug", 4483362458)

local autoBuyRunning = false
local autoPlantRunning = false
local autoHarvestRunning = false
local debugMode = true
local selectedSeed = "Carrot"

local seedList = {"Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Apple", "Bamboo", "Mushroom", "Pumpkin", "Rose", "Sunflower"}

local harvestToggleRef

local function dbg(...)
    if debugMode then
        print("[Hub]", ...)
    end
end

local function safeCall(label, fn)
    local ok, err = pcall(fn)
    if not ok then
        dbg("ERROR in " .. label .. ":", err)
    end
    return ok
end

-- Resolve the remote with explicit failure reporting instead of silent nil
local Event
do
    local rs = game:GetService("ReplicatedStorage")
    local sharedModules = rs:WaitForChild("SharedModules", 5)
    if not sharedModules then
        Rayfield:Notify({Title = "❌ Remote Error", Content = "SharedModules not found", Duration = 6})
    else
        local packet = sharedModules:WaitForChild("Packet", 5)
        Event = packet and packet:WaitForChild("RemoteEvent", 5)
    end
    if not Event then
        Rayfield:Notify({Title = "❌ Remote Error", Content = "RemoteEvent path is wrong — check Debug tab", Duration = 8})
    end
end

-- Get Player's Plot — plots live under workspace.Gardens
local function getPlayerPlot()
    local gardens = workspace:FindFirstChild("Gardens", true)
    if not gardens then
        dbg("getPlayerPlot: 'Gardens' folder not found in workspace")
        return nil
    end
    for _, v in ipairs(gardens:GetChildren()) do
        if v.Name:match("^Plot%d+$") then
            local owner = v:FindFirstChild("Owner")
            if owner and owner.Value == player then
                return v
            end
        end
    end
    dbg("getPlayerPlot: no Plot under Gardens matched Owner == player")
    return nil
end

-- Equip Tool: returns the actual tool instance, not just true/false
local function equipTool(name)
    local char = player.Character
    if not char or not char:FindFirstChild("Humanoid") then
        return nil
    end
    local tool = char:FindFirstChild(name) or (player.Backpack and player.Backpack:FindFirstChild(name))
    if not tool then
        dbg("equipTool: no tool named '" .. name .. "' in Character or Backpack")
        return nil
    end
    char.Humanoid:EquipTool(tool)
    local deadline = os.clock() + 1
    repeat
        task.wait(0.05)
    until char:FindFirstChildOfClass("Tool") or os.clock() > deadline
    return char:FindFirstChildOfClass("Tool")
end

-- Find the BasePart a prompt is anchored to, walking up if needed
local function getPromptPart(prompt)
    local node = prompt.Parent
    while node and not node:IsA("BasePart") do
        node = node.Parent
    end
    return node
end

-- ==================== DEBUG TAB ====================
DebugTab:CreateToggle({
    Name = "Verbose Logging",
    CurrentValue = true,
    Callback = function(val) debugMode = val end,
})

DebugTab:CreateButton({
    Name = "Dump Backpack Tool Names",
    Callback = function()
        if player.Backpack then
            for _, tool in ipairs(player.Backpack:GetChildren()) do
                print("[Backpack]", tool.Name, tool.ClassName)
            end
        end
        local char = player.Character
        if char then
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    print("[Character]", tool.Name, tool.ClassName)
                end
            end
        end
    end,
})

DebugTab:CreateButton({
    Name = "Dump All Plots + Owners",
    Callback = function()
        local gardens = workspace:FindFirstChild("Gardens", true)
        if not gardens then
            print("[Plots] 'Gardens' folder not found")
            return
        end
        for _, v in ipairs(gardens:GetChildren()) do
            if v.Name:match("^Plot%d+$") then
                local owner = v:FindFirstChild("Owner")
                print("[Plots]", v.Name, "| Owner:", owner and tostring(owner.Value) or "none", "| You:", tostring(player))
            end
        end
    end,
})

DebugTab:CreateButton({
    Name = "Dump Plot + Prompts",
    Callback = function()
        local plot = getPlayerPlot()
        if not plot then
            print("[Plot] getPlayerPlot() returned nil — run 'Dump All Plots + Owners' to see why")
            return
        end
        print("[Plot] Found:", plot:GetFullName())
        local count = 0
        for _, inst in ipairs(plot:GetDescendants()) do
            if inst:IsA("ProximityPrompt") then
                count += 1
                local part = getPromptPart(inst)
                print("[Prompt]", inst:GetFullName(), "| Enabled:", inst.Enabled, "| HoldDuration:", inst.HoldDuration, "| Part:", part and part:GetFullName() or "none")
            end
        end
        print("[Plot] Total ProximityPrompts found:", count)
    end,
})

-- ==================== SHOP ====================
ShopTab:CreateSection("🛒 Auto Buy")
ShopTab:CreateDropdown({
    Name = "Select Seed",
    Options = seedList,
    CurrentOption = {"Carrot"},
    Callback = function(sel) selectedSeed = sel[1] end,
})

ShopTab:CreateToggle({
    Name = "Auto Buy Selected Seed",
    CurrentValue = false,
    Callback = function(val)
        autoBuyRunning = val
        Rayfield:Notify({Title = "🛒 Auto Buy", Content = val and "ON" or "OFF", Duration = 3})
    end,
})

-- ==================== FARM ====================
MainTab:CreateSection("🌱 Auto Farm")

MainTab:CreateToggle({
    Name = "Auto Plant",
    CurrentValue = false,
    Callback = function(val) autoPlantRunning = val end,
})

harvestToggleRef = MainTab:CreateToggle({
    Name = "Auto Harvest",
    CurrentValue = false,
    Callback = function(val) autoHarvestRunning = val end,
})

-- Auto Buy
task.spawn(function()
    while true do
        if autoBuyRunning and Event then
            safeCall("AutoBuy", function()
                Event:FireServer(buffer.fromstring("j\x00\x06" .. selectedSeed))
            end)
        end
        task.wait(0.3)
    end
end)

-- Auto Plant
task.spawn(function()
    while true do
        if autoPlantRunning and Event then
            safeCall("AutoPlant", function()
                local tool = equipTool(selectedSeed)
                if tool then
                    local buf = buffer.fromstring("\x05\x00\x9C\b\xD4C\xFEZ\x0EC\xD1\xE6\x13\xC3\x06" .. selectedSeed)
                    Event:FireServer(buf, {tool})
                    dbg("Planted", selectedSeed)
                else
                    dbg("AutoPlant: no tool resolved for", selectedSeed)
                end
            end)
        end
        task.wait(0.8)
    end
end)

-- Auto Harvest — walks the character to each plant before firing, stops when none remain
task.spawn(function()
    while true do
        if autoHarvestRunning then
            safeCall("AutoHarvest", function()
                local plot = getPlayerPlot()
                if not plot then
                    autoHarvestRunning = false
                    if harvestToggleRef then harvestToggleRef:Set(false) end
                    Rayfield:Notify({Title = "🌾 Auto Harvest", Content = "No plot found — stopped", Duration = 4})
                    return
                end

                local prompts = {}
                for _, inst in ipairs(plot:GetDescendants()) do
                    if inst:IsA("ProximityPrompt") and inst.Enabled then
                        table.insert(prompts, inst)
                    end
                end

                if #prompts == 0 then
                    dbg("AutoHarvest: nothing left to harvest")
                    autoHarvestRunning = false
                    if harvestToggleRef then harvestToggleRef:Set(false) end
                    Rayfield:Notify({Title = "🌾 Auto Harvest", Content = "All plants harvested — stopped", Duration = 4})
                    return
                end

                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then
                    dbg("AutoHarvest: no HumanoidRootPart")
                    return
                end

                local originalCFrame = root.CFrame
                local harvested = 0

                for _, prompt in ipairs(prompts) do
                    if not autoHarvestRunning then break end
                    if prompt.Enabled and prompt.Parent then
                        local part = getPromptPart(prompt)
                        if part then
                            root.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0))
                            task.wait(0.1)
                            local ok = safeCall("FirePrompt:" .. prompt:GetFullName(), function()
                                fireproximityprompt(prompt, prompt.HoldDuration)
                            end)
                            if ok then
                                harvested += 1
                            end
                            task.wait(0.1)
                        end
                    end
                end

                root.CFrame = originalCFrame

                if harvested > 0 then
                    dbg("Harvested " .. harvested .. " plants")
                end
            end)
        end
        task.wait(0.6)
    end
end)

Rayfield:Notify({Title = "🌱 Loaded", Content = "Check Debug tab if anything still fails", Duration = 8})
