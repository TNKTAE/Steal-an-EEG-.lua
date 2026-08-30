--[[
    THE CRAFT HUB - FIXED VERSION
    ✅ รันแล้วทำงานทันที | ✅ แสดง UI แน่นอน | ✅ เก็บไข่เร็วที่สุด
]]

-- ==============================================
-- SERVICES - โหลดก่อนเสมอ
-- ==============================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- ==============================================
-- แจ้งเตือนว่าสคริปต์เริ่มทำงาน
-- ==============================================
print("🔄 กำลังโหลด THE CRAFT HUB...")

-- ==============================================
-- ภาษา
-- ==============================================
local Language = "TH"
local Translations = {
    TH = {
        title = "THE CRAFT HUB",
        script_on = "ON",
        script_off = "OFF",
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
        feat_fast_pickup = "เก็บไข่เร็วสุด",
        feat_zigzag = "ซิกแซก",
        feat_esp_egg = "ESP ไข่",
        feat_esp_player = "ESP ผู้เล่น",
        feat_speed = "ความเร็ว",
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
    },
    EN = {
        title = "THE CRAFT HUB",
        script_on = "ON",
        script_off = "OFF",
        toggle_on = "ON",
        toggle_off = "OFF",
        cat_event = "⚡ Event",
        cat_steal = "🥚 Steal",
        cat_esp = "👁️ ESP",
        cat_move = "🏃 Movement",
        cat_combat = "⚔️ Combat",
        cat_server = "🌐 Server",
        cat_zone = "📍 Zone",
        feat_auto_tree = "Auto Tree",
        feat_steal_monster = "Steal Monster",
        feat_loot_treadmill = "Loot Treadmill",
        feat_steal_fx = "Steal FX",
        feat_auto_steal = "Auto Steal",
        feat_anti_drop = "Anti Drop",
        feat_fast_pickup = "Fast Pickup",
        feat_zigzag = "Zigzag",
        feat_esp_egg = "ESP Eggs",
        feat_esp_player = "ESP Players",
        feat_speed = "Speed",
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
    }
}
local Lang = Translations[Language]

-- ==============================================
-- ตัวแปร
-- ==============================================
local Settings = {
    ScriptEnabled = true,
    AutoTree = false,
    StealMonster = false,
    LootTreadmill = false,
    StealFX = false,
    AutoSteal = false,
    AntiDrop = false,
    FastPickup = true,
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

-- ==============================================
-- ฟังก์ชันช่วยเหลือ
-- ==============================================
local function GetChar() return LocalPlayer.Character end
local function GetHumanoid() local c = GetChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function GetRoot() local c = GetChar(); return c and c:FindFirstChild("HumanoidRootPart") end

local function GetObjPos(obj)
    if not obj then return nil end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        if obj:FindFirstChild("HumanoidRootPart") then return obj.HumanoidRootPart.Position end
        local p = obj:FindFirstChildWhichIsA("BasePart")
        if p then return p.Position end
    elseif obj:IsA("BasePart") then return obj.Position end
    return nil
end

local function HasChild(obj, name)
    if not obj then return false end
    for _, c in pairs(obj:GetChildren()) do if c.Name == name then return true end end
    return false
end

-- 🔥 เก็บไข่ทันที - กดปุ๊บติดมือปั๊บ
local function PickupInstant()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
end

local function FastCollect()
    PickupInstant()
    task.wait(0.03)
    PickupInstant()
end

-- บินเร็ว
local function FlyTo(pos, speed)
    local root = GetRoot()
    if not root or not pos then return end
    speed = speed or 120
    
    local dist = (pos - root.Position).Magnitude
    if dist < 3 then return end
    
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = (pos - root.Position).Unit * speed
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.P = 5000
    bv.Parent = root
    
    while (pos - root.Position).Magnitude > 3 do
        task.wait()
        bv.Velocity = (pos - root.Position).Unit * speed
    end
    
    bv:Destroy()
end

-- ==============================================
-- ฟังก์ชันหลัก
-- ==============================================

-- ขโมยไข่อัตโนมัติ
local function AutoStealLoop()
    while Settings.AutoSteal and Settings.ScriptEnabled do
        task.wait(0.2)
        if IsStealing then continue end
        
        pcall(function()
            local root = GetRoot()
            if not root then return end
            if not BasePosition then BasePosition = root.Position end
            
            local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")
            if not areaEggs then return end
            
            local nearest, minDist = nil, math.huge
            for _, egg in pairs(areaEggs:GetChildren()) do
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
                    FlyTo(eggPos, 150)
                    FastCollect() -- 🔥 เก็บทันที
                    task.wait(0.1)
                    if BasePosition then FlyTo(BasePosition, 150) end
                end
                IsStealing = false
            end
        end)
    end
end

-- ESP ไข่
local function CreateESP(target, color, name)
    pcall(function()
        local hl = Instance.new("Highlight")
        hl.Name = "ESP_"..name
        hl.FillColor = color
        hl.FillTransparency = 0.4
        hl.OutlineColor = Color3.new(1,1,1)
        hl.OutlineTransparency = 0.2
        hl.Adornee = target
        hl.Parent = target
        table.insert(ESPObjects, hl)
    end)
end

local function ClearESP()
    for _, v in pairs(ESPObjects) do pcall(function() v:Destroy() end) end
    ESPObjects = {}
end

local function ESPEggLoop()
    while Settings.ESPEgg and Settings.ScriptEnabled do
        task.wait(1.5)
        ClearESP()
        pcall(function()
            local area = Workspace:FindFirstChild("AreaEggSlotsClient")
            if area then
                for _, egg in pairs(area:GetChildren()) do
                    if egg:IsA("Model") then
                        CreateESP(egg, Color3.fromRGB(255,200,0), egg.Name)
                    end
                end
            end
        end)
    end
end

-- ปรับความเร็ว
local function ApplySpeed(val)
    pcall(function() local h = GetHumanoid() if h then h.WalkSpeed = val end end)
end

local function ApplyJump(val)
    pcall(function() local h = GetHumanoid() if h then h.JumpPower = val end end)
end

-- ==============================================
-- สร้าง UI - ส่วนสำคัญที่สุด!
-- ==============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "THE_CRAFT_HUB"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- ปุ่มลอยเปิด-ปิด
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -25)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
OpenBtn.Text = "🎮"
OpenBtn.TextSize = 24
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.BorderSizePixel = 0
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = ScreenGui

local OpenBtnCorner = Instance.new("UICorner")
OpenBtnCorner.CornerRadius = UDim.new(0, 12)
OpenBtnCorner.Parent = OpenBtn

-- หน้าต่างหลัก
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 180, 255)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- แถบชื่อ
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = Lang.title
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- ปุ่มปิด
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- เนื้อหา
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -10, 1, -50)
Content.Position = UDim2.new(0, 5, 0, 45)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 4
Content.CanvasSize = UDim2.new(0, 0, 0, 550)
Content.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 6)
ListLayout.Parent = Content

-- ฟังก์ชันสร้าง Toggle
local function AddToggle(name, setting, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    Frame.Parent = Content
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 50, 0, 24)
    Btn.Position = UDim2.new(1, -62, 0.5, -12)
    Btn.BackgroundColor3 = Settings[setting] and Color3.fromRGB(0, 160, 230) or Color3.fromRGB(60, 60, 80)
    Btn.Text = Settings[setting] and Lang.toggle_on or Lang.toggle_off
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 10
    Btn.BorderSizePixel = 0
    Btn.Parent = Frame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 12)
    BtnCorner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        Btn.BackgroundColor3 = Settings[setting] and Color3.fromRGB(0, 160, 230) or Color3.fromRGB(60, 60, 80)
        Btn.Text = Settings[setting] and Lang.toggle_on or Lang.toggle_off
        if callback then callback(Settings[setting]) end
    end)
end

local function AddSlider(name, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    Frame.Parent = Content
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -15, 0, 18)
    Label.Position = UDim2.new(0, 8, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -30, 0, 8)
    Bar.Position = UDim2.new(0, 15, 0, 35)
    Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    Bar.Parent = Frame
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 4)
    BarCorner.Parent = Bar
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 160, 230)
    Fill.Parent = Bar
    
    local dragging, value = false, default
    
    local function Update(input)
        local pos = UserInputService:GetMouseLocation()
        local barPos = Bar.AbsolutePosition
        local barSize = Bar.AbsoluteSize
        local percent = math.clamp((pos.X - barPos.X) / barSize.X, 0, 1)
        value = math.floor(min + percent * (max - min))
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        Label.Text = name .. ": " .. value
        callback(value)
    end
    
    Bar.MouseButton1Down:Connect(function() dragging = true Update() end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
end

-- ==============================================
-- เพิ่มฟังก์ชันทั้งหมดลง UI
-- ==============================================
local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundTransparency = 1
Header.Text = "🥚 " .. Lang.cat_steal
Header.TextColor3 = Color3.fromRGB(255, 200, 0)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 12
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = Content

AddToggle(Lang.feat_auto_steal, "AutoSteal", function(s) if s then task.spawn(AutoStealLoop) end end)
AddToggle(Lang.feat_anti_drop, "AntiDrop")
AddToggle(Lang.feat_fast_pickup .. " ⚡", "FastPickup")
AddToggle(Lang.feat_zigzag, "Zigzag")

Header = Header:Clone()
Header.Text = "👁️ " .. Lang.cat_esp
Header.Parent = Content

AddToggle(Lang.feat_esp_egg, "ESPEgg", function(s) if s then task.spawn(ESPEggLoop) else ClearESP() end end)

Header = Header:Clone()
Header.Text = "🏃 " .. Lang.cat_move
Header.Parent = Content

AddSlider(Lang.speed_label, 16, 2000, 100, function(v) Settings.SpeedValue = v if Settings.SpeedEnabled then ApplySpeed(v) end end)
AddToggle(Lang.feat_speed, "SpeedEnabled", function(s) if s then ApplySpeed(Settings.SpeedValue) else ApplySpeed(16) end end)
AddSlider(Lang.jump_label, 50, 500, 100, function(v) Settings.JumpPower = v if Settings.HighJump then ApplyJump(v) end end)
AddToggle(Lang.feat_high_jump, "HighJump", function(s) if s then ApplyJump(Settings.JumpPower) else ApplyJump(50) end end)

-- ==============================================
-- การทำงานปุ่ม
-- ==============================================
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- ==============================================
-- เสร็จสิ้น!
-- ==============================================
print("✅ THE CRAFT HUB โหลดสำเร็จแล้ว!")
print("👉 กดปุ่ม 🎮 ที่ด้านซ้ายเพื่อเปิดเมนู")
print("⚡ เก็บไข่เร็วที่สุด - กดปุ๊บติดมือปั๊บ")

-- แจ้งเตือนในเกม
pcall(function()
    StarterGui:SetCore("NotificationService", {
        Title = "THE CRAFT HUB",
        Text = "โหลดสำเร็จ! กด 🎮 เพื่อเปิดเมนู",
        Duration = 5
    })
end)

return ScreenGui
