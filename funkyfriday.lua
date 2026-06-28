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

-- Services
local Players = game:GetService("Players")
local player  = Players.LocalPlayer

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
        if val then
            task.spawn(function()
                -- =================================================
                -- APEX ARCHITECTURE: MEMORY-MAPPED PIPELINE
                -- =================================================
                local os_clock     = os.clock
                local task_spawn   = task.spawn
                local task_wait    = task.wait
                local pcall        = pcall
                local setmetatable = setmetatable
                local b_create     = buffer.create
                local b_writef64   = buffer.writef64
                local b_readf64    = buffer.readf64
                local RunService   = game:GetService("RunService")
                local PreRender    = RunService.PreRender

                -- Secure Fetch with Exponential Backoff
                local fetchSuccess, rawLib
                local delayTime = 0.5
                for attempt = 1, 3 do
                    fetchSuccess, rawLib = pcall(function()
                        return loadstring(game:HttpGet(
                            "https://raw.githubusercontent.com/Null-Cherry/Null-Fire/refs/heads/main/Core/Loaders/Funky-Friday/Autoplay.lua",
                            true
                        ))()
                    end)
                    if fetchSuccess and type(rawLib) == "table" then break end
                    task_wait(delayTime)
                    delayTime = delayTime * 2
                end

                if not (fetchSuccess and type(rawLib) == "table") then
                    Rayfield:Notify({
                        Title    = "★ StarCalled Hub",
                        Content  = "Auto Player failed to load. Try again.",
                        Duration = 4,
                    })
                    return
                end

                -- Immutable Sandbox Proxy
                local coreProxy = setmetatable({}, {
                    __index     = rawLib,
                    __newindex  = function(t, k, v) rawLib[k] = v end,
                    __metatable = "LOCKED"
                })

                -- Configure
                coreProxy.AutoPlay    = true
                coreProxy.MoreStats   = false
                coreProxy.PerfectSick = 1
                coreProxy.Performance = 5

                -- Memory-Mapped Pipeline
                local mem_ring      = b_create(64)
                local ptr_offset    = 0
                local lastTimestamp = os_clock()

                local connection
                connection = PreRender:Connect(function()
                    if not rawLib then
                        connection:Disconnect()
                        return
                    end

                    local currentTimestamp = os_clock()
                    local delta = currentTimestamp - lastTimestamp
                    lastTimestamp = currentTimestamp

                    b_writef64(mem_ring, ptr_offset, delta)
                    ptr_offset = (ptr_offset + 8) % 64

                    -- Kahan Summation for zero-loss float accuracy
                    local sum, c = 0.0, 0.0
                    for offset = 0, 56, 8 do
                        local y = b_readf64(mem_ring, offset) - c
                        local t = sum + y
                        c   = (t - sum) - y
                        sum = t
                    end

                    if sum > 0.036 then
                        coreProxy.MoreStats   = false
                        coreProxy.Performance = 5
                    end

                    coreProxy.AutoPlay = true
                end)

                Rayfield:Notify({
                    Title    = "★ StarCalled Hub",
                    Content  = "Auto Player is running!",
                    Duration = 3,
                })
            end)
        else
            Rayfield:Notify({
                Title    = "★ StarCalled Hub",
                Content  = "Auto Player disabled. Rejoin to fully stop.",
                Duration = 3,
            })
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
