-- ==========================================
-- THE CRAFT HUB - High-Speed Fly & Dynamic Real-Map Data Edition
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
    UltraFastSpeed = 0.001,
    AutoHoldEgg = true,
    AutoReturnBase = true,
    AntiAFK = true,

    -- High-Speed Fly Steal
    AutoStealEgg = false,
    FlySpeed = 150,
    InstantCollectEgg = true,

    -- Dynamic Real-Map Filters
    SelectedEgg = "All",
    SelectedRarity = "All",
    SelectedSize = "All",
    SelectedZone = "All",

    -- Event & Last Zone
    AutoLastZoneTree = false,

    -- ESP Visuals
    ESP_Eggs = false,
    ESP_Players = false
}

local RealMapData = {
    Eggs = {"All"},
    Rarities = {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"},
    Sizes = {"All", "Small", "Medium", "Large", "Huge", "Gigantic"},
    Zones = {"All"}
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
-- 2. DYNAMIC REAL-MAP DATA SCANNER
-- ==========================================
local function ScanRealMapData()
    pcall(function()
        -- สแกนรายชื่อไข่และโซนจริงใน Workspace
        for _, obj in pairs(workspace:GetDescendants()) do
            local nameLower = string.lower(obj.Name)

            -- สแกนไข่
            if string.find(nameLower, "egg") then
                if not table.find(RealMapData.Eggs, obj.Name) and #obj.Name < 30 then
                    table.insert(RealMapData.Eggs, obj.Name)
                end
            end

            -- สแกนโซน
            if string.find(nameLower, "zone") or string.find(nameLower, "area") or string.find(nameLower, "world") then
                if not table.find(RealMapData.Zones, obj.Name) and #obj.Name < 30 then
                    table.insert(RealMapData.Zones, obj.Name)
                end
            end
        end
    end)
end
task.spawn(ScanRealMapData)

-- ==========================================
-- 3. CORE HIGH-PERFORMANCE FUNCTIONS
-- ==========================================

-- ฟังก์ชันเคลื่อนที่แบบลอยด้วยความเร็วสูง (Smooth High-Speed Fly)
local function FlyToTarget(targetCFrame)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    if distance <= 3 then return end

    local duration = distance / Config.FlySpeed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    
    -- ลอยตัวตรงไปหาเป้าหมาย
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- ระบบตีไวระดับ Ultra Fast Attack
RunService.RenderStepped:Connect(function()
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
end)

-- ระบบขโมยไข่ (ลอยไปหา ➔ เก็บไข่ไว ➔ ลอยกลับฐาน)
task.spawn(function()
    while true do
        task.wait(0.05)
        if Config.AutoStealEgg then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, obj in pairs(workspace:GetDescendants()) do
                    if not Config.AutoStealEgg then break end

                    local nameLower = string.lower(obj.Name)
                    local isEgg = string.find(nameLower, "egg") or obj:GetAttribute("Egg")

                    if isEgg then
                        -- กรองไข่ตามที่เลือกไว้บน UI
                        local matchEgg = (Config.SelectedEgg == "All" or string.find(obj.Name, Config.SelectedEgg))
                        local matchRarity = (Config.SelectedRarity == "All" or string.find(nameLower, string.lower(Config.SelectedRarity)))
                        local matchSize = (Config.SelectedSize == "All" or string.find(nameLower, string.lower(Config.SelectedSize)))

                        if matchEgg and matchRarity and matchSize then
                            local targetPart = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                            if targetPart then

                                -- 1. ลอยไปหาไข่ด้วยความเร็วสูง
                                local targetCFrame = CFrame.new(targetPart.Position + Vector3.new(0, 2, 0))
                                FlyToTarget(targetCFrame)

                                -- 2. กดเก็บไข่ไวทันที (Instant Bypass)
                                local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChild("Prompt", true)
                                local clicker = obj:FindFirstChildOfClass("ClickDetector")

                                if prompt then
                                    prompt.HoldDuration = 0
                                    if fireproximityprompt then fireproximityprompt(prompt) end
                                elseif clicker and fireclickdetector then
                                    fireclickdetector(clicker)
                                elseif firetouchinterest then
                                    firetouchinterest(hrp, targetPart, 0)
                                    firetouchinterest(hrp, targetPart, 1)
                                end

                                task.wait(0.1)

                                -- 3. ตรวจสอบว่าไข่อยู่ในมือหรือไม่
                                local isHoldingEgg = false
                                for _, item in pairs(char:GetChildren()) do
                                    if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
                                        isHoldingEgg = true
                                    end
                                end

                                -- 4. ถ้าไข่อยู่ในมือแล้ว ให้ลอยกลับฐานด้วยความเร็วสูงทันที
                                if isHoldingEgg and BasePosition then
                                    FlyToTarget(BasePosition)
                                end

                                task.wait(0.1)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ระบบกิจกรรม: วาร์ปตีต้นไม้ในโซนสุดท้ายจนหายแล้วย้ายต้นใหม่
task.spawn(function()
    while true do
        task.wait(0.1)
        if Config.AutoLastZoneTree then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                -- สแกนหาโซนสุดท้าย
                local lastZone = nil
                local maxZoneIndex = -1

                for _, zone in pairs(workspace:GetDescendants()) do
                    if string.find(string.lower(zone.Name), "zone") or string.find(string.lower(zone.Name), "area") then
                        local zoneNum = tonumber(string.match(zone.Name, "%d+")) or 0
                        if zoneNum >= maxZoneIndex then
                            maxZoneIndex = zoneNum
                            lastZone = zone
                        end
                    end
                end

                local searchParent = lastZone or workspace

                -- ค้นหาต้นไม้ในโซนสุดท้าย
                for _, obj in pairs(searchParent:GetDescendants()) do
                    if not Config.AutoLastZoneTree then break end

                    local nameLower = string.lower(obj.Name)
                    local isTree = string.find(nameLower, "tree") or string.find(nameLower, "bluetree") or string.find(nameLower, "wood")

                    if isTree then
                        local targetPart = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                        if targetPart and targetPart.Parent then

                            -- วาร์ป/ลอยไปหาต้นไม้
                            local treeCFrame = CFrame.new(targetPart.Position + Vector3.new(0, 2, 3))
                            FlyToTarget(treeCFrame)

                            -- ตีต้นไม้เรื่อยๆ จนกว่าต้นไม้จะถูกทำลาย/หายไป
                            while targetPart and targetPart.Parent and Config.AutoLastZoneTree do
                                local tool = char:FindFirstChildOfClass("Tool")
                                if tool then
                                    tool:Activate()
                                    if firetouchinterest and tool:FindFirstChild("Handle") then
                                        firetouchinterest(tool.Handle, targetPart, 0)
                                        firetouchinterest(tool.Handle, targetPart, 1)
                                    end
                                end
                                task.wait(0.02)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ระบบดูปไข่ (Egg Dupe System)
local function DupeHeldEgg()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end

        local heldEgg = nil
        for _, item in pairs(char:GetChildren()) do
            if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
                heldEgg = item
                break
            end
        end

        if heldEgg then
            -- จำลองการส่งสัญญาณ Remote duplication
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                    local rName = string.lower(remote.Name)
                    if string.find(rName, "egg") or string.find(rName, "dupe") or string.find(rName, "claim") or string.find(rName, "save") then
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer(heldEgg)
                        end
                    end
                end
            end
            print("[THE CRAFT HUB] Dupe command sent for: " .. heldEgg.Name)
        else
            warn("[THE CRAFT HUB] Please hold an egg in your hand first!")
        end
    end)
end

-- ระบบ ESP มองไข่เฉพาะที่เลือก
local function UpdateESP(targetType, enable)
    if ESP_Storage[targetType] then
        for _, v in pairs(ESP_Storage[targetType]) do if v then v:Destroy() end end
        ESP_Storage[targetType] = {}
    end
    if not enable then return end

    task.spawn(function()
        if targetType == "Egg" then
            for _, obj in pairs(workspace:GetDescendants()) do
                local nameLower = string.lower(obj.Name)
                if string.find(nameLower, "egg") and (obj:IsA("Model") or obj:IsA("BasePart")) then
                    -- กรองแสดงเฉพาะไข่ที่เลือก
                    local matchEgg = (Config.SelectedEgg == "All" or string.find(obj.Name, Config.SelectedEgg))
                    if matchEgg then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "HUB_ESP_Egg"
                        highlight.FillColor = Color3.fromRGB(0, 170, 255)
                        highlight.FillTransparency = 0.3
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.Adornee = obj
                        highlight.Parent = CoreGui

                        local bb = Instance.new("BillboardGui")
                        bb.Size = UDim2.new(0, 120, 0, 25)
                        bb.AlwaysOnTop = true
                        bb.Adornee = obj
                        bb.Parent = highlight

                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.Text = obj.Name
                        txt.TextColor3 = Color3.fromRGB(0, 170, 255)
                        txt.Font = Enum.Font.GothamBold
                        txt.TextSize = 9
                        txt.TextWrapped = true
                        txt.Parent = bb

                        table.insert(ESP_Storage["Egg"], highlight)
                    end
                end
            end
        end
    end)
end

-- ==========================================
-- 4. PERFECT SIDE-BY-SIDE GRID UI CREATION
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
MainFrame.Size = UDim2.new(0, 720, 0, 420)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -210)
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

local LogoIcon = Instance.new("ImageLabel")
LogoIcon.Size = UDim2.new(0, 22, 0, 22)
LogoIcon.Position = UDim2.new(0, 12, 0, 11)
LogoIcon.BackgroundTransparency = 1
LogoIcon.Image = "rbxassetid://6031068421"
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

local CloseBtn = Instance.new("ImageButton")
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -32, 0, 12)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Image = "rbxassetid://6031094678"
CloseBtn.ImageColor3 = Color3.fromRGB(180, 180, 180)
CloseBtn.Parent = TopBar

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -220, 1, 0)
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

    -- จัดวางไอเท็มแบบ Grid Side-by-Side (2 คอลัมน์คู่กัน)
    local PageGrid = Instance.new("UIGridLayout")
    PageGrid.CellSize = UDim2.new(0.485, 0, 0, 42)
    PageGrid.CellPadding = UDim2.new(0.03, 0, 0, 8)
    PageGrid.SortOrder = Enum.SortOrder.LayoutOrder
    PageGrid.Parent = Page

    PageGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageGrid.AbsoluteContentSize.Y + 15)
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
-- 5. SIDE-BY-SIDE UI COMPONENTS
-- ==========================================

local function AddToggle(parentPage, name, configKey, callback)
    local Frame = Instance.new("Frame")
    Frame.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
    Frame.Parent = parentPage

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.68, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 10
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextWrapped = true
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 44, 0, 22)
    Button.Position = UDim2.new(1, -50, 0.5, -11)
    Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(30, 35, 50)
    Button.Text = Config[configKey] and "ON" or "OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 9
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
    Button.BackgroundColor3 = Color3.fromRGB(15, 22, 36)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(0, 170, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 10
    Button.TextWrapped = true
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

local function AddDropdown(parentPage, name, dataTable, configKey)
    local Frame = Instance.new("Frame")
    Frame.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
    Frame.Parent = parentPage

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.45, 0, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 9
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextWrapped = true
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(0.5, 0, 0, 24)
    DropBtn.Position = UDim2.new(0.47, 0, 0.5, -12)
    DropBtn.BackgroundColor3 = Color3.fromRGB(20, 26, 40)
    DropBtn.Text = tostring(Config[configKey])
    DropBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
    DropBtn.Font = Enum.Font.GothamBold
    DropBtn.TextSize = 9
    DropBtn.Parent = Frame

    local DropCorner = Instance.new("UICorner")
    DropCorner.CornerRadius = UDim.new(0, 4)
    DropCorner.Parent = DropBtn

    local currentIndex = 1
    DropBtn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #dataTable then currentIndex = 1 end
        Config[configKey] = dataTable[currentIndex]
        DropBtn.Text = tostring(Config[configKey])
    end)
end

-- ==========================================
-- 6. BUILD TABS & CONNECT ALL FUNCTIONS
-- ==========================================

local PlayerPage = CreateTab("PLAYER", "rbxassetid://6034287525")
local EggPage = CreateTab("STEAL EGGS", "rbxassetid://6031082533")
local EventPage = CreateTab("EVENT TREE", "rbxassetid://6031075931")
local VisualPage = CreateTab("VISUALS", "rbxassetid://6031075929")

-- แท็บ 1: PLAYER
AddToggle(PlayerPage, "Ultra Fast Attack (ตีไวมากๆ)", "FastAttack")
AddButton(PlayerPage, "Dupe Held Egg (ดูปไข่ที่ถืออยู่)", DupeHeldEgg)
AddToggle(PlayerPage, "Auto Hold Egg (ถือไข่อัตโนมัติ)", "AutoHoldEgg")
AddToggle(PlayerPage, "WalkSpeed Bypass", "WalkSpeedBypass")

-- แท็บ 2: STEAL EGGS (การขโมยไข่)
AddToggle(EggPage, "High-Speed Fly Steal (ลอยขโมยไข่ไว)", "AutoStealEgg")
AddToggle(EggPage, "Instant Collect (กดเก็บครั้งเดียว)", "InstantCollectEgg")
AddToggle(EggPage, "Fly Return Base (ถือไข่แล้วลอยกลับฐาน)", "AutoReturnBase")
AddButton(EggPage, "Set Current Base Position", function() UpdateBasePosition() end)

-- Dropdowns กรองข้อมูลแมพจริง
AddDropdown(EggPage, "Egg Filter (กรองไข่):", RealMapData.Eggs, "SelectedEgg")
AddDropdown(EggPage, "Rarity Filter (กรองระดับ):", RealMapData.Rarities, "SelectedRarity")
AddDropdown(EggPage, "Size Filter (กรองขนาด):", RealMapData.Sizes, "SelectedSize")
AddDropdown(EggPage, "Zone Filter (กรองโซน):", RealMapData.Zones, "SelectedZone")

-- แท็บ 3: EVENT TREE
AddToggle(EventPage, "Farm Last Zone Tree (ตีต้นไม้โซนสุดท้าย)", "AutoLastZoneTree")

-- แท็บ 4: VISUALS
AddToggle(VisualPage, "Selected Egg ESP (มองไข่ที่เลือก)", "ESP_Eggs", function(val)
    UpdateESP("Egg", val)
end)

-- เลือกแท็บแรกเริ่มต้น
Tabs[1].TextColor3 = Color3.fromRGB(0, 170, 255)
Tabs[1].BackgroundColor3 = Color3.fromRGB(20, 32, 55)
local firstIcon = Tabs[1]:FindFirstChildOfClass("ImageLabel")
if firstIcon then firstIcon.ImageColor3 = Color3.fromRGB(0, 170, 255) end
Pages[1].Visible = true

-- ปุ่มลอยเปิด/ปิด GUI
local ToggleGuiBtn = Instance.new("ImageButton")
ToggleGuiBtn.Name = "ToggleCraftHub"
ToggleGuiBtn.Size = UDim2.new(0, 42, 0, 42)
ToggleGuiBtn.Position = UDim2.new(0, 15, 0.18, 0)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(6, 10, 18)
ToggleGuiBtn.Image = "rbxassetid://6031068421"
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

print("[THE CRAFT HUB] High-Speed Fly & Real-Map Data Script Loaded Successfully!")
