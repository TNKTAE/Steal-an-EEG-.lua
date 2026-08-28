-- ==========================================
-- THE CRAFT HUB - Ultimate Advanced Edition
-- Theme: Dark Navy Blue & Pure Black
-- Language: Lua
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. CONFIG & SYSTEM VARIABLES
-- ==========================================
local Config = {
    -- Player & Combat
    WalkSpeed = 16,
    WalkSpeedBypass = false,
    FastAttack = false,
    AutoEquipEgg = false, -- ใส่ไข่อัตโนมัติเมื่อไข่ตกใส่มือ
    AntiAFK = false,

    -- Eggs System
    AutoStealEgg = false,
    StealAllInRange = false,
    KeepEggs = false, -- เก็บไข่ไว้
    
    -- Egg Filters
    FilterNameEnabled = false,
    TargetEggName = "", -- คัดกรองชื่อไข่
    FilterSizeEnabled = false,
    TargetEggSize = "Large", -- Small, Medium, Large, Giant, Huge
    FilterZoneEnabled = false,
    TargetZone = "", -- คัดกรองโซน

    -- Visual & ESP
    ESP_Eggs = false,
    ESP_Cards = false,

    -- Automation
    AutoSellEggs = false,
    AutoMergePets = false,
    StealRadius = 150,
    WebhookURL = ""
}

local ESP_Storage = { Egg = {}, Card = {} }

-- ==========================================
-- 2. CORE REAL-WORKING FUNCTIONS
-- ==========================================
local Functions = {}

-- 🏃‍♂️ ระบบ WalkSpeed 2000 Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if Config.WalkSpeedBypass then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChildOfClass("Humanoid") then
                    char:FindFirstChildOfClass("Humanoid").WalkSpeed = tonumber(Config.WalkSpeed) or 16
                end
            end)
        end
    end
end)

-- ⚔️ ระบบตีไว (Fast Attack)
task.spawn(function()
    while true do
        task.wait(0.01)
        if Config.FastAttack then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                        if firetouchinterest and tool:FindFirstChild("Handle") then
                            for _, obj in pairs(workspace:GetChildren()) do
                                if obj:IsA("Model") and obj ~= char and obj:FindFirstChild("HumanoidRootPart") then
                                    firetouchinterest(tool.Handle, obj.HumanoidRootPart, 0)
                                    firetouchinterest(tool.Handle, obj.HumanoidRootPart, 1)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 🤲 ระบบใส่ไข่อัตโนมัติเมื่อไข่ตกใส่มือ / เข้ากระเป๋า (Auto Equip Egg)
task.spawn(function()
    while true do
        task.wait(0.2)
        if Config.AutoEquipEgg then
            pcall(function()
                local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                if backpack then
                    for _, item in pairs(backpack:GetChildren()) do
                        if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
                            item.Parent = LocalPlayer.Character -- สวมใส่ถือทันที
                        end
                    end
                end
            end)
        end
    end
end)

-- 🥚 ระบบขโมย / เก็บ / คัดกรองไข่ (ทำงานได้จริง)
task.spawn(function()
    while true do
        task.wait(0.1)
        if Config.AutoStealEgg then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, obj in pairs(workspace:GetDescendants()) do
                    if not Config.AutoStealEgg then break end

                    local nameLower = string.lower(obj.Name)
                    local isEgg = string.find(nameLower, "egg") or obj:GetAttribute("Egg")

                    if isEgg and (obj:IsA("Model") or obj:IsA("BasePart")) then
                        local pos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position) or obj.Position
                        local dist = (hrp.Position - pos).Magnitude

                        -- 🔍 คัดกรองโซน (Filter Zone)
                        if Config.FilterZoneEnabled and Config.TargetZone ~= "" then
                            if not string.find(string.lower(obj:GetFullName()), string.lower(Config.TargetZone)) then
                                continue
                            end
                        end

                        -- 🔍 คัดกรองชื่อไข่ (Filter Name)
                        if Config.FilterNameEnabled and Config.TargetEggName ~= "" then
                            if not string.find(nameLower, string.lower(Config.TargetEggName)) then
                                continue
                            end
                        end

                        -- 🔍 คัดกรองขนาดไข่ (Filter Size)
                        if Config.FilterSizeEnabled then
                            local sz = string.lower(Config.TargetEggSize)
                            if not string.find(nameLower, sz) then
                                continue
                            end
                        end

                        -- ตรวจสอบระยะทาง
                        if Config.StealAllInRange and dist > Config.StealRadius then
                            continue
                        end

                        -- 📦 เก็บไข่ไว้ / ขโมยไข่
                        local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChild("Prompt", true)
                        local clicker = obj:FindFirstChildOfClass("ClickDetector")

                        if prompt and fireproximityprompt then
                            fireproximityprompt(prompt)
                        elseif clicker and fireclickdetector then
                            fireclickdetector(clicker)
                        else
                            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 2.5, 0))
                            if firetouchinterest and obj:IsA("BasePart") then
                                firetouchinterest(hrp, obj, 0)
                                firetouchinterest(hrp, obj, 1)
                            end
                        end
                        task.wait(0.05)
                    end
                end
            end)
        end
    end
end)

-- 👁️ ระบบมองไข่ (ESP มองเห็นไข่)
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
                highlight.FillTransparency = 0.3
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Adornee = obj
                highlight.Parent = CoreGui

                local bb = Instance.new("BillboardGui")
                bb.Size = UDim2.new(0, 140, 0, 30)
                bb.AlwaysOnTop = true
                bb.Adornee = obj
                bb.Parent = highlight

                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.Text = "👁️ [" .. targetType:upper() .. "] " .. obj.Name
                txt.TextColor3 = highlight.FillColor
                txt.Font = Enum.Font.GothamBold
                txt.TextSize = 10
                txt.Parent = bb

                table.insert(ESP_Storage[targetType], highlight)
            end
        end
    end)
end

-- 💰 ระบบขายไข่อัตโนมัติ (ปิดทำงานหากเปิด 'เก็บไข่ไว้')
task.spawn(function()
    while true do
        task.wait(1.5)
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

-- 🧬 ผสานสัตว์เลี้ยง
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
-- 3. HORIZONTAL GUI CREATION
-- ==========================================
if CoreGui:FindFirstChild("TheCraftHubGUI") then
    CoreGui.TheCraftHubGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHubGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 650, 0, 350)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -175)
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

-- Top Bar Bar & Navigation
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(3, 5, 10)
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 140, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Text = "THE CRAFT HUB"
TitleLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = TopBar

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

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -180, 1, 0)
TabBar.Position = UDim2.new(0, 145, 0, 0)
TabBar.BackgroundTransparency = 1
TabBar.Parent = TopBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabBar
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 4)

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -55)
ContentContainer.Position = UDim2.new(0, 10, 0, 48)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local Tabs, Pages = {}, {}

local function CreateTab(tabName)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 95, 0, 28)
    TabBtn.Position = UDim2.new(0, 0, 0, 7)
    TabBtn.BackgroundColor3 = Color3.fromRGB(12, 18, 30)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 10
    TabBtn.Parent = TabBar

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 5)
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
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 48, 0, 22)
    Button.Position = UDim2.new(1, -56, 0.5, -11)
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
    Button.TextSize = 11
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
    Frame.Size = UDim2.new(1, -10, 0, 36)
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
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0.42, 0, 0, 22)
    TextBox.Position = UDim2.new(0.56, 0, 0.5, -11)
    TextBox.BackgroundColor3 = Color3.fromRGB(20, 26, 40)
    TextBox.Text = ""
    TextBox.PlaceholderText = placeholder
    TextBox.TextColor3 = Color3.fromRGB(0, 170, 255)
    TextBox.Font = Enum.Font.GothamBold
    TextBox.TextSize = 10
    TextBox.Parent = Frame

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = TextBox

    TextBox.FocusLost:Connect(function()
        callback(TextBox.Text)
    end)
end

-- ==========================================
-- 5. BUILD TABS & CONNECT ALL FUNCTIONS
-- ==========================================

local PlayerPage = CreateTab("👤 ผู้เล่น & ต่อสู้")
local EggPage = CreateTab("🥚 ระบบไข่")
local FilterPage = CreateTab("🔍 คัดกรองไข่ & โซน")
local VisualPage = CreateTab("👁️ มองไข่ / ESP")
local MiscPage = CreateTab("⚙️ ระบบเพิ่มเติม")

-- 👤 แท็บ 1: ผู้เล่น & ต่อสู้
AddToggle(PlayerPage, "⚔️ ระบบตีไวอัตโนมัติ (Fast Attack)", "FastAttack")
AddToggle(PlayerPage, "🤲 ใส่ไข่อัตโนมัติเมื่อไข่ตกใส่มือ (Auto Equip)", "AutoEquipEgg")
AddToggle(PlayerPage, "⚡ เปิดใช้งานเร่งความเร็วตัวละคร", "WalkSpeedBypass")

AddInputBox(PlayerPage, "ปรับความเร็วเดิน (0 - 2000):", "พิมพ์ตัวเลข เช่น 500", function(text)
    local num = tonumber(text)
    if num then
        if num > 2000 then num = 2000 end
        Config.WalkSpeed = num
    end
end)

AddButton(PlayerPage, "🚀 ความเร็วสูงสุด = 2000", function() Config.WalkSpeed = 2000 Config.WalkSpeedBypass = true end)
AddButton(PlayerPage, "🚶‍♂️ รีเซ็ตความเร็วปกติ (16)", function() Config.WalkSpeed = 16 Config.WalkSpeedBypass = false end)

-- 🥚 แท็บ 2: ระบบไข่
AddToggle(EggPage, "ขโมยไข่อัตโนมัติ", "AutoStealEgg")
AddToggle(EggPage, "ขโมยทุกไข่ในระยะ", "StealAllInRange")
AddToggle(EggPage, "📦 เก็บไข่ไว้ (ไม่ขาย / Keep Eggs)", "KeepEggs")
AddToggle(EggPage, "ขายไข่อัตโนมัติ", "AutoSellEggs")
AddToggle(EggPage, "ผสานสัตว์เลี้ยงอัตโนมัติ", "AutoMergePets")

-- 🔍 แท็บ 3: ระบบคัดกรอง
AddToggle(FilterPage, "🔍 เปิดใช้งานระบบคัดกรองชื่อไข่", "FilterNameEnabled")
AddInputBox(FilterPage, "ชื่อไข่ที่ต้องการ:", "เช่น Dragon, Gold", function(text)
    Config.TargetEggName = text
end)

AddToggle(FilterPage, "📐 เปิดใช้งานระบบคัดกรองขนาดไข่", "FilterSizeEnabled")
AddInputBox(FilterPage, "ขนาดไข่ (Large/Giant/Huge):", "พิมพ์ขนาด เช่น Huge", function(text)
    Config.TargetEggSize = text
end)

AddToggle(FilterPage, "🗺️ เปิดใช้งานระบบคัดกรองโซน", "FilterZoneEnabled")
AddInputBox(FilterPage, "ชื่อโซน/พื้นที่เฉพาะ:", "พิมพ์ชื่อโซน เช่น Zone1", function(text)
    Config.TargetZone = text
end)

-- 👁️ แท็บ 4: มองไข่ / ESP
AddToggle(VisualPage, "👁️ มองเห็นตำแหน่งไข่ทั้งหมด (Egg ESP)", "ESP_Eggs", function(val)
    Functions.UpdateESP("Egg", val)
end)
AddToggle(VisualPage, "🎴 มองเห็นตำแหน่งการ์ด (Card ESP)", "ESP_Cards", function(val)
    Functions.UpdateESP("Card", val)
end)

-- ⚙️ แท็บ 5: ระบบเพิ่มเติม
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

-- สลับแท็บแรกตามค่าเริ่มต้น
Tabs[1].TextColor3 = Color3.fromRGB(0, 170, 255)
Tabs[1].BackgroundColor3 = Color3.fromRGB(20, 32, 55)
Pages[1].Visible = true

-- ปุ่มเปิด/ปิด เมนูหลัก (Floating Screen Button)
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

print("[THE CRAFT HUB] อัปเดตฟังก์ชั่นผู้เล่น คัดกรองไข่ และโซนเรียบร้อยแล้ว!")
