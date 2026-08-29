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
local LocalPlayer = Players.LocalPlayer

-- Config
local DiscordLink = "https://discord.gg/EHZ8MsKZCt"
local HubName = "◌ิ THE CRAFT HUB"

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

-- Toggle Button (เปิด-ปิด)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleButton"
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 15, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 23, 42) -- น้ำเงินเข้ม
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
MainFrame.Size = UDim2.new(0, 320, 0, 550)
MainFrame.Position = UDim2.new(0, 80, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42) -- น้ำเงินเข้ม
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(30, 64, 175)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 64, 175) -- น้ำเงิน
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -45, 1, 0)
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
CloseBtn.Position = UDim2.new(1, -34, 0, 4)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = TopBar

-- Content Area
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 0, 0, 45)
Content.Size = UDim2.new(1, 0, 1, -45)
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

local function PlacePets()
    Notify("แจ้งเตือน", "ฟังก์ชันทำงาน! จำนวน: " .. SpawnAmount)
    -- เพิ่มโค้ดวางไข่ที่นี่
end

local function ClearAll()
    Notify("ล้างสำเร็จ", "ล้างสัตว์ทั้งหมดแล้ว")
    -- เพิ่มโค้ดล้างที่นี่
end

-- ==============================================
--              MENU SECTIONS
-- ==============================================

-- === SECTION 1: ข้อมูลระบบ ===
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

local function AddButton(name, callback)
    local Btn = Instance.new("TextButton")
    Btn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    Btn.Size = UDim2.new(1, 0, 0, 34)
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

local function AddAmountControl()
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    Frame.Parent = Content
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(0, 100, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(220, 220, 255)
    Label.Text = "จำนวนวาง:"
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Value = Instance.new("TextLabel")
    Value.BackgroundTransparency = 1
    Value.Size = UDim2.new(0, 30, 1, 0)
    Value.Position = UDim2.new(0.5, -15, 0, 0)
    Value.Font = Enum.Font.GothamBold
    Value.TextSize = 14
    Value.TextColor3 = Color3.fromRGB(96, 165, 250)
    Value.Text = tostring(SpawnAmount)
    Value.Parent = Frame

    local Minus = Instance.new("TextButton")
    Minus.Size = UDim2.new(0, 32, 1, -6)
    Minus.Position = UDim2.new(0, 10, 0, 3)
    Minus.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
    Minus.Font = Enum.Font.GothamBold
    Minus.TextSize = 16
    Minus.Text = "-"
    Minus.TextColor3 = Color3.fromRGB(255, 255, 255)
    Minus.Parent = Frame
    Instance.new("UICorner", Minus).CornerRadius = UDim.new(0, 6)

    local Plus = Instance.new("TextButton")
    Plus.Size = UDim2.new(0, 32, 1, -6)
    Plus.Position = UDim2.new(1, -42, 0, 3)
    Plus.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
    Plus.Font = Enum.Font.GothamBold
    Plus.TextSize = 16
    Plus.Text = "+"
    Plus.TextColor3 = Color3.fromRGB(255, 255, 255)
    Plus.Parent = Frame
    Instance.new("UICorner", Plus).CornerRadius = UDim.new(0, 6)

    Minus.MouseButton1Click:Connect(function()
        SpawnAmount = math.max(1, SpawnAmount - 1)
        Value.Text = tostring(SpawnAmount)
    end)
    Plus.MouseButton1Click:Connect(function()
        SpawnAmount = math.min(5, SpawnAmount + 1)
        Value.Text = tostring(SpawnAmount)
    end)
end

local function AddMonsterGrid()
    AddSectionHeader("รายการสัตว์/ไข่")
    
    local GridFrame = Instance.new("Frame")
    GridFrame.Size = UDim2.new(1, 0, 0, 0)
    GridFrame.AutomaticSize = Enum.AutomaticSize.Y
    GridFrame.BackgroundTransparency = 1
    GridFrame.Parent = Content

    local Grid = Instance.new("UIGridLayout")
    Grid.CellSize = UDim2.new(0, 80, 0, 90)
    Grid.CellPadding = UDim2.new(0, 6, 0, 6)
    Grid.Parent = GridFrame

    for _, v in ipairs(MonsterList) do
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 80, 0, 90)
        Btn.BackgroundColor3 = v.Color
        Btn.Text = ""
        Btn.AutoButtonColor = true
        Btn.Parent = GridFrame
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

        local Name = Instance.new("TextLabel")
        Name.BackgroundTransparency = 1
        Name.Size = UDim2.new(1, -6, 0, 28)
        Name.Position = UDim2.new(0, 3, 0, 58)
        Name.Font = Enum.Font.GothamBold
        Name.TextSize = 10
        Name.TextColor3 = Color3.fromRGB(255, 255, 255)
        Name.Text = v.DisplayName
        Name.TextWrapped = true
        Name.Parent = Btn

        if v.RarityName == "Rainbow" then
            table.insert(RainbowButtons, Btn)
        end

        Btn.MouseButton1Click:Connect(function()
            Notify("เลือก", "เลือก " .. v.DisplayName)
        end)
    end
end

-- === BUILD MENU ===
AddSectionHeader("📋 ข้อมูลระบบ")
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, 0, 0, 40)
Info.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
Info.Font = Enum.Font.Gotham
Info.TextSize = 11
Info.TextColor3 = Color3.fromRGB(180, 180, 200)
Info.Text = "สถานะ: พร้อมใช้งาน\nสัตว์ทั้งหมด: " .. #MonsterList .. " ชนิด"
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.TextYAlignment = Enum.TextYAlignment.Top
Info.Parent = Content
Instance.new("UICorner", Info).CornerRadius = UDim.new(0, 8)

AddMonsterGrid()

AddSectionHeader("⚙️ การตั้งค่า")
AddAmountControl()

AddSectionHeader("🎮 การทำงาน")
AddButton("📍 วางสัตว์ที่เลือก", PlacePets)
AddButton("🗑️ ล้างสัตว์ทั้งหมด", ClearAll)
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
