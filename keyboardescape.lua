-- ★ StarCalled Hub | +1 Speed Keyboard Escape | Candy & Chocolate

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

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
local NotesTab = Window:CreateTab("📝 Notes", 4483362458)

-- Remote
local UpdateSpeed = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpdateSpeed")

-- Variables
local autoSpeed = false
local autoWalk = false

-- ==================== MAIN TAB ====================
MainTab:CreateSection("⚡ Speed Features")

MainTab:CreateToggle({
    Name = "Auto Speed (Spam Walking Remote)",
    CurrentValue = false,
    Flag = "AutoSpeed",
    Callback = function(Value)
        autoSpeed = Value
        if Value then
            Rayfield:Notify({Title = "⚡ Auto Speed", Content = "Enabled - Spamming speed remote", Duration = 3})
            task.spawn(function()
                while autoSpeed do
                    UpdateSpeed:FireServer("Walking")
                    task.wait(0.03) -- Fast spam for max speed gain
                end
            end)
        else
            Rayfield:Notify({Title = "⚡ Auto Speed", Content = "Disabled", Duration = 2})
        end
    end,
})

MainTab:CreateToggle({
    Name = "Auto Walk + Speed",
    CurrentValue = false,
    Flag = "AutoWalk",
    Callback = function(Value)
        autoWalk = Value
        if Value then
            Rayfield:Notify({Title = "🏃 Auto Walk", Content = "Started", Duration = 3})
            task.spawn(function()
                while autoWalk do
                    UpdateSpeed:FireServer("Walking")
                    local character = player.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:MoveTo(character.HumanoidRootPart.Position + character.HumanoidRootPart.CFrame.LookVector * 8)
                    end
                    task.wait(0.1)
                end
            end)
        else
            Rayfield:Notify({Title = "🏃 Auto Walk", Content = "Stopped", Duration = 2})
        end
    end,
})

MainTab:CreateButton({
    Name = "Manual Speed Boost",
    Callback = function()
        for i = 1, 30 do
            UpdateSpeed:FireServer("Walking")
        end
        Rayfield:Notify({Title = "⚡ Boost", Content = "Speed boosted!", Duration = 2})
    end,
})

MainTab:CreateSection("🛠 Other Features")

MainTab:CreateToggle({
    Name = "Fly (Press F to toggle)",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        -- Basic Fly Script
        local character = player.Character
        if not character then return end
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local bv = Instance.new("BodyVelocity")
        local bg = Instance.new("BodyGyro")
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bv.Parent = root
        bg.Parent = root

        local flying = Value
        local uis = game:GetService("UserInputService")
        local cam = workspace.CurrentCamera

        uis.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.F then
                flying = not flying
            end
        end)

        task.spawn(function()
            while flying do
                local dir = Vector3.new()
                if uis:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end

                bv.Velocity = dir.Unit * 80
                bg.CFrame = cam.CFrame
                task.wait()
            end
            bv:Destroy()
            bg:Destroy()
        end)
    end,
})

MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value)
        local character = player.Character
        if not character then return end
        task.spawn(function()
            while Value do
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                task.wait(0.1)
            end
            -- Reset on disable
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end)
    end,
})

-- ==================== NOTES TAB ====================
NotesTab:CreateSection("📝 About")
NotesTab:CreateLabel("★ StarCalled Hub")
NotesTab:CreateLabel("Made by: Jayden")
NotesTab:CreateLabel("Game: +1 Speed Keyboard Escape | Candy & Chocolate")
NotesTab:CreateLabel("Version: 1.0")
local timeLbl = NotesTab:CreateLabel("🕐 Loading time...")
local function getTime()
    return os.date("%A %d %B %Y • %H:%M:%S")
end
timeLbl:Set("🕐 Loaded at: " .. getTime())

Rayfield:Notify({
    Title = "⭐ StarCalled Hub",
    Content = "+1 Speed Keyboard Escape Loaded Successfully!",
    Duration = 5
})
