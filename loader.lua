-- StarCalled Hub | Loader
-- Run this in your executor

local SUPPORTED_GAMES = {
    {
        name = "PROJECT GAMBLING",
        emoji = "🎰",
        loader = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/jaydencarson1609-lang/StarCalledHub/main/projectgambling.lua"))()
        end
    },
    {
        name = "Baby Pursuers",
        emoji = "👶",
        loader = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/jaydencarson1609-lang/StarCalledHub/main/babypursuers.lua"))()
        end
    },
    {
        name = "Sell Lemons 🍋",
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
    LoadingSubtitle = "Choose a game",
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
            Rayfield:Notify({ Title = "Loading", Content = "Loading " .. gameEntry.name, Duration = 2 })
            task.wait(0.4)
            Rayfield:Destroy()
            gameEntry.loader()
        end,
    })
end

GameTab:CreateSection("📝 About")
GameTab:CreateLabel("★ StarCalled Hub — Made by Jayden")
