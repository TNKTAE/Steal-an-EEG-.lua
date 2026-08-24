-- ==========================================
-- Script: THE CRAFT HUB (Steal an Egg - Fix & Ultimate Edition)
-- Theme: Cyberpunk Neon Cyan/Purple Animated UI
-- Features: Fix Teleport Walk, Zone-Only ESP, Spawn Radar, Auto Farm, Mechanics Fix
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Global State & Config
local Config = {
    CurrentMap = "Steal an Egg",
    AutoSteal = false,
    AutoReturn = false,
    AutoPickupDrop = false,
    NoDrop = false,
    CustomSpeedToggle = false,
    WalkSpeed = 32,
    Noclip = false,
    Fly = false,
    FlySpeed = 40,
    EggESP = false,
    PlayerESP = false,
    SelectedRarity = "ทั้งหมด",
    SavedBaseCFrame = nil
}

-- Rarity Colors Setup
local RarityColors = {
    Common = Color3.fromRGB(200, 200, 200),
    Rare = Color3.fromRGB(0, 150, 255),
    Epic = Color3.fromRGB(170, 0, 255),
    Legendary = Color3.fromRGB(255, 170, 0),
    Mythic = Color3.fromRGB(255, 0, 80)
}

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHub_V3"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Intro & Main Frames
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 10)
MainUICorner.Parent = MainFrame

local MainUIStroke = Instance.new("UIStroke")
MainUIStroke.Color = Color3.fromRGB(0, 220, 255)
MainUIStroke.Thickness = 2
MainUIStroke.Parent = MainFrame

-- Animated Rainbow/Cyan Border
task.spawn(function()
    while task.wait(0.04) do
        MainUIStroke.Color = Color3.fromHSV((tick() * 0.2) % 1, 0.9, 1)
    end
end)

-- Top Header
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(6, 9, 15)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ THE CRAFT HUB ✦ Cyberpunk Edition"
TitleLabel.TextColor3 = Color3.fromRGB(0, 230, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -32, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 70)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Floating Open/Close Icon
local ToggleGuiBtn = Instance.new("TextButton")
ToggleGuiBtn.Size = UDim2.new(0, 110, 0, 36)
ToggleGuiBtn.Position = UDim2.new(0, 15, 0.5, -18)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 240)
ToggleGuiBtn.Text = "⚡ CRAFT HUB"
ToggleGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleGuiBtn.Font = Enum.Font.GothamBold
ToggleGuiBtn.TextSize = 12
ToggleGuiBtn.Active = true
ToggleGuiBtn.Draggable = true
ToggleGuiBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleGuiBtn

local function OpenUI()
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 530, 0, 410),
        Position = UDim2.new(0.5, -265, 0.5, -205)
    }):Play()
end

local function CloseUI()
    local tw = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    tw:Play()
    tw.Completed:Connect(function() MainFrame.Visible = false end)
end

ToggleGuiBtn.MouseButton1Click:Connect(function()
    if MainFrame.Visible then CloseUI() else OpenUI() end
end)
CloseBtn.MouseButton1Click:Connect(CloseUI)

-- Instant Start UI Animation
OpenUI()

-- Tabs Navigation Panel
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 125, 1, -42)
TabBar.Position = UDim2.new(0, 0, 0, 42)
TabBar.BackgroundColor3 = Color3.fromRGB(8, 12, 18)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabBar
TabListLayout.Padding = UDim.new(0, 4)

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -135, 1, -50)
ContentArea.Position = UDim2.new(0, 130, 0, 46)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local Tabs, TabPages = {}, {}
local function CreateTab(tabName)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, -8, 0, 34)
    tabBtn.Position = UDim2.new(0, 4, 0, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    tabBtn.Text = tabName
    tabBtn.TextColor3 = Color3.fromRGB(140, 170, 200)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 11
    tabBtn.Parent = TabBar

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabBtn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
    page.Visible = false
    page.Parent = ContentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Parent = page
    pageLayout.Padding = UDim.new(0, 6)
    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 15)
    end)

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.BackgroundColor3 = Color3.fromRGB(15, 20, 30) t.TextColor3 = Color3.fromRGB(140, 170, 200) end
        for _, p in pairs(TabPages) do p.Visible = false end
        tabBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 230)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        page.Visible = true
    end)

    table.insert(Tabs, tabBtn)
    table.insert(TabPages, page)
    return page
end

local PageFarm = CreateTab("ฟาร์ม & ขโมย")
local PageMove = CreateTab("การเคลื่อนที่")
local PageVisual = CreateTab("ESP & เรดาร์")
local PageUtility = CreateTab("ตั้งค่า/คำสั่ง")

Tabs[1].BackgroundColor3 = Color3.fromRGB(0, 160, 230)
Tabs[1].TextColor3 = Color3.fromRGB(255, 255, 255)
TabPages[1].Visible = true

-- UI Builders
local function AddToggle(parentPage, text, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(16, 22, 32)
    row.Parent = parentPage

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 6)
    rCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 235, 255)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 52, 0, 22)
    switch.Position = UDim2.new(1, -58, 0.5, -11)
    switch.BackgroundColor3 = Color3.fromRGB(35, 45, 60)
    switch.Text = "ปิด"
    switch.TextColor3 = Color3.fromRGB(160, 160, 160)
    switch.Font = Enum.Font.GothamBold
    switch.TextSize = 10
    switch.Parent = row

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(0, 11)
    sCorner.Parent = switch

    local state = false
    switch.MouseButton1Click:Connect(function()
        state = not state
        switch.Text = state and "เปิด" or "ปิด"
        local col = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(35, 45, 60)
        TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = col}):Play()
        switch.TextColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,160,160)
        callback(state)
    end)
end

local function AddInput(parentPage, text, defaultVal, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(16, 22, 32)
    row.Parent = parentPage

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 6)
    rCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 235, 255)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 70, 0, 22)
    box.Position = UDim2.new(1, -76, 0.5, -11)
    box.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
    box.Text = tostring(defaultVal)
    box.TextColor3 = Color3.fromRGB(0, 220, 255)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 11
    box.Parent = row

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 5)
    bCorner.Parent = box

    box.FocusLost:Connect(function() callback(box.Text) end)
end

-- ==========================================
-- SCRIPT LOGIC FIXES & FEATURES
-- ==========================================

-- Helper: Check Egg in Hand
local function GetHeldEgg()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") or item.Name:lower():find("egg") then
            return item
        end
    end
    return nil
end

-- Helper: Find Steal-Zone Eggs (Exclude Base/Plots)
local function GetTargetEggInZone()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local closestEgg = nil
    local minDistance = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("egg") then
            -- Check parent to ignore player bases & inventory
            local isInsideBase = obj:FindFirstAncestor("Bases") or obj:FindFirstAncestor("Plots") or obj:IsDescendantOf(char)
            if not isInsideBase then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    local dist = (char.HumanoidRootPart.Position - part.Position).Magnitude
                    if dist < minDistance then
                        minDistance = dist
                        closestEgg = {Object = obj, Part = part}
                    end
                end
            end
        end
    end
    return closestEgg
end

-- 1. FARMING TAB
AddToggle(PageFarm, "ขโมยไข่อัตโนมัติ (Auto Steal)", function(v) Config.AutoSteal = v end)
AddToggle(PageFarm, "ขโมยเสร็จวาร์ปส่งฐาน (Auto Return)", function(v) Config.AutoReturn = v end)
AddToggle(PageFarm, "เก็บไข่ตกพื้นทันที (Auto Pickup Drop)", function(v) Config.AutoPickupDrop = v end)
AddToggle(PageFarm, "กันมอนสเตอร์ตีไข่หลุด (No Drop)", function(v) Config.NoDrop = v end)

-- Set Base Manual Button
local SetBaseBtn = Instance.new("TextButton")
SetBaseBtn.Size = UDim2.new(1, -6, 0, 32)
SetBaseBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 200)
SetBaseBtn.Text = "📌 บันทึกพิกัดฐานผู้เล่น"
SetBaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetBaseBtn.Font = Enum.Font.GothamBold
SetBaseBtn.TextSize = 11
SetBaseBtn.Parent = PageFarm
local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 6)
sbCorner.Parent = SetBaseBtn

SetBaseBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Config.SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        SetBaseBtn.Text = "✓ บันทึกพิกัดฐานเรียบร้อย!"
        task.wait(1.5)
        SetBaseBtn.Text = "📌 บันทึกพิกัดฐานผู้เล่น"
    end
end)

-- 2. MOVEMENT TAB (Fix Teleporting Back)
AddToggle(PageMove, "เปิดสวิตช์เพิ่มความเร็ว (WalkSpeed)", function(v) Config.CustomSpeedToggle = v end)
AddInput(PageMove, "ค่าความเร็วการวิ่ง (แนะนำ: 24-40):", 32, function(t)
    local n = tonumber(t)
    if n then Config.WalkSpeed = n end
end)
AddToggle(PageMove, "เดินทะลุสิ่งกีดขวาง (Noclip)", function(v) Config.Noclip = v end)
AddToggle(PageMove, "เปิดระบบบิน (Fly)", function(v) Config.Fly = v end)

-- Smooth Speed Loop Fix (Using MoveDirection to prevent Rubberbanding/Warp back)
RunService.Heartbeat:Connect(function(deltaTime)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if Config.CustomSpeedToggle then
            if hum.MoveDirection.Magnitude > 0 then
                char:TranslateBy(hum.MoveDirection * (Config.WalkSpeed / 16) * deltaTime * 10)
            end
        end
        if Config.Noclip then
            for _, p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
        if Config.NoDrop then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name:lower():find("egg") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- 3. VISUAL & RADAR TAB
AddToggle(PageVisual, "ESP มองไข่ (มองเฉพาะในโซน)", function(v) Config.EggESP = v end)
AddToggle(PageVisual, "ESP มองผู้เล่นคนอื่น", function(v) Config.PlayerESP = v end)

-- Spawn Radar Status Box
local RadarBox = Instance.new("Frame")
RadarBox.Size = UDim2.new(1, -6, 0, 75)
RadarBox.BackgroundColor3 = Color3.fromRGB(14, 18, 26)
RadarBox.Parent = PageVisual
local rdbCorner = Instance.new("UICorner")
rdbCorner.CornerRadius = UDim.new(0, 6)
rdbCorner.Parent = RadarBox

local RadarTitle = Instance.new("TextLabel")
RadarTitle.Size = UDim2.new(1, -10, 0, 22)
RadarTitle.Position = UDim2.new(0, 8, 0, 4)
RadarTitle.BackgroundTransparency = 1
RadarTitle.Text = "📡 เรดาร์สแกนไข่ในเซิร์ฟเวอร์"
RadarTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
RadarTitle.Font = Enum.Font.GothamBold
RadarTitle.TextSize = 11
RadarTitle.TextXAlignment = Enum.TextXAlignment.Left
RadarTitle.Parent = RadarBox

local RadarStatus = Instance.new("TextLabel")
RadarStatus.Size = UDim2.new(1, -10, 0, 40)
RadarStatus.Position = UDim2.new(0, 8, 0, 26)
RadarStatus.BackgroundTransparency = 1
RadarStatus.Text = "กำลังสแกนหาไข่ในพื้นที่..."
RadarStatus.TextColor3 = Color3.fromRGB(200, 230, 255)
RadarStatus.Font = Enum.Font.Gotham
RadarStatus.TextSize = 10
RadarStatus.TextWrapped = true
RadarStatus.TextXAlignment = Enum.TextXAlignment.Left
RadarStatus.Parent = RadarBox

-- Radar & ESP Loop
task.spawn(function()
    while task.wait(0.6) do
        -- Clear old ESP
        for _, old in ipairs(workspace:GetDescendants()) do
            if old.Name == "TCH_ESP" then old:Destroy() end
        end

        local count = 0
        local latestEgg = "ไม่มี"

        for _, obj in ipairs(workspace:GetDescendants()) do
            if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("egg") then
                local inBase = obj:FindFirstAncestor("Bases") or obj:FindFirstAncestor("Plots") or (LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character))
                if not inBase then
                    count = count + 1
                    latestEgg = obj.Name

                    if Config.EggESP then
                        local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local bg = Instance.new("BillboardGui")
                            bg.Name = "TCH_ESP"
                            bg.AlwaysOnTop = true
                            bg.Size = UDim2.new(0, 100, 0, 25)
                            bg.Adornee = part

                            local txt = Instance.new("TextLabel")
                            txt.Size = UDim2.new(1,0,1,0)
                            txt.BackgroundTransparency = 1
                            txt.Text = "🥚 " .. obj.Name
                            txt.TextColor3 = RarityColors[obj.Name] or Color3.fromRGB(0, 230, 255)
                            txt.Font = Enum.Font.GothamBold
                            txt.TextSize = 11
                            txt.Parent = bg
                            bg.Parent = part
                        end
                    end
                end
            end
        end
        RadarStatus.Text = "ไข่ในโซนกลาง: " .. count .. " ใบ\nไข่พบล่าสุด: " .. latestEgg .. "\nเวลาสแกน: " .. os.date("%X")
    end
end)

-- 4. UTILITY TAB
local RejoinBtn = Instance.new("TextButton")
RejoinBtn.Size = UDim2.new(1, -6, 0, 34)
RejoinBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
RejoinBtn.Text = "🔄 Rejoin Server (เข้าเซิร์ฟเดิมใหม่)"
RejoinBtn.TextColor3 = Color3.fromRGB(200, 235, 255)
RejoinBtn.Font = Enum.Font.GothamBold
RejoinBtn.TextSize = 11
RejoinBtn.Parent = PageUtility
local rjCorner = Instance.new("UICorner")
rjCorner.CornerRadius = UDim.new(0, 6)
rjCorner.Parent = RejoinBtn

RejoinBtn.MouseButton1Click:Connect(function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

-- Auto Steal & Auto Return Loop
task.spawn(function()
    while task.wait(0.3) do
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            if Config.AutoReturn and GetHeldEgg() then
                if Config.SavedBaseCFrame then
                    char.HumanoidRootPart.CFrame = Config.SavedBaseCFrame
                    task.wait(1)
                end
            elseif Config.AutoSteal and not GetHeldEgg() then
                local target = GetTargetEggInZone()
                if target then
                    char.HumanoidRootPart.CFrame = target.Part.CFrame * CFrame.new(0, 3, 0)
                end
            end
        end
    end
end)
