-- ★ StarCalled Hub | Build Anything! [🛠️]
-- Version 1.6 - Fixed Selection Bug

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub - Build Anything! 🛠️",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Build Anything!",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

-- MAIN TAB (with Auto Delete)
local MainTab = Window:CreateTab("🛠️ Main", 4483362458)
MainTab:CreateSection("Main Controls")

local targetUsername = ""

MainTab:CreateInput({
    Name = "Delete Specific User's Builds",
    PlaceholderText = "Type username here",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        targetUsername = text
    end,
})

MainTab:CreateButton({
    Name = "Delete User Build",
    Callback = function()
        if targetUsername == "" then return end
        local Built = workspace:FindFirstChild("Built")
        if not Built then return end
        local targetFolder = Built:FindFirstChild(targetUsername)
        if not targetFolder then return end

        local Event = game:GetService("ReplicatedStorage").Events.DestroyBlock
        for _, block in ipairs(targetFolder:GetChildren()) do
            task.spawn(function()
                pcall(function() Event:InvokeServer(block) end)
            end)
        end
    end,
})

MainTab:CreateButton({
    Name = "🗑️ Delete Everyone's Builds",
    Callback = function()
        local Built = workspace:FindFirstChild("Built")
        if not Built then return end
        local Event = game:GetService("ReplicatedStorage").Events.DestroyBlock
        for _, plot in ipairs(Built:GetChildren()) do
            for _, block in ipairs(plot:GetChildren()) do
                task.spawn(function()
                    pcall(function() Event:InvokeServer(block) end)
                end)
            end
        end
    end,
})

local autoDeleteConnection = nil

MainTab:CreateToggle({
    Name = "Auto Delete Everyone's Builds",
    CurrentValue = false,
    Callback = function(value)
        if value then
            autoDeleteConnection = task.spawn(function()
                while true do
                    pcall(function()
                        local Built = workspace:FindFirstChild("Built")
                        if Built then
                            local Event = game:GetService("ReplicatedStorage").Events.DestroyBlock
                            for _, plot in ipairs(Built:GetChildren()) do
                                for _, block in ipairs(plot:GetChildren()) do
                                    pcall(function() Event:InvokeServer(block) end)
                                end
                            end
                        end
                    end)
                    task.wait(0.3)
                end
            end)
            Rayfield:Notify({Title = "Auto Delete", Content = "ENABLED", Duration = 3})
        else
            if autoDeleteConnection then task.cancel(autoDeleteConnection) end
            autoDeleteConnection = nil
            Rayfield:Notify({Title = "Auto Delete", Content = "DISABLED", Duration = 3})
        end
    end,
})

MainTab:CreateButton({
    Name = "Delete All My Builds",
    Callback = function()
        pcall(function()
            game:GetService("ReplicatedStorage").Events.DeleteAllPlayerBlocks:FireServer()
        end)
    end,
})

-- NOTES TAB
local NotesTab = Window:CreateTab("📝 Notes", 4483362458)
NotesTab:CreateSection("Info")
NotesTab:CreateLabel("★ StarCalled Hub - Build Anything!")
NotesTab:CreateLabel("Version 1.6 - Selection Fixed")

print("⭐ StarCalled Hub Loaded! Open F9 console for debug info.")
