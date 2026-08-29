-- ==============================================
--           ◌ิ THE CRAFT HUB
--   UI: สีน้ำเงินเข้ม + ดำ | เปิด-ปิดได้
-- ==============================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Config
local DiscordLink = "https://discord.gg/EHZ8MsKZCt"
local HubName = "◌ิ THE CRAFT HUB"
local WebhookURL = "" -- ใส่ Webhook ที่นี่ถ้าต้องการใช้

-- Notification Function
local function Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5
        })
    end)
    warn("[THE CRAFT HUB] " .. title .. ": " .. text)
end

-- Load Check
if getgenv().__THECRAFTHUB_Loaded then
    Notify("แจ้งเตือน", "สคริปต์ทำงานอยู่แล้ว!")
    return
end
getgenv().__THECRAFTHUB_Loaded = true

-- Services & Variables
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- State
local State = {
    AutoStealEgg = false,
    AutoStealAll = false,
    StealBigEggsOnly = false,
    EggESP = false,
    CardESP = false,
    AutoSell = false,
    AutoFuse = false,
    AutoRejoin = false,
    AntiAFK = false,
    Speed = 16,
    ESPObjects = {}
}

-- Data & Monsters
local Directory = nil
local ok, result = pcall(function()
    return require(ReplicatedStorage:WaitForChild("Data", 20):WaitForChild("Assets", 20)).Directory
end)

local DefaultMonsters = {
    {Id = "Unicorn", DisplayName = "Unicorn", RarityName = "Legendary", RarityNumber = 4, Color = Color3.fromRGB(255, 215, 90)},
    {Id = "Kraken", DisplayName = "Kraken", RarityName = "Secret", RarityNumber = 6, Color = Color3.fromRGB(255, 60, 60)},
    {Id = "Phoenix", DisplayName = "Phoenix", RarityName = "Mythic", RarityNumber = 5, Color = Color3.fromRGB(255, 120, 255)},
    {Id = "Duckling", DisplayName = "Duckling", RarityName = "Common", RarityNumber = 1, Color = Color3.fromRGB(200, 200, 200)}
}

local MonsterList = {}
if ok and type(result) == "table" then
    for k, v in pairs(result) do
        if type(v) == "table" then
            local Rarity = v.Rarity or {}
            table.insert(MonsterList, {
                Id = k,
                DisplayName = v.DisplayName or k,
                RarityName = Rarity.DisplayName or "Unknown",
                RarityNumber = Rarity.RarityNumber or -1,
                Color = Rarity.Color or Color3.fromRGB(190, 190, 195)
            })
        end
    end
    table.sort(MonsterList, function(a, b) return a.RarityNumber > b.RarityNumber end)
end
if #MonsterList == 0 then MonsterList = DefaultMonsters end

-- Settings
local SpawnAmount = 1
local UI_Open = true
local RainbowButtons = {}

-- ==============================================
--                   CREATE UI
-- ==============================================
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "THE_CRAFT_HUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- Drag Function
local function MakeDraggable(TopBar, Frame)
    local DragStart, InputStart, FrameStart
    TopBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            DragStart = Input.Position
            FrameStart = Frame.Position
            Input.Changed:Connect(function(Input2)
                if Input2.UserInputState == Enum.UserInputState.End then DragStart = nil end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(Input)
        if DragStart and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = Input.Position - DragStart
            Frame.Position = UDim2.new(FrameStart.X.Scale, FrameStart.X.Offset + Delta.X, FrameStart.Y.Scale, FrameStart.Y.Offset + Delta.Y)
        end
    end)
end

-- Toggle Button (เปิด-ปิด สคริปต์)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleButton"
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 15, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
ToggleBtn.Text = "◌ิ"
ToggleBtn.TextColor3 = Color3.fromRGB(96, 165, 250)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 24
ToggleBtn.AutoButtonColor = true
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 580)
MainFrame.Position = UDim2.new(0, 80, 0.5, -290)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(30, 64, 175)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 64, 175)
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = HubName
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.BackgroundTransparency = 1
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -34, 0, 5)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = TopBar

-- Content Area
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 0, 0, 47)
Content.Size = UDim2.new(1, 0, 1, -47)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(96, 165, 250)
Content.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Content

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft = UDim.new(0, 12)
UIPadding.PaddingRight = UDim.new(0, 12)
UIPadding.PaddingTop = UDim.new(0, 12)
UIPadding.PaddingBottom = UDim.new(0, 12)
UIPadding.Parent = Content

-- ==============================================
--                FUNCTIONS
-- ==============================================
local function OpenDiscord()
    pcall(function() setclipboard(DiscordLink) end)
    pcall(function() game:GetService("GuiService"):OpenBrowserWindowAsync(DiscordLink) end)
    Notify("ลิงก์ถูกคัดลอก", "Discord: " .. DiscordLink)
end

local function SendWebhook(Message)
    if not WebhookURL or WebhookURL == "" then return end
    pcall(function()
        local Data = {
            ["username"] = "THE CRAFT HUB",
            ["embeds"] = {{
                ["title"] = "แจ้งเตือนจากสคริปต์",
                ["description"] = Message,
                ["color"] = 255
            }}
        }
        HttpService:PostAsync(WebhookURL, HttpService:JSONEncode(Data))
    end)
end

local function ToggleButtonState(Btn, StateTable, Key)
    StateTable[Key] = not StateTable[Key]
    Btn.BackgroundColor3 = StateTable[Key] and Color3.fromRGB(30, 64, 175) or Color3.fromRGB(30, 41, 59)
    return StateTable[Key]
end

-- === ESP Functions ===
local function DrawESP(Part, Name, Color)
    if not Part then return end
    local ESP = {}
    ESP.Dot = Instance.new("BillboardGui")
    ESP.Dot.AlwaysOnTop = true
    ESP.Dot.Size = UDim2.new(0, 12, 0, 12)
    ESP.Dot.Parent = Part
    local Frame = Instance.new("Frame")
    Frame.BackgroundColor3 = Color
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.Parent = ESP.Dot
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(1, 0)

    ESP.Label = Instance.new("BillboardGui")
    ESP.Label.AlwaysOnTop = true
    ESP.Label.Size = UDim2.new(0, 100, 0, 20)
    ESP.Label.Parent = Part
    local Text = Instance.new("TextLabel")
    Text.BackgroundTransparency = 1
    Text.Size = UDim2.new(1, 0, 1, 0)
    Text.Position = UDim2.new(0, 0, 1, 5)
    Text.Font = Enum.Font.Gotham
    Text.TextSize = 11
    Text.Text = Name
    Text.TextColor3 = Color
    Text.Parent = ESP.Label

    return ESP
end

-- === Main Loop Functions ===
RunService.Heartbeat:Connect(function()
    local Character = LocalPlayer.Character
    if not Character then return end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not HumanoidRootPart or not Humanoid then return end

    -- Speed
    Humanoid.WalkSpeed = State.Speed

    -- Anti-AFK
    if State.AntiAFK then
        pcall(function()
            task.wait(60)
            UserInputService:CaptureController()
        end)
    end

    -- Auto Steal Egg / Auto Steal All
    if State.AutoStealEgg or State.AutoStealAll then
        for _, Desc in pairs(Workspace:GetDescendants()) do
            if Desc:IsA("BasePart") and (Desc.Name:find("Egg") or Desc.Name:find("EggPart")) then
                local Dist = (HumanoidRootPart.Position - Desc.Position).Magnitude
                if Dist < 15 then
                    if State.StealBigEggsOnly and not Desc.Name:find("Big") then continue end
                    -- โค้ดหยิบไข่ ปรับตามเกมจริง
                    pcall(function()
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Desc.Position)
                        task.wait(0.1)
                    end)
                end
                if State.EggESP and not State.ESPObjects[Desc] then
                    State.ESPObjects[Desc] = DrawESP(Desc, "🥚 ไข่", Color3.fromRGB(255, 200, 50))
                end
            end
        end
    end

    -- Clear ESP when off
    if not State.EggESP then
        for _, v in pairs(State.ESPObjects) do
            if v.Dot then v.Dot:Destroy() end
            if v.Label then v.Label:Destroy() end
        end
        State.ESPObjects = {}
    end
end)

-- ==============================================
--              MENU SECTIONS
-- ==============================================

local function AddSectionHeader(name)
    local Header = Instance.new("TextLabel")
    Header.LayoutOrder = 0
    Header.BackgroundTransparency = 1
    Header.Size = UDim2.new(1, 0, 0, 22)
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 12
    Header.TextColor3 = Color3.fromRGB(96, 165, 250)
    Header.Text = "▸ " .. name
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = Content
end

local function AddToggle(name, Key, StateTable)
    local Btn = Instance.new("TextButton")
    Btn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    Btn.Size = UDim2.new(1, 0, 0, 36)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 13
    Btn.TextColor3 = Color3.fromRGB(240, 240, 255)
    Btn.Text = name
    Btn.AutoButtonColor = false
    Btn.Parent = Content
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    Btn.MouseButton1Click:Connect(function()
        local IsOn = ToggleButtonState(Btn, StateTable, Key)
        Notify(name, IsOn and "เปิดใช้งานแล้ว ✅" or "ปิดใช้งานแล้ว ❌")
    end)
    return Btn
end

local function AddButton(name, callback)
    local Btn = Instance.new("TextButton")
    Btn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    Btn.Size = UDim2.new(1, 0, 0, 36)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 13
    Btn.TextColor3 = Color3.fromRGB(240, 240, 255)
    Btn.Text = name
    Btn.AutoButtonColor = false
    Btn.Parent = Content
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

local function AddSlider(name, Min, Max, Default, Callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    Frame.Parent = Content
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextColor3 = Color3.fromRGB(220, 220, 255)
    Label.Text = name .. ": " .. Default
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -20, 0, 8)
    SliderBg.Position = UDim2.new(0, 10, 0, 30)
    SliderBg.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
    SliderBg.Parent = Frame
    Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(96, 165, 250)
    SliderFill.Parent = SliderBg
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

    local function Update(input)
        local Pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
        local Value = math.floor(Min + (Max - Min) * Pos)
        SliderFill.Size = UDim2.new(Pos, 0, 1, 0)
        Label.Text = name .. ": " .. Value
        Callback(Value)
        return Value
    end

    SliderBg.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Update(Input)
        end
    end)
    UserInputService.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(Input)
        end
    end)
end

-- === BUILD FULL MENU ===
AddSectionHeader("🥚 ระบบไข่")
AddToggle("🥚 ขโมยไข่อัตโนมัติ", "AutoStealEgg", State)
AddToggle("🎯 ขโมยทุกไข่ในระยะ", "AutoStealAll", State)
AddToggle("💎 ขโมยเฉพาะไข่ขนาดใหญ่", "StealBigEggsOnly", State)
AddToggle("👁️ แสดงตำแหน่งไข่ทั้งหมด", "EggESP", State)
AddToggle("🃏 แสดงตำแหน่งการ์ด", "CardESP", State)

AddSectionHeader("💰 ระบบอัตโนมัติ")
AddToggle("💰 ขายไข่อัตโนมัติ", "AutoSell", State)
AddToggle("🔄 ผสานสัตว์เลี้ยงอัตโนมัติ", "AutoFuse", State)
AddToggle("🌐 ย้ายเซิร์ฟเวอร์อัตโนมัติ", "AutoRejoin", State)

AddSectionHeader("⚙️ การตั้งค่า")
AddSlider("🏃 ความเร็วการเดิน", 16, 100, 16, function(val)
    State.Speed = val
end)
AddToggle("🛡️ Anti-AFK", "AntiAFK", State)

AddSectionHeader("📡 อื่นๆ")
AddToggle("📊 Webhook Alerts", "WebhookAlerts", State)
AddButton("⚙️ ตั้งค่าทั้งหมด", function() Notify("ตั้งค่า", "เปิดหน้าตั้งค่า") end)
AddButton("📋 ข้อมูลเพิ่มเติม", function() Notify("ข้อมูล", "THE CRAFT HUB | Discord: "..DiscordLink) end)
AddButton("🔗 เข้าร่วม Discord", OpenDiscord)

-- ==============================================
--              TOGGLE SHOW/HIDE
-- ==============================================
ToggleBtn.MouseButton1Click:Connect(function()
    UI_Open = not UI_Open
    MainFrame.Visible = UI_Open
    ToggleBtn.BackgroundColor3 = UI_Open and Color3.fromRGB(30, 64, 175) or Color3.fromRGB(15, 23, 42)
end)

CloseBtn.MouseButton1Click:Connect(function()
    UI_Open = false
    MainFrame.Visible = false
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
end)

MakeDraggable(TopBar, MainFrame)

-- Rainbow Animation
RunService.Heartbeat:Connect(function()
    for _, Btn in ipairs(RainbowButtons) do
        if Btn.Parent then
            Btn.BackgroundColor3 = Color3.fromHSV(os.clock() * 0.15 % 1, 0.85, 1)
        end
    end
end)

-- ==============================================
--                  LOADED
-- ==============================================
Notify("◌ิ THE CRAFT HUB", "โหลดเสร็จสิ้น! กดปุ่ม ◌ิ เพื่อเปิด/ปิด")
print("[THE CRAFT HUB] ✅ Loaded successfully!")
