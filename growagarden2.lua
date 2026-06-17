-- 🌱 Grow a Garden 2 | StarCalled Hub - FIXED Harvest + Plant
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "🌱 Grow a Garden 2 | StarCalled Hub",
    LoadingTitle = "Grow a Garden 2",
    LoadingSubtitle = "Auto Buy • Plant • Harvest",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

local MainTab = Window:CreateTab("🌱 Main", 4483362458)
local ShopTab = Window:CreateTab("🛒 Shop", 4483362458)
local OtherTab = Window:CreateTab("🛠 Others", 4483362458)

local autoBuyRunning = false
local autoPlantRunning = false
local autoHarvestRunning = false
local selectedSeed = "Carrot"

local buyDelay = 0.3
local plantDelay = 0.8
local harvestDelay = 0.6

local Event = ReplicatedStorage:WaitForChild("SharedModules", 5):WaitForChild("Packet", 5):WaitForChild("RemoteEvent", 5)

local seedList = {"Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Apple", "Bamboo", "Mushroom", "Pumpkin", "Rose", "Sunflower"}

-- Find Player's Plot
local function getPlayerPlot()
    for _, plot in ipairs(workspace:GetChildren()) do
        if plot.Name:match("^Plot%d+$") and plot:FindFirstChild("Owner") and plot.Owner.Value == player then
            return plot
        end
    end
    return nil
end

-- Equip Tool
local function equipTool(name)
    local char = player.Character
    if not char or not char:FindFirstChild("Humanoid") then return end
    local tool = char:FindFirstChild(name) or player.Backpack:FindFirstChild(name)
    if tool then
        char.Humanoid:EquipTool(tool)
        task.wait(0.2)
    end
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
        Rayfield:Notify({Title = "🛒 Auto Buy", Content = val and "ON - "..selectedSeed or "OFF", Duration = 3})
    end,
})

-- ==================== FARM ====================
MainTab:CreateSection("🌱 Auto Farm")

MainTab:CreateToggle({
    Name = "Auto Plant (Equip Seed)",
    CurrentValue = false,
    Callback = function(val) autoPlantRunning = val end,
})

MainTab:CreateToggle({
    Name = "Auto Harvest (New Method)",
    CurrentValue = false,
    Callback = function(val) autoHarvestRunning = val end,
})

-- Auto Buy
task.spawn(function()
    while true do
        if autoBuyRunning then
            pcall(function()
                Event:FireServer(buffer.fromstring("j\x00\x06" .. selectedSeed))
            end)
        end
        task.wait(buyDelay)
    end
end)

-- Auto Plant
task.spawn(function()
    while true do
        if autoPlantRunning then
            pcall(function()
                equipTool(selectedSeed)
                local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local buf = buffer.fromstring("\x05\x00\x9C\b\xD4C\xFEZ\x0EC\xD1\xE6\x13\xC3\x06" .. selectedSeed)
                    Event:FireServer(buf, {tool})
                end
            end)
        end
        task.wait(plantDelay)
    end
end)

-- **NEW & IMPROVED Auto Harvest** (uses HarvestPrompt from your screenshot)
task.spawn(function()
    while true do
        if autoHarvestRunning then
            pcall(function()
                local plot = getPlayerPlot()
                if plot then
                    for _, plant in ipairs(plot:GetDescendants()) do
                        if plant:FindFirstChild("HarvestPrompt") then
                            local prompt = plant.HarvestPrompt
                            if prompt and prompt.Enabled then
                                -- Fire the ProximityPrompt
                                pcall(function()
                                    fireproximityprompt(prompt, 1)
                                end)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(harvestDelay)
    end
end)

OtherTab:CreateButton({
    Name = "Load Infinite Yield",
    Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end,
})

Rayfield:Notify({Title = "🌱 Updated!", Content = "New Harvest using HarvestPrompt\nBuy seeds → Equip seed → Turn on Auto Plant & Harvest", Duration = 8})
