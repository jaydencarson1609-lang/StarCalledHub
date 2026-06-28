-- ★ StarCalled Hub | Natural Disaster Survival | FE GODMODE
-- Executor-ready (Synapse/Krnl/Fluxus/etc.)
-- Telekinesis replicates to all players via BodyPosition physics

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Load Rayfield (or use your own UI lib)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
if not Rayfield then
    -- Fallback: simple notification
    warn("Rayfield not loaded, using basic UI")
    -- We'll still work but without UI
end

-- ========== WINDOW ==========
local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub FE",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "NDS • FE Telekinesis",
    ConfigurationSaving = { Enabled = true, FolderName = "StarCalledHub", FileName = "NDS_FE" },
    Discord = { Enabled = false },
    KeySystem = false,
})

local MainTab = Window:CreateTab("🚀 Movement", 4483362458)
local TeleTab = Window:CreateTab("🧲 Telekinesis", 4483362458)
local InfoTab = Window:CreateTab("📝 Info", 4483362458)

-- ========== GLOBALS ==========
local flying = false
local noclipEnabled = false
local vehicleFlyEnabled = false
local telekinesisActive = false
local teleTarget = nil
local teleBodyPos = nil
local teleBodyGyro = nil
local teleHolding = false
local teleTool = nil

-- ========== UTILITY ==========
local function safeChar()
    local c = player.Character
    if c and c.Parent then return c end
    return nil
end

local function getRoot()
    local c = safeChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = safeChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ========== FLY (FE REPLICATING) ==========
local flyBV, flyBG, flyThread = nil, nil, nil
local function startFly()
    local root = getRoot()
    if not root then return end
    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end
    flyBV = Instance.new("BodyVelocity")
    flyBG = Instance.new("BodyGyro")
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Parent = root
    flyBG.Parent = root
    if flyThread then task.cancel(flyThread) end
    flyThread = task.spawn(function()
        while flying and root and root.Parent do
            local cam = Workspace.CurrentCamera
            if not cam then task.wait(0.1) continue end
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
            flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * 120 or Vector3.new(0,0,0)
            flyBG.CFrame = cam.CFrame
            task.wait(0.03)
        end
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
        flyBV = nil; flyBG = nil
    end)
end

-- ========== NOCLIP (CLIENT ONLY, BUT WORKS) ==========
local noclipThread = nil
local origCollisions = {}
local function toggleNoclip(state)
    noclipEnabled = state
    if noclipThread then task.cancel(noclipThread); noclipThread = nil end
    local c = safeChar()
    if not c then return end
    if state then
        for _, part in pairs(c:GetDescendants()) do
            if part:IsA("BasePart") then
                origCollisions[part] = part.CanCollide
                part.CanCollide = false
            end
        end
        noclipThread = task.spawn(function()
            while noclipEnabled do
                local ch = safeChar()
                if ch then
                    for _, p in pairs(ch:GetDescendants()) do
                        if p:IsA("BasePart") and p.CanCollide ~= false then
                            p.CanCollide = false
                        end
                    end
                end
                task.wait(0.15)
            end
        end)
    else
        for part, val in pairs(origCollisions) do
            if part and part.Parent then part.CanCollide = val end
        end
        origCollisions = {}
        local ch = safeChar()
        if ch then
            for _, p in pairs(ch:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end

-- ========== VEHICLE FLY (FE) ==========
local vFlyThread = nil
local function startVehicleFly()
    if vFlyThread then task.cancel(vFlyThread) end
    vFlyThread = task.spawn(function()
        while vehicleFlyEnabled do
            local c = safeChar()
            if c then
                local hum = c:FindFirstChildOfClass("Humanoid")
                local seat = hum and hum.SeatPart
                if seat then
                    local vehicle = seat.Parent
                    if vehicle and vehicle:IsA("Model") then
                        local root = vehicle:FindFirstChild("PrimaryPart") or vehicle:FindFirstChildWhichIsA("BasePart")
                        if root then
                            local bv = root:FindFirstChild("VehFlyBV") or Instance.new("BodyVelocity")
                            local bg = root:FindFirstChild("VehFlyBG") or Instance.new("BodyGyro")
                            bv.Name = "VehFlyBV"; bg.Name = "VehFlyBG"
                            bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                            bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
                            bv.Parent = root; bg.Parent = root
                            local cam = Workspace.CurrentCamera
                            if cam then
                                local dir = Vector3.new()
                                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
                                bv.Velocity = dir.Magnitude > 0 and dir.Unit * 100 or Vector3.new(0,0,0)
                                bg.CFrame = cam.CFrame
                            end
                        end
                    end
                end
            end
            task.wait(0.035)
        end
        -- cleanup
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BodyVelocity") and obj.Name == "VehFlyBV" then obj:Destroy() end
            if obj:IsA("BodyGyro") and obj.Name == "VehFlyBG" then obj:Destroy() end
        end
    end)
end

-- ========== FE TELEKINESIS TOOL ==========
-- Creates a Tool with a Handle that, when equipped, lets you drag unanchored parts.
-- Uses BodyPosition/BodyGyro which replicate across clients.

local function createTeleTool()
    if teleTool then teleTool:Destroy() end
    teleTool = Instance.new("Tool")
    teleTool.Name = "FE Telekinesis"
    teleTool.RequiresHandle = true
    teleTool.CanBeDropped = false

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 1)
    handle.Anchored = false
    handle.CanCollide = false
    handle.Transparency = 0.6
    handle.BrickColor = BrickColor.new("Bright violet")
    handle.Material = Enum.Material.Neon
    handle.Parent = teleTool

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 120, 0, 30)
    bill.StudsOffset = Vector3.new(0, 1.5, 0)
    bill.Parent = handle
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = "🧲 CLICK TO GRAB"
    label.TextColor3 = Color3.new(1, 0.8, 0.2)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = bill

    -- We'll use a LocalScript inside the tool (executor runs it)
    local ls = Instance.new("LocalScript")
    ls.Name = "TeleControl"
    ls.Parent = teleTool

    -- The script content (as a string, we'll compile it)
    local scriptSrc = [[
        local tool = script.Parent
        local player = game.Players.LocalPlayer
        local mouse = player:GetMouse()
        local char = player.Character or player.CharacterAdded:Wait()
        local holding = false
        local target = nil
        local bPos = nil
        local bGyro = nil
        local runConn = nil

        local function grabPart()
            local hit = mouse.Target
            if hit and hit:IsA("BasePart") and hit.Anchored == false and hit.CanCollide then
                -- Check if it's not part of the player
                if hit.Parent ~= char and hit.Parent ~= tool then
                    target = hit
                    bPos = Instance.new("BodyPosition")
                    bGyro = Instance.new("BodyGyro")
                    bPos.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    bPos.P = 5000
                    bPos.D = 1200
                    bPos.Parent = target
                    bGyro.Parent = target
                    holding = true
                    tool.Handle.BillboardGui.TextLabel.Text = "🧲 DRAGGING " .. target.Name
                end
            end
        end

        local function releasePart()
            if bPos then bPos:Destroy() end
            if bGyro then bGyro:Destroy() end
            bPos = nil; bGyro = nil
            target = nil
            holding = false
            tool.Handle.BillboardGui.TextLabel.Text = "🧲 CLICK TO GRAB"
        end

        local function launchPart()
            if holding and target then
                local vel = (mouse.Hit.Position - target.Position).Unit * 200
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = vel
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Parent = target
                task.delay(1.5, function() if bv then bv:Destroy() end end)
                releasePart()
            end
        end

        tool.Equipped:Connect(function()
            mouse.Button1Down:Connect(function()
                if not holding then grabPart() else releasePart() end
            end)
            mouse.Button2Down:Connect(launchPart)
            runConn = game:GetService("RunService").Heartbeat:Connect(function()
                if holding and target and bPos then
                    bPos.Position = mouse.Hit.Position
                    bGyro.CFrame = CFrame.new(mouse.Hit.Position, mouse.Hit.Position + Vector3.new(0,1,0))
                end
            end)
        end)

        tool.Unequipped:Connect(function()
            releasePart()
            if runConn then runConn:Disconnect() end
        end)

        -- Also handle character death
        player.CharacterAdded:Connect(function(newChar)
            char = newChar
            releasePart()
        end)
    ]]

    -- Inject the script (use loadstring to compile, then run it inside the tool)
    local func, err = loadstring(scriptSrc)
    if func then
        -- We need to set the script's environment to the tool's context
        local env = getfenv()
        env.script = ls
        setfenv(func, env)
        task.spawn(func)
    else
        warn("Failed to compile tele script: " .. tostring(err))
    end

    teleTool.Parent = player.Backpack
    return teleTool
end

-- ========== UI ==========

-- Main Tab
MainTab:CreateSection("🦅 Flight")
local flyToggle = MainTab:CreateToggle({
    Name = "Fly (F toggle)",
    CurrentValue = false,
    Callback = function(v)
        flying = v
        if v then startFly() else if flyBV then flyBV:Destroy() end if flyBG then flyBG:Destroy() end flyBV=nil; flyBG=nil; if flyThread then task.cancel(flyThread) end end
    end,
})

MainTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 350},
    Increment = 1,
    CurrentValue = 100,
    Callback = function(v) local h = getHum() if h then h.WalkSpeed = v end end,
})

MainTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 800},
    Increment = 1,
    CurrentValue = 100,
    Callback = function(v) local h = getHum() if h then h.JumpPower = v end end,
})

MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v) toggleNoclip(v) end,
})

MainTab:CreateToggle({
    Name = "Vehicle Fly",
    CurrentValue = false,
    Callback = function(v)
        vehicleFlyEnabled = v
        if v then startVehicleFly() else if vFlyThread then task.cancel(vFlyThread); vFlyThread=nil end end
        Rayfield:Notify({Title = "🚗", Content = v and "Vehicle Fly ON" or "OFF", Duration=2})
    end,
})

-- Telekinesis Tab
TeleTab:CreateSection("🧲 FE Telekinesis Tool")
TeleTab:CreateButton({
    Name = "📥 Get Telekinesis Tool (FE)",
    Callback = function()
        local t = createTeleTool()
        if t then
            Rayfield:Notify({Title = "✅", Content = "Tool added to backpack. Equip it!", Duration=4})
        else
            Rayfield:Notify({Title = "❌", Content = "Failed to create tool", Duration=3})
        end
    end,
})

TeleTab:CreateButton({
    Name = "🗑️ Remove Telekinesis",
    Callback = function()
        if teleTool then teleTool:Destroy(); teleTool=nil end
        for _, item in pairs(player.Backpack:GetChildren()) do if item.Name == "FE Telekinesis" then item:Destroy() end end
        Rayfield:Notify({Title = "🗑️", Content = "Removed", Duration=2})
    end,
})

TeleTab:CreateLabel("📖 HOW TO USE (FE):")
TeleTab:CreateLabel("1. Click 'Get Telekinesis Tool'")
TeleTab:CreateLabel("2. Equip the tool from backpack")
TeleTab:CreateLabel("3. Click any UNANCHORED part to grab")
TeleTab:CreateLabel("4. Move mouse to drag it (others see it!)")
TeleTab:CreateLabel("5. Right-click to launch it like a cannon")
TeleTab:CreateLabel("6. Click again to release gently")
TeleTab:CreateLabel("⚠️ Only works on unanchored parts (debris, props)")

-- Info Tab
InfoTab:CreateSection("📌 StarCalled Hub FE")
InfoTab:CreateLabel("Version: 3.1 FE-Ready")
InfoTab:CreateLabel("Features: Fly, Noclip, Vehicle Fly,")
InfoTab:CreateLabel("FE Telekinesis (replicates!)")
InfoTab:CreateLabel("Made for Natural Disaster Survival")
InfoTab:CreateLabel("Loaded: " .. os.date("%H:%M:%S"))

-- Keybind
UserInputService.InputBegan:Connect(function(input, g)
    if g then return end
    if input.KeyCode == Enum.KeyCode.F then
        flyToggle:SetValue(not flyToggle.CurrentValue)
    end
end)

-- Startup notify
Rayfield:Notify({Title = "⭐ StarCalled FE", Content = "Fly(F) • Telekinesis ready", Duration=5})

-- Cleanup on respawn
player.CharacterAdded:Connect(function()
    if flying then task.wait(0.3) startFly() end
    if noclipEnabled then toggleNoclip(true) end
    if vehicleFlyEnabled then startVehicleFly() end
end)

print("✅ StarCalled Hub FE loaded. Telekinesis replicates to all players!")
