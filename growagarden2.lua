-- 🌱 Grow a Garden 2 | StarCalled Hub
-- Using your exact remote events

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

-- Variables
local autoBuyRunning = false
local autoPlantRunning = false
local autoHarvestRunning = false
local selectedSeed = "Carrot"

local buyDelay = 0.4
local plantDelay = 1.1
local harvestDelay = 1.3

-- Remote
local Event = ReplicatedStorage:WaitForChild("SharedModules", 5)
                  :WaitForChild("Packet", 5)
                  :WaitForChild("RemoteEvent", 5)

local seedList = {"Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Apple", "Bamboo", "Mushroom", "Pumpkin", "Rose", "Sunflower"}

-- ==================== SHOP TAB ====================
ShopTab:CreateSection("🛒 Auto Buy")

ShopTab:CreateDropdown({
    Name = "Select Seed to Buy",
    Options = seedList,
    CurrentOption = {"Carrot"},
    MultipleOptions = false,
    Callback = function(selected)
        selectedSeed = selected[1]
    end,
})

ShopTab:CreateToggle({
    Name = "Auto Buy Selected Seed",
    CurrentValue = false,
    Callback = function(val)
        autoBuyRunning = val
        Rayfield:Notify({Title = "🛒 Auto Buy", Content = val and "Started - " .. selectedSeed or "Stopped", Duration = 3})
    end,
})

ShopTab:CreateSlider({
    Name = "Buy Speed",
    Range = {0.1, 2},
    Increment = 0.1,
    CurrentValue = 0.4,
    Suffix = "s",
    Callback = function(v) buyDelay = v end,
})

-- ==================== FARM TAB ====================
MainTab:CreateSection("🌱 Auto Farm")

MainTab:CreateToggle({
    Name = "Auto Plant",
    CurrentValue = false,
    Callback = function(val)
        autoPlantRunning = val
        Rayfield:Notify({Title = "🌱 Auto Plant", Content = val and "Enabled" or "Disabled", Duration = 3})
    end,
})

MainTab:CreateToggle({
    Name = "Auto Harvest",
    CurrentValue = false,
    Callback = function(val)
        autoHarvestRunning = val
        Rayfield:Notify({Title = "🌾 Auto Harvest", Content = val and "Enabled" or "Disabled", Duration = 3})
    end,
})

MainTab:CreateSlider({Name = "Plant Delay", Range = {0.5, 3}, Increment = 0.1, CurrentValue = 1.1, Callback = function(v) plantDelay = v end})
MainTab:CreateSlider({Name = "Harvest Delay", Range = {0.5, 4}, Increment = 0.1, CurrentValue = 1.3, Callback = function(v) harvestDelay = v end})

-- ==================== LOOPS (Using Your Exact Remotes) ====================

-- Auto Buy Loop
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

-- Auto Plant Loop
task.spawn(function()
    while true do
        if autoPlantRunning then
            pcall(function()
                local plantBuffer = buffer.fromstring("\x05\x00\x9C\b\xD4C\xFEZ\x0EC\xD1\xE6\x13\xC3\x06" .. selectedSeed)
                local tool = player.Character and (player.Character:FindFirstChild(selectedSeed) or player.Character:FindFirstChildOfClass("Tool"))
                Event:FireServer(plantBuffer, {tool})
            end)
        end
        task.wait(plantDelay)
    end
end)

-- Auto Harvest Loop
task.spawn(function()
    while true do
        if autoHarvestRunning then
            pcall(function()
                local harvestStr = "c\x00\x1C\x05\x01\v\rShovel:Shovel\x05\x02\v\vBuild:Build\x05\x03\v\vSeed:" 
                                   .. selectedSeed .. "\x05\x04\v\vSeed:" .. selectedSeed 
                                   .. "\x05\x05\v\x10Fruit:" .. selectedSeed .. ":828\x00"
                Event:FireServer(buffer.fromstring(harvestStr))
            end)
        end
        task.wait(harvestDelay)
    end
end)

-- ==================== OTHERS ====================
OtherTab:CreateButton({
    Name = "🔍 Load Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        Rayfield:Notify({Title = "✅ Loaded", Content = "Infinite Yield", Duration = 3})
    end,
})

OtherTab:CreateSection("🚶 Anti-AFK")
local afk = false
OtherTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Callback = function(v)
        afk = v
    end,
})

task.spawn(function()
    while true do
        task.wait(60)
        if afk and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 0.1)
            task.wait(0.1)
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -0.1)
        end
    end
end)

Rayfield:Notify({
    Title = "✅ Grow a Garden 2 Hub",
    Content = "Loaded Successfully! Use Auto Buy + Plant + Harvest",
    Duration = 6
})
