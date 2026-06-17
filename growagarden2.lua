-- 🌱 Grow a Garden 2 | StarCalled Hub - DIAGNOSTIC BUILD

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

-- Get Player's Plot, with diagnostics if nothing matches
local function getPlayerPlot()
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Name:match("^Plot%d+$") then
            local owner = v:FindFirstChild("Owner")
            if owner and owner.Value == player then
                return v
            end
        end
    end
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

-- ==================== DEBUG TAB ====================
DebugTab:CreateToggle({
    Name = "Verbose Logging",
    CurrentValue = true,
    Callback = function(val) debugMode = val end,
})

DebugTab:CreateButton({
    Name = "Dump Backpack Tool Names",
    Callback = function()
        if not player.Backpack then return end
        for _, tool in ipairs(player.Backpack:GetChildren()) do
            print("[Backpack]", tool.Name, tool.ClassName)
        end
        for _, tool in ipairs(player.Character and player.Character:GetChildren() or {}) do
            if tool:IsA("Tool") then
                print("[Character]", tool.Name, tool.ClassName)
            end
        end
    end,
})

DebugTab:CreateButton({
    Name = "Dump Plot + Prompts",
    Callback = function()
        local plot = getPlayerPlot()
        if not plot then
            print("[Plot] getPlayerPlot() returned nil — check Owner value / Plot naming pattern")
            return
        end
        print("[Plot] Found:", plot:GetFullName())
        for _, inst in ipairs(plot:GetDescendants()) do
            if inst:IsA("ProximityPrompt") then
                print("[Prompt]", inst:GetFullName(), "| Name:", inst.Name, "| ActionText:", inst.ActionText, "| Enabled:", inst.Enabled)
            end
        end
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

MainTab:CreateToggle({
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

-- Auto Harvest — matches by ActionText too, not just instance Name
task.spawn(function()
    while true do
        if autoHarvestRunning then
            safeCall("AutoHarvest", function()
                local plot = getPlayerPlot()
                if not plot then
                    dbg("AutoHarvest: no plot found for player")
                    return
                end
                local harvested = 0
                for _, inst in ipairs(plot:GetDescendants()) do
                    if inst:IsA("ProximityPrompt") and inst.Enabled then
                        local nameMatch = inst.Name == "HarvestPrompt" or inst.Name == "HarvestPromptLabel"
                        local textMatch = inst.ActionText and inst.ActionText:lower():find("harvest")
                        if nameMatch or textMatch then
                            fireproximityprompt(inst)
                            harvested += 1
                            task.wait(0.05)
                        end
                    end
                end
                if harvested > 0 then
                    dbg("Harvested " .. harvested .. " plants")
                end
            end)
        end
        task.wait(0.6)
    end
end)

Rayfield:Notify({Title = "🌱 Loaded", Content = "Open the Debug tab if Plant/Harvest still fail", Duration = 8})
