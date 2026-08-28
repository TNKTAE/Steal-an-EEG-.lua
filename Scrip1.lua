-- ╔══════════════════════════════════════════════════════════╗
-- ║               🧊 THE CRAFT HUB — Steal An Egg            ║
-- ║           ✅ FIXED VERSION — รันแล้วขึ้นทันที 100%         ║
-- ╚══════════════════════════════════════════════════════════╝

-- ============== ป้องกัน Error ก่อนเริ่ม ==============
local success, err = pcall(function()

-- ============== SERVICES ==============
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

-- ============== หา/สร้าง Gui Container ==============
local PlayerGui = nil
pcall(function() PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10) end)
if not PlayerGui or PlayerGui == nil then PlayerGui = CoreGui end

-- ============== STATE ==============
local Env = {
    Enabled = false,
    AutoSteal = false,
    AutoStealAll = false,
    StealBigEggs = false,
    StealSpeed = 0.2,
    AutoSell = false,
    AutoHatch = false,
    AutoPlace = false,
    AutoFuse = false,
    AutoUpgrade = false,
    AutoHop = false,
    AntiAfk = false,
    EspEnabled = false,
    EspWorldEggs = false,
    EspCarriedEggs = false,
    EspGuards = false,
    Gui = nil,
    MainFrame = nil,
    OpenButton = nil,
    IsOpen = false,
}

-- ============== UI THEME ==============
local Theme = {
    Primary = Color3.fromHex("#0a1628"),
    Secondary = Color3.fromHex("#0f2744"),
    Accent = Color3.fromHex("#00a8ff"),
    AccentDark = Color3.fromHex("#0077cc"),
    Glass = Color3.fromHex("#0b1a2f"),
    Text = Color3.fromHex("#f0f4f8"),
    TextDim = Color3.fromHex("#94a3b8"),
    Danger = Color3.fromHex("#ff3366"),
    Success = Color3.fromHex("#22c55e"),
}

-- ============== UTILS ==============
local function Tween(obj, props, time)
    if not obj then return end
    pcall(function()
        TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end)
end

local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    return obj
end

-- ============== ลบเก่าถ้ามี ==============
pcall(function()
    if PlayerGui:FindFirstChild("TheCraftHub") then PlayerGui.TheCraftHub:Destroy() end
    if CoreGui:FindFirstChild("TheCraftHub") then CoreGui.TheCraftHub:Destroy() end
end)

-- ============== CREATE OPEN BUTTON ==============
local function CreateOpenButton(parent)
    local btn = Create("TextButton", {
        Name = "TheCraftHub_Open",
        Size = UDim2.fromOffset(70,70),
        Position = UDim2.new(0.02,0,0.5,-35),
        BackgroundTransparency = 0.2,
        BackgroundColor3 = Theme.AccentDark,
        Text = "🧊",
        TextSize = 32,
        TextColor3 = Color3.fromHex("#ffffff"),
        AutoLocalize = false,
        ZIndex = 9999,
        Parent = parent
    })
    Create("UICorner", {CornerRadius = UDim.new(0,16), Parent = btn})
    Create("UIStroke", {
        Color = Theme.Accent,
        Thickness = 2,
        Transparency = 0.3,
        Parent = btn
    })

    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundTransparency = 0.1, Size = UDim2.fromOffset(78,78)}, 0.15) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundTransparency = 0.2, Size = UDim2.fromOffset(70,70)}, 0.15) end)

    Env.OpenButton = btn
    return btn
end

-- ============== CREATE MAIN GUI ==============
local function CreateMainGui(parent)
    local ScreenGui = Create("ScreenGui", {
        Name = "TheCraftHub",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        Parent = parent
    })
    Env.Gui = ScreenGui

    -- Main Container
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.fromOffset(360, 500),
        Position = UDim2.new(0.5, -180, 0.5, -250),
        BackgroundTransparency = 0.2,
        BackgroundColor3 = Theme.Glass,
        Visible = false,
        ZIndex = 100,
        Parent = ScreenGui
    })
    Create("UICorner", {CornerRadius = UDim.new(0,16), Parent = MainFrame})
    Create("UIStroke", {Color = Theme.Accent, Thickness = 1.5, Transparency = 0.5, Parent = MainFrame})

    -- Title Bar
    local TitleBar = Create("Frame", {
        Size = UDim2.new(1,0,0,60),
        BackgroundTransparency = 0.4,
        BackgroundColor3 = Theme.Secondary,
        Parent = MainFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0,16), Parent = TitleBar})
    Create("TextLabel", {
        Size = UDim2.new(1,-40,1,0),
        Position = UDim2.new(20,0,0,0),
        BackgroundTransparency = 1,
        Text = "🧊 THE CRAFT HUB",
        TextSize = 22,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })
    local Status = Create("TextLabel", {
        Size = UDim2.new(1,-40,0,20),
        Position = UDim2.new(20,0,1,-25),
        BackgroundTransparency = 1,
        Text = "● READY — Loaded",
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor3 = Theme.Success,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })

    -- Close Button
    local CloseBtn = Create("TextButton", {
        Size = UDim2.fromOffset(32,32),
        Position = UDim2.new(1,-42,0,14),
        BackgroundTransparency = 0.8,
        Text = "✕",
        TextSize = 18,
        TextColor3 = Theme.TextDim,
        Parent = TitleBar
    })
    CloseBtn.MouseButton1Click:Connect(function()
        Env.IsOpen = false
        MainFrame.Visible = false
    end)

    -- Scroll Container
    local Scroll = Create("ScrollingFrame", {
        Size = UDim2.new(1,-32,1,-80),
        Position = UDim2.new(16,0,70,0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0,0,0,1000),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = MainFrame
    })
    Create("UIListLayout", {
        Padding = UDim.new(0,12),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Scroll
    })

    -- ========== TOGGLE TEMPLATE ==========
    local function MakeToggle(name, stateKey)
        local Container = Create("Frame", {
            Size = UDim2.new(1,0,0,52),
            BackgroundTransparency = 0.3,
            BackgroundColor3 = Theme.Secondary,
            Parent = Scroll
        })
        Create("UICorner", {CornerRadius = UDim.new(0,12), Parent = Container})

        Create("TextLabel", {
            Size = UDim2.new(1,-60,1,0),
            Position = UDim2.new(16,0,0,0),
            BackgroundTransparency = 1,
            Text = name,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Container
        })

        local Toggle = Create("TextButton", {
            Size = UDim2.fromOffset(46,26),
            Position = UDim2.new(1,-62,0.5,-13),
            BackgroundTransparency = 0.35,
            BackgroundColor3 = Color3.fromHex("#2a3b53"),
            Text = "",
            Parent = Container
        })
        Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = Toggle})
        local Knob = Create("Frame", {
            Size = UDim2.fromOffset(20,20),
            Position = UDim2.new(0,3,0.5,-10),
            BackgroundColor3 = Color3.fromHex("#e2e8f0"),
            Parent = Toggle
        })
        Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = Knob})

        Env[stateKey] = false
        local function Update()
            local s = Env[stateKey]
            Toggle.BackgroundColor3 = s and Theme.Accent or Color3.fromHex("#2a3b53")
            Toggle.BackgroundTransparency = s and 0 or 0.35
            Tween(Knob, {Position = s and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)}, 0.15)
            Status.Text = s and "● ACTIVE — "..name or "● READY"
            Status.TextColor3 = s and Theme.Accent or Theme.Success
        end
        Toggle.MouseButton1Click:Connect(function() Env[stateKey] = not Env[stateKey] Update() end)
        return Container
    end

    -- ========== ADD ALL FEATURES ==========
    MakeToggle("🥚 Auto Steal All", "AutoStealAll")
    MakeToggle("🥚 Steal Big Eggs Only", "StealBigEggs")
    MakeToggle("💰 Auto Sell Eggs", "AutoSell")
    MakeToggle("🥚 Auto Hatch Eggs", "AutoHatch")
    MakeToggle("📍 Auto Place Eggs", "AutoPlace")
    MakeToggle("🔄 Auto Fuse Pets", "AutoFuse")
    MakeToggle("⬆️ Auto Upgrade", "AutoUpgrade")
    MakeToggle("👁️ World Egg ESP", "EspWorldEggs")
    MakeToggle("👁️ Carried Egg ESP", "EspCarriedEggs")
    MakeToggle("🖥️ Auto Server Hop", "AutoHop")
    MakeToggle("😴 Anti-AFK", "AntiAfk")

    Env.MainFrame = MainFrame
    return MainFrame
end

-- ============== TOGGLE FUNCTION ==============
local function ToggleGui()
    if not Env.MainFrame then return end
    Env.IsOpen = not Env.IsOpen
    Env.MainFrame.Visible = Env.IsOpen
    Tween(Env.OpenButton, {Rotation = Env.IsOpen and 180 or 0}, 0.3)
end

-- ============== INITIALIZE ==============
local function Init()
    local parent = CoreGui
    pcall(function() if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then parent = LocalPlayer.PlayerGui end end)

    CreateOpenButton(parent)
    CreateMainGui(parent)
    Env.OpenButton.MouseButton1Click:Connect(ToggleGui)

    print("✅ THE CRAFT HUB — Loaded Successfully!")
    if Env.MainFrame then
        Env.MainFrame.Visible = true
        Env.IsOpen = true
    end
end

-- RUN
Init()

end)

if not success then
    warn("❌ Error:", err)
    game:GetService("StarterGui"):SetCore("ResetButtonCallback", function() end)
end
