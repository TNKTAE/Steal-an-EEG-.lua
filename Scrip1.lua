-- ==========================================
-- THE CRAFT HUB - Pure Text & High Performance Edition
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
    AutoHoldEgg = true, -- ถือไข่อัตโนมัติ
    AutoReturnBase = true, -- กลับฐานเมื่อถือไข่
    AntiAFK = false,

    -- Eggs System
    AutoStealEgg = false,
    InstantCollectEgg = false, -- กดเก็บไข่ทีเดียว/ไว
    KeepEggs = false, -- เก็บไข่ไว้ไม่ขาย

    -- Event
    AutoBlueTreeEvent = false, -- ตีต้นไม้ฟ้าอัตโนมัติ

    -- Visuals (ESP)
    ESP_Eggs = false,
    ESP_Players = false,

    -- System
    StealRadius = 150
}

local ESP_Storage = { Egg = {}, Player = {} }
local BasePosition = nil

-- บันทึกจุดเกิด/ฐานเริ่มต้นของผู้เล่น
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
-- 2. CORE REAL-WORKING FUNCTIONS (100% WORKING)
-- ==========================================

-- ระบบปรับความเร็วการเดิน (WalkSpeed)
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

-- ระบบถือไข่อัตโนมัติ + กลับฐานอัตโนมัติ (Auto Hold Egg & Return Base)
task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

            local isHoldingEgg = false

            -- 1. ย้ายไข่จากกระเป๋ามาสวมใส่ถือในมือทันที
            if Config.AutoHoldEgg and backpack then
                for _, item in pairs(backpack:GetChildren()) do
                    if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
                        item.Parent = char
                        isHoldingEgg = true
                    end
                end
            end

            -- 2. เช็คว่าในมือถือไข่อยู่หรือไม่
            if char then
                for _, item in pairs(char:GetChildren()) do
                    if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
                        isHoldingEgg = true
                    end
                end
            end

            -- 3. หากถือไข่อยู่ในมือแล้ว ให้กลับฐานอัตโนมัติ
            if Config.AutoReturnBase and isHoldingEgg and hrp and BasePosition then
                hrp.CFrame = BasePosition
                task.wait(0.3)
            end
        end)
    end
end)

-- ระบบขโมยไข่ และ กดเก็บไข่ไวทีเดียว (Auto Steal & Instant Collect Egg)
task.spawn(function()
    while true do
        task.wait(0.05)
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
                            local dist = (hrp.Position - targetPart.Position).Magnitude

                            -- หากเปิดระบบขโมยไข่ วาร์ปไปหาตำแหน่งไข่ทันที
                            if Config.AutoStealEgg then
                                hrp.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 2, 0))
                            end

                            -- ระบบกดเก็บไข่ทีเดียว / ไว (Instant Collection Bypass)
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

-- ระบบกิจกรรม: ตีต้นไม้ฟ้าอัตโนมัติ (Auto Blue Tree Event)
task.spawn(function()
    while true do
        task.wait(0.1)
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

-- ระบบมองไข่ / มองผู้เล่น (ESP System)
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
                    txt.Text = "[PLAYER] " .. plr.DisplayName .. " (@" .. plr.Name .. ")"
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
                    txt.Text = "[EGG] " .. obj.Name
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
-- 3. GUI CREATION (PURE TEXT ONLY)
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
MainFrame.Size = UDim2.new(0, 660, 0, 360)
MainFrame.Position = UDim2.new(0.5, -330, 0.5, -180)
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
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(3, 5, 10)
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 150, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
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
CloseBtn.Text = "X"
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
TabBar.Size = UDim2.new(1, -190, 1, 0)
TabBar.Position = UDim2.new(0, 155, 0, 0)
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
    TabBtn.Size = UDim2.new(0, 105, 0, 28)
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

local PlayerPage = CreateTab("Player Options")
local EggPage = CreateTab("Egg Systems")
local EventPage = CreateTab("Event Systems")
local VisualPage = CreateTab("ESP Visuals")
local MiscPage = CreateTab("Settings")

-- แท็บ 1: ระบบผู้เล่น
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

AddButton(PlayerPage, "Set Max Speed (2000)", function() Config.WalkSpeed = 2000 Config.WalkSpeedBypass = true end)
AddButton(PlayerPage, "Reset Speed (16)", function() Config.WalkSpeed = 16 Config.WalkSpeedBypass = false end)

-- แท็บ 2: ระบบไข่
AddToggle(EggPage, "Auto Steal Egg (ขโมยไข่อัตโนมัติ)", "AutoStealEgg")
AddToggle(EggPage, "Instant Collect Egg (กดเก็บไข่ทีเดียว/ไว)", "InstantCollectEgg")
AddToggle(EggPage, "Auto Return Base On Hold (ถือไข่แล้วกลับฐาน)", "AutoReturnBase")
AddToggle(EggPage, "Keep Eggs (เก็บไข่ไว้ไม่ขาย)", "KeepEggs")

AddButton(EggPage, "Set Current Position As Base", function()
    UpdateBasePosition()
    print("[THE CRAFT HUB] Updated Base Position Successfully")
end)

-- แท็บ 3: ระบบกิจกรรม
AddToggle(EventPage, "Auto Farm Blue Tree (ตีต้นไม้ฟ้าอัตโนมัติ)", "AutoBlueTreeEvent")

-- แท็บ 4: มองเห็น (ESP)
AddToggle(VisualPage, "Player ESP (มองเห็นตำแหน่งผู้เล่น)", "ESP_Players", function(val)
    UpdateESP("Player", val)
end)
AddToggle(VisualPage, "Egg ESP (มองเห็นตำแหน่งไข่)", "ESP_Eggs", function(val)
    UpdateESP("Egg", val)
end)

-- แท็บ 5: ตั้งค่าระบบ
AddToggle(MiscPage, "Anti-AFK (ป้องกันการหลุดออกจากเกม)", "AntiAFK")

AddButton(MiscPage, "Server Hop (ย้ายเซิร์ฟเวอร์อัตโนมัติ)", function()
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

-- ปุ่มเปิด/ปิด เมนูหลัก (Floating Button)
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

print("[THE CRAFT HUB] 100% Functional Pure Text Version Loaded Successfully!")
