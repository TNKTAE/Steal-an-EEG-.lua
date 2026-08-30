--[[
    THE CRAFT HUB - สคริปต์อเนกประสงค์
    UI แบบมินิมอล ลอยได้ เคลื่อนที่ได้
    รวมทุกฟังก์ชันที่ต้องการ - ทุกฟังก์ชันทำงานเต็มระบบ
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
local StarterGui = game:GetService("StarterGui")

-- ==================== ระบบภาษา ====================
local Language = "TH"
local Translations = {
    TH = {
        title = "THE CRAFT HUB",
        script_on = "สคริปต์: เปิด",
        script_off = "สคริปต์: ปิด",
        toggle_on = "ON",
        toggle_off = "OFF",
        cat_event = "⚡ อีเว้น",
        cat_steal = "🥚 ขโมยไข่",
        cat_esp = "👁️ ESP",
        cat_move = "🏃 เคลื่อนไหว",
        cat_combat = "⚔️ ต่อสู้",
        cat_server = "🌐 เซิฟเวอร์",
        cat_zone = "📍 โซน",
        feat_auto_tree = "ตีต้นไม้ Auto",
        feat_steal_monster = "ขโมยไข่ Monster",
        feat_loot_treadmill = "เสกลู่วิ่ง",
        feat_steal_fx = "ขโมยไข่ FX",
        feat_auto_steal = "ขโมยไข่อัตโนมัติ",
        feat_anti_drop = "กันไข่หลุด",
        feat_fast_pickup = "เก็บไข่เร็วที่สุด",
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
        zone_label = "โซนที่เลือก: ",
        no_zone = "ไม่พบโซน",
        zones_found = "พบโซน: ",
        esp_cleared = "ล้าง ESP แล้ว",
        hopping = "กำลังย้ายเซิฟ...",
        no_target = "ไม่พบเป้าหมาย",
        stealing = "กำลังขโมย...",
        returning = "กำลังกลับฐาน...",
        fast_pickup_note = "เก็บทันที ไม่ต้องกดค้าง",
    },
    EN = {
        title = "THE CRAFT HUB",
        script_on = "Script: ON",
        script_off = "Script: OFF",
        toggle_on = "ON",
        toggle_off = "OFF",
        cat_event = "⚡ Event",
        cat_steal = "🥚 Steal",
        cat_esp = "👁️ ESP",
        cat_move = "🏃 Move",
        cat_combat = "⚔️ Combat",
        cat_server = "🌐 Server",
        cat_zone = "📍 Zone",
        feat_auto_tree = "Auto Tree",
        feat_steal_monster = "Steal Monster",
        feat_loot_treadmill = "Loot Treadmill",
        feat_steal_fx = "Steal FX",
        feat_auto_steal = "Auto Steal",
        feat_anti_drop = "Anti Drop",
        feat_fast_pickup = "Instant Pickup",
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
        zone_label = "Selected Zone: ",
        no_zone = "No zones found",
        zones_found = "Zones: ",
        esp_cleared = "ESP Cleared",
        hopping = "Hopping...",
        no_target = "No target",
        stealing = "Stealing...",
        returning = "Returning...",
        fast_pickup_note = "Instant pickup - No hold needed",
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
    FastPickup = true, -- เปิดค่าเริ่มต้น เก็บเร็วที่สุด
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
local IsStealing = false
local BasePosition = nil
local ZoneList = {}
local ZoneButtons = {}

-- ==================== ฟังก์ชันช่วยเหลือ ====================
local function GetChar()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local char = GetChar()
    if char then return char:FindFirstChildOfClass("Humanoid") end
    return nil
end

local function GetRoot()
    local char = GetChar()
    if char then return char:FindFirstChild("HumanoidRootPart") end
    return nil
end

local function GetObjPos(obj)
    if not obj then return nil end
    if obj:IsA("Model") then
        if obj:FindFirstChild("HumanoidRootPart") then return obj.HumanoidRootPart.Position end
        if obj:FindFirstChild("PrimaryPart") then return obj.PrimaryPart.Position end
        local part = obj:FindFirstChildWhichIsA("BasePart")
        if part then return part.Position end
    elseif obj:IsA("BasePart") then
        return obj.Position
    end
    return nil
end

local function HasChild(obj, name)
    if not obj then return false end
    for _, child in pairs(obj:GetChildren()) do
        if child.Name == name then return true end
    end
    return false
end

-- 🔑 ปรับปรุง: กดเก็บทันที รวดเร็วที่สุด ไม่ต้องรอ ไม่ต้องกดค้าง
local function PickupInstant()
    -- กด E แบบรวดเร็ว 2 ครั้งติดกันทันที เพื่อให้แน่ใจว่าเก็บได้ทันที
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
end

-- เก็บไข่แบบเร่งด่วน - เรียกใช้เมื่อต้องการเก็บทันที
local function FastCollect()
    if Settings.FastPickup then
        PickupInstant()
        -- ป้องกันไข่หลุด กดซ้ำทันที
        if Settings.AntiDrop then
            task.wait(0.05)
            PickupInstant()
        end
    else
        PickupInstant()
    end
end

local function MoveTo(pos)
    local humanoid = GetHumanoid()
    local root = GetRoot()
    if humanoid and root and pos then
        humanoid:MoveTo(pos)
        if Settings.Zigzag and IsStealing then
            local offset = Vector3.new(math.sin(tick() * 10) * 3, 0, math.cos(tick() * 10) * 3)
            humanoid:MoveTo(pos + offset)
        end
    end
end

-- บินเร็วขึ้น
local function FlyTo(pos, speed)
    local root = GetRoot()
    if not root or not pos then return end
    
    local distance = (pos - root.Position).Magnitude
    if distance < 2 then return end
    
    local direction = (pos - root.Position).Unit
    local moveSpeed = speed or 120
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = direction * moveSpeed
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.P = 1000
    bodyVelocity.Parent = root
    
    -- รอจนถึงเป้าหมาย เร็วขึ้น
    while (root.Position - pos).Magnitude > 2 do
        task.wait()
        bodyVelocity.Velocity = (pos - root.Position).Unit * moveSpeed
    end
    
    bodyVelocity:Destroy()
end

-- ==================== ฟังก์ชันหลัก ====================

-- ตีต้นไม้อัตโนมัติ
local function AutoTreeLoop()
    while Settings.AutoTree and Settings.ScriptEnabled do
        task.wait(0.2)
        pcall(function()
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
                        if minDist > 4 then
                            FlyTo(pos, 100)
                        else
                            local char = GetChar()
                            local tool = char and char:FindFirstChildOfClass("Tool")
                            if tool then
                                tool:Activate()
                                task.wait(0.05)
                                tool:Deactivate()
                            else
                                FastCollect()
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- ขโมยไข่ Monster
local function StealMonsterLoop()
    while Settings.StealMonster and Settings.ScriptEnabled do
        task.wait(0.5)
        pcall(function()
            local root = GetRoot()
            if root then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and HasChild(obj, "MonsterParasiteVisual") then
                        local pos = GetObjPos(obj)
                        if pos then
                            FlyTo(pos, 120)
                            FastCollect() -- เก็บทันที
                            break
                        end
                    end
                end
            end
        end)
    end
end

-- เสกลู่วิ่ง
local function LootTreadmillLoop()
    while Settings.LootTreadmill and Settings.ScriptEnabled do
        task.wait(0.3)
        pcall(function()
            local treadmill = nil
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name == "AdminTreadmill" then
                    treadmill = obj
                    break
                end
            end
            if treadmill then
                local pos = GetObjPos(treadmill)
                if pos then
                    FlyTo(pos, 100)
                    FastCollect()
                end
            end
        end)
    end
end

-- ขโมยไข่ FX
local function StealFXLoop()
    while Settings.StealFX and Settings.ScriptEnabled do
        task.wait(0.5)
        pcall(function()
            local root = GetRoot()
            if root then
                local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
                if areaEggs then
                    for _, egg in pairs(areaEggs:GetChildren()) do
                        if egg:IsA("Model") and HasChild(egg, "FX") then
                            local pos = GetObjPos(egg)
                            if pos then
                                FlyTo(pos, 120)
                                FastCollect() -- เก็บทันที
                                break
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- 🔑 ขโมยไข่อัตโนมัติ - ปรับปรุงใหม่ เก็บทันที ไม่รอ
local function AutoStealLoop()
    while Settings.AutoSteal and Settings.ScriptEnabled do
        task.wait(0.3)
        if not IsStealing then
            pcall(function()
                local root = GetRoot()
                if not root then return end
                
                if not BasePosition then
                    BasePosition = root.Position
                end
                
                local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
                if not areaEggs then return end
                
                local eggs = areaEggs:GetChildren()
                local nearest = nil
                local minDist = math.huge
                
                for _, egg in pairs(eggs) do
                    if egg:IsA("Model") then
                        local pos = GetObjPos(egg)
                        if pos then
                            -- ตรวจสอบโซน
                            local inZone = true
                            if Settings.SelectedZone ~= "" then
                                inZone = false
                                local objectsFolder = Workspace:FindFirstChild("__OBJECTS")
                                if objectsFolder then
                                    local areasFolder = objectsFolder:FindFirstChild("Areas")
                                    if areasFolder then
                                        local zone = areasFolder:FindFirstChild(Settings.SelectedZone)
                                        if zone then
                                            local zonePos = GetObjPos(zone)
                                            if zonePos and (pos - zonePos).Magnitude < 300 then
                                                inZone = true
                                            end
                                        end
                                    end
                                end
                            end
                            
                            if inZone then
                                local dist = (pos - root.Position).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    nearest = egg
                                end
                            end
                        end
                    end
                end
                
                if nearest then
                    IsStealing = true
                    local eggPos = GetObjPos(nearest)
                    if eggPos then
                        -- บินไปไข่
                        FlyTo(eggPos, Settings.SpeedEnabled and Settings.SpeedValue or 150)
                        
                        -- 🔑 เก็บทันที กดปุ๊บติดมือปั๊บ ไม่ต้องรอ
                        FastCollect()
                        
                        -- กลับฐานทันที
                        if BasePosition then
                            if Settings.Zigzag then
                                local zigzagPos = BasePosition + Vector3.new(math.sin(tick() * 8) * 8, 0, math.cos(tick() * 8) * 8)
                                FlyTo(zigzagPos, Settings.SpeedEnabled and Settings.SpeedValue or 150)
                            else
                                FlyTo(BasePosition, Settings.SpeedEnabled and Settings.SpeedValue or 150)
                            end
                        end
                    end
                    IsStealing = false
                end
            end)
        end
    end
end

-- ESP ไข่
local function ESPEggLoop()
    while Settings.ESPEgg and Settings.ScriptEnabled do
        task.wait(1)
        ClearESP()
        pcall(function()
            local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
            if areaEggs then
                local seen = {}
                for _, egg in pairs(areaEggs:GetChildren()) do
                    if egg:IsA("Model") then
                        local baseName = egg.Name:gsub("%d+$", "")
                        local color = seen[baseName] and Color3.fromRGB(255,100,100) or Color3.fromRGB(255,255,0)
                        seen[baseName] = true
                        CreateESP(egg, color, baseName)
                    end
                end
            end
        end)
    end
end

-- ESP ผู้เล่น
local function ESPPlayerLoop()
    while Settings.ESPPlayer and Settings.ScriptEnabled do
        task.wait(1)
        ClearESP()
        pcall(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local char = player.Character
                    if char then
                        CreateESP(char, Color3.fromRGB(0,200,255), player.Name)
                    end
                end
            end
        end)
    end
end

-- ปรับความเร็ว
local function ApplySpeed(value)
    pcall(function()
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end)
end

-- กระโดดสูง
local function ApplyJump(value)
    pcall(function()
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.JumpPower = value
        end
    end)
end

-- กระโดดไม่จำกัด
local function EnableInfiniteJump()
    spawn(function()
        while Settings.InfiniteJump and Settings.ScriptEnabled do
            task.wait(0.05)
            pcall(function()
                local humanoid = GetHumanoid()
                if humanoid then
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
                    humanoid.JumpPower = Settings.JumpPower
                end
            end)
        end
        pcall(function()
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
            end
        end)
    end)
end

-- ตีไว
local function EnableFastAttack()
    spawn(function()
        while Settings.FastAttack and Settings.ScriptEnabled do
            task.wait(0.03)
            pcall(function()
                local char = GetChar()
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                        task.wait(0.01)
                        tool:Deactivate()
                    end
                end
            end)
        end
    end)
end

-- ไม่กระเด็น
local function EnableNoKnockback()
    spawn(function()
        while Settings.NoKnockback and Settings.ScriptEnabled do
            task.wait(0.1)
            pcall(function()
                local char = GetChar()
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0)
                    end
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Massless = true
                        end
                    end
                end
            end)
        end
    end)
end

-- ย้ายเซิฟ
local function HopServer()
    pcall(function()
        local servers = {}
        local success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success and response and response.data then
            for _, server in pairs(response.data) do
                if server.playing < server.maxPlayers and server.id then
                    table.insert(servers, server.id)
                end
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

-- รีเฟรชโซน
local function RefreshZones()
    ZoneList = {}
    pcall(function()
        local objectsFolder = Workspace:FindFirstChild("__OBJECTS")
        if objectsFolder then
            local areasFolder = objectsFolder:FindFirstChild("Areas")
            if areasFolder then
                for _, area in pairs(areasFolder:GetChildren()) do
                    if area:IsA("BasePart") or area:IsA("Model") then
                        table.insert(ZoneList, area.Name)
                    end
                end
            end
        end
    end)
    return ZoneList
end

-- สร้าง ESP
function CreateESP(target, color, name)
    pcall(function()
        if not target then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_" .. name
        highlight.FillColor = color
        highlight.FillTransparency = 0.4
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.2
        highlight.Adornee = target
        highlight.Parent = target
        table.insert(ESPObjects, highlight)
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_BB_" .. name
        billboard.Size = UDim2.new(0, 100, 0, 25)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = target:IsA("Model") and target.PrimaryPart or target
        billboard.Parent = target
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.Parent = billboard
    end)
end

-- ล้าง ESP
function ClearESP()
    for _, obj in pairs(ESPObjects) do
        pcall(function() if obj then obj:Destroy() end end)
    end
    ESPObjects = {}
end

-- ==================== สร้าง UI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "THE_CRAFT_HUB_UI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ปุ่มเปิด/ปิด UI
local ToggleUIButton = Instance.new("TextButton")
ToggleUIButton.Size = UDim2.new(0, 45, 0, 45)
ToggleUIButton.Position = UDim2.new(0, 8, 0.5, -22)
ToggleUIButton.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
ToggleUIButton.Text = "🎮"
ToggleUIButton.TextSize = 22
ToggleUIButton.BorderSizePixel = 0
ToggleUIButton.Parent = ScreenGui

local ToggleUICorner = Instance.new("UICorner")
ToggleUICorner.CornerRadius = UDim.new(0, 10)
ToggleUICorner.Parent = ToggleUIButton

-- Main Panel
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 440, 0, 280)
MainPanel.Position = UDim2.new(0.5, -220, 0.5, -140)
MainPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 25)
MainPanel.BorderSizePixel = 0
MainPanel.Visible = true
MainPanel.Active = true
MainPanel.Draggable = true
MainPanel.Parent = ScreenGui

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 10)
PanelCorner.Parent = MainPanel

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(0, 180, 255)
PanelStroke.Thickness = 1.5
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
TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = Lang.title
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- ปุ่ม Script On/Off
local ScriptToggle = Instance.new("TextButton")
ScriptToggle.Size = UDim2.new(0, 80, 0, 26)
ScriptToggle.Position = UDim2.new(1, -185, 0, 7)
ScriptToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
ScriptToggle.Text = Lang.script_on
ScriptToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ScriptToggle.Font = Enum.Font.GothamBold
ScriptToggle.TextSize = 10
ScriptToggle.BorderSizePixel = 0
ScriptToggle.Parent = TitleBar

local ScriptToggleCorner = Instance.new("UICorner")
ScriptToggleCorner.CornerRadius = UDim.new(0, 13)
ScriptToggleCorner.Parent = ScriptToggle

-- ปุ่มปิด Panel
local ClosePanel = Instance.new("TextButton")
ClosePanel.Size = UDim2.new(0, 28, 0, 28)
ClosePanel.Position = UDim2.new(1, -35, 0, 6)
ClosePanel.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ClosePanel.Text = "✕"
ClosePanel.TextColor3 = Color3.fromRGB(255, 255, 255)
ClosePanel.Font = Enum.Font.GothamBold
ClosePanel.TextSize = 12
ClosePanel.BorderSizePixel = 0
ClosePanel.Parent = TitleBar

local ClosePanelCorner = Instance.new("UICorner")
ClosePanelCorner.CornerRadius = UDim.new(0, 14)
ClosePanelCorner.Parent = ClosePanel

-- Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 100, 1, -40)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainPanel

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 3)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = TabBar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 4)
TabPadding.PaddingLeft = UDim.new(0, 4)
TabPadding.PaddingRight = UDim.new(0, 4)
TabPadding.Parent = TabBar

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -100, 1, -40)
ContentArea.Position = UDim2.new(0, 100, 0, 40)
ContentArea.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainPanel

-- สร้าง Tabs
local Tabs = {}

local function CreateTab(name, order)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 32)
    TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(160, 160, 160)
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 9
    TabButton.BorderSizePixel = 0
    TabButton.LayoutOrder = order
    TabButton.Parent = TabBar
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 5)
    TabCorner.Parent = TabButton
    
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Size = UDim2.new(1, -8, 1, -8)
    TabContent.Position = UDim2.new(0, 4, 0, 4)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 4
    TabContent.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
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
            tab.Button.TextColor3 = Color3.fromRGB(160, 160, 160)
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
    ToggleFrame.Size = UDim2.new(1, 0, 0, 32)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.LayoutOrder = order
    ToggleFrame.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 5)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 8, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = title
    ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 9
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 44, 0, 22)
    ToggleBtn.Position = UDim2.new(1, -52, 0.5, -11)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
    ToggleBtn.Text = Lang.toggle_off
    ToggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 8
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ToggleFrame
    
    local ToggleBtnCorner = Instance.new("UICorner")
    ToggleBtnCorner.CornerRadius = UDim.new(0, 11)
    ToggleBtnCorner.Parent = ToggleBtn
    
    -- ตั้งค่าสถานะเริ่มต้น
    if Settings[setting] then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 230)
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBtn.Text = Lang.toggle_on
    end
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        if Settings[setting] then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 230)
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleBtn.Text = Lang.toggle_on
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
            ToggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
            ToggleBtn.Text = Lang.toggle_off
        end
        if callback then callback(Settings[setting]) end
    end)
    
    return ToggleFrame
end

-- ฟังก์ชันสร้าง Slider
local function CreateSlider(parent, title, min, max, default, callback, order)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 45)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.LayoutOrder = order
    SliderFrame.Parent = parent
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 5)
    SliderCorner.Parent = SliderFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, -10, 0, 18)
    SliderLabel.Position = UDim2.new(0, 5, 0, 3)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = title .. ": " .. default
    SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextSize = 9
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -30, 0, 8)
    SliderBar.Position = UDim2.new(0, 15, 0, 28)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderFrame
    
    local SliderBarCorner = Instance.new("UICorner")
    SliderBarCorner.CornerRadius = UDim.new(0, 4)
    SliderBarCorner.Parent = SliderBar
    
    local SliderFill = Instance.new("Frame")
    local fillPercent = (default - min) / (max - min)
    SliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 230)
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
    
    SliderBtn.MouseButton1Down:Connect(function() dragging = true end)
    SliderBar.MouseButton1Down:Connect(function() dragging = true UpdateSlider() end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider() end
    end)
    
    return SliderFrame
end

-- ฟังก์ชันสร้างปุ่ม
local function CreateButton(parent, title, callback, order)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -8, 0, 28)
    Button.Position = UDim2.new(0, 4, 0, 0)
    Button.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    Button.Text = title
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 9
    Button.BorderSizePixel = 0
    Button.LayoutOrder = order
    Button.Parent = parent
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    return Button
end

-- ==================== สร้างเนื้อหา - ทุกฟังก์ชันครบถ้วน ====================
local orderCounter = 0
local function NextOrder()
    orderCounter += 1
    return orderCounter
end

-- ========== Tab อีเว้น ==========
local eventTab = CreateTab(Lang.cat_event, NextOrder())
CreateToggle(eventTab, Lang.feat_auto_tree, "AutoTree", function(s) if s then spawn(AutoTreeLoop) end end, NextOrder())
CreateToggle(eventTab, Lang.feat_steal_monster, "StealMonster", function(s) if s then spawn(StealMonsterLoop) end end, NextOrder())
CreateToggle(eventTab, Lang.feat_loot_treadmill, "LootTreadmill", function(s) if s then spawn(LootTreadmillLoop) end end, NextOrder())
CreateToggle(eventTab, Lang.feat_steal_fx, "StealFX", function(s) if s then spawn(StealFXLoop) end end, NextOrder())

-- ========== Tab ขโมยไข่ ==========
local stealTab = CreateTab(Lang.cat_steal, NextOrder())
CreateToggle(stealTab, Lang.feat_auto_steal, "AutoSteal", function(s) if s then spawn(AutoStealLoop) end end, NextOrder())
CreateToggle(stealTab, Lang.feat_anti_drop, "AntiDrop", nil, NextOrder())
CreateToggle(stealTab, Lang.feat_fast_pickup .. " ⚡", "FastPickup", nil, NextOrder())
CreateToggle(stealTab, Lang.feat_zigzag, "Zigzag", nil, NextOrder())

-- ========== Tab ESP ==========
local espTab = CreateTab(Lang.cat_esp, NextOrder())
CreateToggle(espTab, Lang.feat_esp_egg, "ESPEgg", function(s) if s then spawn(ESPEggLoop) else ClearESP() end end, NextOrder())
CreateToggle(espTab, Lang.feat_esp_player, "ESPPlayer", function(s) if s then spawn(ESPPlayerLoop) else ClearESP() end end, NextOrder())
CreateButton(espTab, Lang.btn_clear_esp, function() ClearESP() end, NextOrder())

-- ========== Tab เคลื่อนไหว ==========
local moveTab = CreateTab(Lang.cat_move, NextOrder())
CreateSlider(moveTab, Lang.speed_label, 16, 2000, 100, function(v)
    Settings.SpeedValue = v
    if Settings.SpeedEnabled then ApplySpeed(v) end
end, NextOrder())
CreateToggle(moveTab, Lang.feat_speed, "SpeedEnabled", function(s)
    if s then ApplySpeed(Settings.SpeedValue)
    else local h = GetHumanoid() if h then h.WalkSpeed = 16 end end
end, NextOrder())
CreateSlider(moveTab, Lang.jump_label, 50, 500, 100, function(v)
    Settings.JumpPower = v
    if Settings.HighJump then ApplyJump(v) end
end, NextOrder())
CreateToggle(moveTab, Lang.feat_high_jump, "HighJump", function(s)
    if s then ApplyJump(Settings.JumpPower)
    else local h = GetHumanoid() if h then h.JumpPower = 50 end end
end, NextOrder())
CreateToggle(moveTab, Lang.feat_infinite_jump, "InfiniteJump", function(s) if s then EnableInfiniteJump() end end, NextOrder())

-- ========== Tab ต่อสู้ ==========
local combatTab = CreateTab(Lang.cat_combat, NextOrder())
CreateToggle(combatTab, Lang.feat_fast_attack, "FastAttack", function(s) if s then EnableFastAttack() end end, NextOrder())
CreateToggle(combatTab, Lang.feat_no_knockback, "NoKnockback", function(s) if s then EnableNoKnockback() end end, NextOrder())

-- ========== Tab เซิฟเวอร์ ==========
local serverTab = CreateTab(Lang.cat_server, NextOrder())
CreateButton(serverTab, Lang.btn_server_hop, HopServer, NextOrder())

-- ========== Tab โซน ==========
local zoneTab = CreateTab(Lang.cat_zone, NextOrder())
local zoneLabel = Instance.new("TextLabel")
zoneLabel.Size = UDim2.new(1, -8, 0, 28)
zoneLabel.Position = UDim2.new(0, 4, 0, 0)
zoneLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
zoneLabel.Text = Lang.zone_label .. "-"
zoneLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
zoneLabel.Font = Enum.Font.GothamBold
zoneLabel.TextSize = 10
zoneLabel.LayoutOrder = NextOrder()
zoneTab.CanvasSize = UDim2.new(0, 0, 0, 100)
zoneLabel.Parent = zoneTab

local zoneLabelCorner = Instance.new("UICorner")
zoneLabelCorner.CornerRadius = UDim.new(0, 5)
zoneLabelCorner.Parent = zoneLabel

CreateButton(zoneTab, Lang.btn_refresh_zone, function()
    local zones = RefreshZones()
    zoneLabel.Text = Lang.zone_label .. (#zones > 0 and table.concat(zones, ", ") or "-")
    for _, btn in pairs(ZoneButtons) do if btn then btn:Destroy() end end
    ZoneButtons = {}
    for i, zoneName in pairs(zones) do
        local btn = CreateButton(zoneTab, zoneName, function()
            Settings.SelectedZone = zoneName
            zoneLabel.Text = Lang.zone_label .. zoneName
        end, NextOrder())
        table.insert(ZoneButtons, btn)
    end
    zoneTab.CanvasSize = UDim2.new(0, 0, 0, 50 + #zones * 32)
end, NextOrder())

-- แสดง Tab แรก
if Tabs[1] then
    Tabs[1].Content.Visible = true
    Tabs[1].Button.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    Tabs[1].Button.TextColor3 = Color3.fromRGB(255, 255, 255)
end

-- ==================== Event Handlers ====================
ToggleUIButton.MouseButton1Click:Connect(function() MainPanel.Visible = not MainPanel.Visible end)
ClosePanel.MouseButton1Click:Connect(function() MainPanel.Visible = false end)

ScriptToggle.MouseButton1Click:Connect(function()
    Settings.ScriptEnabled = not Settings.ScriptEnabled
    if Settings.ScriptEnabled then
        ScriptToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        ScriptToggle.Text = Lang.script_on
    else
        ScriptToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ScriptToggle.Text = Lang.script_off
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Settings.SpeedEnabled then ApplySpeed(Settings.SpeedValue) end
    if Settings.HighJump then ApplyJump(Settings.JumpPower) end
end)

-- โหลดโซนอัตโนมัติ
task.spawn(function()
    task.wait(1.5)
    RefreshZones()
end)

-- ==================== แจ้งเตือน ====================
print("========================================")
print("✅ THE CRAFT HUB - โหลดสำเร็จ!")
print("⚡ เก็บไข่ทันที - กดปุ๊บติดมือปั๊บ ไม่ต้องรอ")
print("📋 ทุกฟังก์ชันแสดงครบถ้วนใน UI")
print("🎮 กดปุ่
