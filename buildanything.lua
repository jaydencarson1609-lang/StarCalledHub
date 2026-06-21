-- ★ StarCalled Hub | Build Anything! [🛠️]
-- Version 1.0 - Made by Grok for StarCalled Hub

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

MainTab:CreateLabel("Version 1.0 - Made by Grok for StarCalled Hub")

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
            Rayfield:Notify({Title = "Select a build", Content = "Choose something from the dropdown", Duration = 3})
            return 
        end
        
        print("Building: " .. selectedBuild)
        -- Add your custom builds here later
        Rayfield:Notify({Title = "Building", Content = "Started building " .. selectedBuild, Duration = 4})
        
        -- Example placeholder for future builds
        -- if selectedBuild == "Custom Build 1" then ... end
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

TrollsTab:CreateButton({
    Name = "Delete All My Builds",
    Callback = function()
        game:GetService("ReplicatedStorage").Events.DeleteAllPlayerBlocks:FireServer()
    end,
})

TrollsTab:CreateSection("Notes")
TrollsTab:CreateLabel("Version 1.0 - Made by Grok for StarCalled Hub")

print("⭐ Script Loaded Successfully")
