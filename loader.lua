-- StarCalled Hub | Loader v2
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
        name = "Sell Lemons",
        emoji = "🍋",
        loader = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/jaydencarson1609-lang/StarCalledHub/main/selllemons.lua"))()
        end
    },
    {
        name = "Grow a Garden 2",
        emoji = "🌱",
        loader = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/jaydencarson1609-lang/StarCalledHub/main/growagarden2.lua"))()
        end
    },
}

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Choose a game to load",
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
                Title = "⏳ Loading",
                Content = "Loading " .. gameEntry.name .. "...",
                Duration = 3
            })
            task.wait(1.5)   -- let notify render before destroy
            Rayfield:Destroy()
            task.wait(0.3)   -- gap before child script inits its own Rayfield
            gameEntry.loader()
        end,
    })
end

GameTab:CreateSection("📝 About")
GameTab:CreateLabel("★ StarCalled Hub — Made by Jayden")
GameTab:CreateLabel("Loaded Games: GAG2 🌱 | Baby Pursuers 👶 | Lemons 🍋 | Gambling 🎰")
