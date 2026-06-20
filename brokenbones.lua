-- ★ StarCalled Hub | Broken Bones
-- Rayfield UI

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Functions = ReplicatedStorage:WaitForChild("Functions")

local RagdollEvent = Functions:WaitForChild("Ragdoll")
local UpdateStat = Functions:WaitForChild("UpdateStat")

local Window = Rayfield:CreateWindow({
    Name = "★ StarCalled Hub | Broken Bones",
    LoadingTitle = "StarCalled Hub",
    LoadingSubtitle = "Broken Bones",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("🦴 Broken Bones", 4483362458)

MainTab:CreateSection("Main")

MainTab:CreateButton({
    Name = "🧍 Ragdoll",
    Callback = function()
        pcall(function()
            RagdollEvent:FireServer()
        end)

        Rayfield:Notify({
            Title = "Ragdoll",
            Content = "Ragdoll remote fired.",
            Duration = 3
        })
    end
})

MainTab:CreateButton({
    Name = "💰 Give Money",
    Callback = function()
        pcall(function()
            UpdateStat:InvokeServer("money", 11855)
        end)

        Rayfield:Notify({
            Title = "Money",
            Content = "Money stat updated.",
            Duration = 3
        })
    end
})

MainTab:CreateButton({
    Name = "📈 Add Run",
    Callback = function()
        pcall(function()
            UpdateStat:InvokeServer("runs", 1)
        end)

        Rayfield:Notify({
            Title = "Runs",
            Content = "Run stat updated.",
            Duration = 3
        })
    end
})

MainTab:CreateSection("Injury Stats")

MainTab:CreateButton({
    Name = "🦴 Set Total Breaks: 25",
    Callback = function()
        pcall(function()
            UpdateStat:InvokeServer("totalbreaks", 25)
        end)

        Rayfield:Notify({
            Title = "Total Breaks",
            Content = "Total breaks set to 25.",
            Duration = 3
        })
    end
})

MainTab:CreateButton({
    Name = "🤕 Set Total Sprains: 8",
    Callback = function()
        pcall(function()
            UpdateStat:InvokeServer("totalsprains", 8)
        end)

        Rayfield:Notify({
            Title = "Total Sprains",
            Content = "Total sprains set to 8.",
            Duration = 3
        })
    end
})

MainTab:CreateButton({
    Name = "🦾 Set Dislocations: 0",
    Callback = function()
        pcall(function()
            UpdateStat:InvokeServer("totaldislocations", 0)
        end)

        Rayfield:Notify({
            Title = "Dislocations",
            Content = "Total dislocations set to 0.",
            Duration = 3
        })
    end
})

MainTab:CreateButton({
    Name = "🏆 Set Record Breaks: 25",
    Callback = function()
        pcall(function()
            UpdateStat:InvokeServer("recordbreaks", 25, true)
        end)

        Rayfield:Notify({
            Title = "Record Breaks",
            Content = "Record breaks set to 25.",
            Duration = 3
        })
    end
})

MainTab:CreateSection("All-In-One")

MainTab:CreateButton({
    Name = "⚡ Apply All Stats",
    Callback = function()
        pcall(function()
            RagdollEvent:FireServer()

            task.wait(0.2)
            UpdateStat:InvokeServer("runs", 1)
            UpdateStat:InvokeServer("totalbreaks", 25)
            UpdateStat:InvokeServer("totalsprains", 8)
            UpdateStat:InvokeServer("totaldislocations", 0)
            UpdateStat:InvokeServer("recordbreaks", 25, true)
            UpdateStat:InvokeServer("money", 11855)
        end)

        Rayfield:Notify({
            Title = "Applied",
            Content = "All Broken Bones stats were sent.",
            Duration = 4
        })
    end
})

MainTab:CreateSection("About")
MainTab:CreateLabel("★ StarCalled Hub — Made by Jayden")
MainTab:CreateLabel("Broken Bones 🦴")
