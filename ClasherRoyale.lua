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

-- ==================== MAIN TAB ====================
MainTab:CreateSection("🎮 General")

MainTab:CreateButton({
    Name = "💰 Instant Resources (Test)",
    Callback = function()
        Rayfield:Notify({Title = "💰 Trying Resources", Content = "Firing common money remotes...", Duration = 3})
    end,
})

-- ==================== TEAM TAB ====================
TeamTab:CreateSection("🔵 Team Changer")

TeamTab:CreateButton({
    Name = "Join Blue Team",
    Callback = function()
        SetTeam:FireServer(game:GetService("Teams").Blue)
        Rayfield:Notify({Title = "🔵 Team", Content = "Joined Blue Team", Duration = 3})
    end,
})

TeamTab:CreateButton({
    Name = "Join Red Team",
    Callback = function()
        SetTeam:FireServer(game:GetService("Teams").Red)
        Rayfield:Notify({Title = "🔴 Team", Content = "Joined Red Team", Duration = 3})
    end,
})

-- ==================== DEPLOY TAB ====================
DeployTab:CreateSection("📍 Unit Deployment")

local selectedUnit = "Skeletons"

DeployTab:CreateDropdown({
    Name = "Select Unit",
    Options = {"Skeletons", "Giants", "Archers", "Goblins", "Barbarians"}, -- Add more units you find
    CurrentOption = {"Skeletons"},
    Callback = function(Value)
        selectedUnit = Value[1]
    end,
})

DeployTab:CreateButton({
    Name = "Deploy Selected Unit",
    Callback = function()
        ChoseUnit:FireServer(selectedUnit)
        task.wait(0.3)
        
        -- Try to deploy on a common tile
        local deployArea = Workspace:FindFirstChild("Dark Elixir Cave") or Workspace:FindFirstChild("Map")
        if deployArea then
            local tiles = deployArea:FindFirstChild("BlueTiles") or deployArea:FindFirstChild("Tiles")
            if tiles and tiles:FindFirstChild("Pocket2") then
                local pocket = tiles.Pocket2
                local children = pocket:GetChildren()
                if #children > 0 then
                    Deploy:FireServer(children[math.random(1, #children)])
                    Rayfield:Notify({Title = "✅ Deployed", Content = selectedUnit .. " deployed!", Duration = 3})
                end
            end
        end
    end,
})

DeployTab:CreateButton({
    Name = "Auto Deploy Skeletons (Spam)",
    Callback = function()
        Rayfield:Notify({Title = "Auto Deploy", Content = "Spamming Skeletons...", Duration = 3})
        task.spawn(function()
            for i = 1, 30 do
                ChoseUnit:FireServer("Skeletons")
                task.wait(0.15)
                -- Try deploy
                local pocket = Workspace:FindFirstChild("Dark Elixir Cave") and Workspace["Dark Elixir Cave"]:FindFirstChild("BlueTiles") and Workspace["Dark Elixir Cave"].BlueTiles:FindFirstChild("Pocket2")
                if pocket then
                    local children = pocket:GetChildren()
                    if #children > 0 then
                        Deploy:FireServer(children[math.random(1, #children)])
                    end
                end
                task.wait(0.4)
            end
        end)
    end,
})

-- ==================== COMBAT TAB ====================
CombatTab:CreateSection("⚔️ Combat Features")

CombatTab:CreateButton({
    Name = "Use Attack (Test Position)",
    Callback = function()
        UseAttack:FireServer(
            Vector3.new(-56.2, 12.6, 430.9),
            Vector3.new(-56.2, 12.6, 430.9)
        )
        Rayfield:Notify({Title = "⚔️ Attack", Content = "Attack fired!", Duration = 3})
    end,
})

CombatTab:CreateButton({
    Name = "Vote Cozy Clashmas Arena",
    Callback = function()
        VoteEvent:FireServer("ARENA", "Cozy Clashmas")
        Rayfield:Notify({Title = "🗳️ Vote", Content = "Voted for Cozy Clashmas", Duration = 3})
    end,
})

-- ==================== NOTES TAB ====================
NotesTab:CreateSection("📝 About")
NotesTab:CreateLabel("★ StarCalled Hub")
NotesTab:CreateLabel("Made by: Jayden")
NotesTab:CreateLabel("Game: Clasher Royale")
NotesTab:CreateLabel("Version: 1.1")
local timeLbl = NotesTab:CreateLabel("🕐 Loaded at: " .. os.date("%A %d %B %Y • %H:%M:%S"))

Rayfield:Notify({
    Title = "✅ Clasher Royale Loaded",
    Content = "Team Changer + Deploy + Combat Added!",
    Duration = 5
})
