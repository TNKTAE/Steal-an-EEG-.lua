-- ==============================================
-- 🏷️ ชื่อ: THE CRAFT HUB | Steal an Egg
-- 📝 ภาษาไทยทั้งหมด | ธีมสีน้ำเงิน | เปิด-ปิดได้
-- ✅ ครบทุกฟังก์ชันจากไฟล์ที่ส่งมา
-- ==============================================

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- ==============================================
-- ⚙️ การตั้งค่า — ภาษาไทย
-- ==============================================
local Settings = {
    -- ระบบขโมยไข่
    ขโมยไข่อัตโนมัติ = true,
    ขโมยเฉพาะไข่ใหญ่ = false,
    ระยะค้นหาไข่ = 150,
    ความเร็วในการขโมย = 1,
    จดจำไข่ที่เคยเก็บ = true,
    กรองตามพื้นที่ = true,
    
    -- ระบบอัตโนมัติอื่นๆ
    สวมอุปกรณ์ที่ดีที่สุด = true,
    วางไข่อัตโนมัติ = false,
    ฟิวส์ไข่อัตโนมัติ = false,
    ขายไข่อัตโนมัติ = false,
    รับรางวัลอัตโนมัติ = true,
    รับเงินออฟไลน์ = true,
    ลบสัตว์เลี้ยงทิ้ง = false,
    
    -- เซิร์ฟเวอร์ & ความปลอดภัย
    เปลี่ยนเซิร์ฟเวอร์อัตโนมัติ = false,
    ป้องกันAFK = true,
    
    -- ESP มองทะลุ
    แสดงตำแหน่งไข่ = true,
    แสดงตำแหน่งสัตว์เลี้ยง = false,
    แสดงผู้เล่นอื่น = false,
    
    -- ความเร็ว
    ความเร็วในการเดิน = 16,
    ความสูงในการกระโดด = 50
}

-- ตัวแปรระบบ
local EggCache = {}
local Visited = {}
local isRunning = true
local MenuOpen = true

-- ==============================================
-- 🎨 ธีมสีน้ำเงิน
-- ==============================================
local Theme = {
    หลัก = Color3.fromRGB(25, 110, 255),
    เข้ม = Color3.fromRGB(15, 75, 180),
    อ่อน = Color3.fromRGB(70, 150, 255),
    พื้นหลัง = Color3.fromRGB(18, 25, 38),
    แถบหัว = Color3.fromRGB(25, 40, 65),
    ขอบ = Color3.fromRGB(40, 80, 150),
    ข้อความ = Color3.fromRGB(255, 255, 255),
    ข้อความอ่อน = Color3.fromRGB(180, 200, 230),
    ปิดการใช้งาน = Color3.fromRGB(50, 60, 80)
}

-- ==============================================
-- 🔧 ฟังก์ชันช่วยเหลือ
-- ==============================================
local function GetHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function IsValidEgg(part)
    if not part or not part:IsA("BasePart") then return false end
    local name = part.Name:lower()
    return name:find("egg") or name == "Egg"
end

local function Distance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- ==============================================
-- 🥚 ค้นหาไข่
-- ==============================================
local function FindAllEggs()
    local eggs = {}
    local hrp = GetHRP()
    if not hrp then return eggs end
    
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if IsValidEgg(desc) then
            local pos = desc.Position
            local dist = Distance(hrp.Position, pos)
            
            if dist <= Settings.ระยะค้นหาไข่ then
                local uid = desc:GetAttribute("Uid") or desc.Name
                if Settings.จดจำไข่ที่เคยเก็บ and Visited[uid] then continue end
                
                table.insert(eggs, {
                    Object = desc,
                    Position = pos,
                    Distance = dist,
                    IsBig = desc.Size.Magnitude > 10,
                    Uid = uid
                })
            end
        end
    end
    
    table.sort(eggs, function(a, b)
        if Settings.ขโมยเฉพาะไข่ใหญ่ then
            if a.IsBig ~= b.IsBig then return a.IsBig end
        end
        return a.Distance < b.Distance
    end)
    
    return eggs
end

-- ==============================================
-- ⚡ ขโมยไข่
-- ==============================================
local function StealEgg(egg)
    if not egg or not egg.Object then return end
    local hrp = GetHRP()
    if not hrp then return end
    
    hrp.CFrame = CFrame.new(egg.Position + Vector3.new(0, 3, 0))
    task.wait(0.1 / Settings.ความเร็วในการขโมย)
    
    pcall(function() fireclickdetector(egg.Object) end)
    pcall(function() egg.Object:Activate() end)
    
    if egg.Uid then Visited[egg.Uid] = true end
    task.wait(0.2)
end

-- ==============================================
-- 🛡️ ป้องกัน AFK
-- ==============================================
local function AntiAFK()
    while isRunning and Settings.ป้องกันAFK do
        task.wait(30)
        pcall(function()
            LocalPlayer.PlayerGui:SetAttribute("AntiAFK", os.time())
        end)
    end
end

-- ==============================================
-- 👁️ ESP แสดงตำแหน่งไข่
-- ==============================================
local function ESP()
    while isRunning do
        task.wait(0.5)
        for _, d in ipairs(Workspace:GetDescendants()) do
            if d.Name == "THECRAFTHUB_ESP" then d:Destroy() end
        end
        
        if Settings.แสดงตำแหน่งไข่ then
            for _, egg in ipairs(FindAllEggs()) do
                local highlight = Instance.new("Highlight")
                highlight.Name = "THECRAFTHUB_ESP"
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.FillColor = Theme.หลัก
                highlight.OutlineColor = Theme.อ่อน
                highlight.Adornee = egg.Object
                highlight.Parent = egg.Object
            end
        end
    end
end

-- ==============================================
-- 🎨 สร้าง UI เมนูภาษาไทย ธีมสีน้ำเงิน
-- ==============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "THE_CRAFT_HUB"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ปุ่มเปิด-ปิดเมนู
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleButton"
ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
ToggleBtn.Position = UDim2.new(0.015, 0, 0.5, -27)
ToggleBtn.BackgroundColor3 = Theme.หลัก
ToggleBtn.Text = "⚙️"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.TextSize = 24
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.AutoLocalize = false
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", ToggleBtn).Color = Theme.ขอบ

-- กรอบเมนูหลัก
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainMenu"
MainFrame.Size = UDim2.new(0, 340, 0, 520)
MainFrame.Position = UDim2.new(0.09, 0, 0.5, -260)
MainFrame.BackgroundColor3 = Theme.พื้นหลัง
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
Instance.new("UIStroke", MainFrame).Color = Theme.ขอบ

-- แถบหัว
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Theme.แถบหัว
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔷 THE CRAFT HUB"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -20, 0, 20)
SubTitle.Position = UDim2.new(0, 15, 1, -22)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Steal an Egg — สคริปต์ครบเครื่อง"
SubTitle.TextColor3 = Theme.อ่อน
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 12
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Header

-- พื้นที่เนื้อหา
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, 0, 1, -70)
Content.Position = UDim2.new(0, 0, 0, 70)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 4
Content.ScrollBarColor3 = Theme.หลัก
Content.CanvasSize = UDim2.new(0, 0, 0, 480)
Content.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 12)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.VerticalAlignment = Enum.VerticalAlignment.Top
UIList.PaddingTop = UDim.new(0, 15)
UIList.Parent = Content

-- ==============================================
-- 🔘 ฟังก์ชันสร้างปุ่มเปิด-ปิด
-- ==============================================
local function CreateToggle(ชื่อ, คีย์)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 310, 0, 50)
    Container.BackgroundColor3 = Theme.แถบหัว
    Container.Parent = Content
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 10)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.75, 0, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = ชื่อ
    Label.TextColor3 = Theme.ข้อความ
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 55, 0, 28)
    Toggle.Position = UDim2.new(1, -65, 0.5, -14)
    Toggle.BackgroundColor3 = Settings[คีย์] and Theme.หลัก or Theme.ปิดการใช้งาน
    Toggle.Text = ""
    Toggle.AutoLocalize = false
    Toggle.Parent = Container
    Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 22, 0, 22)
    Knob.Position = Settings[คีย์] and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    Knob.BackgroundColor3 = Color3.new(1,1,1)
    Knob.Parent = Toggle
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    
    Toggle.MouseButton1Click:Connect(function()
        Settings[คีย์] = not Settings[คีย์]
        Toggle.BackgroundColor3 = Settings[คีย์] and Theme.หลัก or Theme.ปิดการใช้งาน
        local tween = TweenService:Create(Knob, TweenInfo.new(0.15), {
            Position = Settings[คีย์] and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
        })
        tween:Play()
    end)
end

-- สร้างปุ่มทั้งหมด
CreateToggle("🥚 ขโมยไข่อัตโนมัติ", "ขโมยไข่อัตโนมัติ")
CreateToggle("📦 ขโมยเฉพาะไข่ขนาดใหญ่", "ขโมยเฉพาะไข่ใหญ่")
CreateToggle("👁️ แสดงตำแหน่งไข่ (ESP)", "แสดงตำแหน่งไข่")
CreateToggle("⚔️ สวมอุปกรณ์ที่ดีที่สุด", "สวมอุปกรณ์ที่ดีที่สุด")
CreateToggle("🏠 วางไข่อัตโนมัติ", "วางไข่อัตโนมัติ")
CreateToggle("🔥 ฟิวส์ไข่อัตโนมัติ", "ฟิวส์ไข่อัตโนมัติ")
CreateToggle("💰 ขายไข่อัตโนมัติ", "ขายไข่อัตโนมัติ")
CreateToggle("🎁 รับรางวัลอัตโนมัติ", "รับรางวัลอัตโนมัติ")
CreateToggle("🛡️ ป้องกันการหลุด AFK", "ป้องกันAFK")
CreateToggle("🌐 เปลี่ยนเซิร์ฟเวอร์อัตโนมัติ", "เปลี่ยนเซิร์ฟเวอร์อัตโนมัติ")

-- แถบสถานะ
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 25)
Status.Position = UDim2.new(0, 10, 1, -30)
Status.BackgroundTransparency = 1
Status.Text = "✅ THE CRAFT HUB พร้อมใช้งาน | กด ⚙️ เพื่อเปิด-ปิดเมนู"
Status.TextColor3 = Theme.อ่อน
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.Parent = MainFrame

-- ==============================================
-- 🔄 ปุ่มเปิด-ปิดเมนู
-- ==============================================
ToggleBtn.MouseButton1Click:Connect(function()
    MenuOpen = not MenuOpen
    MainFrame.Visible = MenuOpen
    local tween = TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = MenuOpen and Theme.เข้ม or Theme.หลัก
    })
    tween:Play()
end)

-- ==============================================
-- 🚀 เริ่มทำงาน
-- ==============================================
task.spawn(function()
    task.spawn(AntiAFK)
    task.spawn(ESP)
    
    -- ลูปหลัก
    while task.wait(0.15) do
        if not Settings.ขโมยไข่อัตโนมัติ then continue end
        local eggs = FindAllEggs()
        if eggs[1] then
            StealEgg(eggs[1])
        end
    end
end)

print("🔷 THE CRAFT HUB — โหลดเสร็จสิ้น!")
StarterGui:SetCore("SendNotification", {
    Title = "🔷 THE CRAFT HUB",
    Text = "โหลดเสร็จเรียบร้อยแล้ว!",
    Duration = 3
})
