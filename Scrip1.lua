--[[
    THE CRAFT HUB - สคริปต์อเนกประสงค์
    UI แนวนอน สวยงาม
    มีปุ่มเปิด/ปิด Script และ UI
    แก้ไขให้ทำงานทันที
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
        ui_show = "แสดง UI",
        ui_hide = "ซ่อน UI",
        toggle_on = "ON",
        toggle_off = "OFF",
        -- หมวดหมู่
        cat_event = "อีเว้น",
        cat_steal = "ขโมยไข่",
        cat_esp = "มองทะลุ",
        cat_move = "เคลื่อนไหว",
        cat_combat = "ต่อสู้",
        cat_server = "เซิฟเวอร์",
        -- ฟีเจอร์
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
        no_zones = "ไม่พบโซน",
        zones_found = "พบโซน: ",
        esp_cleared = "ล้าง ESP แล้ว",
        hopping = "กำลังย้ายเซิฟ...",
    },
    EN = {
        title = "THE CRAFT HUB",
        script_on = "Script: ON",
        script_off = "Script: OFF",
        ui_show = "Show UI",
        ui_hide = "Hide UI",
        toggle_on = "ON",
        toggle_off = "OFF",
        cat_event = "Event",
        cat_steal = "Egg Steal",
        cat_esp = "ESP",
        cat_move = "Movement",
        cat_combat = "Combat",
        cat_server = "Server",
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
}

local ESPObjects = {}
local IsStealing = false
local BasePosition = nil
local RunningLoops = {}

-- ==================== ฟังก์ชันช่วยเหลือ ====================
local function GetChar()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local char = GetChar()
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local function GetRoot()
    local char = GetChar()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function GetObjPos(obj)
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

local function FindObj(name)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == name then
            return obj
        end
    end
    return nil
end

local function HasChild(obj, childName)
    if not obj then return false end
    for _, child in pairs(obj:GetChildren()) do
        if child.Name == childName then
            return true
        end
    end
    return false
end

local function PressE()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
    task.wait(0.08)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
end

local function MoveTo(pos)
    local humanoid = GetHumanoid()
    if humanoid and pos then
        humanoid:MoveTo(pos)
    end
end

-- ==================== ฟังก์ชันหลัก ====================

-- ตีต้นไม้
local function AutoTreeLoop()
    while Settings.AutoTree and Settings.ScriptEnabled do
        task.wait(0.5)
        local root = GetRoot()
        if root then
            local trees = {}
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name == "small" or obj.Name:lower():find("small") then
                    table.insert(trees, obj)
                end
            end
            
            local nearest = nil
            local minDist = math.huge
            for _, tree in pairs(trees) do
                local pos = GetObjPos(tree)
                if pos then
                    local dist = (pos - root.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = tree
                    end
                end
            end
            
            if nearest then
                local pos = GetObjPos(nearest)
                if pos then
                    if minDist > 5 then
                        MoveTo(pos)
                        task.wait(0.3)
                    else
                        local char = GetChar()
                        local tool = char and char:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                            task.wait(0.1)
                            tool:Deactivate()
                        else
                            PressE()
                        end
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
        local root = GetRoot()
        if root then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and HasChild(obj, "MonsterParasiteVisual") then
                    local pos = GetObjPos(obj)
                    if pos then
                        MoveTo(pos)
                        task.wait(0.5)
                        PressE()
                        if Settings.AntiDrop then
                            task.wait(0.3)
                            PressE()
                        end
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
        local treadmill = FindObj("AdminTreadmill")
        if treadmill then
            local pos = GetObjPos(treadmill)
            if pos then
                MoveTo(pos)
                task.wait(0.3)
                PressE()
            end
        end
    end
end

-- ขโมยไข่ FX
local function StealFXLoop()
    while Settings.StealFX and Settings.ScriptEnabled do
        task.wait(1)
        local root = GetRoot()
        if root then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and HasChild(obj, "FX") then
                    local pos = GetObjPos(obj)
                    if pos then
                        MoveTo(pos)
                        task.wait(0.5)
                        PressE()
                        if Settings.AntiDrop then
                            task.wait(0.3)
                            PressE()
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
            local root = GetRoot()
            if root then
                if not BasePosition then
                    BasePosition = root.Position
                end
                
                local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
                if areaEggs then
                    local eggs = areaEggs:GetChildren()
                    local nearest = nil
                    local minDist = math.huge
                    
                    for _, egg in pairs(eggs) do
                        if egg:IsA("Model") then
                            local pos = GetObjPos(egg)
                            if pos then
                                local dist = (pos - root.Position).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    nearest = egg
                                end
                            end
                        end
                    end
                    
                    if nearest then
                        IsStealing = true
                        local eggPos = GetObjPos(nearest)
                        if eggPos then
                            MoveTo(eggPos)
                            task.wait(0.5)
                            PressE()
                            
                            if Settings.AntiDrop then
                                task.wait(0.2)
                                PressE()
                            end
                            
                            if Settings.FastPickup then
                                task.wait(0.15)
                                PressE()
                            end
                            
                            task.wait(1)
                            
                            if BasePosition then
                                MoveTo(BasePosition)
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
    spawn(function()
        while Settings.InfiniteJump and Settings.ScriptEnabled do
            task.wait(0.1)
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
                humanoid.JumpPower = Settings.JumpPower
            end
        end
        -- คืนค่าเมื่อปิด
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
        end
    end)
end

-- ตีไว
local function EnableFastAttack()
    spawn(function()
        while Settings.FastAttack and Settings.ScriptEnabled do
            task.wait(0.05)
            local char = GetChar()
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
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
            local char = GetChar()
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
    pcall(function()
        local Http = game:GetService("HttpService")
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local response = Http:JSONDecode(game:HttpGet(url))
        local servers = {}
        for _, server in pairs(response.data) do
            if server.playing < server.maxPlayers then
                table.insert(servers, server.id)
            end
        end
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end)
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

-- ==================== สร้าง UI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "THE_CRAFT_HUB_UI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ปุ่มเปิด/ปิด UI (ลอยอยู่ตลอด)
local ToggleUIButton = Instance.new("TextButton")
ToggleUIButton.Size = UDim2.new(0, 45, 0, 45)
ToggleUIButton.Position = UDim2.new(0, 10, 0.5, -22)
ToggleUIButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
ToggleUIButton.Text = "🎮"
ToggleUIButton.TextSize = 22
ToggleUIButton.BorderSizePixel = 0
ToggleUIButton.Parent = ScreenGui

local ToggleUICorner = Instance.new("UICorner")
ToggleUICorner.CornerRadius = UDim.new(0, 10)
ToggleUICorner.Parent = ToggleUIButton

-- Main Panel
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 750, 0, 280)
MainPanel.Position = UDim2.new(0.5, -375, 0.5, -140)
MainPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
MainPanel.BorderSizePixel = 0
MainPanel.Visible = true
MainPanel.Parent = ScreenGui

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 10)
PanelCorner.Parent = MainPanel

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(0, 150, 255)
PanelStroke.Thickness = 2
PanelStroke.Parent = MainPanel

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainPanel

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleBottom = Instance.new("Frame")
TitleBottom.Size = UDim2.new(1, 0, 0, 10)
TitleBottom.Position = UDim2.new(0, 0, 0, 30)
TitleBottom.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
TitleBottom.BorderSizePixel = 0
TitleBottom.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.4, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = Lang.title
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- ปุ่ม Script On/Off
local ScriptToggle = Instance.new("TextButton")
ScriptToggle.Size = UDim2.new(0, 90, 0, 28)
ScriptToggle.Position = UDim2.new(1, -220, 0, 6)
ScriptToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
ScriptToggle.Text = Lang.script_on
ScriptToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ScriptToggle.Font = Enum.Font.GothamBold
ScriptToggle.TextSize = 10
ScriptToggle.BorderSizePixel = 0
ScriptToggle.Parent = TitleBar

local ScriptToggleCorner = Instance.new("UICorner")
ScriptToggleCorner.CornerRadius = UDim.new(0, 14)
ScriptToggleCorner.Parent = ScriptToggle

-- ปุ่มปิด Panel
local ClosePanel = Instance.new("TextButton")
ClosePanel.Size = UDim2.new(0, 28, 0, 28)
ClosePanel.Position = UDim2.new(1, -34, 0, 6)
ClosePanel.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ClosePanel.Text = "✕"
ClosePanel.TextColor3 = Color3.fromRGB(255, 255, 255)
ClosePanel.Font = Enum.Font.GothamBold
ClosePanel.TextSize = 13
ClosePanel.BorderSizePixel = 0
ClosePanel.Parent = TitleBar

local ClosePanelCorner = Instance.new("UICorner")
ClosePanelCorner.CornerRadius = UDim.new(0, 14)
ClosePanelCorner.Parent = ClosePanel

-- Tab Bar (ด้านซ้ายแนวตั้ง)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 130, 1, -40)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainPanel

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 2)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = TabBar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 5)
TabPadding.PaddingLeft = UDim.new(0, 5)
TabPadding.PaddingRight = UDim.new(0, 5)
TabPadding.Parent = TabBar

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -130, 1, -40)
ContentArea.Position = UDim2.new(0, 130, 0, 40)
ContentArea.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainPanel

-- สร้าง Tabs
local Tabs = {}

local function CreateTab(name, order)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 35)
    TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 11
    TabButton.BorderSizePixel = 0
    TabButton.LayoutOrder = order
    TabButton.Parent = TabBar
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 4)
    TabCorner.Parent = TabButton
    
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Size = UDim2.new(1, -8, 1, -8)
    TabContent.Position = UDim2.new(0, 4, 0, 4)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 3
    TabContent.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 400)
    TabContent.Visible = false
    TabContent.Parent = ContentArea
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 3)
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = TabContent
    
    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Content.Visible = false
            tab.Button.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
            tab.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        TabContent.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    table.insert(Tabs, {Button = TabButton, Content = TabContent})
    
    return TabContent
end

-- ฟังก์ชันสร้าง Toggle
local function CreateToggle(parent, title, setting, callback, order)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 52)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.LayoutOrder = order
    ToggleFrame.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 4)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.65, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 8, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = title
    ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 10
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 48, 0, 20)
    ToggleBtn.Position = UDim2.new(1, -56, 0.5, -10)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    ToggleBtn.Text = Lang.toggle_off
    ToggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 9
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ToggleFrame
    
    local ToggleBtnCorner = Instance.new("UICorner")
    ToggleBtnCorner.CornerRadius = UDim.new(0, 10)
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
    SliderFrame.Size = UDim2.new(1, 0, 0, 48)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 52)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.LayoutOrder = order
    SliderFrame.Parent = parent
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 4)
    SliderCorner.Parent = SliderFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, -10, 0, 18)
    SliderLabel.Position = UDim2.new(0, 5, 0, 2)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = title .. ": " .. default
    SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextSize = 10
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -30, 0, 8)
    SliderBar.Position = UDim2.new(0, 15, 0, 25)
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
    SliderBtn.Size = UDim2.new(0, 14, 0, 14)
    SliderBtn.Position = UDim2.new(fillPercent, -7, 0.5, -7)
    SliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderBtn.Text = ""
    SliderBtn.BorderSizePixel = 0
    SliderBtn.AutoButtonColor = false
    SliderBtn.Parent = SliderBar
    
    local SliderBtnCorner = Instance.new("UICorner")
    SliderBtnCorner.CornerRadius = UDim.new(0, 7)
    SliderBtnCorner.Parent = SliderBtn
    
    local dragging = false
    
    local function UpdateSlider()
        local mousePos = UserInputService:GetMouseLocation()
        local barPos = SliderBar.AbsolutePosition
        local barSize = SliderBar.AbsoluteSize
        local relativeX = math.clamp(mousePos.X - barPos.X, 0, barSize.X)
        local value = math.floor(min + (relativeX / barSize.X) * (max - min))
        
        SliderFill.Size = UDim2.new(relativeX / barSize.X, 0, 1, 0)
        SliderBtn.Position = UDim2.new(relativeX / barSize.X, -7, 0.5, -7)
        SliderLabel.Text = title .. ": " .. value
        callback(value)
    end
    
    SliderBtn.MouseButton1Down:Connect(function()
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
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider()
        end
    end)
    
    return SliderFrame
end

-- ฟังก์ชันสร้างปุ่ม
local function CreateButton(parent, title, callback, order)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, 0, 0, 32)
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 52)
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.LayoutOrder = order
    ButtonFrame.Parent = parent
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = ButtonFrame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 1, -6)
    Button.Position = UDim2.new(0, 5, 0, 3)
    Button.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    Button.Text = title
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 11
    Button.BorderSizePixel = 0
    Button.Parent = ButtonFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 3)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    
    return ButtonFrame
end

-- ==================== สร้างเนื้อหา Tabs ====================
local orderCounter = 0
local function NextOrder()
    orderCounter = orderCounter + 1
    return orderCounter
end

-- Tab อีเว้น
local eventTab = CreateTab(Lang.cat_event, NextOrder())

CreateToggle(eventTab, Lang.feat_auto_tree, "AutoTree", function(state)
    if state then
        spawn(AutoTreeLoop)
    end
end, NextOrder())

CreateToggle(eventTab, Lang.feat_steal_monster, "StealMonster", function(state)
    if state then
        spawn(StealMonsterLoop)
    end
end, NextOrder())

CreateToggle(eventTab, Lang.feat_loot_treadmill, "LootTreadmill", function(state)
    if state then
        spawn(LootTreadmillLoop)
    end
end, NextOrder())

CreateToggle(eventTab, Lang.feat_steal_fx, "StealFX", function(state)
    if state then
        spawn(StealFXLoop)
    end
end, NextOrder())

-- Tab ขโมยไข่
local stealTab = CreateTab(Lang.cat_steal, NextOrder())

CreateToggle(stealTab, Lang.feat_auto_steal, "AutoSteal", function(state)
    if state then
        spawn(AutoStealLoop)
    end
end, NextOrder())

CreateToggle(stealTab, Lang.feat_anti_drop, "AntiDrop", nil, NextOrder())

CreateToggle(stealTab, Lang.feat_fast_pickup, "FastPickup", nil, NextOrder())

CreateToggle(stealTab, Lang.feat_zigzag, "Zigzag", nil, NextOrder())

-- Tab ESP
local espTab = CreateTab(Lang.cat_esp, NextOrder())

CreateToggle(espTab, Lang.feat_esp_egg, "ESPEgg", function(state)
    if state then
        spawn(ESPEggLoop)
    else
        ClearESP()
    end
end, NextOrder())

CreateToggle(espTab, Lang.feat_esp_player, "ESPPlayer", function(state)
    if state then
        spawn(ESPPlayerLoop)
    else
        ClearESP()
    end
end, NextOrder())

CreateButton(espTab, Lang.btn_clear_esp, function()
    ClearESP()
    print(Lang.esp_cleared)
end, NextOrder())

-- Tab เคลื่อนไหว
local moveTab = CreateTab(Lang.cat_move, NextOrder())

CreateSlider(moveTab, Lang.speed_label, 16, 2000, 100, function(value)
    Settings.SpeedValue = value
    if Settings.SpeedEnabled then
        ApplySpeed(value)
    end
end, NextOrder())

CreateToggle(moveTab, Lang.feat_speed, "SpeedEnabled", function(state)
    if state then
        ApplySpeed(Settings.SpeedValue)
    else
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end, NextOrder())

CreateSlider(moveTab, Lang.jump_label, 50, 500, 100, function(value)
    Settings.JumpPower = value
    if Settings.HighJump then
        ApplyJump(value)
    end
end, NextOrder())

CreateToggle(moveTab, Lang.feat_high_jump, "HighJump", function(state)
    if state then
        ApplyJump(Settings.JumpPower)
    else
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.JumpPower = 50
        end
    end
end, NextOrder())

CreateToggle(moveTab, Lang.feat_infinite_jump, "InfiniteJump", function(state)
    if state then
        EnableInfiniteJump()
    end
end, NextOrder())

-- Tab ต่อสู้
local combatTab = CreateTab(Lang.cat_combat, NextOrder())

CreateToggle(combatTab, Lang.feat_fast_attack, "FastAttack", function(state)
    if state then
        EnableFastAttack()
    end
end, NextOrder())

CreateToggle(combatTab, Lang.feat_no_knockback, "NoKnockback", function(state)
    if state then
        EnableNoKnockback()
    end
end, NextOrder())

-- Tab เซิฟเวอร์
local serverTab = CreateTab(Lang.cat_server, NextOrder())

CreateButton(serverTab, Lang.btn_server_hop, function()
    HopServer()
end, NextOrder())

-- แสดง Tab แรก
if Tabs[1] then
    Tabs[1].Content.Visible = true
    Tabs[1].Button.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    Tabs[1].Button.TextColor3 = Color3.fromRGB(255, 255, 255)
end

-- ==================== Event Handlers ====================

-- ปุ่มเปิด/ปิด UI
ToggleUIButton.MouseButton1Click:Connect(function()
    MainPanel.Visible = not MainPanel.Visible
end)

-- ปุ่มปิด Panel
ClosePanel.MouseButton1Click:Connect(function()
    MainPanel.Visible = false
end)

-- ปุ่มเปิด/ปิด Script
ScriptToggle.MouseButton1Click:Connect(function()
    Settings.ScriptEnabled = not Settings.ScriptEnabled
    if Settings.ScriptEnabled then
        ScriptToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        ScriptToggle.Text = Lang.script_on
    else
        ScriptToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ScriptToggle.Text = Lang.script_off
    end
end)

-- ตรวจสอบตัวละครเกิดใหม่
LocalPlayer.CharacterAdded:Connect(function(char)
    if Settings.SpeedEnabled then
        task.wait(0.5)
        ApplySpeed(Settings.SpeedValue)
    end
    if Settings.HighJump then
        task.wait(0.5)
        ApplyJump(Settings.JumpPower)
    end
end)

-- ==================== แจ้งเตือน ====================
print("========================================")
print("THE CRAFT HUB - โหลดสำเร็จ!")
print("กดปุ่ม 🎮 เพื่อเปิด/ปิด UI")
print("========================================")

-- แสดง UI ทันที
MainPanel.Visible = true

return ScreenGui
