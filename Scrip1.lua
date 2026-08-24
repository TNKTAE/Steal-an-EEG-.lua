-- ==========================================
-- Script: THE CRAFT HUB (Steal an Egg - Real Mechanics Edition 2026)
-- Complete Overhaul: Custom Zones, Proximity Pickup, Event Tree, Real Farm Loop
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then return end

if PlayerGui:FindFirstChild("TheCraftHub_RealMechanics") then
    PlayerGui.TheCraftHub_RealMechanics:Destroy()
end

-- Global Configuration State
local Config = {
    FarmEnabled = false,
    FarmMode = "TP_Return", -- TP_Return, Fly_Return, Safe_Mixed, Loop_Farm
    FlySpeed = 60,
    HoverHeight = 1.5, -- สูงจากพื้น 1.5 studs (ระดับเท้าลอยนิดเดียว)
    
    -- Zone & Filters (Map Specific)
    SelectedZone = "ทั้งหมด",
    TargetRarity = "ทั้งหมด",
    EggSizeFilter = "ทั้งหมด",
    
    -- Security & Pickup
    AutoEquipOnDrop = false,
    AutoPickProximity = false,
    AntiDropHit = false,
    
    -- Event Tree
    EventTreeMode = "Off", -- Off, Walk, Fly
    
    -- Movement
    MoveMode = "Normal", -- Normal, LowHover
    MoveSpeed = 32,
    Noclip = false,
    
    -- Visuals
    EggESP = false,
    PlayerESP = false,
    
    -- Internal Base Tracking
    BaseCFrame = nil
}

-- Automatic Base / Spawn Location Detector
local function AutoDetectBase()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        -- ลองหาจาก Folder Plots/Bases ของระบบเกมก่อน
        for _, folderName in ipairs({"Plots", "Bases", "PlayerBases", "PlotsFolder"}) do
            local folder = Workspace:FindFirstChild(folderName)
            if folder then
                for _, plot in ipairs(folder:GetChildren()) do
                    if plot:FindFirstChild("Owner") and tostring(plot.Owner.Value) == LocalPlayer.Name then
                        local spawnPart = plot:FindFirstChild("Spawn") or plot:FindFirstChildWhichIsA("BasePart")
                        if spawnPart then
                            Config.BaseCFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)
                            return
                        end
                    end
                end
            end
        end
        -- ถ้าไม่เจอ โครงสร้างเกม ให้ใช้พิกัดปัจจุบันเป็นจุดเกิด/ฐาน
        if not Config.BaseCFrame then
            Config.BaseCFrame = char.HumanoidRootPart.CFrame
        end
    end
end
AutoDetectBase()

-- ==========================================
-- GUI CREATION (Compact Scale: 460 x 350)
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHub_RealMechanics"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 460, 0, 350)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 15, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 8) MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke") MainStroke.Color = Color3.fromRGB(0, 180, 230) MainStroke.Thickness = 1.5 MainStroke.Parent = MainFrame

-- TopBar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ THE CRAFT HUB ✦ Steal an Egg (V3 Engine)"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -27, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(230, 50, 70)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11
CloseBtn.Parent = TopBar
local CloseCorner = Instance.new("UICorner") CloseCorner.CornerRadius = UDim.new(0, 4) CloseCorner.Parent = CloseBtn

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 95, 0, 30)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -15)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
ToggleBtn.Text = "⚡ CRAFT HUB"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 11
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui
local ToggleCorner = Instance.new("UICorner") ToggleCorner.CornerRadius = UDim.new(0, 6) ToggleCorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Navigation Tabs
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 125, 1, -32)
TabBar.Position = UDim2.new(0, 0, 0, 32)
TabBar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabList = Instance.new("UIListLayout") TabList.Parent = TabBar TabList.Padding = UDim.new(0, 3)

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -131, 1, -38)
ContentArea.Position = UDim2.new(0, 128, 0, 35)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local Tabs, TabPages = {}, {}
local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 28)
    btn.Position = UDim2.new(0, 3, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 170, 190)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Parent = TabBar
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 4) c.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 230)
    page.Visible = false
    page.Parent = ContentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Parent = page
    pageLayout.Padding = UDim.new(0, 5)
    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 10)
    end)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.BackgroundColor3 = Color3.fromRGB(18, 22, 30) t.TextColor3 = Color3.fromRGB(150, 170, 190) end
        for _, p in pairs(TabPages) do p.Visible = false end
        btn.BackgroundColor3 = Color3.fromRGB(0, 140, 210)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        page.Visible = true
    end)

    table.insert(Tabs, btn)
    table.insert(TabPages, page)
    return page
end

local PageFarm = CreateTab("ระบบฟาร์มไข่")
local PageFilter = CreateTab("ตัวกรองไข่ในแมป")
local PageSecurity = CreateTab("กันไข่หลุด/เก็บออโต้")
local PageEvent = CreateTab("กิจกรรม Event Tree")
local PageMove = CreateTab("การเคลื่อนที่")
local PageESP = CreateTab("มองทะลุ (ESP)")

Tabs[1].BackgroundColor3 = Color3.fromRGB(0, 140, 210)
Tabs[1].TextColor3 = Color3.fromRGB(255, 255, 255)
TabPages[1].Visible = true

-- UI Builders
local function AddToggle(page, text, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 28)
    row.BackgroundColor3 = Color3.fromRGB(18, 23, 32)
    row.Parent = page
    local rc = Instance.new("UICorner") rc.CornerRadius = UDim.new(0, 4) rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.68, 0, 1, 0)
    lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 230, 245)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 44, 0, 18)
    btn.Position = UDim2.new(1, -48, 0.5, -9)
    btn.BackgroundColor3 = Color3.fromRGB(40, 50, 65)
    btn.Text = "ปิด"
    btn.TextColor3 = Color3.fromRGB(160, 160, 160)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.Parent = row
    local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0, 9) bc.Parent = btn

    local st = false
    btn.MouseButton1Click:Connect(function()
        st = not st
        btn.Text = st and "เปิด" or "ปิด"
        btn.BackgroundColor3 = st and Color3.fromRGB(0, 180, 90) or Color3.fromRGB(40, 50, 65)
        btn.TextColor3 = st and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
        callback(st)
    end)
end

local function AddDropdown(page, text, options, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 28)
    frame.BackgroundColor3 = Color3.fromRGB(18, 23, 32)
    frame.ClipsDescendants = true
    frame.Parent = page
    local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0, 4) fc.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.48, 0, 0, 28)
    lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 230, 245)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(0.5, 0, 0, 20)
    dropBtn.Position = UDim2.new(0.48, 0, 0, 4)
    dropBtn.BackgroundColor3 = Color3.fromRGB(28, 36, 50)
    dropBtn.Text = options[1] .. " ▼"
    dropBtn.TextColor3 = Color3.fromRGB(0, 210, 255)
    dropBtn.Font = Enum.Font.GothamBold
    dropBtn.TextSize = 9
    dropBtn.Parent = frame
    local dc = Instance.new("UICorner") dc.CornerRadius = UDim.new(0, 4) dc.Parent = dropBtn

    local isOpen = false
    dropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        frame.Size = isOpen and UDim2.new(1, -6, 0, 28 + (#options * 22)) or UDim2.new(1, -6, 0, 28)
    end)

    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(0, 150, 0, 20)
        optBtn.Position = UDim2.new(0.48, 0, 0, 28 + ((i - 1) * 22))
        optBtn.BackgroundColor3 = Color3.fromRGB(24, 32, 44)
        optBtn.Text = opt
        optBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
        optBtn.Font = Enum.Font.GothamSemibold
        optBtn.TextSize = 9
        optBtn.Parent = frame

        optBtn.MouseButton1Click:Connect(function()
            dropBtn.Text = opt .. " ▼"
            isOpen = false
            frame.Size = UDim2.new(1, -6, 0, 28)
            callback(opt)
        end)
    end
end

local function AddInput(page, text, defaultVal, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 28)
    row.BackgroundColor3 = Color3.fromRGB(18, 23, 32)
    row.Parent = page
    local rc = Instance.new("UICorner") rc.CornerRadius = UDim.new(0, 4) rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 230, 245)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 60, 0, 20)
    box.Position = UDim2.new(1, -64, 0.5, -10)
    box.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
    box.Text = tostring(defaultVal)
    box.TextColor3 = Color3.fromRGB(0, 220, 255)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 10
    box.Parent = row
    local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0, 4) bc.Parent = box

    box.FocusLost:Connect(function() callback(box.Text) end)
end

-- ==========================================
-- CORE MECHANICS & FILTER FUNCTIONS
-- ==========================================

local function HasEggInHand()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and item.Name:lower():find("egg") then
            return true
        end
    end
    return false
end

-- ตรวจสอบและกรองไข่ใน Workspace ตามชื่อโซน/ระดับจริง
local function GetFilteredEggs()
    local validEggs = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("egg") then
            -- ตัดไข่ที่อยู่ในสวน หรือฐานของผู้เล่นออกทั้งหมด (ขโมยเฉพาะไข่กลางแจ้ง/โซนเปิด)
            if not obj:IsDescendantOf(LocalPlayer.Character) and not obj:FindFirstAncestor("Bases") and not obj:FindFirstAncestor("Plots") and not obj:FindFirstAncestor("Garden") then
                
                local passZone = true
                if Config.SelectedZone ~= "ทั้งหมด" then
                    local parentFolder = obj:FindFirstAncestorOfClass("Folder") or obj.Parent
                    passZone = parentFolder and parentFolder.Name:lower():find(Config.SelectedZone:lower())
                end

                local passRarity = true
                if Config.TargetRarity ~= "ทั้งหมด" then
                    passRarity = obj.Name:lower():find(Config.TargetRarity:lower())
                end

                local passSize = true
                if Config.EggSizeFilter ~= "ทั้งหมด" then
                    passSize = obj.Name:lower():find(Config.EggSizeFilter:lower())
                end

                if passZone and passRarity and passSize then
                    table.insert(validEggs, obj)
                end
            end
        end
    end
    return validEggs
end

-- ==========================================
-- 1. FARM TAB & ENGINE (No-Reset Real TP/Fly Return)
-- ==========================================

AddToggle(PageFarm, "เปิดใช้งานระบบฟาร์มอัตโนมัติ", function(v)
    Config.FarmEnabled = v
    if v then AutoDetectBase() end
end)

AddDropdown(PageFarm, "รูปแบบการฟาร์ม:", {
    "วาร์ปไปขโมย -> วาร์ปกลับฐาน",
    "บินไปขโมย -> บินกลับฐาน",
    "วาร์ปไปขโมย -> บินกลับฐาน (Safe)",
    "ฟาร์มวนเฉพาะจุด (Loop)"
}, function(v)
    if v:find("วาร์ปไปขโมย -> วาร์ปกลับฐาน") then Config.FarmMode = "TP_Return"
    elseif v:find("บินไปขโมย -> บินกลับฐาน") then Config.FarmMode = "Fly_Return"
    elseif v:find("Safe") then Config.FarmMode = "Safe_Mixed"
    else Config.FarmMode = "Loop_Farm" end
end)

-- Farm Processing Loop
task.spawn(function()
    while true do
        task.wait(0.15)
        if Config.FarmEnabled then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if root and Config.BaseCFrame then
                -- ถ้าไข่อยู่ในมือแล้ว ให้ส่งกลับฐานทันที
                if HasEggInHand() then
                    if Config.FarmMode == "TP_Return" then
                        root.CFrame = Config.BaseCFrame
                        task.wait(0.3)
                    elseif Config.FarmMode == "Fly_Return" or Config.FarmMode == "Safe_Mixed" then
                        local dist = (root.Position - Config.BaseCFrame.Position).Magnitude
                        local tw = TweenService:Create(root, TweenInfo.new(dist / Config.FlySpeed, Enum.EasingStyle.Linear), {CFrame = Config.BaseCFrame})
                        tw:Play()
                        tw.Completed:Wait()
                    end
                else
                    -- ถ้าไม่มีไข่ ไปหาไข่ในแผนที่
                    local eggs = GetFilteredEggs()
                    if #eggs > 0 then
                        local targetEgg = eggs[1]
                        local eggPart = targetEgg:IsA("BasePart") and targetEgg or targetEgg:FindFirstChildWhichIsA("BasePart")
                        
                        if eggPart then
                            if Config.FarmMode == "TP_Return" or Config.FarmMode == "Safe_Mixed" then
                                root.CFrame = eggPart.CFrame + Vector3.new(0, 2, 0)
                                task.wait(0.2)
                                firetouchinterest(root, eggPart, 0)
                                firetouchinterest(root, eggPart, 1)
                                
                                -- สั่งกด ProximityPrompt หากเกมใช้ระบบกด E
                                local prompt = eggPart:FindFirstChildOfClass("ProximityPrompt") or targetEgg:FindFirstChildOfClass("ProximityPrompt")
                                if prompt then fireproximityprompt(prompt) end
                            elseif Config.FarmMode == "Fly_Return" then
                                local targetPos = eggPart.CFrame + Vector3.new(0, Config.HoverHeight, 0)
                                local dist = (root.Position - targetPos.Position).Magnitude
                                local tw = TweenService:Create(root, TweenInfo.new(dist / Config.FlySpeed, Enum.EasingStyle.Linear), {CFrame = targetPos})
                                tw:Play()
                                tw.Completed:Wait()
                                firetouchinterest(root, eggPart, 0)
                                firetouchinterest(root, eggPart, 1)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 2. FILTERS TAB (Map Real Named Zones)
-- ==========================================

AddDropdown(PageFilter, "เลือกโซนในแมป:", {
    "ทั้งหมด",
    "Spawn Zone",
    "Middle Zone",
    "Forest Zone",
    "Volcano Zone",
    "Snow Zone",
    "Desert Zone"
}, function(v) Config.SelectedZone = v end)

AddDropdown(PageFilter, "ระดับความหายาก (Rarity):", {
    "ทั้งหมด",
    "Common",
    "Rare",
    "Epic",
    "Legendary",
    "Mythic",
    "Secret"
}, function(v) Config.TargetRarity = v end)

AddDropdown(PageFilter, "ขนาดของไข่ (Size):", {
    "ทั้งหมด",
    "Small",
    "Medium",
    "Large",
    "Giant"
}, function(v) Config.EggSizeFilter = v end)

-- ==========================================
-- 3. SECURITY & AUTOMATIC PICKUP
-- ==========================================

AddToggle(PageSecurity, "ดึงไข่กลับเข้ามือทันทีเมื่อไข่ตก", function(v) Config.AutoEquipOnDrop = v end)
AddToggle(PageSecurity, "เข้าใกล้ไข่แล้วเก็บอัตโนมัติ (Proximity)", function(v) Config.AutoPickProximity = v end)
AddToggle(PageSecurity, "กันไข่หลุดมือเมื่อถูกตี", function(v) Config.AntiDropHit = v end)

-- Pickup & Security Loops
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    -- Auto Re-Equip Tool
    if Config.AutoEquipOnDrop then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") and item.Name:lower():find("egg") then
                    item.Parent = char
                end
            end
        end
    end

    -- Proximity Auto Pickup (เมื่อเดินเข้าใกล้ไข่จะเก็บให้อัตโนมัติ)
    if Config.AutoPickProximity then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            for _, egg in ipairs(GetFilteredEggs()) do
                local part = egg:IsA("BasePart") and egg or egg:FindFirstChildWhichIsA("BasePart")
                if part and (root.Position - part.Position).Magnitude <= 12 then
                    firetouchinterest(root, part, 0)
                    firetouchinterest(root, part, 1)
                    local prompt = part:FindFirstChildOfClass("ProximityPrompt") or egg:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt) end
                end
            end
        end
    end
end)

-- ==========================================
-- 4. EVENT TREE AUTOMATION
-- ==========================================

AddDropdown(PageEvent, "โหมดไปตี Event Tree:", {
    "ปิดการทำงาน",
    "วิ่งไปหาต้นไม้ + ตีออโต้",
    "บินไปหาต้นไม้ + ตีออโต้"
}, function(v)
    if v:find("วิ่ง") then Config.EventTreeMode = "Walk"
    elseif v:find("บิน") then Config.EventTreeMode = "Fly"
    else Config.EventTreeMode = "Off" end
end)

task.spawn(function()
    while true do
        task.wait(0.3)
        if Config.EventTreeMode ~= "Off" then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            -- ค้นหา Event Tree ใน Workspace
            local tree = Workspace:FindFirstChild("EventTree") or Workspace:FindFirstChild("TreeEvent") or Workspace:FindFirstChild("GiantTree")
            if tree and root then
                local treePart = tree:IsA("BasePart") and tree or tree:FindFirstChildWhichIsA("BasePart")
                if treePart then
                    if Config.EventTreeMode == "Walk" and hum then
                        hum:MoveTo(treePart.Position)
                    elseif Config.EventTreeMode == "Fly" then
                        root.CFrame = treePart.CFrame + Vector3.new(0, 4, 0)
                    end
                    
                    -- สั่งใช้อาวุธตีอัตโนมัติ
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 5. MOVEMENT ENGINE (Low-Hover 1.5 Studs & WalkSpeed)
-- ==========================================

AddDropdown(PageMove, "โหมดการเคลื่อนที่:", {
    "วิ่งปกติ (Normal Speed)",
    "ลอยตัวแข็งระดับต่ำ (Low-Hover 1.5m)"
}, function(v)
    if v:find("ลอยตัวแข็ง") then Config.MoveMode = "LowHover" else Config.MoveMode = "Normal" end
end)

AddInput(PageMove, "กำหนดความเร็วการเคลื่อนที่:", 32, function(t)
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
            -- หยุด Animation ท่าทางให้อยู่ในลักษณะ static
            if hum:FindFirstChild("Animator") then
                for _, track in ipairs(hum.Animator:GetPlayingAnimationTracks()) do track:AdjustSpeed(0) end
            end

            -- คำนวณระยะความสูงจากพื้นจริง 1.5 Studs
            local ray = Ray.new(root.Position, Vector3.new(0, -10, 0))
            local hit, hitPos = Workspace:FindPartOnRayWithIgnoreList(ray, {char})
            local targetY = hitPos and (hitPos.Y + Config.HoverHeight) or root.Position.Y

            local moveDir = hum.MoveDirection
            local bv = root:FindFirstChild("LowHoverBV") or Instance.new("BodyVelocity")
            bv.Name = "LowHoverBV"
            bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            bv.Parent = root
            
            if moveDir.Magnitude > 0 then
                bv.Velocity = (moveDir * Config.MoveSpeed) + Vector3.new(0, (targetY - root.Position.Y) * 6, 0)
            else
                bv.Velocity = Vector3.new(0, (targetY - root.Position.Y) * 6, 0)
            end
        end

        if Config.Noclip then
            for _, p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- ==========================================
-- 6. ESP SYSTEM (Zone Filtered & Optimized Performance)
-- ==========================================

AddToggle(PageESP, "เปิดแสดงตำแหน่งไข่ (Egg ESP)", function(v) Config.EggESP = v end)
AddToggle(PageESP, "เปิดแสดงตำแหน่งผู้เล่น (Player ESP)", function(v) Config.PlayerESP = v end)

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "TheCraft_ESP_Folder"
ESPFolder.Parent = ScreenGui

task.spawn(function()
    while true do
        task.wait(0.8)
        ESPFolder:ClearAllChildren()

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        -- Egg ESP (แสดงเฉพาะไข่ในโซน ไม่แสดงในสวน/ฐาน)
        if Config.EggESP and root then
            for _, egg in ipairs(GetFilteredEggs()) do
                local part = egg:IsA("BasePart") and egg or egg:FindFirstChildWhichIsA("BasePart")
                if part then
                    local dist = math.floor((root.Position - part.Position).Magnitude)
                    
                    local bGui = Instance.new("BillboardGui")
                    bGui.Adornee = part
                    bGui.Size = UDim2.new(0, 140, 0, 30)
                    bGui.StudsOffset = Vector3.new(0, 2, 0)
                    bGui.AlwaysOnTop = true
                    bGui.Parent = ESPFolder

                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = Color3.fromRGB(0, 230, 255)
                    lbl.TextStrokeTransparency = 0
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 11
                    lbl.Text = "🥚 " .. egg.Name .. "\n[" .. dist .. "m]"
                    lbl.Parent = bGui
                end
            end
        end

        -- Player ESP
        if Config.PlayerESP and root then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local pRoot = p.Character.HumanoidRootPart
                    local dist = math.floor((root.Position - pRoot.Position).Magnitude)

                    local bGui = Instance.new("BillboardGui")
                    bGui.Adornee = pRoot
                    bGui.Size = UDim2.new(0, 140, 0, 30)
                    bGui.StudsOffset = Vector3.new(0, 3, 0)
                    bGui.AlwaysOnTop = true
                    bGui.Parent = ESPFolder

                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = Color3.fromRGB(255, 80, 80)
                    lbl.TextStrokeTransparency = 0
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 11
                    lbl.Text = "👤 " .. p.DisplayName .. "\n[" .. dist .. "m]"
                    lbl.Parent = bGui
                end
            end
        end
    end
end)
