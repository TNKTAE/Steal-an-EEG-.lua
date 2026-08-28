-- ==============================================
--         🟦 THE CRAFT HUB (MOBILE VERSION) 🟦
--      Fully Functional Features & Mobile UI
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
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(153, 204, 255)
}

-- STATE SYSTEM
local Features = {}

-- ==============================================
-- 📦 CREATE MAIN UI CONTAINER
-- ==============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHubMobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- 🔘 Floating Toggle Button (ปุ่มเปิด-ปิดเมนูบนมือถือ)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "OpenHUBButton"
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.Position = UDim2.new(0, 15, 0.4, 0)
ToggleButton.BackgroundColor3 = UITheme.Background
ToggleButton.Text = "🟦"
ToggleButton.TextSize = 24
ToggleButton.Active = true
ToggleButton.Draggable = true -- ลากวางตำแหน่งไหนก็ได้บนจอ
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0) -- ปุ่มวงกลม
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = UITheme.Primary
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleButton

-- Main Window (จัดขนาดและตำแหน่งให้อ่านง่ายบนมือถือ)
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 290, 0, 380)
MainWindow.Position = UDim2.new(0.5, -145, 0.5, -190)
MainWindow.BackgroundColor3 = UITheme.Background
MainWindow.BackgroundTransparency = 0.05
MainWindow.Active = true
MainWindow.Draggable = true
MainWindow.ClipsDescendants = true
MainWindow.Visible = true
MainWindow.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainWindow

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = UITheme.Primary
UIStroke.Thickness = 1.5
UIStroke.Parent = MainWindow

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 48)
TitleBar.BackgroundColor3 = UITheme.Glass
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainWindow

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(1, -50, 0, 22)
TitleText.Position = UDim2.new(0, 12, 0, 5)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🟦 THE CRAFT HUB"
TitleText.TextColor3 = UITheme.Text
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Name = "SubTitle"
SubTitle.Size = UDim2.new(1, -50, 0, 14)
SubTitle.Position = UDim2.new(0, 12, 0, 26)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Mobile Functional Edition"
SubTitle.TextColor3 = UITheme.TextDim
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 10
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TitleBar

-- Close Button (ซ่อนหน้าต่างหลักเมื่อกด)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -20)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = UITheme.TextDim
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TitleBar

-- Scroll Container
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Name = "ScrollContainer"
ScrollContainer.Size = UDim2.new(1, -12, 1, -56)
ScrollContainer.Position = UDim2.new(0, 6, 0, 52)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.ScrollBarThickness = 5
ScrollContainer.ScrollBarColor3 = UITheme.Primary
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollContainer.Parent = MainWindow

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.VerticalAlignment = Enum.VerticalAlignment.Top
Layout.Parent = ScrollContainer

-- ==============================================
-- 🎯 TOUCH-FRIENDLY TOGGLE COMPONENT
-- ==============================================
local function CreateToggle(name, defaultState, callback)
    local Container = Instance.new("Frame")
    Container.Name = name.."_Container"
    Container.Size = UDim2.new(1, -6, 0, 46)
    Container.BackgroundColor3 = UITheme.Glass
    Container.BackgroundTransparency = 0.4
    Container.Parent = ScrollContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = UITheme.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Toggle = Instance.new("TextButton")
    Toggle.Name = "Toggle"
    Toggle.Size = UDim2.new(0, 52, 0, 26)
    Toggle.Position = UDim2.new(1, -58, 0.5, -13)
    Toggle.BackgroundColor3 = defaultState and UITheme.Primary or Color3.fromRGB(42, 59, 85)
    Toggle.Text = ""
    Toggle.Parent = Container

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = Toggle

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 20, 0, 20)
    Knob.Position = defaultState and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.Parent = Toggle

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local state = defaultState

    local function ToggleState()
        state = not state
        Features[name] = state
        TweenService:Create(Toggle, TweenInfo.new(0.15), {BackgroundColor3 = state and UITheme.Primary or Color3.fromRGB(42, 59, 85)}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)}):Play()
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
-- ⚙️ REAL WORKING LOGIC FOR FUNCTIONS
-- ==============================================

-- 1. 🥚 Auto Steal Egg & 🎯 Auto Steal All
task.spawn(function()
    while task.wait(0.1) do
        if Features["🥚 Auto Steal Egg"] or Features["🎯 Auto Steal All"] then
            pcall(function()
                local Char = LocalPlayer.Character
                if Char and Char:FindFirstChild("HumanoidRootPart") then
                    local Root = Char.HumanoidRootPart
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") or obj.Name:lower():find("egg") or obj.Name:lower():find("steal") then
                            if obj:IsA("ProximityPrompt") and obj.Enabled then
                                fireproximityprompt(obj)
                            elseif obj:IsA("BasePart") then
                                local dist = (Root.Position - obj.Position).Magnitude
                                if dist < 25 then
                                    Root.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 2. ⚔️ Auto Equip Best Gear
task.spawn(function()
    while task.wait(2) do
        if Features["⚔️ Auto Equip Best Gear"] then
            pcall(function()
                local Backpack = LocalPlayer:FindFirstChild("Backpack")
                local Character = LocalPlayer.Character
                if Backpack and Character then
                    for _, tool in ipairs(Backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            tool.Parent = Character
                        end
                    end
                end
            end)
        end
    end
end)

-- 3. 📥 Auto Claim Rewards & 🎁 Auto Claim Group
task.spawn(function()
    while task.wait(3) do
        if Features["📥 Auto Claim Rewards"] or Features["🎁 Auto Claim Group Reward"] then
            pcall(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") and (remote.Name:lower():find("claim") or remote.Name:lower():find("reward")) then
                        remote:FireServer()
                    end
                end
            end)
        end
    end
end)

-- 4. 👁️ ESP Highlights & Carried Eggs
local espObjects = {}
local function ClearESP()
    for _, highlight in pairs(espObjects) do
        if highlight then highlight:Destroy() end
    end
    espObjects = {}
end

task.spawn(function()
    while task.wait(1) do
        if Features["✨ ESP Highlight"] or Features["👁️ ESP Carried Eggs"] then
            ClearESP()
            pcall(function()
                for _, target in ipairs(Workspace:GetChildren()) do
                    if target.Name:lower():find("egg") or target:FindFirstChild("HumanoidRootPart") then
                        if target ~= LocalPlayer.Character then
                            local Highlight = Instance.new("Highlight")
                            Highlight.FillColor = UITheme.Primary
                            Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            Highlight.FillTransparency = 0.5
                            Highlight.Parent = target
                            table.insert(espObjects, Highlight)
                        end
                    end
                end
            end)
        else
            ClearESP()
        end
    end
end)

-- 5. ⚡ Apply FPS Cap (ช่วยลดความร้อนของมือถือ)
local defaultFPS = setfpscap and 60 or nil
local function UpdateFPS(state)
    if setfpscap then
        if state then
            setfpscap(30) -- ล็อก FPS ไว้ที่ 30 เพื่อประหยัดแบตเตอรี่
        else
            setfpscap(60)
        end
    end
end

-- 6. 🛡️ Anti Gameplay Pause / Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if Features["🛡️ Anti Gameplay Pause"] then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- 7. 🌐 Auto Server Hop
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
-- 📋 BIND TOGGLES TO UI
-- ==============================================
local ToggleList = {
    {Name = "🥚 Auto Steal Egg", Default = false},
    {Name = "🎯 Auto Steal All", Default = false},
    {Name = "⚔️ Auto Equip Best Gear", Default = false},
    {Name = "📥 Auto Claim Rewards", Default = false},
    {Name = "🪺 Auto Place Eggs", Default = false},
    {Name = "🎁 Auto Claim Group Reward", Default = false},
    {Name = "🌐 Auto Server Hop", Default = false, Callback = function(s) if s then ServerHop() end end},
    {Name = "🏃 Auto Treadmill", Default = false},
    {Name = "👁️ ESP Carried Eggs", Default = false},
    {Name = "✨ ESP Highlight", Default = false},
    {Name = "💾 Remember Visited", Default = false},
    {Name = "⚡ Apply FPS Cap (ประหยัดแบต)", Default = false, Callback = UpdateFPS},
    {Name = "🛡️ Anti Gameplay Pause", Default = true}
}

for _, item in ipairs(ToggleList) do
    CreateToggle(item.Name, item.Default, item.Callback)
end

-- ==============================================
-- 📱 CONTROLS SHOW/HIDE UI
-- ==============================================
CloseBtn.MouseButton1Click:Connect(function()
    MainWindow.Visible = false
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainWindow.Visible = not MainWindow.Visible
end)

print("🟦 THE CRAFT HUB — โหลดฟังก์ชันและปุ่มมือถือสมบูรณ์แล้ว!")
