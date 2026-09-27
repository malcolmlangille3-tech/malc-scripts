```lua
--==================================================
-- MALC SCRIPTS
-- Roblox Studio-safe version
--==================================================

if not game:IsLoaded() then
	game.Loaded:Wait()
end

--==================================================
-- GAME DETECTION
--==================================================

local PlaceId = game.PlaceId

local Games = {
	[94641783649173] = "World Of Trollge",
	[75661637882183] = "World Of Trollge",

	[18687417158] = "Forsaken",
	[83645629621104] = "Forsaken",

	[12377995562] = "Trollge Incident Fights Reborn",
	[12801608913] = "Trollge Incident Fights Reborn",
	[13028864053] = "Trollge Incident Fights Reborn",

	[13946738101] = "Trollge Multiverse",

	[70845479499574] = "Bite By Night"
}

local DetectedGame = Games[PlaceId]

if DetectedGame then
	print("Malc Scripts: Detected " .. DetectedGame)
else
	print("Malc Scripts: Game not found.")
end

--==================================================
-- UI LIBRARY
--==================================================

local gui = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/zxcursedsocute/UI-Library/refs/heads/main/UI-Library.txt"
))()

local Window = gui.CreateWindow(
	"Malc Scripts - Main",
	"",
	"590",
	"v 1.0"
)

Window:SetSavePath(
	"MalcScripts",
	"Malc Scripts.json"
)

--==================================================
-- SCRIPTS TAB
--==================================================

local ScriptsTab = Window:AddTab("Scripts", "Misc")

ScriptsTab:AddParagraph(
	"Detected Game",
	DetectedGame or "No supported game detected"
)

ScriptsTab:AddButton({
	Name = "Forsaken",
	Description = "Forsaken",
	Callback = function()
		print("Malc Scripts: Forsaken selected.")
	end
})

ScriptsTab:AddButton({
	Name = "Fish It",
	Description = "Fish It",
	Callback = function()
		print("Malc Scripts: Fish It selected.")
	end
})

ScriptsTab:AddButton({
	Name = "Trollge Multiverse",
	Description = "Trollge Multiverse",
	Callback = function()
		print("Malc Scripts: Trollge Multiverse selected.")
	end
})

ScriptsTab:AddButton({
	Name = "Trollge Incident Fights Reborn",
	Description = "Trollge Incident Fights Reborn",
	Callback = function()
		print("Malc Scripts: Trollge Incident Fights Reborn selected.")
	end
})

ScriptsTab:AddButton({
	Name = "World Of Trollge",
	Description = "World Of Trollge",
	Callback = function()
		print("Malc Scripts: World Of Trollge selected.")
	end
})

ScriptsTab:AddButton({
	Name = "Bite By Night",
	Description = "Bite By Night",
	Callback = function()
		print("Malc Scripts: Bite By Night selected.")
	end
})

--==================================================
-- SETTINGS TAB
--==================================================

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

Settings:AddToggle({
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

Settings:AddToggle({
	Name = "Transparency",
	Description = "Change the background transparency",

	Callback = function()
		Window:ChangeBackgroundTransparance()
	end
})

Settings:AddToggle({
	Name = "User Info",
	Description = "Show information about your account",

	Callback = function()
		Window:UserInfo()
	end
})

Settings:AddToggle({
	Name = "Search",
	Description = "Show the search",

	Callback = function()
		Window:ShowSearch()
	end
})

--==================================================
-- WINDOW SETTINGS
--==================================================

Settings:AddSection("Window")

Settings:AddKeybind({
	Name = "Minimize Window",
	Description = "Minimize the window",
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
	Description = "Close the window",

	Default = Enum.KeyCode.LeftAlt,

	Callback = function()
		Window:Close()
	end
})

--==================================================
-- CONFIG
--==================================================

Settings:AddSection("Config")

Settings:AddToggle({
	Name = "Load Config",
	Description = "Load the saved settings",

	Callback = function(state)
		if state then
			Window:LoadConfig(
				"MalcScripts/Malc Scripts.json"
			)
		end
	end
})

local SaveConfigCon = nil

Settings:AddToggle({
	Name = "Save Config",
	Description = "Save the current settings",

	Callback = function(state)

		if SaveConfigCon then
			SaveConfigCon:Disconnect()
			SaveConfigCon = nil
		end

		if state then

			Window:SaveConfig(
				"MalcScripts",
				"Malc Scripts.json"
			)

			SaveConfigCon =
				game.Players.PlayerRemoving:Connect(function(plr)

					if plr == game.Players.LocalPlayer then

						Window:SaveConfig(
							"MalcScripts",
							"Malc Scripts.json"
						)

					end

				end)
		end
	end
})

Settings:AddButton({
	Name = "Get Config",
	Description = "Copy the current config",

	Callback = function()
		Window:GetConfig(
			"MalcScripts/Malc Scripts.json"
		)
	end
})

Settings:AddInput({
	Name = "Input Config",
	Description = "",
	SaveConfig = true,

	Callback = function(text)
		Window:InputConfig(
			"MalcScripts/Malc Scripts.json",
			text
		)
	end
})

--==================================================
-- STARTUP NOTIFICATION
--==================================================

Window:Notification({
	Name = "Malc Scripts",

	Description =
		DetectedGame
		and ("Detected: " .. DetectedGame)
		or "No supported game detected.",

	Type = "Notification",
	Duration = 10
})

Window:IsLoadConfig(
	"MalcScripts/Malc Scripts.json"
)

Window:ScaleForMobileFixed()
```
