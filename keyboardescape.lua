-- ★ StarCalled Hub | +1 Speed Keyboard Escape | Candy & Chocolate

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "+1 Speed Keyboard Escape | Candy & Chocolate",
    ConfigurationSaving = { Enabled = true, FolderName = "StarCalledHub", FileName = "KeyboardEscape" },
    Discord = { Enabled = false },
    KeySystem = false,
})

local MainTab = Window:CreateTab("🏠 Main", 4483362458)
local MovementTab = Window:CreateTab("🏃 Movement", 4483362458)
local AutoFarmTab = Window:CreateTab("🌾 Auto Farm", 4483362458)
local TeleportTab = Window:CreateTab("📍 Teleports", 4483362458)
local NotesTab = Window:CreateTab("📝 Notes", 4483362458)

-- Remote
local UpdateSpeed = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpdateSpeed")

-- Variables
local autoSpeed = false
local autoWalk = false
local autoFarm = false
local noclip = false
local flying = false
local godmode = false

-- Find Win Blocks (safer version)
local function getWinBlocks()
    local wins = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and 
           (v.Name:lower():find("winblock") or v.Name:lower():find("win") or 
            v.Name:lower():find("finish") or v.Name:lower():find("goal") or 
            v.Name:lower():find("end")) then
            table.insert(wins, v)
        end
    end
    return wins
end

-- ==================== ANTI-DEATH (Godmode) ====================
local function enableGodmode()
    godmode = true
    task.spawn(function()
        while godmode do
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Health = hum.MaxHealth
                    hum.MaxHealth = 99999
                end
                -- ForceField
                if not char:FindFirstChild("ForceField") then
                    local ff = Instance.new("ForceField")
                    ff.Parent = char
                end
            end
            task.wait(0.1)
        end
    end)
end

-- ==================== MAIN TAB ====================
MainTab:CreateSection("⚡ Speed & Protection")

MainTab:CreateToggle({
    Name = "🔥 Auto Speed (Spam Remote)",
    CurrentValue = false,
    Callback = function(Value)
        autoSpeed = Value
        if Value then
            task.spawn(function()
                while autoSpeed do
                    UpdateSpeed:FireServer("Walking")
                    task.wait(0.025)
                end
            end)
        end
    end,
})

MainTab:CreateToggle({
    Name = "🛡️ Godmode / Anti-Death",
    CurrentValue = false,
    Callback = function(Value)
        godmode = Value
        if Value then
            enableGodmode()
            Rayfield:Notify({Title = "🛡️ Godmode", Content = "Enabled - You should no longer die to bosses", Duration = 4})
        else
            Rayfield:Notify({Title = "🛡️ Godmode", Content = "Disabled", Duration = 2})
        end
    end,
})

MainTab:CreateButton({
    Name = "💨 Instant Speed Boost",
    Callback = function()
        for i = 1, 50 do UpdateSpeed:FireServer("Walking") end
        Rayfield:Notify({Title = "Boosted!", Content = "Huge speed increase", Duration = 2})
    end,
})

-- ==================== AUTO FARM TAB ====================
AutoFarmTab:CreateSection("🌾 Auto Farm (Improved)")

local farmStatus = AutoFarmTab:CreateLabel("⚪ Auto Farm: Idle")

AutoFarmTab:CreateToggle({
    Name = "Auto Farm (WinBlock Loop + Safer)",
    CurrentValue = false,
    Callback = function(Value)
        autoFarm = Value
        if Value then
            farmStatus:Set("🟢 Running (Safer Mode)")
            Rayfield:Notify({Title = "🌾 Auto Farm", Content = "Started - Avoiding instant boss death", Duration = 3})
            
            task.spawn(function()
                while autoFarm do
                    local winBlocks = getWinBlocks()
                    if #winBlocks > 0 then
                        -- Pick random win block but with delay
                        local winPart = winBlocks[math.random(1, #winBlocks)]
                        local char = player.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.CFrame = winPart.CFrame + Vector3.new(0, 10, 0) -- Higher up to avoid direct touch issues
                            farmStatus:Set("🚀 TP to: " .. winPart.Name)
                        end
                    else
                        farmStatus:Set("🔍 Searching for WinBlocks...")
                    end
                    task.wait(1.2) -- Longer delay = less buggy
                end
                farmStatus:Set("⚪ Auto Farm: Idle")
            end)
        else
            farmStatus:Set("⚪ Auto Farm: Idle")
        end
    end,
})

AutoFarmTab:CreateLabel("ℹ️ Safer delays + Godmode recommended to survive bosses")

-- ==================== MOVEMENT TAB ====================
MovementTab:CreateSection("Movement Hacks")

MovementTab:CreateSlider({
    Name = "WalkSpeed", Range = {16, 400}, Increment = 1, CurrentValue = 60,
    Callback = function(v)
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end,
})

MovementTab:CreateToggle({
    Name = "Fly (Press F to toggle)",
    CurrentValue = false,
    Callback = function(Value)
        flying = Value
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local bv = Instance.new("BodyVelocity")
        local bg = Instance.new("BodyGyro")
        bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
        bv.Parent = root
        bg.Parent = root

        task.spawn(function()
            while flying do
                local cam = workspace.CurrentCamera
                local dir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

                bv.Velocity = dir.Unit * 90
                bg.CFrame = cam.CFrame
                task.wait()
            end
            bv:Destroy()
            bg:Destroy()
        end)
    end,
})

MovementTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value)
        noclip = Value
        task.spawn(function()
            while noclip do
                local char = player.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
                task.wait(0.1)
            end
        end)
    end,
})

-- ==================== NOTES TAB ====================
NotesTab:CreateSection("📝 About")
NotesTab:CreateLabel("★ StarCalled Hub")
NotesTab:CreateLabel("Made by: Jayden")
NotesTab:CreateLabel("Game: +1 Speed Keyboard Escape | Candy & Chocolate")
NotesTab:CreateLabel("Version: 1.4 - Anti-Boss Edition")
local timeLbl = NotesTab:CreateLabel("🕐 Loading...")
timeLbl:Set("🕐 Loaded at: " .. os.date("%A %d %B %Y • %H:%M:%S"))

Rayfield:Notify({Title = "✅ Updated", Content = "Anti-Death + Safer Auto Farm Added!", Duration = 5})
