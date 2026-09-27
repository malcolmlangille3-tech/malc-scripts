-- 1. LOAD THE UNIVERSALLY SUPPORTED ORION FRAMEWORK
local OrionLib = loadstring(game:HttpGet(("https://githubusercontent.com")))()

-- 2. CREATE THE MAIN WINDOW
local Window = OrionLib:MakeWindow({
    Name = "Malc Scripts", 
    HidePremium = false, 
    SaveConfig = false, 
    IntroText = "Loading Malc Scripts..."
})

-- 3. CREATE THE TABS
local VisualsTab = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483345998"})
local FarmTab = Window:CreateTab and Window:MakeTab({Name = "Farm/Autogen", Icon = "rbxassetid://4483345998"}) or Window:MakeTab({Name = "Farm", Icon = "rbxassetid://4483345998"})
local CombatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})

-- GLOBALS FOR VALUES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_G.ESP_Enabled = false
_G.Autogen_Enabled = false
_G.Autogen_Speed = 1.5
_G.AutoBlock_Enabled = false
_G.Hitbox_Enabled = false
_G.Hitbox_Size = 1

-- ========================================================
-- 4. VISUALS: WORKING ROLE OUTLINE ESP (RED/GREEN)
-- ========================================================
VisualsTab:AddToggle({
   Name = "Role Outline ESP",
   Default = false,
   Callback = function(Value)
      _G.ESP_Enabled = Value
      if Value then
         task.spawn(function()
            while _G.ESP_Enabled do
               for _, player in pairs(Players:GetPlayers()) do
                  if player ~= LocalPlayer and player.Character then
                     local isKiller = player:GetAttribute("Role") == "Killer" or player:GetAttribute("IsKiller") == true or (player.Team and string.lower(player.Team.Name):find("killer"))
                     local targetColor = isKiller and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                     
                     local hl = player.Character:FindFirstChild("MalcESP")
                     if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "MalcESP"
                        hl.Parent = player.Character
                     end
                     hl.FillColor = targetColor
                     hl.FillTransparency = 1
                     hl.OutlineColor = targetColor
                     hl.OutlineTransparency = 0
                  end
               end
               task.wait(1)
            end
         end)
      else
         for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("MalcESP") then
               player.Character.MalcESP:Destroy()
            end
         end
      end
   end,
})

-- ========================================================
-- 5. FARM: OPTIMIZED AUTO GENERATOR
-- ========================================================
FarmTab:AddSlider({
   Name = "Autogen Interval (Seconds)",
   Min = 1.5,
   Max = 10,
   Increment = 0.5,
   Default = 1.5,
   ValueName = "s",
   Callback = function(Value)
      _G.Autogen_Speed = Value
   end,
})

FarmTab:AddToggle({
   Name = "Auto Generator",
   Default = false,
   Callback = function(Value)
      _G.Autogen_Enabled = Value
      if Value then
         task.spawn(function()
            while _G.Autogen_Enabled do
               pcall(function()
                  local myChar = LocalPlayer.Character
                  if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                     local mapDir = workspace:FindFirstChild("Map") or workspace
                     for _, desc in pairs(mapDir:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") then
                           local nameLower = string.lower(desc.Parent.Name)
                           local objLower = string.lower(desc.ObjectText)
                           if nameLower:find("gen") or objLower:find("repair") or objLower:find("fix") then
                              local dist = (desc.Parent.Position - myChar.HumanoidRootPart.Position).Magnitude
                              if dist < 20 then
                                 desc:InputHoldBegin()
                                 task.wait(_G.Autogen_Speed)
                                 desc:InputHoldEnd()
                              end
                           end
                        end
                     end
                  end
               end)
               task.wait(1)
            end
         end)
      end
   end,
})

-- ========================================================
-- 6. COMBAT: FIX AUTO BLOCK (Q KEY) & AUTO STUN PUNCH
-- ========================================================
CombatTab:AddToggle({
   Name = "Auto Block & Stun Parry",
   Default = false,
   Callback = function(Value)
      _G.AutoBlock_Enabled = Value
      if Value then
         task.spawn(function()
            local isBlocking = false
            local VirtualInputManager = game:GetService("VirtualInputManager")
            while _G.AutoBlock_Enabled do
               local character = LocalPlayer.Character
               if character and character:FindFirstChild("HumanoidRootPart") then
                  local killer = nil
                  for _, player in pairs(Players:GetPlayers()) do
                     if player ~= LocalPlayer and (player:GetAttribute("Role") == "Killer" or (player.Team and string.lower(player.Team.Name):find("killer"))) then
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                           local dist = (player.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                           if dist < 18 then
                              killer = player
                              break
                           end
                        end
                     end
                  end
                  
                  if killer and not isBlocking then
                     isBlocking = true
                     VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                     task.wait(1)
                     
                     if _G.AutoBlock_Enabled and killer.Character and killer.Character:FindFirstChild("HumanoidRootPart") then
                        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, killer.Character.HumanoidRootPart.Position)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                        
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                     end
                     task.wait(1.5)
                     isBlocking = false
                  end
               end
               task.wait(0.1)
            end
         end)
      end
   end,
})

-- ========================================================
-- 7. COMBAT: HITBOX EXPANDER
-- ========================================================
CombatTab:AddSlider({
   Name = "Hitbox Size Expansion",
   Min = 1,
   Max = 50,
   Increment = 1,
   Default = 1,
   ValueName = "Studs",
   Callback = function(Value)
      _G.Hitbox_Size = Value
   end,
})

CombatTab:AddToggle({
   Name = "Hitbox Expander",
   Default = false,
   Callback = function(Value)
      _G.Hitbox_Enabled = Value
      if Value then
         task.spawn(function()
            while _G.Hitbox_Enabled do
               for _, player in pairs(Players:GetPlayers()) do
                  if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                     local isSurvivor = player:GetAttribute("Role") == "Survivor" or (player.Team and string.lower(player.Team.Name):find("survivor"))
                     if isSurvivor then
                        local hrp = player.Character.HumanoidRootPart
                        hrp.Size = Vector3.new(_G.Hitbox_Size, _G.Hitbox_Size, _G.Hitbox_Size)
                        hrp.Transparency = 0.7
                        hrp.CanCollide = false
                     end
                  end
               end
               task.wait(1)
            end
         end)
      else
         for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               local hrp = player.Character.HumanoidRootPart
               hrp.Size = Vector3.new(2, 2, 1)
               hrp.Transparency = 1
               hrp.CanCollide = true
            end
         end
      end
   end,
})

-- REQUIRED INITIALIZATION FOR ORION CLOSING FRAMEWORK
OrionLib:Init()
