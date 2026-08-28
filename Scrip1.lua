-- [[ THE CRAFT HUB | ALL-IN-ONE FIXED EDITION V5 ]] --
-- แก้ไขเมนูหาย + แก้ตัวแข็ง + แก้บินหลุดแมพ + แก้โดนตีไม่กระเด็น + ระบบฟาร์มไข่อัตโนมัติ

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--------------------------------------------------------------------------------
-- GLOBAL FLAGS
--------------------------------------------------------------------------------
local Flags = {
    -- Steal & Farm Modes
    AutoStealFly = false,
    AutoFarmEgg = false,
    GroundedFly = true,
    
    -- Speed Controls
    FlySpeed = 150,
    WalkSpeed = 16,
    
    -- Dropdown Filters (ดึงกลับมาครบถ้วน)
    FilterRarity = "ทั้งหมด",
    FilterZone = "ทุกโซน",
    FilterTier = "ทุกขนาด",
    
    -- Automations & Fixes
    AutoReGrabFast = false,
    FastPickup = false,
    AntiKnockback = false,
    
    -- Visuals
    ESP_Players = false
}

local ESP_Folder = Instance.new("Folder", CoreGui)
ESP_Folder.Name = "Craft_ESP_Storage"

--------------------------------------------------------------------------------
-- HELPER FUNCTIONS
--------------------------------------------------------------------------------
local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function isHoldingEgg()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") or item.Name:lower():find("egg") then
            return true
        end
    end
    return false
end

local function getMyBaseCFrame()
    local plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Bases") or workspace:FindFirstChild("PlotsFolder")
    if plots then
        for _, plot in pairs(plots:GetChildren()) do
            local owner = plot:FindFirstChild("Owner") or plot:GetAttribute("Owner")
            if (owner and tostring(owner) == LocalPlayer.Name) or plot.Name:find(LocalPlayer.Name) then
                local spawnPart = plot:FindFirstChild("Spawn") or plot:FindFirstChildWhichIsA("BasePart")
                if spawnPart then return spawnPart.CFrame end
            end
        end
    end
    local sellZone = workspace:FindFirstChild("SellZone", true) or workspace:FindFirstChild("SellArea", true)
    if sellZone then
        local p = sellZone:IsA("Model") and (sellZone.PrimaryPart or sellZone:FindFirstChildWhichIsA("BasePart")) or sellZone
        if p then return p.CFrame end
    end
    return getRoot() and getRoot().CFrame
end

-- ระบบการบินแบบสมูท ไม่แข็งค้าง ไม่ตกแมพ
local function flyToCFrame(targetCFrame)
    local hrp = getRoot()
    if not hrp then return end
    
    local targetPos = targetCFrame.Position
    if Flags.GroundedFly then
        targetPos = Vector3.new(targetPos.X, math.max(targetPos.Y + 2, 3), targetPos.Z)
    end
    
    local destination = CFrame.new(targetPos)
    local distance = (hrp.Position - destination.Position).Magnitude
    if distance > 3000 then return end
    
    local timeToReach = math.clamp(distance / math.max(Flags.FlySpeed, 30), 0.05, 4)
    local tweenInfo = TweenInfo.new(timeToReach, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = destination})
    
    tween:Play()
    tween.Completed:Wait()
end

-- ระบบดูดไข่เข้ามือแบบเร็วจี๋
local function forceGrabEgg(eggPart)
    local hrp = getRoot()
    if not hrp or not eggPart or not eggPart.Parent then return end
    
    local count = 0
    while count < 6 and not isHoldingEgg() and eggPart.Parent do
        hrp.CFrame = eggPart.CFrame
        for _, prompt in pairs(eggPart:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                prompt.HoldDuration = 0
                prompt.RequiresLineOfSight = false
                fireproximityprompt(prompt)
            end
        end
        count = count + 1
        task.wait(0.02)
    end
end

-- ตัวกรองไข่ (ความหายาก / โซน / ขนาด)
local function checkEggFilter(obj)
    if not obj:IsA("BasePart") and not obj:IsA("Model") then return false end
    local name = obj.Name:lower()
    if not name:find("egg") then return false end
    
    -- 1. เช็กความหายาก
    if Flags.FilterRarity ~= "ทั้งหมด" then
        local rarity = obj:GetAttribute("Rarity") or obj.Name
        if not tostring(rarity):lower():find(Flags.FilterRarity:lower()) then
            return false
        end
    end
    
    -- 2. เช็กโซน
    if Flags.FilterZone ~= "ทุกโซน" then
        local parentZone = obj:FindFirstAncestorWhichIsA("Folder") or obj.Parent
        if parentZone and not parentZone.Name:lower():find(Flags.FilterZone:lower()) then
            return false
        end
    end
    
    -- 3. เช็กขนาด
    if Flags.FilterTier ~= "ทุกขนาด" then
        local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
        if part then
            local sz = part.Size.Y
            if Flags.FilterTier == "Small" and sz > 2.5 then return false
            elseif Flags.FilterTier == "Medium" and (sz <= 2.5 or sz > 4.5) then return false
            elseif Flags.FilterTier == "Big" and sz <= 4.5 then return false end
        end
    end
    
    return true
end

--------------------------------------------------------------------------------
-- GUI CREATION
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CraftHubFullEditionUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Name = "CraftToggleButton"
ToggleBtn.Size = UDim2.new(0, 130, 0, 40)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(10, 25, 50)
ToggleBtn.BackgroundTransparency = 0.25
ToggleBtn.Text = "⚡ CRAFT [K]"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 225, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 420)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 16, 32)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 180, 255)
MainStroke.Thickness = 2

local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.Size = UDim2.new(1, -20, 0, 40)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Text = "⚡ THE CRAFT HUB | ALL-IN-ONE FIXED ⚡"
TitleLabel.TextColor3 = Color3.fromRGB(0, 230, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1

local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(0, 145, 1, -50)
TabContainer.Position = UDim2.new(0, 10, 0, 45)
TabContainer.BackgroundColor3 = Color3.fromRGB(5, 12, 25)
TabContainer.BackgroundTransparency = 0.4
Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 8)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -175, 1, -50)
ContentContainer.Position = UDim2.new(0, 165, 0, 45)
ContentContainer.BackgroundTransparency = 1

local Tabs, Pages = {}, {}

local function createTab(name)
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(1, -10, 0, 32)
    TabBtn.Position = UDim2.new(0, 5, 0, #Tabs * 36 + 5)
    TabBtn.BackgroundColor3 = Color3.fromRGB(15, 30, 60)
    TabBtn.BackgroundTransparency = 0.5
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 220, 255)
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 11
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", ContentContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 4

    local ListLayout = Instance.new("UIListLayout", Page)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 6)
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, t in pairs(Tabs) do t.TextColor3 = Color3.fromRGB(200, 220, 255) end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(0, 230, 255)
    end)

    table.insert(Tabs, TabBtn)
    table.insert(Pages, Page)
    return Page
end

local function addToggle(page, text, flagName, callback)
    local Frame = Instance.new("Frame", page)
    Frame.Size = UDim2.new(1, -10, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(12, 24, 48)
    Frame.BackgroundTransparency = 0.3
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.68, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Switch = Instance.new("TextButton", Frame)
    Switch.Size = UDim2.new(0, 50, 0, 22)
    Switch.Position = UDim2.new(1, -58, 0.5, -11)
    Switch.BackgroundColor3 = Flags[flagName] and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(40, 50, 70)
    Switch.Text = Flags[flagName] and "เปิด" or "ปิด"
    Switch.TextColor3 = Color3.fromRGB(255, 255, 255)
    Switch.Font = Enum.Font.GothamBold
    Switch.TextSize = 10
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 11)

    Switch.MouseButton1Click:Connect(function()
        Flags[flagName] = not Flags[flagName]
        Switch.BackgroundColor3 = Flags[flagName] and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(40, 50, 70)
        Switch.Text = Flags[flagName] and "เปิด" or "ปิด"
        if callback then callback(Flags[flagName]) end
    end)
end

local function addSlider(page, text, min, max, default, callback)
    local Frame = Instance.new("Frame", page)
    Frame.Size = UDim2.new(1, -10, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(12, 24, 48)
    Frame.BackgroundTransparency = 0.3
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.Text = string.format("%s: %d", text, default)
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local SliderBtn = Instance.new("TextButton", Frame)
    SliderBtn.Size = UDim2.new(1, -20, 0, 12)
    SliderBtn.Position = UDim2.new(0, 10, 0, 24)
    SliderBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    SliderBtn.Text = ""
    Instance.new("UICorner", SliderBtn).CornerRadius = UDim.new(0, 6)

    local Fill = Instance.new("Frame", SliderBtn)
    Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 6)

    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - SliderBtn.AbsolutePosition.X) / SliderBtn.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Label.Text = string.format("%s: %d", text, val)
        callback(val)
    end

    SliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function addSelectorGrid(page, titleText, options, defaultVal, callback)
    local Container = Instance.new("Frame", page)
    Container.Size = UDim2.new(1, -10, 0, 60)
    Container.BackgroundColor3 = Color3.fromRGB(12, 24, 48)
    Container.BackgroundTransparency = 0.3
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(1, -10, 0, 18)
    Label.Position = UDim2.new(0, 8, 0, 2)
    Label.Text = titleText
    Label.TextColor3 = Color3.fromRGB(0, 230, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local ScrollBtns = Instance.new("ScrollingFrame", Container)
    ScrollBtns.Size = UDim2.new(1, -16, 0, 34)
    ScrollBtns.Position = UDim2.new(0, 8, 0, 22)
    ScrollBtns.BackgroundTransparency = 1
    ScrollBtns.ScrollBarThickness = 2

    local Layout = Instance.new("UIListLayout", ScrollBtns)
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.Padding = UDim.new(0, 5)

    local optionButtons = {}
    for _, opt in ipairs(options) do
        local Btn = Instance.new("TextButton", ScrollBtns)
        Btn.Size = UDim2.new(0, 75, 1, -4)
        Btn.BackgroundColor3 = (opt == defaultVal) and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(25, 45, 75)
        Btn.Text = opt
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 10
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

        Btn.MouseButton1Click:Connect(function()
            for _, b in pairs(optionButtons) do
                b.BackgroundColor3 = Color3.fromRGB(25, 45, 75)
            end
            Btn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
            callback(opt)
        end)
        table.insert(optionButtons, Btn)
    end
    ScrollBtns.CanvasSize = UDim2.new(0, #options * 80, 0, 0)
end

local function addButton(page, text, callback)
    local Btn = Instance.new("TextButton", page)
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 210)
    Btn.BackgroundTransparency = 0.3
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(callback)
end

local uiVisible = true
ToggleBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    MainFrame.Visible = uiVisible
end)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.K then
        uiVisible = not uiVisible
        MainFrame.Visible = uiVisible
    end
end)

--------------------------------------------------------------------------------
-- PAGES
--------------------------------------------------------------------------------
local PageSteal = createTab("⚡ บินขโมย & ฟาร์มออโต้")
local PageFilters = createTab("🎯 เลือกความหายาก/โซน/ขนาด")
local PagePlayer = createTab("🏃 ความเร็ว & กันกระเด็น")
local PageVisuals = createTab("👁️ ESP มองผู้เล่น")

Pages[1].Visible = true
Tabs[1].TextColor3 = Color3.fromRGB(0, 230, 255)

--------------------------------------------------------------------------------
-- 1. บินขโมย & ฟาร์มไข่อัตโนมัติ (FIXED & IMPROVED)
--------------------------------------------------------------------------------
addToggle(PageSteal, "ฟังก์ชันขโมยไข่ (บินไปเอาแล้วกลับฐาน)", "AutoStealFly", function(v)
    if v then
        Flags.AutoFarmEgg = false
        task.spawn(function()
            while Flags.AutoStealFly do
                task.wait(0.2)
                if isHoldingEgg() then
                    local baseCF = getMyBaseCFrame()
                    if baseCF then flyToCFrame(baseCF) end
                else
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if not Flags.AutoStealFly or isHoldingEgg() then break end
                        if checkEggFilter(obj) and not obj:IsDescendantOf(LocalPlayer.Character) then
                            local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                            if part then
                                flyToCFrame(part.CFrame)
                                forceGrabEgg(part)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

addToggle(PageSteal, "ฟังก์ชันฟาร์มไข่อัตโนมัติ (Auto Farm Eggs)", "AutoFarmEgg", function(v)
    if v then
        Flags.AutoStealFly = false
        task.spawn(function()
            while Flags.AutoFarmEgg do
                task.wait(0.2)
                for _, obj in pairs(workspace:GetDescendants()) do
                    if not Flags.AutoFarmEgg then break end
                    if checkEggFilter(obj) and not obj:IsDescendantOf(LocalPlayer.Character) then
                        local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                        if part then
                            flyToCFrame(part.CFrame)
                            forceGrabEgg(part)
                            task.wait(0.1)
                        end
                    end
                end
            end
        end)
    end
end)

addToggle(PageSteal, "บินติดเรียบพื้นดิน (Grounded Fly)", "GroundedFly", function(v) Flags.GroundedFly = v end)

--------------------------------------------------------------------------------
-- 2. เมนูตัวเลือกที่หายไป (ดึงกลับมาครบ 100%)
--------------------------------------------------------------------------------
addSelectorGrid(PageFilters, "เลือกระดับความหายากของไข่", {"ทั้งหมด", "Common", "Rare", "Epic", "Legendary", "Mythic"}, Flags.FilterRarity, function(v) Flags.FilterRarity = v end)
addSelectorGrid(PageFilters, "เลือกโซนของไข่", {"ทุกโซน", "Zone 1", "Zone 2", "Zone 3", "VIP Zone"}, Flags.FilterZone, function(v) Flags.FilterZone = v end)
addSelectorGrid(PageFilters, "เลือกขนาดของไข่", {"ทุกขนาด", "Small", "Medium", "Big"}, Flags.FilterTier, function(v) Flags.FilterTier = v end)

--------------------------------------------------------------------------------
-- 3. ความเร็ว & กันกระเด็น & เก็บไข่ตกพื้น (FIXED SPEED BUG)
--------------------------------------------------------------------------------
addSlider(PagePlayer, "ปรับความเร็ววิ่ง (WalkSpeed)", 16, 500, Flags.WalkSpeed, function(v) Flags.WalkSpeed = v end)
addSlider(PagePlayer, "ปรับความเร็วบิน (FlySpeed)", 30, 1000, Flags.FlySpeed, function(v) Flags.FlySpeed = v end)

-- แก้ปัญหาฟังก์ชันไข่ตกเปิดแล้ววิ่งช้า (Ultra-Fast Non-Lagging Re-Grab)
addToggle(PagePlayer, "เก็บไข่ตกพื้นกลับเข้ามือทันที (ไม่ดื้อ/ไม่อืด)", "AutoReGrabFast", function(v)
    if v then
        task.spawn(function()
            while Flags.AutoReGrabFast do
                task.wait(0.1)
                local hrp = getRoot()
                if hrp and not isHoldingEgg() then
                    for _, obj in pairs(workspace:GetChildren()) do
                        if obj:IsA("BasePart") and obj.Name:lower():find("egg") then
                            if (obj.Position - hrp.Position).Magnitude < 20 then
                                forceGrabEgg(obj)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- แก้โดนตีไม่กระเด็น (Anti-Knockback แบบไม่ล็อคตัวแข็ง)
addToggle(PagePlayer, "โดนตีไม่กระเด็น (Anti-Knockback)", "AntiKnockback", function(v)
    if v then
        task.spawn(function()
            while Flags.AntiKnockback do
                task.wait(0.05)
                local hrp = getRoot()
                if hrp then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end)
    end
end)

addToggle(PagePlayer, "เก็บไข่เร็ว (Instant Pick)", "FastPickup", function(v)
    if v then
        task.spawn(function()
            while Flags.FastPickup do
                task.wait(0.5)
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        prompt.HoldDuration = 0
                        prompt.RequiresLineOfSight = false
                    end
                end
            end
        end)
    end
end)

--------------------------------------------------------------------------------
-- 4. ESP มองผู้เล่น
--------------------------------------------------------------------------------
addToggle(PageVisuals, "มองผู้เล่นทะลุกำแพง (Player ESP)", "ESP_Players", function(v)
    ESP_Folder:ClearAllChildren()
    if v then
        task.spawn(function()
            while Flags.ESP_Players do
                task.wait(0.5)
                ESP_Folder:ClearAllChildren()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                        local bb = Instance.new("BillboardGui")
                        bb.Name = player.Name
                        bb.Adornee = player.Character.Head
                        bb.Size = UDim2.new(0, 140, 0, 40)
                        bb.StudsOffset = Vector3.new(0, 2.5, 0)
                        bb.AlwaysOnTop = true

                        local txt = Instance.new("TextLabel", bb)
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.TextColor3 = Color3.fromRGB(0, 255, 200)
                        txt.Font = Enum.Font.GothamBold
                        txt.TextSize = 11

                        local hrp = getRoot()
                        local dist = hrp and math.floor((hrp.Position - player.Character.Head.Position).Magnitude) or 0
                        txt.Text = string.format("👤 %s\n[%d m]", player.DisplayName, dist)
                        
                        bb.Parent = ESP_Folder
                    end
                end
            end
        end)
    end
end)

addButton(PageVisuals, "🔴 ปิดระบบทั้งหมด และ ทำลาย UI", function()
    for k in pairs(Flags) do if type(Flags[k]) == "boolean" then Flags[k] = false end end
    ESP_Folder:ClearAllChildren()
    ScreenGui:Destroy()
end)

-- ลูปคุม WalkSpeed ไม่ให้โดนเกมนับถอยหลังแก้คืน
RunService.Stepped:Connect(function()
    local hum = getHumanoid()
    if hum and Flags.WalkSpeed > 16 then
        hum.WalkSpeed = Flags.WalkSpeed
    end
end)
