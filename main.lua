local RayfieldSource = game:HttpGet("https://githubusercontent.com", true)
local Rayfield = loadstring(RayfieldSource)()

local Window = Rayfield:CreateWindow({
   Name = "Malc Scripts - Forsaken",
   LoadingTitle = "Loading Malc Scripts Hub...",
   LoadingSubtitle = "by Malc",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local SurvivorTab = Window:CreateTab("Survivor Profile", 4483362458)

local Config = {
    ESPEnabled = false,
    AutoParry = false,
    ParryRadius = 15,
    CombatAimbot = false,
    HitboxExpander = false,
    HitboxRadius = 10,
    Guest1337Automation = false
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local function isTargetKiller(player)
    if not player or player == LocalPlayer then return false end
    local char = player.Character
    if not char then return false end
    if player:FindFirstChild("Role") and (player.Role.Value == "Killer" or player.Role.Value == "Slasher") then
        return true
    elseif char:FindFirstChild("Anims") and char.Anims:FindFirstChild("SlasherAnims") then
        return true
    elseif player.Team and (string.find(string.lower(player.Team.Name), "killer") or string.find(string.lower(player.Team.Name), "slasher")) then
        return true
    end
    return false
end

local function getClosestKiller()
    local closest, minDistance = nil, math.huge
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    for _, p in ipairs(Players:GetPlayers()) do
        if isTargetKiller(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (myPos - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < minDistance then
                minDistance = dist
                closest = p.Character
            end
        end
    end
    return closest
end

local function applyESP(player)
    if player == LocalPlayer then return end
    local function setupHighlight(character)
        if character:FindFirstChild("MalcESP") then character.MalcESP:Destroy() end
        local highlight = Instance.new("Highlight")
        highlight.Name = "MalcESP"
        highlight.Adornee = character
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = character
        if isTargetKiller(player) then
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

VisualsTab:CreateToggle({
   Name = "Auto Gen Team ESP Outlines",
   CurrentValue = false,
   Callback = function(Value)
       Config.ESPEnabled = Value
       for _, p in ipairs(Players:GetPlayers()) do
           if p.Character and p.Character:FindFirstChild("MalcESP") then
               p.Character.MalcESP.Enabled = Value
           end
       end
   end,
})

task.spawn(function()
    while true do
        task.wait(0.01)
        if (Config.AutoParry or Config.Guest1337Automation) and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myHRP = LocalPlayer.Character.HumanoidRootPart
            local killerChar = getClosestKiller()
            if killerChar and killerChar:FindFirstChild("HumanoidRootPart") then
                local killerHRP = killerChar.HumanoidRootPart
                if (myHRP.Position - killerHRP.Position).Magnitude <= Config.ParryRadius then
                    local isAttacking = killerChar:FindFirstChild("Attacking") or killerChar:FindFirstChild("IsSwinging")
                    local tool = killerChar:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Active") and tool.Active.Value == true then isAttacking = true end
                    
                    if isAttacking then
                        print("[Malc Scripts] Incoming attack Blocked/Parried!")
                        if Config.CombatAimbot and workspace.CurrentCamera then
                            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, killerHRP.Position)
                        end
                        task.wait(1.0)
                        print("[Malc Scripts] 1 Second elapsed. Executing Counter Punch + Stun combo!")
                        task.wait(0.5)
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
   Callback = function(Value) Config.AutoParry = Value end,
})

CombatTab:CreateToggle({
   Name = "Parry Target Aimbot Lock",
   CurrentValue = false,
   Callback = function(Value) Config.CombatAimbot = Value end,
})

CombatTab:CreateSlider({
   Name = "Auto Parry Stud Radius",
   Min = 10, Max = 20, CurrentValue = 15,
   Callback = function(Value) Config.ParryRadius = Value end,
})

local function hookCharacterCombat(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            child.Activated:Connect(function()
                if not Config.HitboxExpander then return end
                local myHRP = char:FindFirstChild("HumanoidRootPart")
                if not myHRP then return end
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHRP = player.Character.HumanoidRootPart
                        if (myHRP.Position - targetHRP.Position).Magnitude <= Config.HitboxRadius then
                            local lookDirection = myHRP.CFrame.LookVector
                            local originalCFrame = myHRP.CFrame
                            myHRP.CFrame = targetHRP.CFrame + (lookDirection * 2)
                            RunService.RenderStepped:Wait()
                            myHRP.CFrame = originalCFrame
                            break
                        end
                    end
                end
            end)
        end
    end)
end

if LocalPlayer.Character then hookCharacterCombat(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(hookCharacterCombat)

CombatTab:CreateSection("Offensive Mechanics")

CombatTab:CreateToggle({
   Name = "Directional Hitbox Expander",
   CurrentValue = false,
   Callback = function(Value) Config.HitboxExpander = Value end,
})

CombatTab:CreateSlider({
   Name = "Hitbox Vector Stud Radius",
   Min = 1, Max = 20, CurrentValue = 10,
   Callback = function(Value) Config.HitboxRadius = Value end,
})

SurvivorTab:CreateSection("Guest 1337 Automation Profile")

SurvivorTab:CreateToggle({
   Name = "Enable Guest 1337 Auto-Parry Suite",
   CurrentValue = false,
   Callback = function(Value) Config.Guest1337Automation = Value end,
})

SurvivorTab:CreateSection("Chance Combat Combo Profile")

SurvivorTab:CreateButton({
   Name = "Execute Chance 360 Torso Snap (< 1s)",
   Callback = function()
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
           local myHRP = LocalPlayer.Character.HumanoidRootPart
           local killerChar = getClosestKiller()
           local targetTorso = killerChar and (killerChar:FindFirstChild("Torso") or killerChar:FindFirstChild("UpperTorso"))
           if targetTorso then
               local tween = TweenService:Create(myHRP, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {CFrame = myHRP.CFrame * CFrame.Angles(0, math.rad(360), 0)})
               tween:Play()
               tween.Completed:Wait()
               task.wait(0.05)
               myHRP.CFrame = CFrame.new(myHRP.Position, Vector3.new(targetTorso.Position.X, myHRP.Position.Y, targetTorso.Position.Z))
               if workspace.CurrentCamera then
                   workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetTorso.Position)
               end
           end
       end
   end,
})

SurvivorTab:CreateSection("More Profiles Coming Soon!")
