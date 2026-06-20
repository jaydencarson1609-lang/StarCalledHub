-- ★ StarCalled Hub | Build Anything! [🛠️]
-- FASTER BULK DELETE

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub - Build Anything! 🛠️",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Build Anything!",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

-- MAIN TAB
local MainTab = Window:CreateTab("🛠️ Main", 4483362458)
MainTab:CreateSection("Build System")
MainTab:CreateLabel("Main building tools coming soon...")

-- TROLLS TAB
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
    Name = "🗑️ DELETE USER (Fast)",
    Callback = function()
        local username = targetUsername
        if username == "" or not username then
            Rayfield:Notify({Title = "❌", Content = "Enter username first", Duration = 2})
            return
        end

        Rayfield:Notify({Title = "⚡ FAST DELETE", Content = "Deleting " .. username .. "'s builds...", Duration = 3})

        local Built = workspace:FindFirstChild("Built")
        if not Built then return end

        local targetFolder = Built:FindFirstChild(username)
        if not targetFolder then
            Rayfield:Notify({Title = "❌", Content = username .. " has no builds", Duration = 3})
            return
        end

        local DestroyEvent = game:GetService("ReplicatedStorage").Events.DestroyBlock

        local count = 0
        local blocks = {}
        for _, block in ipairs(targetFolder:GetDescendants()) do
            if block:IsA("BasePart") then
                table.insert(blocks, block)
            end
        end

        for _, block in ipairs(blocks) do
            pcall(function()
                DestroyEvent:InvokeServer(block)
                DestroyEvent:InvokeServer(block)
                count += 1
            end)
            task.wait(0.05) -- Much faster now
        end

        Rayfield:Notify({Title = "✅ Done", Content = "Deleted " .. count .. " blocks from " .. username, Duration = 4})
    end,
})

TrollsTab:CreateButton({
    Name = "🌍 DELETE EVERYONE (Fast)",
    Callback = function()
        Rayfield:Notify({Title = "⚡ MASS FAST DELETE", Content = "Wiping entire server...", Duration = 4})

        local Built = workspace:FindFirstChild("Built")
        if not Built then return end

        local DestroyEvent = game:GetService("ReplicatedStorage").Events.DestroyBlock

        local total = 0
        local allBlocks = {}
        for _, folder in ipairs(Built:GetChildren()) do
            for _, block in ipairs(folder:GetDescendants()) do
                if block:IsA("BasePart") then
                    table.insert(allBlocks, block)
                end
            end
        end

        for _, block in ipairs(allBlocks) do
            pcall(function()
                DestroyEvent:InvokeServer(block)
                DestroyEvent:InvokeServer(block)
                total += 1
            end)
            task.wait(0.045) -- Even faster
        end

        Rayfield:Notify({Title = "💀 SERVER WIPED", Content = "Deleted " .. total .. " blocks", Duration = 5})
    end,
})

TrollsTab:CreateButton({
    Name = "🗑️ Delete All My Builds",
    Callback = function()
        game:GetService("ReplicatedStorage").Events.DeleteAllPlayerBlocks:FireServer()
        Rayfield:Notify({Title = "✅", Content = "Your builds cleared", Duration = 3})
    end,
})

TrollsTab:CreateSection("Tips")
TrollsTab:CreateLabel("Now running at max safe speed")
TrollsTab:CreateLabel("If it skips some blocks, tell me and I'll adjust")

print("⭐ Fast Troll Version Loaded")
