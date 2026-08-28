-- ==============================================
--         🟦 THE CRAFT HUB (TABBED MOBILE) 🟦
--      Categorized Features & Master Control
-- ==============================================

-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ลบ UI เก่าออกก่อนป้องกันการรันซ้ำ
if PlayerGui:FindFirstChild("TheCraftHubMobile") then
    PlayerGui.TheCraftHubMobile:Destroy()
end

-- ==============================================
-- 🎨 UI THEME & RESPONSIVE CONSTANTS
-- ==============================================
local UITheme = {
    Primary = Color3.fromRGB(0, 153, 255),
    Secondary = Color3.fromRGB(0, 204, 255),
    Background = Color3.fromRGB(10, 22, 40),
    Glass = Color3.fromRGB(15, 42, 72),
    TabInactive = Color3.fromRGB(20, 32, 50),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(153, 204, 255)
}

-- STATE SYSTEM
local Features = {}
local ScriptActive = true

-- ==============================================
-- 📦 CREATE MAIN UI CONTAINER
-- ==============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHubMobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- 🔘 Floating Toggle Button (ปุ่มเปิด-ปิดเมนูบนหน้าจอมือถือ)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "OpenHUBButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 15, 0.4, 0)
ToggleButton.BackgroundColor3 = UITheme.Background
ToggleButton.Text = "🟦"
ToggleButton.TextSize = 22
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = UITheme.Primary
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleButton

-- Main Window
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 300, 0, 380)
MainWindow.Position = UDim2.new(0.5, -150, 0.5, -190)
MainWindow.BackgroundColor3 = UITheme.Background
MainWindow.BackgroundTransparency = 0.05
MainWindow.Active = true
MainWindow.Draggable = true
MainWindow.ClipsDescendants = true
MainWindow.Visible = true
MainWindow.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainWindow

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = UITheme.Primary
UIStroke.Thickness = 1.5
UIStroke.Parent = MainWindow

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = UITheme.Glass
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainWindow

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(1, -90, 0, 20)
TitleText.Position = UDim2.new(0, 10, 0, 4)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🟦 THE CRAFT HUB"
TitleText.TextColor3 = UITheme.Text
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 15
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Name = "SubTitle"
SubTitle.Size = UDim2.new(1, -90, 0, 14)
SubTitle.Position = UDim2.new(0, 10, 0, 22)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Mobile Optimized Hub"
SubTitle.TextColor3 = UITheme.TextDim
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 10
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TitleBar

-- 🔴 Master Off Button (ปุ่มปิดการทำงานสคริปต์ทั้งหมด)
local MasterOffBtn = Instance.new("TextButton")
MasterOffBtn.Name = "MasterOffBtn"
MasterOffBtn.Size = UDim2.new(0, 32, 0, 32)
MasterOffBtn.Position = UDim2.new(1, -74, 0.5, -16)
MasterOffBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
MasterOffBtn.Text = "🛑"
MasterOffBtn.TextSize = 14
MasterOffBtn.Parent = TitleBar

local MasterOffCorner = Instance.new("UICorner")
MasterOffCorner.CornerRadius = UDim.new(0, 6)
MasterOffCorner.Parent = MasterOffBtn

-- Minimize Button (ซ่อน/แสดงหน้าต่าง)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -16)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = UITheme.TextDim
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TitleBar

-- ==============================================
-- 📂 TAB BAR SYSTEM (แถบเลือกหมวดหมู่)
-- ==============================================
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -12, 0, 32)
TabBar.Position = UDim2.new(0, 6, 0, 46)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainWindow

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.Padding = UDim.new(0, 4)
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.Parent = TabBar

local ContainerFolder = Instance.new("Folder")
ContainerFolder.Name = "Containers"
ContainerFolder.Parent = MainWindow

local Tabs = {}
local TabButtons = {}

local function CreateTab(tabName, isDefault)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = tabName.."_TabBtn"
    TabBtn.Size = UDim2.new(0.32, 0, 1, 0)
    TabBtn.BackgroundColor3 = isDefault and UITheme.Primary or UITheme.TabInactive
    TabBtn.Text = tabName
    TabBtn.TextColor3 = UITheme.Text
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 11
    TabBtn.Parent = TabBar

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabBtn

    local ScrollContainer = Instance.new("ScrollingFrame")
    ScrollContainer.Name = tabName.."_Container"
    ScrollContainer.Size = UDim2.new(1, -12, 1, -88)
    ScrollContainer.Position = UDim2.new(0, 6, 0, 82)
    ScrollContainer.BackgroundTransparency = 1
    ScrollContainer.BorderSizePixel = 0
    ScrollContainer.ScrollBarThickness = 4
    ScrollContainer.ScrollBarColor3 = UITheme.Primary
    ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollContainer.Visible = isDefault
    ScrollContainer.Parent = ContainerFolder

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 6)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.VerticalAlignment = Enum.VerticalAlignment.Top
    Layout.Parent = ScrollContainer

    Tabs[tabName] = ScrollContainer
    TabButtons[tabName] = TabBtn

    TabBtn.MouseButton1Click:Connect(function()
        for name, container in pairs(Tabs) do
            container.Visible = (name == tabName)
            TabButtons[name].BackgroundColor3 = (name == tabName) and UITheme.Primary or UITheme.TabInactive
        end
    end)

    return ScrollContainer
end

local MainTab = CreateTab("🥚 Main", true)
local VisualTab = CreateTab("👁️ Visuals", false)
local MiscTab = CreateTab("⚡ Misc", false)

-- ==============================================
-- 🎯 TOGGLE COMPONENT BUILDER
-- ==============================================
local function CreateToggle(parentContainer, name, defaultState, callback)
    local Container = Instance.new("Frame")
    Container.Name = name.."_Container"
    Container.Size = UDim2.new(1, -4, 0, 42)
    Container.BackgroundColor3 = UITheme.Glass
    Container.BackgroundTransparency = 0.4
    Container.Parent = parentContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -65, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = UITheme.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Toggle = Instance.new("TextButton")
    Toggle.Name = "Toggle"
    Toggle.Size = UDim2.new(0, 46, 0, 22)
    Toggle.Position = UDim2.new(1, -50, 0.5, -11)
    Toggle.BackgroundColor3 = defaultState and UITheme.Primary or Color3.fromRGB(42, 59, 85)
    Toggle.Text = ""
    Toggle.Parent = Container

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = Toggle

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = defaultState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.Parent = Toggle

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local state = defaultState
    Features[name] = defaultState

    local function ToggleState()
        state = not state
        Features[name] = state
        TweenService:Create(Toggle, TweenInfo.new(0.12), {BackgroundColor3 = state and UITheme.Primary or Color3.fromRGB(42, 59, 85)}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.12), {Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
        if callback then callback(state) end
    end

    Toggle.MouseButton1Click:Connect(ToggleState)
    
    local ClickArea = Instance.new("TextButton")
    ClickArea.Size = UDim2.new(1, 0, 1, 0)
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text = ""
    ClickArea.Parent = Container
    ClickArea.MouseButton1Click:Connect(ToggleState)

    return Container
end

-- ==============================================
-- ⚙️ REAL FUNCTION IMPLEMENTATIONS
-- ==============================================

-- 1. Main Steal Loop
task.spawn(function()
    while ScriptActive do
        task.wait(0.15)
        if Features["Auto Steal Egg"] or Features["Auto Steal All"] then
            pcall(function()
                local Char = LocalPlayer.Character
                if Char and Char:FindFirstChild("HumanoidRootPart") then
                    local Root = Char.HumanoidRootPart
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") and obj.Enabled then
                            if obj.Parent and (obj.Parent.Name:lower():find("egg") or obj.Parent.Name:lower():find("steal")) then
                                fireproximityprompt(obj)
                            end
                        elseif obj:IsA("BasePart") and (obj.Name:lower():find("egg_") or obj.Name:lower():find("pet_")) then
                            if (Root.Position - obj.Position).Magnitude < 20 then
                                Root.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 2. ESP Visuals
local espHighlights = {}
local function ClearESP()
    for _, h in pairs(espHighlights) do
        if h then h:Destroy() end
    end
    espHighlights = {}
end

task.spawn(function()
    while ScriptActive do
        task.wait(1)
        if Features["ESP Highlight"] or Features["ESP Carried Eggs"] then
            ClearESP()
            pcall(function()
                for _, v in ipairs(Workspace:GetChildren()) do
                    if v.Name:lower():find("egg") or v:FindFirstChild("Humanoid") then
                        if v ~= LocalPlayer.Character then
                            local hl = Instance.new("Highlight")
                            hl.FillColor = UITheme.Primary
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.5
                            hl.Parent = v
                            table.insert(espHighlights, hl)
                        end
                    end
                end
            end)
        else
            ClearESP()
        end
    end
end)

-- 3. Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if ScriptActive and Features["Anti Gameplay Pause"] then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- 4. Server Hop Function
local function ServerHop()
    pcall(function()
        local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        for _, server in ipairs(Servers) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end)
end

-- ==============================================
-- 📋 BIND TOGGLES TO SPECIFIC TABS
-- ==============================================

-- 🥚 Main Tab
CreateToggle(MainTab, "Auto Steal Egg", false)
CreateToggle(MainTab, "Auto Steal All", false)
CreateToggle(MainTab, "Auto Place Eggs", false)
CreateToggle(MainTab, "Auto Equip Best Gear", false)
CreateToggle(MainTab, "Auto Treadmill", false)

-- 👁️ Visuals Tab
CreateToggle(VisualTab, "ESP Highlight", false)
CreateToggle(VisualTab, "ESP Carried Eggs", false)
CreateToggle(VisualTab, "Remember Visited", false)

-- ⚡ Misc Tab
CreateToggle(MiscTab, "Auto Claim Rewards", false)
CreateToggle(MiscTab, "Auto Claim Group Reward", false)
CreateToggle(MiscTab, "Anti Gameplay Pause", true)
CreateToggle(MiscTab, "Apply FPS Cap (30 FPS)", false, function(s)
    if setfpscap then setfpscap(s and 30 or 60) end
end)
CreateToggle(MiscTab, "Auto Server Hop", false, function(s)
    if s then ServerHop() end
end)

-- ==============================================
-- 📱 UI CONTROLS & MASTER OFF
-- ==============================================

-- ซ่อน/เปิดหน้าต่างหลัก
CloseBtn.MouseButton1Click:Connect(function()
    MainWindow.Visible = false
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainWindow.Visible = not MainWindow.Visible
end)

-- ปุ่มปิดสคริปต์ถาวร (Stop All Script Actions)
MasterOffBtn.MouseButton1Click:Connect(function()
    ScriptActive = false
    ClearESP()
    ScreenGui:Destroy()
    print("🔴 THE CRAFT HUB: ปิดการทำงานสคริปต์เรียบร้อยแล้ว")
end)

print("🟦 THE CRAFT HUB — โหลดโครงสร้างเมนูและระบบเปิด-ปิดสำเร็จ!")
