-- ★ StarCalled Hub | Clasher Royale

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Clasher Royale",
    ConfigurationSaving = { Enabled = true, FolderName = "StarCalledHub", FileName = "ClasherRoyale" },
    Discord = { Enabled = false },
    KeySystem = false,
})

local MainTab = Window:CreateTab("🏠 Main", 4483362458)
local TeamTab = Window:CreateTab("🔵 Teams", 4483362458)
local DeployTab = Window:CreateTab("📍 Deploy Units", 4483362458)
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
local NotesTab = Window:CreateTab("📝 Notes", 4483362458)

-- Remotes
local SetTeam = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SetTeam")
local Deploy = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Deploy")
local ChoseUnit = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ChoseUnit")
local UseAttack = ReplicatedStorage:WaitForChild("UnitEvents"):WaitForChild("UseAttack")
local VoteEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("VoteEvent")

-- Variables
local autoDeploy = false
local autoAttack = false
local selectedUnit = "Skeletons"

-- ==================== MAIN TAB ====================
MainTab:CreateSection("🎮 General Features")

MainTab:CreateButton({
    Name = "Refresh Tower Values",
    Callback = function()
        local towerValues = Workspace:FindFirstChild("Royal Arena") and Workspace["Royal Arena"]:FindFirstChild("TowerValues")
        if towerValues then
            Rayfield:Notify({Title = "✅ Tower Values", Content = "Found! Check console (F9)", Duration = 4})
            print("Tower Values:", towerValues:GetChildren())
        else
            Rayfield:Notify({Title = "❌ Not Found", Content = "Royal Arena.TowerValues not found", Duration = 3})
        end
    end,
})

-- ==================== TEAM TAB ====================
TeamTab:CreateSection("🔵 Team Changer")

TeamTab:CreateButton({
    Name = "Join Blue Team",
    Callback = function()
        SetTeam:FireServer(game:GetService("Teams").Blue)
        Rayfield:Notify({Title = "🔵 Blue Team", Content = "Joined successfully", Duration = 3})
    end,
})

TeamTab:CreateButton({
    Name = "Join Red Team",
    Callback = function()
        SetTeam:FireServer(game:GetService("Teams").Red)
        Rayfield:Notify({Title = "🔴 Red Team", Content = "Joined successfully", Duration = 3})
    end,
})

-- ==================== DEPLOY TAB ====================
DeployTab:CreateSection("📍 Unit Deployment")

DeployTab:CreateDropdown({
    Name = "Select Unit",
    Options = {"Skeletons", "Giants", "Archers", "Goblins", "Barbarians", "Knight", "Wizard"}, -- Add more as you discover
    CurrentOption = {"Skeletons"},
    Callback = function(Value)
        selectedUnit = Value[1]
    end,
})

DeployTab:CreateToggle({
    Name = "Auto Spam Selected Unit",
    CurrentValue = false,
    Callback = function(Value)
        autoDeploy = Value
        if Value then
            Rayfield:Notify({Title = "📍 Auto Deploy", Content = "Spamming " .. selectedUnit, Duration = 3})
            task.spawn(function()
                while autoDeploy do
                    ChoseUnit:FireServer(selectedUnit)
                    task.wait(0.12)
                    
                    -- Try to deploy on available tiles
                    local arena = Workspace:FindFirstChild("Royal Arena") or Workspace:FindFirstChild("Dark Elixir Cave")
                    if arena then
                        local tilesFolder = arena:FindFirstChild("BlueTiles") or arena:FindFirstChild("Tiles")
                        if tilesFolder and tilesFolder:FindFirstChild("Pocket2") then
                            local pocket = tilesFolder.Pocket2
                            local children = pocket:GetChildren()
                            if #children > 0 then
                                Deploy:FireServer(children[math.random(1, #children)])
                            end
                        end
                    end
                    task.wait(0.35)
                end
            end)
        else
            Rayfield:Notify({Title = "📍 Auto Deploy", Content = "Stopped", Duration = 2})
        end
    end,
})

DeployTab:CreateButton({
    Name = "Deploy Once (Selected Unit)",
    Callback = function()
        ChoseUnit:FireServer(selectedUnit)
        task.wait(0.2)
        Rayfield:Notify({Title = "✅ Deployed", Content = selectedUnit, Duration = 2})
    end,
})

-- ==================== COMBAT TAB ====================
CombatTab:CreateSection("⚔️ Combat & Auto Attack")

CombatTab:CreateToggle({
    Name = "Auto Attack (Spam)",
    CurrentValue = false,
    Callback = function(Value)
        autoAttack = Value
        if Value then
            Rayfield:Notify({Title = "⚔️ Auto Attack", Content = "Spamming attacks...", Duration = 3})
            task.spawn(function()
                while autoAttack do
                    local targetPos = Vector3.new(-56.2, 12.6, 430.9) -- You can change this
                    UseAttack:FireServer(targetPos, targetPos)
                    task.wait(0.15)
                end
            end)
        else
            Rayfield:Notify({Title = "⚔️ Auto Attack", Content = "Stopped", Duration = 2})
        end
    end,
})

CombatTab:CreateButton({
    Name = "Vote Cozy Clashmas Arena",
    Callback = function()
        VoteEvent:FireServer("ARENA", "Cozy Clashmas")
        Rayfield:Notify({Title = "🗳️ Voted", Content = "Cozy Clashmas Arena", Duration = 3})
    end,
})

CombatTab:CreateButton({
    Name = "Attack Nearest Unit",
    Callback = function()
        local units = Workspace:FindFirstChild("Units")
        if units then
            local children = units:GetChildren()
            if #children > 0 then
                local target = children[math.random(1, #children)]
                local pos = target.Position
                UseAttack:FireServer(pos, pos)
                Rayfield:Notify({Title = "⚔️ Attacking", Content = "Nearest unit targeted", Duration = 2})
            end
        end
    end,
})

-- ==================== NOTES TAB ====================
NotesTab:CreateSection("📝 About")
NotesTab:CreateLabel("★ StarCalled Hub")
NotesTab:CreateLabel("Made by: Jayden")
NotesTab:CreateLabel("Game: Clasher Royale")
NotesTab:CreateLabel("Version: 1.2 - Auto Spam Edition")
local timeLbl = NotesTab:CreateLabel("🕐 Loaded at: " .. os.date("%A %d %B %Y • %H:%M:%S"))

Rayfield:Notify({
    Title = "✅ Clasher Royale",
    Content = "Auto Spam Deploy + Auto Attack Added!",
    Duration = 5
})
