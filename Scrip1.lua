-- ==========================================
-- Script: THE CRAFT HUB (Steal an Egg - Ultimate Edition)
-- Theme: Blue Cyberpunk UI with Category Tabs & Animations
-- Language: Thai
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Configuration & States
local Config = {
    CurrentMap = "Steal an Egg",
    AutoSteal = false,
    AutoReturn = false,
    AutoPickupDrop = false,
    AutoTreeEvent = false,
    LockEggInHand = false,
    NoDrop = false,
    Noclip = false,
    Fly = false,
    PlayerESP = false,
    EggESP = false,
    WalkSpeed = 16,
    FlySpeed = 50,
    SelectedRarity = "ทั้งหมด",
    BaseCFrame = nil
}

-- Rarity Color Palette
local RarityColors = {
    Common = Color3.fromRGB(200, 200, 200),
    Rare = Color3.fromRGB(0, 150, 255),
    Epic = Color3.fromRGB(170, 0, 255),
    Legendary = Color3.fromRGB(255, 170, 0),
    Mythic = Color3.fromRGB(255, 0, 80)
}

-- ScreenGui Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHub_Ultimate"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ------------------------------------------
-- 1. MAP SELECTION INTRO OVERLAY
-- ------------------------------------------
local MapSelectFrame = Instance.new("Frame")
MapSelectFrame.Name = "MapSelectFrame"
MapSelectFrame.Size = UDim2.new(0, 360, 0, 220)
MapSelectFrame.Position = UDim2.new(0.5, -180, 0.5, -110)
MapSelectFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
MapSelectFrame.BorderSizePixel = 0
MapSelectFrame.Parent = ScreenGui

local MapCorner = Instance.new("UICorner")
MapCorner.CornerRadius = UDim.new(0, 12)
MapCorner.Parent = MapSelectFrame

local MapStroke = Instance.new("UIStroke")
MapStroke.Color = Color3.fromRGB(0, 180, 255)
MapStroke.Thickness = 2
MapStroke.Parent = MapSelectFrame

local MapTitle = Instance.new("TextLabel")
MapTitle.Size = UDim2.new(1, 0, 0, 45)
MapTitle.BackgroundTransparency = 1
MapTitle.Text = "THE CRAFT HUB\nกรุณาเลือกแมพที่จะใช้งาน"
MapTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
MapTitle.Font = Enum.Font.GothamBold
MapTitle.TextSize = 15
MapTitle.Parent = MapSelectFrame

local MapBtnList = Instance.new("Frame")
MapBtnList.Size = UDim2.new(1, -20, 0, 150)
MapBtnList.Position = UDim2.new(0, 10, 0, 55)
MapBtnList.BackgroundTransparency = 1
MapBtnList.Parent = MapSelectFrame

local MapListLayout = Instance.new("UIListLayout")
MapListLayout.Parent = MapBtnList
MapListLayout.Padding = UDim.new(0, 8)

-- ------------------------------------------
-- 2. MAIN HUB FRAME (WITH OPEN ANIMATION)
-- ------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 0, 0, 0) -- For Intro Animation
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 12)
MainUICorner.Parent = MainFrame

local MainUIStroke = Instance.new("UIStroke")
MainUIStroke.Color = Color3.fromRGB(0, 200, 255)
MainUIStroke.Thickness = 2
MainUIStroke.Parent = MainFrame

-- Glowing Rainbow Border Animation
task.spawn(function()
    while task.wait(0.03) do
        MainUIStroke.Color = Color3.fromHSV(tick() % 4 / 4, 0.8, 1)
    end
end)

-- Top Header
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(8, 12, 18)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "THE CRAFT HUB ✦ Steal an Egg"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -32, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Floating Toggle Icon
local ToggleGuiBtn = Instance.new("TextButton")
ToggleGuiBtn.Size = UDim2.new(0, 110, 0, 35)
ToggleGuiBtn.Position = UDim2.new(0, 15, 0.5, -17)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 240)
ToggleGuiBtn.Text = "⚡ THE CRAFT"
ToggleGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleGuiBtn.Font = Enum.Font.GothamBold
ToggleGuiBtn.TextSize = 12
ToggleGuiBtn.Active = true
ToggleGuiBtn.Draggable = true
ToggleGuiBtn.Visible = false
ToggleGuiBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleGuiBtn

local function OpenMainUI()
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 520, 0, 420),
        Position = UDim2.new(0.5, -260, 0.5, -210)
    }):Play()
end

local function CloseMainUI()
    local tw = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    tw:Play()
    tw.Completed:Connect(function()
        MainFrame.Visible = false
    end)
end

ToggleGuiBtn.MouseButton1Click:Connect(function()
    if MainFrame.Visible then CloseMainUI() else OpenMainUI() end
end)
CloseBtn.MouseButton1Click:Connect(CloseMainUI)

-- Map Selector Trigger Function
local function LaunchHub(mapName)
    Config.CurrentMap = mapName
    TitleLabel.Text = "THE CRAFT HUB ✦ " .. mapName
    
    TweenService:Create(MapSelectFrame, TweenInfo.new(0.3), {Size = UDim2.new(0,0,0,0)}):Play()
    task.wait(0.3)
    MapSelectFrame:Destroy()
    
    ToggleGuiBtn.Visible = true
    OpenMainUI()
end

local function CreateMapOption(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
    btn.Text = "▶  " .. name
    btn.TextColor3 = Color3.fromRGB(200, 240, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = MapBtnList
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        LaunchHub(name)
    end)
end

CreateMapOption("Steal an Egg (แมพหลัก)")
CreateMapOption("Steal an Egg (Event Zone)")

-- ------------------------------------------
-- 3. CATEGORY TABS SCAFFOLDING
-- ------------------------------------------
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 120, 1, -40)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabBar
TabListLayout.Padding = UDim.new(0, 4)

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -130, 1, -50)
ContentArea.Position = UDim2.new(0, 125, 0, 45)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local Tabs = {}
local TabPages = {}

local function CreateTab(tabName)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, -8, 0, 36)
    tabBtn.Position = UDim2.new(0, 4, 0, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(18, 24, 34)
    tabBtn.Text = tabName
    tabBtn.TextColor3 = Color3.fromRGB(150, 170, 190)
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
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
    page.Visible = false
    page.Parent = ContentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Parent = page
    pageLayout.Padding = UDim.new(0, 6)

    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 15)
    end)

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.BackgroundColor3 = Color3.fromRGB(18, 24, 34) t.TextColor3 = Color3.fromRGB(150, 170, 190) end
        for _, p in pairs(TabPages) do p.Visible = false end
        
        tabBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        page.Visible = true
    end)

    table.insert(Tabs, tabBtn)
    table.insert(TabPages, page)
    return page
end

local PageFarm = CreateTab("ฟาร์ม & ขโมย")
local PageEvent = CreateTab("กิจกรรม")
local PageMove = CreateTab("เคลื่อนที่")
local PageVisual = CreateTab("ESP สายตา")

-- Set First Tab Active
Tabs[1].BackgroundColor3 = Color3.fromRGB(0, 150, 220)
Tabs[1].TextColor3 = Color3.fromRGB(255, 255, 255)
TabPages[1].Visible = true

-- ------------------------------------------
-- 4. UI COMPONENTS (TOGGLE & INPUT)
-- ------------------------------------------
local function AddToggle(parentPage, text, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(20, 28, 40)
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
    switch.BackgroundColor3 = Color3.fromRGB(40, 50, 65)
    switch.Text = "ปิด"
    switch.TextColor3 = Color3.fromRGB(180, 180, 180)
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
        local col = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 50, 65)
        TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = col}):Play()
        switch.TextColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(180,180,180)
        callback(state)
    end)
end

local function AddInput(parentPage, text, defaultVal, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(20, 28, 40)
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
    box.BackgroundColor3 = Color3.fromRGB(10, 15, 22)
    box.Text = tostring(defaultVal)
    box.TextColor3 = Color3.fromRGB(0, 220, 255)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 11
    box.Parent = row

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 5)
    bCorner.Parent = box

    box.FocusLost:Connect(function()
        callback(box.Text)
    end)
end

-- ------------------------------------------
-- 5. FEATURE LOGIC & IMPLEMENTATION
-- ------------------------------------------

-- Helper: Check if character holds an egg
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

-- PAGE 1: FARMING
AddToggle(PageFarm, "ขโมยไข่อัตโนมัติ (Auto Steal)", function(v) Config.AutoSteal = v end)
AddToggle(PageFarm, "ขโมยเสร็จวาร์ปกลับฐาน (Auto Return)", function(v) Config.AutoReturn = v end)
AddToggle(PageFarm, "เก็บไข่ตกพื้นรัวๆ (Auto Pickup Drop)", function(v) Config.AutoPickupDrop = v end)
AddToggle(PageFarm, "ป้องกันไข่หลุดมือ / โดนตีไข่ไม่ตก", function(v) Config.NoDrop = v end)

-- PAGE 2: EVENT
AddToggle(PageEvent, "วาร์ปไปตีต้นไม้อัตโนมัติ (Event Tree)", function(v) Config.AutoTreeEvent = v end)

-- PAGE 3: MOVEMENT
AddInput(PageMove, "ปรับความเร็ว (WalkSpeed):", 16, function(t)
    local n = tonumber(t)
    if n then Config.WalkSpeed = n end
end)
AddToggle(PageMove, "เดินทะลุสิ่งกีดขวาง (Noclip)", function(v) Config.Noclip = v end)
AddToggle(PageMove, "เปิดโหมดบิน (Fly)", function(v) Config.Fly = v end)

-- PAGE 4: VISUALS / ESP
AddToggle(PageVisual, "ESP มองทะลุตำแหน่งไข่ (Zone Only)", function(v) Config.EggESP = v end)
AddToggle(PageVisual, "ESP มองทะลุผู้เล่นอื่น", function(v) Config.PlayerESP = v end)

-- ------------------------------------------
-- 6. BACKGROUND ENGINE LOOPS
-- ------------------------------------------

-- Loop 1: WalkSpeed Fix (ไม่มีอาการค้าง/ตัวแข็ง) & Noclip
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= Config.WalkSpeed then
            hum.WalkSpeed = Config.WalkSpeed
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

-- Loop 2: Auto Pickup Dropped Eggs (เก็บทันทีเมื่อไข่หลุด)
RunService.RenderStepped:Connect(function()
    if Config.AutoPickupDrop then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and not GetHeldEgg() then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("egg") and not obj:IsDescendantOf(char) then
                    if (char.HumanoidRootPart.Position - obj.Position).Magnitude < 20 then
                        firetouchinterest(char.HumanoidRootPart, obj, 0)
                        firetouchinterest(char.HumanoidRootPart, obj, 1)
                    end
                end
            end
        end
    end
end)

-- Loop 3: ESP Zone Visuals (กรองมองเฉพาะโซนขโมย)
task.spawn(function()
    while task.wait(0.8) do
        for _, old in ipairs(workspace:GetDescendants()) do
            if old.Name == "TCH_ESP" then old:Destroy() end
        end

        if Config.EggESP then
            local stealZone = workspace:FindFirstChild("StealZone") or workspace:FindFirstChild("Eggs") or workspace
            for _, obj in ipairs(stealZone:GetDescendants()) do
                if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("egg") then
                    -- กรองไข่ในฐานผู้เล่นออก
                    if not obj:FindFirstAncestor("Bases") and not obj:FindFirstAncestor("Plots") then
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
                            txt.TextColor3 = RarityColors[obj.Name] or Color3.fromRGB(0, 220, 255)
                            txt.Font = Enum.Font.GothamBold
                            txt.TextSize = 11
                            txt.Parent = bg
                            bg.Parent = part
                        end
                    end
                end
            end
        end
    end
end)
