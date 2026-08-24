-- ==========================================
-- Script: THE CRAFT HUB (Steal an Egg - Safe UI Edition 2026)
-- Fix: GUI Not Showing / Infinite Wait Issue
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

-- 1. ลบ UI เก่าออกก่อนเสมอ (ป้องกัน UI ซ้อนหรือบั๊กค้าง)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then return end

if PlayerGui:FindFirstChild("TheCraftHub_Overhaul") then
    PlayerGui.TheCraftHub_Overhaul:Destroy()
end

-- Configuration System
local Config = {
    FarmMode = "None",
    FlySpeedFarm = 60,
    SavedBaseCFrame = nil,
    AutoReEquipOnDrop = true,
    AntiDropOnHit = true,
    AntiResetToolLoss = true,
    AutoEventTree = false,
    SpeedToggle = false,
    WalkSpeed = 32,
    Noclip = false,
    SelectedZone = "All",
    MinEggSize = 0,
    TargetRarity = "All",
    EspEnabled = false,
    CleanESP = true,
    ShowDistance = true
}

local RarityColors = {
    Common = Color3.fromRGB(200, 200, 200),
    Rare = Color3.fromRGB(0, 150, 255),
    Epic = Color3.fromRGB(170, 0, 255),
    Legendary = Color3.fromRGB(255, 170, 0),
    Mythic = Color3.fromRGB(255, 0, 80)
}

-- 2. สร้าง ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHub_Overhaul"
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main UI Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 540, 0, 430)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -215)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true -- บังคับเปิดทันที
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 10)
MainUICorner.Parent = MainFrame

local MainUIStroke = Instance.new("UIStroke")
MainUIStroke.Color = Color3.fromRGB(0, 220, 255)
MainUIStroke.Thickness = 2
MainUIStroke.Parent = MainFrame

task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        MainUIStroke.Color = Color3.fromHSV((tick() * 0.2) % 1, 0.9, 1)
        task.wait(0.04)
    end
end)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(6, 9, 15)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ THE CRAFT HUB ✦ Cyberpunk Overhaul Edition"
TitleLabel.TextColor3 = Color3.fromRGB(0, 230, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -32, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 70)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = TopBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Floating Toggle Button
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
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 540, 0, 430),
        Position = UDim2.new(0.5, -270, 0.5, -215)
    }):Play()
end

local function CloseUI()
    local tw = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
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

-- Sidebar Construction
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 130, 1, -40)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(8, 12, 18)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabBar
TabListLayout.Padding = UDim.new(0, 4)

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -140, 1, -48)
ContentArea.Position = UDim2.new(0, 135, 0, 44)
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

local PageFarmMode = CreateTab("ระบบฟาร์มหลัก")
local PageFilters = CreateTab("ตัวกรองไข่")
local PageSecurity = CreateTab("กันไข่หลุด/เซฟตัว")
local PageEvent = CreateTab("กิจกรรม (Event)")
local PageMove = CreateTab("การเคลื่อนที่")
local PageVisual = CreateTab("ESP คลีน")

Tabs[1].BackgroundColor3 = Color3.fromRGB(0, 160, 230)
Tabs[1].TextColor3 = Color3.fromRGB(255, 255, 255)
TabPages[1].Visible = true

-- Shared UI Helper Functions
local function AddToggle(parentPage, text, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 34)
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
    switch.Size = UDim2.new(0, 50, 0, 22)
    switch.Position = UDim2.new(1, -56, 0.5, -11)
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
    row.Size = UDim2.new(1, -6, 0, 34)
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
-- FILTERS & HELPER FUNCTIONS
-- ==========================================

local function IsEggValid(obj)
    local name = obj.Name:lower()

    if name:find("pet") or name:find("animal") or obj:FindFirstChildOfClass("Humanoid") then
        return false
    end

    if not name:find("egg") then
        return false
    end

    if obj:FindFirstAncestor("Bases") or obj:FindFirstAncestor("Plots") or obj:FindFirstAncestor("Garden") or (LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character)) then
        return false
    end
    
    if Config.SelectedZone ~= "All" then
        local zoneFolder = obj:FindFirstAncestorOfClass("Folder") or obj.Parent
        if not zoneFolder or not zoneFolder.Name:lower():find(Config.SelectedZone:lower()) then
            return false
        end
    end

    if Config.TargetRarity ~= "All" then
        if not name:find(Config.TargetRarity:lower()) then
            return false
        end
    end

    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
    if part and Config.MinEggSize > 0 then
        local sz = part.Size.Magnitude
        if Config.MinEggSize == 1 and sz > 4 then return false end
        if Config.MinEggSize == 2 and (sz < 4 or sz > 8) then return false end
        if Config.MinEggSize == 3 and sz < 8 then return false end
    end

    return true
end

-- 1. FARM MODE
local ModeStatus = Instance.new("TextLabel")
ModeStatus.Size = UDim2.new(1, -6, 0, 30)
ModeStatus.BackgroundColor3 = Color3.fromRGB(16, 22, 32)
ModeStatus.Text = "สถานะโหมดฟาร์ม: 🔴 ปิดการทำงาน"
ModeStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
ModeStatus.Font = Enum.Font.GothamBold
ModeStatus.TextSize = 11
ModeStatus.Parent = PageFarmMode
local msCorner = Instance.new("UICorner")
msCorner.CornerRadius = UDim.new(0, 6)
msCorner.Parent = ModeStatus

local function CreateModeBtn(text, modeName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 230, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = PageFarmMode
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        Config.FarmMode = modeName
        ModeStatus.Text = "สถานะโหมดฟาร์ม: 🟢 " .. text
        ModeStatus.TextColor3 = Color3.fromRGB(0, 230, 150)
    end)
end

CreateModeBtn("✈️ โหมด 1: บินไปขโมยไข่ แล้วบินกลับฐาน", "Fly")
CreateModeBtn("⚡ โหมด 2: วาร์ปไปขโมยไข่ แล้ววาร์ปกลับฐาน", "TP")
CreateModeBtn("🛑 ปิดระบบฟาร์มทั้งหมด", "None")

-- 2. FILTERS
AddInput(PageFilters, "โซนที่ต้องการขโมย (All, Middle, Forest):", "All", function(t) Config.SelectedZone = t end)
AddInput(PageFilters, "ความหายาก (All, Rare, Epic, Legendary):", "All", function(t) Config.TargetRarity = t end)
AddInput(PageFilters, "ขนาดไข่ (0:ทั้งหมด, 1:เล็ก, 2:กลาง, 3:ใหญ่):", 0, function(t)
    local n = tonumber(t)
    if n then Config.MinEggSize = n end
end)

-- 3. SECURITY
AddToggle(PageSecurity, "เก็บไข่อัตโนมัติรัวๆ เมื่อหลุดมือ", function(v) Config.AutoReEquipOnDrop = v end)
AddToggle(PageSecurity, "ป้องกันไข่หลุดมือเมื่อโดนตี/โดนแย่ง", function(v) Config.AntiDropOnHit = v end)
AddToggle(PageSecurity, "ป้องกันไข่หายเมื่อกดรีเซ็ตตัวตาย", function(v) Config.AntiResetToolLoss = v end)

-- 4. EVENT
AddToggle(PageEvent, "วาร์ปไปตีต้นไม้อัตโนมัติ (Event Tree)", function(v) Config.AutoEventTree = v end)

-- 5. MOVEMENT ENGINE (FLY SPEED + FREEZE ANIMATION)
AddToggle(PageMove, "เปิดระบบวิ่งไวตัวแข็งลอย (Fly Speed)", function(v) 
    Config.SpeedToggle = v 
    
    if not v then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            
            if root and root:FindFirstChild("CraftSpeedBV") then
                root.CraftSpeedBV:Destroy()
            end
            
            if hum and hum:FindFirstChild("Animator") then
                for _, track in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(1)
                end
            end
        end
    end
end)

AddInput(PageMove, "ค่าความเร็วการวิ่ง (แนะนำ 40 - 100):", 60, function(t)
    local n = tonumber(t)
    if n then Config.WalkSpeed = n end
end)

AddToggle(PageMove, "เดินทะลุสิ่งกีดขวาง (Noclip)", function(v) Config.Noclip = v end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if root and hum then
        if Config.SpeedToggle then
            if hum:FindFirstChild("Animator") then
                for _, track in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(0)
                end
            end

            local bv = root:FindFirstChild("CraftSpeedBV")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "CraftSpeedBV"
                bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                bv.Parent = root
            end

            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                bv.Velocity = (moveDir * Config.WalkSpeed) + Vector3.new(0, 1, 0)
            else
                bv.Velocity = Vector3.new(0, 1, 0)
            end
        else
            if root:FindFirstChild("CraftSpeedBV") then
                root.CraftSpeedBV:Destroy()
            end
        end
        
        if Config.Noclip then
            for _, p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- 6. ESP SYSTEM
AddToggle(PageVisual, "เปิดใช้งาน ESP มองทะลุไข่ (Egg ESP)", function(v) Config.EspEnabled = v end)
AddToggle(PageVisual, "แสดงระยะทาง (Distance Metres)", function(v) Config.ShowDistance = v end)

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "TheCraft_ESP_Folder"
ESPFolder.Parent = ScreenGui

RunService.RenderStepped:Connect(function()
    ESPFolder:ClearAllChildren()
    
    if not Config.EspEnabled then return end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) then
            if IsEggValid(obj) then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    local dist = math.floor((root.Position - part.Position).Magnitude)
                    
                    local color = Color3.fromRGB(0, 220, 255)
                    for rarity, c in pairs(RarityColors) do
                        if obj.Name:lower():find(rarity:lower()) then
                            color = c
                            break
                        end
                    end

                    local bGui = Instance.new("BillboardGui")
                    bGui.Name = "EggESP"
                    bGui.Adornee = part
                    bGui.Size = UDim2.new(0, 150, 0, 40)
                    bGui.StudsOffset = Vector3.new(0, 2.5, 0)
                    bGui.AlwaysOnTop = true
                    bGui.Parent = ESPFolder

                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextColor3 = color
                    textLabel.TextStrokeTransparency = 0
                    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    textLabel.Font = Enum.Font.GothamBold
                    textLabel.TextSize = 12
                    
                    if Config.ShowDistance then
                        textLabel.Text = "🥚 " .. obj.Name .. "\n[" .. dist .. "m]"
                    else
                        textLabel.Text = "🥚 " .. obj.Name
                    end
                    textLabel.Parent = bGui
                end
            end
        end
    end
end)
