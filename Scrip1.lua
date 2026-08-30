--[[
    THE CRAFT HUB - สคริปต์อเนกประสงค์
    UI แนวนอนสวยงาม
    มีปุ่มเปิด/ปิด Script และ UI
]]

-- ==================== Services ====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- ==================== ระบบภาษา ====================
local Language = "TH"
local Translations = {
    TH = {
        title = "THE CRAFT HUB",
        script_on = "สคริปต์: เปิด",
        script_off = "สคริปต์: ปิด",
        ui_on = "UI: เปิด",
        ui_off = "UI: ปิด",
        toggle_on = "ON",
        toggle_off = "OFF",
        category_event = "⚡ อีเว้น",
        category_steal = "🥚 ขโมยไข่",
        category_esp = "👁️ ESP",
        category_movement = "🏃 เคลื่อนไหว",
        category_combat = "⚔️ ต่อสู้",
        category_server = "🌐 เซิฟเวอร์",
        feat_auto_tree = "ตีต้นไม้ Auto",
        feat_steal_monster = "ขโมยไข่ Monster",
        feat_loot_treadmill = "เสกลู่วิ่ง",
        feat_steal_fx = "ขโมยไข่ FX",
        feat_auto_steal = "ขโมยไข่อัตโนมัติ",
        feat_anti_drop = "กันไข่หลุด",
        feat_fast_pickup = "เก็บไข่เร็ว",
        feat_zigzag = "ซิกแซก",
        feat_esp_egg = "ESP ไข่",
        feat_esp_player = "ESP ผู้เล่น",
        feat_speed = "ปรับความเร็ว",
        feat_high_jump = "กระโดดสูง",
        feat_infinite_jump = "กระโดดไม่จำกัด",
        feat_fast_attack = "ตีไว",
        feat_no_knockback = "ไม่กระเด็น",
        speed_label = "ความเร็ว",
        jump_label = "พลังกระโดด",
        btn_server_hop = "ย้ายเซิฟ",
        btn_clear_esp = "ล้าง ESP",
        btn_refresh_zone = "รีเฟรชโซน",
        zone_label = "โซน: ",
        no_zones = "ไม่พบโซน",
        zones_found = "พบโซน: ",
        esp_cleared = "ล้าง ESP แล้ว",
        hopping = "กำลังย้ายเซิฟ...",
    },
    EN = {
        title = "THE CRAFT HUB",
        script_on = "Script: ON",
        script_off = "Script: OFF",
        ui_on = "UI: ON",
        ui_off = "UI: OFF",
        toggle_on = "ON",
        toggle_off = "OFF",
        category_event = "⚡ Event",
        category_steal = "🥚 Egg Steal",
        category_esp = "👁️ ESP",
        category_movement = "🏃 Movement",
        category_combat = "⚔️ Combat",
        category_server = "🌐 Server",
        feat_auto_tree = "Auto Tree",
        feat_steal_monster = "Steal Monster Egg",
        feat_loot_treadmill = "Loot Treadmill",
        feat_steal_fx = "Steal FX Egg",
        feat_auto_steal = "Auto Steal",
        feat_anti_drop = "Anti Drop",
        feat_fast_pickup = "Fast Pickup",
        feat_zigzag = "Zigzag",
        feat_esp_egg = "ESP Eggs",
        feat_esp_player = "ESP Players",
        feat_speed = "Speed Hack",
        feat_high_jump = "High Jump",
        feat_infinite_jump = "Infinite Jump",
        feat_fast_attack = "Fast Attack",
        feat_no_knockback = "No Knockback",
        speed_label = "Speed",
        jump_label = "Jump Power",
        btn_server_hop = "Server Hop",
        btn_clear_esp = "Clear ESP",
        btn_refresh_zone = "Refresh Zones",
        zone_label = "Zone: ",
        no_zones = "No zones",
        zones_found = "Zones: ",
        esp_cleared = "ESP Cleared",
        hopping = "Hopping...",
    }
}
local Lang = Translations[Language]

-- ==================== ตัวแปร ====================
local Settings = {
    ScriptEnabled = true,
    UIEnabled = true,
    AutoTree = false,
    StealMonster = false,
    LootTreadmill = false,
    StealFX = false,
    AutoSteal = false,
    AntiDrop = false,
    FastPickup = false,
    Zigzag = false,
    ESPEgg = false,
    ESPPlayer = false,
    SpeedEnabled = false,
    SpeedValue = 100,
    HighJump = false,
    JumpPower = 100,
    InfiniteJump = false,
    FastAttack = false,
    NoKnockback = false,
    SelectedZone = "",
}

local ESPObjects = {}
local ZoneList = {}
local IsStealing = false
local BasePosition = nil
local Connections = {}
local LoopConnections = {}

-- ==================== ฟังก์ชันช่วยเหลือ ====================
local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local char = GetCharacter()
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local function GetRootPart()
    local char = GetCharacter()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function GetObjectPosition(obj)
    if not obj then return nil end
    if obj:IsA("Model") then
        if obj:FindFirstChild("HumanoidRootPart") then
            return obj.HumanoidRootPart.Position
        elseif obj:FindFirstChild("PrimaryPart") then
            return obj.PrimaryPart.Position
        else
            local part = obj:FindFirstChildWhichIsA("BasePart")
            if part then return part.Position end
        end
    elseif obj:IsA("BasePart") then
        return obj.Position
    end
    return nil
end

local function FindInWorkspace(name)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == name then
            return obj
        end
    end
    return nil
end

local function HasChild(parent, childName)
    if not parent then return false end
    for _, child in pairs(parent:GetChildren()) do
        if child.Name == childName then
            return true
        end
    end
    return false
end

local function PressKey(key, holdTime)
    holdTime = holdTime or 0.05
    VirtualInputManager:SendKeyEvent(true, key, false, nil)
    task.wait(holdTime)
    VirtualInputManager:SendKeyEvent(false, key, false, nil)
end

local function MoveToPosition(position)
    local humanoid = GetHumanoid()
    if not humanoid then return end
    humanoid:MoveTo(position)
end

local function TweenToPosition(position, speed)
    local rootPart = GetRootPart()
    if not rootPart then return end
    
    local tween = TweenService:Create(rootPart, 
        TweenInfo.new(1, Enum.EasingStyle.Linear), 
        {CFrame = CFrame.new(position)}
    )
    tween:Play()
    tween.Completed:Wait()
end

-- ==================== ฟังก์ชันหลัก ====================

-- ตีต้นไม้อัตโนมัติ
local function AutoTreeLoop()
    while Settings.AutoTree and Settings.ScriptEnabled do
        task.wait(0.5)
        local char = GetCharacter()
        local rootPart = GetRootPart()
        if char and rootPart then
            local trees = {}
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name == "small" or obj.Name:lower():find("small") then
                    table.insert(trees, obj)
                end
            end
            
            local nearest = nil
            local minDist = math.huge
            for _, tree in pairs(trees) do
                local pos = GetObjectPosition(tree)
                if pos then
                    local dist = (pos - rootPart.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = tree
                    end
                end
            end
            
            if nearest then
                local pos = GetObjectPosition(nearest)
                if pos and minDist > 5 then
                    MoveToPosition(pos)
                    task.wait(0.3)
                elseif pos then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                        task.wait(0.1)
                        tool:Deactivate()
                    else
                        PressKey(Enum.KeyCode.E, 0.1)
                    end
                end
            end
        end
    end
end

-- ขโมยไข่ Monster
local function StealMonsterLoop()
    while Settings.StealMonster and Settings.ScriptEnabled do
        task.wait(1)
        local rootPart = GetRootPart()
        if rootPart then
            local found = false
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and HasChild(obj, "MonsterParasiteVisual") then
                    local pos = GetObjectPosition(obj)
                    if pos then
                        MoveToPosition(pos)
                        task.wait(0.5)
                        PressKey(Enum.KeyCode.E, 0.1)
                        if Settings.AntiDrop then
                            task.wait(0.3)
                            PressKey(Enum.KeyCode.E, 0.1)
                        end
                        found = true
                        break
                    end
                end
            end
        end
    end
end

-- เสกลู่วิ่ง
local function LootTreadmillLoop()
    while Settings.LootTreadmill and Settings.ScriptEnabled do
        task.wait(0.5)
        local treadmill = FindInWorkspace("AdminTreadmill")
        if treadmill then
            local pos = GetObjectPosition(treadmill)
            if pos then
                MoveToPosition(pos)
                task.wait(0.3)
                PressKey(Enum.KeyCode.E, 0.1)
            end
        end
    end
end

-- ขโมยไข่ FX
local function StealFXLoop()
    while Settings.StealFX and Settings.ScriptEnabled do
        task.wait(1)
        local rootPart = GetRootPart()
        if rootPart then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and HasChild(obj, "FX") then
                    local pos = GetObjectPosition(obj)
                    if pos then
                        MoveToPosition(pos)
                        task.wait(0.5)
                        PressKey(Enum.KeyCode.E, 0.1)
                        if Settings.AntiDrop then
                            task.wait(0.3)
                            PressKey(Enum.KeyCode.E, 0.1)
                        end
                        break
                    end
                end
            end
        end
    end
end

-- ขโมยไข่อัตโนมัติ
local function AutoStealLoop()
    while Settings.AutoSteal and Settings.ScriptEnabled do
        task.wait(1)
        if not IsStealing then
            local rootPart = GetRootPart()
            if rootPart then
                if not BasePosition then
                    BasePosition = rootPart.Position
                end
                
                local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
                if areaEggs then
                    local eggs = areaEggs:GetChildren()
                    local nearest = nil
                    local minDist = math.huge
                    
                    for _, egg in pairs(eggs) do
                        if egg:IsA("Model") then
                            local pos = GetObjectPosition(egg)
                            if pos then
                                local dist = (pos - rootPart.Position).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    nearest = egg
                                end
                            end
                        end
                    end
                    
                    if nearest then
                        IsStealing = true
                        local eggPos = GetObjectPosition(nearest)
                        if eggPos then
                            MoveToPosition(eggPos)
                            task.wait(0.5)
                            PressKey(Enum.KeyCode.E, 0.1)
                            
                            if Settings.AntiDrop then
                                task.wait(0.2)
                                PressKey(Enum.KeyCode.E, 0.1)
                            end
                            
                            if Settings.FastPickup then
                                task.wait(0.15)
                                PressKey(Enum.KeyCode.E, 0.1)
                            end
                            
                            task.wait(1)
                            
                            -- กลับฐาน
                            if BasePosition then
                                MoveToPosition(BasePosition)
                                task.wait(0.5)
                            end
                        end
                        IsStealing = false
                    end
                end
            end
        end
    end
end

-- ESP ไข่
local function ESPEggLoop()
    while Settings.ESPEgg and Settings.ScriptEnabled do
        task.wait(2)
        ClearESP()
        
        local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
        if areaEggs then
            local seenNames = {}
            for _, egg in pairs(areaEggs:GetChildren()) do
                if egg:IsA("Model") then
                    local baseName = egg.Name:gsub("%d+$", "")
                    local color = seenNames[baseName] and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 0)
                    seenNames[baseName] = true
                    CreateESP(egg, color, baseName)
                end
            end
        end
    end
end

-- ESP ผู้เล่น
local function ESPPlayerLoop()
    while Settings.ESPPlayer and Settings.ScriptEnabled do
        task.wait(2)
        ClearESP()
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                if char then
                    CreateESP(char, Color3.fromRGB(0, 200, 255), player.Name)
                end
            end
        end
    end
end

-- ปรับความเร็ว
local function ApplySpeed(value)
    local humanoid = GetHumanoid()
    if humanoid then
        humanoid.WalkSpeed = value
    end
end

-- กระโดดสูง
local function ApplyJump(value)
    local humanoid = GetHumanoid()
    if humanoid then
        humanoid.JumpPower = value
    end
end

-- กระโดดไม่จำกัด
local function EnableInfiniteJump()
    local char = GetCharacter()
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
            humanoid.JumpPower = Settings.JumpPower
        end
    end
end

-- ตีไว
local function EnableFastAttack()
    spawn(function()
        while Settings.FastAttack and Settings.ScriptEnabled do
            task.wait(0.05)
            local char = GetCharacter()
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and tool:IsA("Tool") then
                    tool:Activate()
                    task.wait(0.02)
                    tool:Deactivate()
                end
            end
        end
    end)
end

-- ไม่กระเด็น
local function EnableNoKnockback()
    spawn(function()
        while Settings.NoKnockback and Settings.ScriptEnabled do
            task.wait(0.1)
            local char = GetCharacter()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Massless = true
                    end
                end
            end
        end
    end)
end

-- ย้ายเซิฟ
local function HopServer()
    local servers = {}
    pcall(function()
        local Http = game:GetService("HttpService")
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local response = Http:JSONDecode(game:HttpGet(url))
        for _, server in pairs(response.data) do
            if server.playing < server.maxPlayers then
                table.insert(servers, server.id)
            end
        end
    end)
    
    if #servers > 0 then
        local randomServer = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, LocalPlayer)
    else
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end

-- รีเฟรชโซน
local function RefreshZones()
    ZoneList = {}
    local objectsFolder = Workspace:FindFirstChild("__OBJECTS")
    if objectsFolder then
        local areasFolder = objectsFolder:FindFirstChild("Areas")
        if areasFolder then
            for _, area in pairs(areasFolder:GetChildren()) do
                table.insert(ZoneList, area.Name)
            end
        end
    end
    
    if #ZoneList > 0 then
        print(Lang.zones_found .. table.concat(ZoneList, ", "))
    else
        print(Lang.no_zones)
    end
end

-- สร้าง ESP
function CreateESP(target, color, name)
    if not target then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_" .. name
    highlight.FillColor = color
    highlight.FillTransparency = 0.4
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.2
    highlight.Parent = target
    table.insert(ESPObjects, highlight)
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_BB_" .. name
    billboard.Size = UDim2.new(0, 100, 0, 25)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = target
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = billboard
end

-- ล้าง ESP
function ClearESP()
    for _, obj in pairs(ESPObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    ESPObjects = {}
end

-- ==================== สร้าง UI แนวนอน ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "THE_CRAFT_HUB_UI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ปุ่มหลักเปิด/ปิด UI
local MainToggleButton = Instance.new("TextButton")
MainToggleButton.Size = UDim2.new(0, 50, 0, 50)
MainToggleButton.Position = UDim2.new(0, 10, 0.5, -25)
MainToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
MainToggleButton.Text = "🎮"
MainToggleButton.TextSize = 25
MainToggleButton.BorderSizePixel = 0
MainToggleButton.Parent = ScreenGui

local MainToggleCorner = Instance.new("UICorner")
MainToggleCorner.CornerRadius = UDim.new(0, 10)
MainToggleCorner.Parent = MainToggleButton

-- Main Panel (แนวนอน)
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 800, 0, 300)
MainPanel.Position = UDim2.new(0.5, -400, 0.5, -150)
MainPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainPanel.BorderSizePixel = 0
MainPanel.Visible = true
MainPanel.Parent = ScreenGui

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 12)
PanelCorner.Parent = MainPanel

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(0, 150, 255)
PanelStroke.Thickness = 2
PanelStroke.Parent = MainPanel

-- Title Bar แนวนอน
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainPanel

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleBottom = Instance.new("Frame")
TitleBottom.Size = UDim2.new(1, 0, 0, 15)
TitleBottom.Position = UDim2.new(0, 0, 0, 30)
TitleBottom.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
TitleBottom.BorderSizePixel = 0
TitleBottom.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = Lang.title
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- ปุ่ม Script On/Off
local ScriptToggle = Instance.new("TextButton")
ScriptToggle.Size = UDim2.new(0, 80, 0, 30)
ScriptToggle.Position = UDim2.new(1, -200, 0, 7)
ScriptToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
ScriptToggle.Text = Lang.script_on
ScriptToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ScriptToggle.Font = Enum.Font.GothamBold
ScriptToggle.TextSize = 11
ScriptToggle.BorderSizePixel = 0
ScriptToggle.Parent = TitleBar

local ScriptToggleCorner = Instance.new("UICorner")
ScriptToggleCorner.CornerRadius = UDim.new(0, 15)
ScriptToggleCorner.Parent = ScriptToggle

-- ปุ่ม UI On/Off
local UIToggle = Instance.new("TextButton")
UIToggle.Size = UDim2.new(0, 70, 0, 30)
UIToggle.Position = UDim2.new(1, -110, 0, 7)
UIToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
UIToggle.Text = Lang.ui_on
UIToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
UIToggle.Font = Enum.Font.GothamBold
UIToggle.TextSize = 11
UIToggle.BorderSizePixel = 0
UIToggle.Parent = TitleBar

local UIToggleCorner = Instance.new("UICorner")
UIToggleCorner.CornerRadius = UDim.new(0, 15)
UIToggleCorner.Parent = UIToggle

-- ปุ่มปิด Panel
local ClosePanel = Instance.new("TextButton")
ClosePanel.Size = UDim2.new(0, 30, 0, 30)
ClosePanel.Position = UDim2.new(1, -35, 0, 7)
ClosePanel.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ClosePanel.Text = "✕"
ClosePanel.TextColor3 = Color3.fromRGB(255, 255, 255)
ClosePanel.Font = Enum.Font.GothamBold
ClosePanel.TextSize = 14
ClosePanel.BorderSizePixel = 0
ClosePanel.Parent = TitleBar

local ClosePanelCorner = Instance.new("UICorner")
ClosePanelCorner.CornerRadius = UDim.new(0, 5)
ClosePanelCorner.Parent = ClosePanel

-- Tab Bar แนวนอน
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 150, 1, -45)
TabBar.Position = UDim2.new(0, 0, 0, 45)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainPanel

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 2)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = TabBar

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -150, 1, -45)
ContentArea.Position = UDim2.new(0, 150, 0, 45)
ContentArea.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainPanel

-- สร้าง Tabs
local Tabs = {}
local CurrentTab = nil

local function CreateTab(name, icon, order)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 40)
    TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    TabButton.Text = icon .. " " .. name
    TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 12
    TabButton.BorderSizePixel = 0
    TabButton.LayoutOrder = order
    TabButton.Parent = TabBar
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 4)
    TabCorner.Parent = TabButton
    
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Size = UDim2.new(1, -10, 1, -10)
    TabContent.Position = UDim2.new(0, 5, 0, 5)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 4
    TabContent.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 500)
    TabContent.Visible = false
    TabContent.Parent = ContentArea
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 4)
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = TabContent
    
    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Content.Visible = false
            tab.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            tab.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        TabContent.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CurrentTab = TabContent
    end)
    
    table.insert(Tabs, {Button = TabButton, Content = TabContent})
    
    return TabContent
end

-- ฟังก์ชันสร้าง Toggle ใน Tab
local function CreateToggle(parent, title, setting, callback, order)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 38)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.LayoutOrder = order
    ToggleFrame.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 4)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 8, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = title
    ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 11
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 22)
    ToggleBtn.Position = UDim2.new(1, -58, 0.5, -11)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    ToggleBtn.Text = Lang.toggle_off
    ToggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 10
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ToggleFrame
    
    local ToggleBtnCorner = Instance.new("UICorner")
    ToggleBtnCorner.CornerRadius = UDim.new(0, 11)
    ToggleBtnCorner.Parent = ToggleBtn
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        if Settings[setting] then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleBtn.Text = Lang.toggle_on
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            ToggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
            ToggleBtn.Text = Lang.toggle_off
        end
        if callback then
            callback(Settings[setting])
        end
    end)
    
    return ToggleFrame
end

-- ฟังก์ชันสร้าง Slider
local function CreateSlider(parent, title, min, max, default, callback, order)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.LayoutOrder = order
    SliderFrame.Parent = parent
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 4)
    SliderCorner.Parent = SliderFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, -10, 0, 18)
    SliderLabel.Position = UDim2.new(0, 5, 0, 3)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = title .. ": " .. default
    SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextSize = 11
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -40, 0, 8)
    SliderBar.Position = UDim2.new(0, 20, 0, 28)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
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
    
    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(0, 16, 0, 16)
    SliderBtn.Position = UDim2.new(fillPercent, -8, 0.5, -8)
    SliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderBtn.Text = ""
    SliderBtn.BorderSizePixel = 0
    SliderBtn.AutoButtonColor = false
    SliderBtn.Parent = SliderBar
    
    local SliderBtnCorner = Instance.new("UICorner")
    SliderBtnCorner.CornerRadius = UDim.new(0, 8)
    SliderBtnCorner.Parent = SliderBtn
    
    local dragging = false
    
    local function UpdateSlider()
        local mousePos = UserInputService:GetMouseLocation()
        local barPos = SliderBar.AbsolutePosition
        local barSize = SliderBar.AbsoluteSize
        local relativeX = math.clamp(mousePos.X - barPos.X, 0, barSize.X)
        local value = math.floor(min + (relativeX / barSize.X) * (max - min))
        
        SliderFill.Size = UDim2.new(relativeX / barSize.X, 0, 1, 0)
        SliderBtn.Position = UDim2.new(relativeX / barSize.X, -8, 0.5, -8)
        SliderLabel.Text = title .. ": " .. value
        callback(value)
    end
    
    SliderBtn.MouseButton1Down:Connect(function()
        dragging = true
        UpdateSlider()
    end)
    
    SliderBar.MouseButton1Down:Connect(function()
