-- ✅ Baby Pursuers (Era 2) AUTOFARM - Fixed for Q Grab
-- Uses simulated Q press for proper grab/drop (matches game controls)
-- Auto cycle: Find baby → Teleport → Grab (Q) → Drop at target → Repeat

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

local TARGET_POS = Vector3.new(-203, 31, 316)  -- Update if needed
local holdingBaby = false
local currentBaby = nil
local scriptEnabled = true
local isAutoFarming = false
local babiesDropped = 0

-- ============== HUD ==============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BabyPursuersAutofarm"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 380, 0, 270)
frame.Position = UDim2.new(0.5, -190, 0.08, 0)
frame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "🍼 BABY PURSUERS AUTOFARM"
title.TextColor3 = Color3.fromRGB(255, 45, 45)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 65)
status.Position = UDim2.new(0, 0, 0, 50)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.TextScaled = true
status.Font = Enum.Font.GothamSemibold
status.Text = "Ready - Press T to Start"
status.Parent = frame

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, 0, 0, 30)
statsLabel.Position = UDim2.new(0, 0, 0, 115)
statsLabel.BackgroundTransparency = 1
statsLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
statsLabel.TextScaled = true
statsLabel.Font = Enum.Font.Gotham
statsLabel.Text = "Babies Dropped: 0"
statsLabel.Parent = frame

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, 0, 0, 30)
hint.Position = UDim2.new(0, 0, 0, 145)
hint.BackgroundTransparency = 1
hint.TextColor3 = Color3.fromRGB(180, 180, 180)
hint.TextScaled = true
hint.Font = Enum.Font.Gotham
hint.Text = "E = Manual | T = Toggle Auto | Uses Q Grab"
hint.Parent = frame

-- Buttons
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 48)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 180)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
toggleBtn.Text = "▶ START AUTOFARM"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.9, 0, 0, 38)
stopBtn.Position = UDim2.new(0.05, 0, 0, 235)
stopBtn.BackgroundColor3 = Color3.fromRGB(190, 40, 40)
stopBtn.Text = "🛑 STOP EVERYTHING"
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.TextScaled = true
stopBtn.Font = Enum.Font.GothamBold
stopBtn.Parent = frame
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 10)

-- Simulate Q key press (for grab/drop)
local function pressQ()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    task.wait(0.08)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    task.wait(0.12)
end

-- Find nearest valid baby
local function findNearestBaby()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil, nil end
    local myPos = char.HumanoidRootPart.Position

    local bestBaby, bestDist = nil, math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("^baby") then
            local wanderScript = obj:FindFirstChild("Wander") or obj:FindFirstChildWhichIsA("Script")
            if wanderScript and (wanderScript.Name == "Wander" or wanderScript.Name:lower():find("wander")) then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                if root then
                    local dist = (root.Position - myPos).Magnitude
                    if dist < bestDist and dist < 750 then
                        bestDist = dist
                        bestBaby = obj
                    end
                end
            end
        end
    end
    if bestBaby then
        return bestBaby, bestBaby:FindFirstChild("HumanoidRootPart") or bestBaby:FindFirstChildWhichIsA("BasePart")
    end
    return nil, nil
end

-- Fast teleport
local function fastTeleport(pos)
    local char = player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    root.CFrame = CFrame.new(pos + Vector3.new(0, 5.5, 0))
    return true
end

-- Attempt to grab baby using Q
local function attemptGrab(babyModel, babyRoot)
    if not babyModel or not babyRoot then return false end

    fastTeleport(babyRoot.Position)
    task.wait(0.25)
    
    pressQ()  -- Grab with Q
    task.wait(0.2)

    -- Check if we are now holding (simple check)
    local char = player.Character
    if char and babyModel.Parent == char then
        currentBaby = babyModel
        holdingBaby = true
        return true
    end
    return false
end

-- Drop using Q
local function dropBaby()
    if not currentBaby then return end

    fastTeleport(TARGET_POS)
    task.wait(0.35)
    
    pressQ()  -- Drop with Q
    task.wait(0.3)

    currentBaby:PivotTo(CFrame.new(TARGET_POS + Vector3.new(0, 4, 0))) -- extra safety

    holdingBaby = false
    currentBaby = nil
    babiesDropped += 1
    statsLabel.Text = "Babies Dropped: " .. babiesDropped
end

-- One full cycle
local function doOneCycle()
    if not scriptEnabled then return end

    if holdingBaby then
        status.Text = "Holding → Dropping..."
        dropBaby()
        status.Text = "✅ Dropped! Next..."
        task.wait(0.6)
        return
    end

    local babyModel, babyRoot = findNearestBaby()
    if not babyModel then
        status.Text = "Searching for babies..."
        return
    end

    status.Text = "Found baby → Grabbing..."
    local success = attemptGrab(babyModel, babyRoot)

    if success then
        status.Text = "✅ Grabbed → Dropping"
        task.wait(0.3)
        dropBaby()
        status.Text = "✅ Cycle complete!"
    else
        status.Text = "Grab failed → Skipping"
        task.wait(0.9)
    end
end

-- Auto loop
local function autoFarmLoop()
    if isAutoFarming then return end
    isAutoFarming = true
    toggleBtn.Text = "⏹ STOP AUTOFARM"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(190, 40, 40)

    while scriptEnabled and isAutoFarming do
        doOneCycle()
        task.wait(0.5)
    end

    isAutoFarming = false
    toggleBtn.Text = "▶ START AUTOFARM"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
end

-- Manual E
UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not scriptEnabled then return end
    if input.KeyCode == Enum.KeyCode.E then
        doOneCycle()
    end
end)

-- Toggle T / Button
local function toggleAuto()
    if isAutoFarming then
        isAutoFarming = false
        status.Text = "Auto paused"
    else
        task.spawn(autoFarmLoop)
        status.Text = "Auto farming..."
    end
end

toggleBtn.MouseButton1Click:Connect(toggleAuto)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not scriptEnabled then return end
    if input.KeyCode == Enum.KeyCode.T then
        toggleAuto()
    end
end)

-- Full stop
stopBtn.MouseButton1Click:Connect(function()
    scriptEnabled = false
    isAutoFarming = false
    status.Text = "🛑 STOPPED"
    title.Text = "BABY PURSUERS AUTOFARM [DISABLED]"
    print("Autofarm fully stopped.")
end)

print("✅ Baby Pursuers (Era 2) Autofarm Loaded!")
print("T = Toggle Auto | E = Manual Cycle | Uses proper Q grab")
status.Text = "Ready - Press T to start autofarm"
