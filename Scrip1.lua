-- ==============================================
-- 🏷️ THE CRAFT HUB — Roblox Script
-- 🎨 Theme: Dark Blue + Black | Glass UI
-- ==============================================

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ======================
-- 🎨 UI THEME SETTINGS
-- ======================
local Theme = {
    Primary = Color3.fromHex("#0F172A"),    -- น้ำเงินเข้มมาก
    Secondary = Color3.fromHex("#1E293B"),  -- น้ำเงินเข้ม
    Accent = Color3.fromHex("#3B82F6"),     -- น้ำเงินสด
    AccentLight = Color3.fromHex("#60A5FA"),
    Text = Color3.fromHex("#F8FAFC"),
    TextDim = Color3.fromHex("#94A3B8"),
    Black = Color3.fromHex("#000000"),
    Transparent = Color3.fromHex("#000000")
}

-- ======================
-- 📦 CREATE UI WINDOW
-- ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Toggle Button (แสดงตลอด มุมขวาบน)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleButton"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Theme.Accent
ToggleBtn.BackgroundTransparency = 0.1
ToggleBtn.Position = UDim2.new(0.96, 0, 0.02, 0)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "⚙️"
ToggleBtn.TextColor3 = Theme.Text
ToggleBtn.TextScaled = true
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoLocalize = false

-- Main Window
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Parent = ScreenGui
MainWindow.BackgroundColor3 = Theme.Primary
MainWindow.BackgroundTransparency = 0.05
MainWindow.BorderSizePixel = 0
MainWindow.Position = UDim2.new(0.02, 0, 0.05, 0)
MainWindow.Size = UDim2.new(0, 380, 0, 520)
MainWindow.ClipsDescendants = true
MainWindow.Visible = true
MainWindow.AutoLocalize = false

-- Window Shadow & Corner
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainWindow

local UIShadow = Instance.new("UIGradient")
UIShadow.Rotation = 90
UIShadow.Transparency = NumberSequence.new{0, 0.15}
UIShadow.Parent = MainWindow

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainWindow
TitleBar.BackgroundColor3 = Theme.Accent
TitleBar.BackgroundTransparency = 0
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.Size = UDim2.new(1, 0, 0, 55)
TitleBar.AutoLocalize = false

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
TitleLabel.Size = UDim2.new(0.9, 0, 0, 28)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "🔷 THE CRAFT HUB"
TitleLabel.TextColor3 = Theme.Text
TitleLabel.TextSize = 22
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.AutoLocalize = false

local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = TitleBar
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.new(0.05, 0, 0.82, 0)
SubTitle.Size = UDim2.new(0.9, 0, 0, 14)
SubTitle.Font = Enum.Font.Gotham
SubTitle.Text = "Steal an Egg • All-in-One Script"
SubTitle.TextColor3 = Color3.fromHex("#BFDBFE")
SubTitle.TextSize = 11
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.AutoLocalize = false

-- Scroll Container
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Name = "ScrollContainer"
ScrollContainer.Parent = MainWindow
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.Position = UDim2.new(0, 0, 0, 65)
ScrollContainer.Size = UDim2.new(1, 0, 1, -75)
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.ScrollBarColor3 = Theme.Accent
ScrollContainer.AutoLocalize = false

local ButtonLayout = Instance.new("UIListLayout")
ButtonLayout.Parent = ScrollContainer
ButtonLayout.Padding = UDim.new(0, 10)
ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local ButtonPadding = Instance.new("UIPadding")
ButtonPadding.Parent = ScrollContainer
ButtonPadding.PaddingTop = UDim.new(0, 5)
ButtonPadding.PaddingBottom = UDim.new(0, 15)

-- ======================
-- 🔄 TOGGLE UI FUNCTION
-- ======================
local UI_Enabled = true
ToggleBtn.MouseButton1Click:Connect(function()
    UI_Enabled = not UI_Enabled
    MainWindow.Visible = UI_Enabled
    ToggleBtn.Text = UI_Enabled and "⚙️" or "🔒"
end)

-- Drag Function
local function makeDraggable(frame)
    local dragToggle, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end) end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(MainWindow)
makeDraggable(ToggleBtn)

-- ======================
-- 🧩 CREATE BUTTON SYSTEM
-- ======================
local Buttons = {}
local Toggles = {}

local function CreateButton(name, desc, callback)
    local btn = Instance.new("TextButton")
    btn.Name = "Btn_"..name
    btn.Parent = ScrollContainer
    btn.BackgroundColor3 = Theme.Secondary
    btn.BackgroundTransparency = 0.3
    btn.Size = UDim2.new(0.92, 0, 0, 55)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = ""
    btn.TextColor3 = Theme.Text
    btn.AutoLocalize = false
    btn.AutoButtonColor = false

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    local btnName = Instance.new("TextLabel")
    btnName.Parent = btn
    btnName.BackgroundTransparency = 1
    btnName.Position = UDim2.new(0.04, 0, 0.2, 0)
    btnName.Size = UDim2.new(0.8, 0, 0, 20)
    btnName.Font = Enum.Font.GothamBold
    btnName.Text = name
    btnName.TextColor3 = Theme.Text
    btnName.TextSize = 15
    btnName.TextXAlignment = Enum.TextXAlignment.Left
    btnName.AutoLocalize = false

    local btnDesc = Instance.new("TextLabel")
    btnDesc.Parent = btn
    btnDesc.BackgroundTransparency = 1
    btnDesc.Position = UDim2.new(0.04, 0, 0.55, 0)
    btnDesc.Size = UDim2.new(0.8, 0, 0, 14)
    btnDesc.Font = Enum.Font.Gotham
    btnDesc.Text = desc
    btnDesc.TextColor3 = Theme.TextDim
    btnDesc.TextSize = 11
    btnDesc.TextXAlignment = Enum.TextXAlignment.Left
    btnDesc.AutoLocalize = false

    local status = Instance.new("Frame")
    status.Parent = btn
    status.BackgroundColor3 = Color3.fromHex("#64748B")
    status.Position = UDim2.new(0.91, 0, 0.3, 0)
    status.Size = UDim2.new(0, 14, 0, 14)
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(1,0)
    statusCorner.Parent = status

    local isActive = false
    btn.MouseButton1Click:Connect(function()
        isActive = not isActive
        status.BackgroundColor3 = isActive and Theme.Accent or Color3.fromHex("#64748B")
        btn.BackgroundTransparency = isActive and 0.15 or 0.3
        callback(isActive)
    end)

    table.insert(Buttons, btn)
    ScrollContainer.CanvasSize = UDim2.new(0,0,0, #Buttons * 65)
end

-- ======================
-- 🎯 ALL FUNCTION BUTTONS
-- ======================
CreateButton("🥚 Auto Steal Egg", "ขโมยไข่อัตโนมัติ", function(state)
    _G.AutoSteal = state
    print("[THE CRAFT HUB] Auto Steal Egg:", state and "✅ ON" or "❌ OFF")
end)

CreateButton("🎯 Auto Steal All", "ขโมยทุกไข่ในระยะ", function(state)
    _G.AutoStealAll = state
    print("[THE CRAFT HUB] Auto Steal All:", state and "✅ ON" or "❌ OFF")
end)

CreateButton("💎 Steal Big Eggs Only", "ขโมยเฉพาะไข่ขนาดใหญ่", function(state)
    _G.OnlyBigEggs = state
    print("[THE CRAFT HUB] Steal Big Eggs Only:", state and "✅ ON" or "❌ OFF")
end)

CreateButton("👁️ Egg ESP", "แสดงตำแหน่งไข่ทั้งหมด", function(state)
    _G.EggESP = state
    print("[THE CRAFT HUB] Egg ESP:", state and "✅ ON" or "❌ OFF")
end)

CreateButton("👁️ Guard ESP", "แสดงตำแหน่งการ์ด", function(state)
    _G.GuardESP = state
    print("[THE CRAFT HUB] Guard ESP:", state and "✅ ON" or "❌ OFF")
end)

CreateButton("💰 Auto Sell Eggs", "ขายไข่อัตโนมัติ", function(state)
    _G.AutoSell = state
    print("[THE CRAFT HUB] Auto Sell Eggs:", state and "✅ ON" or "❌ OFF")
end)

CreateButton("⚡ Auto Fuse Pets", "ผสานสัตว์เลี้ยงอัตโนมัติ", function(state)
    _G.AutoFuse = state
    print("[THE CRAFT HUB] Auto Fuse Pets:", state and "✅ ON" or "❌ OFF")
end)

CreateButton("🖥️ Auto Server Hop", "ย้ายเซิร์ฟเวอร์อัตโนมัติ", function(state)
    _G.AutoHop = state
    print("[THE CRAFT HUB] Auto Server Hop:", state and "✅ ON" or "❌ OFF")
end)

CreateButton("🏃 Walk Speed", "ปรับความเร็วการเดิน", function(state)
    if state then
        LocalPlayer.Character.Humanoid.WalkSpeed = 32
    else
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
    print("[THE CRAFT HUB] Walk Speed:", state and "⚡ FAST" or "🐾 NORMAL")
end)

CreateButton("🛡️ Anti-AFK", "ป้องกันหลุดจากเซิร์ฟ", function(state)
    _G.AntiAFK = state
    print("[THE CRAFT HUB] Anti-AFK:", state and "✅ ON" or "❌ OFF")
end)

CreateButton("📊 Webhook Alerts", "ส่งแจ้งเตือนไป Discord", function(state)
    _G.Webhook = state
    print("[THE CRAFT HUB] Webhook Alerts:", state and "✅ ON" or "❌ OFF")
end)

CreateButton("⚙️ Settings & Config", "ตั้งค่าทั้งหมด", function(state)
    print("[THE CRAFT HUB] Settings Opened")
end)

CreateButton("ℹ️ Info / Discord", "ข้อมูลเพิ่มเติม", function(state)
    print("[THE CRAFT HUB] Discord: Coming Soon!")
end)

-- ======================
-- 🛡️ ANTI-AFK LOOP
-- ======================
spawn(function()
    while task.wait(60) do
        if _G.AntiAFK then
            UIS:SetFocusOverride()
            LocalPlayer.Character.Humanoid:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position)
        end
    end
end)

-- ======================
-- ✅ LOADED
-- ======================
print(" ")
print("🔷 THE CRAFT HUB — LOADED SUCCESSFULLY")
print("📋 Total Functions: "..#Buttons)
print("🎨 Theme: Dark Blue & Black")
print("🔘 Toggle Button: Top-Right Corner")
print(" ")
