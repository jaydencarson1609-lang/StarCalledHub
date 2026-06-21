-- ★ StarCalled Hub | Build Anything! [🛠️]
-- Version 1.0 - Made by Jayden

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub - Build Anything! 🛠️",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Build Anything!",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

-- ==================== MAIN TAB ====================
local MainTab = Window:CreateTab("🛠️ Main", 4483362458)
MainTab:CreateSection("Build System")

MainTab:CreateLabel("Version 1.0 - Made by Jayden")

local selectedBuild = "None"

MainTab:CreateDropdown({
    Name = "What do you want to build?",
    Options = {"None", "Custom Build 1", "Custom Build 2", "Custom Build 3"},
    Default = "None",
    Callback = function(value)
        selectedBuild = value
    end,
})

MainTab:CreateButton({
    Name = "Build Selected",
    Callback = function()
        if selectedBuild == "None" then 
            Rayfield:Notify({Title = "Select Build", Content = "Please choose something from the dropdown", Duration = 3})
            return 
        end
        Rayfield:Notify({Title = "Building", Content = "Started: " .. selectedBuild, Duration = 4})
    end,
})

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
    Name = "Delete User Build",
    Callback = function()
        local username = targetUsername
        if username == "" or not username then return end

        local Built = workspace:FindFirstChild("Built")
        if not Built then return end

        local targetFolder = Built:FindFirstChild(username)
        if not targetFolder then return end

        local Event = game:GetService("ReplicatedStorage").Events.DestroyBlock

        for _, block in ipairs(targetFolder:GetChildren()) do
            task.spawn(function()
                Event:InvokeServer(block)
            end)
        end
    end,
})

TrollsTab:CreateButton({
    Name = "Delete Everyone Build",
    Callback = function()
        local Built = workspace:FindFirstChild("Built")
        if not Built then return end

        local Event = game:GetService("ReplicatedStorage").Events.DestroyBlock

        for _, plot in ipairs(Built:GetChildren()) do
            for _, block in ipairs(plot:GetChildren()) do
                task.spawn(function()
                    Event:InvokeServer(block)
                end)
            end
        end
    end,
})

local autoDeleteConnection = nil

TrollsTab:CreateToggle({
    Name = "Auto Delete Everyone Build",
    CurrentValue = false,
    Callback = function(value)
        if value then
            autoDeleteConnection = task.spawn(function()
                while true do
                    local Built = workspace:FindFirstChild("Built")
                    if Built then
                        local Event = game:GetService("ReplicatedStorage").Events.DestroyBlock
                        for _, plot in ipairs(Built:GetChildren()) do
                            for _, block in ipairs(plot:GetChildren()) do
                                pcall(function()
                                    Event:InvokeServer(block)
                                end)
                            end
                        end
                    end
                    task.wait(0.1) -- Fast loop
                end
            end)
            Rayfield:Notify({Title = "Auto Delete", Content = "Auto Delete Everyone Build ENABLED", Duration = 3})
        else
            if autoDeleteConnection then
                task.cancel(autoDeleteConnection)
                autoDeleteConnection = nil
            end
            Rayfield:Notify({Title = "Auto Delete", Content = "Auto Delete Everyone Build DISABLED", Duration = 3})
        end
    end,
})

TrollsTab:CreateButton({
    Name = "Delete All My Builds",
    Callback = function()
        game:GetService("ReplicatedStorage").Events.DeleteAllPlayerBlocks:FireServer()
    end,
})

-- ==================== NOTES TAB ====================
local NotesTab = Window:CreateTab("📝 Notes", 4483362458)
NotesTab:CreateSection("📝 About")
NotesTab:CreateLabel("★ StarCalled Hub - Build Anything!")
NotesTab:CreateLabel("Version: 1.0")
NotesTab:CreateLabel("Made by: Jayden")
NotesTab:CreateLabel("For: StarCalled Hub")

print("⭐ StarCalled Hub - Build Anything! Loaded Successfully")
