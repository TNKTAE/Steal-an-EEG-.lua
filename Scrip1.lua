-- ==============================================
-- 🔷 THE CRAFT HUB | แก้จุดค้าง (FORCE DISPLAY)
-- ==============================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- ==============================================
-- ⚙️ การตั้งค่า & ธีม
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
-- 🛠️ ฟังก์ชันดึง Character แบบไม่ค้าง
-- ==============================================
local function GetHRP()
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
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
-- 🥚 ค้นหาไข่ & ขโมย
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
            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
            if pgui then pgui:SetAttribute("AntiAFK", os.time()) end
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
-- 🎨 สร้าง UI แบบตรงไปตรงมา (Direct Parent)
-- ==============================================
local function BuildUI()
    -- ดึง PlayerGui โดยตรง
    local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    if not PlayerGui then return end

    -- ลบอันเก่าทิ้งก่อน
    if PlayerGui:FindFirstChild("THE_CRAFT_HUB") then
        PlayerGui["THE_CRAFT_HUB"]:Destroy()
    end
    if game:GetService("CoreGui"):FindFirstChild("THE_CRAFT_HUB") then
        game:GetService("CoreGui")["THE_CRAFT_HUB"]:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "THE_CRAFT_HUB"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Enabled = true
    ScreenGui.DisplayOrder = 99999
    
    -- ลองใส่ CoreGui ก่อน ถ้าไม่ได้ให้ใส่ PlayerGui ทันที
    local success = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not success or not ScreenGui.Parent then
        ScreenGui.Parent = PlayerGui
    end

    -- ปุ่มเปิด-ปิด (โลโก้ 🔷)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleButton"
    ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
    ToggleBtn.Position = UDim2.new(0, 15, 0, 15)
    ToggleBtn.BackgroundColor3 = Theme.หลัก
    ToggleBtn.Text = "🔷"
    ToggleBtn.TextColor3 = Color3.new(1,1,1)
    ToggleBtn.TextSize = 26
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Active = true
    ToggleBtn.Visible = true
    ToggleBtn.ZIndex = 100
    ToggleBtn.Parent = ScreenGui
    
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)
    local btnStroke = Instance.new("UIStroke", ToggleBtn)
    btnStroke.Color = Theme.ขอบ
    btnStroke.Thickness = 2

    -- ตัวเมนูหลัก
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainMenu"
    MainFrame.Size = UDim2.new(0, 320, 0, 460)
    MainFrame.Position = UDim2.new(0, 80, 0, 15)
    MainFrame.BackgroundColor3 = Theme.พื้นหลัง
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = true
    MainFrame.ZIndex = 10
    MainFrame.Parent = ScreenGui
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
    local frameStroke = Instance.new("UIStroke", MainFrame)
    frameStroke.Color = Theme.ขอบ
    frameStroke.Thickness = 1.5

    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Theme.แถบหัว
    Header.ZIndex = 11
    Header.Parent = MainFrame
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🔷 THE CRAFT HUB"
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 12
    Title.Parent = Header

    -- Scrolling Area
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, 0, 1, -60)
    Content.Position = UDim2.new(0, 0, 0, 55)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 4
    Content.ScrollBarColor3 = Theme.หลัก
    Content.CanvasSize = UDim2.new(0, 0, 0, 520)
    Content.ZIndex = 11
    Content.Parent = MainFrame

    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 6)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIList.Parent = Content

    -- สร้าง Toggle Switch
    local function AddToggle(name, settingKey)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(0, 290, 0, 40)
        Container.BackgroundColor3 = Theme.แถบหัว
        Container.ZIndex = 12
        Container.Parent = Content
        Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Theme.ข้อความ
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.ZIndex = 13
        Label.Parent = Container

        local Switch = Instance.new("TextButton")
        Switch.Size = UDim2.new(0, 46, 0, 22)
        Switch.Position = UDim2.new(1, -54, 0.5, -11)
        Switch.BackgroundColor3 = Settings[settingKey] and Theme.หลัก or Theme.ปิดการใช้งาน
        Switch.Text = ""
        Switch.ZIndex = 13
        Switch.Parent = Container
        Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 6)

        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 16, 0, 16)
        Knob.Position = Settings[settingKey] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        Knob.BackgroundColor3 = Color3.new(1,1,1)
        Knob.ZIndex = 14
        Knob.Parent = Switch
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

        Switch.MouseButton1Click:Connect(function()
            Settings[settingKey] = not Settings[settingKey]
            Switch.BackgroundColor3 = Settings[settingKey] and Theme.หลัก or Theme.ปิดการใช้งาน
            Knob.Position = Settings[settingKey] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        end)
    end

    -- เพิ่มรายการสวิตช์
    AddToggle("🥚 ขโมยไข่อัตโนมัติ", "ขโมยไข่อัตโนมัติ")
    AddToggle("📦 ขโมยเฉพาะไข่ขนาดใหญ่", "ขโมยเฉพาะไข่ใหญ่")
    AddToggle("👁️ แสดงตำแหน่งไข่ (ESP)", "แสดงตำแหน่งไข่")
    AddToggle("⚔️ สวมอุปกรณ์ที่ดีที่สุด", "สวมอุปกรณ์ที่ดีที่สุด")
    AddToggle("🏠 วางไข่อัตโนมัติ", "วางไข่อัตโนมัติ")
    AddToggle("🔥 ฟิวส์ไข่อัตโนมัติ", "ฟิวส์ไข่อัตโนมัติ")
    AddToggle("💰 ขายไข่อัตโนมัติ", "ขายไข่อัตโนมัติ")
    AddToggle("🎁 รับรางวัลอัตโนมัติ", "รับรางวัลอัตโนมัติ")
    AddToggle("🛡️ ป้องกันการหลุด AFK", "ป้องกันAFK")
    AddToggle("🌐 เปลี่ยนเซิร์ฟเวอร์อัตโนมัติ", "เปลี่ยนเซิร์ฟเวอร์อัตโนมัติ")

    -- เปิด / ปิด เมนู
    ToggleBtn.MouseButton1Click:Connect(function()
        MenuOpen = not MenuOpen
        MainFrame.Visible = MenuOpen
    end)
end

-- ==============================================
-- 🚀 รันระบบทันที (ไม่ต้องรอ Character)
-- ==============================================
BuildUI()

task.spawn(AntiAFK)
task.spawn(ESP)

task.spawn(function()
    while task.wait(0.15) do
        if Settings.ขโมยไข่อัตโนมัติ then
            local eggs = FindAllEggs()
            if eggs[1] then
                StealEgg(eggs[1])
            end
        end
    end
end)

print("🔷 CRAFT HUB: UI Rendered Successfully!")
