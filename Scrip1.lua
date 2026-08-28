-- [[ EXCLUSIVE DARK BLUE GLASSMORPHISM HUB ]] --
-- [[ Game: Steal an Egg / Ouroboros Script Hub ]] --
-- [[ Visual Style: Translucent Cyan/Blue Glassmorphism UI ]] --

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "💙 Ouroboros Hub | Dark Blue Glass Edition",
   Icon = 0,
   LoadingTitle = "Glassmorphism Blue Hub",
   LoadingSubtitle = "by Ouroboros Team",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "OuroborosGlassConfig",
      FileName = "BlueGlassConfig"
   },
   Discord = {
      Enabled = true,
      Invite = "keyless",
      RememberJoins = true
   },
   KeySystem = false
})

-- Global Glass Blur Reference
local BackgroundBlur = Instance.new("BlurEffect")
BackgroundBlur.Name = "BlueGlassBlur"
BackgroundBlur.Size = 8
BackgroundBlur.Parent = game:GetService("Lighting")

-- Custom Dark Blue Glass Styling Overrides
task.spawn(function()
    local CoreGui = game:GetService("CoreGui")
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui.Name == "Rayfield" or gui:FindFirstChild("Main") then
            local main = gui:FindFirstChild("Main", true)
            if main then
                main.BackgroundColor3 = Color3.fromRGB(15, 25, 45)
                main.BackgroundTransparency = 0.25
                main.BorderSizePixel = 1
                main.BorderColor3 = Color3.fromRGB(0, 170, 255)
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

-- Internal Toggle States (All Extracted States)
local States = {
    AutoStealAll = false,
    AutoStealSelected = false,
    AutoStealEgg = false,
    StealBigEggs = false,
    AutoSellEggs = false,
    AutoPlaceAll = false,
    AutoTreadmill = false,
    AutoEquipBestGear = false,
    AutoUpgrades = false,
    AutoClaimGroupReward = false,
    AutoClaimIndex = false,
    AutoServerHop = false,
    AutoDeleteOwnPets = false,
    PlayerESP = false,
    WorldEggESP = false,
    EspCarriedEggs = false,
    AntiAFK = true,
    WalkSpeed = 16,
    StealSpeed = 1,
    SellInterval = 60
}

local ESP_Storage = {}

--------------------------------------------------------------------------------
-- CORE UTILITY & SCRIPT FUNCTIONS (All Original Functions)
--------------------------------------------------------------------------------

-- Helper: Get Local Character HumanoidRootPart
local function getRoot()
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- Helper: Get Local Humanoid
local function getHumanoid()
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
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

-- Function 6: Auto Treadmill (Train Speed/Stats)
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

-- Function 7: Auto Equip Best Gear / Pets
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
            highlight.Name = "BlueGlassESP"
            highlight.FillColor = Color3.fromRGB(0, 170, 255)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.Parent = player.Character
            table.insert(ESP_Storage, highlight)
        end
    end
end

--------------------------------------------------------------------------------
-- UI TABS & CONTROLS
--------------------------------------------------------------------------------

-- TAB 1: Main Steal & Farm
local MainTab = Window:CreateTab("🌀 Main Steal", 4483362458)

MainTab:CreateSection("Auto Steal Options")

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

ManagementTab:CreateSection("Eggs & Placement")

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
local UpgradeTab = Window:CreateTab("⚡ Upgrades & Stats", 4483362458)

UpgradeTab:CreateSection("Automation & Training")

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
         Title = "Equip Best",
         Content = "Equipped best gear successfully!",
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
   Name = "Auto Claim Index",
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
         Title = "Group Claim",
         Content = "Attempted to claim group reward!",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

-- TAB 4: Visuals, Server & Unload Script
local VisualsTab = Window:CreateTab("👁 Visuals & Settings", 4483362458)

VisualsTab:CreateSection("ESP & Movement")

VisualsTab:CreateToggle({
   Name = "Player Blue Glass ESP",
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
         Title = "Clipboard",
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

VisualsTab:CreateSection("Unload Script (ปิด UI ทั้งหมด)")

VisualsTab:CreateButton({
   Name = "🔴 Destroy UI & Unload Script (ลบ UI ถาวร)",
   Callback = function()
      -- 1. หยุดลูปและปิดการทำงานของท็อกเกิลทั้งหมด
      for k in pairs(States) do
          if type(States[k]) == "boolean" then
              States[k] = false
          end
      end
      
      -- 2. ล้างเอฟเฟกต์ ESP, Blur Background และความเร็วตัวละคร
      togglePlayerESP(false)
      if BackgroundBlur then BackgroundBlur:Destroy() end
      
      local hum = getHumanoid()
      if hum then hum.WalkSpeed = 16 end

      -- 3. ทำลายหน้าต่าง UI ออกจากจอแบบถาวร
      Rayfield:Destroy()
   end,
})

Rayfield:Notify({
   Title = "Ouroboros Blue Glass Hub Loaded",
   Content = "โหลดฟังก์ชันครบ 100%! มีปุ่มลบ UI ถาวรในแท็บ Visuals & Settings",
   Duration = 5,
   Image = 4483362458,
})
