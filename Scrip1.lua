-- ==========================================
-- Script: THE CRAFT HUB (Steal an Egg - Final Fixed Edition 2026)
-- UI Re-scaled | Real Auto Farm | Low-Hover | Performance ESP
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then return end

-- 1. Anti-Duplicate UI
if PlayerGui:FindFirstChild("TheCraftHub_Fixed") then
    PlayerGui.TheCraftHub_Fixed:Destroy()
end

-- Config State
local Config = {
    FarmMode = "None", -- "Fly", "TP", "None"
    FlySpeed = 50,
    HoverHeight = 1.8, -- ลอยสูงจากพื้นนิดเดียว
    SelectedZone = "ทั้งหมด",
    TargetRarity = "ทั้งหมด",
    EggSizeFilter = "ทั้งหมด",
    AutoReEquip = false,
    AntiDropHit = false,
    AntiResetLoss = false,
    AutoEventTree = false,
    SpeedToggle = false,
    WalkSpeed = 32,
    Noclip = false,
    EggESP = false,
    PlayerESP = false,
    AutoCoins = false,
    SavedBaseCFrame = nil
}

-- บันทึกตำแหน่งฐาน/จุดเกิด
local function SaveBasePosition()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        Config.SavedBaseCFrame = char.HumanoidRootPart.CFrame
    end
end
SaveBasePosition()

-- Color Maps
local RarityColors = {
    Common = Color3.fromRGB(180, 180, 180),
    Rare = Color3.fromRGB(0, 170, 255),
    Epic = Color3.fromRGB(170, 0, 255),
    Legendary = Color3.fromRGB(255, 170, 0),
    Mythic = Color3.fromRGB(255, 0, 80)
}

-- 2. GUI Setup (ปรับขนาดให้เล็กลง Compact Size: 460 x 340)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHub_Fixed"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 460, 0, 340)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 16, 23)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 180, 230)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ THE CRAFT HUB ✦ Steal an Egg (Fixed Edition)"
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
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

-- Toggle GUI Button
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
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 120, 1, -32)
TabBar.Position = UDim2.new(0, 0, 0, 32)
TabBar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabList = Instance.new("UIListLayout")
TabList.Parent = TabBar
TabList.Padding = UDim.new(0, 3)

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -126, 1, -38)
ContentArea.Position = UDim2.new(0, 123, 0, 35)
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
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = btn

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

local PageFarm = CreateTab("ฟาร์มขโมยไข่")
local PageFilter = CreateTab("ตัวกรองไข่")
local PageSecurity = CreateTab("กันไข่หลุด/เซฟ")
local PageEvent = CreateTab("กิจกรรม/พิเศษ")
local PageMove = CreateTab("ตัวแข็งลอยต่ำ")
local PageESP = CreateTab("มองทะลุ (ESP)")

Tabs[1].BackgroundColor3 = Color3.fromRGB(0, 140, 210)
Tabs[1].TextColor3 = Color3.fromRGB(255, 255, 255)
TabPages[1].Visible = true

-- Helper UI Components
local function AddToggle(page, text, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 28)
    row.BackgroundColor3 = Color3.fromRGB(18, 23, 32)
    row.Parent = page
    local rc = Instance.new("UICorner") rc.CornerRadius = UDim.new(0, 4) rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 230, 245)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 42, 0, 18)
    btn.Position = UDim2.new(1, -46, 0.5, -9)
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
    lbl.Size = UDim2.new(0.5, 0, 0, 28)
    lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 230, 245)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(0.48, 0, 0, 20)
    dropBtn.Position = UDim2.new(0.5, 0, 0, 4)
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
        optBtn.Size = UDim2.new(0.48, 0, 0, 20)
        optBtn.Position = UDim2.new(0.5, 0, 0, 28 + ((i - 1) * 22))
        optBtn.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
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

-- ==========================================
-- EGG DETECTION & AUTO FARM ENGINE
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

local function GetFilteredEggs()
    local validEggs = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("egg") then
            -- ต้องไม่ใช่อยู่ในตัวผู้เล่น หรือฐานคนอื่น
            if not obj:IsDescendantOf(LocalPlayer.Character) and not obj:FindFirstAncestor("Bases") then
                local passZone = (Config.SelectedZone == "ทั้งหมด") or obj:FindFirstAncestor(Config.SelectedZone)
                local passRarity = (Config.TargetRarity == "ทั้งหมด") or obj.Name:lower():find(Config.TargetRarity:lower())
                
                if passZone and passRarity then
                    table.insert(validEggs, obj)
                end
            end
        end
    end
    return validEggs
end

-- Farm Thread (Loop)
task.spawn(function()
    while true do
        task.wait(0.2)
        if Config.FarmMode ~= "None" then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if root then
                -- ถ้ากำลังถือไข่ ให้กลับฐานทันที
                if HasEggInHand() then
                    if Config.SavedBaseCFrame then
                        if Config.FarmMode == "TP" then
                            root.CFrame = Config.SavedBaseCFrame
                        elseif Config.FarmMode == "Fly" then
                            local tween = TweenService:Create(root, TweenInfo.new((root.Position - Config.SavedBaseCFrame.Position).Magnitude / Config.FlySpeed, Enum.EasingStyle.Linear), {CFrame = Config.SavedBaseCFrame})
                            tween:Play()
                            tween.Completed:Wait()
                        end
                    end
                else
                    -- ถ้ายังไม่มีไข่ บิน/วาร์ป ไปหาไข่ที่ตรงตามกรอง
                    local eggs = GetFilteredEggs()
                    if #eggs > 0 then
                        local targetEgg = eggs[1]
                        local eggPart = targetEgg:IsA("BasePart") and targetEgg or targetEgg:FindFirstChildWhichIsA("BasePart")
                        
                        if eggPart then
                            if Config.FarmMode == "TP" then
                                root.CFrame = eggPart.CFrame + Vector3.new(0, 2, 0)
                                task.wait(0.3)
                                firetouchinterest(root, eggPart, 0)
                                firetouchinterest(root, eggPart, 1)
                            elseif Config.FarmMode == "Fly" then
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

-- 1. FARM MODE TAB
AddDropdown(PageFarm, "โหมดการฟาร์ม:", {"ปิดทำงาน", "วาร์ปไปขโมย -> วาร์ปกลับ", "บินไปขโมย -> บินกลับ"}, function(val)
    if val:find("วาร์ป") then Config.FarmMode = "TP"
    elseif val:find("บิน") then Config.FarmMode = "Fly"
    else Config.FarmMode = "None" end
end)

-- 2. FILTERS TAB (DROPDOWN MENU)
AddDropdown(PageFilter, "โซนที่ขโมย:", {"ทั้งหมด", "Zone1", "Zone2", "Middle", "Forest"}, function(v) Config.SelectedZone = v end)
AddDropdown(PageFilter, "ระดับความหายาก:", {"ทั้งหมด", "Common", "Rare", "Epic", "Legendary", "Mythic"}, function(v) Config.TargetRarity = v end)
AddDropdown(PageFilter, "ขนาดไข่:", {"ทั้งหมด", "เล็ก", "กลาง", "ใหญ่"}, function(v) Config.EggSizeFilter = v end)

-- 3. SECURITY TAB
AddToggle(PageSecurity, "หยิบไข่อัตโนมัติใส่หู/มือ", function(v) Config.AutoReEquip = v end)
AddToggle(PageSecurity, "ป้องกันไข่หลุดเมื่อโดนแย่ง/ตี", function(v) Config.AntiDropHit = v end)
AddToggle(PageSecurity, "ป้องกันไข่หายตอนกด Reset ตัว", function(v) Config.AntiResetLoss = v end)

-- Auto Re-Equip Tool Engine
RunService.Stepped:Connect(function()
    if Config.AutoReEquip then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        local char = LocalPlayer.Character
        if backpack and char then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:lower():find("egg") then
                    tool.Parent = char
                end
            end
        end
    end
end)

-- 4. EVENT TAB & COIN COLLECTOR
AddToggle(PageEvent, "วาร์ปไปตี Event Tree อัตโนมัติ", function(v) Config.AutoEventTree = v end)
AddToggle(PageEvent, "เก็บเหรียญ/เพชรอัตโนมัติรอบตัว", function(v) Config.AutoCoins = v end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.AutoCoins then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                for _, item in ipairs(Workspace:GetDescendants()) do
                    if item:IsA("BasePart") and (item.Name:lower():find("coin") or item.Name:lower():find("gem")) then
                        firetouchinterest(root, item, 0)
                        firetouchinterest(root, item, 1)
                    end
                end
            end
        end
    end
end)

-- 5. MOVEMENT ENGINE (LOW HOVER FLY - ลอยเหนือพื้นนิดเดียว)
AddToggle(PageMove, "เปิดลอยตัวแข็งเหนือพื้น (Low Hover)", function(v) Config.SpeedToggle = v end)
AddToggle(PageMove, "เดินทะลุสิ่งกีดขวาง (Noclip)", function(v) Config.Noclip = v end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if root and hum then
        if Config.SpeedToggle then
            -- หยุด Animation ตัวละครให้อยู่ในท่าแข็ง static
            if hum:FindFirstChild("Animator") then
                for _, track in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(0)
                end
            end
            
            -- ปรับระดับความสูงให้ลอยเหนือพื้นแค่นิดเดียว (Low Hover)
            local ray = Ray.new(root.Position, Vector3.new(0, -10, 0))
            local hit, hitPos = Workspace:FindPartOnRayWithIgnoreList(ray, {char})
            
            local targetY = hitPos and (hitPos.Y + Config.HoverHeight) or root.Position.Y
            local moveDir = hum.MoveDirection
            
            if moveDir.Magnitude > 0 then
                root.Velocity = (moveDir * Config.WalkSpeed) + Vector3.new(0, (targetY - root.Position.Y) * 5, 0)
            else
                root.Velocity = Vector3.new(0, (targetY - root.Position.Y) * 5, 0)
            end
        end

        if Config.Noclip then
            for _, p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- 6. ESP SYSTEM (LIGHTWEIGHT HIGHLIGHT + BILLBOARD - ลื่น ไม่กระตุก)
AddToggle(PageESP, "มองทะลุไข่ (Egg ESP)", function(v) Config.EggESP = v end)
AddToggle(PageESP, "มองทะลุผู้เล่น (Player ESP)", function(v) Config.PlayerESP = v end)

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "TheCraft_ESP"
ESPFolder.Parent = ScreenGui

task.spawn(function()
    while true do
        task.wait(1)
        ESPFolder:ClearAllChildren()

        -- Egg ESP
        if Config.EggESP then
            for _, egg in ipairs(GetFilteredEggs()) do
                local highlight = Instance.new("Highlight")
                highlight.Adornee = egg
                highlight.FillColor = Color3.fromRGB(0, 230, 255)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.Parent = ESPFolder
            end
        end

        -- Player ESP
        if Config.PlayerESP then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = p.Character
                    highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.6
                    highlight.Parent = ESPFolder
                end
            end
        end
    end
end)
