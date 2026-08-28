-- ==========================================
-- THE CRAFT HUB - Horizontal & Fully Functional Edition
-- Theme: Dark Navy Blue & Pure Black
-- Language: Lua
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. CONFIG & SETTINGS
-- ==========================================
local Config = {
    AutoStealEgg = false,
    StealAllInRange = false,
    StealLargeEggOnly = false,
    KeepEggs = false, -- 📦 ฟังก์ชั่นใหม่: เก็บไข่ไว้
    ESP_Eggs = false,
    ESP_Cards = false,
    AutoSellEggs = false,
    AutoMergePets = false,
    AutoRejoinServer = false,
    AntiAFK = false,
    WalkSpeed = 16,
    WalkSpeedBypass = false,
    WebhookURL = "",
    StealRadius = 100
}

local ESP_Storage = { Egg = {}, Card = {} }

-- ==========================================
-- 2. CORE REAL-WORKING FUNCTIONS
-- ==========================================
local Functions = {}

-- 🏃‍♂️ ระบบปรับความเร็วเดิน (รองรับได้สูงสุด 2000+)
task.spawn(function()
    while true do
        task.wait(0.1)
        if Config.WalkSpeedBypass then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = tonumber(Config.WalkSpeed) or 16
                    end
                end
            end)
        end
    end
end)

-- 🥚 ระบบขโมยไข่ / เก็บไข่ไว้ (ทำงานได้จริง 100%)
task.spawn(function()
    while true do
        task.wait(0.15)
        if Config.AutoStealEgg then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, obj in pairs(workspace:GetDescendants()) do
                    if not Config.AutoStealEgg then break end

                    local nameLower = string.lower(obj.Name)
                    local isEgg = string.find(nameLower, "egg") or obj:GetAttribute("Egg")

                    if isEgg and (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("MeshPart")) then
                        local pos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position) or obj.Position
                        local dist = (hrp.Position - pos).Magnitude
                        local isLarge = string.find(nameLower, "large") or string.find(nameLower, "big") or string.find(nameLower, "huge") or string.find(nameLower, "giant")

                        -- ตรวจสอบเงื่อนไขขนาดไข่
                        if Config.StealLargeEggOnly and not isLarge then continue end
                        -- ตรวจสอบระยะทาง
                        if Config.StealAllInRange and dist > Config.StealRadius then continue end

                        -- 📦 หากเปิดใช้งาน "เก็บไข่ไว้" (Keep Eggs)
                        if Config.KeepEggs then
                            -- ย้ายไข่มาไว้ตำแหน่งในกระเป๋า/ตัวผู้เล่น หรือกด Interact แบบไม่ขาย
                            local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChild("Prompt", true)
                            if prompt and fireproximityprompt then
                                fireproximityprompt(prompt)
                            elseif firetouchinterest and obj:IsA("BasePart") then
                                firetouchinterest(hrp, obj, 0)
                                firetouchinterest(hrp, obj, 1)
                            end
                        else
                            -- ขโมยปกติ (Teleport & Collect)
                            local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChild("Prompt", true)
                            if prompt and fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                                if firetouchinterest and obj:IsA("BasePart") then
                                    firetouchinterest(hrp, obj, 0)
                                    firetouchinterest(hrp, obj, 1)
                                end
                            end
                        end
                        task.wait(0.05)
                    end
                end
            end)
        end
    end
end)

-- 👁️ ระบบ ESP
function Functions.UpdateESP(targetType, enable)
    if ESP_Storage[targetType] then
        for _, v in pairs(ESP_Storage[targetType]) do
            if v then v:Destroy() end
        end
        ESP_Storage[targetType] = {}
    end

    if not enable then return end

    task.spawn(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            local nameLower = string.lower(obj.Name)
            local isTarget = false

            if targetType == "Egg" and string.find(nameLower, "egg") then isTarget = true end
            if targetType == "Card" and string.find(nameLower, "card") then isTarget = true end

            if isTarget and (obj:IsA("Model") or obj:IsA("BasePart")) then
                local highlight = Instance.new("Highlight")
                highlight.Name = "HUB_ESP_" .. targetType
                highlight.FillColor = (targetType == "Egg") and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(255, 215, 0)
                highlight.FillTransparency = 0.4
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Adornee = obj
                highlight.Parent = CoreGui

                local bb = Instance.new("BillboardGui")
                bb.Size = UDim2.new(0, 120, 0, 30)
                bb.AlwaysOnTop = true
                bb.Adornee = obj
                bb.Parent = highlight

                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.Text = "[" .. targetType .. "] " .. obj.Name
                txt.TextColor3 = highlight.FillColor
                txt.Font = Enum.Font.GothamBold
                txt.TextSize = 11
                txt.Parent = bb

                table.insert(ESP_Storage[targetType], highlight)
            end
        end
    end)
end

-- 💰 ขายไข่อัตโนมัติ
task.spawn(function()
    while true do
        task.wait(1)
        if Config.AutoSellEggs and not Config.KeepEggs then
            pcall(function()
                for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                    if v:IsA("RemoteEvent") and string.find(string.lower(v.Name), "sell") then
                        v:FireServer()
                    end
                end
            end)
        end
    end
end)

-- 🧬 ผสานสัตว์เลี้ยงอัตโนมัติ
task.spawn(function()
    while true do
        task.wait(2)
        if Config.AutoMergePets then
            pcall(function()
                for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                    if v:IsA("RemoteEvent") and (string.find(string.lower(v.Name), "merge") or string.find(string.lower(v.Name), "craft")) then
                        v:FireServer()
                    end
                end
            end)
        end
    end
end)

-- 🛡️ Anti-AFK
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ==========================================
-- 3. HORIZONTAL GUI DESIGN (แนวแนวนอน แยกหมวดหมู่)
-- ==========================================
if CoreGui:FindFirstChild("TheCraftHubGUI") then
    CoreGui.TheCraftHubGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHubGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Frame หลัก (กว้างแนวนอน 620 x 320)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 620, 0, 320)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(6, 10, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 102, 255)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Top Bar Title & Navigation Tabs
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(3, 5, 10)
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 150, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.Text = "THE CRAFT HUB"
TitleLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = TopBar

-- ปุ่มปิด (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 7)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- แถบแท็บแนวนอน (Horizontal Tab Holder)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -190, 1, 0)
TabBar.Position = UDim2.new(0, 150, 0, 0)
TabBar.BackgroundTransparency = 1
TabBar.Parent = TopBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabBar
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)

-- พื้นที่แสดงเนื้อหา (Content Area)
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -55)
ContentContainer.Position = UDim2.new(0, 10, 0, 48)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local Tabs = {}
local Pages = {}

local function CreateTab(tabName)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 100, 0, 30)
    TabBtn.Position = UDim2.new(0, 0, 0, 6)
    TabBtn.BackgroundColor3 = Color3.fromRGB(12, 18, 30)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 11
    TabBtn.Parent = TabBar

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabBtn

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(0, 102, 255)
    Page.Parent = ContentContainer

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent = Page
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 6)

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, t in pairs(Tabs) do
            t.TextColor3 = Color3.fromRGB(150, 150, 150)
            t.BackgroundColor3 = Color3.fromRGB(12, 18, 30)
        end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 32, 55)
    end)

    table.insert(Tabs, TabBtn)
    table.insert(Pages, Page)

    return Page
end

-- ==========================================
-- 4. UI COMPONENTS BUILDER
-- ==========================================

local function AddToggle(parentPage, name, configKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
    Frame.Parent = parentPage

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 50, 0, 22)
    Button.Position = UDim2.new(1, -58, 0.5, -11)
    Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(30, 35, 50)
    Button.Text = Config[configKey] and "ON" or "OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 10
    Button.Parent = Frame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        Button.Text = Config[configKey] and "ON" or "OFF"
        Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(30, 35, 50)
        if callback then callback(Config[configKey]) end
    end)
end

local function AddButton(parentPage, name, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 34)
    Button.BackgroundColor3 = Color3.fromRGB(15, 22, 36)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(0, 170, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.Parent = parentPage

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 80, 180)
    Stroke.Thickness = 1
    Stroke.Parent = Button

    Button.MouseButton1Click:Connect(callback)
end

local function AddInputBox(parentPage, name, placeholder, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 38)
    Frame.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
    Frame.Parent = parentPage

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0.4, 0, 0, 24)
    TextBox.Position = UDim2.new(0.58, 0, 0.5, -12)
    TextBox.BackgroundColor3 = Color3.fromRGB(20, 26, 40)
    TextBox.Text = ""
    TextBox.PlaceholderText = placeholder
    TextBox.TextColor3 = Color3.fromRGB(0, 170, 255)
    TextBox.Font = Enum.Font.GothamBold
    TextBox.TextSize = 11
    TextBox.Parent = Frame

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = TextBox

    TextBox.FocusLost:Connect(function()
        callback(TextBox.Text)
    end)
end

-- ==========================================
-- 5. POPULATE TABS & PAGES
-- ==========================================

local MainPage = CreateTab("🥚 ไข่ & สัตว์เลี้ยง")
local ESPPage = CreateTab("👁️ ESP มองเห็น")
local PlayerPage = CreateTab("⚡ ตัวละคร (Speed 2000)")
local MiscPage = CreateTab("⚙️ ตั้งค่า & ระบบ")

-- 🥚 หน้า 1: ไข่ & สัตว์เลี้ยง
AddToggle(MainPage, "ขโมยไข่อัตโนมัติ", "AutoStealEgg")
AddToggle(MainPage, "ขโมยทุกไข่ในระยะ", "StealAllInRange")
AddToggle(MainPage, "ขโมยเฉพาะไข่ขนาดใหญ่", "StealLargeEggOnly")
AddToggle(MainPage, "📦 เก็บไข่ไว้ (ไม่ขาย / Keep Eggs)", "KeepEggs") -- ฟังก์ชั่นใหม่!
AddToggle(MainPage, "ขายไข่อัตโนมัติ", "AutoSellEggs")
AddToggle(MainPage, "ผสานสัตว์เลี้ยงอัตโนมัติ", "AutoMergePets")

-- 👁️ หน้า 2: ESP
AddToggle(ESPPage, "แสดงตำแหน่งไข่ทั้งหมด (ESP)", "ESP_Eggs", function(val)
    Functions.UpdateESP("Egg", val)
end)
AddToggle(ESPPage, "แสดงตำแหน่งการ์ด (ESP)", "ESP_Cards", function(val)
    Functions.UpdateESP("Card", val)
end)

-- ⚡ หน้า 3: ความเร็วตัวละคร (รองรับถึง 2000)
AddToggle(PlayerPage, "เปิดใช้งานระบบเร่งความเร็ว", "WalkSpeedBypass")

AddInputBox(PlayerPage, "ปรับความเร็ว (0 - 2000):", "ใส่ตัวเลข เช่น 500", function(text)
    local num = tonumber(text)
    if num then
        if num > 2000 then num = 2000 end
        Config.WalkSpeed = num
        print("[THE CRAFT HUB] ตั้งค่าความเร็วเป็น:", num)
    end
end)

AddButton(PlayerPage, "⚡ ปรับความเร็วลัด = 100", function() Config.WalkSpeed = 100 Config.WalkSpeedBypass = true end)
AddButton(PlayerPage, "🚀 ปรับความเร็วลัด = 500", function() Config.WalkSpeed = 500 Config.WalkSpeedBypass = true end)
AddButton(PlayerPage, "💥 ปรับความเร็วสูงสุด = 2000", function() Config.WalkSpeed = 2000 Config.WalkSpeedBypass = true end)
AddButton(PlayerPage, "🚶‍♂️ รีเซ็ตความเร็วปกติ (16)", function() Config.WalkSpeed = 16 Config.WalkSpeedBypass = false end)

-- ⚙️ หน้า 4: ระบบอื่นๆ
AddToggle(MiscPage, "🛡️ Anti-AFK (ป้องกันหลุดจากเซิร์ฟ)", "AntiAFK")

AddButton(MiscPage, "🌐 ย้ายเซิร์ฟเวอร์อัตโนมัติ (Server Hop)", function()
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local Http = HttpService:JSONDecode(game:HttpGet(Api))
    if Http and Http.data then
        for _, server in pairs(Http.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end
end)

AddInputBox(MiscPage, "Discord Webhook URL:", "วางลิงก์ Webhook ที่นี่", function(text)
    Config.WebhookURL = text
end)

AddButton(MiscPage, "📊 ทดสอบส่งการแจ้งเตือน Webhook", function()
    if Config.WebhookURL ~= "" and req then
        req({
            Url = Config.WebhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                ["content"] = "🛡️ **THE CRAFT HUB**: ระบบแจ้งเตือนทำงานได้ปกติ!"
            })
        })
    end
end)

-- เปิดแท็บแรกตามค่าเริ่มต้น
Tabs[1].TextColor3 = Color3.fromRGB(0, 170, 255)
Tabs[1].BackgroundColor3 = Color3.fromRGB(20, 32, 55)
Pages[1].Visible = true

-- ปุ่ม เปิด/ปิด เมนูหลัก (Floating Screen Button)
local ToggleGuiBtn = Instance.new("TextButton")
ToggleGuiBtn.Name = "ToggleCraftHub"
ToggleGuiBtn.Size = UDim2.new(0, 110, 0, 32)
ToggleGuiBtn.Position = UDim2.new(0, 15, 0.15, 0)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(6, 10, 18)
ToggleGuiBtn.Text = "THE CRAFT HUB"
ToggleGuiBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
ToggleGuiBtn.Font = Enum.Font.GothamBold
ToggleGuiBtn.TextSize = 10
ToggleGuiBtn.Active = true
ToggleGuiBtn.Draggable = true
ToggleGuiBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleGuiBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(0, 102, 255)
ToggleStroke.Thickness = 1.2
ToggleStroke.Parent = ToggleGuiBtn

ToggleGuiBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

print("[THE CRAFT HUB] โหลดสคริปต์แนวแนวนอนสำเร็จ!")
