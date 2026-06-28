-- ╔══════════════════════════════════════════════╗
-- ║                                              ║
-- ║          ★ StarCalled Hub  |  NDS            ║
-- ║        Natural Disaster Survival             ║
-- ║                                              ║
-- ║              Made by Jayden                  ║
-- ║                                              ║
-- ╚══════════════════════════════════════════════╝

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
task.wait(0.5)

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub | Natural Disaster Survival",
    LoadingTitle = "★ StarCalled Hub",
    LoadingSubtitle = "Natural Disaster Survival",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "StarCalledHub",
        FileName = "NDS_Config"
    },
    Discord = { Enabled = false },
    KeySystem = false,
})

-- Services
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local PhysicsService   = game:GetService("PhysicsService")
local player           = Players.LocalPlayer
local camera           = Workspace.CurrentCamera

-- Noclip collision group
pcall(function()
    PhysicsService:CreateCollisionGroup("NoCollideGroup")
    PhysicsService:CollisionGroupSetCollidable("NoCollideGroup", "Default", false)
end)

-- State
local flying       = false
local noclip       = false
local infiniteJump = false
local FLY_SPEED    = 50

---------------------------------------
-- TABS
---------------------------------------
local MainTab  = Window:CreateTab("★ Main",     4483362458)
local FETab    = Window:CreateTab("★ FE Stuff", 4483362458)
local NotesTab = Window:CreateTab("★ Notes",    4483362458)

---------------------------------------
-- MAIN TAB
---------------------------------------
MainTab:CreateSection("★ Movement")

MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(val)
        flying = val
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = val end
        end
    end
})

RunService.RenderStepped:Connect(function(dt)
    if not flying then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local dir = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W)           then dir += camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S)           then dir -= camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A)           then dir -= camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D)           then dir += camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then dir += Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end

    if dir.Magnitude > 0 then
        root.CFrame = root.CFrame + (dir.Unit * FLY_SPEED * dt)
    end
end)

MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(val) FLY_SPEED = val end
})

MainTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(val)
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
})

MainTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 300},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(val)
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = val end
    end
})

MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(val)
        noclip = val
        if val then
            task.spawn(function()
                while noclip and player.Character do
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            pcall(function() PhysicsService:SetPartCollisionGroup(part, "NoCollideGroup") end)
                        end
                    end
                    task.wait(0.05)
                end
            end)
        else
            local char = player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function() PhysicsService:SetPartCollisionGroup(part, "Default") end)
                    end
                end
            end
        end
    end
})

MainTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(val)
        infiniteJump = val
        if val then
            if _G.InfJumpCon then _G.InfJumpCon:Disconnect() end
            _G.InfJumpCon = UserInputService.JumpRequest:Connect(function()
                if infiniteJump and player.Character then
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        else
            if _G.InfJumpCon then
                _G.InfJumpCon:Disconnect()
                _G.InfJumpCon = nil
            end
        end
    end
})

MainTab:CreateSection("★ Utilities")

MainTab:CreateButton({
    Name = "Load Infinite Yield",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
            Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Infinite Yield loaded!", Duration = 3})
        end)
    end
})

---------------------------------------
-- FE STUFF TAB
---------------------------------------
FETab:CreateSection("★ FE Scripts")

FETab:CreateButton({
    Name = "FE Inverse Gravity",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/96XzjEiK"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Inverse Gravity loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE SCP-096",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://pastefy.app/YsJgITXR/raw"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE SCP-096 loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE A-Train",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqv1/A-Train-by-GioBolqv1-/refs/heads/main/train.lua"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE A-Train loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Fighter Animation",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://pastefy.app/wxVAgZpT/raw"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Fighter Animation loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Punch",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/0Ben1/fe/main/obf_rf6iQURzu1fqrytcnLBAvW34C9N55kS9g9G3CKz086rC47M6632sEd4ZZYB0AYgV.lua.txt", true))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Punch loaded! Works R15/R6.", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Telekinesis V5",
    Callback = function()
        pcall(function() loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/randomstring0/Qwerty/refs/heads/main/qwerty11.lua"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Telekinesis V5 loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Car Script",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexCr4sh/FeScripts/main/FeCarScript.lua", true))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Car Script loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Troll Animations",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ShutUpJamesTheLoserAlt/fes/refs/heads/main/e"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Troll Animations loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Super Ring",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-SUPER-RING-PARTS-V3-WITH-NO-MESSAGE-26385"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Super Ring loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Motiona Animations",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/BeemTZy/Motiona/refs/heads/main/source.lua"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Motiona loaded!", Duration = 3})
    end
})

FETab:CreateSection("★ R6 & R15 FE Scripts")

FETab:CreateButton({
    Name = "AquaMatrix (320+ FE Animations R6/R15)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ExploitFin/AquaMatrix/refs/heads/AquaMatrix/AquaMatrix"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "AquaMatrix loaded! 270+ R6 & 50+ R15.", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Neko (R6 Only)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Gazer-Ha/Neko-v1/main/Extremely Broken"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Neko loaded! R6 only.", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Ender (R6 Only)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/Qwerty/refs/heads/main/qwerty18.lua"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Ender loaded! R6 only.", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Btools V5 (R6 & R15)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/v9P6zsuW", true))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Btools V5 loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Bird (R6 & R15)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/0Ben1/fe/main/Fe%20Bird%20R6%20and%20R15"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Bird loaded! R6 & R15.", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Honored (R6 & R15)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Cortzalno666/NectoVerse-Industries-Data/master/Scripts Folder/Honored.lua", true))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Honored loaded! R6 & R15.", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Tool Draw (R6 & R15)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Affexter/Programs/refs/heads/main/scripts/tooldrawFE.lua"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Tool Draw loaded! R6 & R15.", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Animation Hub (R6 & R15)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/echelonvanta/Scripts/refs/heads/main/Animstions Hub/animation.lua"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Animation Hub loaded! R6 & R15.", Duration = 3})
    end
})

FETab:CreateSection("★ FE Troll & Misc")

FETab:CreateButton({
    Name = "FE Ragdoll (Universal)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/shakk-code/fe-ragdoll-script/refs/heads/main/script.lua", true))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Ragdoll loaded! Universal R6/R15.", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Dropkick Fling",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/gsm231/Fe-DropKick/refs/heads/main/V0.1"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Dropkick loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Invisible",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/K0khSQFN"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Invisible loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Animation Pack",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/tcTds0ky"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Animation Pack loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Animation Hub V2.5 (R6)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Emerson2-creator/Scripts-Roblox/refs/heads/main/ScriptR6/AnimGuiV2.lua"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Animation Hub V2.5 loaded! R6.", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "Open-FE Reanimation Hub",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Blukezz/Open-FE/refs/heads/main/Main.lua"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Open-FE loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Bring & Fling Players",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Bac0nHck/Scripts/main/BringFlingPlayers"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Bring & Fling loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Zombie Fling",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://pastefy.app/w7KnPY70/raw", true))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Zombie Fling loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Control NPCs",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://pastefy.app/x8nWWq0M/raw", true))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Control NPCs loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Part Mover (Unanchored)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://pastefy.app/Vcuyg09O/raw", true))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Part Mover loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE GigaChad Hub",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/OWJBWKQLAISH/GigaChad-Hub/main/Protected_3038811338432694.lua.txt"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "GigaChad Hub loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Ocfi Animations (Obfuscated)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ocfi/Animations-obfus/refs/heads/main/obfus"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Ocfi Animations loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE System Broken",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/H20CalibreYT/SystemBroken/main/script"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE System Broken loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Nameless Admin (No Kick)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/FD2Team/Nameless-Admin-No-Byfron-Kick/main/Source", true))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Nameless Admin loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "Fates Admin (FE Features)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Fates Admin loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "Herbert V1 FE Bypass",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaGunsX/HerbertV1/main/main.lua", true))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Herbert V1 loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Punch Fling",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/fedoratums/Base-Script/Base-Script/fedoratum punch fling", true))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Punch Fling loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Tool Rotator",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/dkufMsdA", true))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Tool Rotator loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "Game Hub V5",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/GamerScripter/Game-Hub/main/loader"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Game Hub V5 loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "FE Fighter (Gale Inspired)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-FE-Fighter-inspired-by-Gale-21557"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "FE Fighter loaded!", Duration = 3})
    end
})

FETab:CreateSection("★ NDS Specific Scripts")

FETab:CreateButton({
    Name = "Mercury Hub (Auto Win, ESP, Teleport)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/celestialkendall/mercuryhub/refs/heads/main/mainnds.lua"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Mercury Hub loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "Lua Land Hub (Anti-Fall, Bridge, Balloon)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Angelo-Gitland/Natural-Disaster-Survival-Script-Lua-Land/refs/heads/main/Natural Disaster Survival Lua Land Hub"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Lua Land Hub loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "NDS Hub (Auto Win, Fly)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Thebestofhack123/2.0/refs/heads/main/NDS"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "NDS Hub loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "Plutonium (Auto Farm Wins)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/PawsThePaw/Plutonium.AA/main/Plutonium.Loader.lua", true))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Plutonium loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "NDS Super Ring",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Lukashub-coder/super-ring/refs/heads/main/Super ring!!"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "NDS Super Ring loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "Spider NDS Script (Auto Win, Inf Jump)",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/SpiderScriptRB/Natural-Disaster-Survival/refs/heads/main/1.0.2 Version Script.txt"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "Spider NDS loaded!", Duration = 3})
    end
})

FETab:CreateButton({
    Name = "NullFire Hub",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/InfernusScripts/Null-Fire/main/Loader"))() end)
        Rayfield:Notify({Title = "★ StarCalled Hub", Content = "NullFire Hub loaded!", Duration = 3})
    end
})

---------------------------------------
-- NOTES TAB
---------------------------------------
NotesTab:CreateSection("★ StarCalled Hub")
NotesTab:CreateLabel("Made by       |  Jayden")
NotesTab:CreateLabel("Game          |  Natural Disaster Survival")
NotesTab:CreateLabel("Version       |  6.3")
NotesTab:CreateLabel("Main          |  Fly, Noclip, Speed, Jump")
NotesTab:CreateLabel("FE Stuff      |  40+ keyless FE scripts")
NotesTab:CreateLabel("Sections      |  FE Scripts | R6+R15 | Troll | NDS")

---------------------------------------
-- Ready
---------------------------------------
Rayfield:Notify({
    Title   = "★ StarCalled Hub",
    Content = "Natural Disaster Survival ready. Stay starred.",
    Duration = 5
})
print("★ StarCalled Hub v6.3 | NDS Ready")
