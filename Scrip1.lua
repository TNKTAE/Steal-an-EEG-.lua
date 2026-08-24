-- ==========================================
-- Script: THE CRAFT HUB (Steal an Egg - V4 Ultimate Edition)
-- Fixed All Core Bugs | Real Teleport & Hover | Optimized ESP
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then return end

if PlayerGui:FindFirstChild("TheCraftHub_V4") then
    PlayerGui.TheCraftHub_V4():Destroy()
end

-- Global Master Configuration State
local Config = {
    -- Master Toggles
    FarmEnabled = false,
    FarmMode = "TP_Return", -- TP_Return, Fly_Return, Safe_Mixed
    FlySpeed = 60,
    HoverHeight = 1.5,
    
    -- Filter Selection
    SelectedZone = "ทั้งหมด",
    TargetRarity = "ทั้งหมด",
    
    -- Security Toggles
    AutoReEquip = false,
    AutoProximityGrab = false,
    AntiKnockback = false,
    
    -- Event Automation
    EventTreeEnabled = false,
    EventTreeMode = "Fly", -- Walk, Fly
    
    -- Movement Toggles
    MoveMode = "Off", -- Off, Normal, LowHover
    MoveSpeed = 32,
    Noclip = false,
    
    -- Visual (ESP) Toggles
    EggESPEnabled = false,
    PlayerESPEnabled = false,
    ESPShowDistance = true,
    
    -- Base Data
    BaseCFrame = nil
}

-- Automatic Base Detector Engine
local function AutoDetectBase()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        -- ค้นหา Plot ของผู้เล่น
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("StringValue") or obj:IsA("ObjectValue") then
                if obj.Name == "Owner" and tostring(obj.Value) == LocalPlayer.Name then
                    local parentPlot = obj.Parent
                    local spawnPart = parentPlot:FindFirstChild("Spawn") or parentPlot:FindFirstChildWhichIsA("BasePart")
                    if spawnPart then
                        Config.BaseCFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)
                        return
                    end
                end
            end
        end
        -- Fallback ใช้พิกัดปัจจุบันเป็นฐาน
        if not Config.BaseCFrame then
            Config.BaseCFrame = char.HumanoidRootPart.CFrame
        end
    end
end
AutoDetectBase()

-- Target Validation Engine (คัดแยกไข่จริง ออกจากสัตว์เลี้ยง/ลู่วิ่ง/ของแต่งสวน)
local function IsRealEgg(obj)
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then return false end
    
    local name = obj.Name:lower()
    
    -- กรองสิ่งที่ไม่ใช่ไข่ออก 100%
    if name:find("pet") or name:find("treadmill") or name:find("runner") or name:find("deco") or name:find("animal") then
        return false
    end
    
    -- ตัดวัตถุที่อยู่ใน Plot/Garden/Base ทั้งหมด
    if obj:FindFirstAncestor("Plots") or obj:FindFirstAncestor("Bases") or obj:FindFirstAncestor("Garden") or obj:FindFirstAncestor("Decorations") then
        return false
    end
    if LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character) then return false end

    -- ต้องมี TouchInterest หรือ ProximityPrompt หรือมีชื่อไข่
    local hasPrompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    local hasTouch = obj:FindFirstChildWhichIsA("TouchTransmitter", true)
    local isEggName = name:find("egg") or name:find("rare") or name:find("legend") or name:find("mythic")
    
    if not (hasPrompt or hasTouch or isEggName) then return false end

    -- กรองตามโซนที่เลือก
    if Config.SelectedZone ~= "ทั้งหมด" then
        local parentFolder = obj:FindFirstAncestorOfClass("Folder") or obj.Parent
        if not parentFolder or not parentFolder.Name:lower():find(Config.SelectedZone:lower()) then
            return false
        end
    end

    -- กรองตามระดับความหายาก
    if Config.TargetRarity ~= "ทั้งหมด" then
        if not name:find(Config.TargetRarity:lower()) then
            return false
        end
    end

    return true
end

-- ==========================================
-- GUI BUILDER (Compact 450x340 Frame)
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHub_V4"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 340)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(11, 14, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 8) MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke") MainStroke.Color = Color3.fromRGB(0, 190, 245) MainStroke.Thickness = 1.5 MainStroke.Parent = MainFrame

-- TopBar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(7, 9, 14)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 8, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ THE CRAFT HUB ✦ Steal an Egg (V4 Engine)"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.TextSize = 11
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -24, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(230, 40, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 10
CloseBtn.Parent = TopBar
local CloseCorner = Instance.new("UICorner") CloseCorner.CornerRadius = UDim.new(0, 4) CloseCorner.Parent = CloseBtn

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 90, 0, 28)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -14)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
ToggleBtn.Text = "⚡ CRAFT HUB"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 10
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui
local ToggleCorner = Instance.new("UICorner") ToggleCorner.CornerRadius = UDim.new(0, 6) ToggleCorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Navigation Sidebar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 120, 1, -30)
TabBar.Position = UDim2.new(0, 0, 0, 30)
TabBar.BackgroundColor3 = Color3.fromRGB(9, 11, 16)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabList = Instance.new("UIListLayout") TabList.Parent = TabBar TabList.Padding = UDim.new(0, 2)

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -126, 1, -36)
ContentArea.Position = UDim2.new(0, 123, 0, 33)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local Tabs, TabPages = {}, {}
local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 26)
    btn.Position = UDim2.new(0, 2, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(140, 160, 185)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.Parent = TabBar
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 4) c.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 230)
    page.Visible = false
    page.Parent = ContentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Parent = page
    pageLayout.Padding = UDim.new(0, 4)
    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 8)
    end)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.BackgroundColor3 = Color3.fromRGB(16, 20, 28) t.TextColor3 = Color3.fromRGB(140, 160, 185) end
        for _, p in pairs(TabPages) do p.Visible = false end
        btn.BackgroundColor3 = Color3.fromRGB(0, 140, 210)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        page.Visible = true
    end)

    table.insert(Tabs, btn)
    table.insert(TabPages, page)
    return page
end

local PageFarm = CreateTab("ระบบฟาร์มหลัก")
local PageFilter = CreateTab("ตัวกรองไข่")
local PageSecurity = CreateTab("กันไข่หลุด/ล็อคตัว")
local PageEvent = CreateTab("กิจกรรม Event Tree")
local PageMove = CreateTab("การเคลื่อนที่")
local PageESP = CreateTab("ระบบมองทะลุ")

Tabs[1].BackgroundColor3 = Color3.fromRGB(0, 140, 210)
Tabs[1].TextColor3 = Color3.fromRGB(255, 255, 255)
TabPages[1].Visible = true

-- Shared Component Helpers
local function AddToggle(page, text, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 26)
    row.BackgroundColor3 = Color3.fromRGB(16, 21, 30)
    row.Parent = page
    local rc = Instance.new("UICorner") rc.CornerRadius = UDim.new(0, 4) rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.68, 0, 1, 0)
    lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 225, 245)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 16)
    btn.Position = UDim2.new(1, -44, 0.5, -8)
    btn.BackgroundColor3 = Color3.fromRGB(35, 45, 60)
    btn.Text = "ปิด"
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.Parent = row
    local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0, 8) bc.Parent = btn

    local st = false
    btn.MouseButton1Click:Connect(function()
        st = not st
        btn.Text = st and "เปิด" or "ปิด"
        btn.BackgroundColor3 = st and Color3.fromRGB(0, 180, 90) or Color3.fromRGB(35, 45, 60)
        btn.TextColor3 = st and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
        callback(st)
    end)
end

local function AddDropdown(page, text, options, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -4, 0, 26)
    frame.BackgroundColor3 = Color3.fromRGB(16, 21, 30)
    frame.ClipsDescendants = true
    frame.Parent = page
    local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0, 4) fc.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.48, 0, 0, 26)
    lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 225, 245)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(0.48, 0, 0, 18)
    dropBtn.Position = UDim2.new(0.48, 0, 0, 4)
    dropBtn.BackgroundColor3 = Color3.fromRGB(25, 33, 46)
    dropBtn.Text = options[1] .. " ▼"
    dropBtn.TextColor3 = Color3.fromRGB(0, 210, 255)
    dropBtn.Font = Enum.Font.GothamBold
    dropBtn.TextSize = 8
    dropBtn.Parent = frame
    local dc = Instance.new("UICorner") dc.CornerRadius = UDim.new(0, 4) dc.Parent = dropBtn

    local isOpen = false
    dropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        frame.Size = isOpen and UDim2.new(1, -4, 0, 26 + (#options * 20)) or UDim2.new(1, -4, 0, 26)
    end)

    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(0.48, 0, 0, 18)
        optBtn.Position = UDim2.new(0.48, 0, 0, 26 + ((i - 1) * 20))
        optBtn.BackgroundColor3 = Color3.fromRGB(20, 26, 36)
        optBtn.Text = opt
        optBtn.TextColor3 = Color3.fromRGB(190, 210, 230)
        optBtn.Font = Enum.Font.GothamSemibold
        optBtn.TextSize = 8
        optBtn.Parent = frame

        optBtn.MouseButton1Click:Connect(function()
            dropBtn.Text = opt .. " ▼"
            isOpen = false
            frame.Size = UDim2.new(1, -4, 0, 26)
            callback(opt)
        end)
    end
end

local function AddInput(page, text, defaultVal, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 26)
    row.BackgroundColor3 = Color3.fromRGB(16, 21, 30)
    row.Parent = page
    local rc = Instance.new("UICorner") rc.CornerRadius = UDim.new(0, 4) rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 225, 245)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 55, 0, 18)
    box.Position = UDim2.new(1, -59, 0.5, -9)
    box.BackgroundColor3 = Color3.fromRGB(10, 13, 18)
    box.Text = tostring(defaultVal)
    box.TextColor3 = Color3.fromRGB(0, 220, 255)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 9
    box.Parent = row
    local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0, 4) bc.Parent = box

    box.FocusLost:Connect(function() callback(box.Text) end)
end

-- ==========================================
-- 1. AUTO FARM ENGINE
-- ==========================================

AddToggle(PageFarm, "เปิดใช้งานระบบฟาร์มไข่อัตโนมัติ", function(v)
    Config.FarmEnabled = v
    if v then AutoDetectBase() end
end)

AddDropdown(PageFarm, "รูปแบบการฟาร์ม:", {
    "วาร์ปไปขโมย -> วาร์ปกลับฐาน",
    "บินไปขโมย -> บินกลับฐาน",
    "วาร์ปไปขโมย -> บินกลับฐาน"
}, function(v)
    if v:find("วาร์ปไปขโมย -> วาร์ปกลับฐาน") then Config.FarmMode = "TP_Return"
    elseif v:find("บินไปขโมย -> บินกลับฐาน") then Config.FarmMode = "Fly_Return"
    else Config.FarmMode = "Safe_Mixed" end
end)

local function HasEggInHand()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") or item.Name:lower():find("egg") then
            return true
        end
    end
    return false
end

-- Farm Process Loop Thread
task.spawn(function()
    while true do
        task.wait(0.2)
        if Config.FarmEnabled then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if root and Config.BaseCFrame then
                if HasEggInHand() then
                    -- ถือไข่อยู่ -> พาพาบิน/วาร์ปกลับฐานทันที
                    if Config.FarmMode == "TP_Return" then
                        root.CFrame = Config.BaseCFrame
                        task.wait(0.3)
                    else
                        local dist = (root.Position - Config.BaseCFrame.Position).Magnitude
                        local tw = TweenService:Create(root, TweenInfo.new(dist / Config.FlySpeed, Enum.EasingStyle.Linear), {CFrame = Config.BaseCFrame})
                        tw:Play()
                        tw.Completed:Wait()
                    end
                else
                    -- ยังไม่มีไข่ -> หาไข่ที่ตรงเงื่อนไข
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if IsRealEgg(obj) then
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if part then
                                if Config.FarmMode == "TP_Return" or Config.FarmMode == "Safe_Mixed" then
                                    root.CFrame = part.CFrame + Vector3.new(0, 2, 0)
                                    task.wait(0.2)
                                    firetouchinterest(root, part, 0)
                                    firetouchinterest(root, part, 1)
                                    local prompt = part:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildOfClass("ProximityPrompt")
                                    if prompt then fireproximityprompt(prompt) end
                                    break
                                elseif Config.FarmMode == "Fly_Return" then
                                    local targetPos = part.CFrame + Vector3.new(0, Config.HoverHeight, 0)
                                    local dist = (root.Position - targetPos.Position).Magnitude
                                    local tw = TweenService:Create(root, TweenInfo.new(dist / Config.FlySpeed, Enum.EasingStyle.Linear), {CFrame = targetPos})
                                    tw:Play()
                                    tw.Completed:Wait()
                                    firetouchinterest(root, part, 0)
                                    firetouchinterest(root, part, 1)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 2. FILTERS TAB
-- ==========================================

AddDropdown(PageFilter, "เลือกโซนที่ต้องการขโมย:", {
    "ทั้งหมด",
    "Spawn",
    "Middle",
    "Forest",
    "Volcano",
    "Snow",
    "Desert"
}, function(v) Config.SelectedZone = v end)

AddDropdown(PageFilter, "เลือกความหายากของไข่:", {
    "ทั้งหมด",
    "Common",
    "Rare",
    "Epic",
    "Legendary",
    "Mythic"
}, function(v) Config.TargetRarity = v end)

-- ==========================================
-- 3. SECURITY & PICKUP ENGINE
-- ==========================================

AddToggle(PageSecurity, "บังคับดึงไข่กลับเข้ามือเมื่อไข่หลุด", function(v) Config.AutoReEquip = v end)
AddToggle(PageSecurity, "เก็บไข่อัตโนมัติเมื่อเดินเข้าใกล้", function(v) Config.AutoProximityGrab = v end)
AddToggle(PageSecurity, "ป้องกันตัวกระเด็น/ล้มเมื่อโดนตี (Anti-Knockback)", function(v) Config.AntiKnockback = v end)

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    if Config.AutoReEquip then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") and item.Name:lower():find("egg") then
                    item.Parent = char
                end
            end
        end
    end

    if Config.AutoProximityGrab then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if IsRealEgg(obj) then
                    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    if part and (root.Position - part.Position).Magnitude <= 15 then
                        firetouchinterest(root, part, 0)
                        firetouchinterest(root, part, 1)
                        local prompt = part:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then fireproximityprompt(prompt) end
                    end
                end
            end
        end
    end

    if Config.AntiKnockback then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end
    end
end)

-- ==========================================
-- 4. EVENT TREE AUTOMATION
-- ==========================================

AddToggle(PageEvent, "เปิดใช้งานระบบ Event Tree", function(v) Config.EventTreeEnabled = v end)
AddDropdown(PageEvent, "การเดินทางไปต้นไม้:", {"บินไปหาต้นไม้", "วิ่งไปหาต้นไม้"}, function(v)
    if v:find("บิน") then Config.EventTreeMode = "Fly" else Config.EventTreeMode = "Walk" end
end)

task.spawn(function()
    while true do
        task.wait(0.4)
        if Config.EventTreeEnabled then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            local tree = Workspace:FindFirstChild("EventTree", true) or Workspace:FindFirstChild("GiantTree", true)
            if tree and root then
                local part = tree:IsA("BasePart") and tree or tree:FindFirstChildWhichIsA("BasePart")
                if part then
                    if Config.EventTreeMode == "Fly" then
                        root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                    elseif hum then
                        hum:MoveTo(part.Position)
                    end
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
        end
    end
end)

-- ==========================================
-- 5. MOVEMENT ENGINE (Low-Hover 1.5 Studs Fix)
-- ==========================================

AddDropdown(PageMove, "โหมดการเคลื่อนที่:", {
    "ปิดใช้งาน (Normal)",
    "วิ่งไว (Custom WalkSpeed)",
    "ลอยตัวแข็งระดับต่ำ (Low-Hover 1.5m)"
}, function(v)
    if v:find("วิ่งไว") then Config.MoveMode = "Normal"
    elseif v:find("ลอยตัวแข็ง") then Config.MoveMode = "LowHover"
    else Config.MoveMode = "Off" end
end)

AddInput(PageMove, "กำหนดค่าความเร็ว (Speed):", 32, function(t)
    local n = tonumber(t)
    if n then Config.MoveSpeed = n end
end)

AddToggle(PageMove, "เดินทะลุสิ่งกีดขวาง (Noclip)", function(v) Config.Noclip = v end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if root and hum then
        if Config.MoveMode == "Normal" then
            hum.WalkSpeed = Config.MoveSpeed
            if root:FindFirstChild("LowHoverBV") then root.LowHoverBV:Destroy() end
        elseif Config.MoveMode == "LowHover" then
            if hum:FindFirstChild("Animator") then
                for _, track in ipairs(hum.Animator:GetPlayingAnimationTracks()) do track:AdjustSpeed(0) end
            end

            local ray = Ray.new(root.Position, Vector3.new(0, -10, 0))
            local hit, hitPos = Workspace:FindPartOnRayWithIgnoreList(ray, {char})
            local targetY = hitPos and (hitPos.Y + Config.HoverHeight) or root.Position.Y

            local moveDir = hum.MoveDirection
            local bv = root:FindFirstChild("LowHoverBV") or Instance.new("BodyVelocity")
            bv.Name = "LowHoverBV"
            bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            bv.Parent = root

            if moveDir.Magnitude > 0 then
                bv.Velocity = (moveDir * Config.MoveSpeed) + Vector3.new(0, (targetY - root.Position.Y) * 5, 0)
            else
                bv.Velocity = Vector3.new(0, (targetY - root.Position.Y) * 5, 0)
            end
        else
            if root:FindFirstChild("LowHoverBV") then root.LowHoverBV:Destroy() end
        end

        if Config.Noclip then
            for _, p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- ==========================================
-- 6. ESP SYSTEM (Zone & Egg Specific Engine)
-- ==========================================

AddToggle(PageESP, "เปิดแสดงตำแหน่งไข่ (Egg ESP)", function(v) Config.EggESPEnabled = v end)
AddToggle(PageESP, "เปิดแสดงตำแหน่งผู้เล่น (Player ESP)", function(v) Config.PlayerESPEnabled = v end)

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "TheCraft_ESP_Holder"
ESPFolder.Parent = ScreenGui

task.spawn(function()
    while true do
        task.wait(1)
        ESPFolder:ClearAllChildren()

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if Config.EggESPEnabled and root then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if IsRealEgg(obj) then
                    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local dist = math.floor((root.Position - part.Position).Magnitude)

                        local bGui = Instance.new("BillboardGui")
                        bGui.Adornee = part
                        bGui.Size = UDim2.new(0, 130, 0, 26)
                        bGui.StudsOffset = Vector3.new(0, 2, 0)
                        bGui.AlwaysOnTop = true
                        bGui.Parent = ESPFolder

                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextColor3 = Color3.fromRGB(0, 220, 255)
                        lbl.TextStrokeTransparency = 0
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 10
                        lbl.Text = "🥚 " .. obj.Name .. " [" .. dist .. "m]"
                        lbl.Parent = bGui
                    end
                end
            end
        end

        if Config.PlayerESPEnabled and root then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local pRoot = p.Character.HumanoidRootPart
                    local dist = math.floor((root.Position - pRoot.Position).Magnitude)

                    local bGui = Instance.new("BillboardGui")
                    bGui.Adornee = pRoot
                    bGui.Size = UDim2.new(0, 130, 0, 26)
                    bGui.StudsOffset = Vector3.new(0, 3, 0)
                    bGui.AlwaysOnTop = true
                    bGui.Parent = ESPFolder

                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = Color3.fromRGB(255, 70, 70)
                    lbl.TextStrokeTransparency = 0
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 10
                    lbl.Text = "👤 " .. p.DisplayName .. " [" .. dist .. "m]"
                    lbl.Parent = bGui
                end
            end
        end
    end
end)
