-- ★ StarCalled Hub | Build Anything! [🛠️]

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub - Build Anything! 🛠️",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Build Anything!",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

local MainTab = Window:CreateTab("🛠️ Main", 4483362458)
MainTab:CreateSection("Build System")
MainTab:CreateLabel("Main tools coming soon...")

local TrollsTab = Window:CreateTab("😈 Trolls", 4483362458)
TrollsTab:CreateSection("Troll Controls")

local targetUsername = ""

TrollsTab:CreateInput({
    Name = "Delete Specific User's Builds",
    PlaceholderText = "Type username here",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        targetUsername = text
    end,
})

TrollsTab:CreateButton({
    Name = "🗑️ DELETE USER",
    Callback = function()
        local username = targetUsername
        if username == "" or not username then return end

        local Built = workspace:FindFirstChild("Built")
        if not Built then return end

        local targetFolder = Built:FindFirstChild(username)
        if not targetFolder then return end

        local Event = game:GetService("ReplicatedStorage").Events.DestroyBlock

        for _, block in ipairs(targetFolder:GetDescendants()) do
            if block:IsA("BasePart") then
                pcall(function()
                    Event:InvokeServer(block)
                end)
                task.wait(0.01)
            end
        end
    end,
})

TrollsTab:CreateButton({
    Name = "🌍 DELETE EVERYONE",
    Callback = function()
        local Built = workspace:FindFirstChild("Built")
        if not Built then return end

        local Event = game:GetService("ReplicatedStorage").Events.DestroyBlock

        for _, folder in ipairs(Built:GetChildren()) do
            for _, block in ipairs(folder:GetDescendants()) do
                if block:IsA("BasePart") then
                    pcall(function()
                        Event:InvokeServer(block)
                    end)
                    task.wait(0.008)
                end
            end
        end
    end,
})

TrollsTab:CreateButton({
    Name = "🗑️ Delete All My Builds",
    Callback = function()
        game:GetService("ReplicatedStorage").Events.DeleteAllPlayerBlocks:FireServer()
    end,
})

print("⭐ Script Loaded")
