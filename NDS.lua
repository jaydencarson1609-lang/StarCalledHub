-- ★ StarCalled Hub | Natural Disaster Survival

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Natural Disaster Survival",
    ConfigurationSaving = { Enabled = true, FolderName = "StarCalledHub", FileName = "NDS_Config" },
    Discord = { Enabled = false },
    KeySystem = false,
})

local MainTab = Window:CreateTab("🏠 Main", 4483362458)
local NotesTab = Window:CreateTab("📝 Notes", 4483362458)

-- Variables
local flying = false
local noclip = false
local vehicleFlying = false

-- ==================== MAIN TAB ====================
MainTab:CreateSection("🚀 Movement Features")

-- Fly
MainTab:CreateToggle({
    Name = "Fly (Press F to toggle)",
    CurrentValue = false,
    Callback = function(Value)
        flying = Value
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local bv = Instance.new("BodyVelocity")
        local bg = Instance.new("BodyGyro")
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bv.Parent = root
        bg.Parent = root

        task.spawn(function()
            while flying do
                local cam = Workspace.CurrentCamera
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
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end)
    end,
})

-- WalkSpeed
MainTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 9999999999},
    Increment = 1,
    CurrentValue = 100,
    Callback = function(Value)
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Value end
    end,
})

-- JumpPower
MainTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 9999999999},
    Increment = 1,
    CurrentValue = 100,
    Callback = function(Value)
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = Value end
    end,
})

-- Noclip
MainTab:CreateToggle({
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
            -- Reset when disabled
            local char = player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end)
    end,
})

-- Vehicle Fly
MainTab:CreateToggle({
    Name = "Vehicle Fly",
    CurrentValue = false,
    Callback = function(Value)
        vehicleFlying = Value
        Rayfield:Notify({Title = "🛻 Vehicle Fly", Content = Value and "Enabled - Enter any vehicle to fly" or "Disabled", Duration = 3})
        
        if Value then
            task.spawn(function()
                while vehicleFlying do
                    local char = player.Character
                    if char then
                        local vehicle = char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart and char.Humanoid.SeatPart.Parent
                        if vehicle then
                            local root = vehicle:FindFirstChild("Body") or vehicle:FindFirstChild("PrimaryPart") or char:FindFirstChild("HumanoidRootPart")
                            if root then
                                local bv = root:FindFirstChild("BodyVelocity") or Instance.new("BodyVelocity")
                                local bg = root:FindFirstChild("BodyGyro") or Instance.new("BodyGyro")
                                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                                bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                                bv.Parent = root
                                bg.Parent = root

                                local cam = Workspace.CurrentCamera
                                local dir = Vector3.new()
                                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

                                bv.Velocity = dir.Unit * 80
                                bg.CFrame = cam.CFrame
                            end
                        end
                    end
                    task.wait()
                end
            end)
        end
    end,
})

-- ==================== NOTES TAB ====================
NotesTab:CreateSection("📝 About")
NotesTab:CreateLabel("★ StarCalled Hub")
NotesTab:CreateLabel("Made by: Jayden")
NotesTab:CreateLabel("Game: Natural Disaster Survival")
NotesTab:CreateLabel("Version: 1.0")
local timeLbl = NotesTab:CreateLabel("🕐 Loaded at: " .. os.date("%A %d %B %Y • %H:%M:%S"))

Rayfield:Notify({
    Title = "⭐ NDS Script Loaded",
    Content = "Fly, God Speed, Noclip & Vehicle Fly Added!",
    Duration = 6
})
