--[[
    📦 THE CRAFT HUB — แก้ไขแล้ว | ตรวจสอบข้อผิดพลาดอัตโนมัติ
    ⚠️ ใช้เพื่อการศึกษาเท่านั้น — เสี่ยงต่อการถูกแบน
]]

-- ====================== ตรวจสอบบริการเบื้องต้น ======================
local Success, Error = pcall(function()
    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local TeleportService = game:GetService("TeleportService")
    local Workspace = game:GetService("Workspace")
    return Players, UIS, RunService, TweenService, TeleportService, Workspace
end)
if not Success then
    warn("❌ โหลดบริการไม่สำเร็จ: " .. tostring(Error))
    return
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("❌ ไม่พบผู้เล่น")
    return
end

-- ====================== การตั้งค่า ======================
local Settings = {
    Language = "TH",
    Speed = 50,
    JumpPower = 50,
    AutoTreeEnabled = false,
    AutoStealMonsterParasite = false,
    AdminTreadmillSpeed = false,
    StealFXEgg = false,
    SeeThroughEgg = false,
    SeeThroughPlayer = false,
    AutoStealEgg = false,
    PreventEggDrop = false,
    FastPickup = false,
    NoLimitJump = false,
    ZigZagReturn = false,
    FastAttack = false,
    NoKnockback = false,
    ServerHop = false,
    SelectedZone = "ทั้งหมด",
    IsRunning = true
}

-- 📖 ภาษา
local Lang = {
    TH = {
        Title = "THE CRAFT HUB",
        Main = "หลัก", Visuals = "ภาพ", Event = "อีเว้นท์", Movement = "การเคลื่อนไหว",
        Combat = "ต่อสู้", Server = "เซิร์ฟเวอร์", Settings = "ตั้งค่า",
        AutoTree = "ตีต้นไม้อัตโนมัติ (ชื่อ Small)",
        StealMonsterParasite = "ขโมยไข่ MonsterParasiteVisual",
        TreadmillSpeed = "สเกลู้วิ่ง AdminTreadmill",
        StealFXEgg = "ขโมยไข่ FX (AreaEggSlotsClient)",
        SeeThroughEgg = "มองทะลุไข่ (แสดงชื่อเดียว)",
        SeeThroughPlayer = "มองทะลุผู้เล่น",
        AutoStealEgg = "ขโมยไข่อัตโนมัติ + กลับฐาน",
        Speed = "ความเร็ว (สูงสุด 2000)",
        PreventEggDrop = "กันไข่หลุด + กด E อัตโนมัติ",
        FastPickup = "เก็บไข่ไว ไม่ต้องกดค้าง",
        JumpPower = "ความสูงกระโดด",
        NoLimitJump = "กระโดดไม่จำกัด",
        ZigZag = "ซิกแซกกลับฐาน",
        FastAttack = "ตีไว กดรัวได้",
        NoKnockback = "ไม่กระเด็น",
        ServerHop = "ย้ายเซิร์ฟเวอร์",
        SelectZone = "เลือกโซน",
        Language = "ภาษา",
        Toggle = "เปิด/ปิด",
        Enabled = "✅ เปิด",
        Disabled = "❌ ปิด",
        Refresh = "รีเฟรชโซน",
        NoCharacter = "⚠️ ไม่พบตัวละคร",
        NoEggFolder = "⚠️ ไม่พบโฟลเดอร์ไข่",
        NoZones = "⚠️ ไม่พบโซน",
        Ready = "✅ พร้อมใช้งาน"
    },
    EN = {
        Title = "THE CRAFT HUB",
        Main = "Main", Visuals = "Visuals", Event = "Event", Movement = "Movement",
        Combat = "Combat", Server = "Server", Settings = "Settings",
        AutoTree = "Auto Hit Tree (Name: Small)",
        StealMonsterParasite = "Steal MonsterParasiteVisual Egg",
        TreadmillSpeed = "Admin Treadmill Speed",
        StealFXEgg = "Steal FX Egg",
        SeeThroughEgg = "See Through Eggs",
        SeeThroughPlayer = "See Through Players",
        AutoStealEgg = "Auto Steal + Return",
        Speed = "Speed (Max 2000)",
        PreventEggDrop = "Prevent Egg Drop",
        FastPickup = "Fast Pickup",
        JumpPower = "Jump Power",
        NoLimitJump = "No Limit Jump",
        ZigZag = "ZigZag Return",
        FastAttack = "Fast Attack",
        NoKnockback = "No Knockback",
        ServerHop = "Server Hop",
        SelectZone = "Select Zone",
        Language = "Language",
        Toggle = "Toggle",
        Enabled = "ON",
        Disabled = "OFF",
        Refresh = "Refresh",
        NoCharacter = "⚠️ No Character",
        NoEggFolder = "⚠️ Egg Folder Not Found",
        NoZones = "⚠️ No Zones Found",
        Ready = "✅ Ready"
    }
}

-- ====================== ตัวแปรตัวละคร ======================
local Character, Humanoid, RootPart, BasePosition
local function UpdateCharacter()
    Character = LocalPlayer.Character
    if not Character then
        task.wait(1)
        Character = LocalPlayer.Character
    end
    if not Character then return end
    Humanoid = Character:FindFirstChild("Humanoid")
    RootPart = Character:FindFirstChild("HumanoidRootPart")
    if RootPart then
        BasePosition = RootPart.Position
    end
end
UpdateCharacter()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    UpdateCharacter()
end)

-- ====================== 🎨 สร้าง UI ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- หลัก
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 520)
MainFrame.Position = UDim2.new(0.02, 0, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 35)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(40, 120, 255)
MainFrame.CornerRadius = UDim.new(0, 10)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- แถบหัว
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 80, 200)
TitleBar.CornerRadius = UDim.new(0, 10)
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Text = Lang[Settings.Language].Title
TitleText.Font = Enum.Font.GothamBold
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1
TitleText.Parent = TitleBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = Lang[Settings.Language].Ready
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
StatusLabel.Size = UDim2.new(1, -10, 0, 15)
StatusLabel.Position = UDim2.new(0, 10, 0, 50)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = MainFrame

-- ปุ่มปิด
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 18
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 7)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function()
    Settings.IsRunning = false
    ScreenGui:Destroy()
end)

-- หมวดหมู่
local CategoryFrame = Instance.new("Frame")
CategoryFrame.Size = UDim2.new(1, -10, 0, 35)
CategoryFrame.Position = UDim2.new(0, 5, 0, 70)
CategoryFrame.BackgroundTransparency = 1
CategoryFrame.Parent = MainFrame

local Categories = {
    Lang[Settings.Language].Main,
    Lang[Settings.Language].Event,
    Lang[Settings.Language].Visuals,
    Lang[Settings.Language].Movement,
    Lang[Settings.Language].Combat,
    Lang[Settings.Language].Server,
    Lang[Settings.Language].Settings
}
local Pages = {}
local CurrentPage = 1

for i, Cat in ipairs(Categories) do
    local Btn = Instance.new("TextButton")
    Btn.Text = Cat
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 11
    Btn.TextColor3 = i == 1 and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(150, 150, 150)
    Btn.Size = UDim2.new(1/#Categories, -4, 1, 0)
    Btn.Position = UDim2.new((i-1)/#Categories, 2, 0, 0)
    Btn.BackgroundTransparency = 1
    Btn.Parent = CategoryFrame
    Btn.MouseButton1Click:Connect(function()
        CurrentPage = i
        for idx, b in ipairs(CategoryFrame:GetChildren()) do
            if b:IsA("TextButton") then
                b.TextColor3 = idx == i and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(150, 150, 150)
            end
        end
        for p, page in ipairs(Pages) do
            page.Visible = (p == i)
        end
    end)
end

-- เนื้อหา
local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Size = UDim2.new(1, -10, 1, -115)
ContentContainer.Position = UDim2.new(0, 5, 0, 105)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ScrollBarThickness = 4
ContentContainer.ScrollBarColor3 = Color3.fromRGB(60, 140, 255)
ContentContainer.Parent = MainFrame

for i = 1, #Categories do
    local Page = Instance.new("Frame")
    Page.Size = UDim2.new(1, 0, 0, 1200)
    Page.BackgroundTransparency = 1
    Page.Visible = (i == 1)
    Page.Parent = ContentContainer
    Pages[i] = Page
end

-- 🧩 ฟังก์ชันสร้างปุ่ม
local function AddToggle(pageIndex, nameKey, settingKey, posY)
    local Page = Pages[pageIndex]
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 42)
    Container.Position = UDim2.new(0, 0, 0, posY)
    Container.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
    Container.CornerRadius = UDim.new(0, 6)
    Container.Parent = Page

    local Label = Instance.new("TextLabel")
    Label.Text = Lang[Settings.Language][nameKey]
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.Size = UDim2.new(1, -55, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Container

    local Toggle = Instance.new("TextButton")
    Toggle.Text = Settings[settingKey] and "✓" or ""
    Toggle.Size = UDim2.new(0, 28, 0, 28)
    Toggle.Position = UDim2.new(1, -35, 0.5, -14)
    Toggle.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(50, 180, 100) or Color3.fromRGB(70, 70, 100)
    Toggle.CornerRadius = UDim.new(0, 14)
    Toggle.Parent = Container

    Toggle.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        Toggle.Text = Settings[settingKey] and "✓" or ""
        Toggle.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(50, 180, 100) or Color3.fromRGB(70, 70, 100)
        StatusLabel.Text = Settings[settingKey] and Lang[Settings.Language].Enabled .. " " .. Lang[Settings.Language][nameKey] or Lang[Settings.Language].Disabled .. " " .. Lang[Settings.Language][nameKey]
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    end)

    return posY + 50
end

-- 🧩 สไลด์
local function AddSlider(pageIndex, nameKey, settingKey, min, max, posY)
    local Page = Pages[pageIndex]
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 55)
    Container.Position = UDim2.new(0, 0, 0, posY)
    Container.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
    Container.CornerRadius = UDim.new(0, 6)
    Container.Parent = Page

    local Label = Instance.new("TextLabel")
    Label.Text = Lang[Settings.Language][nameKey] .. ": " .. Settings[settingKey]
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.Size = UDim2.new(1, -10, 0, 22)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Name = "Label"
    Label.Parent = Container

    local BarBg = Instance.new("Frame")
    BarBg.Size = UDim2.new(1, -20, 0, 8)
    BarBg.Position = UDim2.new(0, 10, 0, 38)
    BarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    BarBg.CornerRadius = UDim.new(0, 4)
    BarBg.Parent = Container

    local BarFill = Instance.new("Frame")
    local initPercent = (Settings[settingKey] - min) / (max - min)
    BarFill.Size = UDim2.new(initPercent, 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(50, 140, 255)
    BarFill.CornerRadius = UDim.new(0, 4)
    BarFill.Parent = BarBg

    local DragBtn = Instance.new("TextButton")
    DragBtn.Text = ""
    DragBtn.Size = UDim2.new(0, 16, 0, 16)
    DragBtn.Position = UDim2.new(1, -8, 0.5, -8)
    DragBtn.BackgroundColor3 = Color3.fromRGB(120, 190, 255)
    DragBtn.CornerRadius = UDim.new(0, 8)
    DragBtn.Parent = BarFill

    local dragging = false
    DragBtn.MouseButton1Down:Connect(function() dragging = true end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    BarBg.MouseMoved:Connect(function(x)
        if not dragging then return end
        local absPos = BarBg.AbsolutePosition.X
        local size = BarBg.AbsoluteSize.X
        local percent = math.clamp((x - absPos) / size, 0, 1)
        Settings[settingKey] = math.floor(min + (max - min) * percent)
        Label.Text = Lang[Settings.Language][nameKey] .. ": " .. Settings[settingKey]
        BarFill.Size = UDim2.new(percent, 0, 1, 0)
    end)

    return posY + 65
end

-- ====================== เติมเนื้อหา ======================
local y = 5
y = AddToggle(1, "AutoTree", "AutoTreeEnabled", y)
y = AddToggle(1, "StealMonsterParasite", "AutoStealMonsterParasite", y)
y = AddToggle(1, "TreadmillSpeed", "AdminTreadmillSpeed", y)
y = AddToggle(1, "StealFXEgg", "StealFXEgg", y)

y = 5
y = AddToggle(2, "SeeThroughEgg", "SeeThroughEgg", y)
y = AddToggle(2, "SeeThroughPlayer", "SeeThroughPlayer", y)

y = 5
y = AddSlider(3, "Speed", "Speed", 16, 2000, y)
y = AddToggle(3, "AutoStealEgg", "AutoStealEgg", y)
y = AddToggle(3, "PreventEggDrop", "PreventEggDrop", y)
y = AddToggle(3, "FastPickup", "FastPickup", y)
y = AddSlider(3, "JumpPower", "JumpPower", 10, 200, y)
y = AddToggle(3, "NoLimitJump", "NoLimitJump", y)
y = AddToggle(3, "ZigZag", "ZigZagReturn", y)

y = 5
y = AddToggle(4, "FastAttack", "FastAttack", y)
y = AddToggle(4, "NoKnockback", "NoKnockback", y)

y = 5
y = AddToggle(5, "ServerHop", "ServerHop", y)

-- ====================== ⚙️ ระบบทำงานจริง ======================
-- 🌳 ตีต้นไม้อัตโนมัติ
task.spawn(function()
    while task.wait(0.3) and Settings.IsRunning do
        if not Settings.AutoTreeEnabled or not RootPart then continue end
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("BasePart") and obj.Name:find("Small") then
                local dist = (RootPart.Position - obj.Position).Magnitude
                if dist < 30 then
                    pcall(function()
                        Humanoid:MoveTo(obj.Position)
                        task.wait(0.2)
                        local click = obj:FindFirstChildOfClass("ClickDetector")
                        if click then
                            fireclickdetector(click)
                            StatusLabel.Text = "🌲 ตีต้นไม้: " .. obj.Name
                            StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
                        end
                    end)
                end
            end
        end
    end
end)

-- 🥚 ขโมยไข่ MonsterParasiteVisual + FX Egg
task.spawn(function()
    while task.wait(0.2) and Settings.IsRunning do
        if not RootPart then continue end
        local eggFolder = Workspace:FindFirstChild("AreaEggSlotsClient")
        if not eggFolder then
            StatusLabel.Text = Lang[Settings.Language].NoEggFolder
            StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
            continue
        end

        -- MonsterParasiteVisual
        if Settings.AutoStealMonsterParasite then
            for _, egg in ipairs(Workspace:GetDescendants()) do
                if egg.Name == "MonsterParasiteVisual" and egg:IsA("BasePart") then
                    local dist = (RootPart.Position - egg.Position).Magnitude
                    if dist < 15 then
                        pcall(function()
                            local click = egg:FindFirstChildOfClass("ClickDetector")
                            if click then
                                fireclickdetector(click)
                                StatusLabel.Text = "🥚 ขโมย MonsterParasiteVisual"
                                StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
                            end
                        end)
                    end
                end
            end
        end

        -- FX Egg
        if Settings.StealFXEgg then
            for _, egg in ipairs(eggFolder:GetDescendants()) do
                if egg.Name == "FX" and egg:IsA("BasePart") then
                    local dist = (RootPart.Position - egg.Position).Magnitude
                    if dist < 15 then
                        pcall(function()
                            local click = egg:FindFirstChildOfClass("ClickDetector")
                            if click then
                                fireclickdetector(click)
                                StatusLabel.Text = "🥚 ขโมยไข่ FX"
                                StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
                            end
                        end)
                    end
                end
            end
        end
    end
end)

-- 🏃 ความเร็ว + กระโดด
RunService.Heartbeat:Connect(function()
    if not Humanoid then return end
    pcall(function()
        Humanoid.WalkSpeed = Settings.Speed
        Humanoid.JumpPower = Settings.JumpPower
        if Settings.NoLimitJump then
            Humanoid.JumpHeight = 500
        end
    end)
end)

-- 👁️ มองทะลุผู้เล่น
RunService.RenderStepped:Connect(function()
    if not Settings.SeeThroughPlayer then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            for _, part in ipairs(p.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0.4
                    part.ZIndex = 2
                end
            end
        end
    end
end)

-- 🥚 มองทะลุไข่
local seenEggs = {}
RunService.RenderStepped:Connect(function()
    if not Settings.SeeThroughEgg then
        seenEggs = {}
        return
    end
    local eggFolder = Workspace:FindFirstChild("AreaEggSlotsClient")
    if not eggFolder then return end
    seenEggs = {}
    for _, egg in ipairs(eggFolder:GetDescendants()) do
        if egg:IsA("BasePart") and egg.Name == "FX" then
            egg.Transparency = 0.3
            if not seenEggs[egg.Name] then
                seenEggs[egg.Name] = true
                pcall(function()
                    local bill = Instance.new("BillboardGui")
                    bill.Name = "EggTag"
                    bill.AlwaysOnTop = true
                    bill.Size = UDim2.new(0, 80, 0, 25)
                    bill.Parent = egg
                    local txt = Instance.new("TextLabel")
                    txt.Text = egg.Name
                    txt.Font = Enum.Font.GothamBold
                    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Parent = bill
                end)
            end
        end
    end
end)

-- ⚔️ ตีไว
UIS.InputBegan:Connect(function(input)
    if not Settings.FastAttack then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        task.spawn(function()
            while Settings.FastAttack and UIS:IsMouseButtonDown(Enum.UserInputType.MouseButton1) do
                task.wait(0.05)
                local tool = Character and Character:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function() tool:Activate() end)
                end
            end
        end)
    end
end)

-- 🛡️ ไม่กระเด็น
RunService.Heartbeat:Connect(function()
    if not Settings.NoKnockback or not RootPart then return end
    pcall(function()
        RootPart.Velocity = Vector3.new(RootPart.Velocity.X, math.min(RootPart.Velocity.Y, 100), RootPart.Velocity.Z)
    end)
end)

-- 🌐 ย้ายเซิร์ฟเวอร์
task.spawn(function()
    while task.wait(15) and Settings.IsRunning do
        if Settings.ServerHop then
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        end
    end
end)

print("✅ THE CRAFT HUB — โหลดเสร็จ!")
StatusLabel.Text = Lang[Settings.Language].Ready
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
