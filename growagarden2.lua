-- 🌱 Grow a Garden 2 | StarCalled Hub - FIXED Plant & Harvest

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

local buyDelay = 0.35
local plantDelay = 0.8
local harvestDelay = 1.2

local Event = ReplicatedStorage:WaitForChild("SharedModules", 5):WaitForChild("Packet", 5):WaitForChild("RemoteEvent", 5)

local seedList = {"Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Apple", "Bamboo", "Mushroom", "Pumpkin", "Rose", "Sunflower"}

-- Helper to equip tool
local function equipTool(toolName)
    local char = player.Character
    if not char then return nil end
    local tool = char:FindFirstChild(toolName) or player.Backpack:FindFirstChild(toolName)
    if tool then
        char.Humanoid:EquipTool(tool)
        task.wait(0.2)
        return tool
    end
    return nil
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
        Rayfield:Notify({Title = "🛒 Auto Buy", Content = val and "ON - " .. selectedSeed or "OFF", Duration = 3})
    end,
})

ShopTab:CreateSlider({Name = "Buy Delay", Range = {0.1, 2}, Increment = 0.05, CurrentValue = 0.35, Callback = function(v) buyDelay = v end})

-- ==================== FARM ====================
MainTab:CreateSection("🌱 Auto Farm")
MainTab:CreateToggle({
    Name = "Auto Plant (Equip Seed First)",
    CurrentValue = false,
    Callback = function(val) autoPlantRunning = val end,
})

MainTab:CreateToggle({
    Name = "Auto Harvest",
    CurrentValue = false,
    Callback = function(val) autoHarvestRunning = val end,
})

-- ==================== LOOPS ====================

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

-- Auto Plant (Improved)
task.spawn(function()
    while true do
        if autoPlantRunning then
            pcall(function()
                local tool = equipTool(selectedSeed)
                if tool then
                    local plantBuffer = buffer.fromstring("\x05\x00\x9C\b\xD4C\xFEZ\x0EC\xD1\xE6\x13\xC3\x06" .. selectedSeed)
                    Event:FireServer(plantBuffer, {tool})
                else
                    Rayfield:Notify({Title = "🌱 Plant", Content = "Equip " .. selectedSeed .. " first!", Duration = 3})
                end
            end)
        end
        task.wait(plantDelay)
    end
end)

-- Auto Harvest (Improved)
task.spawn(function()
    while true do
        if autoHarvestRunning then
            pcall(function()
                -- Try to equip shovel if exists
                equipTool("Shovel")
                local harvestStr = "c\x00\x1C\x05\x01\v\rShovel:Shovel\x05\x02\v\vBuild:Build\x05\x03\v\vSeed:" 
                    .. selectedSeed .. "\x05\x04\v\vSeed:" .. selectedSeed 
                    .. "\x05\x05\v\x10Fruit:" .. selectedSeed .. ":828\x00"
                Event:FireServer(buffer.fromstring(harvestStr))
            end)
        end
        task.wait(harvestDelay)
    end
end)

-- Others
OtherTab:CreateButton({
    Name = "🔍 Load Infinite Yield",
    Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end,
})

OtherTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Callback = function(v) 
        -- Anti AFK logic here if needed
    end,
})

Rayfield:Notify({Title = "✅ Fixed Version", Content = "Plant & Harvest Improved!\nEquip seed for planting.", Duration = 6})
