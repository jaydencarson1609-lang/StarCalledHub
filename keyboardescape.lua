-- ★ StarCalled Hub | +1 Speed Keyboard Escape | Candy & Chocolate

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
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

-- Function to find Win Blocks
local function getWinBlocks()
    local wins = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and 
           (v.Name:lower():find("winblock") or 
            v.Name:lower():find("win") or 
            v.Name:lower():find("finish") or 
            v.Name:lower():find("goal") or 
            v.Name:lower():find("end")) then
            table.insert(wins, v)
        end
    end
    return wins
end

-- ==================== MAIN TAB ====================
MainTab:CreateSection("⚡ Speed & Auto Features")

MainTab:CreateToggle({
    Name = "🔥 Auto Speed (Spam Remote)",
    CurrentValue = false,
    Flag = "AutoSpeed",
    Callback = function(Value)
        autoSpeed = Value
        if Value then
            Rayfield:Notify({Title = "⚡ Auto Speed", Content = "Spamming for max speed gain!", Duration = 3})
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
    Name = "🏃 Auto Walk + Speed",
    CurrentValue = false,
    Flag = "AutoWalk",
    Callback = function(Value)
        autoWalk = Value
        if Value then
            task.spawn(function()
                while autoWalk do
                    UpdateSpeed:FireServer("Walking")
                    local char = player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if root and hum then
                        hum:MoveTo(root.Position + root.CFrame.LookVector * 12)
                    end
                    task.wait(0.08)
                end
            end)
        end
    end,
})

MainTab:CreateButton({
    Name = "💨 Instant Speed Boost",
    Callback = function()
        for i = 1, 50 do
            UpdateSpeed:FireServer("Walking")
        end
        Rayfield:Notify({Title = "Boosted!", Content = "Huge speed increase applied", Duration = 2})
    end,
})

-- ==================== AUTO FARM TAB ====================
AutoFarmTab:CreateSection("🌾 Auto Farm Settings")

local farmStatus = AutoFarmTab:CreateLabel("⚪ Auto Farm: Idle")

AutoFarmTab:CreateToggle({
    Name = "Auto Farm (WinBlock Loop)",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(Value)
        autoFarm = Value
        if Value then
            farmStatus:Set("🟢 Auto Farm: Running")
            Rayfield:Notify({Title = "🌾 Auto Farm", Content = "Started - Looping WinBlocks", Duration = 3})
            
            task.spawn(function()
                while autoFarm do
                    local winBlocks = getWinBlocks()
                    if #winBlocks > 0 then
                        for _, winPart in ipairs(winBlocks) do
                            if not autoFarm then break end
                            
                            local char = player.Character
                            local root = char and char:FindFirstChild("HumanoidRootPart")
                            if root then
                                root.CFrame = winPart.CFrame + Vector3.new(0, 8, 0)
                                farmStatus:Set("🚀 Teleported to: " .. winPart.Name)
                            end
                            task.wait(0.6) -- Adjust timing based on reset speed
                        end
                    else
                        farmStatus:Set("🔍 Searching for WinBlocks...")
                        task.wait(1)
                    end
                    task.wait(0.3)
                end
                farmStatus:Set("⚪ Auto Farm: Idle")
            end)
        else
            farmStatus:Set("⚪ Auto Farm: Idle")
            Rayfield:Notify({Title = "🌾 Auto Farm", Content = "Stopped", Duration = 2})
        end
    end,
})

AutoFarmTab:CreateLabel("ℹ️ The script will repeatedly teleport to WinBlock / Finish parts")
AutoFarmTab:CreateLabel("🔄 Game should reset your progress on touch → farm continues")

-- ==================== MOVEMENT TAB ====================
MovementTab:CreateSection("Movement Hacks")

MovementTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 300},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(Value)
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Value end
    end,
})

MovementTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 400},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(Value)
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = Value end
    end,
})

MovementTab:CreateToggle({
    Name = "Fly (F to toggle in-game)",
    CurrentValue = false,
    Callback = function(Value)
        flying = Value
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
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

                bv.Velocity = dir.Unit * 80
                bg.CFrame = cam.CFrame
                task.wait()
            end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
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
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end,
})

MovementTab:CreateButton({
    Name = "Infinite Jump",
    Callback = function()
        UserInputService.JumpRequest:Connect(function()
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState("Jumping") end
        end)
        Rayfield:Notify({Title = "Infinite Jump", Content = "Enabled", Duration = 3})
    end,
})

-- ==================== TELEPORTS ====================
TeleportTab:CreateSection("Quick Teleports")
TeleportTab:CreateButton({
    Name = "Teleport to Start",
    Callback = function() 
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = CFrame.new(0, 10, 0) end 
    end,
})

-- ==================== NOTES TAB ====================
NotesTab:CreateSection("📝 About")
NotesTab:CreateLabel("★ StarCalled Hub")
NotesTab:CreateLabel("Made by: Jayden")
NotesTab:CreateLabel("Game: +1 Speed Keyboard Escape | Candy & Chocolate")
NotesTab:CreateLabel("Version: 1.3")
local timeLbl = NotesTab:CreateLabel("🕐 Loading...")
local function getTime()
    return os.date("%A %d %B %Y • %H:%M:%S")
end
timeLbl:Set("🕐 Loaded at: " .. getTime())

Rayfield:Notify({
    Title = "⭐ Loaded Successfully",
    Content = "+1 Speed Keyboard Escape | Candy & Chocolate",
    Duration = 5
})
