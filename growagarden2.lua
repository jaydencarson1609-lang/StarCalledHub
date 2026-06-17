-- 🌱 Grow a Garden 2 | StarCalled Hub - FINAL TRY (HarvestPrompt Focus)

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

local autoBuyRunning = false
local autoPlantRunning = false
local autoHarvestRunning = false
local selectedSeed = "Carrot"

local Event = game:GetService("ReplicatedStorage"):WaitForChild("SharedModules", 5):WaitForChild("Packet", 5):WaitForChild("RemoteEvent", 5)

local seedList = {"Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Apple", "Bamboo", "Mushroom", "Pumpkin", "Rose", "Sunflower"}

-- Get Player's Plot
local function getPlayerPlot()
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Name:match("^Plot%d+$") and v:FindFirstChild("Owner") and v.Owner.Value == player then
            return v
        end
    end
    return nil
end

-- Equip Tool
local function equipTool(name)
    local char = player.Character
    if not char or not char:FindFirstChild("Humanoid") then return false end
    local tool = char:FindFirstChild(name) or player.Backpack:FindFirstChild(name)
    if tool then
        char.Humanoid:EquipTool(tool)
        task.wait(0.2)
        return true
    end
    return false
end

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
    Name = "Auto Harvest (HarvestPrompt)",
    CurrentValue = false,
    Callback = function(val) autoHarvestRunning = val end,
})

-- Auto Buy (Works for you)
task.spawn(function()
    while true do
        if autoBuyRunning then
            pcall(function()
                Event:FireServer(buffer.fromstring("j\x00\x06" .. selectedSeed))
            end)
        end
        task.wait(0.3)
    end
end)

-- Auto Plant
task.spawn(function()
    while true do
        if autoPlantRunning then
            pcall(function()
                if equipTool(selectedSeed) then
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        local buf = buffer.fromstring("\x05\x00\x9C\b\xD4C\xFEZ\x0EC\xD1\xE6\x13\xC3\x06" .. selectedSeed)
                        Event:FireServer(buf, {tool})
                    end
                end
            end)
        end
        task.wait(0.8)
    end
end)

-- Auto Harvest - Focused on HarvestPrompt
task.spawn(function()
    while true do
        if autoHarvestRunning then
            pcall(function()
                local plot = getPlayerPlot()
                if plot then
                    local harvested = 0
                    for _, plant in ipairs(plot:GetDescendants()) do
                        local prompt = plant:FindFirstChild("HarvestPrompt") or plant:FindFirstChild("HarvestPromptLabel")
                        if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            fireproximityprompt(prompt)
                            harvested += 1
                            task.wait(0.05)
                        end
                    end
                    if harvested > 0 then
                        print("Harvested " .. harvested .. " plants")
                    end
                end
            end)
        end
        task.wait(0.6)
    end
end)

Rayfield:Notify({Title = "🌱 Loaded", Content = "Auto Buy works\nTry Auto Harvest first (after crops grow)", Duration = 8})
