local gui = loadstring(game:HttpGet("https://raw.githubusercontent.com/zxcursedsocute/UI-Library/refs/heads/main/UI-Library.txt"))()

local Window = gui.CreateWindow("Malc Scripts - Main", "", "590", "v 1.0")

Window:SetSavePath("MalcScripts", "Malc Scripts.json")

local ChooseGameTab = Window:AddTab("Scripts", "Misc")

ChooseGameTab:AddButton({
    Name = "Forsaken",
    Description = "",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/zxcursedsocute/Forsaken-Script/refs/heads/main/lua"))()
        end)
        Window:Destroy()
    end
})

ChooseGameTab:AddButton({
    Name = "Fish it",
    Description = "",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/zxcursedsocute/Fish-It/refs/heads/main/lua"))()
        end)
        Window:Destroy()
    end
})

ChooseGameTab:AddButton({
    Name = "Trollge Multiverse",
    Description = "",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/zxcursedsocute/Trollge-Multiverse/refs/heads/main/lua"))()
        end)
        Window:Destroy()
    end
})

ChooseGameTab:AddButton({
    Name = "Trollge Incident Fights Reborn",
    Description = "",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/zxcursedsocute/Trollge-Incident-Fights-Reborn2-script/refs/heads/main/lua"))()
        end)
        Window:Destroy()
    end
})

ChooseGameTab:AddButton({
    Name = "World Of Trollge",
    Description = "",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/zxcursedsocute/World-of-Trollge-script/refs/heads/main/lua"))()
        end)
        Window:Destroy()
    end
})

local Settings = Window:AddTab("UI Settings", "Settings")

Settings:AddSection("Interface")

Settings:AddDropdown({
    Name = "Theme",
    Description = "Change the interface theme",
    Options = {
        "Darkness",
        "Dark",
        "White",
        "Black",
        "Forsaken",
        "Forest 2021",
        "Germany 1941",
        "Spooky"
    },
    Default = "Darkness",
    Callback = function(select)
        Window:SetTheme(select)
    end
})

SetBlur = Settings:AddToggle({
    Name = "Blur",
    Description = "Need graphics level of 8 and above",
    Callback = function(state)
        if state then
            Window:BlurOff()
        else
            Window:Blur()
        end
    end
})

SetTrans = Settings:AddToggle({
    Name = "Transparency",
    Description = "Change the background transparency",
    Callback = function(state)
        Window:ChangeBackgroundTransparance()
    end
})

SetuserInfo = Settings:AddToggle({
    Name = "User Info",
    Description = "Show info about your account",
    Callback = function(state)
        Window:UserInfo()
    end
})

Settings:AddToggle({
    Name = "Search",
    Description = "Show the search",
    Callback = function(state)
        Window:ShowSearch()
    end
})

Settings:AddSection("Window")

Settings:AddKeybind({
    Name = "Minimize Window",
    Description = "Change the window to minimize",
    Default = "",
    Callback = function()
        Window:Minimaze()
    end
})

Settings:AddKeybind({
    Name = "Column Window",
    Description = "Change the window to column",
    Default = "",
    Callback = function()
        Window:ColumnWindow()
    end
})

Settings:AddKeybind({
    Name = "Close Window",
    Description = "Close the Window",
    Default = Enum.KeyCode.LeftAlt,
    Callback = function()
        Window:Close()
    end
})

Settings:AddSection("Config")

Settings:AddToggle({
    Name = "Load Config",
    Description = "Loads the saved script settings",
    Callback = function(state)
        if state then
            Window:LoadConfig("MalcScripts/Malc Scripts.json")
        end
    end,
})

local SaveConfigCon = nil

Settings:AddToggle({
    Name = "Save Config",
    Description = "Saves the current script settings",
    Callback = function(state)
        if SaveConfigCon then
            SaveConfigCon:Disconnect()
            SaveConfigCon = nil
        end

        if state then
            Window:SaveConfig("MalcScripts", "Malc Scripts.json")

            SaveConfigCon = game.Players.PlayerRemoving:Connect(function(plr)
                if plr.DisplayName == game.Players.LocalPlayer.DisplayName then
                    Window:SaveConfig("MalcScripts", "Malc Scripts.json")
                end
            end)
        end
    end
})

Settings:AddButton({
    Name = "Get Config",
    Description = "Copies the current config to the clipboard",
    Callback = function()
        Window:GetConfig("MalcScripts/Malc Scripts.json")
    end,
})

Settings:AddInput({
    Name = "Input Config",
    Description = "",
    SaveConfig = true,
    Callback = function(text)
        Window:InputConfig("MalcScripts/Malc Scripts.json", text)
    end,
})

Window:Notification({
    Name = "Notification",
    Description = "Game not found in the hub, please select the required script",
    Type = "Notification",
    Duration = 10
})

Window:IsLoadConfig("MalcScripts/Malc Scripts.json")

Window:ScaleForMobileFixed()
