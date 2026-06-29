-- ╔══════════════════════════════════════════════╗
-- ║                                              ║
-- ║       ★ StarCalled Hub  |  Funky Friday      ║
-- ║              Made by Jayden                  ║
-- ║                                              ║
-- ╚══════════════════════════════════════════════╝

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
task.wait(0.5)

local Window = Rayfield:CreateWindow({
    Name            = "★ StarCalled Hub | Funky Friday",
    LoadingTitle    = "★ StarCalled Hub",
    LoadingSubtitle = "Funky Friday",
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "StarCalledHub",
        FileName   = "FF_Config"
    },
    Discord   = { Enabled = false },
    KeySystem = false,
})

local Players = game:GetService("Players")
local player  = Players.LocalPlayer

-- Load the autoplay library once and cache it
local autoLib = nil
local libLoaded = false

local function loadLib()
    if libLoaded then return autoLib end

    local ok, result = pcall(function()
        return loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/Null-Cherry/Null-Fire/refs/heads/main/Core/Loaders/Funky-Friday/Autoplay.lua",
            true
        ))()
    end)

    if ok and type(result) == "table" then
        autoLib = result
        libLoaded = true
        return autoLib
    end

    -- Retry once with a short delay
    task.wait(1)
    ok, result = pcall(function()
        return loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/Null-Cherry/Null-Fire/refs/heads/main/Core/Loaders/Funky-Friday/Autoplay.lua",
            true
        ))()
    end)

    if ok and type(result) == "table" then
        autoLib = result
        libLoaded = true
        return autoLib
    end

    return nil
end

---------------------------------------
-- TABS
---------------------------------------
local MainTab  = Window:CreateTab("★ Main",  4483362458)
local NotesTab = Window:CreateTab("★ Notes", 4483362458)

---------------------------------------
-- MAIN TAB
---------------------------------------
MainTab:CreateSection("★ Auto Player")

MainTab:CreateToggle({
    Name         = "Auto Player",
    CurrentValue = false,
    Callback     = function(val)
        task.spawn(function()
            local lib = loadLib()

            if not lib then
                Rayfield:Notify({
                    Title    = "★ StarCalled Hub",
                    Content  = "Auto Player failed to load. Try again.",
                    Duration = 4,
                })
                return
            end

            -- The library uses settings.AutoPlay as the control flag
            lib.AutoPlay = val

            if val then
                -- Set performance/accuracy defaults
                lib.Performance  = 0       -- 0 = best quality, 7 = max performance
                lib.PerfectSick  = 1       -- aim for Sick accuracy
                lib.MoreStats    = false

                lib.Chances.Sick  = 100
                lib.Chances.Good  = 0
                lib.Chances.Ok    = 0
                lib.Chances.Bad   = 0
                lib.Chances.Miss  = 0

                Rayfield:Notify({
                    Title    = "★ StarCalled Hub",
                    Content  = "Auto Player enabled!",
                    Duration = 3,
                })
            else
                Rayfield:Notify({
                    Title    = "★ StarCalled Hub",
                    Content  = "Auto Player disabled.",
                    Duration = 3,
                })
            end
        end)
    end
})

MainTab:CreateSection("★ Accuracy")

MainTab:CreateSlider({
    Name         = "Sick %",
    Range        = {0, 100},
    Increment    = 1,
    CurrentValue = 100,
    Callback     = function(val)
        if autoLib then
            autoLib.Chances.Sick = val
            autoLib.Chances.Miss = 100 - val
        end
    end
})

MainTab:CreateSection("★ Movement")

MainTab:CreateSlider({
    Name         = "WalkSpeed",
    Range        = {16, 250},
    Increment    = 1,
    CurrentValue = 16,
    Callback     = function(val)
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
})

MainTab:CreateSlider({
    Name         = "JumpPower",
    Range        = {50, 300},
    Increment    = 5,
    CurrentValue = 50,
    Callback     = function(val)
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = val end
    end
})

MainTab:CreateSection("★ Utilities")

MainTab:CreateButton({
    Name     = "Load Infinite Yield",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Infinite Yield loaded!", Duration = 3})
    end
})

---------------------------------------
-- NOTES TAB
---------------------------------------
NotesTab:CreateSection("★ StarCalled Hub")
NotesTab:CreateLabel("Made by       |  Jayden")
NotesTab:CreateLabel("Game          |  Funky Friday")
NotesTab:CreateLabel("Version       |  1.0")
NotesTab:CreateLabel("Main          |  Auto Player, Speed, Jump")

---------------------------------------
-- Ready
---------------------------------------
Rayfield:Notify({
    Title    = "★ StarCalled Hub",
    Content  = "Funky Friday ready. Hit those notes.",
    Duration = 5,
})
print("★ StarCalled Hub | Funky Friday Ready")
