-- ╔══════════════════════════════════════════════╗
-- ║                                              ║
-- ║            ★ StarCalled Hub                  ║
-- ║          The hub above all others.           ║
-- ║                                              ║
-- ║              Made by Jayden                  ║
-- ║                                              ║
-- ╚══════════════════════════════════════════════╝

-- Configuration
local HUB = {
    Name      = "★ StarCalled Hub",
    Version   = "2.0",
    Developer = "Jayden",
    BaseURL   = "https://raw.githubusercontent.com/jaydencarson1609-lang/StarCalledHub/main/",
}

-- Games
local Games = {
    { Name = "★ Project Gambling",          Script = "projectgambling.lua"  },
    { Name = "★ Baby Pursuers",             Script = "babypursuers.lua"     },
    { Name = "★ Build Anything",            Script = "buildanything.lua"    },
    { Name = "★ Keyboard Escape",           Script = "keyboardescape.lua"   },
    { Name = "★ Clasher Royale",            Script = "ClasherRoyale.lua"    },
    { Name = "★ Natural Disaster Survival", Script = "NDS.lua"              },
    { Name = "★ Funky Friday",              Script = "funkyfriday.lua"      },
}

-- Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Window
local Window = Rayfield:CreateWindow({
    Name            = "★ StarCalled Hub",
    LoadingTitle    = "★ StarCalled Hub",
    LoadingSubtitle = "The hub above all others.",
    ConfigurationSaving = { Enabled = false },
    Discord         = { Enabled = false },
    KeySystem       = false,
})

-- Games Tab
local GameTab = Window:CreateTab("★ Games", 4483362458)
GameTab:CreateSection("★ Select a Game")

for _, entry in ipairs(Games) do
    GameTab:CreateButton({
        Name = entry.Name,
        Callback = function()
            Rayfield:Notify({
                Title    = "★ StarCalled Hub",
                Content  = "Loading " .. entry.Name .. "...",
                Duration = 3,
            })
            task.wait(1.5)
            Rayfield:Destroy()
            task.wait(0.3)
            loadstring(game:HttpGet(HUB.BaseURL .. entry.Script))()
        end,
    })
end

-- Info Tab
local InfoTab = Window:CreateTab("★ Info", 4483362458)
InfoTab:CreateSection("★ About")
InfoTab:CreateLabel("Developer  |  " .. HUB.Developer)
InfoTab:CreateLabel("Version    |  v" .. HUB.Version)
InfoTab:CreateLabel("Games      |  " .. #Games .. " Supported")
InfoTab:CreateSection("★ Games List")
for _, entry in ipairs(Games) do
    InfoTab:CreateLabel(entry.Name)
end

-- Startup
Rayfield:Notify({
    Title    = "★ StarCalled Hub",
    Content  = "Welcome back. " .. #Games .. " games ready.",
    Duration = 5,
})
