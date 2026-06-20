-- ★ StarCalled Hub | Build Anything! [🛠️]
-- FIXED BULK DELETE - Replace entire file

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
MainTab:CreateLabel("Main tools coming later...")

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
    Name = "🗑️ DELETE USER",
    Callback = function()
        local username = targetUsername
        if username == "" then
            Rayfield:Notify({Title = "❌ Error", Content = "Type username first", Duration = 3})
            return
        end

        local Built = workspace:FindFirstChild("Built")
        if not Built then return end

        local folder = Built:FindFirstChild(username)
        if not folder then
            Rayfield:Notify({Title = "❌", Content = username .. " has no builds", Duration = 3})
            return
        end

        local Destroy = game:GetService("ReplicatedStorage").Events.DestroyBlock
        local function GetNil(n, id)
            for _, v in ipairs(getnilinstances()) do
                if v.Name == n and v:GetDebugId() == id then return v end
            end
        end

        local count = 0
        for _, block in ipairs(folder:GetDescendants()) do
            if block:IsA("BasePart") then
                pcall(function()
                    local obj = GetNil(block.Name, block:GetDebugId())
                    if obj then
                        Destroy:InvokeServer(obj)
                        count += 1
                    end
                end)
                task.wait(0.15) -- Slower = more reliable
            end
        end

        Rayfield:Notify({Title = "✅ Done", Content = "Deleted " .. count .. " from " .. username, Duration = 5})
    end,
})

TrollsTab:CreateButton({
    Name = "🌍 DELETE EVERYONE'S BUILDS",
    Callback = function()
        Rayfield:Notify({Title = "☢️ MASS DELETE", Content = "Wiping entire server...", Duration = 5})

        local Built = workspace:FindFirstChild("Built")
        if not Built then return end

        local Destroy = game:GetService("ReplicatedStorage").Events.DestroyBlock
        local function GetNil(n, id)
            for _, v in ipairs(getnilinstances()) do
                if v.Name == n and v:GetDebugId() == id then return v end
            end
        end

        local total = 0
        for _, folder in ipairs(Built:GetChildren()) do
            for _, block in ipairs(folder:GetDescendants()) do
                if block:IsA("BasePart") then
                    pcall(function()
                        local obj = GetNil(block.Name, block:GetDebugId())
                        if obj then
                            Destroy:InvokeServer(obj)
                            total += 1
                        end
                    end)
                    task.wait(0.12)
                end
            end
        end

        Rayfield:Notify({Title = "💀 SERVER WIPED", Content = "Deleted " .. total .. " blocks total", Duration = 6})
    end,
})

TrollsTab:CreateButton({
    Name = "🗑️ Delete All My Builds",
    Callback = function()
        game:GetService("ReplicatedStorage").Events.DeleteAllPlayerBlocks:FireServer()
        Rayfield:Notify({Title = "✅", Content = "Your builds cleared", Duration = 3})
    end,
})

TrollsTab:CreateSection("Why it wasn't working")
TrollsTab:CreateLabel("• Bulk delete needs slow speed")
TrollsTab:CreateLabel("• Your single block tool works because it's manual")
TrollsTab:CreateLabel("• YouTuber scripts use the same method but slower")

print("⭐ Build Anything! Troll Script Loaded")
