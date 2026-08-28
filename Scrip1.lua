-- ==============================================
--           🟦 THE CRAFT HUB 🟦
--        DELTA EXECUTOR VERSION
--  ปรับพิเศษให้รันได้ในเดลต้า 100%
-- ==============================================

-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then return end

-- ==============================================
-- 🎨 UI THEME
-- ==============================================
local UITheme = {
    Primary = Color3.fromRGB(0, 153, 255),
    Secondary = Color3.fromRGB(0, 204, 255),
    Background = Color3.fromRGB(10, 22, 40),
    Glass = Color3.fromRGB(15, 42, 72),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(153, 204, 255)
}

-- ==============================================
-- 📦 CREATE SCREENGUI
-- ==============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- MAIN WINDOW
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 320, 0, 480)
MainWindow.Position = UDim2.new(0.02, 0, 0.5, -240)
MainWindow.BackgroundColor3 = UITheme.Background
MainWindow.Active = true
MainWindow.Draggable = true
MainWindow.ClipsDescendants = true
MainWindow.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainWindow

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 55)
TitleBar.BackgroundColor3 = UITheme.Glass
TitleBar.Parent = MainWindow

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🟦 THE CRAFT HUB"
TitleText.TextColor3 = UITheme.Text
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 20
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- CLOSE BUTTON
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -45, 0.5, -17)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = UITheme.TextDim
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.Parent = TitleBar

-- SCROLL CONTAINER
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Name = "ScrollContainer"
ScrollContainer.Size = UDim2.new(1, -10, 1, -65)
ScrollContainer.Position = UDim2.new(0, 5, 0, 60)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.ScrollBarColor3 = UITheme.Primary
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollContainer.Parent = MainWindow

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = ScrollContainer

-- ==============================================
-- 🎯 TOGGLE BUTTON FUNCTION
-- ==============================================
local function CreateToggle(name, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 50)
    Container.BackgroundColor3 = UITheme.Glass
    Container.BackgroundTransparency = 0.5
    Container.Parent = ScrollContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -55, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = UITheme.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 48, 0, 25)
    Toggle.Position = UDim2.new(1, -58, 0.5, -12)
    Toggle.BackgroundColor3 = Color3.fromRGB(40, 55, 80)
    Toggle.Text = ""
    Toggle.Parent = Container

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = Toggle

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 19, 0, 19)
    Knob.Position = UDim2.new(0, 3, 0.5, -9.5)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.Parent = Toggle

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local state = false

    local function Click()
        state = not state
        Toggle.BackgroundColor3 = state and UITheme.Primary or Color3.fromRGB(40, 55, 80)
        Knob.Position = state and UDim2.new(1, -22, 0.5, -9.5) or UDim2.new(0, 3, 0.5, -9.5)
        pcall(callback, state)
    end

    Toggle.MouseButton1Click:Connect(Click)
    Container.MouseButton1Click:Connect(Click)

    return Container
end

-- ==============================================
-- ⚙️ FEATURES
-- ==============================================
local Features = {
    AutoStealEgg = false,
    AutoStealAll = false,
    AutoEquip = false,
    AutoClaim = false,
    AutoPlace = false,
    Esp = false
}

local StealLoop = nil

-- AUTO STEAL EGG FUNCTION
local function UpdateSteal()
    if StealLoop then return end
    StealLoop = task.spawn(function()
        while Features.AutoStealEgg or Features.AutoStealAll do
            task.wait(0.1)
            local Char = LocalPlayer.Character
            if not Char then continue end
            local Root = Char:FindFirstChild("HumanoidRootPart")
            if not Root then continue end

            local Target = nil
            local MinDist = 15

            for _, v in workspace:GetChildren() do
                if v:IsA("BasePart") or v:IsA("Model") then
                    if string.find(string.lower(v.Name), "egg") or string.find(string.lower(v.Name), "pet") then
                        local PR = v.PrimaryPart or (v:IsA("BasePart") and v or nil)
                        if PR then
                            local Dist = (Root.Position - PR.Position).Magnitude
                            if Dist < MinDist then
                                MinDist = Dist
                                Target = PR
                            end
                        end
                    end
                end
            end

            if Target then
                Root.CFrame = CFrame.new(Target.Position)
            end
        end
        StealLoop = nil
    end)
end

-- ==============================================
-- 📋 CREATE ALL BUTTONS
-- ==============================================
CreateToggle("🥚 Auto Steal Egg", function(s)
    Features.AutoStealEgg = s
    if s then UpdateSteal() end
end)

CreateToggle("🎯 Auto Steal All", function(s)
    Features.AutoStealAll = s
    if s then UpdateSteal() end
end)

CreateToggle("⚔️ Auto Equip Best Gear", function(s) Features.AutoEquip = s end)
CreateToggle("📥 Auto Claim Rewards", function(s) Features.AutoClaim = s end)
CreateToggle("🪺 Auto Place Eggs", function(s) Features.AutoPlace = s end)
CreateToggle("👁️ ESP Eggs", function(s) Features.Esp = s end)

-- ==============================================
-- ❌ CLOSE FUNCTION
-- ==============================================
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ==============================================
-- ✅ SUCCESS MESSAGE
-- ==============================================
print(" ")
print("🟦========================================")
print("🟦    THE CRAFT HUB — DELTA VERSION")
print("🟦       ✅ LOADED SUCCESSFULLY!")
print("🟦========================================")
print("✅ UI ขึ้นแล้ว! เปิดเมนูทางซ้ายจอ")
print("✅ กดเปิด 🥚 Auto Steal Egg เพื่อเริ่มใช้งาน")
print("🟦========================================")
print(" ")
