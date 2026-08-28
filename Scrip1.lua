-- [[ THE CRAFT HUB | CYBER LIGHTNING GLASS EDITION ]] --
-- [[ Game: Steal an Egg / Ouroboros Script Hub ]] --
-- [[ Theme: Blue Glassmorphism + Lightning Particle Effects ]] --

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "⚡ THE CRAFT HUB | Cyber Blue Glass ⚡",
   Icon = 0,
   LoadingTitle = "THE CRAFT HUB Loading...",
   LoadingSubtitle = "by Craft Team",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TheCraftHubConfig",
      FileName = "CraftBlueGlass"
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false
})

-- Global Glass Blur & Lighting Setup
local BackgroundBlur = Instance.new("BlurEffect")
BackgroundBlur.Name = "CraftGlassBlur"
BackgroundBlur.Size = 8
BackgroundBlur.Parent = game:GetService("Lighting")

-- Create Visual Lightning Aura Effect around Player Character
local LightningAttachment = Instance.new("Attachment")
local LightningParticles = Instance.new("ParticleEmitter")

local function setupLightningAura(player)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp then
        LightningAttachment.Name = "CraftLightningAttachment"
        LightningAttachment.Parent = hrp

        LightningParticles.Name = "CraftLightningParticles"
        LightningParticles.Texture = "rbxassetid://258122976" -- Spark / Lightning Texture
        LightningParticles.Color = ColorSequence.new(Color3.fromRGB(0, 200, 255), Color3.fromRGB(0, 100, 255))
        LightningParticles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0)})
        LightningParticles.Lifetime = NumberRange.new(0.1, 0.4)
        LightningParticles.Rate = 25
        LightningParticles.Speed = NumberRange.new(2, 6)
        LightningParticles.Enabled = true
        LightningParticles.Parent = LightningAttachment
    end
end

-- Custom Cyan/Blue Glass Styling Overrides with Animated Border
local LightningStrokeLoop
task.spawn(function()
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui.Name == "Rayfield" or gui:FindFirstChild("Main") then
            local main = gui:FindFirstChild("Main", true)
            if main then
                main.BackgroundColor3 = Color3.fromRGB(10, 20, 40)
                main.BackgroundTransparency = 0.2
                main.BorderSizePixel = 0

                -- Add Neon Blue Glow Border
                local UIStroke = main:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
                UIStroke.Color = Color3.fromRGB(0, 170, 255)
                UIStroke.Thickness = 2
                UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                UIStroke.Parent = main

                -- Animated Lightning Pulse Effect
                LightningStrokeLoop = task.spawn(function()
                    while task.wait(0.5) do
                        TweenService:Create(UIStroke, TweenInfo.new(0.25), {Color = Color3.fromRGB(0, 255, 255), Thickness = 3}):Play()
                        task.wait(0.25)
                        TweenService:Create(UIStroke, TweenInfo.new(0.25), {Color = Color3.fromRGB(0, 120, 255), Thickness = 1.5}):Play()
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
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Internal Toggle States
local States = {
    AutoStealAll = false,
    AutoStealSelected = false,
    StealBigEggs = false,
    AutoSellEggs = false,
    AutoPlaceAll = false,
    AutoTreadmill = false,
    AutoEquipBestGear = false,
    AutoUpgrades = false,
    AutoClaimGroupReward = false,
    AutoClaimIndex = false,
    PlayerESP = false,
    LightningAura = false,
    AntiAFK = true,
    WalkSpeed = 16,
    StealSpeed = 1,
    SellInterval = 60
}

local ESP_Storage = {}

--------------------------------------------------------------------------------
-- CORE UTILITY & SCRIPT FUNCTIONS
--------------------------------------------------------------------------------

local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Function: Anti-AFK
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        if States.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end
    end)
end)

-- Function 1: Auto Steal All Eggs
local function runAutoStealAll()
    while States.AutoStealAll do
        task.wait(0.1)
        local hrp = getRoot()
        if hrp then
            local eggsFolder = workspace:FindFirstChild("Eggs") or workspace:FindFirstChild("Plots")
            if eggsFolder then
                for _, egg in pairs(eggsFolder:GetDescendants()) do
                    if not States.AutoStealAll then break end
                    if egg:IsA("BasePart") and egg.Name:lower():find("egg") then
                        hrp.CFrame = egg.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.2 / States.StealSpeed)
                    end
                end
            end
        end
    end
end

-- Function 2: Auto Steal Selected Eggs
local function runAutoStealSelected(selectedEggName)
    while States.AutoStealSelected do
        task.wait(0.1)
        local hrp = getRoot()
        if hrp and selectedEggName then
            local eggsFolder = workspace:FindFirstChild("Eggs") or workspace:FindFirstChild("Plots")
            if eggsFolder then
                for _, egg in pairs(eggsFolder:GetDescendants()) do
                    if not States.AutoStealSelected then break end
                    if egg.Name == selectedEggName and egg:IsA("BasePart") then
                        hrp.CFrame = egg.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.2 / States.StealSpeed)
                    end
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
            local eggsFolder = workspace:FindFirstChild("Eggs") or workspace:FindFirstChild("Plots")
            if eggsFolder then
                for _, egg in pairs(eggsFolder:GetDescendants()) do
                    if not States.StealBigEggs then break end
                    if egg:IsA("Model") or egg:IsA("BasePart") then
                        local scale = egg:GetAttribute("Scale") or egg.Size.Y
                        if scale and scale > 3 then
                            local targetPart = egg:IsA("Model") and egg.PrimaryPart or egg
                            if targetPart then
                                hrp.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
                                task.wait(0.3)
                            end
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
        local sellArea = workspace:FindFirstChild("SellArea") or workspace:FindFirstChild("SellZone")
        if hrp and sellArea then
            local oldCFrame = hrp.CFrame
            hrp.CFrame = sellArea.CFrame + Vector3.new(0, 3, 0)
            task.wait(1)
            hrp.CFrame = oldCFrame
        end
    end
end

-- Function 5: Auto Place All Eggs
local function runAutoPlaceEggs()
    while States.AutoPlaceAll do
        task.wait(0.5)
        local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
        local placeRemote = remotes:FindFirstChild("PlaceEgg") or remotes:FindFirstChild("RequestPlaceEgg")
        if placeRemote then
            placeRemote:FireServer()
        end
    end
end

-- Function 6: Auto Treadmill
local function runAutoTreadmill()
    while States.AutoTreadmill do
        task.wait(0.1)
        local hrp = getRoot()
        local treadmill = workspace:FindFirstChild("Treadmill") or workspace:FindFirstChild("TreadmillBottom")
        if hrp and treadmill then
            hrp.CFrame = treadmill.CFrame + Vector3.new(0, 2, 0)
        end
    end
end

-- Function 7: Auto Equip Best
local function runAutoEquipBestGear()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
    local equipRemote = remotes:FindFirstChild("EquipBest") or remotes:FindFirstChild("REQUEST_EQUIP_STATIC")
    if equipRemote then
        equipRemote:FireServer()
    end
end

-- Function 8: Auto Upgrades
local function runAutoUpgrades()
    while States.AutoUpgrades do
        task.wait(1)
        local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
        local upgradeRemote = remotes:FindFirstChild("Upgrade") or remotes:FindFirstChild("REQUEST_UPGRADE")
        if upgradeRemote then
            upgradeRemote:FireServer()
        end
    end
end

-- Function 9: Auto Claim Group Rewards
local function runAutoClaimGroupReward()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
    local groupRemote = remotes:FindFirstChild("ClaimGroup") or remotes:FindFirstChild("GroupReward")
    if groupRemote then
        groupRemote:FireServer()
    end
end

-- Function 10: Auto Claim Index
local function runAutoClaimIndex()
    while States.AutoClaimIndex do
        task.wait(2)
        local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
        local claimRemote = remotes:FindFirstChild("ClaimIndex") or remotes:FindFirstChild("REQUEST_CLAIM_ALL")
        if claimRemote then
            claimRemote:FireServer()
        end
    end
end

-- Function 11: Auto Server Hop
local function runAutoServerHop()
    local Api = "https://games.roblox.com/v1/games/"
    local _place = game.PlaceId
    local _servers = Api .. _place .. "/servers/Public?sortOrder=Asc&limit=100"
    
    local function ListServers(cursor)
        local Raw = game:HttpGet(_servers .. ((cursor and "&cursor=" .. cursor) or ""))
        return HttpService:JSONDecode(Raw)
    end
    
    local Server, Next;
    repeat
        local Servers = ListServers(Next)
        Server = Servers.data[math.random(1, #Servers.data)]
        Next = Servers.nextPageCursor
    until Server and Server.playing < Server.maxPlayers and Server.id ~= game.JobId
    
    TeleportService:TeleportToPlaceInstance(_place, Server.id, LocalPlayer)
end

-- Function 12: Player ESP
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
            highlight.FillColor = Color3.fromRGB(0, 200, 255)
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

-- TAB 1: Main Steal & Farm
local MainTab = Window:CreateTab("⚡ Main Steal", 4483362458)

MainTab:CreateSection("Auto Steal Systems")

MainTab:CreateToggle({
   Name = "Auto Steal All Eggs",
   CurrentValue = false,
   Flag = "AutoStealAll",
   Callback = function(Value)
      States.AutoStealAll = Value
      if Value then task.spawn(runAutoStealAll) end
   end,
})

MainTab:CreateToggle({
   Name = "Auto Steal Big Eggs",
   CurrentValue = false,
   Flag = "StealBigEggs",
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
   Flag = "SelectedEggDropdown",
   Callback = function(Option)
      selectedEgg = Option[1]
   end,
})

MainTab:CreateToggle({
   Name = "Auto Steal Selected Egg",
   CurrentValue = false,
   Flag = "AutoStealSelected",
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
   Flag = "StealSpeedSlider",
   Callback = function(Value)
      States.StealSpeed = Value
   end,
})

-- TAB 2: Egg & Plot Management
local ManagementTab = Window:CreateTab("🥚 Management", 4483362458)

ManagementTab:CreateSection("Eggs & Base Management")

ManagementTab:CreateToggle({
   Name = "Auto Place All Eggs",
   CurrentValue = false,
   Flag = "AutoPlaceAll",
   Callback = function(Value)
      States.AutoPlaceAll = Value
      if Value then task.spawn(runAutoPlaceEggs) end
   end,
})

ManagementTab:CreateToggle({
   Name = "Auto Sell Eggs",
   CurrentValue = false,
   Flag = "AutoSellEggs",
   Callback = function(Value)
      States.AutoSellEggs = Value
      if Value then task.spawn(runAutoSellEggs) end
   end,
})

ManagementTab:CreateSlider({
   Name = "Sell Interval (Seconds)",
   Range = {10, 300},
   Increment = 5,
   Suffix = "s",
   CurrentValue = 60,
   Flag = "SellIntervalSlider",
   Callback = function(Value)
      States.SellInterval = Value
   end,
})

-- TAB 3: Upgrades & Fitness
local UpgradeTab = Window:CreateTab("💎 Upgrades & Stats", 4483362458)

UpgradeTab:CreateSection("Auto Upgrades & Gear")

UpgradeTab:CreateToggle({
   Name = "Auto Treadmill (Train)",
   CurrentValue = false,
   Flag = "AutoTreadmill",
   Callback = function(Value)
      States.AutoTreadmill = Value
      if Value then task.spawn(runAutoTreadmill) end
   end,
})

UpgradeTab:CreateButton({
   Name = "Equip Best Gear / Pets Now",
   Callback = function()
      runAutoEquipBestGear()
      Rayfield:Notify({
         Title = "THE CRAFT HUB",
         Content = "Equipped best items successfully!",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

UpgradeTab:CreateToggle({
   Name = "Auto Upgrades",
   CurrentValue = false,
   Flag = "AutoUpgrades",
   Callback = function(Value)
      States.AutoUpgrades = Value
      if Value then task.spawn(runAutoUpgrades) end
   end,
})

UpgradeTab:CreateToggle({
   Name = "Auto Claim Index Rewards",
   CurrentValue = false,
   Flag = "AutoClaimIndex",
   Callback = function(Value)
      States.AutoClaimIndex = Value
      if Value then task.spawn(runAutoClaimIndex) end
   end,
})

UpgradeTab:CreateButton({
   Name = "Claim Group Rewards",
   Callback = function()
      runAutoClaimGroupReward()
      Rayfield:Notify({
         Title = "THE CRAFT HUB",
         Content = "Claimed group reward!",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

-- TAB 4: Visuals, Lightning FX & Unload
local VisualsTab = Window:CreateTab("🌌 FX & Settings", 4483362458)

VisualsTab:CreateSection("Visuals & Character FX")

VisualsTab:CreateToggle({
   Name = "Blue Lightning Character Aura",
   CurrentValue = false,
   Flag = "LightningAuraToggle",
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
   Flag = "PlayerESP",
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
   Flag = "WalkSpeedSlider",
   Callback = function(Value)
      States.WalkSpeed = Value
      local hum = getHumanoid()
      if hum then hum.WalkSpeed = Value end
   end,
})

VisualsTab:CreateSection("Server Utilities")

VisualsTab:CreateButton({
   Name = "Copy JobId / Join Script",
   Callback = function()
      local cmd = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, game.JobId)
      setclipboard(cmd)
      Rayfield:Notify({
         Title = "THE CRAFT HUB",
         Content = "Copied Join Script to Clipboard!",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

VisualsTab:CreateButton({
   Name = "Server Hop",
   Callback = function()
      runAutoServerHop()
   end,
})

VisualsTab:CreateSection("Unload Script")

VisualsTab:CreateButton({
   Name = "🔴 Destroy UI & Unload Script",
   Callback = function()
      -- Reset States
      for k in pairs(States) do
          if type(States[k]) == "boolean" then
              States[k] = false
          end
      end
      
      -- Clear Effects & Loops
      togglePlayerESP(false)
      if LightningParticles then LightningParticles:Destroy() end
      if LightningAttachment then LightningAttachment:Destroy() end
      if BackgroundBlur then BackgroundBlur:Destroy() end
      if LightningStrokeLoop then task.cancel(LightningStrokeLoop) end
      
      local hum = getHumanoid()
      if hum then hum.WalkSpeed = 16 end

      -- Destroy UI
      Rayfield:Destroy()
   end,
})

Rayfield:Notify({
   Title = "THE CRAFT HUB Loaded!",
   Content = "Cyber Blue Glass Edition ready to use.",
   Duration = 5,
   Image = 4483362458,
})
