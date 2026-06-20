-- ★ StarCalled Hub | Build Anything! [🛠️]

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub - Build Anything! 🛠️",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Build Anything!",
    ConfigurationSaving = { Enabled = true, FolderName = "StarCalledHub", FileName = "BuildAnything" },
    Discord = { Enabled = false },
    KeySystem = false,
})

-- ==================== MAIN TAB ====================
local MainTab = Window:CreateTab("🛠️ Main", 4483362458)
MainTab:CreateSection("Build Tools")
MainTab:CreateLabel("Main building features coming soon...")

-- ==================== TROLLS TAB ====================
local TrollsTab = Window:CreateTab("😈 Trolls", 4483362458)

local targetUsername = ""

TrollsTab:CreateSection("Troll Controls")

TrollsTab:CreateInput({
    Name = "Delete Specific User's Builds",
    PlaceholderText = "Type username here (e.g. Chiksa801)",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        targetUsername = text
    end,
})

TrollsTab:CreateButton({
    Name = "🗑️ DELETE",
    Callback = function()
        local username = targetUsername
        if not username or username == "" then
            Rayfield:Notify({Title = "❌ Error", Content = "Please type a username first", Duration = 3})
            return
        end
        
        Rayfield:Notify({Title = "🔥 Deleting", Content = "Targeting " .. username .. "'s builds...", Duration = 3})
        
        local Built = workspace:FindFirstChild("Built")
        if not Built then
            Rayfield:Notify({Title = "❌ Error", Content = "Built folder not found", Duration = 3})
            return
        end
        
        local targetFolder = Built:FindFirstChild(username)
        if not targetFolder then
            Rayfield:Notify({Title = "❌ Not Found", Content = "No builds found for " .. username, Duration = 4})
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
            if block:IsA("BasePart") then
                pcall(function()
                    local nilObj = GetNil(block.Name, block:GetDebugId())
                    if nilObj then
                        DestroyEvent:InvokeServer(nilObj)
                        count += 1
                    end
                end)
                task.wait(0.03)
            end
        end
        
        Rayfield:Notify({Title = "✅ Troll Success", Content = "Deleted " .. count .. " blocks from " .. username, Duration = 4})
    end,
})

TrollsTab:CreateButton({
    Name = "🗑️ Delete All My Builds",
    Callback = function()
        pcall(function()
            game:GetService("ReplicatedStorage").Events.DeleteAllPlayerBlocks:FireServer()
        end)
        Rayfield:Notify({Title = "🗑️ Cleared", Content = "All of your builds have been deleted", Duration = 3})
    end,
})

TrollsTab:CreateSection("Tips")
TrollsTab:CreateLabel("Type exact username from Built folder")
TrollsTab:CreateLabel("Works on visible player builds")

print("⭐ StarCalled Hub - Build Anything! Loaded Successfully!")
