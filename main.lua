-- 1. LOAD THE RAYFIELD FRAMEWORK CLEANLY
local Rayfield = loadstring(game:HttpGet('https://githubusercontent.com'))()

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

-- GLOBALS FOR VALUES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_G.ESP_Enabled = false
_G.Autogen_Enabled = false
_G.Hitbox_Enabled = false

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
-- 5. FARM: SEED BUTTON FOR AUTOGEN
-- ========================================================
FarmTab:CreateButton({
   Name = "Trigger Manual Repair",
   Callback = function()
      pcall(function()
         for _, desc in pairs(workspace:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
               if string.lower(desc.Parent.Name):find("gen") or string.lower(desc.ObjectText):find("repair") then
                  desc:InputHoldBegin()
                  task.wait(0.5)
                  desc:InputHoldEnd()
               end
            end
         end
      end)
   end,
})

-- ========================================================
-- 6. COMBAT: SIMPLIFIED BASIC HITBOX
-- ========================================================
CombatTab:CreateToggle({
   Name = "Basic Hitbox Expander",
   CurrentValue = false,
   Callback = function(Value)
      _G.Hitbox_Enabled = Value
      if Value then
         task.spawn(function()
            while _G.Hitbox_Enabled do
               for _, player in pairs(Players:GetPlayers()) do
                  if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                     player.Character.HumanoidRootPart.Size = Vector3.new(15, 15, 15)
                     player.Character.HumanoidRootPart.Transparency = 0.7
                     player.Character.HumanoidRootPart.CanCollide = false
                  end
               end
               task.wait(1)
            end
         end)
      else
         for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               player.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
               player.Character.HumanoidRootPart.Transparency = 1
               player.Character.HumanoidRootPart.CanCollide = true
            end
         end
      end
   end,
})
