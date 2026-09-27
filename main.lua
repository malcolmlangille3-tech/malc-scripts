-- 1. LOAD THE RAYFIELD FRAMEWORK
local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

-- 2. CREATE THE MAIN MENU WINDOW
local Window = Rayfield:CreateWindow({
   Name = "Malc Scripts",
   LoadingTitle = "Malc Scripts - Forsaken Hub",
   LoadingSubtitle = "by Malc",
   ConfigurationSaving = { Enabled = false }
})

-- 3. CREATE THE TABS
local VisualsTab = Window:CreateTab("Visuals")
local FarmTab = Window:CreateTab("Farm/Autogen")
local CombatTab = Window:CreateTab("Combat")

-- GLOBALS FOR SCRIPTS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

_G.ESP_Enabled = false
_G.Autogen_Enabled = false
_G.Autogen_Speed = 1.5
_G.AutoBlock_Enabled = false
_G.Hitbox_Enabled = false
_G.Hitbox_Size = 1

-- ========================================================
-- 4. VISUALS: WORKING ROLE OUTLINE ESP
-- ========================================================
VisualsTab:CreateToggle({
   Name = "Role Outline ESP",
   CurrentValue = false,
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
-- 5. FARM: OPTIMIZED AUTO GENERATOR (LAG-FREE)
-- ========================================================
FarmTab:CreateSlider({
   Name = "Autogen Interval (Seconds)",
   Range = {1.5, 10},
   Increment = 0.5,
   Suffix = "s",
   CurrentValue = 1.5,
   Callback = function(Value)
      _G.Autogen_Speed = Value
   end,
})

FarmTab:CreateToggle({
   Name = "Auto Generator",
   CurrentValue = false,
   Callback = function(Value)
      _G.Autogen_Enabled = Value
      if Value then
         task.spawn(function()
            while _G.Autogen_Enabled do
               pcall(function()
                  local myChar = LocalPlayer.Character
                  if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                     -- Optimized to look only inside specific map interactive folders instead of the whole game
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
CombatTab:CreateToggle({
   Name = "Auto Block & Stun Parry",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoBlock_Enabled = Value
      if Value then
         task.spawn(function()
            local isBlocking = false
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
                     -- Physically hold down the Q key
                     VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                     
                     task.wait(1) -- Hold block state for exactly 1 second
                     
                     if _G.AutoBlock_Enabled and killer.Character and killer.Character:FindFirstChild("HumanoidRootPart") then
                        -- Instantly lock the camera directly onto the killer
                        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, killer.Character.HumanoidRootPart.Position)
                        
                        -- Release the Q key to drop block defense
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                        
                        -- Instantly simulate a mouse click to throw the stun punch
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                     end
                     task.wait(1.5) -- Cool down block loop to prevent key spam crashes
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
-- 7. COMBAT: FIXED HITBOX EXPANDER (RESIZES SELECTION ON SCREEN)
-- ========================================================
CombatTab:CreateSlider({
   Name = "Hitbox Size Expansion",
   Range = {1, 50},
   Increment = 1,
   Suffix = " Studs",
   CurrentValue = 1,
   Callback = function(Value)
      _G.Hitbox_Size = Value
   end
})

CombatTab:CreateToggle({
   Name = "Hitbox Expander",
   CurrentValue = false,
   Callback = function(Value)
      _G.Hitbox_Enabled = Value
      if Value then
         task.spawn(function()
            while _G.Hitbox_Enabled do
               for _, player in pairs(Players:GetPlayers()) do
                  if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                     local isSurvivor = player:GetAttribute("Role") == "Survivor" or (player.Team and string.lower(player.Team.Name):find("survivor"))
                     if isSurvivor then
                        -- Correct client logic: expand the physics box size so your weapons hit them anywhere
                        local hrp = player.Character.HumanoidRootPart
                        hrp.Size = Vector3.new(_G.Hitbox_Size, _G.Hitbox_Size, _G.Hitbox_Size)
                        hrp.Transparency = 0.7 -- Dim it slightly so you can see the giant hitbox boundary
                        hrp.CanCollide = false
                     end
                  end
               end
               task.wait(1)
            end
         end)
      else
         -- Reset back to standard default Roblox physics box size when turned off
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
