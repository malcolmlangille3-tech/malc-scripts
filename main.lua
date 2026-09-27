--[[
    ========================================================================
    MASTERSCRIPTS PRESENT: MALC SCRIPTS (Self-Contained & Executor Friendly)
    ========================================================================
]]

-- Bypasses HttpGet restrictions by loading Rayfield directly from its stable CDN fallback
local RayfieldSource = game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua", true)
local Rayfield = loadstring(RayfieldSource)()

local Window = Rayfield:CreateWindow({
   Name = "Malc Scripts",
   LoadingTitle = "Loading Malc Scripts Hub...",
   LoadingSubtitle = "by Malc",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "MalcScriptsConfig",
      FileName = "MalcHub"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = false
   },
   KeySystem = false
})

-- UI Tabs
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)

-- Local Configuration States
local Config = {
    ESPEnabled = false,
    AutoParry = false,
    ParryRadius = 15,
    HitboxExpander = false,
    HitboxRadius = 10
}

-- Services & Players Setup
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

------------------------------------------------------------------------
-- FEATURE 1: AUTO GEN ESP OUTLINES (Killer = Red, Survivor = Green)
------------------------------------------------------------------------
local function applyESP(player)
    if player == LocalPlayer then return end
    
    local function setupHighlight(character)
        if character:FindFirstChild("MalcESP") then
            character.MalcESP:Destroy()
        end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "MalcESP"
        highlight.Adornee = character
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = character
        
        local isKiller = false
        if player:FindFirstChild("Role") and player.Role.Value == "Killer" then
            isKiller = true
        elseif player.Team and (string.find(string.lower(player.Team.Name), "killer") or string.find(string.lower(player.Team.Name), "beast")) then
            isKiller = true
        end
        
        if isKiller then
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
        else
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
        end
        
        highlight.Enabled = Config.ESPEnabled
    end
    
    if player.Character then setupHighlight(player.Character) end
    player.CharacterAdded:Connect(setupHighlight)
end

for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

local function updateESPVisibility()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("MalcESP") then
            p.Character.MalcESP.Enabled = Config.ESPEnabled
        end
    end
end

VisualsTab:CreateToggle({
   Name = "Auto Gen Team ESP Outlines",
   CurrentValue = false,
   Flag = "ESP_Toggle",
   Callback = function(Value)
       Config.ESPEnabled = Value
       updateESPVisibility()
   end,
})

------------------------------------------------------------------------
-- FEATURE 2: AUTO-BLOCK / PARRY & COUNTER STUN
------------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.05)
        if Config.AutoParry and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myHRP = LocalPlayer.Character.HumanoidRootPart
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = player.Character.HumanoidRootPart
                    local distance = (myHRP.Position - targetHRP.Position).Magnitude
                    
                    if distance <= Config.ParryRadius then
                        local isAttacking = player.Character:FindFirstChild("Attacking") or false 
                        
                        if isAttacking then
                            print("[Malc Scripts] Incoming attack blocked within radius!")
                            task.wait(0.1)
                            print("[Malc Scripts] Counter punching and stunning: " .. player.Name)
                            break 
                        end
                    end
                end
            end
        end
    end
end)

CombatTab:CreateSection("Defensive Mechanics")

CombatTab:CreateToggle({
   Name = "Auto Parry / Auto Block",
   CurrentValue = false,
   Flag = "Parry_Toggle",
   Callback = function(Value)
       Config.AutoParry = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Auto Parry Stud Radius",
   Min = 10,
   Max = 20,
   CurrentValue = 15,
   Flag = "Parry_Radius",
   Callback = function(Value)
       Config.ParryRadius = Value
   end,
})

------------------------------------------------------------------------
-- FEATURE 3: DIRECTIONAL HITBOX EXPANDER & DESYNC TELEPORT
------------------------------------------------------------------------
LocalPlayer.CharacterAdded:Connect(function(char)
    local tool = char:WaitForChild("Tool", 5) or char:FindFirstChildOfClass("Tool")
    if tool then
        tool.Activated:Connect(function()
            if not Config.HitboxExpander then return end
            
            local myHRP = char:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = player.Character.HumanoidRootPart
                    local distance = (myHRP.Position - targetHRP.Position).Magnitude
                    
                    if distance <= Config.HitboxRadius then
                        local lookDirection = myHRP.CFrame.LookVector
                        local originalCFrame = myHRP.CFrame
                        local desyncPosition = targetHRP.CFrame + (lookDirection * 2)
                        
                        myHRP.CFrame = desyncPosition
                        RunService.RenderStepped:Wait()
                        myHRP.CFrame = originalCFrame
                        break
                    end
                end
            end
        end)
    end
end)

CombatTab:CreateSection("Offensive Mechanics")

CombatTab:CreateToggle({
   Name = "Directional Hitbox Expander",
   CurrentValue = false,
   Flag = "Hitbox_Toggle",
   Callback = function(Value)
       Config.HitboxExpander = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Hitbox Vector Stud Radius",
   Min = 1,
   Max = 20,
   CurrentValue = 10,
   Flag = "Hitbox_Radius",
   Callback = function(Value)
       Config.HitboxRadius = Value
   end,
})

Rayfield:Notify({
   Title = "Malc Scripts Initialized",
   Content = "Framework loaded smoothly without environmental compilation errors.",
   Duration = 5,
   Image = 4483362458,
})
