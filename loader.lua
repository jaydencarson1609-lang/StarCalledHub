-- StarCalled Hub | Loader
-- Run this in your executor

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local SUPPORTED_GAMES = {
    {
        name = "PROJECT GAMBLING",
        description = "Slot Machine Farmer + Plinko Auto Drop",
        emoji = "🎰",
        loader = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/jaydencarson1609-lang/StarCalledHub/main/projectgambling.lua"))()
        end
    },
    {
        name = "Baby Pursuers",
        description = "Auto Spawn + Auto Farm babies into Vent",
        emoji = "👶",
        loader = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/jaydencarson1609-lang/StarCalledHub/main/babypursuers.lua"))()
        end
    },
    {
        name = "Sell Lemons 🍋",
        description = "Auto Click + Auto Upgrade + Auto Rebirth",
        emoji = "🍋",
        loader = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/jaydencarson1609-lang/StarCalledHub/main/selllemons.lua"))()
        end
    },
}

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Select a game to load",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

local GameTab = Window:CreateTab("🎮 Games", 4483362458)

GameTab:CreateSection("Supported Games")

for _, gameEntry in ipairs(SUPPORTED_GAMES) do
    GameTab:CreateButton({
        Name = gameEntry.emoji .. " " .. gameEntry.name,
        Callback = function()
            Rayfield:Notify({
                Title = "Loading...",
                Content = "Loading " .. gameEntry.name .. "...",
                Duration = 3,
                Image = 4483362458,
            })
            
            task.wait(0.5)
            Rayfield:Destroy()
            gameEntry.loader()
        end,
    })
    
    GameTab:CreateLabel("   📝 " .. gameEntry.description)
end

GameTab:CreateSection("📝 About")
GameTab:CreateLabel("★ StarCalled Hub — Made by Jayden")
GameTab:CreateLabel("More games coming soon!")
