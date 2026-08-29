-- ==========================================
-- THE CRAFT HUB - Fixed & Optimized Edition
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
    AutoHoldEgg = true,
    AutoReturnBase = true,
    AntiAFK = true,

    -- High-Speed Fly Steal
    AutoStealEgg = false,
    FlySpeed = 150,
    InstantCollectEgg = true,

    -- Dynamic Filters
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
    pcall(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if hrp then
            BasePosition = hrp.CFrame
        end
    end)
end
UpdateBasePosition()
LocalPlayer.CharacterAdded:Connect(UpdateBasePosition)

-- ==========================================
-- 2. MAP DATA SCANNER
-- ==========================================
local function ScanRealMapData()
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            local nameLower = string.lower(obj.Name)

            if string.find(nameLower, "egg") then
                if not table.find(RealMapData.Eggs, obj.Name) and #obj.Name < 30 then
                    table.insert(RealMapData.Eggs, obj.Name)
                end
            end

            if string.find(nameLower, "zone") or string.find(nameLower, "area") or string.find(nameLower, "world") then
                if not table.find(RealMapData.Zones, obj.Name) and #obj.Name < 30 then
                    table.insert(RealMapData.Zones, obj.Name)
                end
            end
        end
    end)
end
task.spawn(ScanRealMapData)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- ==========================================
-- 3. CORE FUNCTIONS
-- ==========================================

local function FlyToTarget(targetCFrame)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetCFrame then return end

    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    if distance <= 3 then return end

    local duration = distance / Config.FlySpeed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- Ultra Fast Attack Loop
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

-- WalkSpeed Loop
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

-- Auto Steal Egg Loop (Non-blocking)
task.spawn(function()
    while true do
        task.wait(0.3)
        if Config.AutoStealEgg then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, obj in pairs(workspace:GetDescendants()) do
                    if not Config.AutoStealEgg then break end

                    local nameLower = string.lower(obj.Name)
                    local isEgg = string.find(nameLower, "egg") or (obj:IsA("Model") and string.find(nameLower, "egg"))

                    if isEgg then
                        local matchEgg = (Config.SelectedEgg == "All" or string.find(obj.Name, Config.SelectedEgg))
                        local matchRarity = (Config.SelectedRarity == "All" or string.find(nameLower, string.lower(Config.SelectedRarity)))
                        local matchSize = (Config.SelectedSize == "All" or string.find(nameLower, string.lower(Config.SelectedSize)))

                        if matchEgg and matchRarity and matchSize then
                            local targetPart = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                            if targetPart and targetPart.Parent then

                                -- 1. Fly to Egg
                                FlyToTarget(CFrame.new(targetPart.Position + Vector3.new(0, 2, 0)))

                                -- 2. Collect
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

                                task.wait(0.2)

                                -- 3. Check & Return
                                if Config.AutoReturnBase and BasePosition then
                                    FlyToTarget(BasePosition)
                                end

                                task.wait(0.2)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Farm Last Zone Tree Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.AutoLastZoneTree then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

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

                for _, obj in pairs(searchParent:GetDescendants()) do
                    if not Config.AutoLastZoneTree then break end

                    local nameLower = string.lower(obj.Name)
                    local isTree = string.find(nameLower, "tree") or string.find(nameLower, "wood")

                    if isTree then
                        local targetPart = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                        if targetPart and targetPart.Parent then

                            FlyToTarget(CFrame.new(targetPart.Position + Vector3.new(0, 2, 3)))

                            local timeout = 0
                            while targetPart and targetPart.Parent and Config.AutoLastZoneTree and timeout < 100 do
                                local tool = char:FindFirstChildOfClass("Tool")
                                if tool then
                                    tool:Activate()
                                    if firetouchinterest and tool:FindFirstChild("Handle") then
                                        firetouchinterest(tool.Handle, targetPart, 0)
                                        firetouchinterest(tool.Handle, tool.Handle, 1)
                                    end
                                end
                                timeout = timeout + 1
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Dupe Held Egg Function
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
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    local rName = string.lower(remote.Name)
                    if string.find(rName, "egg") or string.find(rName, "claim") or string.find(rName, "save") then
                        remote:FireServer(heldEgg)
                    end
                end
            end
            print("[THE CRAFT HUB] Dupe command triggered for: " .. heldEgg.Name)
        else
            warn("[THE CRAFT HUB] No egg found in hand!")
        end
    end)
end

-- ESP System
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
                    local matchEgg = (Config.SelectedEgg == "All" or string.find(obj.Name, Config.SelectedEgg))
                    if matchEgg then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "HUB_ESP_Egg"
                        highlight.FillColor = Color3.fromRGB(0, 170, 255)
                        highlight.FillTransparency = 0.3
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.Adornee = obj
                        highlight.Parent = CoreGui

                        table.insert(ESP_Storage["Egg"], highlight)
                    end
                end
            end
        end
    end)
end

-- ==========================================
-- 4. UI CREATION (FIXED GRID SCROLLING)
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

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -220, 1, 0)
TabBar.Position = UDim2.new(0, 180, 0, 0)
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

    -- คำนวณขยาย Canvas ให้เลื่อนสโคลลงดูฟังก์ชั่นได้ทั้งหมด
    PageGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageGrid.AbsoluteContentSize.Y + 20)
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

-- UI Components
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
-- 5. BUILD PAGES
-- ==========================================

local PlayerPage = CreateTab("PLAYER")
local EggPage = CreateTab("STEAL EGGS")
local EventPage = CreateTab("EVENT TREE")
local VisualPage = CreateTab("VISUALS")

-- PLAYER TAB
AddToggle(PlayerPage, "Ultra Fast Attack", "FastAttack")
AddToggle(PlayerPage, "WalkSpeed Bypass", "WalkSpeedBypass")
AddButton(PlayerPage, "Dupe Held Egg", DupeHeldEgg)
AddToggle(PlayerPage, "Auto Hold Egg", "AutoHoldEgg")

-- STEAL EGGS TAB
AddToggle(EggPage, "High-Speed Fly Steal", "AutoStealEgg")
AddToggle(EggPage, "Instant Collect", "InstantCollectEgg")
AddToggle(EggPage, "Fly Return Base", "AutoReturnBase")
AddButton(EggPage, "Set Current Base", function() UpdateBasePosition() end)

AddDropdown(EggPage, "Egg Filter:", RealMapData.Eggs, "SelectedEgg")
AddDropdown(EggPage, "Rarity Filter:", RealMapData.Rarities, "SelectedRarity")
AddDropdown(EggPage, "Size Filter:", RealMapData.Sizes, "SelectedSize")
AddDropdown(EggPage, "Zone Filter:", RealMapData.Zones, "SelectedZone")

-- EVENT TREE TAB
AddToggle(EventPage, "Farm Last Zone Tree", "AutoLastZoneTree")

-- VISUALS TAB
AddToggle(VisualPage, "Selected Egg ESP", "ESP_Eggs", function(val)
    UpdateESP("Egg", val)
end)

-- Open First Tab
Tabs[1].TextColor3 = Color3.fromRGB(0, 170, 255)
Tabs[1].BackgroundColor3 = Color3.fromRGB(20, 32, 55)
Pages[1].Visible = true

-- Toggle Button UI
local ToggleGuiBtn = Instance.new("TextButton")
ToggleGuiBtn.Name = "ToggleCraftHub"
ToggleGuiBtn.Size = UDim2.new(0, 40, 0, 40)
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

print("[THE CRAFT HUB] Fixed & Ready to Use!")
