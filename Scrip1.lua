-- ==============================================
--         🟦 THE CRAFT HUB (FIXED UI) 🟦
--         Auto Steal Egg & Utilities
-- ==============================================

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ลบ UI เก่าออกก่อนป้องกันการรันซ้ำ
if PlayerGui:FindFirstChild("TheCraftHub") then
    PlayerGui.TheCraftHub:Destroy()
end

-- ==============================================
-- 📂 STEP 1: ORIGINAL DATA
-- ==============================================
local adv = {
    "runAutoClaimIndex", 3198., 1327, 2518,
    "htmpks", "pet_", 1000000, "clas", "ConfigurationBox",
    "Auto Steal Egg", "EspAnchor", 1910, "gauge", task.spawn, 2431
}

print("✅ โค้ดต้นฉบับพร้อมใช้งาน")

-- ==============================================
-- 🎨 STEP 2: UI THEME — BLUE GLASS STYLE
-- ==============================================
local UITheme = {
    Primary = Color3.fromRGB(0, 153, 255),
    Secondary = Color3.fromRGB(0, 204, 255),
    Accent = Color3.fromRGB(0, 102, 204),
    Background = Color3.fromRGB(10, 22, 40),
    Glass = Color3.fromRGB(15, 42, 72),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(153, 204, 255)
}

-- ==============================================
-- 📦 CREATE MAIN UI WINDOW
-- ==============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main Window
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 340, 0, 480)
MainWindow.Position = UDim2.new(0.5, -170, 0.5, -240) -- จัดให้อยู่กลางจอพอดี
MainWindow.BackgroundColor3 = UITheme.Background
MainWindow.BackgroundTransparency = 0.1
MainWindow.Active = true
MainWindow.Draggable = true
MainWindow.ClipsDescendants = true
MainWindow.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainWindow

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = UITheme.Primary
UIStroke.Thickness = 1.5
UIStroke.Parent = MainWindow

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = UITheme.Glass
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainWindow

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(1, -50, 0, 26)
TitleText.Position = UDim2.new(0, 14, 0, 6)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🟦 THE CRAFT HUB"
TitleText.TextColor3 = UITheme.Text
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Name = "SubTitle"
SubTitle.Size = UDim2.new(1, -50, 0, 16)
SubTitle.Position = UDim2.new(0, 14, 0, 28)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Auto Steal Egg & Utilities"
SubTitle.TextColor3 = UITheme.TextDim
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 11
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -15)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = UITheme.TextDim
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TitleBar

-- Scroll Container
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Name = "ScrollContainer"
ScrollContainer.Size = UDim2.new(1, -16, 1, -62)
ScrollContainer.Position = UDim2.new(0, 8, 0, 56)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.ScrollBarColor3 = UITheme.Primary
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollContainer.Parent = MainWindow

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.VerticalAlignment = Enum.VerticalAlignment.Top
Layout.Parent = ScrollContainer

-- ==============================================
-- 🎯 TOGGLE BUTTON COMPONENT
-- ==============================================
local function CreateToggle(name, defaultState, callback)
    local Container = Instance.new("Frame")
    Container.Name = name.."_Container"
    Container.Size = UDim2.new(1, -8, 0, 45)
    Container.BackgroundColor3 = UITheme.Glass
    Container.BackgroundTransparency = 0.4
    Container.Parent = ScrollContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = UITheme.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Toggle = Instance.new("TextButton")
    Toggle.Name = "Toggle"
    Toggle.Size = UDim2.new(0, 44, 0, 22)
    Toggle.Position = UDim2.new(1, -52, 0.5, -11)
    Toggle.BackgroundColor3 = defaultState and UITheme.Primary or Color3.fromRGB(42, 59, 85)
    Toggle.Text = ""
    Toggle.Parent = Container

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = Toggle

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = defaultState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.Parent = Toggle

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local state = defaultState

    local function ToggleState()
        state = not state
        TweenService:Create(Toggle, TweenInfo.new(0.15), {BackgroundColor3 = state and UITheme.Primary or Color3.fromRGB(42, 59, 85)}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
        if callback then callback(state) end
    end

    Toggle.MouseButton1Click:Connect(ToggleState)
    
    return Container
end

-- ==============================================
-- ⚙️ FEATURE SYSTEM & TOGGLES
-- ==============================================
local Features = {}

local StealLoop = nil
local function StartSteal()
    if StealLoop then return end
    StealLoop = task.spawn(function()
        while Features["Auto Steal Egg"] or Features["Auto Steal All"] do
            task.wait(0.15)
            local Char = LocalPlayer.Character
            if not Char then continue end
            local Root = Char:FindFirstChild("HumanoidRootPart")
            if not Root then continue end

            for _, v in workspace:GetChildren() do
                if v.Name:find("egg_") or v.Name:find("pet_") then
                    local PR = v.PrimaryPart or v:FindFirstChild("HumanoidRootPart")
                    if PR then
                        local Dist = (Root.Position - PR.Position).Magnitude
                        if Dist < 15 then
                            Root.CFrame = CFrame.new(PR.Position)
                            break
                        end
                    end
                end
            end
        end
        StealLoop = nil
    end)
end

local ToggleList = {
    "🥚 Auto Steal Egg",
    "🎯 Auto Steal All",
    "⚔️ Auto Equip Best Gear",
    "📥 Auto Claim Rewards",
    "🪺 Auto Place Eggs",
    "🎁 Auto Claim Group Reward",
    "🌐 Auto Server Hop",
    "🏃 Auto Treadmill",
    "👁️ ESP Carried Eggs",
    "✨ ESP Highlight",
    "📡 Webhook Egg Spawns",
    "💾 Remember Visited",
    "⚡ Apply FPS Cap",
    "🛡️ Anti Gameplay Pause"
}

for _, name in ipairs(ToggleList) do
    CreateToggle(name, false, function(state)
        Features[name] = state
        if (name == "🥚 Auto Steal Egg" or name == "🎯 Auto Steal All") and state then
            StartSteal()
        end
    end)
end

-- ==============================================
-- ❌ CLOSE BUTTON ACTION
-- ==============================================
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

print("🟦 THE CRAFT HUB — โหลด UI สำเร็จเรียบร้อย!")
