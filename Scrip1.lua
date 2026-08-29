-- ==========================================
-- THE CRAFT HUB - Ultra Fix 100% (Real Steal, ESP De-duplicate, Speed Customizer)
-- ภาษา: ไทย | โทนสี: ดำ-น้ำเงินเข้ม (Navy Blue)
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. การตั้งค่าและตัวแปรหลัก (CONFIG)
-- ==========================================
local Config = {
    -- ตัวละครและความเร็ว
    WalkSpeed = 32,
    WalkSpeedBypass = false,
    FlySpeed = 300,
    FastAttack = false,
    AntiKnockback = true,
    AutoHoldEgg = true,
    AutoReturnBase = true,
    AntiAFK = true,

    -- ระบบขโมยไข่
    AutoStealEgg = false,
    InstantCollectEgg = true,

    -- ตัวกรองไข่และโซน
    SelectedEgg = "All",
    SelectedRarity = "All",
    SelectedSize = "All",
    SelectedZone = "All",

    -- ฟังก์ชันเสริมในแมพ
    AutoLastZoneTree = false,
    AutoOpenEgg = false,
    AutoCollectCoins = false,

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

-- บันทึกพิกัดฐาน
local function UpdateBasePosition()
    pcall(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if hrp then BasePosition = hrp.CFrame end
    end)
end
UpdateBasePosition()
LocalPlayer.CharacterAdded:Connect(UpdateBasePosition)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- ==========================================
-- 2. สแกนดึงข้อมูลแมพจริงแบบเรียลไทม์
-- ==========================================
local function ScanRealMapData()
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            local nameLower = string.lower(obj.Name)

            -- ดึงชื่อไข่จริง
            if string.find(nameLower, "egg") and not string.find(nameLower, "gui") then
                if not table.find(RealMapData.Eggs, obj.Name) and #obj.Name < 35 then
                    table.insert(RealMapData.Eggs, obj.Name)
                end
            end

            -- ดึงชื่อโซนจริง
            if (string.find(nameLower, "zone") or string.find(nameLower, "area") or string.find(nameLower, "world")) and not string.find(nameLower, "gui") then
                if not table.find(RealMapData.Zones, obj.Name) and #obj.Name < 35 then
                    table.insert(RealMapData.Zones, obj.Name)
                end
            end
        end
    end)
end
task.spawn(ScanRealMapData)

-- ==========================================
-- 3. ฟังก์ชั่นการเคลื่อนที่และต่อสู้ (CORE ENGINE)
-- ==========================================

-- บินไปยังพิกัดเป้าหมาย
local function FlyToTarget(targetCFrame)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetCFrame then return end

    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    if distance <= 3 then return end

    local duration = distance / math.max(Config.FlySpeed, 50)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    
    tween:Play()
    tween.Completed:Wait()
end

-- ป้องกันแรงกระเด็น (Anti-Knockback)
RunService.Stepped:Connect(function()
    if Config.AntiKnockback and Config.AutoStealEgg then
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end)
    end
end)

-- ปรับความเร็วการเดิน (WalkSpeed Customizer)
RunService.Stepped:Connect(function()
    if Config.WalkSpeedBypass then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = Config.WalkSpeed
            end
        end)
    end
end)

-- โจมตีเร็ว (Fast Attack)
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

-- ถือไข่อัตโนมัติ (Auto Hold Egg)
RunService.Stepped:Connect(function()
    if Config.AutoHoldEgg then
        pcall(function()
            local char = LocalPlayer.Character
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            if char and backpack and not char:FindFirstChildOfClass("Tool") then
                for _, item in pairs(backpack:GetChildren()) do
                    if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
                        item.Parent = char
                        break
                    end
                end
            end
        end)
    end
end)

-- ==========================================
-- 4. ระบบขโมยไข่และฟังก์ชั่นฟาร์ม (AUTO STEAL FIX)
-- ==========================================

-- ระบบขโมยไข่ (ล็อคตัวเก็บจนกว่าจะสำเร็จ)
task.spawn(function()
    while true do
        task.wait(0.1)
        if Config.AutoStealEgg then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, obj in pairs(workspace:GetDescendants()) do
                    if not Config.AutoStealEgg then break end

                    local nameLower = string.lower(obj.Name)
                    local isEgg = string.find(nameLower, "egg") and not string.find(nameLower, "gui")

                    if isEgg then
                        local matchEgg = (Config.SelectedEgg == "All" or string.find(obj.Name, Config.SelectedEgg))
                        local matchRarity = (Config.SelectedRarity == "All" or string.find(nameLower, string.lower(Config.SelectedRarity)))
                        local matchSize = (Config.SelectedSize == "All" or string.find(nameLower, string.lower(Config.SelectedSize)))

                        if matchEgg and matchRarity and matchSize then
                            local targetPart = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))

                            if targetPart and targetPart.Parent then
                                -- 1. บินเข้าหาเป้าหมาย
                                FlyToTarget(CFrame.new(targetPart.Position + Vector3.new(0, 1.5, 0)))

                                -- 2. ล็อคตำแหน่งตัวละครเพื่อทำการขโมยไข่จนสำเร็จ
                                local attempts = 0
                                while targetPart and targetPart.Parent and attempts < 15 and Config.AutoStealEgg do
                                    attempts = attempts + 1
                                    hrp.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 1.5, 0))

                                    -- ค้นหาตัวกดเก็บ
                                    local prompt = obj:FindFirstChildOfClass("ProximityPrompt", true) or targetPart:FindFirstChildOfClass("ProximityPrompt")
                                    local clicker = obj:FindFirstChildOfClass("ClickDetector", true) or targetPart:FindFirstChildOfClass("ClickDetector")

                                    if prompt then
                                        if Config.InstantCollectEgg then prompt.HoldDuration = 0 end
                                        if fireproximityprompt then fireproximityprompt(prompt) end
                                    elseif clicker and fireclickdetector then
                                        fireclickdetector(clicker)
                                    end

                                    if firetouchinterest then
                                        firetouchinterest(hrp, targetPart, 0)
                                        firetouchinterest(hrp, targetPart, 1)
                                    end

                                    task.wait(0.08)
                                end

                                -- 3. กลับฐานหลังเก็บเสร็จ
                                if Config.AutoReturnBase and BasePosition then
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

-- ฟาร์มตีต้นไม้โซนสุดท้าย
task.spawn(function()
    while true do
        task.wait(0.2)
        if Config.AutoLastZoneTree then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, obj in pairs(workspace:GetDescendants()) do
                    if not Config.AutoLastZoneTree then break end

                    local nameLower = string.lower(obj.Name)
                    if string.find(nameLower, "tree") or string.find(nameLower, "wood") then
                        local targetPart = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                        if targetPart and targetPart.Parent then
                            FlyToTarget(CFrame.new(targetPart.Position + Vector3.new(0, 2, 2)))

                            local hp = 0
                            while targetPart and targetPart.Parent and Config.AutoLastZoneTree and hp < 80 do
                                hp = hp + 1
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
                end
            end)
        end
    end
end)

-- ฟังก์ชันเสริม: เปิดไข่ออโต้ (Auto Open Egg)
task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.AutoOpenEgg then
            pcall(function()
                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        local rName = string.lower(remote.Name)
                        if string.find(rName, "hatch") or string.find(rName, "open") or string.find(rName, "buyegg") then
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer(Config.SelectedEgg ~= "All" and Config.SelectedEgg or 1)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ฟังก์ชันเสริม: เก็บเหรียญ/เพชรออโต้ (Auto Collect Coins)
task.spawn(function()
    while true do
        task.wait(0.3)
        if Config.AutoCollectCoins then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, obj in pairs(workspace:GetDescendants()) do
                    if not Config.AutoCollectCoins then break end

                    local nameLower = string.lower(obj.Name)
                    if string.find(nameLower, "coin") or string.find(nameLower, "gem") or string.find(nameLower, "orb") then
                        local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and obj.PrimaryPart)
                        if part and firetouchinterest then
                            firetouchinterest(hrp, part, 0)
                            firetouchinterest(hrp, part, 1)
                        end
                    end
                end
            end)
        end
    end
end)

-- ระบบดูปไข่ (Dupe Held Egg)
local function DupeHeldEgg()
    pcall(function()
        local char = LocalPlayer.Character
        local heldEgg = nil
        if char then
            for _, item in pairs(char:GetChildren()) do
                if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
                    heldEgg = item
                    break
                end
            end
        end

        if heldEgg then
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    local rName = string.lower(remote.Name)
                    if string.find(rName, "egg") or string.find(rName, "claim") or string.find(rName, "dupe") then
                        remote:FireServer(heldEgg)
                    end
                end
            end
            print("[THE CRAFT HUB] ดูปไข่สำเร็จ: " .. heldEgg.Name)
        else
            warn("[THE CRAFT HUB] ไม่พบไข่ในมือ กรุณาถือไข่ก่อนกด!")
        end
    end)
end

-- ==========================================
-- 5. ระบบ ESP กรองไข่ไม่ให้ซ้ำ (ESP DE-DUPLICATE)
-- ==========================================
local function UpdateESP(targetType, enable)
    if ESP_Storage[targetType] then
        for _, v in pairs(ESP_Storage[targetType]) do if v then v:Destroy() end end
        ESP_Storage[targetType] = {}
    end
    if not enable then return end

    task.spawn(function()
        if targetType == "Egg" then
            local trackedPositions = {}

            for _, obj in pairs(workspace:GetDescendants()) do
                local nameLower = string.lower(obj.Name)
                if string.find(nameLower, "egg") and not string.find(nameLower, "gui") and (obj:IsA("Model") or obj:IsA("BasePart")) then
                    local matchEgg = (Config.SelectedEgg == "All" or string.find(obj.Name, Config.SelectedEgg))
                    
                    if matchEgg then
                        local part = obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        if part then
                            -- กรองตำแหน่งซ้ำกันในรัศมี 3 หน่วย
                            local isDuplicate = false
                            for _, pos in pairs(trackedPositions) do
                                if (pos - part.Position).Magnitude < 3 then
                                    isDuplicate = true
                                    break
                                end
                            end

                            if not isDuplicate then
                                table.insert(trackedPositions, part.Position)

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
                                bb.Adornee = part
                                bb.Parent = highlight

                                local txt = Instance.new("TextLabel")
                                txt.Size = UDim2.new(1, 0, 1, 0)
                                txt.BackgroundTransparency = 1
                                txt.Text = "[ไข่] " .. obj.Name
                                txt.TextColor3 = Color3.fromRGB(0, 170, 255)
                                txt.Font = Enum.Font.GothamBold
                                txt.TextSize = 10
                                txt.Parent = bb

                                table.insert(ESP_Storage["Egg"], highlight)
                            end
                        end
                    end
                end
            end
        elseif targetType == "Player" then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "HUB_ESP_Player"
                    highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    highlight.FillTransparency = 0.4
                    highlight.Adornee = plr.Character
                    highlight.Parent = CoreGui

                    table.insert(ESP_Storage["Player"], highlight)
                end
            end
        end
    end)
end

-- ==========================================
-- 6. ระบบ UI (INTERFACE DESIGN)
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
MainFrame.Size = UDim2.new(0, 740, 0, 430)
MainFrame.Position = UDim2.new(0.5, -370, 0.5, -215)
MainFrame.BackgroundColor3 = Color3.fromRGB(6, 10, 18)
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

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 160, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Text = "THE CRAFT HUB"
TitleLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -35, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = TopBar

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

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

local function CreateTab(tabName)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 110, 0, 30)
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
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Color3.fromRGB(0, 102, 255)
    Page.Parent = ContentContainer

    local PageGrid = Instance.new("UIGridLayout")
    PageGrid.CellSize = UDim2.new(0.485, 0, 0, 45)
    PageGrid.CellPadding = UDim2.new(0.02, 0, 0, 8)
    PageGrid.SortOrder = Enum.SortOrder.LayoutOrder
    PageGrid.Parent = Page

    PageGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageGrid.AbsoluteContentSize.Y + 25)
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

-- Component UI Elements
local function AddToggle(parentPage, name, configKey, callback)
    local Frame = Instance.new("Frame")
    Frame.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
    Frame.Parent = parentPage

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.65, 0, 1, 0)
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
    Button.Size = UDim2.new(0, 45, 0, 24)
    Button.Position = UDim2.new(1, -52, 0.5, -12)
    Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(30, 35, 50)
    Button.Text = Config[configKey] and "เปิด" or "ปิด"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 9
    Button.Parent = Frame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        Button.Text = Config[configKey] and "เปิด" or "ปิด"
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

local function AddSpeedSelector(parentPage, name, configKey, stepVal)
    local Frame = Instance.new("Frame")
    Frame.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
    Frame.Parent = parentPage

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.Text = name .. ": " .. tostring(Config[configKey])
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 9
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local MinusBtn = Instance.new("TextButton")
    MinusBtn.Size = UDim2.new(0, 24, 0, 24)
    MinusBtn.Position = UDim2.new(1, -55, 0.5, -12)
    MinusBtn.BackgroundColor3 = Color3.fromRGB(20, 26, 40)
    MinusBtn.Text = "-"
    MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinusBtn.Font = Enum.Font.GothamBold
    MinusBtn.Parent = Frame

    local PlusBtn = Instance.new("TextButton")
    PlusBtn.Size = UDim2.new(0, 24, 0, 24)
    PlusBtn.Position = UDim2.new(1, -28, 0.5, -12)
    PlusBtn.BackgroundColor3 = Color3.fromRGB(20, 26, 40)
    PlusBtn.Text = "+"
    PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlusBtn.Font = Enum.Font.GothamBold
    PlusBtn.Parent = Frame

    MinusBtn.MouseButton1Click:Connect(function()
        Config[configKey] = math.max(16, Config[configKey] - stepVal)
        Label.Text = name .. ": " .. tostring(Config[configKey])
    end)

    PlusBtn.MouseButton1Click:Connect(function()
        Config[configKey] = Config[configKey] + stepVal
        Label.Text = name .. ": " .. tostring(Config[configKey])
    end)
end

-- ==========================================
-- 7. เมนูใช้งานภาษาไทย (FULL MENU TABS)
-- ==========================================

local PlayerPage = CreateTab("ตัวละครหลัก")
local EggPage = CreateTab("บินขโมยไข่")
local MapFarmPage = CreateTab("ฟาร์มแมพ/กิจกรรม")
local VisualPage = CreateTab("ระบบมองทะลุ")

-- แท็บที่ 1: ตัวละครหลัก
AddToggle(PlayerPage, "เปิดใช้งานความเร็วเดิน", "WalkSpeedBypass")
AddSpeedSelector(PlayerPage, "ปรับความเร็วเดิน", "WalkSpeed", 10)
AddSpeedSelector(PlayerPage, "ปรับความเร็วบินขโมย", "FlySpeed", 50)
AddToggle(PlayerPage, "ตีไว Ultra Fast Attack", "FastAttack")
AddToggle(PlayerPage, "ป้องกันกระเด็น (Anti-Knockback)", "AntiKnockback")
AddToggle(PlayerPage, "ถือไข่อัตโนมัติ (Auto Hold)", "AutoHoldEgg")
AddButton(PlayerPage, "ปั๊ม/ดูปไข่ที่ถืออยู่", DupeHeldEgg)

-- แท็บที่ 2: บินขโมยไข่
AddToggle(EggPage, "บินขโมยไข่ออโต้ (100% Fix)", "AutoStealEgg")
AddToggle(EggPage, "เก็บไข่ทันที (Instant Collect)", "InstantCollectEgg")
AddToggle(EggPage, "บินกลับฐานออโต้", "AutoReturnBase")
AddButton(EggPage, "รีเซ็ตตำแหน่งฐานใหม่", function() UpdateBasePosition() end)

AddDropdown(EggPage, "คัดกรองไข่ (สแกนจริง):", RealMapData.Eggs, "SelectedEgg")
AddDropdown(EggPage, "คัดกรองระดับ (Rarity):", RealMapData.Rarities, "SelectedRarity")
AddDropdown(EggPage, "คัดกรองขนาด (Size):", RealMapData.Sizes, "SelectedSize")
AddDropdown(EggPage, "คัดกรองโซน (สแกนจริง):", RealMapData.Zones, "SelectedZone")

-- แท็บที่ 3: ฟาร์มแมพ/กิจกรรม
AddToggle(MapFarmPage, "ตีต้นไม้โซนสุดท้ายออโต้", "AutoLastZoneTree")
AddToggle(MapFarmPage, "เปิดไข่อัตโนมัติ (Auto Open)", "AutoOpenEgg")
AddToggle(MapFarmPage, "เก็บเหรียญ/เพชรออโต้", "AutoCollectCoins")
AddButton(MapFarmPage, "ย้ายเซิร์ฟเวอร์ (Server Hop)", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
AddButton(MapFarmPage, "เข้าเซิร์ฟเวอร์เดิมใหม่ (Rejoin)", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

-- แท็บที่ 4: มองทะลุ (ESP)
AddToggle(VisualPage, "ESP ไข่ (กรองอันซ้ำออก)", "ESP_Eggs", function(val)
    UpdateESP("Egg", val)
end)
AddToggle(VisualPage, "ESP ผู้เล่นทะลุกำแพง", "ESP_Players", function(val)
    UpdateESP("Player", val)
end)

-- Default Selected Tab
Tabs[1].TextColor3 = Color3.fromRGB(0, 170, 255)
Tabs[1].BackgroundColor3 = Color3.fromRGB(20, 32, 55)
Pages[1].Visible = true

-- ปุ่มลอย เปิด/ปิด GUI
local ToggleGuiBtn = Instance.new("TextButton")
ToggleGuiBtn.Name = "ToggleCraftHub"
ToggleGuiBtn.Size = UDim2.new(0, 42, 0, 42)
ToggleGuiBtn.Position = UDim2.new(0, 15, 0.2, 0)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(6, 10, 18)
ToggleGuiBtn.Text = "HUB"
ToggleGuiBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
ToggleGuiBtn.Font = Enum.Font.GothamBold
ToggleGuiBtn.TextSize = 11
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

print("[THE CRAFT HUB] โหลดสคริปต์เวอร์ชัน Ultra Fix 100% เรียบร้อยแล้ว!")
