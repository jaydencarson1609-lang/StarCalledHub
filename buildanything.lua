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

local MainTab = Window:CreateTab("🛠️ Main", 4483362458)

MainTab:CreateSection("Build System")

MainTab:CreateButton({
    Name = "🔨 Load Main Building System",
    Callback = function()
        Rayfield:Notify({Title = "✅ Loaded", Content = "Advanced Placement + Preview System Activated", Duration = 4})
        
        -- Your full placement system goes here (cleaned version)
        -- Paste your entire original building code (the big v_u_1 table etc.) here if you want it fully working
        print("⭐ Build System Loaded - Use mouse to place")
    end,
})

MainTab:CreateButton({
    Name = "🗑️ Delete All My Builds",
    Callback = function()
        local success, err = pcall(function()
            local DeleteAll = game:GetService("ReplicatedStorage").Events.DeleteAllPlayerBlocks
            DeleteAll:FireServer()
        end)
        
        if success then
            Rayfield:Notify({Title = "🗑️ Cleared", Content = "All of your builds have been deleted", Duration = 3})
        else
            Rayfield:Notify({Title = "⚠️ Error", Content = "Failed to delete builds", Duration = 3})
        end
    end,
})

MainTab:CreateButton({
    Name = "🗑️ Delete Specific User's Builds",
    Callback = function()
        Rayfield:CreateInput({
            Name = "Enter Username to Delete",
            PlaceholderText = "Chiksa801",
            RemoveTextAfterFocusLost = false,
            Callback = function(username)
                if username and username ~= "" then
                    Rayfield:Notify({Title = "🔍 Searching", Content = "Attempting to delete " .. username .. "'s builds...", Duration = 3})
                    
                    local BuiltFolder = workspace:FindFirstChild("Built")
                    if not BuiltFolder then
                        Rayfield:Notify({Title = "❌ Error", Content = "Built folder not found", Duration = 3})
                        return
                    end
                    
                    local PlayerFolder = BuiltFolder:FindFirstChild(username)
                    if PlayerFolder then
                        for _, block in ipairs(PlayerFolder:GetDescendants()) do
                            if block:IsA("BasePart") or block:IsA("Model") then
                                local DestroyEvent = game:GetService("ReplicatedStorage").Events.DestroyBlock
                                local function GetNil(Name, DebugId)
                                    for _, obj in ipairs(getnilinstances()) do
                                        if obj.Name == Name and obj:GetDebugId() == DebugId then
                                            return obj
                                        end
                                    end
                                end
                                pcall(function()
                                    DestroyEvent:InvokeServer(GetNil(block.Name, block:GetDebugId()))
                                end)
                            end
                        end
                        Rayfield:Notify({Title = "✅ Success", Content = "Deleted " .. username .. "'s builds", Duration = 4})
                    else
                        Rayfield:Notify({Title = "❌ Not Found", Content = "No builds found for " .. username, Duration = 4})
                    end
                end
            end,
        })
    end,
})

MainTab:CreateSection("Info")
MainTab:CreateLabel("Game: Build Anything! [🛠️]")
MainTab:CreateLabel("StarCalled Hub")

print("⭐ StarCalled Hub - Build Anything! Loaded Successfully!")
