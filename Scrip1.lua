-- [[ THE CRAFT HUB - ROBLOX SCRIPT ]]
-- Theme: Dark Blue & Black Minimalist UI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- State Management
local Config = {
    Language = "TH", -- "TH" หรือ "EN"
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    NoKnockback = false,
    FastAttack = false,
    AutoTree = false,
    StealParasite = false,
    StealFX = false,
    AutoStealZone = false,
    SelectedZone = "",
    ZigZagSteal = false,
    AntiDropEgg = false,
    FastGrab = false,
    ESP_Eggs = false,
    ESP_Players = false
}

-- UI Library Creation (Ouroboros/Rayfield Style)
local Library = {}
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHub_UI"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame (Dark Blue & Black Theme)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 620, 0, 380)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(0, 102, 204)
UIStroke.Thickness = 1.5

-- Sidebar Navigation
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
Sidebar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "THE CRAFT HUB"
Title.TextColor3 = Color3.fromRGB(0, 150, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(12, 14, 22)

local CategoryContainer = Instance.new("UIListLayout", Sidebar)
CategoryContainer.SortOrder = Enum.SortOrder.LayoutOrder
CategoryContainer.Padding = UDim.new(0, 4)

-- Content Area
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -170, 1, -10)
ContentArea.Position = UDim2.new(0, 165, 0, 5)
ContentArea.BackgroundTransparency = 1

-- Icon Assets (Lucide / Roblox Asset IDs)
local Icons = {
    Main = "rbxassetid://10723415903",
    Event = "rbxassetid://10734952042",
    Steal = "rbxassetid://10747373158",
    Visuals = "rbxassetid://10723424102",
    Settings = "rbxassetid://10734975692"
}

-- Language Dictionary
local Translations = {
    TH = {
        MainTab = "ทั่วไป / ผู้เล่น",
        EventTab = "อีเว้นท์",
        StealTab = "ขโมยไข่",
        VisualTab = "มองทะลุ (ESP)",
        SettingsTab = "ตั้งค่า",
        Speed = "ความเร็วการวิ่ง (สูงสุด 2000)",
        Jump = "แรงกระโดด",
        InfJump = "กระโดดไม่จำกัด",
        NoKnock = "ไม่กระเด็น (Anti-Knockback)",
        FastAttack = "ตีไวเมื่อถืออาวุธ",
        AutoTree = "ตีต้นไม้ small อัตโนมัติ",
        SpawnTreadmill = "เสกลู้วิ่ง Admin",
        StealParasite = "ขโมยไข่ MonsterParasite",
        StealFX = "ขโมยไข่มี FX",
        FastGrab = "กดเก็บไข่ไว (Instant E)",
        AntiDrop = "กันไข่หลุดมือ",
        ZigZag = "ซิกแซกกลับฐาน",
        Rejoin = "ย้ายเซิฟเวอร์ (Rejoin/Server Hop)",
        LangToggle = "เปลี่ยนภาษา (TH/EN)"
    },
    EN = {
        MainTab = "Main / Player",
        EventTab = "Event",
        StealTab = "Steal Eggs",
        VisualTab = "Visuals (ESP)",
        SettingsTab = "Settings",
        Speed = "WalkSpeed (Max 2000)",
        Jump = "Jump Power",
        InfJump = "Infinite Jump",
        NoKnock = "No Knockback",
        FastAttack = "Fast Attack",
        AutoTree = "Auto Farm Small Trees",
        SpawnTreadmill = "Spawn Admin Treadmill",
        StealParasite = "Steal Parasite Egg",
        StealFX = "Steal FX Eggs",
        FastGrab = "Fast Grab (Instant E)",
        AntiDrop = "Anti Drop Egg",
        ZigZag = "Zig-Zag Return",
        Rejoin = "Server Hop / Rejoin",
        LangToggle = "Switch Language"
    }
}

-- ========================================================
-- [CORE FUNCTIONS & FEATURES]
-- ========================================================

-- 1. ความเร็วและแรงกระโดด
RunService.Stepped:Connect(function()
    if Humanoid then
        Humanoid.WalkSpeed = Config.WalkSpeed
        Humanoid.JumpPower = Config.JumpPower
    end
end)

-- 2. กระโดดไม่จำกัด
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- 3. ระบบตีไว (Fast Attack)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and Config.FastAttack and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local tool = Character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end
end)

-- 4. ระบบไม่กระเด็น (No Knockback)
RunService.Heartbeat:Connect(function()
    if Config.NoKnockback and RootPart then
        RootPart.Velocity = Vector3.new(0, RootPart.Velocity.Y, 0)
        RootPart.RotVelocity = Vector3.new(0, 0, 0)
    end
end)

-- 5. ตีต้นไม้ small อัตโนมัติ (Event)
task.spawn(function()
    while task.wait(0.5) do
        if Config.AutoTree then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and string.lower(obj.Name):find("small") and obj:FindFirstChild("HumanoidRootPart") then
                    repeat
                        if not Config.AutoTree then break end
                        RootPart.CFrame = obj.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                        local tool = Character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        task.wait(0.1)
                    until not obj or not obj.Parent or obj.Humanoid.Health <= 0
                end
            end
        end
    end
end)

-- 6. เสกลู้วิ่ง Admin (AdminTreadmill)
local function SpawnTreadmill()
    local tm = Instance.new("Part")
    tm.Name = "AdminTreadmill"
    tm.Size = Vector3.new(6, 1, 10)
    tm.Position = RootPart.Position + Vector3.new(0, -2, 0)
    tm.Anchored = true
    tm.Material = Enum.Material.SmoothPlastic
    tm.Color = Color3.fromRGB(0, 102, 204)
    tm.Parent = Workspace
end

-- 7. มองทะลุไข่ (AreaEggSlotsClient) แบบไม่ซ้ำชื่อ & มองทะลุผู้เล่น
local Highlights = {}
local function ClearESP()
    for _, h in pairs(Highlights) do h:Destroy() end
    Highlights = {}
end

task.spawn(function()
    while task.wait(1) do
        ClearESP()
        -- ESP Eggs
        if Config.ESP_Eggs then
            local eggFolder = Workspace:FindFirstChild("AreaEggSlotsClient")
            local renderNames = {}
            if eggFolder then
                for _, egg in pairs(eggFolder:GetChildren()) do
                    if not renderNames[egg.Name] then
                        renderNames[egg.Name] = true
                        local hl = Instance.new("Highlight")
                        hl.Adornee = egg
                        hl.FillColor = Color3.fromRGB(0, 255, 150)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.Parent = egg
                        table.insert(Highlights, hl)
                    end
                end
            end
        end
        -- ESP Players
        if Config.ESP_Players then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = player.Character
                    hl.FillColor = Color3.fromRGB(255, 50, 50)
                    hl.Parent = player.Character
                    table.insert(Highlights, hl)
                end
            end
        end
    end
end)

-- 8. ระบบขโมยไข่ / กันไข่หลุด / กดเก็บไว
local function TriggerPrompt(prompt)
    if Config.FastGrab then
        fireproximityprompt(prompt)
    else
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end
end

-- ดึงรายชื่อโซนจาก __OBJECTS -> Areas
local function GetZoneList()
    local zones = {}
    local objs = Workspace:FindFirstChild("__OBJECTS")
    if objs and objs:FindFirstChild("Areas") then
        for _, area in pairs(objs.Areas:GetChildren()) do
            table.insert(zones, area.Name)
        end
    end
    return zones
end

-- 9. ระบบ ย้ายเซิฟ (Server Hop / Rejoin)
local function RejoinServer()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end

-- Default Start Screen Message
print("THE CRAFT HUB - Loaded Successfully!")
