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
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualInputManager = game:GetService("VirtualInputManager") -- Used to simulate real keypresses safely

_G.ESP_Enabled = false
_G.Autogen_Enabled = false
_G.Autogen_Speed = 1.5
_G.AutoBlock_Enabled = false
_G.Hitbox_Enabled = false
_G.Hitbox_Multiplier = 1

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
                     -- Dynamic role checking via attributes or team names
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
-- 5. FARM: PROXIMITY-BASED AUTO GENERATOR
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
                     -- Scans the entire map for interactable prompts matching progress/objectives
                     for _, desc in pairs(workspace:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") then
                           -- Target object names related to generators or repairs
                           if string.lower(desc.Parent.Name):find("gen") or string.lower(desc.ObjectText):find("repair") or string.lower(desc.ActionText):find("fix") then
                              local dist = (desc.Parent.Position - myChar.HumanoidRootPart.Position).Magnitude
                              if dist < 25 then -- Must be nearby to interact safely without bans
                                 desc:InputHoldBegin()
                                 task.wait(_G.Autogen_Speed)
                                 desc:InputHoldEnd()
                              end
                           end
                        end
                     end
                  end
               end)
               task.wait(0.5)
            end
         end)
      end
   end,
})

-- ========================================================
-- 6. COMBAT: SIMULATED INPUT AUTO BLOCK & STUN
-- ========================================================
CombatTab:CreateToggle({
   Name = "Auto Block & Stun Parry",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoBlock_Enabled = Value
      if Value then
         task.spawn(function()
            while _G.AutoBlock_Enabled do
               local character = LocalPlayer.Character
               if character and character:FindFirstChild("HumanoidRootPart") then
                  local killer = nil
                  -- Find nearest player matching Killer criteria
                  for _, player in pairs(Players:GetPlayers()) do
                     if player ~= LocalPlayer and (player:GetAttribute("Role") == "Killer" or (player.Team and string.lower(player.Team.Name):find("killer"))) then
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                           local dist = (player.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                           if dist < 18 then -- Attack warning boundary
                              killer = player
                              break
                           end
                        end
                     end
                  end
                  
                  if killer then
                     -- Forcefully trigger right-click or F key (standard block inputs for Roblox horror combat engines)
                     VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                     
                     task.wait(1)
                     
                     if _G.AutoBlock_Enabled and killer.Character and killer.Character:FindFirstChild("HumanoidRootPart") then
                        -- Snap look vector right at the killer
                        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, killer.Character.HumanoidRootPart.Position)
                        
                        -- Lift the block shield and immediately punch back to stun
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0) -- Client-side Left Click attack simulation
                        task.wait(0.1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                     end
                  end
               end
               task.wait(0.1)
            end
         end)
      end
   end,
})

-- ========================================================
-- 7. COMBAT: DIRECTIONAL HITBOX EXPANDER
-- ========================================================
CombatTab:CreateSlider({
   Name = "Hitbox Range (Desync Multiplier)",
   Range = {1, 50},
   Increment = 1,
   Suffix = " Studs",
   CurrentValue = 1,
   Callback = function(Value)
      _G.Hitbox_Multiplier = Value
   end,
})

CombatTab:CreateToggle({
   Name = "Directional Hitbox Expander",
   CurrentValue = false,
   Callback = function(Value)
      _G.Hitbox_Enabled = Value
      if Value then
         RunService:BindToRenderStep("MalcHitbox", Enum.RenderPriority.Character.Value, function()
            if not _G.Hitbox_Enabled then return end
            
            local myChar = LocalPlayer.Character
            if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
            
            for _, player in pairs(Players:GetPlayers()) do
               if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                  local isSurvivor = player:GetAttribute("Role") == "Survivor" or (player.Team and string.lower(player.Team.Name):find("survivor"))
                  if isSurvivor then
                     local targetHRP = player.Character.HumanoidRootPart
                     local myHRP = myChar.HumanoidRootPart
                     
                     local survivorLookDirection = targetHRP.CFrame.LookVector
                     local desiredOffsetPosition = targetHRP.Position - (survivorLookDirection * (_G.Hitbox_Multiplier * 0.5))
                     
                     pcall(function()
                        targetHRP.CFrame = CFrame.new(desiredOffsetPosition, myHRP.Position)
                     end)
                  end
               end
            end
         end)
      else
         RunService:UnbindFromRenderStep("MalcHitbox")
      end
   end,
})
