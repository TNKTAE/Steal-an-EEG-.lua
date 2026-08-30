-- สร้าง ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "THE_CRAFT_HUB"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- สร้างหน้าต่างหลัก
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 300) -- ขนาดเล็ก
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = UDim2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35) -- ดำอมน้ำเงินเข้ม
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- แถบหัวข้อ
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 45, 65) -- น้ำเงินเข้ม
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "THE CRAFT HUB"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = TopBar

-- ปุ่มปิด/เปิด (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 1, 0)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

-- ปุ่มเปิด/ปิดสคริปต์ (Toggle)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 30, 1, 0)
ToggleBtn.Position = UDim2.new(1, -60, 0, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255) -- สีน้ำเงิน
ToggleBtn.Text = "..."
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Parent = TopBar
ToggleBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled -- เปิด/ปิดทั้งสคริปต์
end)

-- ฟังก์ชันสร้างหมวดหมู่
local function CreateCategory(name, yPos)
    local CategoryBtn = Instance.new("TextButton")
    CategoryBtn.Size = UDim2.new(1, 0, 0, 25)
    CategoryBtn.Position = UDim2.new(0, 0, 0, yPos)
    CategoryBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
    CategoryBtn.Text = name
    CategoryBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CategoryBtn.TextXAlignment = Enum.TextXAlignment.Left
    CategoryBtn.Parent = MainFrame
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 0, 0)
    ContentFrame.Position = UDim2.new(0, 0, 0, yPos + 25)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame
    
    local expanded = true
    CategoryBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        ContentFrame.Visible = expanded
    end)
    
    return ContentFrame
end

-- ฟังก์ชันสร้างปุ่มสลับเปิด/ปิด (Toggle)
local function CreateToggle(parent, title, yPos)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 30)
    ToggleFrame.Position = UDim2.new(0, 5, 0, yPos)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Color3.fromRGB(200, 210, 230)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local ToggleBg = Instance.new("TextButton")
    ToggleBg.Size = UDim2.new(0, 30, 0, 15)
    ToggleBg.Position = UDim2.new(1, -30, 0.5, -7.5)
    ToggleBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleBg.Text = ""
    ToggleBg.Parent = ToggleFrame
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 13, 0, 13)
    Circle.Position = UDim2.new(0, 2, 0.5, -6.5)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.Parent = ToggleBg
    
    local isOn = false
    ToggleBg.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            ToggleBg.BackgroundColor3 = Color3.fromRGB(0, 170, 255) -- สีฟ้า
            Circle.Position = UDim2.new(1, -15, 0.5, -6.5)
            -- ใส่ฟังก์ชันที่ต้องการเปิดตรงนี้
        else
            ToggleBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- สีเทา
            Circle.Position = UDim2.new(0, 2, 0.5, -6.5)
            -- ใส่ฟังก์ชันที่ต้องการปิดตรงนี้
        end
    end)
end

-- สร้างหมวดหมู่และฟังก์ชัน (ตามที่คุณต้องการ)

-- หมวด: อีเว้นต์
local EventCat = CreateCategory("⚡ อีเว้นต์ (Events)", 35)
CreateToggle(EventCat, "ตีต้นไม้ (Small)", 0)
CreateToggle(EventCat, "ขโมยไข่ (MonsterParasiteVisual)", 30)

-- หมวด: ขโมย
local StealCat = CreateCategory("🛒 ขโมย (Steal)", 65)
CreateToggle(StealCat, "ลอยไปขโมยแล้วกลับฐาน (AreaEggSlotsClient)", 0)
CreateToggle(StealCat, "กันไข่หลุด (Auto E)", 30)
CreateToggle(StealCat, "กดเก็บไข่ไว (Auto Hold E)", 60)
CreateToggle(StealCat, "ซิกแซกกลับฐาน", 90)

-- หมวด: ระบบ
local SystemCat = CreateCategory("⚙️ ระบบ (System)", 95)
CreateToggle(SystemCat, "มองทะลุไข่ (Filter)", 0)
CreateToggle(SystemCat, "มองทะลุผู้เล่น (ESP)", 30)
CreateToggle(SystemCat, "ไม่กระเด็น (No Knockback)", 60)

-- หมวด: เคลื่อนไหว
local MoveCat = CreateCategory("🏃 เคลื่อนไหว (Movement)", 125)
CreateToggle(MoveCat, "ความเร็วสูง (ปรับได้ 2000)", 0)
CreateToggle(MoveCat, "กระโดดสูง (ปรับได้)", 30)
CreateToggle(MoveCat, "กระโดดไม่จำกัด", 60)
CreateToggle(MoveCat, "วิ่ง AdminTreadmill", 90)

-- หมวด: อื่นๆ
local MiscCat = CreateCategory("🔧 อื่นๆ (Misc)", 155)
CreateToggle(MiscCat, "ตีไวเมื่อถืออาวุธ", 0)
CreateToggle(MiscCat, "ย้ายเซิฟ", 30)
CreateToggle(MiscCat, "เลือกโซนขโมย (__OBJECTS/Areas)", 60)

-- (หมายเหตุ: โค้ดนี้เป็นเพียงการสร้าง UI เท่านั้น ไม่มีฟังก์ชันโกงภายในเกมผูกอยู่ และจำเป็นต้องใช้ใน Roblox Studio เพื่อทดสอบการแสดงผล)
