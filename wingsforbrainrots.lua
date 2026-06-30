-- ╔══════════════════════════════════════════════╗
-- ║                                              ║
-- ║ ★ StarCalled Hub | Wings for Brainrots      ║
-- ║ Made by Jayden                               ║
-- ║                                              ║
-- ╚══════════════════════════════════════════════╝

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
task.wait(0.5)

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub | Wings for Brainrots",
    LoadingTitle = "★ StarCalled Hub",
    LoadingSubtitle = "Wings for Brainrots",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "StarCalledHub",
        FileName = "WFB_Config"
    },
    Discord = { Enabled = false },
    KeySystem = false,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- ╔══════════════════════════════════════════════╗
-- ║ RARITY CONFIG ║
-- ╚══════════════════════════════════════════════╝
local RARITIES = {
    { name = "Common", folder = "Common", pos = Vector3.new(22, 8, 134) },
    { name = "Uncommon", folder = "Uncommon", pos = Vector3.new(35, 1, 295) },
    { name = "Rare", folder = "Rare", pos = Vector3.new(31, 1, 516) },
    { name = "Epic", folder = "Epic", pos = Vector3.new(32, 1, 824) },
    { name = "Legendary", folder = "Legendary", pos = Vector3.new(33, 1, 1253) },
    { name = "Mythical", folder = "Mythical", pos = Vector3.new(31, 1, 1822) },
    { name = "Cosmic", folder = "Cosmic", pos = Vector3.new(0, 13, 6102) },
    { name = "Celestial", folder = "Celestial", pos = Vector3.new(34, 1, 4051) },
}

local SUBMIT_POS = Vector3.new(11, 16, 13)
local selectedRarity = RARITIES[8] -- default Celestial

local farmActive = false
local farmThread = nil

local function isPaused()
    local gui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if gui then
        for _, v in ipairs(gui:GetDescendants()) do
            if v:IsA("Frame") and v.Visible then
                local name = v.Name:lower()
                if name:find("pause") or name:find("frozen") or name:find("suspended") then
                    return true
                end
            end
        end
    end
    return false
end

local function safeTeleport(pos)
    local rx = (math.random() - 0.5) * 2
    local rz = (math.random() - 0.5) * 2
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(pos + Vector3.new(rx, 0, rz))
    end
end

-- ╔══════════════════════════════════════════════╗
-- ║ HELPERS ║
-- ╚══════════════════════════════════════════════╝
local function getRootPart()
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function teleport(pos)
    local root = getRootPart()
    if root then
        root.CFrame = CFrame.new(pos)
    end
end

local function tryPickup(item, prompt)
    pcall(function() prompt.HoldDuration = 0 end)
    pcall(fireproximityprompt, prompt)
    pcall(firesignal, prompt.Triggered, player)
    pcall(function() prompt:InputHoldBegin() prompt:InputHoldEnd() end)
    
    for _, v in ipairs(item:GetDescendants()) do
        if v:IsA("ClickDetector") then
            pcall(fireclickdetector, v)
        end
    end
end

-- Auto detect carry limit and teleport to lobby
local notifEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ShowNotification")
notifEvent.OnClientEvent:Connect(function(message, notifType)
    if message and message:lower():find("carry limit") then
        safeTeleport(SUBMIT_POS)
        Rayfield:Notify({
            Title = "★ StarCalled Hub",
            Content = "Carry limit! Rushing to lobby...",
            Duration = 3,
        })
    end
end)

-- ╔══════════════════════════════════════════════╗
-- ║ FARM LOOP ║
-- ╚══════════════════════════════════════════════╝
local function farmLoop()
    while farmActive do
        local rarity = selectedRarity
        safeTeleport(rarity.pos)
        task.wait(1.5)
        
        local spawners = workspace:FindFirstChild("ItemSpawners")
        local zoneFolder = spawners and spawners:FindFirstChild(rarity.folder)
        
        if zoneFolder then
            for _, item in ipairs(zoneFolder:GetChildren()) do
                if not farmActive then break end
                while isPaused() do task.wait(0.5) end
                
                local mesh = item:FindFirstChild("Mesh")
                local prompt = mesh and mesh:FindFirstChildOfClass("ProximityPrompt")
                
                if prompt then
                    local pos = (mesh:IsA("BasePart") and mesh.Position) or (item:IsA("BasePart") and item.Position) or rarity.pos
                    safeTeleport(Vector3.new(pos.X, pos.Y, pos.Z))
                    task.wait(0.4)
                    
                    local spamEnd = tick() + 5
                    while tick() < spamEnd and item.Parent ~= nil do
                        if not farmActive then break end
                        tryPickup(item, prompt)
                        task.wait(0.1)
                    end
                    task.wait(0.3)
                end
            end
        else
            Rayfield:Notify({
                Title = "★ StarCalled Hub",
                Content = rarity.name .. " area not loaded yet, retrying...",
                Duration = 3,
            })
            task.wait(2)
            continue
        end
        
        safeTeleport(SUBMIT_POS)
        task.wait(1)
    end
end

-- ╔══════════════════════════════════════════════╗
-- ║ TABS ║
-- ╚══════════════════════════════════════════════╝
local MainTab = Window:CreateTab("★ Main", 4483362458)
local UpgradeTab = Window:CreateTab("★ Upgrades", 4483362458)
local ExtrasTab = Window:CreateTab("★ Extras", 4483362458)
local NotesTab = Window:CreateTab("★ Notes", 4483362458)

-- ╔══════════════════════════════════════════════╗
-- ║ MAIN TAB ║
-- ╚══════════════════════════════════════════════╝
MainTab:CreateSection("★ Auto Farm")

local rarityNames = {}
for _, r in ipairs(RARITIES) do
    table.insert(rarityNames, r.name)
end

MainTab:CreateDropdown({
    Name = "Select Rarity",
    Options = rarityNames,
    CurrentOption = {"Celestial"},
    MultipleOptions = false,
    Callback = function(selected)
        local choice = type(selected) == "table" and selected[1] or selected
        for _, r in ipairs(RARITIES) do
            if r.name == choice then
                selectedRarity = r
                Rayfield:Notify({
                    Title = "★ StarCalled Hub",
                    Content = "Rarity set to " .. r.name,
                    Duration = 2,
                })
                break
            end
        end
    end
})

MainTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Callback = function(val)
        farmActive = val
        if val then
            Rayfield:Notify({
                Title = "★ StarCalled Hub",
                Content = "Farming " .. selectedRarity.name .. " brainrots...",
                Duration = 3,
            })
            farmThread = task.spawn(farmLoop)
        else
            if farmThread then
                task.cancel(farmThread)
                farmThread = nil
            end
            Rayfield:Notify({
                Title = "★ StarCalled Hub",
                Content = "Auto Farm stopped.",
                Duration = 3,
            })
        end
    end
})

MainTab:CreateSection("★ Teleport")
MainTab:CreateButton({
    Name = "Go to Selected Rarity Zone",
    Callback = function()
        safeTeleport(selectedRarity.pos)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Teleported to " .. selectedRarity.name .. "!", Duration = 3})
    end
})

MainTab:CreateButton({
    Name = "Go to Lobby (Submit)",
    Callback = function()
        safeTeleport(SUBMIT_POS)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Teleported to Lobby!", Duration = 3})
    end
})

MainTab:CreateSection("★ Utilities")
MainTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Callback = function(val)
        if val then
            _G.AntiAFK = RunService.Heartbeat:Connect(function()
                player:Move(Vector3.new(0, 0, 0))
            end)
        else
            if _G.AntiAFK then
                _G.AntiAFK:Disconnect()
                _G.AntiAFK = nil
            end
        end
    end
})

MainTab:CreateButton({
    Name = "Load Infinite Yield",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Infinite Yield loaded!", Duration = 3})
    end
})

-- ╔══════════════════════════════════════════════╗
-- ║ UPGRADES TAB ║
-- ╚══════════════════════════════════════════════╝
local upgradeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpgradeRequested")
local autoUpgradeThreads = {}

local function startAutoUpgrade(stat)
    if autoUpgradeThreads[stat] then return end
    autoUpgradeThreads[stat] = task.spawn(function()
        while autoUpgradeThreads[stat] do
            pcall(function()
                upgradeRemote:FireServer(stat, 1)
            end)
            task.wait(0.1)
        end
    end)
end

local function stopAutoUpgrade(stat)
    if autoUpgradeThreads[stat] then
        task.cancel(autoUpgradeThreads[stat])
        autoUpgradeThreads[stat] = nil
    end
end

UpgradeTab:CreateSection("★ Auto Upgrade")
UpgradeTab:CreateToggle({
    Name = "Auto Upgrade Speed",
    CurrentValue = false,
    Callback = function(val)
        if val then startAutoUpgrade("Speed") else stopAutoUpgrade("Speed") end
    end
})
UpgradeTab:CreateToggle({
    Name = "Auto Upgrade Stamina",
    CurrentValue = false,
    Callback = function(val)
        if val then startAutoUpgrade("Stamina") else stopAutoUpgrade("Stamina") end
    end
})
UpgradeTab:CreateToggle({
    Name = "Auto Upgrade Carry",
    CurrentValue = false,
    Callback = function(val)
        if val then startAutoUpgrade("Carry") else stopAutoUpgrade("Carry") end
    end
})

UpgradeTab:CreateSection("★ Rebirth")
local rebirthRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RequestRebirth")
UpgradeTab:CreateButton({
    Name = "Rebirth",
    Callback = function()
        pcall(function() rebirthRemote:FireServer() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Rebirth requested!", Duration = 3})
    end
})

local autoRebirthThread = nil
UpgradeTab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Callback = function(val)
        if val then
            autoRebirthThread = task.spawn(function()
                while val do
                    pcall(function() rebirthRemote:FireServer() end)
                    task.wait(1)
                end
            end)
        else
            if autoRebirthThread then
                task.cancel(autoRebirthThread)
                autoRebirthThread = nil
            end
        end
    end
})

UpgradeTab:CreateSection("★ Max Upgrades")
UpgradeTab:CreateButton({
    Name = "Max Speed (x108)",
    Callback = function()
        pcall(function() upgradeRemote:FireServer("Speed", 108) end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Max Speed fired!", Duration = 3})
    end
})
UpgradeTab:CreateButton({
    Name = "Max Stamina",
    Callback = function()
        for i = 1, 50 do
            pcall(function() upgradeRemote:FireServer("Stamina", 1) end)
            task.wait(0.05)
        end
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Max Stamina fired!", Duration = 3})
    end
})
UpgradeTab:CreateButton({
    Name = "Max Carry",
    Callback = function()
        for i = 1, 50 do
            pcall(function() upgradeRemote:FireServer("Carry", 1) end)
            task.wait(0.05)
        end
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Max Carry fired!", Duration = 3})
    end
})

-- ╔══════════════════════════════════════════════╗
-- ║ EXTRAS TAB ║
-- ╚══════════════════════════════════════════════╝
local wingsRemote = nil
local function getWingsRemote()
    if wingsRemote then return wingsRemote end
    local char = player.Character
    if char then
        local wa = char:FindFirstChild("WingsAnims")
        if wa then
            wingsRemote = wa:FindFirstChild("UpdateState")
        end
    end
    return wingsRemote
end

ExtrasTab:CreateSection("★ Wings")
ExtrasTab:CreateToggle({
    Name = "Wing Animation",
    CurrentValue = false,
    Callback = function(val)
        local remote = getWingsRemote()
        if remote then
            pcall(function() remote:FireServer(val) end)
            Rayfield:Notify({
                Title = "★ StarCalled Hub",
                Content = val and "Wings enabled!" or "Wings disabled!",
                Duration = 2,
            })
        else
            Rayfield:Notify({
                Title = "★ StarCalled Hub",
                Content = "Wings remote not found. Make sure you have wings equipped.",
                Duration = 4,
            })
        end
    end
})

ExtrasTab:CreateSection("★ Lucky Block")
local LUCKY_BLOCK_TYPES = {
    "Normal", "Golden", "Lava", "Rainbow",
    "Diamond", "Galaxy", "Hacker", "UFO"
}
local selectedLuckyBlock = "Lava"

ExtrasTab:CreateDropdown({
    Name = "Lucky Block Type",
    Options = LUCKY_BLOCK_TYPES,
    CurrentOption = {"Lava"},
    MultipleOptions = false,
    Callback = function(selected)
        selectedLuckyBlock = type(selected) == "table" and selected[1] or selected
    end
})

ExtrasTab:CreateButton({
    Name = "Open Lucky Block (Visual)",
    Callback = function()
        local rollRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("RollLuckyBlock")
        if rollRemote then
            local itemFolder = ReplicatedStorage:FindFirstChild("Items") and ReplicatedStorage.Items:FindFirstChild(selectedLuckyBlock)
            local brainrotName = "Brainrot"
            if itemFolder then
                local children = itemFolder:GetChildren()
                if #children > 0 then
                    brainrotName = children[math.random(1, #children)].Name
                end
            end
            pcall(function()
                firesignal(rollRemote.OnClientEvent, player, brainrotName, selectedLuckyBlock)
            end)
            Rayfield:Notify({
                Title = "★ StarCalled Hub",
                Content = "Lucky Block opened! (" .. selectedLuckyBlock .. ") — visual only",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "★ StarCalled Hub",
                Content = "Lucky Block remote not found.",
                Duration = 3,
            })
        end
    end
})

-- ╔══════════════════════════════════════════════╗
-- ║ NOTES TAB ║
-- ╚══════════════════════════════════════════════╝
NotesTab:CreateSection("★ StarCalled Hub")
NotesTab:CreateLabel("Made by | Jayden")
NotesTab:CreateLabel("Game | Wings for Brainrots")
NotesTab:CreateLabel("Version | 1.3")
NotesTab:CreateLabel("Main | Auto Farm, Rarity Select, Teleports")
NotesTab:CreateLabel("Upgrades | Speed, Stamina, Carry, Rebirth")
NotesTab:CreateLabel("Extras | Wings Anim, Lucky Block Visual")

-- ╔══════════════════════════════════════════════╗
-- ║ READY ║
-- ╚══════════════════════════════════════════════╝
Rayfield:Notify({
    Title = "★ StarCalled Hub",
    Content = "Wings for Brainrots ready. Celestial added!",
    Duration = 5,
})

print("★ StarCalled Hub | Wings for Brainrots Ready (Celestial Added)")
