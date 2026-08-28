-- ==========================================
-- THE CRAFT HUB - Ultra Professional Vector Edition
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
    -- Player & Movement
    WalkSpeed = 16,
    WalkSpeedBypass = false,
    FastAttack = false,
    AutoHoldEgg = true, -- ถือไข่อัตโนมัติเมื่อตกใส่มือ
    AutoReturnBase = true, -- ถือไข่ในมือแล้ววาร์ปกลับฐาน
    AntiAFK = false,

    -- Eggs & Stealing
    AutoStealEgg = false,
    InstantCollectEgg = true, -- กดเก็บไข่ทันที ไม่ต้องกดค้าง
    KeepEggs = false,

    -- Event
    AutoBlueTreeEvent = false,

    -- Visuals (ESP)
    ESP_Eggs = false,
    ESP_Players = false
}

local ESP_Storage = { Egg = {}, Player = {} }
local BasePosition = nil

-- บันทึกพิกัดฐานเริ่มต้น
local function UpdateBasePosition()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp then
        BasePosition = hrp.CFrame
    end
end
UpdateBasePosition()
LocalPlayer.CharacterAdded:Connect(UpdateBasePosition)

-- ==========================================
-- 2. CORE REAL-WORKING FUNCTIONS
-- ==========================================

-- ระบบ WalkSpeed
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

-- ระบบตีไว (Fast Attack)
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

-- ระบบถือไข่อัตโนมัติ + ถือไข่แล้ววาร์ปกลับฐานทันที
task.spawn(function()
    while true do
        task.wait(0.05)
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

            local isHoldingEgg = false

            -- 1. ย้ายไข่จาก Backpack มาใส่เข้ามือทันที
            if Config.AutoHoldEgg and backpack then
                for _, item in pairs(backpack:GetChildren()) do
                    if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
                        item.Parent = char
                        isHoldingEgg = true
                    end
                end
            end

            -- 2. ตรวจสอบว่าในมือถือไข่อยู่หรือไม่
            if char then
                for _, item in pairs(char:GetChildren()) do
                    if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
                        isHoldingEgg = true
                    end
                end
            end

            -- 3. หากถือไข่อยู่ในมือแล้ว วาร์ปกลับฐานทันที
            if Config.AutoReturnBase and isHoldingEgg and hrp and BasePosition then
                hrp.CFrame = BasePosition
                task.wait(0.2)
            end
        end)
    end
end)

-- ระบบขโมยไข่ + กดเก็บไข่ทันที (Instant Bypass)
task.spawn(function()
    while true do
        task.wait(0.03)
        if Config.AutoStealEgg or Config.InstantCollectEgg then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, obj in pairs(workspace:GetDescendants()) do
                    if not (Config.AutoStealEgg or Config.InstantCollectEgg) then break end

                    local nameLower = string.lower(obj.Name)
                    local isEgg = string.find(nameLower, "egg") or obj:GetAttribute("Egg")

                    if isEgg then
                        local targetPart = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                        if targetPart then

                            -- วาร์ปไปหาไข่
                            if Config.AutoStealEgg then
                                hrp.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 1.5, 0))
                            end

                            -- Bypass กดเก็บไข่ทันทีไม่ต้องกดค้าง
                            local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChild("Prompt", true)
                            local clicker = obj:FindFirstChildOfClass("ClickDetector")

                            if prompt then
                                prompt.HoldDuration = 0
                                if fireproximityprompt then
                                    fireproximityprompt(prompt)
                                end
                            elseif clicker and fireclickdetector then
                                fireclickdetector(clicker)
                            elseif firetouchinterest then
                                firetouchinterest(hrp, targetPart, 0)
                                firetouchinterest(hrp, targetPart, 1)
                            end

                            task.wait(0.02)
                        end
                    end
                end
            end)
        end
    end
end)

-- ระบบตีต้นไม้ฟ้าอัตโนมัติ
task.spawn(function()
    while true do
        task.wait(0.08)
        if Config.AutoBlueTreeEvent then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                if backpack then
                    local tool = backpack:FindFirstChildOfClass("Tool")
                    if tool then tool.Parent = char end
                end

                for _, obj in pairs(workspace:GetDescendants()) do
                    if not Config.AutoBlueTreeEvent then break end

                    local nameLower = string.lower(obj.Name)
                    local isBlueTree = string.find(nameLower, "bluetree") or string.find(nameLower, "blue tree") or (string.find(nameLower, "tree") and string.find(nameLower, "blue"))

                    if isBlueTree then
                        local targetPart = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                        if targetPart then
                            hrp.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 2, 3))

                            local tool = char:FindFirstChildOfClass("Tool")
                            if tool then
                                tool:Activate()
                                if firetouchinterest and tool:FindFirstChild("Handle") then
                                    firetouchinterest(tool.Handle, targetPart, 0)
                                    firetouchinterest(tool.Handle, targetPart, 1)
                                end
                            end
                            task.wait(0.05)
                        end
                    end
                end
            end)
        end
    end
end)

-- ระบบ ESP
local function UpdateESP(targetType, enable)
    if ESP_Storage[targetType] then
        for _, v in pairs(ESP_Storage[targetType]) do
            if v then v:Destroy() end
        end
        ESP_Storage[targetType] = {}
    end

    if not enable then return end

    task.spawn(function()
        if targetType == "Player" then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local char = plr.Character
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "HUB_ESP_Player"
                    highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    highlight.FillTransparency = 0.4
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Adornee = char
                    highlight.Parent = CoreGui

                    local bb = Instance.new("BillboardGui")
                    bb.Size = UDim2.new(0, 140, 0, 30)
                    bb.AlwaysOnTop = true
                    bb.Adornee = char:FindFirstChild("Head") or char.HumanoidRootPart
                    bb.Parent = highlight

                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
                    txt.TextColor3 = Color3.fromRGB(255, 100, 100)
                    txt.Font = Enum.Font.GothamBold
                    txt.TextSize = 10
                    txt.Parent = bb

                    table.insert(ESP_Storage["Player"], highlight)
                end
            end
        elseif targetType == "Egg" then
            for _, obj in pairs(workspace:GetDescendants()) do
                local nameLower = string.lower(obj.Name)
                if string.find(nameLower, "egg") and (obj:IsA("Model") or obj:IsA("BasePart")) then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "HUB_ESP_Egg"
                    highlight.FillColor = Color3.fromRGB(0, 170, 255)
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
                    txt.Text = obj.Name
                    txt.TextColor3 = Color3.fromRGB(0, 170, 255)
                    txt.Font = Enum.Font.GothamBold
                    txt.TextSize = 10
                    txt.Parent = bb

                    table.insert(ESP_Storage["Egg"], highlight)
                end
            end
        end
    end)
end

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ==========================================
-- 3. PERFECT VECTOR UI CREATION
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
MainFrame.Size = UDim2.new(0, 680, 0, 370)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -185)
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

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(3, 5, 10)
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 8)
TopBarCorner.Parent = TopBar

-- Vector Logo Icon
local LogoIcon = Instance.new("ImageLabel")
LogoIcon.Size = UDim2.new(0, 22, 0, 22)
LogoIcon.Position = UDim2.new(0, 12, 0, 11)
LogoIcon.BackgroundTransparency = 1
LogoIcon.Image = "rbxassetid://6031068421" -- Vector Shield / Hub Icon
LogoIcon.ImageColor3 = Color3.fromRGB(0, 170, 255)
LogoIcon.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 140, 1, 0)
TitleLabel.Position = UDim2.new(0, 40, 0, 0)
TitleLabel.Text = "THE CRAFT HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = TopBar

-- Vector Close Button
local CloseBtn = Instance.new("ImageButton")
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -32, 0, 12)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Image = "rbxassetid://6031094678" -- Vector Close X Icon
CloseBtn.ImageColor3 = Color3.fromRGB(180, 180, 180)
CloseBtn.Parent = TopBar

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -210, 1, 0)
TabBar.Position = UDim2.new(0, 170, 0, 0)
TabBar.BackgroundTransparency = 1
TabBar.Parent = TopBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabBar
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -24, 1, -60)
ContentContainer.Position = UDim2.new(0, 12, 0, 52)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local Tabs, Pages = {}, {}

local function CreateTab(tabName, iconAssetId)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 110, 0, 30)
    TabBtn.Position = UDim2.new(0, 0, 0, 7)
    TabBtn.BackgroundColor3 = Color3.fromRGB(12, 18, 30)
    TabBtn.Text = "    " .. tabName
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 10
    TabBtn.Parent = TabBar

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 5)
    TabCorner.Parent = TabBtn

    if iconAssetId then
        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Size = UDim2.new(0, 14, 0, 14)
        TabIcon.Position = UDim2.new(0, 8, 0.5, -7)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = iconAssetId
        TabIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
        TabIcon.Parent = TabBtn
    end

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
            local ic = t:FindFirstChildOfClass("ImageLabel")
            if ic then ic.ImageColor3 = Color3.fromRGB(150, 150, 150) end
        end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 32, 55)
        local ic = TabBtn:FindFirstChildOfClass("ImageLabel")
        if ic then ic.ImageColor3 = Color3.fromRGB(0, 170, 255) end
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
    Frame.Size = UDim2.new(1, -10, 0, 38)
    Frame.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
    Frame.Parent = parentPage

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 50, 0, 22)
    Button.Position = UDim2.new(1, -60, 0.5, -11)
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
    Button.Size = UDim2.new(1, -10, 0, 36)
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
    Frame.Size = UDim2.new(1, -10, 0, 38)
    Frame.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
    Frame.Parent = parentPage

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0.42, 0, 0, 24)
    TextBox.Position = UDim2.new(0.55, 0, 0.5, -12)
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

local PlayerPage = CreateTab("PLAYER", "rbxassetid://6034287525")
local EggPage = CreateTab("EGGS", "rbxassetid://6031082533")
local EventPage = CreateTab("EVENT", "rbxassetid://6031075931")
local VisualPage = CreateTab("VISUALS", "rbxassetid://6031075929")
local MiscPage = CreateTab("SETTINGS", "rbxassetid://6031280882")

-- แท็บ 1: PLAYER
AddToggle(PlayerPage, "Auto Fast Attack (ตีไวอัตโนมัติ)", "FastAttack")
AddToggle(PlayerPage, "Auto Hold Egg (ถือไข่อัตโนมัติเมื่อเข้ากระเป๋า)", "AutoHoldEgg")
AddToggle(PlayerPage, "Enable WalkSpeed Bypass", "WalkSpeedBypass")

AddInputBox(PlayerPage, "Custom WalkSpeed (0 - 2000):", "Ex. 500", function(text)
    local num = tonumber(text)
    if num then
        if num > 2000 then num = 2000 end
        Config.WalkSpeed = num
    end
end)

AddButton(PlayerPage, "Set Speed Max (2000)", function() Config.WalkSpeed = 2000 Config.WalkSpeedBypass = true end)
AddButton(PlayerPage, "Reset Speed (16)", function() Config.WalkSpeed = 16 Config.WalkSpeedBypass = false end)

-- แท็บ 2: EGGS
AddToggle(EggPage, "Auto Steal Egg (ขโมยไข่อัตโนมัติ)", "AutoStealEgg")
AddToggle(EggPage, "Instant Collect Egg (กดเก็บไข่ทันที ไม่ต้องกดค้าง)", "InstantCollectEgg")
AddToggle(EggPage, "Auto Return Base On Hold (ถือไข่ในมือแล้วกลับฐาน)", "AutoReturnBase")
AddToggle(EggPage, "Keep Eggs (เก็บไข่ไว้ไม่ขาย)", "KeepEggs")

AddButton(EggPage, "Set Current Position As Base", function()
    UpdateBasePosition()
    print("[THE CRAFT HUB] Base Position Set!")
end)

-- แท็บ 3: EVENT
AddToggle(EventPage, "Auto Farm Blue Tree (ตีต้นไม้ฟ้าอัตโนมัติ)", "AutoBlueTreeEvent")

-- แท็บ 4: VISUALS
AddToggle(VisualPage, "Player ESP (มองเห็นผู้เล่น)", "ESP_Players", function(val)
    UpdateESP("Player", val)
end)
AddToggle(VisualPage, "Egg ESP (มองเห็นไข่)", "ESP_Eggs", function(val)
    UpdateESP("Egg", val)
end)

-- แท็บ 5: SETTINGS
AddToggle(MiscPage, "Anti-AFK (ป้องกันหลุดเกม)", "AntiAFK")

AddButton(MiscPage, "Server Hop (ย้ายเซิร์ฟเวอร์)", function()
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

-- เลือกแท็บแรกเริ่มต้น
Tabs[1].TextColor3 = Color3.fromRGB(0, 170, 255)
Tabs[1].BackgroundColor3 = Color3.fromRGB(20, 32, 55)
local firstIcon = Tabs[1]:FindFirstChildOfClass("ImageLabel")
if firstIcon then firstIcon.ImageColor3 = Color3.fromRGB(0, 170, 255) end
Pages[1].Visible = true

-- ปุ่มลอยเปิด/ปิด GUI (Vector Floating Toggle)
local ToggleGuiBtn = Instance.new("ImageButton")
ToggleGuiBtn.Name = "ToggleCraftHub"
ToggleGuiBtn.Size = UDim2.new(0, 42, 0, 42)
ToggleGuiBtn.Position = UDim2.new(0, 15, 0.18, 0)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(6, 10, 18)
ToggleGuiBtn.Image = "rbxassetid://6031068421" -- Vector Shield Asset
ToggleGuiBtn.ImageColor3 = Color3.fromRGB(0, 150, 255)
ToggleGuiBtn.Active = true
ToggleGuiBtn.Draggable = true
ToggleGuiBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleGuiBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(0, 102, 255)
ToggleStroke.Thickness = 1.5
ToggleStroke.Parent = ToggleGuiBtn

ToggleGuiBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

print("[THE CRAFT HUB] Complete Vector UI Edition Loaded Successfully!")
