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
      Enabled = false
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
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Internal Toggle States
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

-- Function Anti-AFK
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        if States.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end
    end)
end)

-- Function ESP
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

-- TAB 1: Main Steal
local MainTab = Window:CreateTab("🌀 Main Steal", 4483362458)

MainTab:CreateSection("Auto Steal Options")

MainTab:CreateToggle({
   Name = "Auto Steal All Eggs",
   CurrentValue = false,
   Callback = function(Value)
      States.AutoStealAll = Value
      if Value then
          task.spawn(function()
              while States.AutoStealAll do
                  task.wait(0.1)
                  local hrp = getRoot()
                  local folder = workspace:FindFirstChild("Eggs") or workspace:FindFirstChild("Plots")
                  if hrp and folder then
                      for _, egg in pairs(folder:GetDescendants()) do
                          if not States.AutoStealAll then break end
                          if egg:IsA("BasePart") and egg.Name:lower():find("egg") then
                              hrp.CFrame = egg.CFrame + Vector3.new(0, 3, 0)
                              task.wait(0.2 / States.StealSpeed)
                          end
                      end
                  end
              end
          end)
      end
   end,
})

MainTab:CreateToggle({
   Name = "Auto Steal Big Eggs",
   CurrentValue = false,
   Callback = function(Value)
      States.StealBigEggs = Value
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

-- TAB 2: Egg Management
local ManagementTab = Window:CreateTab("🥚 Management", 4483362458)

ManagementTab:CreateToggle({
   Name = "Auto Place All Eggs",
   CurrentValue = false,
   Callback = function(Value)
      States.AutoPlaceAll = Value
   end,
})

ManagementTab:CreateToggle({
   Name = "Auto Sell Eggs",
   CurrentValue = false,
   Callback = function(Value)
      States.AutoSellEggs = Value
   end,
})

-- TAB 3: Upgrades
local UpgradeTab = Window:CreateTab("⚡ Upgrades & Stats", 4483362458)

UpgradeTab:CreateButton({
   Name = "Equip Best Gear / Pets Now",
   Callback = function()
      local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
      local remote = remotes:FindFirstChild("EquipBest") or remotes:FindFirstChild("REQUEST_EQUIP_STATIC")
      if remote then remote:FireServer() end
   end,
})

-- TAB 4: Visuals, Server & Unload Script
local VisualsTab = Window:CreateTab("👁 Visuals & Settings", 4483362458)

VisualsTab:CreateSection("Visual Controls")

VisualsTab:CreateToggle({
   Name = "Player Blue Glass ESP",
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

VisualsTab:CreateSection("Unload Script (ปิด UI ทั้งหมด)")

VisualsTab:CreateButton({
   Name = "🔴 Destroy UI & Unload Script (ลบ UI ถาวร)",
   Callback = function()
      -- 1. ปิดฟังก์ชันทำงานทั้งหมด
      for k in pairs(States) do
          if type(States[k]) == "boolean" then
              States[k] = false
          end
      end
      
      -- 2. คืนค่าฟังก์ชั่นและเอฟเฟกต์
      togglePlayerESP(false)
      if BackgroundBlur then BackgroundBlur:Destroy() end
      
      local hum = getHumanoid()
      if hum then hum.WalkSpeed = 16 end

      -- 3. ทำลายหน้าต่าง Rayfield UI ถาวร
      Rayfield:Destroy()
   end,
})

Rayfield:Notify({
   Title = "Ouroboros Blue Glass Hub Loaded",
   Content = "พร้อมใช้งานแล้ว! มีปุ่มปิด UI อยู่ในแท็บ Visuals & Settings",
   Duration = 5,
   Image = 4483362458,
})
