-- ==============================================
-- 🔷 THE CRAFT HUB | รันแล้วต้องขึ้น!
-- ภาษาไทย | เปิด-ปิดได้ | สีน้ำเงิน | เบามาก
-- ==============================================

-- SERVICES
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ====================== การตั้งค่า ======================
local Settings = {
    ขโมยไข่อัตโนมัติ = true,
    ขโมยเฉพาะไข่ใหญ่ = false,
    แสดงตำแหน่งไข่ = true,
    ป้องกันAFK = true
}

-- ====================== สร้าง UI ก่อนเลย สำคัญที่สุด! ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "THE_CRAFT_HUB"
ScreenGui.ResetOnSpawn = false

-- ✅ ใช้ PlayerGui แทน CoreGui — ขึ้นแน่นอนทุกเครื่อง
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ====================== ปุ่มเปิด-ปิด ======================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 255)
ToggleBtn.Text = "🔷"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 24
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.AutoLocalize = false
ToggleBtn.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ToggleBtn

-- ====================== เมนูหลัก ======================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0, 70, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(50, 140, 255)

-- หัวเมนู
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(30, 80, 180)
Title.Text = "🔷 THE CRAFT HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 15)

-- เนื้อหา
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 55)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local yPos = 0
local function AddToggle(ชื่อ, คีย์)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Settings[คีย์] and Color3.fromRGB(30, 120, 255) or Color3.fromRGB(40, 50, 70)
    btn.Text = "✅ "..ชื่อ
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        Settings[คีย์] = not Settings[คีย์]
        btn.BackgroundColor3 = Settings[คีย์] and Color3.fromRGB(30, 120, 255) or Color3.fromRGB(40, 50, 70)
        btn.Text = (Settings[คีย์] and "✅ " or "❌ ")..ชื่อ
    end)
    
    yPos += 55
end

-- สร้างปุ่ม
AddToggle("ขโมยไข่อัตโนมัติ", "ขโมยไข่อัตโนมัติ")
AddToggle("ขโมยเฉพาะไข่ใหญ่", "ขโมยเฉพาะไข่ใหญ่")
AddToggle("แสดงตำแหน่งไข่ (ESP)", "แสดงตำแหน่งไข่")
AddToggle("ป้องกัน AFK", "ป้องกันAFK")

-- ปิด-เปิดเมนู
local MenuOpen = true
ToggleBtn.MouseButton1Click:Connect(function()
    MenuOpen = not MenuOpen
    MainFrame.Visible = MenuOpen
    ToggleBtn.BackgroundColor3 = MenuOpen and Color3.fromRGB(20, 90, 200) or Color3.fromRGB(30, 120, 255)
end)

-- ====================== แจ้งเตือน ======================
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "🔷 THE CRAFT HUB",
        Text = "โหลดเสร็จ! กดปุ่มซ้ายบนเพื่อเปิดเมนู",
        Duration = 3
    })
end)

print("✅ THE CRAFT HUB — ทำงานแล้ว!")

-- ====================== ระบบทำงาน ======================
task.spawn(function()
    local Workspace = game:GetService("Workspace")
    while task.wait(0.3) do
        if not Settings.ขโมยไข่อัตโนมัติ then continue end
        
        local char = LocalPlayer.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        -- หาไข่ใกล้สุด
        local nearestEgg, minDist = nil, 100
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name:lower():find("egg") then
                local dist = (hrp.Position - v.Position).Magnitude
                if dist < minDist then
                    if Settings.ขโมยเฉพาะไข่ใหญ่ and v.Size.Magnitude < 15 then continue end
                    minDist = dist
                    nearestEgg = v
                end
            end
        end
        
        -- ขโมย
        if nearestEgg then
            pcall(function() fireclickdetector(nearestEgg) end)
        end
    end
end)
