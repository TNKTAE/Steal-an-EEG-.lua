--[[
    THE CRAFT HUB - สคริปต์อเนกประสงค์
    รองรับภาษา: ไทย / English
    UI: น้ำเงิน-ดำ เท่ๆ
]]

-- ==================== การตั้งค่าหลัก ====================
local ScriptName = "THE CRAFT HUB"
local Version = "1.0.0"
local Language = "TH" -- TH / EN
local ToggleUI = true

-- ==================== ระบบภาษา ====================
local Translations = {
    TH = {
        mainTitle = "THE CRAFT HUB",
        category_event = "⚡ อีเว้น",
        category_esp = "👁️ มองทะลุ",
        category_movement = "🏃 การเคลื่อนไหว",
        category_combat = "⚔️ ต่อสู้",
        category_teleport = "🌐 ย้ายเซิฟ",
        category_misc = "🔧 อื่นๆ",
        btn_enable_all = "เปิดทั้งหมด",
        btn_disable_all = "ปิดทั้งหมด",
        btn_language = "เปลี่ยนภาษา",
        toggle_on = "เปิด",
        toggle_off = "ปิด",
        -- ฟีเจอร์
        feat_auto_tree = "ตีต้นไม้อัตโนมัติ (small)",
        feat_steal_egg_monster = "ขโมยไข่ MonsterParasiteVisual",
        feat_loot_treadmill = "เสกลู่วิ่ง AdminTreadmill",
        feat_steal_egg_fx = "ขโมยไข่ที่มี FX",
        feat_esp_egg = "มองทะลุไข่ (รวมซ้ำ)",
        feat_esp_player = "มองทะลุผู้เล่น",
        feat_auto_steal_egg = "ขโมยไข่อัตโนมัติ (AreaEggSlotsClient)",
        feat_speed = "ปรับความเร็ว (สูงสุด 2000)",
        feat_anti_egg_drop = "กันไข่หลุด (กด E อัตโนมัติ)",
        feat_fast_pickup = "เก็บไข่เร็ว (กดครั้งเดียว)",
        feat_high_jump = "กระโดดสูง (ปรับได้)",
        feat_infinite_jump = "กระโดดไม่จำกัด",
        feat_zigzag = "ซิกแซกตอนขโมยไข่",
        feat_fast_attack = "ตีไว (ถืออาวุธ)",
        feat_no_knockback = "ไม่กระเด็น",
        feat_server_hop = "ย้ายเซิฟเวอร์",
        feat_zone_select = "เลือกโซนขโมยไข่",
        -- โซน
        zone_label = "โซนเป้าหมาย:",
        zone_refresh = "รีเฟรชโซน",
        -- อื่นๆ
        speed_label = "ความเร็ว:",
        jump_label = "พลังกระโดด:",
        server_label = "เซิฟเวอร์:",
        btn_join = "เข้าร่วม",
        lang_th = "ไทย",
        lang_en = "English",
        status_running = "กำลังทำงาน",
        status_stopped = "หยุดทำงาน",
        no_target = "ไม่พบเป้าหมาย",
        found_target = "พบเป้าหมาย",
        stealing = "กำลังขโมย...",
        returning = "กลับฐาน...",
    },
    EN = {
        mainTitle = "THE CRAFT HUB",
        category_event = "⚡ Event",
        category_esp = "👁️ ESP",
        category_movement = "🏃 Movement",
        category_combat = "⚔️ Combat",
        category_teleport = "🌐 Server Hop",
        category_misc = "🔧 Misc",
        btn_enable_all = "Enable All",
        btn_disable_all = "Disable All",
        btn_language = "Change Language",
        toggle_on = "ON",
        toggle_off = "OFF",
        -- Features
        feat_auto_tree = "Auto Hit Tree (small)",
        feat_steal_egg_monster = "Steal Egg (MonsterParasiteVisual)",
        feat_loot_treadmill = "Loot AdminTreadmill",
        feat_steal_egg_fx = "Steal Egg with FX",
        feat_esp_egg = "ESP Eggs (merged)",
        feat_esp_player = "ESP Players",
        feat_auto_steal_egg = "Auto Steal Egg (AreaEggSlotsClient)",
        feat_speed = "Speed Hack (max 2000)",
        feat_anti_egg_drop = "Anti Egg Drop (auto E)",
        feat_fast_pickup = "Fast Pickup (one click)",
        feat_high_jump = "High Jump (adjustable)",
        feat_infinite_jump = "Infinite Jump",
        feat_zigzag = "Zigzag when stealing",
        feat_fast_attack = "Fast Attack",
        feat_no_knockback = "No Knockback",
        feat_server_hop = "Server Hop",
        feat_zone_select = "Select Egg Zone",
        -- Zone
        zone_label = "Target Zone:",
        zone_refresh = "Refresh Zones",
        -- Other
        speed_label = "Speed:",
        jump_label = "Jump Power:",
        server_label = "Server:",
        btn_join = "Join",
        lang_th = "ไทย",
        lang_en = "English",
        status_running = "Running",
        status_stopped = "Stopped",
        no_target = "No target found",
        found_target = "Target found",
        stealing = "Stealing...",
        returning = "Returning...",
    }
}

local Lang = Translations[Language]

-- ==================== ระบบหลัก ====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

-- ==================== ตัวแปรสถานะ ====================
local Settings = {
    -- อีเว้น
    AutoTree = false,
    StealMonsterEgg = false,
    LootTreadmill = false,
    StealFXEgg = false,
    -- ESP
    ESPEggs = false,
    ESPPlayers = false,
    -- ขโมยไข่
    AutoStealEgg = false,
    AntiEggDrop = false,
    FastPickup = false,
    Zigzag = false,
    ZoneSelect = "",
    -- การเคลื่อนไหว
    SpeedEnabled = false,
    SpeedValue = 100,
    HighJumpEnabled = false,
    JumpPower = 100,
    InfiniteJump = false,
    -- ต่อสู้
    FastAttack = false,
    NoKnockback = false,
    -- อื่นๆ
    ServerHop = false,
    SelectedServer = "",
}

local Connections = {}
local ESPObjects = {}
local ZoneList = {}
local IsStealing = false
local BasePosition = nil
local LastHitTime = 0

-- ==================== ฟังก์ชัน UI ====================
local function CreateUI()
    -- สร้าง ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = ScriptName
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 420, 0, 580)
    MainFrame.Position = UDim2.new(0.5, -210, 0.5, -290)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- UI Corner
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    -- UI Stroke
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(0, 150, 255)
    UIStroke.Thickness = 2
    UIStroke.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = TitleBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = ScriptName
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBlack
    TitleLabel.TextSize = 22
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- ปุ่มปิด
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -40, 0, 10)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 18
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 5)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- ปุ่มเปลี่ยนภาษา
    local LangButton = Instance.new("TextButton")
    LangButton.Size = UDim2.new(0, 50, 0, 30)
    LangButton.Position = UDim2.new(1, -100, 0, 10)
    LangButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    LangButton.Text = "TH/EN"
    LangButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    LangButton.Font = Enum.Font.GothamBold
    LangButton.TextSize = 12
    LangButton.BorderSizePixel = 0
    LangButton.Parent = TitleBar
    
    local LangCorner = Instance.new("UICorner")
    LangCorner.CornerRadius = UDim.new(0, 5)
    LangCorner.Parent = LangButton
    
    LangButton.MouseButton1Click:Connect(function()
        Language = Language == "TH" and "EN" or "TH"
        Lang = Translations[Language]
        TitleLabel.Text = ScriptName
        -- อัปเดตข้อความทั้งหมด
        RefreshUILanguage(ScreenGui)
    end)
    
    -- Scroll Frame
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -10, 1, -60)
    ScrollFrame.Position = UDim2.new(0, 5, 0, 55)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 5
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1600)
    ScrollFrame.Parent = MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ScrollFrame
    
    -- เก็บองค์ประกอบสำหรับอัปเดตภาษา
    local UIElements = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        TitleBar = TitleBar,
        TitleLabel = TitleLabel,
        CloseButton = CloseButton,
        LangButton = LangButton,
        ScrollFrame = ScrollFrame,
        UIListLayout = UIListLayout,
    }
    
    return UIElements
end

-- ฟังก์ชันสร้างหมวดหมู่
local function CreateCategory(parent, title, order)
    local CategoryFrame = Instance.new("Frame")
    CategoryFrame.Size = UDim2.new(1, -10, 0, 40)
    CategoryFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    CategoryFrame.BorderSizePixel = 0
    CategoryFrame.LayoutOrder = order
    CategoryFrame.Parent = parent
    
    local CatCorner = Instance.new("UICorner")
    CatCorner.CornerRadius = UDim.new(0, 5)
    CatCorner.Parent = CategoryFrame
    
    local CatLabel = Instance.new("TextLabel")
    CatLabel.Size = UDim2.new(1, -10, 1, 0)
    CatLabel.Position = UDim2.new(0, 10, 0, 0)
    CatLabel.BackgroundTransparency = 1
    CatLabel.Text = title
    CatLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
    CatLabel.Font = Enum.Font.GothamBlack
    CatLabel.TextSize = 16
    CatLabel.TextXAlignment = Enum.TextXAlignment.Left
    CatLabel.Parent = CategoryFrame
    
    return CategoryFrame
end

-- ฟังก์ชันสร้างปุ่มสลับ
local function CreateToggle(parent, title, callback, order)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.LayoutOrder = order
    ToggleFrame.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 5)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = title
    ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 14
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 60, 0, 25)
    ToggleButton.Position = UDim2.new(1, -70, 0.5, -12)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    ToggleButton.Text = "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 12
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
            ToggleButton.Text = "ON"
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            ToggleButton.TextColor3 = Color3.fromRGB(150, 150, 150)
            ToggleButton.Text = "OFF"
        end
        callback(isOn)
    end)
    
    return ToggleFrame, ToggleLabel, ToggleButton
end

-- ฟังก์ชันสร้าง Slider
local function CreateSlider(parent, title, min, max, default, callback, order)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -10, 0, 50)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.LayoutOrder = order
    SliderFrame.Parent = parent
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 5)
    SliderCorner.Parent = SliderFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, -10, 0, 20)
    SliderLabel.Position = UDim2.new(0, 10, 0, 5)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = title .. ": " .. default
    SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextSize = 13
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -20, 0, 10)
    SliderBar.Position = UDim2.new(0, 10, 0, 32)
    SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderFrame
    
    local SliderBarCorner = Instance.new("UICorner")
    SliderBarCorner.CornerRadius = UDim.new(0, 5)
    SliderBarCorner.Parent = SliderBar
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0, 5)
    SliderFillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 20, 0, 20)
    SliderButton.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderButton.Text = ""
    SliderButton.BorderSizePixel = 0
    SliderButton.Parent = SliderBar
    
    local SliderButtonCorner = Instance.new("UICorner")
    SliderButtonCorner.CornerRadius = UDim.new(0, 10)
    SliderButtonCorner.Parent = SliderButton
    
    -- Slider logic
    local dragging = false
    
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local barPos = SliderBar.AbsolutePosition
            local barSize = SliderBar.AbsoluteSize
            local relativeX = math.clamp(mousePos.X - barPos.X, 0, barSize.X)
            local value = min + (relativeX / barSize.X) * (max - min)
            value = math.floor(value)
            
            SliderFill.Size = UDim2.new(relativeX / barSize.X, 0, 1, 0)
            SliderButton.Position = UDim2.new(relativeX / barSize.X, -10, 0.5, -10)
            SliderLabel.Text = title .. ": " .. value
            callback(value)
        end
    end)
    
    return SliderFrame, SliderLabel
end

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

-- ฟังก์ชันหาไข่ใน AreaEggSlotsClient
local function FindEggsInArea()
    local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
    if not areaEggs then
        return {}
    end
    return areaEggs:GetChildren()
end

-- ฟังก์ชันหาไข่ที่มีไฟล์ MonsterParasiteVisual
local function FindMonsterEggs()
    local results = {}
    for _, egg in pairs(Workspace:GetDescendants()) do
        if egg:IsA("Model") and HasChildNamed(egg, "MonsterParasiteVisual") then
            table.insert(results, egg)
        end
    end
    return results
end

-- ฟังก์ชันหาไข่ที่มีไฟล์ FX
local function FindFXEggs()
    local results = {}
    for _, egg in pairs(Workspace:GetDescendants()) do
        if egg:IsA("Model") and HasChildNamed(egg, "FX") then
            table.insert(results, egg)
        end
    end
    return results
end

-- ฟังก์ชันหา AdminTreadmill
local function FindTreadmill()
    return FindInWorkspace("AdminTreadmill")
end

-- ฟังก์ชันหาไข่ซ้ำ (ESP)
local function FindDuplicateEggs()
    local eggNames = {}
    local duplicates = {}
    local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
    if areaEggs then
        for _, egg in pairs(areaEggs:GetChildren()) do
            if egg:IsA("Model") then
                local baseName = egg.Name:gsub("%d+$", "")
                if eggNames[baseName] then
                    table.insert(duplicates, egg)
                else
                    eggNames[baseName] = true
                end
            end
        end
    end
    return duplicates
end

-- ฟังก์ชันย้ายไปยังตำแหน่ง
local function MoveTo(position, speed)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character.HumanoidRootPart
    
    if Settings.SpeedEnabled then
        humanoid.WalkSpeed = Settings.SpeedValue
    else
        humanoid.WalkSpeed = 16
    end
    
    -- ใช้ CFrame ในการเคลื่อนที่
    local distance = (position - rootPart.Position).Magnitude
    local direction = (position - rootPart.Position).Unit
    
    -- เดินไปยังเป้าหมาย
    humanoid:MoveTo(position)
    
    -- ถ้าใช้ Zigzag จะเคลื่อนที่แบบซิกแซก
    if Settings.Zigzag and distance > 10 then
        local zigzagOffset = Vector3.new(math.sin(tick() * 5) * 5, 0, math.cos(tick() * 5) * 5)
        humanoid:MoveTo(position + zigzagOffset)
    end
end

-- ฟังก์ชันกดปุ่ม E
local function PressE()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
    wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
end

-- ฟังก์ชันตีต้นไม้อัตโนมัติ
local function AutoTreeFunction()
    spawn(function()
        while Settings.AutoTree do
            wait(0.5)
            
            -- หาต้นไม้ small
            local trees = {}
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name == "small" or (obj:IsA("Model") and obj.Name:lower():find("small")) then
                    table.insert(trees, obj)
                end
            end
            
            if #trees > 0 then
                -- เลือกต้นไม้ที่ใกล้ที่สุด
                local nearestTree = nil
                local nearestDistance = math.huge
                local character = LocalPlayer.Character
                
                if character and character:FindFirstChild("HumanoidRootPart") then
                    for _, tree in pairs(trees) do
                        if tree:IsA("Model") and tree:FindFirstChild("HumanoidRootPart") then
                            local distance = (tree.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                            if distance < nearestDistance then
                                nearestDistance = distance
                                nearestTree = tree
                            end
                        elseif tree:IsA("BasePart") then
                            local distance = (tree.Position - character.HumanoidRootPart.Position).Magnitude
                            if distance < nearestDistance then
                                nearestDistance = distance
                                nearestTree = tree
                            end
                        end
                    end
                end
                
                if nearestTree then
                    local targetPosition
                    if nearestTree:IsA("Model") and nearestTree:FindFirstChild("HumanoidRootPart") then
                        targetPosition = nearestTree.HumanoidRootPart.Position
                    else
                        targetPosition = nearestTree.Position
                    end
                    
                    -- บินไปที่ต้นไม้
                    MoveTo(targetPosition, 50)
                    
                    -- ตีต้นไม้
                    local character = LocalPlayer.Character
                    if character and character:FindFirstChild("Humanoid") then
                        local humanoid = character.Humanoid
                        
                        -- หาเครื่องมือ
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                            wait(0.2)
                            tool:Deactivate()
                        else
                            -- ตีด้วยมือ
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
                            wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
                        end
                    end
                end
            end
        end
    end)
end

-- ฟังก์ชันขโมยไข่
local function StealEgg(egg)
    if not egg then
        return false
    end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    -- บันทึกตำแหน่งฐาน
    if not BasePosition then
        BasePosition = character.HumanoidRootPart.Position
    end
    
    -- หาตำแหน่งไข่
    local eggPosition
    if egg:IsA("Model") and egg:FindFirstChild("HumanoidRootPart") then
        eggPosition = egg.HumanoidRootPart.Position
    elseif egg:IsA("BasePart") then
        eggPosition = egg.Position
    else
        return false
    end
    
    IsStealing = true
    
    -- บินไปที่ไข่
    MoveTo(eggPosition, Settings.SpeedEnabled and Settings.SpeedValue or 50)
    
    -- รอจนกว่าจะถึง
    local timeout = 0
    while (character.HumanoidRootPart.Position - eggPosition).Magnitude > 10 and timeout < 5 do
        wait(0.1)
        timeout = timeout + 0.1
    end
    
    -- กด E เพื่อขโมย
    PressE()
    
    -- ถ้าเปิดกันไข่หลุด จะกด E ซ้ำ
    if Settings.AntiEggDrop then
        spawn(function()
            local checkTime = 0
            while IsStealing and checkTime < 3 do
                wait(0.2)
                PressE()
                checkTime = checkTime + 0.2
            end
        end)
    end
    
    -- ถ้าเก็บไข่เร็ว จะไม่ต้องกดค้าง
    if Settings.FastPickup then
        wait(0.3)
        PressE()
    end
    
    -- รอสักครู่
    wait(1)
    
    -- กลับฐาน
    if BasePosition then
        MoveTo(BasePosition, Settings.SpeedEnabled and Settings.SpeedValue or 50)
        
        -- รอจนกว่าจะถึงฐาน
        timeout = 0
        while (character.HumanoidRootPart.Position - BasePosition).Magnitude > 10 and timeout < 5 do
            wait(0.1)
            timeout = timeout + 0.1
        end
    end
    
    IsStealing = false
    return true
end

-- ฟังก์ชันขโมยไข่อัตโนมัติ
local function AutoStealFunction()
    spawn(function()
        while Settings.AutoStealEgg do
            wait(1)
            
            if not IsStealing then
                -- หาไข่ใน AreaEggSlotsClient
                local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
                if areaEggs then
                    local eggs = areaEggs:GetChildren()
                    
                    -- กรองตามโซน
                    if Settings.ZoneSelect and Settings.ZoneSelect ~= "" then
                        local filteredEggs = {}
                        for _, egg in pairs(eggs) do
                            -- ตรวจสอบว่าไข่อยู่ในโซนที่เลือก
                            local zoneFolder = Workspace:FindFirstChild("__OBJECTS")
                            if zoneFolder then
                                local areas = zoneFolder:FindFirstChild("Areas")
                                if areas then
                                    local targetZone = areas:FindFirstChild(Settings.ZoneSelect)
                                    if targetZone then
                                        -- ตรวจสอบว่าไข่อยู่ในโซน
                                        local eggPos = egg:IsA("Model") and egg:FindFirstChild("HumanoidRootPart") and egg.HumanoidRootPart.Position or nil
                                        if eggPos and targetZone:IsA("Model") and targetZone:FindFirstChild("HumanoidRootPart") then
                                            local zonePos = targetZone.HumanoidRootPart.Position
                                            local distance = (eggPos - zonePos).Magnitude
                                            if distance < 200 then
                                                table.insert(filteredEggs, egg)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        eggs = filteredEggs
                    end
                    
                    -- เลือกไข่ที่ใกล้ที่สุด
                    local nearestEgg = nil
                    local nearestDistance = math.huge
                    local character = LocalPlayer.Character
                    
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        for _, egg in pairs(eggs) do
                            if egg:IsA("Model") then
                                local eggPos = egg:FindFirstChild("HumanoidRootPart") and egg.HumanoidRootPart.Position or nil
                                if eggPos then
                                    local distance = (eggPos - character.HumanoidRootPart.Position).Magnitude
                                    if distance < nearestDistance then
                                        nearestDistance = distance
                                        nearestEgg = egg
                                    end
                                end
                            end
                        end
                    end
                    
                    if nearestEgg then
                        StealEgg(nearestEgg)
                    end
                end
            end
        end
    end)
end

-- ฟังก์ชันสร้าง ESP
local function CreateESP(target, color, name)
    if not target then
        return
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_" .. name
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = target
    
    table.insert(ESPObjects, highlight)
    
    -- สร้าง BillboardGui แสดงชื่อ
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard_" .. name
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.AlwaysOnTop = true
    billboard.Parent = target
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 14
    textLabel.Parent = billboard
    
    return highlight, billboard
end

-- ฟังก์ชันล้าง ESP
local function ClearESP()
    for _, obj in pairs(ESPObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    ESPObjects = {}
end

-- ฟังก์ชัน ESP ไข่
local function ESPEggsFunction()
    spawn(function()
        while Settings.ESPEggs do
            wait(2)
            ClearESP()
            
            -- หาไข่ใน AreaEggSlotsClient
            local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
            if areaEggs then
                local eggNames = {}
                for _, egg in pairs(areaEggs:GetChildren()) do
                    if egg:IsA("Model") then
                        local baseName = egg.Name:gsub("%d+$", "")
                        
                        -- ถ้าเป็นไข่ซ้ำ ให้แสดงชื่อเดียว
                        if eggNames[baseName] then
                            CreateESP(egg, Color3.fromRGB(255, 165, 0), baseName .. " (ซ้ำ)")
                        else
                            eggNames[baseName] = true
                            CreateESP(egg, Color3.fromRGB(255, 255, 0), baseName)
                        end
                    end
                end
            end
        end
        ClearESP()
    end)
end

-- ฟังก์ชัน ESP ผู้เล่น
local function
