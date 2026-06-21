-- ★ StarCalled Hub | Build Anything! [🛠️]
-- Version 1.5 - Fixed Selection + Auto Delete

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub - Build Anything! 🛠️",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Build Anything!",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

-- ==================== DYNAMIC BUILD LOADER ====================
local BuildsFolder = {}
local GITHUB_USER = "jaydencarson1609-lang"
local GITHUB_REPO = "StarCalledHub"
local BUILDS_PATH = "Builds"

local function LoadBuildsFromGitHub()
    BuildsFolder = {}
    local buildOptions = {"None"}

    local buildFiles = {"Tower.lua"}

    for _, filename in ipairs(buildFiles) do
        local url = "https://raw.githubusercontent.com/" .. GITHUB_USER .. "/" .. GITHUB_REPO .. "/main/" .. BUILDS_PATH .. "/" .. filename
        
        local success, response = pcall(function()
            return game:HttpGet(url, true)
        end)

        if success and response and response ~= "404: Not Found" then
            local loadSuccess, buildData = pcall(function()
                return loadstring(response)()
            end)
            
            if loadSuccess and buildData and type(buildData) == "table" and #buildData > 0 then
                local buildName = filename:gsub("%.lua$", "")
                BuildsFolder[buildName] = buildData
                table.insert(buildOptions, buildName)
                print("✅ Loaded build:", buildName, "| Blocks:", #buildData)
            else
                warn("❌ Failed to load build data from:", filename)
            end
        else
            warn("❌ Could not download:", filename)
        end
    end

    return buildOptions
end

local buildOptions = LoadBuildsFromGitHub()

-- ==================== MAIN TAB ====================
local MainTab = Window:CreateTab("🛠️ Main", 4483362458)
MainTab:CreateSection("Build System")

local selectedBuildName = "None"
local selectedBuildData = nil

MainTab:CreateDropdown({
    Name = "What do you want to build?",
    Options = buildOptions,
    Default = "None",
    Callback = function(value)
        selectedBuildName = value
        selectedBuildData = BuildsFolder[value]
        if selectedBuildData then
            print("📌 Selected:", value, "- Blocks:", #selectedBuildData)
        end
    end,
})

MainTab:CreateButton({
    Name = "🚀 Build Selected",
    Callback = function()
        if selectedBuildName == "None" or not selectedBuildData then 
            Rayfield:Notify({Title = "Error", Content = "Please select Tower from the dropdown!", Duration = 4})
            return 
        end

        Rayfield:Notify({Title = "Building...", Content = selectedBuildName, Duration = 4})

        local PlaceEvent = game:GetService("ReplicatedStorage").Events:FindFirstChild("PlaceBlock") 
                        or game:GetService("ReplicatedStorage").Events:FindFirstChild("BuildBlock")

        if not PlaceEvent then
            Rayfield:Notify({Title = "Error", Content = "PlaceBlock event not found!", Duration = 5})
            return
        end

        for i, blockData in ipairs(selectedBuildData) do
            task.spawn(function()
                pcall(function()
                    local blockType = blockData[1]
                    local cframe = blockData[2]
                    local parent = blockData[3] or workspace.Baseplate
                    PlaceEvent:InvokeServer(blockType, cframe, parent)
                end)
            end)
            if i % 6 == 0 then task.wait(0.04) end
        end

        Rayfield:Notify({Title = "✅ Success", Content = selectedBuildName .. " finished!", Duration = 5})
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

TrollsTab:CreateButton({
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

TrollsTab:CreateToggle({
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
            if autoDeleteConnection then
                task.cancel(autoDeleteConnection)
                autoDeleteConnection = nil
            end
            Rayfield:Notify({Title = "Auto Delete", Content = "DISABLED", Duration = 3})
        end
    end,
})

TrollsTab:CreateButton({
    Name = "Delete All My Builds",
    Callback = function()
        pcall(function()
            game:GetService("ReplicatedStorage").Events.DeleteAllPlayerBlocks:FireServer()
        end)
    end,
})

-- ==================== NOTES TAB ====================
local NotesTab = Window:CreateTab("📝 Notes", 4483362458)
NotesTab:CreateSection("Info")
NotesTab:CreateLabel("★ StarCalled Hub - Build Anything!")
NotesTab:CreateLabel("Version 1.5")

print("⭐ StarCalled Hub Loaded! Press F9 to see console messages.")
