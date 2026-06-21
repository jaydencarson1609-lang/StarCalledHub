-- ★ StarCalled Hub | Build Anything! [🛠️]
-- Version 1.4 - Fixed Build Selection

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
        
        local success, response = pcall(game.HttpGet, game, url)
        if success and response then
            local loadSuccess, buildData = pcall(function()
                return loadstring(response)()
            end)
            
            if loadSuccess and buildData and #buildData > 0 then
                local buildName = filename:gsub("%.lua$", "")
                BuildsFolder[buildName] = buildData
                table.insert(buildOptions, buildName)
                print("✅ Successfully loaded build:", buildName, "(", #buildData, "blocks)")
            else
                warn("❌ Failed to parse build:", filename)
            end
        else
            warn("❌ Failed to download:", filename, "| URL:", url)
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
            print("Selected build:", value, "| Blocks:", #selectedBuildData)
        end
    end,
})

MainTab:CreateButton({
    Name = "🚀 Build Selected",
    Callback = function()
        if selectedBuildName == "None" or not selectedBuildData then 
            Rayfield:Notify({Title = "Error", Content = "Please select a build from the dropdown!", Duration = 4})
            return 
        end

        Rayfield:Notify({Title = "Building...", Content = selectedBuildName, Duration = 4})

        local PlaceEvent = game:GetService("ReplicatedStorage").Events:FindFirstChild("PlaceBlock") 
                        or game:GetService("ReplicatedStorage").Events:FindFirstChild("BuildBlock")
                        or game:GetService("ReplicatedStorage").Events:FindFirstChild("Place")

        if not PlaceEvent then
            Rayfield:Notify({Title = "Error", Content = "Build event not found in game!", Duration = 5})
            return
        end

        local builtCount = 0
        for i, blockData in ipairs(selectedBuildData) do
            task.spawn(function()
                pcall(function()
                    local blockType = blockData[1]
                    local cframe = blockData[2]
                    local parent = blockData[3] or workspace.Baseplate
                    
                    PlaceEvent:InvokeServer(blockType, cframe, parent)
                    builtCount += 1
                end)
            end)
            
            if i % 6 == 0 then 
                task.wait(0.035) 
            end
        end

        Rayfield:Notify({Title = "✅ Finished", Content = selectedBuildName .. " completed!", Duration = 5})
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
NotesTab:CreateLabel("Version 1.4 - Fixed Selection")

print("⭐ StarCalled Hub Loaded! Check console (F9) for build loading info.")
