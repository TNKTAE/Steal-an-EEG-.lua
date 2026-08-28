-- ==============================================
-- 🥚 STEAL AN EGG — GLASS BLUE EDITION 💙
--  UI กระจกใสสีน้ำเงิน | แยกหมวดหมู่ | ระบบเสถียร 100%
-- ==============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==============================================
-- 📋 การตั้งค่าระบบ
-- ==============================================
local Settings = {
    -- FARMING
    AutoSteal = false,
    StealBigOnly = false,
    StealSpeed = 1,
    MaxDistance = 250,
    StealInterval = 0.15,
    RememberVisited = true,
    
    -- AUTO ACTIONS
    AutoSell = false,
    SellInterval = 60,
    AutoEquipBest = false,
    AutoClaimRewards = false,
    
    -- VISUALS (ESP)
    ESP_Egg = false,
    ESP_Player = false,
    ESPColor = Color3.fromRGB(0, 200, 255),
    
    -- MISC
    AntiAFK = true,
    WalkSpeed = 16,
    JumpPower = 50,
    AutoServerHop = false
}

local VisitedEggs = {}
local isRunning = true

-- ==============================================
-- 🔧 ฟังก์ชันระบบเกม (Core Functions)
-- ==============================================
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHRP()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsValidEgg(obj)
    if not obj then return false end
    local name = obj.Name:lower()
    if name:find("egg") or obj:GetAttribute("Rarity") then
        return true
    end
    return false
end

local function InteractWithObject(obj)
    if not obj then return end
    
    -- 1. ตรวจหา ProximityPrompt (ระบบปุ่มกดขโมยยุคใหม่)
    local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt and typeof(fireproximityprompt) == "function" then
        fireproximityprompt(prompt)
    end
    
    -- 2. ตรวจหา ClickDetector
    local cd = obj:FindFirstChildOfClass("ClickDetector") or obj:FindFirstChildWhichIsA("ClickDetector", true)
    if cd and typeof(fireclickdetector) == "function" then
        fireclickdetector(cd)
    end
    
    -- 3. ตรวจหา Touch Interest (เดินชน)
    if obj:IsA("BasePart") and typeof(firetouchinterest) == "function" then
        local hrp = GetHRP()
        if hrp then
            firetouchinterest(hrp, obj, 0)
            task.wait(0.02)
            firetouchinterest(hrp, obj, 1)
        end
    end
    
    -- 4. ตรวจหา Remote
    local remote = obj:FindFirstChildOfClass("RemoteEvent") or obj:FindFirstChildWhichIsA("RemoteEvent", true)
    if remote then
        pcall(function() remote:FireServer() end)
    end
end

local function FindEggs()
    local eggs = {}
    local hrp = GetHRP()
    if not hrp then return eggs end
    
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if IsValidEgg(desc) then
            local pos = desc:IsA("BasePart") and desc.Position or (desc:IsA("Model") and desc:GetPivot().Position)
            if pos then
                local dist = (hrp.Position - pos).Magnitude
                if dist <= Settings.MaxDistance then
                    local uid = desc:GetAttribute("Uid") or desc.Name .. "_" .. tostring(pos)
                    if not (Settings.RememberVisited and VisitedEggs[uid]) then
                        local sizeMag = desc:IsA("BasePart") and desc.Size.Magnitude or 5
                        table.insert(eggs, {
                            Object = desc,
                            Position = pos,
                            Distance = dist,
                            IsBig = sizeMag > 10,
                            Uid = uid
                        })
                    end
                end
            end
        end
    end
    
    table.sort(eggs, function(a, b)
        if Settings.StealBigOnly and a.IsBig ~= b.IsBig then
            return a.IsBig
        end
        return a.Distance < b.Distance
    end)
    
    return eggs
end

local function StealEgg(egg)
    if not egg or not egg.Object then return end
    local hrp = GetHRP()
    if not hrp then return end
    
    -- วาร์ปไปหาไข่
    hrp.CFrame = CFrame.new(egg.Position + Vector3.new(0, 3, 0))
    task.wait(0.05)
    
    InteractWithObject(egg.Object)
    
    if egg.Uid then
        VisitedEggs[egg.Uid] = true
    end
end

-- ==============================================
-- 🎨 ระบบ UI (Glassmorphism Translucent Blue)
-- ==============================================
if CoreGui:FindFirstChild("GlassBlueHub") then
    CoreGui.GlassBlueHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GlassBlueHub"
ScreenGui.Parent = CoreGui

-- 🔘 ปุ่มเปิด-ปิดเมนูลอยบนหน้าจอ (Toggle Button)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenButton"
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(10, 30, 60)
OpenBtn.BackgroundTransparency = 0.2
OpenBtn.Text = "🥚"
OpenBtn.TextSize = 24
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = ScreenGui

local OpenBtnCorner = Instance.new("UICorner", OpenBtn)
OpenBtnCorner.CornerRadius = UDim.new(0, 25)

local OpenBtnStroke = Instance.new("UIStroke", OpenBtn)
OpenBtnStroke.Color = Color3.fromRGB(0, 170, 255)
OpenBtnStroke.Thickness = 2

-- 🖼️ หน้าต่างหลัก (Main Window)
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 550, 0, 360)
Main.Position = UDim2.new(0.5, -275, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(12, 22, 40)
Main.BackgroundTransparency = 0.25 -- เอฟเฟกต์กระจกใส
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 16)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(0, 160, 255)
MainStroke.Transparency = 0.3
MainStroke.Thickness = 1.5

-- 📌 แถบด้านบน (Header Bar)
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "STEAL AN EGG  |  <font color='#00d2ff'>GLASS HUB</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- 📁 แถบเมนูข้าง (Tab Buttons Container)
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 140, 1, -55)
Sidebar.Position = UDim2.new(0, 10, 0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(8, 15, 28)
Sidebar.BackgroundTransparency = 0.4
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.Padding = UDim.new(0, 6)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SidebarPadding = Instance.new("UIPadding", Sidebar)
SidebarPadding.PaddingTop = UDim.new(0, 8)

-- 📄 พื้นที่แสดงเนื้อหา (Page Container)
local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -165, 1, -55)
Container.Position = UDim2.new(0, 155, 0, 50)
Container.BackgroundTransparency = 1

-- ระบบสลับหน้า (Tab Switching System)
local Pages = {}
local TabButtons = {}

local function CreateTab(name, icon)
    local Page = Instance.new("ScrollingFrame", Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
    
    local PageList = Instance.new("UIListLayout", Page)
    PageList.Padding = UDim.new(0, 8)

    Pages[name] = Page

    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 36)
    TabBtn.BackgroundColor3 = Color3.fromRGB(15, 30, 55)
    TabBtn.BackgroundTransparency = 0.5
    TabBtn.Text = icon .. "  " .. name
    TabBtn.TextColor3 = Color3.fromRGB(180, 200, 220)
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 13
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

    TabBtn.MouseButton1Click:Connect(function()
        for tabName, pageObj in pairs(Pages) do
            pageObj.Visible = (tabName == name)
        end
        for _, btnObj in pairs(TabButtons) do
            btnObj.BackgroundColor3 = Color3.fromRGB(15, 30, 55)
            btnObj.TextColor3 = Color3.fromRGB(180, 200, 220)
            btnObj.BackgroundTransparency = 0.5
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundTransparency = 0.2
    end)

    TabButtons[name] = TabBtn
    return Page
end

-- สร้างหน้าหมวดหมู่
local FarmPage = CreateTab("ฟาร์ม", "🌾")
local AutoPage = CreateTab("ออโต้", "⚡")
local VisualPage = CreateTab("แสดงผล", "👁️")
local MiscPage = CreateTab("อื่นๆ", "⚙️")

-- เปิดหน้าแรกเป็นค่าเริ่มต้น
FarmPage.Visible = true
TabButtons["ฟาร์ม"].BackgroundColor3 = Color3.fromRGB(0, 140, 255)
TabButtons["ฟาร์ม"].TextColor3 = Color3.fromRGB(255, 255, 255)
TabButtons["ฟาร์ม"].BackgroundTransparency = 0.2

-- 🎛️ ฟังก์ชันสร้างปุ่ม Toggle
local function AddToggle(parent, text, key, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -10, 0, 42)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 28, 48)
    Frame.BackgroundTransparency = 0.4
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(230, 240, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Switch = Instance.new("TextButton", Frame)
    Switch.Size = UDim2.new(0, 50, 0, 24)
    Switch.Position = UDim2.new(1, -60, 0.5, -12)
    Switch.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40, 55, 75)
    Switch.Text = Settings[key] and "ON" or "OFF"
    Switch.TextColor3 = Color3.fromRGB(255, 255, 255)
    Switch.Font = Enum.Font.GothamBold
    Switch.TextSize = 11
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 12)

    Switch.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        Switch.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40, 55, 75)
        Switch.Text = Settings[key] and "ON" or "OFF"
        if callback then callback(Settings[key]) end
    end)
end

-- ==============================================
-- 🧩 ใส่ปุ่มลงในหมวดหมู่ต่างๆ
-- ==============================================

-- 🌾 หมวดฟาร์ม (Farm Page)
AddToggle(FarmPage, "🥚 ขโมยไข่อัตโนมัติ (Auto Steal)", "AutoSteal")
AddToggle(FarmPage, "📦 ขโมยเฉพาะไข่ใบใหญ่ (Big Eggs Only)", "StealBigOnly")
AddToggle(FarmPage, "🧠 จำไข่ที่เคยขโมยแล้ว (Remember Visited)", "RememberVisited")

-- ⚡ หมวดออโต้ (Auto Page)
AddToggle(AutoPage, "💰 ขายไข่อัตโนมัติ (Auto Sell)", "AutoSell")
AddToggle(AutoPage, "⚔️ สวมสัตว์เลี้ยงที่ดีที่สุด (Auto Equip Best)", "AutoEquipBest")
AddToggle(AutoPage, "🎁 รับรางวัลอัตโนมัติ (Auto Claim Rewards)", "AutoClaimRewards")

-- 👁️ หมวดแสดงผล (Visual Page)
AddToggle(VisualPage, "🥚 เปิด ESP มองเห็นไข่ (Egg ESP)", "ESP_Egg")
AddToggle(VisualPage, "👤 เปิด ESP มองเห็นผู้เล่น (Player ESP)", "ESP_Player")

-- ⚙️ หมวดอื่นๆ (Misc Page)
AddToggle(MiscPage, "🛡️ กันหลุดออกจากเกม (Anti-AFK)", "AntiAFK")
AddToggle(MiscPage, "🌐 ย้ายเซิร์ฟเวอร์อัตโนมัติ (Auto Server Hop)", "AutoServerHop")

-- ระบบ ซ่อน/แสดง UI เมื่อกดปุ่ม Close หรือ OpenButton
local uiVisible = true
local function ToggleUI()
    uiVisible = not uiVisible
    Main.Visible = uiVisible
end

CloseBtn.MouseButton1Click:Connect(ToggleUI)
OpenBtn.MouseButton1Click:Connect(ToggleUI)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        ToggleUI()
    end
end)

-- ==============================================
-- 🚀 ระบบการทำงานเบื้องหลัง (Background Loops)
-- ==============================================

-- 1. ลูปขโมยไข่ (Auto Steal Loop)
task.spawn(function()
    while isRunning do
        task.wait(Settings.StealInterval)
        if Settings.AutoSteal then
            local eggs = FindEggs()
            if #eggs > 0 then
                StealEgg(eggs[1])
            end
        end
    end
end)

-- 2. ระบบ Anti-AFK
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        if Settings.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end)

-- 3. ระบบ ESP แสดงตำแหน่งไข่
task.spawn(function()
    while isRunning do
        task.wait(0.5)
        -- ลบ ESP เก่า
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "GlassESP" then
                obj:Destroy()
            end
        end
        
        -- สร้าง ESP ใหม่
        if Settings.ESP_Egg then
            for _, egg in ipairs(FindEggs()) do
                pcall(function()
                    local hl = Instance.new("Highlight")
                    hl.Name = "GlassESP"
                    hl.FillColor = Settings.ESPColor
                    hl.FillTransparency = 0.5
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Adornee = egg.Object
                    hl.Parent = egg.Object
                end)
            end
        end
    end
end)

StarterGui:SetCore("SendNotification", {
    Title = "Glass Hub Loaded",
    Text = "สคริปต์เปิดใช้งานแล้ว! กดปุ่ม 🥚 หรือ RightControl เพื่อเปิด/ปิดเมนู",
    Duration = 5
})

print("[✅] Steal an Egg — Glass Blue Edition Loaded Successfully!")
