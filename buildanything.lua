-- ★ StarCalled Hub | Build Anything! [🛠️]
-- FULLY UPDATED - Replace everything

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub - Build Anything! 🛠️",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Build Anything!",
    ConfigurationSaving = { Enabled = false }, -- Disabled to force fresh UI
    Discord = { Enabled = false },
    KeySystem = false,
})

-- ==================== MAIN TAB ====================
local MainTab = Window:CreateTab("🛠️ Main", 4483362458)
MainTab:CreateSection("Build System")
MainTab:CreateLabel("Main building tools coming soon...")

-- ==================== TROLLS TAB ====================
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
    Name = "🗑️ DELETE",
    Callback = function()
        local username = targetUsername
        if username == "" or not username then
            Rayfield:Notify({Title = "❌ Error", Content = "Enter a username first!", Duration = 3})
            return
        end

        Rayfield:Notify({Title = "🔥 Trolling...", Content = "Deleting " .. username .. "'s builds...", Duration = 3})

        local Built = workspace:FindFirstChild("Built")
        if not Built then
            Rayfield:Notify({Title = "❌ Error", Content = "Built folder not found", Duration = 3})
            return
        end

        local targetFolder = Built:FindFirstChild(username)
        if not targetFolder then
            Rayfield:Notify({Title = "❌ Not Found", Content = username .. " has no builds here", Duration = 4})
            return
        end

        local DestroyEvent = game:GetService("ReplicatedStorage").Events.DestroyBlock

        local function GetNil(Name, DebugId)
            for _, obj in ipairs(getnilinstances()) do
                if obj.Name == Name and obj:GetDebugId() == DebugId then
                    return obj
                end
            end
        end

        local count = 0
        for _, block in ipairs(targetFolder:GetDescendants()) do
            if block:IsA("BasePart") or block:IsA("Model") then
                pcall(function()
                    local nilObj = GetNil(block.Name, block:GetDebugId())
                    if nilObj then
                        DestroyEvent:InvokeServer(nilObj)
                        count += 1
                    end
                end)
                task.wait(0.1) -- Slower for better reliability
            end
        end

        Rayfield:Notify({Title = "✅ Troll Complete", Content = "Deleted " .. count .. " blocks from " .. username, Duration = 5})
    end,
})

TrollsTab:CreateButton({
    Name = "🌍 Delete EVERYONE's Builds",
    Callback = function()
        Rayfield:Notify({Title = "☢️ Mass Troll", Content = "Deleting ALL builds...", Duration = 4})

        local Built = workspace:FindFirstChild("Built")
        if not Built then return end

        local DestroyEvent = game:GetService("ReplicatedStorage").Events.DestroyBlock

        local function GetNil(Name, DebugId)
            for _, obj in ipairs(getnilinstances()) do
                if obj.Name == Name and obj:GetDebugId() == DebugId then
                    return obj
                end
            end
        end

        local total = 0
        for _, playerFolder in ipairs(Built:GetChildren()) do
            for _, block in ipairs(playerFolder:GetDescendants()) do
                if block:IsA("BasePart") or block:IsA("Model") then
                    pcall(function()
                        local nilObj = GetNil(block.Name, block:GetDebugId())
                        if nilObj then
                            DestroyEvent:InvokeServer(nilObj)
                            total += 1
                        end
                    end)
                    task.wait(0.08)
                end
            end
        end

        Rayfield:Notify({Title = "💀 Server Wiped", Content = "Deleted " .. total .. " blocks", Duration = 6})
    end,
})

TrollsTab:CreateButton({
    Name = "🗑️ Delete All My Builds",
    Callback = function()
        pcall(function()
            game:GetService("ReplicatedStorage").Events.DeleteAllPlayerBlocks:FireServer()
        end)
        Rayfield:Notify({Title = "🗑️ Cleared", Content = "All your builds deleted", Duration = 3})
    end,
})

TrollsTab:CreateSection("Tips")
TrollsTab:CreateLabel("Type exact username from Built folder")
TrollsTab:CreateLabel("Slower speed = higher success rate")

print("⭐ StarCalled Hub - Build Anything! Loaded Successfully!")
