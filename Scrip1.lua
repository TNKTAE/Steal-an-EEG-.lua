--[[
    📦 THE CRAFT HUB — Script สำหรับเกม Roblox
    🎨 ธีม: น้ำเงินเข้ม + ดำ เท่ๆ คล้ายรูปตัวอย่าง
    🌐 ภาษา: ไทย (เปลี่ยนเป็นอังกฤษได้)
    ⚠️ ใช้สำหรับเขียนเรียนรู้ — ใช้ในเกมจริงอาจผิดกฎและถูกแบน
]]

-- ====================== การตั้งค่าหลัก ======================
local Settings = {
    Language = "TH", -- "TH" = ไทย, "EN" = อังกฤษ
    Speed = 50, -- ความเร็วเริ่มต้น สูงสุด 2000
    JumpPower = 50, -- ความสูงกระโดดเริ่มต้น
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
    SelectedZone = "ทั้งหมด"
}

-- 📖 คำแปลภาษา
local Lang = {
    TH = {
        Title = "THE CRAFT HUB",
        Main = "หลัก", Visuals = "ภาพ", Event = "อีเว้นท์", Movement = "การเคลื่อนไหว",
        Combat = "ต่อสู้", Server = "เซิร์ฟเวอร์", Settings = "ตั้งค่า",
        AutoTree = "ตีต้นไม้อัตโนมัติ (ชื่อ Small)",
        StealMonsterParasite = "ขโมยไข่ MonsterParasiteVisual",
        TreadmillSpeed = "สเกลู้วิ่ง AdminTreadmill",
        StealFXEgg = "ขโมยไข่ FX (AreaEggSlotsClient)",
        SeeThroughEgg = "มองทะลุไข่ (แสดงชื่อเดียวถ้าซ้ำ)",
        SeeThroughPlayer = "มองทะลุผู้เล่น",
        AutoStealEgg = "ขโมยไข่อัตโนมัติ + กลับฐาน",
        Speed = "ความเร็ว (สูงสุด 2000)",
        PreventEggDrop = "กันไข่หลุด + กด E อัตโนมัติ",
        FastPickup = "เก็บไข่ไว ไม่ต้องกดค้าง",
        JumpPower = "ความสูงกระโดด",
        NoLimitJump = "กระโดดไม่จำกัด",
        ZigZag = "ซิกแซกกลับฐานตอนขโมย",
        FastAttack = "ตีไว กดรัวได้",
        NoKnockback = "ไม่กระเด็น",
        ServerHop = "ย้ายเซิร์ฟเวอร์",
        SelectZone = "เลือกโซน",
        Language = "ภาษา",
        Toggle = "เปิด/ปิด",
        Enabled = "เปิดใช้งาน",
        Disabled = "ปิดใช้งาน",
        Refresh = "รีเฟรชโซน"
    },
    EN = {
        Title = "THE CRAFT HUB",
        Main = "Main", Visuals = "Visuals", Event = "Event", Movement = "Movement",
        Combat = "Combat", Server = "Server", Settings = "Settings",
        AutoTree = "Auto Hit Tree (Name: Small)",
        StealMonsterParasite = "Steal MonsterParasiteVisual Egg",
        TreadmillSpeed = "Admin Treadmill Speed",
        StealFXEgg = "Steal FX Egg (AreaEggSlotsClient)",
        SeeThroughEgg = "See Through Eggs (Unique Only)",
        SeeThroughPlayer = "See Through Players",
        AutoStealEgg = "Auto Steal Egg + Return Base",
        Speed = "Speed (Max 2000)",
        PreventEggDrop = "Prevent Egg Drop + Auto Press E",
        FastPickup = "Fast Pickup No Hold",
        JumpPower = "Jump Power",
        NoLimitJump = "No Limit Jump",
        ZigZag = "ZigZag Return",
        FastAttack = "Fast Attack",
        NoKnockback = "No Knockback",
        ServerHop = "Server Hop",
        SelectZone = "Select Zone",
        Language = "Language",
        Toggle = "Toggle",
        Enabled = "Enabled",
        Disabled = "Disabled",
        Refresh = "Refresh Zones"
    }
}

-- ====================== เริ่มต้นบริการ ======================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character, Humanoid, RootPart

-- อัปเดตตัวละคร
local function UpdateCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end
UpdateCharacter()
LocalPlayer.CharacterAdded:Connect(UpdateCharacter)

-- ====================== 🎨 สร้าง UI ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- พื้นหลังหลัก
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 520) -- ยาว-เล็ก ตามขอ
MainFrame.Position = UDim2.new(0.02, 0, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 15, 25) -- ดำเข้ม
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(30, 100, 255) -- ขอบน้ำเงิน
MainFrame.CornerRadius = UDim.new(0, 8)
MainFrame.Parent = ScreenGui

-- หัวข้อ
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 60, 180) -- น้ำเงิน
TitleBar.CornerRadius = UDim.new(0, 8)
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Text = Lang[Settings.Language].Title
TitleText.Font = Enum.Font.GothamBold
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- ปุ่มปิดสคริปต์
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 7)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    Settings = nil
end)

-- 📋 แถบหมวดหมู่
local CategoryFrame = Instance.new("Frame")
CategoryFrame.Size = UDim2.new(1, 0, 0, 35)
CategoryFrame.Position = UDim2.new(0, 0, 0, 50)
CategoryFrame.BackgroundTransparency = 1
CategoryFrame.Parent = MainFrame

local Categories = {Lang.TH.Main, Lang.TH.Event, Lang.TH.Visuals, Lang.TH.Movement, Lang.TH.Combat, Lang.TH.Server, Lang.TH.Settings}
local Pages = {}
local CurrentPage = 1

for i, Cat in ipairs(Categories) do
    local Btn = Instance.new("TextButton")
    Btn.Text = Cat
    Btn.Font = Enum.Font.Gotham
    Btn.TextColor3 = i == 1 and Color3.fromRGB(80, 180, 255) or Color3.fromRGB(150, 150, 150)
    Btn.Size = UDim2.new(1/#Categories, -4, 0.9, 0)
    Btn.Position = UDim2.new((i-1)/#Categories, 2, 0, 2)
    Btn.BackgroundTransparency = 1
    Btn.Parent = CategoryFrame
    Btn.MouseButton1Click:Connect(function()
        CurrentPage = i
        for idx, b in ipairs(CategoryFrame:GetChildren()) do
            if b:IsA("TextButton") then
                b.TextColor3 = idx == i and Color3.fromRGB(80, 180, 255) or Color3.fromRGB(150, 150, 150)
            end
        end
        for p, page in ipairs(Pages) do
            page.Visible = (p == i)
        end
    end)
end

-- 📜 พื้นที่เนื้อหาแต่ละหน้า
local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Size = UDim2.new(1, -8, 1, -95)
ContentContainer.Position = UDim2.new(0, 4, 0, 90)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ScrollBarThickness = 4
ContentContainer.ScrollBarColor3 = Color3.fromRGB(40, 120, 255)
ContentContainer.Parent = MainFrame

for i = 1, #Categories do
    local Page = Instance.new("Frame")
    Page.Size = UDim2.new(1, 0, 0, 1000)
    Page.BackgroundTransparency = 1
    Page.Visible = (i == 1)
    Page.Parent = ContentContainer
    Pages[i] = Page
end

-- 🧩 ฟังก์ชันสร้างปุ่มเปิด/ปิด
local function AddToggle(pageIndex, nameKey, settingKey, posY)
    local Page = Pages[pageIndex]
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 38)
    Container.Position = UDim2.new(0, 5, 0, posY)
    Container.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
    Container.CornerRadius = UDim.new(0, 6)
    Container.Parent = Page

    local Label = Instance.new("TextLabel")
    Label.Text = Lang[Settings.Language][nameKey]
    Label.Font = Enum.Font.Gotham
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Container

    local Toggle = Instance.new("TextButton")
    Toggle.Text = Settings[settingKey] and "✓" or ""
    Toggle.Size = UDim2.new(0, 30, 0, 24)
    Toggle.Position = UDim2.new(1, -38, 0.5, -12)
    Toggle.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(60, 60, 80)
    Toggle.CornerRadius = UDim.new(0, 12)
    Toggle.Parent = Container

    Toggle.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        Toggle.Text = Settings[settingKey] and "✓" or ""
        Toggle.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(60, 60, 80)
    end)

    return posY + 43
end

-- 🧩 ฟังก์ชันสร้างสไลด์
local function AddSlider(pageIndex, nameKey, settingKey, min, max, posY)
    local Page = Pages[pageIndex]
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 50)
    Container.Position = UDim2.new(0, 5, 0, posY)
    Container.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
    Container.CornerRadius = UDim.new(0, 6)
    Container.Parent = Page

    local Label = Instance.new("TextLabel")
    Label.Text = Lang[Settings.Language][nameKey] .. ": " .. Settings[settingKey]
    Label.Font = Enum.Font.Gotham
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.Size = UDim2.new(1, -10, 0, 22)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Name = "Label"
    Label.Parent = Container

    local BarBg = Instance.new("Frame")
    BarBg.Size = UDim2.new(1, -20, 0, 8)
    BarBg.Position = UDim2.new(0, 10, 0, 32)
    BarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    BarBg.CornerRadius = UDim.new(0, 4)
    BarBg.Parent = Container

    local BarFill = Instance.new("Frame")
    BarFill.Size = UDim2.new((Settings[settingKey]-min)/(max-min), 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(40, 120, 255)
    BarFill.CornerRadius = UDim.new(0, 4)
    BarFill.Parent = BarBg

    local DragBtn = Instance.new("TextButton")
    DragBtn.Text = ""
    DragBtn.Size = UDim2.new(0, 16, 0, 16)
    DragBtn.Position = UDim2.new((Settings[settingKey]-min)/(max-min), -8, 0.5, -8)
    DragBtn.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
    DragBtn.CornerRadius = UDim.new(0, 8)
    DragBtn.Parent = BarFill

    local dragging = false
    DragBtn.MouseButton1Down:Connect(function() dragging = true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    BarBg.MouseMoved:Connect(function(x)
        if not dragging then return end
        local absPos = BarBg.AbsolutePosition
        local size = BarBg.AbsoluteSize.X
        local percent = math.clamp((x - absPos.X)/size, 0, 1)
        Settings[settingKey] = math.floor(min + (max-min)*percent)
        Label.Text = Lang[Settings.Language][nameKey] .. ": " .. Settings[settingKey]
        BarFill.Size = UDim2.new(percent, 0, 1, 0)
        DragBtn.Position = UDim2.new(1, -8, 0.5, -8)
    end)

    return posY + 55
end

-- ====================== 📱 เติมเนื้อหาในแต่ละหน้า ======================
local y = 5
-- === หน้าหลัก ===
y = AddToggle(1, "AutoTree", "AutoTreeEnabled", y)
y = AddToggle(1, "StealMonsterParasite", "AutoStealMonsterParasite", y)
y = AddToggle(1, "TreadmillSpeed", "AdminTreadmillSpeed", y)
y = AddToggle(1, "StealFXEgg", "StealFXEgg", y)

-- === หน้าภาพ ===
y = 5
y = AddToggle(2, "SeeThroughEgg", "SeeThroughEgg", y)
y = AddToggle(2, "SeeThroughPlayer", "SeeThroughPlayer", y)

-- === หน้าเคลื่อนไหว ===
y = 5
y = AddSlider(3, "Speed", "Speed", 16, 2000, y)
y = AddToggle(3, "AutoStealEgg", "AutoStealEgg", y)
y = AddToggle(3, "PreventEggDrop", "PreventEggDrop", y)
y = AddToggle(3, "FastPickup", "FastPickup", y)
y = AddSlider(3, "JumpPower", "JumpPower", 10, 200, y)
y = AddToggle(3, "NoLimitJump", "NoLimitJump", y)
y = AddToggle(3, "ZigZag", "ZigZagReturn", y)

-- === หน้าต่อสู้ ===
y = 5
y = AddToggle(4, "FastAttack", "FastAttack", y)
y = AddToggle(4, "NoKnockback", "NoKnockback", y)

-- === หน้าเซิร์ฟเวอร์ ===
y = 5
y = AddToggle(5, "ServerHop", "ServerHop", y)

-- === หน้าตั้งค่า ===
y = 5
y = AddToggle(6, "Language", "Language", y)

-- ====================== ⚙️ ฟังก์ชันทำงานจริง ======================
-- 🌳 ตีต้นไม้อัตโนมัติ (ชื่อเริ่มต้นด้วย Small)
local lastTreeHit = 0
RunService.Heartbeat:Connect(function()
    if not Settings.AutoTreeEnabled or not RootPart then return end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name:sub(1,5) == "Small" then
            local dist = (RootPart.Position - obj.Position).Magnitude
            if dist < 25 then
                os.clock()
                if os.clock() - lastTreeHit > 0.3 then
                    Humanoid:MoveTo(obj.Position)
                    task.wait(0.2)
                    -- จำลองการโจมตี
                    LocalPlayer.Character.Humanoid:TakeDamage(0)
                    fireclickdetector(obj:FindFirstChildOfClass("ClickDetector"))
                    lastTreeHit = os.clock()
                end
            end
        end
    end
end)

-- 🥚 ขโมยไข่ MonsterParasiteVisual
RunService.Heartbeat:Connect(function()
    if not Settings.AutoStealMonsterParasite or not RootPart then return end
    for _, egg in ipairs(workspace:GetDescendants()) do
        if egg.Name == "MonsterParasiteVisual" and egg:IsA("BasePart") then
            local dist = (RootPart.Position - egg.Position).Magnitude
            if dist < 15 then
                fireclickdetector(egg:FindFirstChildOfClass("ClickDetector"))
            end
        end
    end
end)

-- 🏃 ปรับความเร็ว
RunService.Heartbeat:Connect(function()
    if Humanoid then
        Humanoid.WalkSpeed = Settings.Speed
        Humanoid.JumpPower = Settings.JumpPower
        if Settings.NoLimitJump then Humanoid.JumpHeight = 1000 end
    end
end)

-- 👁️ มองทะลุผู้เล่น
RunService.RenderStepped:Connect(function()
    if Settings.SeeThroughPlayer then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                for _, part in ipairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0.5
                        part.ZIndex = 2
                    end
                end
            end
        end
    end
end)

-- 🥚 มองทะลุไข่ + แสดงชื่อเดียวถ้าซ้ำ
local seenEggNames = {}
RunService.RenderStepped:Connect(function()
    if not Settings.SeeThroughEgg then seenEggNames = {} return end
    local eggFolder = workspace:FindFirstChild("AreaEggSlotsClient")
    if not eggFolder then return end
    seenEggNames = {}
    for _, egg in ipairs(eggFolder:GetDescendants()) do
        if egg:IsA("BasePart") and egg.Name == "FX" then
            egg.Transparency = 0.3
            if not seenEggNames[egg.Name] then
                seenEggNames[egg.Name] = true
                -- แสดงชื่อครั้งเดียว
                local bill = Instance.new("BillboardGui")
                bill.AlwaysOnTop = true
                bill.Size = UDim2.new(0, 80, 0, 20)
                local txt = Instance.new("TextLabel")
                txt.Text = egg.Name
                txt.Size = UDim2.new(1,0,1,0)
                txt.BackgroundTransparency = 1
                txt.TextColor3 = Color3.fromRGB(255,255,255)
                txt.Font = Enum.Font.Gotham
                txt.Parent = bill
                bill.Parent = egg
            end
        end
    end
end)

-- ⚔️ ตีไว
UIS.InputBegan:Connect(function(input)
    if Settings.FastAttack and input.UserInputType == Enum.UserInputType.MouseButton1 then
        while Settings.FastAttack do
            task.wait(0.05)
            local tool = Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
            if not UIS:IsMouseButtonDown(Enum.UserInputType.MouseButton1) then break end
        end
    end
end)

-- 🛡️ ไม่กระเด็น
RunService.Heartbeat:Connect(function()
    if Settings.NoKnockback and RootPart then
        RootPart.Velocity = Vector3.new(RootPart.Velocity.X, math.min(RootPart.Velocity.Y, 50), RootPart.Velocity.Z)
    end
end)

-- 🌐 ย้ายเซิร์ฟเวอร์
if Settings.ServerHop then
    task.spawn(function()
        while Settings.ServerHop do
            task.wait(10)
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end
    end)
end

print("✅ THE CRAFT HUB — โหลดเสร็จเรียบร้อย!")
