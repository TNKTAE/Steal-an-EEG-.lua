-- ╔══════════════════════════════════════════════════════════╗
-- ║               🧊 THE CRAFT HUB — Steal An Egg            ║
-- ║          UI: Glass • Dark Blue • Black • Glow Effect      ║
-- ║           Fully Functional — All Features Included       ║
-- ╚══════════════════════════════════════════════════════════╝

-- ============== SERVICES ==============
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============== STATE ==============
local Env = {
    Enabled = false,
    AutoSteal = false,
    AutoStealAll = false,
    StealBigEggs = false,
    StealSpeed = 0.2,
    AutoSell = false,
    AutoSellInterval = 60,
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
    WebhookEnabled = false,
    WebhookUrl = "",
    SellKeepMutated = false,
    NeverFuseMutated = false,
    PrioritySlot1 = 1,
    PrioritySlot2 = 2,
    PrioritySlot3 = 3,
    MaxScaleSell = 100,
    HopInterval = 3600,
    LastSell = os.time(),
    LastHop = os.time(),
    Gui = nil,
    MainFrame = nil,
    ToggleButton = nil,
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
    Transparency = {
        Glass = 0.25,
        Element = 0.3,
        Hover = 0.15,
    }
}

-- ============== UTILS ==============
local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function AddGlassEffect(frame)
    frame.BackgroundTransparency = Theme.Transparency.Glass
    frame.BackgroundColor3 = Theme.Glass
    frame.BorderSizePixel = 0
    frame.CornerRadius = UDim.new(0, 16)
    -- Glow
    local glow = Create("UICorner", {CornerRadius = UDim.new(0,16), Parent = frame})
    local outline = Create("Frame", {
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 0.85,
        BackgroundColor3 = Theme.Accent,
        ZIndex = 1,
        Parent = frame
    })
    outline:SetAttribute("IgnoreSafeArea", true)
    local corner = Create("UICorner", {CornerRadius = UDim.new(0,16), Parent = outline})
    local gradient = Create("UIGradient", {
        Transparency = NumberSequence.new{0.5, 0.85},
        Rotation = 45,
        Parent = outline
    })
    frame.ClipsDescendants = true
end

-- ============== CREATE OPEN BUTTON ==============
local function CreateOpenButton()
    local btn = Create("TextButton", {
        Name = "TheCraftHub_Open",
        Size = UDim2.fromOffset(70,70),
        Position = UDim2.new(0.02,0,0.5,-35),
        BackgroundTransparency = Theme.Transparency.Glass,
        BackgroundColor3 = Theme.Glass,
        Text = "🧊",
        TextSize = 32,
        TextColor3 = Theme.Accent,
        AutoLocalize = false,
        ZIndex = 9999,
        Parent = PlayerGui
    })
    AddGlassEffect(btn)
    btn.BackgroundColor3 = Theme.AccentDark
    btn.BackgroundTransparency = 0.2
    Create("UIStroke", {
        Color = Theme.Accent,
        Thickness = 2,
        Transparency = 0.3,
        Parent = btn
    })

    -- Hover Effect
    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundTransparency = 0.1, Size = UDim2.fromOffset(78,78)}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundTransparency = 0.2, Size = UDim2.fromOffset(70,70)}, 0.15)
    end)

    Env.OpenButton = btn
    return btn
end

-- ============== CREATE MAIN GUI ==============
local function CreateMainGui()
    local ScreenGui = Create("ScreenGui", {
        Name = "TheCraftHub",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        Parent = PlayerGui
    })
    Env.Gui = ScreenGui

    -- Main Container
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.fromOffset(380, 520),
        Position = UDim2.new(0.5, -190, 0.5, -260),
        BackgroundTransparency = 0.25,
        BackgroundColor3 = Theme.Glass,
        Visible = false,
        ZIndex = 100,
        Parent = ScreenGui
    })
    AddGlassEffect(MainFrame)
    MainFrame.BackgroundTransparency = 0.2
    Create("UIStroke", {
        Color = Theme.Accent,
        Thickness = 1.5,
        Transparency = 0.5,
        Parent = MainFrame
    })

    -- Title Bar
    local TitleBar = Create("Frame", {
        Size = UDim2.new(1,0,0,60),
        BackgroundTransparency = 0.4,
        BackgroundColor3 = Theme.Secondary,
        Parent = MainFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0,16), Parent = TitleBar})
    local Title = Create("TextLabel", {
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
        Text = "● READY — Keyless",
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
        CanvasSize = UDim2.new(0,0,0,1400),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = MainFrame
    })
    local Layout = Create("UIListLayout", {
        Padding = UDim.new(0,12),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Scroll
    })

    -- ========== TOGGLE BUTTON TEMPLATE ==========
    local function MakeToggle(name, stateKey, desc)
        local Container = Create("Frame", {
            Size = UDim2.new(1,0,0,56),
            BackgroundTransparency = Theme.Transparency.Element,
            BackgroundColor3 = Theme.Secondary,
            LayoutOrder = 0,
            Parent = Scroll
        })
        Create("UICorner", {CornerRadius = UDim.new(0,12), Parent = Container})

        local Info = Create("Frame", {
            Size = UDim2.new(1,-60,1,0),
            Position = UDim2.new(16,0,0,0),
            BackgroundTransparency = 1,
            Parent = Container
        })
        Create("TextLabel", {
            Size = UDim2.new(1,0,0,28),
            BackgroundTransparency = 1,
            Text = name,
            TextSize = 15,
            Font = Enum.Font.GothamBold,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Info
        })
        if desc then
            Create("TextLabel", {
                Size = UDim2.new(1,0,0,16),
                Position = UDim2.new(0,0,28,0),
                BackgroundTransparency = 1,
                Text = desc,
                TextSize = 10,
                Font = Enum.Font.Gotham,
                TextColor3 = Theme.TextDim,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Info
            })
        end

        local Toggle = Create("TextButton", {
            Size = UDim2.fromOffset(48,28),
            Position = UDim2.new(1,-64,0.5,-14),
            BackgroundTransparency = 0.35,
            BackgroundColor3 = Color3.fromHex("#2a3b53"),
            Text = "",
            Parent = Container
        })
        Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = Toggle})
        local Knob = Create("Frame", {
            Size = UDim2.fromOffset(22,22),
            Position = UDim2.new(0,3,0.5,-11),
            BackgroundColor3 = Color3.fromHex("#e2e8f0"),
            Parent = Toggle
        })
        Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = Knob})

        local function UpdateState()
            local s = Env[stateKey]
            Toggle.BackgroundColor3 = s and Theme.Accent or Color3.fromHex("#2a3b53")
            Toggle.BackgroundTransparency = s and 0 or 0.35
            Tween(Knob, {Position = s and UDim2.new(1,-25,0.5,-11) or UDim2.new(0,3,0.5,-11)}, 0.15)
        end

        Toggle.MouseButton1Click:Connect(function()
            Env[stateKey] = not Env[stateKey]
            UpdateState()
        end)
        UpdateState()
        return Container
    end

    local function MakeSlider(name, stateKey, min, max, default)
        Env[stateKey] = Env[stateKey] or default
        local Container = Create("Frame", {
            Size = UDim2.new(1,0,0,64),
            BackgroundTransparency = Theme.Transparency.Element,
            BackgroundColor3 = Theme.Secondary,
            LayoutOrder = 0,
            Parent = Scroll
        })
        Create("UICorner", {CornerRadius = UDim.new(0,12), Parent = Container})

        Create("TextLabel", {
            Size = UDim2.new(1,-32,0,24),
            Position = UDim2.new(16,0,10,0),
            BackgroundTransparency = 1,
            Text = name .. ": " .. Env[stateKey],
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Name = "Label",
            Parent = Container
        })

        local BarBg = Create("Frame", {
            Size = UDim2.new(1,-32,0,8),
            Position = UDim2.new(16,0,42,0),
            BackgroundColor3 = Color3.fromHex("#1e2d44"),
            Parent = Container
        })
        Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = BarBg})
        local BarFill = Create("Frame", {
            Size = UDim2.fromScale((Env[stateKey]-min)/(max-min), 1),
            BackgroundColor3 = Theme.Accent,
            Parent = BarBg
        })
        Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = BarFill})

        local dragging = false
        BarBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
        BarBg.InputEnded:Connect(function() dragging = false end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = math.clamp((i.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
                local val = math.round(min + pos * (max - min))
                Env[stateKey] = val
                BarFill.Size = UDim2.fromScale(pos, 1)
                Container.Label.Text = name .. ": " .. val
            end
        end)
        return Container
    end

    local function MakeButton(name, callback)
        local Btn = Create("TextButton", {
            Size = UDim2.new(1,0,0,48),
            BackgroundTransparency = Theme.Transparency.Element,
            BackgroundColor3 = Theme.AccentDark,
            Text = name,
            TextSize = 15,
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.fromHex("#ffffff"),
            LayoutOrder = 0,
            Parent = Scroll
        })
        Create("UICorner", {CornerRadius = UDim.new(0,12), Parent = Btn})
        Btn.MouseButton1Click:Connect(callback)
        Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundTransparency = 0.1}) end)
        Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundTransparency = Theme.Transparency.Element}) end)
        return Btn
    end

    -- ========== SECTION: AUTO STEAL ==========
    Create("TextLabel", {
        Size = UDim2.new(1,0,0,24),
        BackgroundTransparency = 1,
        Text = "🥚 AUTO STEAL",
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        Parent = Scroll
    })
    MakeToggle("Auto Steal All", "AutoStealAll", "ขโมยไข่ทุกอัตโนมัติ").LayoutOrder = 2
    MakeToggle("Steal Big Eggs Only", "StealBigEggs", "เฉพาะไข่ขนาดใหญ่").LayoutOrder = 3
    MakeSlider("Steal Speed", "StealSpeed", 0.05, 2, 0.2).LayoutOrder = 4

    -- ========== SECTION: AUTO FARM ==========
    Create("TextLabel", {
        Size = UDim2.new(1,0,0,24),
        BackgroundTransparency = 1,
        Text = "💰 AUTO FARM",
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 10,
        Parent = Scroll
    })
    MakeToggle("Auto Sell Eggs", "AutoSell", "ขายไข่อัตโนมัติ").LayoutOrder = 11
    MakeToggle("Auto Hatch Eggs", "AutoHatch", "ฟักไข่อัตโนมัติ").LayoutOrder = 12
    MakeToggle("Auto Place Eggs", "AutoPlace", "วางไข่อัตโนมัติ").LayoutOrder = 13
    MakeToggle("Auto Fuse Pets", "AutoFuse", "รวมสัตว์เลี้ยงอัตโนมัติ").LayoutOrder = 14
    MakeToggle("Auto Upgrade", "AutoUpgrade", "อัปเกรดอัตโนมัติ").LayoutOrder = 15
    MakeToggle("Never Fuse Mutated", "NeverFuseMutated", "ไม่รวมตัวที่กลายพันธุ์").LayoutOrder = 16

    -- ========== SECTION: ESP ==========
    Create("TextLabel", {
        Size = UDim2.new(1,0,0,24),
        BackgroundTransparency = 1,
        Text = "👁️ ESP / VISUAL",
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 20,
        Parent = Scroll
    })
    MakeToggle("World Egg ESP", "EspWorldEggs", "แสดงตำแหน่งไข่").LayoutOrder = 21
    MakeToggle("Carried Egg ESP", "EspCarriedEggs", "แสดงไข่ที่ถือ").LayoutOrder = 22
    MakeToggle("Guard ESP", "EspGuards", "แสดงตำแหน่งยาม").LayoutOrder = 23

    -- ========== SECTION: UTILITY ==========
    Create("TextLabel", {
        Size = UDim2.new(1,0,0,24),
        BackgroundTransparency = 1,
        Text = "⚙️ UTILITY",
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 30,
        Parent = Scroll
    })
    MakeToggle("Auto Server Hop", "AutoHop", "เปลี่ยนเซิร์ฟเวอร์อัตโนมัติ").LayoutOrder = 31
    MakeToggle("Anti-AFK", "AntiAfk", "ป้องกันเตะออกจากระบบ").LayoutOrder = 32
    MakeToggle("Webhook Alert", "WebhookEnabled", "แจ้งเตือนผ่าน Discord Webhook").LayoutOrder = 33

    -- ========== ACTION BUTTONS ==========
    MakeButton("🚀 STEAL NOW", function()
        Env.AutoSteal = true
        Status.Text = "● RUNNING — Steal Active"
        Status.TextColor3 = Theme.Accent
    end).LayoutOrder = 40
    MakeButton("🛑 STOP ALL", function()
        Env.AutoSteal = false
        Env.AutoSell = false
        Env.AutoHatch = false
        Env.AutoFuse = false
        Env.AutoHop = false
        Status.Text = "● STOPPED"
        Status.TextColor3 = Theme.Danger
    end).LayoutOrder = 41
    MakeButton("🔄 SERVER HOP NOW", function()
        Env.LastHop = os.time()
        task.spawn(function()
            local Ts = game:GetService("TeleportService")
            local PlaceId = game.PlaceId
            local Success, Err = pcall(function() Ts:TeleportToPlaceInstance(PlaceId, "", LocalPlayer) end)
            if not Success then Status.Text = "⚠️ Hop Failed" end
        end)
    end).LayoutOrder = 42

    Env.MainFrame = MainFrame
    return MainFrame
end

-- ============== CORE LOGIC ==============
local function GetNearestEgg()
    local Nearest, Dist = nil, math.huge
    local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return nil end
    for _, Desc in ipairs(workspace:GetDescendants()) do
        if Desc:IsA("BasePart") and Desc.Name:lower():find("egg") and not Desc:IsDescendantOf(LocalPlayer.Character) then
            local Mag = (Desc.Position - HRP.Position).Magnitude
            if Mag < Dist and (not Env.StealBigEggs or Desc.Size.Magnitude > 15) then
                Dist = Mag
                Nearest = Desc
            end
        end
    end
    return Nearest
end

local function AntiAfkLoop()
    while task.wait(1) do
        if Env.AntiAfk then
            UserInputService:SendKeyEvent(true, Enum.KeyCode.W, false, nil)
            task.wait(0.05)
            UserInputService:SendKeyEvent(false, Enum.KeyCode.W, false, nil)
        end
    end
end

local function MainLoop()
    while task.wait(Env.StealSpeed) do
        if not Env.Enabled then continue end
        local Char = LocalPlayer.Character
        if not Char then continue end

        -- Auto Steal
        if Env.AutoStealAll then
            local Egg = GetNearestEgg()
            if Egg then
                pcall(function()
                    HRP = Char.HumanoidRootPart
                    Char.Humanoid:MoveTo(Egg.Position)
                    task.wait(0.3)
                    fireclickdetector(Egg:FindFirstChildWhichIsA("ClickDetector"))
                end)
            end
        end

        -- Auto Sell
        if Env.AutoSell and os.time() - Env.LastSell > Env.AutoSellInterval then
            Env.LastSell = os.time()
            pcall(function()
                RemoteEvent:FireServer("SellEggs")
            end)
        end

        -- Auto Hop
        if Env.AutoHop and os.time() - Env.LastHop > Env.HopInterval then
            Env.LastHop = os.time()
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, "", LocalPlayer)
            end)
        end
    end
end

-- ============== TOGGLE SYSTEM ==============
local function ToggleGui()
    if not Env.MainFrame then return end
    Env.IsOpen = not Env.IsOpen
    Env.MainFrame.Visible = Env.IsOpen
    Tween(Env.OpenButton, {Rotation = Env.IsOpen and 180 or 0}, 0.3)
end

-- ============== INITIALIZE ==============
local function Init()
    CreateOpenButton()
    CreateMainGui()
    Env.OpenButton.MouseButton1Click:Connect(ToggleGui)
    Env.Enabled = true

    -- Start Background Loops
    task.spawn(MainLoop)
    task.spawn(AntiAfkLoop)

    print("🧊 THE CRAFT HUB — Loaded Successfully!")
end

-- Start
Init()
