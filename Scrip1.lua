-- [[ THE CRAFT HUB | ULTIMATE BLUE GLASS LIGHTNING EDITION ]] --
-- [[ Game: Steal an Egg / Ouroboros Script Hub ]] --
-- [[ Features: Fully Working Logic + UI Toggle + Cyber FX ]] --

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "⚡ THE CRAFT HUB | Blue Glass ⚡",
   Icon = 0,
   LoadingTitle = "THE CRAFT HUB Loading...",
   LoadingSubtitle = "by Craft Team",
   ConfigurationSaving = {
      Enabled = false
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false
})

--------------------------------------------------------------------------------
-- UI TOGGLE BUTTON (ปุ่มเปิด-ปิด UI บนหน้าจอ และ ปุ่ม K)
--------------------------------------------------------------------------------
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CraftHubToggleGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleButton"
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 110, 0, 38)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(10, 25, 45)
ToggleBtn.BackgroundTransparency = 0.2
ToggleBtn.Text = "⚡ CRAFT [K]"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 230, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(0, 170, 255)
BtnStroke.Thickness = 2
BtnStroke.Parent = ToggleBtn

local uiVisible = true
local function toggleUI()
    uiVisible = not uiVisible
    local mainUI = CoreGui:FindFirstChild("Rayfield") or CoreGui:FindFirstChild("Main", true)
    if mainUI then
        mainUI.Enabled = uiVisible
    end
end

ToggleBtn.MouseButton1Click:Connect(toggleUI)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
        toggleUI()
    end
end)

--------------------------------------------------------------------------------
-- VISUAL STYLING & LIGHTNING EFFECTS
--------------------------------------------------------------------------------
local Lighting = game:GetService("Lighting")
local BackgroundBlur = Instance.new("BlurEffect")
BackgroundBlur.Name = "CraftGlassBlur"
BackgroundBlur.Size = 6
BackgroundBlur.Parent = Lighting

local LightningAttachment = Instance.new("Attachment")
local LightningParticles = Instance.new("ParticleEmitter")

local function setupLightningAura(player)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp then
        LightningAttachment.Name = "CraftLightningAttachment"
        LightningAttachment.Parent = hrp

        LightningParticles.Name = "CraftLightningParticles"
        LightningParticles.Texture = "rbxassetid://258122976"
        LightningParticles.Color = ColorSequence.new(Color3.fromRGB(0, 230, 255), Color3.fromRGB(0, 100, 255))
        LightningParticles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0)})
        LightningParticles.Lifetime = NumberRange.new(0.1, 0.35)
        LightningParticles.Rate = 35
        LightningParticles.Speed = NumberRange.new(3, 8)
        LightningParticles.Enabled = true
        LightningParticles.Parent = LightningAttachment
    end
end

local LightningStrokeLoop
task.spawn(function()
    local TweenService = game:GetService("TweenService")
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui.Name == "Rayfield" or gui:FindFirstChild("Main") then
            local main = gui:FindFirstChild("Main", true)
            if main then
                main.BackgroundColor3 = Color3.fromRGB(8, 16, 32)
                main.BackgroundTransparency = 0.2
                
                local UIStroke = main:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
                UIStroke.Color = Color3.fromRGB(0, 170, 255)
                UIStroke.Thickness = 2
                UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                UIStroke.Parent = main

                LightningStrokeLoop = task.spawn(function()
                    while task.wait(0.4) do
                        TweenService:Create(UIStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(0, 255, 255), Thickness = 2.5}):Play()
                        task.wait(0.2)
                        TweenService:Create(UIStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(0, 120, 255), Thickness = 1.5}):Play()
                    end
                end)
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- SERVICES & GLOBAL VARIABLES
--------------------------------------------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local States = {
    AutoStealAll = false,
    AutoStealSelected = false,
    StealBigEggs = false,
    AutoSellEggs = false,
    AutoPlaceAll = false,
    AutoTreadmill = false,
    AutoUpgrades = false,
    AutoClaimIndex = false,
    PlayerESP = false,
    LightningAura = false,
    AntiAFK = true,
    WalkSpeed = 16,
    StealSpeed = 1,
    SellInterval = 15
}

local ESP_Storage = {}

--------------------------------------------------------------------------------
-- WORKING DIRECT LOGIC FUNCTIONS
--------------------------------------------------------------------------------

local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Helper Dynamic Remote Finder
local function fireRemote(possibleNames)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, name in pairs(possibleNames) do
                if v.Name:lower():find(name:lower()) then
                    if v:IsA("RemoteEvent") then
                        v:FireServer()
                    elseif v:IsA("RemoteFunction") then
                        pcall(function() v:InvokeServer() end)
                    end
                    return true
                end
            end
        end
    end
    return false
end

-- Anti-AFK
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        if States.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end
    end)
end)

-- Real Working Steal System (Proximity & Teleport Combined)
local function stealTarget(part)
    local hrp = getRoot()
    if hrp and part then
        hrp.CFrame = part.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.05)
        
        -- Fire any nearby interaction triggers (ProximityPrompt)
        for _, prompt in pairs(part:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                fireproximityprompt(prompt)
            end
        end
        if part.Parent then
            for _, prompt in pairs(part.Parent:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    fireproximityprompt(prompt)
                end
            end
        end
    end
end

-- Function 1: Auto Steal All Eggs
local function runAutoStealAll()
    while States.AutoStealAll do
        task.wait(0.1 / States.StealSpeed)
        local hrp = getRoot()
        if hrp then
            local targets = {}
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("egg") and not obj:IsDescendantOf(LocalPlayer.Character) then
                    table.insert(targets, obj)
                end
            end
            
            for _, eggPart in pairs(targets) do
                if not States.AutoStealAll then break end
                stealTarget(eggPart)
                task.wait(0.1 / States.StealSpeed)
            end
        end
    end
end

-- Function 2: Auto Steal Selected Egg
local function runAutoStealSelected(selectedName)
    while States.AutoStealSelected do
        task.wait(0.1 / States.StealSpeed)
        local hrp = getRoot()
        if hrp and selectedName then
            for _, obj in pairs(workspace:GetDescendants()) do
                if not States.AutoStealSelected then break end
                if obj.Name:lower() == selectedName:lower() and obj:IsA("BasePart") then
                    stealTarget(obj)
                    task.wait(0.1 / States.StealSpeed)
                end
            end
        end
    end
end

-- Function 3: Auto Steal Big Eggs
local function runAutoStealBigEggs()
    while States.StealBigEggs do
        task.wait(0.2)
        local hrp = getRoot()
        if hrp then
            for _, obj in pairs(workspace:GetDescendants()) do
                if not States.StealBigEggs then break end
                if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("egg") then
                    local sizeY = obj:IsA("BasePart") and obj.Size.Y or (obj.PrimaryPart and obj.PrimaryPart.Size.Y or 0)
                    if sizeY > 3 then
                        local target = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                        if target then
                            stealTarget(target)
                            task.wait(0.2)
                        end
                    end
                end
            end
        end
    end
end

-- Function 4: Auto Sell Eggs
local function runAutoSellEggs()
    while States.AutoSellEggs do
        task.wait(States.SellInterval)
        local hrp = getRoot()
        local sellZone = workspace:FindFirstChild("SellZone", true) or workspace:FindFirstChild("SellArea", true) or workspace:FindFirstChild("Sell", true)
        
        if hrp and sellZone then
            local oldCF = hrp.CFrame
            local targetPart = sellZone:IsA("Model") and (sellZone.PrimaryPart or sellZone:FindFirstChildWhichIsA("BasePart")) or sellZone
            if targetPart then
                hrp.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.8)
                fireRemote({"sell", "selleggs", "drop"})
                task.wait(0.5)
                hrp.CFrame = oldCF
            end
        else
            fireRemote({"sell", "selleggs", "drop"})
        end
    end
end

-- Function 5: Auto Place Eggs
local function runAutoPlaceEggs()
    while States.AutoPlaceAll do
        task.wait(0.4)
        fireRemote({"place", "placeegg", "putegg", "claimplot"})
    end
end

-- Function 6: Auto Treadmill
local function runAutoTreadmill()
    while States.AutoTreadmill do
        task.wait(0.1)
        local hrp = getRoot()
        local treadmill = workspace:FindFirstChild("Treadmill", true) or workspace:FindFirstChild("Train", true)
        if hrp and treadmill then
            local targetPart = treadmill:IsA("Model") and (treadmill.PrimaryPart or treadmill:FindFirstChildWhichIsA("BasePart")) or treadmill
            if targetPart then
                hrp.CFrame = targetPart.CFrame + Vector3.new(0, 2.5, 0)
            end
        end
        fireRemote({"train", "treadmill", "addspeed", "workout"})
    end
end

-- Function 7: Auto Upgrades
local function runAutoUpgrades()
    while States.AutoUpgrades do
        task.wait(1)
        fireRemote({"upgrade", "upgradespeed", "upgradestat", "buy"})
    end
end

-- Function 8: Auto Claim Index
local function runAutoClaimIndex()
    while States.AutoClaimIndex do
        task.wait(2)
        fireRemote({"index", "claimindex", "reward", "claim"})
    end
end

-- Function 9: ESP
local function togglePlayerESP(enabled)
    if not enabled then
        for _, v in pairs(ESP_Storage) do
            if v then v:Destroy() end
        end
        ESP_Storage = {}
        return
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = Instance.new("Highlight")
            highlight.Name = "CraftBlueESP"
            highlight.FillColor = Color3.fromRGB(0, 220, 255)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.4
            highlight.Parent = player.Character
            table.insert(ESP_Storage, highlight)
        end
    end
end

--------------------------------------------------------------------------------
-- UI TABS & CONTROLS
--------------------------------------------------------------------------------

-- TAB 1: Main Steal
local MainTab = Window:CreateTab("⚡ Main Steal", 4483362458)

MainTab:CreateSection("Auto Steal Systems")

MainTab:CreateToggle({
   Name = "Auto Steal All Eggs",
   CurrentValue = false,
   Callback = function(Value)
      States.AutoStealAll = Value
      if Value then task.spawn(runAutoStealAll) end
   end,
})

MainTab:CreateToggle({
   Name = "Auto Steal Big Eggs",
   CurrentValue = false,
   Callback = function(Value)
      States.StealBigEggs = Value
      if Value then task.spawn(runAutoStealBigEggs) end
   end,
})

local selectedEgg = "Epic Egg"
MainTab:CreateDropdown({
   Name = "Select Specific Egg",
   Options = {"Common Egg", "Rare Egg", "Epic Egg", "Legendary Egg", "Mythic Egg"},
   CurrentOption = {"Epic Egg"},
   MultipleOptions = false,
   Callback = function(Option)
      selectedEgg = Option[1]
   end,
})

MainTab:CreateToggle({
   Name = "Auto Steal Selected Egg",
   CurrentValue = false,
   Callback = function(Value)
      States.AutoStealSelected = Value
      if Value then task.spawn(function() runAutoStealSelected(selectedEgg) end) end
   end,
})

MainTab:CreateSlider({
   Name = "Steal Speed Multiplier",
   Range = {1, 10},
   Increment = 1,
   Suffix = "x",
   CurrentValue = 1,
   Callback = function(Value)
      States.StealSpeed = Value
   end,
})

-- TAB 2: Management
local ManagementTab = Window:CreateTab("🥚 Management", 4483362458)

ManagementTab:CreateSection("Eggs & Base Management")

ManagementTab:CreateToggle({
   Name = "Auto Place All Eggs",
   CurrentValue = false,
   Callback = function(Value)
      States.AutoPlaceAll = Value
      if Value then task.spawn(runAutoPlaceEggs) end
   end,
})

ManagementTab:CreateToggle({
   Name = "Auto Sell Eggs",
   CurrentValue = false,
   Callback = function(Value)
      States.AutoSellEggs = Value
      if Value then task.spawn(runAutoSellEggs) end
   end,
})

ManagementTab:CreateSlider({
   Name = "Sell Interval (Seconds)",
   Range = {5, 120},
   Increment = 5,
   Suffix = "s",
   CurrentValue = 15,
   Callback = function(Value)
      States.SellInterval = Value
   end,
})

-- TAB 3: Upgrades
local UpgradeTab = Window:CreateTab("💎 Upgrades & Stats", 4483362458)

UpgradeTab:CreateSection("Auto Upgrades & Gear")

UpgradeTab:CreateToggle({
   Name = "Auto Treadmill (Train)",
   CurrentValue = false,
   Callback = function(Value)
      States.AutoTreadmill = Value
      if Value then task.spawn(runAutoTreadmill) end
   end,
})

UpgradeTab:CreateButton({
   Name = "Equip Best Gear / Pets Now",
   Callback = function()
      fireRemote({"equipbest", "equip", "best"})
      Rayfield:Notify({
         Title = "THE CRAFT HUB",
         Content = "Triggered Equip Best Items!",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

UpgradeTab:CreateToggle({
   Name = "Auto Upgrades",
   CurrentValue = false,
   Callback = function(Value)
      States.AutoUpgrades = Value
      if Value then task.spawn(runAutoUpgrades) end
   end,
})

UpgradeTab:CreateToggle({
   Name = "Auto Claim Index Rewards",
   CurrentValue = false,
   Callback = function(Value)
      States.AutoClaimIndex = Value
      if Value then task.spawn(runAutoClaimIndex) end
   end,
})

-- TAB 4: FX & Settings
local VisualsTab = Window:CreateTab("🌌 FX & Settings", 4483362458)

VisualsTab:CreateSection("Visuals & FX Controls")

VisualsTab:CreateToggle({
   Name = "Blue Lightning Character Aura",
   CurrentValue = false,
   Callback = function(Value)
      States.LightningAura = Value
      if Value then
         setupLightningAura(LocalPlayer)
      else
         LightningParticles.Enabled = false
      end
   end,
})

VisualsTab:CreateToggle({
   Name = "Cyan Player ESP",
   CurrentValue = false,
   Callback = function(Value)
      States.PlayerESP = Value
      togglePlayerESP(Value)
   end,
})

VisualsTab:CreateSlider({
   Name = "WalkSpeed Modifier",
   Range = {16, 200},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 16,
   Callback = function(Value)
      States.WalkSpeed = Value
      local hum = getHumanoid()
      if hum then hum.WalkSpeed = Value end
   end,
})

VisualsTab:CreateSection("Unload Script")

VisualsTab:CreateButton({
   Name = "🔴 Destroy UI & Unload Script",
   Callback = function()
      for k in pairs(States) do
          if type(States[k]) == "boolean" then
              States[k] = false
          end
      end
      
      togglePlayerESP(false)
      if LightningParticles then LightningParticles:Destroy() end
      if LightningAttachment then LightningAttachment:Destroy() end
      if BackgroundBlur then BackgroundBlur:Destroy() end
      if LightningStrokeLoop then task.cancel(LightningStrokeLoop) end
      if ScreenGui then ScreenGui:Destroy() end
      
      local hum = getHumanoid()
      if hum then hum.WalkSpeed = 16 end

      Rayfield:Destroy()
   end,
})

Rayfield:Notify({
   Title = "THE CRAFT HUB Ready!",
   Content = "กดปุ่ม [⚡ CRAFT] หรือกด 'K' เพื่อ ซ่อน/แสดง UI ได้ตลอดเวลา",
   Duration = 5,
   Image = 4483362458,
})
