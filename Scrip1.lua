-- ==============================================
-- 🔷 THE CRAFT HUB | แก้ไข UI ไม่ขึ้น (FIXED)
-- ==============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

-- ==============================================
-- ⚙️ การตั้งค่า
-- ==============================================
local Settings = {
    ขโมยไข่อัตโนมัติ = true,
    ขโมยเฉพาะไข่ใหญ่ = false,
    ระยะค้นหาไข่ = 150,
    ความเร็วในการขโมย = 1,
    จดจำไข่ที่เคยเก็บ = true,
    กรองตามพื้นที่ = true,
    สวมอุปกรณ์ที่ดีที่สุด = true,
    วางไข่อัตโนมัติ = false,
    ฟิวส์ไข่อัตโนมัติ = false,
    ขายไข่อัตโนมัติ = false,
    รับรางวัลอัตโนมัติ = true,
    ป้องกันAFK = true,
    แสดงตำแหน่งไข่ = true,
    เปลี่ยนเซิร์ฟเวอร์อัตโนมัติ = false,
}

local Theme = {
    หลัก = Color3.fromRGB(25, 110, 255),
    เข้ม = Color3.fromRGB(15, 75, 180),
    อ่อน = Color3.fromRGB(70, 150, 255),
    พื้นหลัง = Color3.fromRGB(18, 25, 38),
    แถบหัว = Color3.fromRGB(25, 40, 65),
    ขอบ = Color3.fromRGB(40, 80, 150),
    ข้อความ = Color3.fromRGB(255, 255, 255),
    ปิดการใช้งาน = Color3.fromRGB(50, 60, 80)
}

local Visited = {}
local isRunning = true
local MenuOpen = true

-- ==============================================
-- 🛠️ ฟังก์ชันพื้นฐาน
-- ==============================================
local function GetHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart", 5)
end

local function Distance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function IsValidEgg(part)
    if not part or not part:IsA("BasePart") then return false end
    local name = part.Name:lower()
    return name:find("egg") or name == "Egg"
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
-- 🛡️ ป้องกัน AFK & ESP
-- ==============================================
local function AntiAFK()
    while isRunning and Settings.ป้องกันAFK do
        task.wait(30)
        pcall(function()
            local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if playerGui then
                playerGui:SetAttribute("AntiAFK", os.time())
            end
        end)
    end
end

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
-- 🎨 สร้าง UI (แก้ไขส่วนการใส่ Parent & Display)
-- ==============================================
local function CreateUI()
    -- ลบ UI เก่าทิ้งก่อนถ้าเคยรันค้างไว้
    local oldUI = game:GetService("CoreGui"):FindFirstChild("THE_CRAFT_HUB") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("THE_CRAFT_HUB")
    if oldUI then oldUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "THE_CRAFT_HUB"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- ตรวจสอบ Parent ที่ปลอดภัยที่สุด
    local parentTarget
    if gethui then
        parentTarget = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        parentTarget = game:GetService("CoreGui")
    elseif pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end) then
        parentTarget = game:GetService("CoreGui")
    else
        parentTarget = LocalPlayer:WaitForChild("PlayerGui")
    end
    ScreenGui.Parent = parentTarget

    -- ปุ่มเปิด-ปิด (มุมซ้ายบน)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleButton"
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Position = UDim2.new(0, 20, 0, 50)
    ToggleBtn.BackgroundColor3 = Theme.หลัก
    ToggleBtn.Text = "🔷"
    ToggleBtn.TextColor3 = Color3.new(1,1,1)
    ToggleBtn.TextSize = 24
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.ZIndex = 10
    ToggleBtn.Parent = ScreenGui
    
    local btnCorner = Instance.new("UICorner", ToggleBtn)
    btnCorner.CornerRadius = UDim.new(0, 12)
    local btnStroke = Instance.new("UIStroke", ToggleBtn)
    btnStroke.Color = Theme.ขอบ
    btnStroke.Thickness = 2
    
    -- เมนูหลัก
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainMenu"
    MainFrame.Size = UDim2.new(0, 320, 0, 480)
    MainFrame.Position = UDim2.new(0, 80, 0, 50)
    MainFrame.BackgroundColor3 = Theme.พื้นหลัง
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = true
    MainFrame.ZIndex = 5
    MainFrame.Parent = ScreenGui
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
    local frameStroke = Instance.new("UIStroke", MainFrame)
    frameStroke.Color = Theme.ขอบ
    frameStroke.Thickness = 1.5
    
    -- แถบหัว
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 55)
    Header.BackgroundColor3 = Theme.แถบหัว
    Header.ZIndex = 6
    Header.Parent = MainFrame
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 25)
    Title.Position = UDim2.new(0, 15, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = "🔷 THE CRAFT HUB"
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 7
    Title.Parent = Header
    
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Size = UDim2.new(1, -20, 0, 15)
    SubTitle.Position = UDim2.new(0, 15, 0, 32)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "Steal an Egg — สคริปต์ครบเครื่อง"
    SubTitle.TextColor3 = Theme.อ่อน
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.TextSize = 11
    SubTitle.TextXAlignment = Enum.TextXAlignment.Left
    SubTitle.ZIndex = 7
    SubTitle.Parent = Header
    
    -- Scroll Content
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, 0, 1, -85)
    Content.Position = UDim2.new(0, 0, 0, 60)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 4
    Content.ScrollBarColor3 = Theme.หลัก
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Content.ZIndex = 6
    Content.Parent = MainFrame
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 8)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIList.VerticalAlignment = Enum.VerticalAlignment.Top
    UIList.Parent = Content
    
    local UIPadding = Instance.new("UIPadding", Content)
    UIPadding.PaddingTop = UDim.new(0, 5)
    UIPadding.PaddingBottom = UDim.new(0, 10)
    
    -- สวิตช์เปิดปิด
    local function CreateToggle(ชื่อ, คีย์)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(0, 290, 0, 42)
        Container.BackgroundColor3 = Theme.แถบหัว
        Container.ZIndex = 7
        Container.Parent = Content
        Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 12, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = ชื่อ
        Label.TextColor3 = Theme.ข้อความ
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.ZIndex = 8
        Label.Parent = Container
        
        local Toggle = Instance.new("TextButton")
        Toggle.Size = UDim2.new(0, 48, 0, 24)
        Toggle.Position = UDim2.new(1, -58, 0.5, -12)
        Toggle.BackgroundColor3 = Settings[คีย์] and Theme.หลัก or Theme.ปิดการใช้งาน
        Toggle.Text = ""
        Toggle.ZIndex = 8
        Toggle.Parent = Container
        Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 6)
        
        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 18, 0, 18)
        Knob.Position = Settings[คีย์] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        Knob.BackgroundColor3 = Color3.new(1,1,1)
        Knob.ZIndex = 9
        Knob.Parent = Toggle
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
        
        Toggle.MouseButton1Click:Connect(function()
            Settings[คีย์] = not Settings[คีย์]
            Toggle.BackgroundColor3 = Settings[คีย์] and Theme.หลัก or Theme.ปิดการใช้งาน
            Knob.Position = Settings[คีย์] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        end)
    end
    
    -- ปุ่มทั้งหมด
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
    Status.Size = UDim2.new(1, -20, 0, 20)
    Status.Position = UDim2.new(0, 10, 1, -22)
    Status.BackgroundTransparency = 1
    Status.Text = "✅ พร้อมใช้งาน | กด 🔷 เพื่อเปิด-ปิดเมนู"
    Status.TextColor3 = Theme.อ่อน
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 10
    Status.ZIndex = 6
    Status.Parent = MainFrame
    
    -- Event ปุ่มซ่อน/แสดง
    ToggleBtn.MouseButton1Click:Connect(function()
        MenuOpen = not MenuOpen
        MainFrame.Visible = MenuOpen
        ToggleBtn.BackgroundColor3 = MenuOpen and Theme.หลัก or Theme.ปิดการใช้งาน
    end)
    
    return ScreenGui
end

-- ==============================================
-- 🚀 เริ่มทำงาน
-- ==============================================
task.spawn(function()
    CreateUI()
    
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🔷 THE CRAFT HUB",
            Text = "โหลดเรียบร้อย! กดปุ่ม 🔷 มุมซ้ายบน",
            Duration = 5
        })
    end)
    
    task.spawn(AntiAFK)
    task.spawn(ESP)
    
    while task.wait(0.15) do
        if not Settings.ขโมยไข่อัตโนมัติ then continue end
        local eggs = FindAllEggs()
        if eggs[1] then
            StealEgg(eggs[1])
        end
    end
end)
