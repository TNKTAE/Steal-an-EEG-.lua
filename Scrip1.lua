-- ==========================================
-- THE CRAFT HUB - Roblox Script GUI
-- Theme: Dark Navy Blue & Pure Black (เท่ๆ)
-- Language: Lua
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. CONFIG / SETTINGS (ตัวแปรระบบ)
-- ==========================================
local Config = {
    AutoStealEgg = false,
    StealAllInRange = false,
    StealLargeEggOnly = false,
    ESP_Eggs = false,
    ESP_Cards = false,
    AutoSellEggs = false,
    AutoMergePets = false,
    AutoRejoinServer = false,
    AntiAFK = false,
    WalkSpeed = 16,
    WebhookURL = "",
    StealRadius = 50
}

-- Table สำหรับเก็บ ESP Objects
local ESP_Objects = {}

-- ==========================================
-- 2. CORE FUNCTIONS (แยกฟังก์ชันการทำงานหลัก)
-- ==========================================

local Functions = {}

-- 🏃‍♂️ ปรับความเร็วการเดิน
function Functions.SetWalkSpeed(speed)
    Config.WalkSpeed = speed
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = speed
    end
end

-- 🥚 ขโมยไข่อัตโนมัติ / ระยะ / ขนาดใหญ่
function Functions.StealEggLogic()
    task.spawn(function()
        while true do
            task.wait(0.5)
            if Config.AutoStealEgg then
                -- ตัวอย่าง Logic: วนหาโฟลเดอร์ไข่ใน workspace (ปรับเปลี่ยนตามชื่อวัตถุในเกม)
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj:IsA("Model") and string.find(string.lower(obj.Name), "egg") then
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - obj:GetModelCFrame().Position).Magnitude
                        
                        -- เช็คเงื่อนไขขโมยเฉพาะไข่ใหญ่
                        local isLarge = string.find(string.lower(obj.Name), "large") or string.find(string.lower(obj.Name), "big")
                        
                        if Config.StealLargeEggOnly and not isLarge then
                            continue
                        end
                        
                        if Config.StealAllInRange and distance <= Config.StealRadius then
                            -- โค้ดส่ง Event หรือวาร์ปไปเก็บ
                            print("[THE CRAFT HUB] ขโมยไข่:", obj.Name)
                        elseif not Config.StealAllInRange then
                            print("[THE CRAFT HUB] ขโมยไข่ทั่วไป:", obj.Name)
                        end
                    end
                end
            end
        end
    end)
end

-- 👁️ ระบบแสดงตำแหน่ง (ESP)
function Functions.ToggleESP(targetType, enable)
    if not enable then
        if ESP_Objects[targetType] then
            for _, highlight in pairs(ESP_Objects[targetType]) do
                highlight:Destroy()
            end
            ESP_Objects[targetType] = nil
        end
        return
    end

    ESP_Objects[targetType] = {}

    task.spawn(function()
        for _, obj in pairs(workspace:GetChildren()) do
            local isTarget = false
            if targetType == "Egg" and string.find(string.lower(obj.Name), "egg") then
                isTarget = true
            elseif targetType == "Card" and string.find(string.lower(obj.Name), "card") then
                isTarget = true
            end

            if isTarget then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = (targetType == "Egg") and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(255, 215, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Adornee = obj
                highlight.Parent = obj
                table.insert(ESP_Objects[targetType], highlight)
            end
        end
    end)
end

-- 💰 ขายไข่อัตโนมัติ
function Functions.AutoSell()
    task.spawn(function()
        while Config.AutoSellEggs do
            task.wait(2)
            print("[THE CRAFT HUB] กำลังขายไข่อัตโนมัติ...")
            -- ReplicatedStorage.Events.SellEgg:FireServer() -- ตัวอย่างการเรียกใช้ Event ของเกม
        end
    end)
end

-- 🧬 ผสานสัตว์เลี้ยงอัตโนมัติ
function Functions.AutoMerge()
    task.spawn(function()
        while Config.AutoMergePets do
            task.wait(3)
            print("[THE CRAFT HUB] กำลังผสานสัตว์เลี้ยง...")
            -- ReplicatedStorage.Events.MergePets:FireServer()
        end
    end)
end

-- 🌐 ย้ายเซิร์ฟเวอร์อัตโนมัติ (Hop Server)
function Functions.RejoinServer()
    print("[THE CRAFT HUB] กำลังย้ายเซิร์ฟเวอร์...")
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

-- 🛡️ Anti-AFK (ป้องกันการหลุดจากเซิร์ฟ)
function Functions.EnableAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        if Config.AntiAFK then
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            print("[THE CRAFT HUB] ป้องกันการหลุด AFK ทำงาน")
        end
    end)
end

-- 📊 Webhook Alerts Send
function Functions.SendWebhook(msg)
    if Config.WebhookURL == "" then return end
    local payload = HttpService:JSONEncode({
        ["content"] = "🛡️ **THE CRAFT HUB Alert**: " .. msg
    })
    
    -- หมายเหตุ: การใช้งาน Webhook จริงใน Roblox client ต้องผ่าน Request function ของ Executor เช่น syn.request / http_request
    local req = syn and syn.request or http_request or request
    if req then
        req({
            Url = Config.WebhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = payload
        })
    end
end

-- เริ่มทำงาน Loop พื้นฐาน
Functions.StealEggLogic()
Functions.EnableAntiAFK()

-- อัปเดต Speed เสมอเมื่อเกิดใหม่
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    Functions.SetWalkSpeed(Config.WalkSpeed)
end)

-- ==========================================
-- 3. GUI DESIGN (Dark Navy & Black Concept)
-- ==========================================

-- ลบ UI เก่าถ้ามีอยู่
if CoreGui:FindFirstChild("TheCraftHubGUI") then
    CoreGui.TheCraftHubGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHubGUI"
ScreenGui.Parent = CoreGui

-- Frame หลัก (สีน้ำเงินเข้มขอบดำ)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 14, 23) -- Dark Navy
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 85, 255) -- Dark Navy Blue Glow Accent
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Top Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(5, 7, 12) -- Near Black
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.Text = "THE CRAFT HUB"
TitleText.TextColor3 = Color3.fromRGB(0, 150, 255)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1
TitleText.Parent = TitleBar

-- ปุ่มปิด GUI (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Scroll Container (พื้นที่วางปุ่มฟังก์ชัน)
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(1, -20, 1, -55)
ScrollContainer.Position = UDim2.new(0, 10, 0, 45)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 100, 200)
ScrollContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- ==========================================
-- 4. UI BUILDER HELPERS (สร้างปุ่ม & สวิตช์)
-- ==========================================

local function CreateToggle(name, defaultState, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 20, 32)
    Frame.Parent = ScrollContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 50, 0, 24)
    Button.Position = UDim2.new(1, -60, 0.5, -12)
    Button.BackgroundColor3 = defaultState and Color3.fromRGB(0, 132, 255) or Color3.fromRGB(35, 40, 55)
    Button.Text = defaultState and "ON" or "OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 11
    Button.Parent = Frame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Button

    local state = defaultState
    Button.MouseButton1Click:Connect(function()
        state = not state
        Button.Text = state and "ON" or "OFF"
        
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(0, 132, 255) or Color3.fromRGB(35, 40, 55)
        }):Play()

        callback(state)
    end)
end

local function CreateActionButton(name, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 38)
    Button.BackgroundColor3 = Color3.fromRGB(18, 26, 43)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(0, 170, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 13
    Button.Parent = ScrollContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 70, 150)
    Stroke.Thickness = 1
    Stroke.Parent = Button

    Button.MouseButton1Click:Connect(callback)
end

-- ==========================================
-- 5. RENDER FUNCTIONS ON GUI
-- ==========================================

-- 🥚 โซนขโมยไข่
CreateToggle("ขโมยไข่อัตโนมัติ", Config.AutoStealEgg, function(val) Config.AutoStealEgg = val end)
CreateToggle("ขโมยทุกไข่ในระยะ", Config.StealAllInRange, function(val) Config.StealAllInRange = val end)
CreateToggle("ขโมยเฉพาะไข่ขนาดใหญ่", Config.StealLargeEggOnly, function(val) Config.StealLargeEggOnly = val end)

-- 👁️ โซนแสดงตำแหน่ง
CreateToggle("แสดงตำแหน่งไข่ทั้งหมด (ESP)", Config.ESP_Eggs, function(val)
    Config.ESP_Eggs = val
    Functions.ToggleESP("Egg", val)
end)

CreateToggle("แสดงตำแหน่งการ์ด (ESP)", Config.ESP_Cards, function(val)
    Config.ESP_Cards = val
    Functions.ToggleESP("Card", val)
end)

-- ⚙️ ระบบออโต้ต่างๆ
CreateToggle("ขายไข่อัตโนมัติ", Config.AutoSellEggs, function(val)
    Config.AutoSellEggs = val
    if val then Functions.AutoSell() end
end)

CreateToggle("ผสานสัตว์เลี้ยงอัตโนมัติ", Config.AutoMergePets, function(val)
    Config.AutoMergePets = val
    if val then Functions.AutoMerge() end
end)

-- 🌐 ระบบเซิร์ฟเวอร์ และ ระบบป้องกัน
CreateActionButton("🔄 ย้ายเซิร์ฟเวอร์อัตโนมัติ", function()
    Functions.RejoinServer()
end)

CreateToggle("🛡️ Anti-AFK (ป้องกันหลุดจากเซิร์ฟ)", Config.AntiAFK, function(val)
    Config.AntiAFK = val
end)

-- 🏃‍♂️ ปรับความเร็ว
CreateActionButton("⚡ ปรับความเร็วการเดิน (Speed: 50)", function()
    Functions.SetWalkSpeed(50)
end)

CreateActionButton("🚶‍♂️ รีเซ็ตความเร็วปกติ (Speed: 16)", function()
    Functions.SetWalkSpeed(16)
end)

-- 📊 Webhook & Info
CreateActionButton("📊 Webhook Alerts (ทดสอบส่งการแจ้งเตือน)", function()
    Functions.SendWebhook("ทดสอบการเชื่อมต่อระบบแจ้งเตือนสำเร็จ!")
end)

CreateActionButton("ℹ️ ข้อมูลเพิ่มเติม / THE CRAFT HUB", function()
    print("==================================")
    print("THE CRAFT HUB v1.0")
    print("Status: Active")
    print("Theme: Dark Navy & Black")
    print("==================================")
end)

-- คำนวณความสูง Canvas อัตโนมัติ
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 15)
end)

-- ==========================================
-- 6. TOGGLE GUI BUTTON (ปุ่มเปิด-ปิด UI หน้าจอ)
-- ==========================================

local ToggleGuiBtn = Instance.new("TextButton")
ToggleGuiBtn.Name = "ToggleCraftHub"
ToggleGuiBtn.Size = UDim2.new(0, 110, 0, 35)
ToggleGuiBtn.Position = UDim2.new(0, 15, 0.3, 0)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(8, 12, 20)
ToggleGuiBtn.Text = "THE CRAFT HUB"
ToggleGuiBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
ToggleGuiBtn.Font = Enum.Font.GothamBold
ToggleGuiBtn.TextSize = 11
ToggleGuiBtn.Active = true
ToggleGuiBtn.Draggable = true
ToggleGuiBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleGuiBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(0, 100, 220)
ToggleStroke.Thickness = 1.2
ToggleStroke.Parent = ToggleGuiBtn

ToggleGuiBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

print("[THE CRAFT HUB] สคริปต์ทำงานเรียบร้อยแล้ว!")
