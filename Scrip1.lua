--[[
    THE CRAFT HUB - สคริปต์อเนกประสงค์
    รองรับภาษา: ไทย / English
    UI: น้ำเงิน-ดำ เท่ๆ
    แก้ไขให้ UI แสดงผลทันที
]]

-- ==================== การตั้งค่าหลัก ====================
local ScriptName = "THE CRAFT HUB"
local Version = "2.0.0"
local Language = "TH" -- TH / EN

-- ==================== Services ====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

-- ==================== ระบบภาษา ====================
local Translations = {
    TH = {
        mainTitle = "THE CRAFT HUB",
        version = "เวอร์ชัน 2.0.0",
        category_event = "⚡ อีเว้น",
        category_steal = "🥚 ขโมยไข่",
        category_esp = "👁️ มองทะลุ",
        category_movement = "🏃 การเคลื่อนไหว",
        category_combat = "⚔️ ต่อสู้",
        category_server = "🌐 เซิฟเวอร์",
        category_misc = "🔧 อื่นๆ",
        btn_refresh = "รีเฟรช",
        btn_clear = "ล้าง ESP",
        btn_server_hop = "สุ่มเซิฟ",
        btn_zone_refresh = "รีเฟรชโซน",
        toggle_on = "เปิด",
        toggle_off = "ปิด",
        -- ฟีเจอร์
        feat_auto_tree = "ตีต้นไม้อัตโนมัติ (small)",
        feat_steal_monster = "ขโมยไข่ MonsterParasiteVisual",
        feat_loot_treadmill = "เสกลู่วิ่ง AdminTreadmill",
        feat_steal_fx = "ขโมยไข่ที่มีไฟล์ FX",
        feat_auto_steal = "ขโมยไข่อัตโนมัติ",
        feat_anti_drop = "กันไข่หลุด (กด E อัตโนมัติ)",
        feat_fast_pickup = "เก็บไข่เร็ว (กดครั้งเดียว)",
        feat_zigzag = "ซิกแซกตอนขโมยไข่",
        feat_esp_egg = "มองทะลุไข่",
        feat_esp_player = "มองทะลุผู้เล่น",
        feat_speed = "ปรับความเร็ว",
        feat_high_jump = "กระโดดสูง",
        feat_infinite_jump = "กระโดดไม่จำกัด",
        feat_fast_attack = "ตีไว (ถืออาวุธ)",
        feat_no_knockback = "ไม่กระเด็น",
        feat_zone_select = "เลือกโซนขโมยไข่",
        -- ป้ายกำกับ
        speed_label = "ความเร็ว:",
        jump_label = "พลังกระโดด:",
        zone_label = "โซนเป้าหมาย:",
        status_running = "กำลังทำงาน...",
        status_stopped = "หยุดทำงาน",
        no_target = "ไม่พบเป้าหมาย",
        found_target = "พบเป้าหมาย: ",
        stealing = "กำลังขโมย: ",
        returning = "กำลังกลับฐาน...",
        no_character = "ไม่พบตัวละคร",
        esp_cleared = "ล้าง ESP แล้ว",
        zones_found = "พบโซน: ",
        no_zones = "ไม่พบโซน",
        server_hopping = "กำลังย้ายเซิฟ...",
    },
    EN = {
        mainTitle = "THE CRAFT HUB",
        version = "Version 2.0.0",
        category_event = "⚡ Event",
        category_steal = "🥚 Egg Steal",
        category_esp = "👁️ ESP",
        category_movement = "🏃 Movement",
        category_combat = "⚔️ Combat",
        category_server = "🌐 Server",
        category_misc = "🔧 Misc",
        btn_refresh = "Refresh",
        btn_clear = "Clear ESP",
        btn_server_hop = "Random Server",
        btn_zone_refresh = "Refresh Zones",
        toggle_on = "ON",
        toggle_off = "OFF",
        feat_auto_tree = "Auto Hit Tree (small)",
        feat_steal_monster = "Steal Monster Egg",
        feat_loot_treadmill = "Loot AdminTreadmill",
        feat_steal_fx = "Steal FX Egg",
        feat_auto_steal = "Auto Steal Egg",
        feat_anti_drop = "Anti Egg Drop",
        feat_fast_pickup = "Fast Pickup",
        feat_zigzag = "Zigzag Steal",
        feat_esp_egg = "ESP Eggs",
        feat_esp_player = "ESP Players",
        feat_speed = "Speed Hack",
        feat_high_jump = "High Jump",
        feat_infinite_jump = "Infinite Jump",
        feat_fast_attack = "Fast Attack",
        feat_no_knockback = "No Knockback",
        feat_zone_select = "Select Egg Zone",
        speed_label = "Speed:",
        jump_label = "Jump Power:",
        zone_label = "Target Zone:",
        status_running = "Running...",
        status_stopped = "Stopped",
        no_target = "No target found",
        found_target = "Found: ",
        stealing = "Stealing: ",
        returning = "Returning...",
        no_character = "No character",
        esp_cleared = "ESP cleared",
        zones_found = "Zones found: ",
        no_zones = "No zones",
        server_hopping = "Hopping server...",
    }
}

local Lang = Translations[Language]

-- ==================== ตัวแปรสถานะ ====================
local Settings = {
    -- อีเว้น
    AutoTree = false,
    StealMonsterEgg = false,
    LootTreadmill = false,
    StealFXEgg = false,
    -- ขโมยไข่
    AutoSteal = false,
    AntiDrop = false,
    FastPickup = false,
    Zigzag = false,
    SelectedZone = "",
    -- ESP
    ESPEgg = false,
    ESPPlayer = false,
    -- การเคลื่อนไหว
    SpeedEnabled = false,
    SpeedValue = 100,
    HighJumpEnabled = false,
    JumpPower = 100,
    InfiniteJump = false,
    -- ต่อสู้
    FastAttack = false,
    NoKnockback = false,
}

local ESPObjects = {}
local ZoneList = {}
local IsStealing = false
local BasePosition = nil
local OriginalWalkSpeed = 16
local OriginalJumpPower = 50

-- ==================== ฟังก์ชัน UI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ScriptName
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 600)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 150, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 60)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Title Bar Bottom (แก้ไขมุม)
local TitleBarBottom = Instance.new("Frame")
TitleBarBottom.Size = UDim2.new(1, 0, 0, 20)
TitleBarBottom.Position = UDim2.new(0, 0, 0, 40)
TitleBarBottom.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
TitleBarBottom.BorderSizePixel = 0
TitleBarBottom.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -120, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = ScriptName
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 24
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(1, -120, 0, 15)
VersionLabel.Position = UDim2.new(0, 15, 0, 35)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = Lang.version
VersionLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextSize = 10
VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
VersionLabel.Parent = TitleBar

-- ปุ่มเปลี่ยนภาษา
local LangButton = Instance.new("TextButton")
LangButton.Size = UDim2.new(0, 50, 0, 30)
LangButton.Position = UDim2.new(1, -110, 0, 15)
LangButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
LangButton.Text = "TH/EN"
LangButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LangButton.Font = Enum.Font.GothamBold
LangButton.TextSize = 11
LangButton.BorderSizePixel = 0
LangButton.Parent = TitleBar

local LangCorner = Instance.new("UICorner")
LangCorner.CornerRadius = UDim.new(0, 5)
LangCorner.Parent = LangButton

-- ปุ่มปิด
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 15)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.BorderSizePixel = 0
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Scroll Frame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -6, 1, -70)
ScrollFrame.Position = UDim2.new(0, 3, 0, 65)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 2000)
ScrollFrame.ScrollBarImageTransparency = 0.3
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 5)
UIPadding.PaddingBottom = UDim.new(0, 5)
UIPadding.PaddingLeft = UDim.new(0, 5)
UIPadding.PaddingRight = UDim.new(0, 5)
UIPadding.Parent = ScrollFrame

-- ==================== ฟังก์ชันสร้างองค์ประกอบ UI ====================
local function CreateCategory(title, order)
    local CategoryFrame = Instance.new("Frame")
    CategoryFrame.Size = UDim2.new(1, 0, 0, 35)
    CategoryFrame.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
    CategoryFrame.BorderSizePixel = 0
    CategoryFrame.LayoutOrder = order
    CategoryFrame.Parent = ScrollFrame
    
    local CatCorner = Instance.new("UICorner")
    CatCorner.CornerRadius = UDim.new(0, 6)
    CatCorner.Parent = CategoryFrame
    
    local CatLabel = Instance.new("TextLabel")
    CatLabel.Size = UDim2.new(1, -10, 1, 0)
    CatLabel.Position = UDim2.new(0, 10, 0, 0)
    CatLabel.BackgroundTransparency = 1
    CatLabel.Text = title
    CatLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CatLabel.Font = Enum.Font.GothamBlack
    CatLabel.TextSize = 15
    CatLabel.TextXAlignment = Enum.TextXAlignment.Left
    CatLabel.Parent = CategoryFrame
    
    return CategoryFrame, CatLabel
end

local function CreateToggle(title, callback, order)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.LayoutOrder = order
    ToggleFrame.Parent = ScrollFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 5)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.75, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = title
    ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 12
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 55, 0, 24)
    ToggleButton.Position = UDim2.new(1, -65, 0.5, -12)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    ToggleButton.Text = Lang.toggle_off
    ToggleButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 11
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Parent = ToggleFrame
    
    local ToggleButtonCorner = Instance.new("UICorner")
    ToggleButtonCorner.CornerRadius = UDim.new(0, 12)
    ToggleButtonCorner.Parent = ToggleButton
    
    local isOn = false
    
    ToggleButton.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleButton.Text = Lang.toggle_on
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            ToggleButton.TextColor3 = Color3.fromRGB(150, 150, 150)
            ToggleButton.Text = Lang.toggle_off
        end
        callback(isOn)
    end)
    
    return ToggleFrame, ToggleLabel, ToggleButton
end

local function CreateSlider(title, min, max, default, callback, order)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 55)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.LayoutOrder = order
    SliderFrame.Parent = ScrollFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 5)
    SliderCorner.Parent = SliderFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, -20, 0, 20)
    SliderLabel.Position = UDim2.new(0, 10, 0, 5)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = title .. ": " .. tostring(default)
    SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextSize = 12
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -40, 0, 8)
    SliderBar.Position = UDim2.new(0, 20, 0, 30)
    SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderFrame
    
    local SliderBarCorner = Instance.new("UICorner")
    SliderBarCorner.CornerRadius = UDim.new(0, 4)
    SliderBarCorner.Parent = SliderBar
    
    local SliderFill = Instance.new("Frame")
    local fillPercent = (default - min) / (max - min)
    SliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0, 4)
    SliderFillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 18, 0, 18)
    SliderButton.Position = UDim2.new(fillPercent, -9, 0.5, -9)
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderButton.Text = ""
    SliderButton.BorderSizePixel = 0
    SliderButton.AutoButtonColor = false
    SliderButton.Parent = SliderBar
    
    local SliderButtonCorner = Instance.new("UICorner")
    SliderButtonCorner.CornerRadius = UDim.new(0, 9)
    SliderButtonCorner.Parent = SliderButton
    
    -- Slider logic
    local dragging = false
    local function UpdateSlider(input)
        local mousePos = UserInputService:GetMouseLocation()
        local barPos = SliderBar.AbsolutePosition
        local barSize = SliderBar.AbsoluteSize
        local relativeX = math.clamp(mousePos.X - barPos.X, 0, barSize.X)
        local value = min + (relativeX / barSize.X) * (max - min)
        value = math.floor(value)
        
        SliderFill.Size = UDim2.new(relativeX / barSize.X, 0, 1, 0)
        SliderButton.Position = UDim2.new(relativeX / barSize.X, -9, 0.5, -9)
        SliderLabel.Text = title .. ": " .. tostring(value)
        callback(value)
    end
    
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
        UpdateSlider()
    end)
    
    SliderBar.MouseButton1Down:Connect(function()
        dragging = true
        UpdateSlider()
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement) then
            UpdateSlider()
        end
    end)
    
    return SliderFrame, SliderLabel
end

local function CreateButton(title, callback, order)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, 0, 0, 35)
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.LayoutOrder = order
    ButtonFrame.Parent = ScrollFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 5)
    ButtonCorner.Parent = ButtonFrame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 1, -5)
    Button.Position = UDim2.new(0, 5, 0, 2)
    Button.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    Button.Text = title
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 13
    Button.BorderSizePixel = 0
    Button.Parent = ButtonFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    
    return ButtonFrame, Button
end

-- ==================== สร้าง UI ====================
-- สร้างหมวดหมู่และฟีเจอร์ทั้งหมด
local orderCounter = 0
local function NextOrder()
    orderCounter = orderCounter + 1
    return orderCounter
end

-- หมวดอีเว้น
local eventCat, eventCatLabel = CreateCategory(Lang.category_event, NextOrder())

CreateToggle(Lang.feat_auto_tree, function(state)
    Settings.AutoTree = state
    if state then
        StartAutoTree()
    end
end, NextOrder())

CreateToggle(Lang.feat_steal_monster, function(state)
    Settings.StealMonsterEgg = state
    if state then
        StartStealMonster()
    end
end, NextOrder())

CreateToggle(Lang.feat_loot_treadmill, function(state)
    Settings.LootTreadmill = state
    if state then
        StartLootTreadmill()
    end
end, NextOrder())

CreateToggle(Lang.feat_steal_fx, function(state)
    Settings.StealFXEgg = state
    if state then
        StartStealFX()
    end
end, NextOrder())

-- หมวดขโมยไข่
local stealCat, stealCatLabel = CreateCategory(Lang.category_steal, NextOrder())

CreateToggle(Lang.feat_auto_steal, function(state)
    Settings.AutoSteal = state
    if state then
        StartAutoSteal()
    end
end, NextOrder())

CreateToggle(Lang.feat_anti_drop, function(state)
    Settings.AntiDrop = state
end, NextOrder())

CreateToggle(Lang.feat_fast_pickup, function(state)
    Settings.FastPickup = state
end, NextOrder())

CreateToggle(Lang.feat_zigzag, function(state)
    Settings.Zigzag = state
end, NextOrder())

-- โซนเลือก
local zoneLabelFrame = Instance.new("Frame")
zoneLabelFrame.Size = UDim2.new(1, 0, 0, 25)
zoneLabelFrame.BackgroundTransparency = 1
zoneLabelFrame.LayoutOrder = NextOrder()
zoneLabelFrame.Parent = ScrollFrame

local zoneLabel = Instance.new("TextLabel")
zoneLabel.Size = UDim2.new(1, 0, 1, 0)
zoneLabel.BackgroundTransparency = 1
zoneLabel.Text = Lang.zone_label .. " -"
zoneLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
zoneLabel.Font = Enum.Font.Gotham
zoneLabel.TextSize = 12
zoneLabel.TextXAlignment = Enum.TextXAlignment.Left
zoneLabel.Parent = zoneLabelFrame

CreateButton(Lang.btn_zone_refresh, function()
    RefreshZones()
end, NextOrder())

-- หมวด ESP
local espCat, espCatLabel = CreateCategory(Lang.category_esp, NextOrder())

CreateToggle(Lang.feat_esp_egg, function(state)
    Settings.ESPEgg = state
    if state then
        StartESPEgg()
    else
        ClearESP()
    end
end, NextOrder())

CreateToggle(Lang.feat_esp_player, function(state)
    Settings.ESPPlayer = state
    if state then
        StartESPPlayer()
    else
        ClearESP()
    end
end, NextOrder())

CreateButton(Lang.btn_clear, function()
    ClearESP()
    print(Lang.esp_cleared)
end, NextOrder())

-- หมวดการเคลื่อนไหว
local moveCat, moveCatLabel = CreateCategory(Lang.category_movement, NextOrder())

CreateSlider(Lang.speed_label, 16, 2000, 100, function(value)
    Settings.SpeedValue = value
    if Settings.SpeedEnabled then
        ApplySpeed(value)
    end
end, NextOrder())

CreateToggle(Lang.feat_speed, function(state)
    Settings.SpeedEnabled = state
    if state then
        ApplySpeed(Settings.SpeedValue)
    else
        ResetSpeed()
    end
end, NextOrder())

CreateSlider(Lang.jump_label, 50, 500, 100, function(value)
    Settings.JumpPower = value
    if Settings.HighJumpEnabled then
        ApplyJump(value)
    end
end, NextOrder())

CreateToggle(Lang.feat_high_jump, function(state)
    Settings.HighJumpEnabled = state
    if state then
        ApplyJump(Settings.JumpPower)
    else
        ResetJump()
    end
end, NextOrder())

CreateToggle(Lang.feat_infinite_jump, function(state)
    Settings.InfiniteJump = state
    if state then
        EnableInfiniteJump()
    else
        DisableInfiniteJump()
    end
end, NextOrder())

-- หมวดต่อสู้
local combatCat, combatCatLabel = CreateCategory(Lang.category_combat, NextOrder())

CreateToggle(Lang.feat_fast_attack, function(state)
    Settings.FastAttack = state
    if state then
        EnableFastAttack()
    end
end, NextOrder())

CreateToggle(Lang.feat_no_knockback, function(state)
    Settings.NoKnockback = state
    if state then
        EnableNoKnockback()
    end
end, NextOrder())

-- หมวดเซิฟเวอร์
local serverCat, serverCatLabel = CreateCategory(Lang.category_server, NextOrder())

CreateButton(Lang.btn_server_hop, function()
    HopServer()
end, NextOrder())

-- ==================== ฟังก์ชันการทำงาน ====================

-- ฟังก์ชันหาวัตถุ
local function FindInWorkspace(name)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == name then
            return obj
        end
    end
    return nil
end

local function FindAllInWorkspace(name)
    local results = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == name then
            table.insert(results, obj)
        end
    end
    return results
end

-- ฟังก์ชันตรวจสอบไข่ที่มีไฟล์
local function HasChildNamed(parent, childName)
    for _, child in pairs(parent:GetChildren()) do
        if child.Name == childName then
            return true
        end
    end
    return false
end

-- ฟังก์ชันหาตัวละคร
local function GetCharacter()
    return LocalPlayer.Character
end

-- ฟังก์ชันหาตำแหน่งของวัตถุ
local function GetObjectPosition(obj)
    if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
        return obj.HumanoidRootPart.Position
    elseif obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") and obj:FindFirstChild("PrimaryPart") then
        return obj.PrimaryPart.Position
    elseif obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") then
        return obj:FindFirstChildWhichIsA("BasePart").Position
    end
    return nil
end

-- ฟังก์ชันเคลื่อนที่
local function MoveTo(position)
    local character = GetCharacter()
    if not character or not character:FindFirstChild("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local humanoid = character.Humanoid
    local rootPart = character.HumanoidRootPart
    
    humanoid:MoveTo(position)
    
    -- ถ้าเปิด Zigzag
    if Settings.Zigzag then
        local offset = Vector3.new(math.sin(tick() * 8) * 3, 0, math.cos(tick() * 8) * 3)
        humanoid:MoveTo(position + offset)
    end
end

-- ฟังก์ชันกดปุ่ม
local function PressKey(key)
    VirtualInputManager:SendKeyEvent(true, key, false, nil)
    wait(0.05)
    VirtualInputManager:SendKeyEvent(false, key, false, nil)
end

-- ฟังก์ชันตีต้นไม้อัตโนมัติ
function StartAutoTree()
    spawn(function()
        while Settings.AutoTree and wait(0.5) do
            local character = GetCharacter()
            if character and character:FindFirstChild("HumanoidRootPart") then
                -- หาต้นไม้ small
                local trees = {}
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name == "small" or obj.Name:lower():find("small") then
                        table.insert(trees, obj)
                    end
                end
                
                -- เลือกต้นไม้ที่ใกล้ที่สุด
                local nearestTree = nil
                local nearestDist = math.huge
                
                for _, tree in pairs(trees) do
                    local pos = GetObjectPosition(tree)
                    if pos then
                        local dist = (pos - character.HumanoidRootPart.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearestTree = tree
                        end
                    end
                end
                
                if nearestTree then
                    local treePos = GetObjectPosition(nearestTree)
                    if treePos then
                        MoveTo(treePos)
                        wait(0.3)
                        
                        -- ตีต้นไม้
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                            wait(0.1)
                            tool:Deactivate()
                        else
                            PressKey(Enum.KeyCode.E)
                        end
                    end
                end
            end
        end
    end)
end

-- ฟังก์ชันขโมยไข่ Monster
function StartStealMonster()
    spawn(function()
        while Settings.StealMonsterEgg and wait(1) do
            local monsterEggs = {}
            for _, egg in pairs(Workspace:GetDescendants()) do
                if egg:IsA("Model") and HasChildNamed(egg, "MonsterParasiteVisual") then
                    table.insert(monsterEggs, egg)
                end
            end
            
            if #monsterEggs > 0 then
                local character = GetCharacter()
                if character and character:FindFirstChild("HumanoidRootPart") then
                    for _, egg in pairs(monsterEggs) do
                        local eggPos = GetObjectPosition(egg)
                        if eggPos then
                            MoveTo(eggPos)
                            wait(0.5)
                            PressKey(Enum.KeyCode.E)
                            
                            if Settings.AntiDrop then
                                wait(0.3)
                                PressKey(Enum.KeyCode.E)
                            end
                            
                            if Settings.FastPickup then
                                wait(0.2)
                                PressKey(Enum.KeyCode.E)
                            end
                            break
                        end
                    end
                end
            end
        end
    end)
end

-- ฟังก์ชันเสกลู่วิ่ง
function StartLootTreadmill()
    spawn(function()
        while Settings.LootTreadmill and wait(0.5) do
            local treadmill = FindInWorkspace("AdminTreadmill")
            if treadmill then
                local treadmillPos = GetObjectPosition(treadmill)
                if treadmillPos then
                    MoveTo(treadmillPos)
                    wait(0.3)
                    PressKey(Enum.KeyCode.E)
                end
            end
        end
    end)
end

-- ฟังก์ชันขโมยไข่ FX
function StartStealFX()
    spawn(function()
        while Settings.StealFXEgg and wait(1) do
            local fxEggs = {}
            for _, egg in pairs(Workspace:GetDescendants()) do
                if egg:IsA("Model") and HasChildNamed(egg, "FX") then
                    table.insert(fxEggs, egg)
                end
            end
            
            if #fxEggs > 0 then
                local character = GetCharacter()
                if character and character:FindFirstChild("HumanoidRootPart") then
                    for _, egg in pairs(fxEggs) do
                        local eggPos = GetObjectPosition(egg)
                        if eggPos then
                            MoveTo(eggPos)
                            wait(0.5)
                            PressKey(Enum.KeyCode.E)
                            
                            if Settings.AntiDrop then
                                wait(0.3)
                                PressKey(Enum.KeyCode.E)
                            end
                            break
                        end
                    end
                end
            end
        end
    end)
end

-- ฟังก์ชันข
