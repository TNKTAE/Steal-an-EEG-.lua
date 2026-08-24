-- ==========================================
-- Script: THE CRAFT HUB (Steal an Egg - Ultimate OVERHAUL 2026)
-- Theme: Cyberpunk Neon Blue/Purple UI
-- Includes: Fly Farm, TP Farm, Instant Re-Equip, Anti-Drop, 
--           Event Auto-Tree, Zone Filter, Size/Rarity Filter, Smooth Speed
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Configuration System
local Config = {
    -- Farm Modes
    FarmMode = "None", -- "Fly", "TP", or "None"
    FlySpeedFarm = 60,
    SavedBaseCFrame = nil,
    
    -- Anti-Drop & Security
    AutoReEquipOnDrop = true,
    AntiDropOnHit = true,
    AntiResetToolLoss = true,
    
    -- Event Mode
    AutoEventTree = false,
    
    -- Speed & Movement (Fixed Warp-Back & Animation Freeze)
    SpeedToggle = false,
    WalkSpeed = 32,
    Noclip = false,
    
    -- Filters (Zone / Size / Rarity)
    SelectedZone = "All", -- "All", "Middle", "Forest", "Desert", "Volcano"
    MinEggSize = 0,       -- 0: ทั้งหมด, 1: เล็ก, 2: กลาง, 3: ใหญ่
    TargetRarity = "All", -- "All", "Common", "Rare", "Epic", "Legendary", "Mythic"
    
    -- Visual / ESP
    CleanESP = true,
    ShowDistance = true
}

-- Rarity Colors Definition
local RarityColors = {
    Common = Color3.fromRGB(200, 200, 200),
    Rare = Color3.fromRGB(0, 150, 255),
    Epic = Color3.fromRGB(170, 0, 255),
    Legendary = Color3.fromRGB(255, 170, 0),
    Mythic = Color3.fromRGB(255, 0, 80)
}

-- ScreenGui Init
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHub_Overhaul"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main UI Frame Setup
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 540, 0, 430)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -215)
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

-- Neon Animated Border Effect
task.spawn(function()
    while task.wait(0.04) do
        MainUIStroke.Color = Color3.fromHSV((tick() * 0.2) % 1, 0.9, 1)
    end
end)

-- Top Header Bar
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

-- Open/Close Floating Button
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
        Size = UDim2.new(0, 540, 0, 430),
        Position = UDim2.new(0.5, -270, 0.5, -215)
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

-- Tab Sidebar Construction
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

-- Shared Component Helpers
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
-- CORE HELPER FUNCTIONS & TARGET FILTERING
-- ==========================================

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

-- Check Zone, Rarity, and Size constraints
local function IsEggValid(obj)
    -- Ignore eggs inside player bases, plots, or player character models
    if obj:FindFirstAncestor("Bases") or obj:FindFirstAncestor("Plots") or (LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character)) then
        return false
    end
    
    -- Zone Check
    if Config.SelectedZone ~= "All" then
        local zoneFolder = obj:FindFirstAncestorOfClass("Folder") or obj.Parent
        if not zoneFolder or not zoneFolder.Name:lower():find(Config.SelectedZone:lower()) then
            return false
        end
    end

    -- Rarity Check
    if Config.TargetRarity ~= "All" then
        if not obj.Name:lower():find(Config.TargetRarity:lower()) then
            return false
        end
    end

    -- Size Check (Based on Part Size magnitude)
    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
    if part and Config.MinEggSize > 0 then
        local sz = part.Size.Magnitude
        if Config.MinEggSize == 1 and sz > 4 then return false end -- Small Only
        if Config.MinEggSize == 2 and (sz < 4 or sz > 8) then return false end -- Medium Only
        if Config.MinEggSize == 3 and sz < 8 then return false end -- Large Only
    end

    return true
end

local function GetTargetEgg()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local closestEgg = nil
    local minDistance = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("egg") then
            if IsEggValid(obj) then
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

-- ==========================================
-- 1. FARM MODE SELECTION & BASE SAVER
-- ==========================================

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

local SetBaseBtn = Instance.new("TextButton")
SetBaseBtn.Size = UDim2.new(1, -6, 0, 34)
SetBaseBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 200)
SetBaseBtn.Text = "📌 บันทึกพิกัดฐานเก็บไข่ (Save Base Position)"
SetBaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetBaseBtn.Font = Enum.Font.GothamBold
SetBaseBtn.TextSize = 11
SetBaseBtn.Parent = PageFarmMode
local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 6)
sbCorner.Parent = SetBaseBtn

SetBaseBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Config.SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        SetBaseBtn.Text = "✓ บันทึกตำแหน่งฐานเรียบร้อย!"
        task.wait(1.5)
        SetBaseBtn.Text = "📌 บันทึกพิกัดฐานเก็บไข่ (Save Base Position)"
    end
end)

-- ==========================================
-- 2. FILTERS (ZONE / SIZE / RARITY)
-- ==========================================

AddInput(PageFilters, "โซนที่ต้องการขโมย (All, Middle, Forest):", "All", function(t) Config.SelectedZone = t end)
AddInput(PageFilters, "ความหายาก (All, Rare, Epic, Legendary):", "All", function(t) Config.TargetRarity = t end)
AddInput(PageFilters, "ขนาดไข่ (0:ทั้งหมด, 1:เล็ก, 2:กลาง, 3:ใหญ่):", 0, function(t)
    local n = tonumber(t)
    if n then Config.MinEggSize = n end
end)

-- ==========================================
-- 3. SECURITY & ANTI-DROP LOGIC
-- ==========================================

AddToggle(PageSecurity, "เก็บไข่อัตโนมัติรัวๆ เมื่อหลุดมือ", function(v) Config.AutoReEquipOnDrop = v end)
AddToggle(PageSecurity, "ป้องกันไข่หลุดมือเมื่อโดนตี/โดนแย่ง", function(v) Config.AntiDropOnHit = v end)
AddToggle(PageSecurity, "ป้องกันไข่หายเมื่อกดรีเซ็ตตัวตาย", function(v) Config.AntiResetToolLoss = v end)

-- Anti Drop / Anti Reset Engine
LocalPlayer.CharacterAdded:Connect(function(char)
    if Config.AntiResetToolLoss then
        char:WaitForChild("Humanoid").Died:Connect(function()
            local held = GetHeldEgg()
            if held then
                held.Parent = LocalPlayer.Backpack
            end
        end)
    end
end)

-- Instant Re-Equip Loop when egg drops
RunService.Stepped:Connect(function()
    if Config.AutoReEquipOnDrop then
        local bp = LocalPlayer:FindFirstChild("Backpack")
        local char = LocalPlayer.Character
        if bp and char and char:FindFirstChild("Humanoid") then
            for _, item in ipairs(bp:GetChildren()) do
                if item.Name:lower():find("egg") or item:IsA("Tool") then
                    char.Humanoid:EquipTool(item)
                end
            end
        end
    end

    if Config.AntiDropOnHit and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name:lower():find("egg") then
                part.CanCollide = false
            end
        end
    end
end)

-- ==========================================
-- 4. EVENT AUTO TREE
-- ==========================================

AddToggle(PageEvent, "วาร์ปไปตีต้นไม้อัตโนมัติ (Event Tree)", function(v) Config.AutoEventTree = v end)

task.spawn(function()
    while task.wait(0.5) do
        if Config.AutoEventTree and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("eventtree") or obj.Name:lower():find("tree") then
                    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    if part then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 0, 3)
                        -- Trigger Attack Anim / Click
                        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        break
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 5. MOVEMENT ENGINE (FIX WARP-BACK & FREEZE)
-- ==========================================

AddToggle(PageMove, "เปิดระบบเพิ่มความเร็วแบบสมูท (Custom Speed)", function(v) Config.SpeedToggle = v end)
AddInput(PageMove, "ค่าความเร็วการวิ่ง (แนะนำ 24 - 45):", 32, function(t)
    local n = tonumber(t)
    if n then Config.WalkSpeed = n end
end)
AddToggle(PageMove, "เดินทะลุสิ่งกีดขวาง (Noclip)", function(v) Config.Noclip = v end)

-- Smooth Speed Loop: Solves Warp Back & Animation Freeze Bug
RunService.Heartbeat:Connect(function(deltaTime)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        -- Custom Velocity Movement to Prevents Server Snap-back
        if Config.SpeedToggle and hum.MoveDirection.Magnitude > 0 then
            char:TranslateBy(hum.MoveDirection * (Config.WalkSpeed / 16) * deltaTime * 12)
        end
        
        if Config.Noclip then
            for _, p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- ==========================================
-- 6. CLEAN ESP ENGINE (ZONE FILTERED)
-- ==========================================

AddToggle(PageVisual, "เปิด ESP ไข่แบบคลีน (กรองเฉพาะโซน)", function(v) Config.CleanESP = v end)
AddToggle(PageVisual, "แสดงระยะห่าง (Distance)", function(v) Config.ShowDistance = v end)

task.spawn(function()
    while task.wait(0.7) do
        for _, old in ipairs(workspace:GetDescendants()) do
            if old.Name == "TCH_CleanESP" then old:Destroy() end
        end

        if Config.CleanESP and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myPos = LocalPlayer.Character.HumanoidRootPart.Position
            for _, obj in ipairs(workspace:GetDescendants()) do
                if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("egg") then
                    if IsEggValid(obj) then
                        local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local dist = math.floor((myPos - part.Position).Magnitude)
                            local bg = Instance.new("BillboardGui")
                            bg.Name = "TCH_CleanESP"
                            bg.AlwaysOnTop = true
                            bg.Size = UDim2.new(0, 110, 0, 22)
                            bg.Adornee = part

                            local txt = Instance.new("TextLabel")
                            txt.Size = UDim2.new(1,0,1,0)
                            txt.BackgroundTransparency = 1
                            txt.Text = "🥚 " .. obj.Name .. (Config.ShowDistance and (" [" .. dist .. "m]") or "")
                            txt.TextColor3 = RarityColors[obj.Name] or Color3.fromRGB(0, 230, 255)
                            txt.Font = Enum.Font.GothamBold
                            txt.TextSize = 10
                            txt.Parent = bg
                            bg.Parent = part
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 7. MAIN FARM ENGINE (FLY & TP MODE)
-- ==========================================

task.spawn(function()
    while task.wait(0.2) do
        if Config.FarmMode ~= "None" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local heldEgg = GetHeldEgg()

            -- State A: Holding Egg -> Return to Base
            if heldEgg then
                if Config.SavedBaseCFrame then
                    if Config.FarmMode == "TP" then
                        hrp.CFrame = Config.SavedBaseCFrame
                        task.wait(1.2)
                    elseif Config.FarmMode == "Fly" then
                        local targetPos = Config.SavedBaseCFrame.Position
                        while (hrp.Position - targetPos).Magnitude > 4 and GetHeldEgg() do
                            local dir = (targetPos - hrp.Position).Unit
                            hrp.CFrame = CFrame.new(hrp.Position + dir * (Config.FlySpeedFarm * 0.2), targetPos)
                            task.wait(0.03)
                        end
                        task.wait(0.8)
                    end
                end
            -- State B: No Egg -> Fly/TP to Egg Target
            else
                local target = GetTargetEgg()
                if target and target.Part then
                    if Config.FarmMode == "TP" then
                        hrp.CFrame = target.Part.CFrame * CFrame.new(0, 3, 0)
                        task.wait(0.5)
                    elseif Config.FarmMode == "Fly" then
                        local targetPos = target.Part.Position + Vector3.new(0, 3, 0)
                        while (hrp.Position - targetPos).Magnitude > 4 and not GetHeldEgg() and Config.FarmMode == "Fly" do
                            local dir = (targetPos - hrp.Position).Unit
                            hrp.CFrame = CFrame.new(hrp.Position + dir * (Config.FlySpeedFarm * 0.2), targetPos)
                            task.wait(0.03)
                        end
                    end
                end
            end
        end
    end
end)
