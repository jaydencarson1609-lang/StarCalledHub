-- StarCalled Hub | Loader
-- Run this in your executor

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local SUPPORTED_GAMES = {
    {
        name = "PROJECT GAMBLING",
        placeId = 103158388706417,
        description = "Slot Machine Farmer + Plinko Auto Drop",
        emoji = "🎰",
        loader = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/jaydencarson1609-lang/StarCalledHub/main/projectgambling.lua"))()
        end
    },
    {
        name = "Baby Pursuers",
        placeId = 96369863816442,
        description = "Auto Spawn + Auto Farm babies into Vent",
        emoji = "👶",
        loader = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/jaydencarson1609-lang/StarCalledHub/main/babypursuers.lua"))()
        end
    },
    {
        name = "Sell Lemons 🍋",
        placeId = 79268393072444,
        description = "Auto Click + Auto Upgrade + Auto Rebirth",
        emoji = "🍋",
        loader = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/jaydencarson1609-lang/StarCalledHub/main/selllemons.lua"))()
        end
    },
}

local currentPlaceId = game.PlaceId

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Loading game list...",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

local GameTab = Window:CreateTab("🎮 Games", 4483362458)

GameTab:CreateSection("Supported Games")
GameTab:CreateLabel("📍 Place ID: " .. tostring(currentPlaceId))

local foundMatch = false

for _, gameEntry in ipairs(SUPPORTED_GAMES) do
    local isCurrentGame = gameEntry.placeId == currentPlaceId
    local btnLabel = gameEntry.emoji .. "  " .. gameEntry.name .. (isCurrentGame and "  ✅ YOU ARE HERE" or "")

    GameTab:CreateButton({
        Name = btnLabel,
        Callback = function()
            if isCurrentGame then
                Rayfield:Destroy()
                task.wait(0.5)
                gameEntry.loader()
            else
                Rayfield:Notify({
                    Title = "Wrong Game",
                    Content = "You are not in " .. gameEntry.name .. "! Join that game first.",
                    Duration = 5,
                    Image = 4483362458,
                })
            end
        end,
    })

    GameTab:CreateLabel("   📝 " .. gameEntry.description)
    if isCurrentGame then foundMatch = true end
end

GameTab:CreateSection("Info")

if not foundMatch then
    GameTab:CreateLabel("❌ This game is not supported yet.")
    GameTab:CreateLabel("Place ID: " .. tostring(currentPlaceId))
    Rayfield:Notify({
        Title = "Not Supported",
        Content = "This game isn't supported yet!",
        Duration = 5,
        Image = 4483362458,
    })
else
    GameTab:CreateLabel("✅ Your game is supported! Click above to load.")
end

GameTab:CreateSection("📝 About")
GameTab:CreateLabel("★ StarCalled Hub — Made by Jayden")
GameTab:CreateLabel("More games coming soon!")
