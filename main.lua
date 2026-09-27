-- 1. LOAD THE RAYFIELD FRAMEWORK
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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

_G.ESP_Enabled = false
_G.Autogen_Enabled = false
_G.Autogen_Speed = 1.5
_G.AutoBlock_Enabled = false
_G.Hitbox_Enabled = false
_G.Hitbox_Multiplier = 1

-- ========================================================
-- 4. VISUALS: OUTLINE-ONLY ESP (RED KILLER / GREEN SURVIVOR)
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
                     local isKiller = player:GetAttribute("Role") == "Killer" or (player.Team and string.lower(player.Team.Name):find("killer"))
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
-- 5. FARM: AUTO GENERATOR WITH CUSTOM SPEED SLIDER
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
                  local remote = workspace:WaitForChild("Map"):WaitForChild("Ingame"):WaitForChild("Map"):WaitForChild("Generator"):WaitForChild("Remotes"):WaitForChild("RE")
                  if remote then
                     remote:FireServer()
                  end
               end) -- FIXED TYPO HERE
               task.wait(_G.Autogen_Speed)
            end
         end)
      end
   end,
})

-- ========================================================
-- 6. COMBAT: AUTO BLOCK & PARRY (1s LOCK-ON + PUNCH STUN)
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
                  for _, player in pairs(Players:GetPlayers()) do
                     if player ~= LocalPlayer and (player:GetAttribute("Role") == "Killer" or (player.Team and string.lower(player.Team.Name):find("killer"))) then
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                           local dist = (player.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                           if dist < 15 then
                              killer = player
                              break
                           end
                        end
                     end
                  end
                  
                  if killer then
                     local blockRemote = character:FindFirstChild("Block") or character:FindFirstChild("Parry")
                     if blockRemote and blockRemote:IsA("RemoteEvent") then
                        blockRemote:FireServer(true)
                     end
                     
                     task.wait(1)
                     if _G.AutoBlock_Enabled and killer.Character and killer.Character:FindFirstChild("HumanoidRootPart") then
                        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, killer.Character.HumanoidRootPart.Position)
                        
                        local attackRemote = character:FindFirstChild("Punch") or character:FindFirstChild("Attack")
                        if attackRemote and attackRemote:IsA("RemoteEvent") then
                           attackRemote:FireServer(killer.Character.HumanoidRootPart.Position)
                        end
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
-- 7. COMBAT: RELATIVE HITBOX EXPANDER (TELEPORT DESYNC)
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
