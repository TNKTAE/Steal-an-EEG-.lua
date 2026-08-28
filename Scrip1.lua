-- [[ THE CRAFT HUB | ULTIMATE EXPERT EDITION ]] --
-- UI กระจกสีน้ำเงินทรงโมเดิร์น + ระบบบินขโมยแล้วกลับฐาน + กรองไข่ + Event + Anti-Knockback

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--------------------------------------------------------------------------------
-- GLOBAL FLAGS & CONFIGURATIONS
--------------------------------------------------------------------------------
local Flags = {
    -- Steal Controls
    AutoStealSmart = false,
    FlySpeed = 60,
    StealDelay = 0.2,
    
    -- Egg Filters
    FilterRarity = "ทั้งหมด", -- ทั้งหมด, Common, Rare, Epic, Legendary, Mythic
    FilterZone = "ทุกโซน",   -- ทุกโซน, Zone 1, Zone 2, Zone 3, VIP Zone
    FilterTier = "ทุกขนาด",  -- ทุกขนาด, Small, Medium, Big
    
    -- Character & Protections
    WalkSpeed = 16,
    FastPickup = false,
    AutoReGrab = false,
    AntiKnockback = false,
    
    -- Visuals & Event
    ESP_Names = false,
    ESP_Zones = false,
    LightningAura = false,
    
    -- Base & Farm
    AutoPlaceAll = false,
    AutoSellEggs = false,
    SellInterval = 15,
    AutoTreadmill = false,
    AutoUpgrades = false
}

local ESP_Elements = {}

--------------------------------------------------------------------------------
-- CORE HELPERS
--------------------------------------------------------------------------------
local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- เช็กว่าผู้เล่นกำลังถือไข่อยู่ในมือหรือไม่
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

-- หาพิกัดฐาน / จุดขายไข่ของผู้เล่น
local function getMyBaseCFrame()
    local plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Bases")
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

-- ระบบบินไปเป้าหมาย (Tween Flight)
local function flyToTarget(targetCFrame)
    local hrp = getRoot()
    if not hrp then return end
    
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local timeToReach = distance / math.max(Flags.FlySpeed, 10)
    
    local tweenInfo = TweenInfo.new(timeToReach, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame + Vector3.new(0, 2, 0)})
    tween:Play()
    tween.Completed:Wait()
end

-- ระบบส่ง Remote อัตโนมัติ
local function fireRemote(possibleNames)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, name in pairs(possibleNames) do
                if v.Name:lower():find(name:lower()) then
                    if v:IsA("RemoteEvent") then v:FireServer()
                    elseif v:IsA("RemoteFunction") then pcall(function() v:InvokeServer() end) end
                    return true
                end
            end
        end
    end
    return false
end

--------------------------------------------------------------------------------
-- CUSTOM BLUE GLASS GUI BUILDER
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CraftHubExpertUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ปุ่ม Toggle เมนู [K]
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
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Color3.fromRGB(0, 170, 255)
ToggleStroke.Thickness = 2

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 560, 0, 400)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 16, 32)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 180, 255)
MainStroke.Thickness = 2

-- Glow Effect Loop
task.spawn(function()
    while MainFrame.Parent do
        TweenService:Create(MainStroke, TweenInfo.new(0.4), {Color = Color3.fromRGB(0, 255, 255), Thickness = 2.5}):Play()
        TweenService:Create(ToggleStroke, TweenInfo.new(0.4), {Color = Color3.fromRGB(0, 255, 255), Thickness = 2.5}):Play()
        task.wait(0.4)
        TweenService:Create(MainStroke, TweenInfo.new(0.4), {Color = Color3.fromRGB(0, 120, 255), Thickness = 1.5}):Play()
        TweenService:Create(ToggleStroke, TweenInfo.new(0.4), {Color = Color3.fromRGB(0, 120, 255), Thickness = 1.5}):Play()
        task.wait(0.4)
    end
end)

-- Title
local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.Size = UDim2.new(1, -20, 0, 40)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Text = "⚡ THE CRAFT HUB | ADVANCED SYSTEM ⚡"
TitleLabel.TextColor3 = Color3.fromRGB(0, 230, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1

-- Sidebar Container
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(0, 140, 1, -50)
TabContainer.Position = UDim2.new(0, 10, 0, 45)
TabContainer.BackgroundColor3 = Color3.fromRGB(5, 12, 25)
TabContainer.BackgroundTransparency = 0.4
Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 8)

-- Content Container
local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -170, 1, -50)
ContentContainer.Position = UDim2.new(0, 160, 0, 45)
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

-- UI UI Components Helper
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

local function addDropdown(page, text, options, default, callback)
    local Frame = Instance.new("Frame", page)
    Frame.Size = UDim2.new(1, -10, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(12, 24, 48)
    Frame.BackgroundTransparency = 0.3
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local DropBtn = Instance.new("TextButton", Frame)
    DropBtn.Size = UDim2.new(0.45, 0, 0.7, 0)
    DropBtn.Position = UDim2.new(0.52, 0, 0.15, 0)
    DropBtn.BackgroundColor3 = Color3.fromRGB(20, 40, 70)
    DropBtn.Text = default
    DropBtn.TextColor3 = Color3.fromRGB(0, 230, 255)
    DropBtn.Font = Enum.Font.GothamBold
    DropBtn.TextSize = 10
    Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 4)

    local currentIndex = 1
    for i, opt in ipairs(options) do if opt == default then currentIndex = i break end end

    DropBtn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        local selected = options[currentIndex]
        DropBtn.Text = selected
        callback(selected)
    end)
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

-- Toggle GUI [K]
local uiVisible = true
local function toggleGui()
    uiVisible = not uiVisible
    MainFrame.Visible = uiVisible
end
ToggleBtn.MouseButton1Click:Connect(toggleGui)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.K then toggleGui() end
end)

--------------------------------------------------------------------------------
-- PAGING CREATION
--------------------------------------------------------------------------------
local PageSteal = createTab("⚡ บินขโมย & กรอง")
local PagePlayer = createTab("🏃 ตัวละคร & ความไว")
local PageVisuals = createTab("👁️ ESP & ส่องโซน")
local PageEvent = createTab("🌳 กิจกรรม Event")
local PageBase = createTab("🥚 ระบบฐาน & อัปเกรด")

Pages[1].Visible = true
Tabs[1].TextColor3 = Color3.fromRGB(0, 230, 255)

--------------------------------------------------------------------------------
-- 1. TAB: บินขโมย & กรองไข่ (SMART STEAL & FLY RETURN)
--------------------------------------------------------------------------------
addToggle(PageSteal, "เปิดระบบบินขโมย (ถือแล้วบินกลับทันที)", "AutoStealSmart", function(v)
    if v then
        task.spawn(function()
            while Flags.AutoStealSmart do
                task.wait(0.1)
                
                -- เช็กถ้าถือไข่อยู่แล้ว ให้บินกลับฐานทันที!
                if isHoldingEgg() then
                    local baseCF = getMyBaseCFrame()
                    if baseCF then
                        flyToTarget(baseCF)
                        task.wait(0.3)
                        fireRemote({"place", "selleggs", "drop"})
                    end
                else
                    -- บินหาไข่ตามตัวกรอง
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if not Flags.AutoStealSmart or isHoldingEgg() then break end
                        
                        if obj:IsA("BasePart") and obj.Name:lower():find("egg") and not obj:IsDescendantOf(LocalPlayer.Character) then
                            local passRarity, passZone, passTier = true, true, true
                            
                            -- กรอง Rarity
                            if Flags.FilterRarity ~= "ทั้งหมด" then
                                local r = obj:GetAttribute("Rarity") or obj.Name
                                if not tostring(r):lower():find(Flags.FilterRarity:lower()) then passRarity = false end
                            end
                            -- กรอง Zone
                            if Flags.FilterZone ~= "ทุกโซน" then
                                local parentZone = obj:FindFirstAncestorWhichIsA("Folder") or obj.Parent
                                if parentZone and not parentZone.Name:lower():find(Flags.FilterZone:lower()) then passZone = false end
                            end
                            -- กรอง ขนาด (Tier)
                            if Flags.FilterTier ~= "ทุกขนาด" then
                                local sz = obj.Size.Y
                                if Flags.FilterTier == "Small" and sz > 2.5 then passTier = false
                                elseif Flags.FilterTier == "Medium" and (sz <= 2.5 or sz > 4.5) then passTier = false
                                elseif Flags.FilterTier == "Big" and sz <= 4.5 then passTier = false end
                            end
                            
                            if passRarity and passZone and passTier then
                                flyToTarget(obj.CFrame)
                                task.wait(0.1)
                                -- กด ProximityPrompt เก็บไข่
                                for _, prompt in pairs(obj:GetDescendants()) do
                                    if prompt:IsA("ProximityPrompt") then fireproximityprompt(prompt) end
                                end
                                task.wait(Flags.StealDelay)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

addSlider(PageSteal, "ความเร็วการบิน (Fly Speed)", 20, 200, Flags.FlySpeed, function(v) Flags.FlySpeed = v end)
addDropdown(PageSteal, "กรองความหายาก", {"ทั้งหมด", "Common", "Rare", "Epic", "Legendary", "Mythic"}, "ทั้งหมด", function(v) Flags.FilterRarity = v end)
addDropdown(PageSteal, "กรองโซนขโมย", {"ทุกโซน", "Zone 1", "Zone 2", "Zone 3", "VIP Zone"}, "ทุกโซน", function(v) Flags.FilterZone = v end)
addDropdown(PageSteal, "กรองขนาดไข่", {"ทุกขนาด", "Small", "Medium", "Big"}, "ทุกขนาด", function(v) Flags.FilterTier = v end)

--------------------------------------------------------------------------------
-- 2. TAB: ตัวละคร & ความไว (CHARACTER & PROTECTIONS)
--------------------------------------------------------------------------------
addSlider(PagePlayer, "ความเร็วการวิ่ง (WalkSpeed)", 16, 250, Flags.WalkSpeed, function(v)
    Flags.WalkSpeed = v
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = v end
end)

addToggle(PagePlayer, "เก็บไข่เร็ว (Instant Fast Pick)", "FastPickup", function(v)
    if v then
        task.spawn(function()
            while Flags.FastPickup do
                task.wait(0.2)
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        prompt.HoldDuration = 0
                    end
                end
            end
        end)
    end
end)

addToggle(PagePlayer, "กันไข่ตก (Auto Grab Back)", "AutoReGrab", function(v)
    if v then
        task.spawn(function()
            while Flags.AutoReGrab do
                task.wait(0.1)
                local hrp = getRoot()
                if hrp and not isHoldingEgg() then
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and obj.Name:lower():find("egg") and (obj.Position - hrp.Position).Magnitude < 12 then
                            for _, prompt in pairs(obj:GetDescendants()) do
                                if prompt:IsA("ProximityPrompt") then fireproximityprompt(prompt) end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

addToggle(PagePlayer, "โดนตีไม่กระเด็น (Anti-Knockback)", "AntiKnockback", function(v)
    if v then
        task.spawn(function()
            while Flags.AntiKnockback do
                task.wait(0.05)
                local hrp = getRoot()
                if hrp then
                    hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
                    hrp.RotVelocity = Vector3.new(0, 0, 0)
                end
            end
        end)
    end
end)

--------------------------------------------------------------------------------
-- 3. TAB: ESP & ส่องโซน (VISUALS & TRACKING)
--------------------------------------------------------------------------------
local function clearESP()
    for _, v in pairs(ESP_Elements) do if v then v:Destroy() end end
    ESP_Elements = {}
end

addToggle(PageVisuals, "มองเห็นชื่อผู้เล่น + ระยะห่าง", "ESP_Names", function(v)
    clearESP()
    if v then
        task.spawn(function()
            while Flags.ESP_Names do
                task.wait(0.5)
                clearESP()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "CraftNameESP"
                        bb.Adornee = player.Character.Head
                        bb.Size = UDim2.new(0, 120, 0, 40)
                        bb.StudsOffset = Vector3.new(0, 2, 0)
                        bb.AlwaysOnTop = true

                        local txt = Instance.new("TextLabel", bb)
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.TextColor3 = Color3.fromRGB(0, 230, 255)
                        txt.Font = Enum.Font.GothamBold
                        txt.TextSize = 11

                        local hrp = getRoot()
                        local dist = hrp and math.floor((hrp.Position - player.Character.Head.Position).Magnitude) or 0
                        txt.Text = string.format("%s\n[%d m]", player.DisplayName, dist)
                        
                        bb.Parent = CoreGui
                        table.insert(ESP_Elements, bb)
                    end
                end
            end
        end)
    end
end)

addToggle(PageVisuals, "แสดงว่าผู้เล่นคนไหนอยู่โซนไหน", "ESP_Zones", function(v)
    if v then
        task.spawn(function()
            while Flags.ESP_Zones do
                task.wait(1)
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local pos = player.Character.HumanoidRootPart.Position
                        local currentZone = "นอกโซน / ฐาน"
                        for _, zone in pairs(workspace:GetDescendants()) do
                            if zone:IsA("BasePart") and zone.Name:lower():find("zone") then
                                local sz = zone.Size
                                local zpos = zone.Position
                                if math.abs(pos.X - zpos.X) < sz.X/2 and math.abs(pos.Z - zpos.Z) < sz.Z/2 then
                                    currentZone = zone.Name
                                    break
                                end
                            end
                        end
                        local hl = player.Character:FindFirstChild("CraftZoneHL") or Instance.new("Highlight", player.Character)
                        hl.Name = "CraftZoneHL"
                        hl.FillColor = currentZone:find("VIP") and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(0, 255, 120)
                        hl.FillTransparency = 0.5
                    end
                end
            end
        end)
    end
end)

--------------------------------------------------------------------------------
-- 4. TAB: กิจกรรม EVENT (EVENT TREE AUTO WARP)
--------------------------------------------------------------------------------
addButton(PageEvent, "วาร์ปไปหาต้นไม้ Event ตอนนี้ทันที", function()
    local treeFound = false
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("event") or obj.Name:lower():find("tree") or obj.Name:lower():find("ต้นไม้") then
            local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or (obj:IsA("BasePart") and obj)
            if part then
                flyToTarget(part.CFrame)
                treeFound = true
                break
            end
        end
    end
    if not treeFound then
        print("ไม่พบต้นไม้ Event ในขณะนี้")
    end
end)

--------------------------------------------------------------------------------
-- 5. TAB: ระบบฐาน & อัปเกรด (BASE & UPGRADES)
--------------------------------------------------------------------------------
addToggle(PageBase, "วางไข่อัตโนมัติ", "AutoPlaceAll", function(v)
    if v then
        task.spawn(function()
            while Flags.AutoPlaceAll do
                task.wait(0.5)
                fireRemote({"place", "placeegg", "putegg"})
            end
        end)
    end
end)

addToggle(PageBase, "วิ่งลู่วิ่งอัตโนมัติ", "AutoTreadmill", function(v)
    if v then
        task.spawn(function()
            while Flags.AutoTreadmill do
                task.wait(0.1)
                local treadmill = workspace:FindFirstChild("Treadmill", true)
                if treadmill then
                    local p = treadmill:IsA("Model") and treadmill.PrimaryPart or treadmill
                    if p then flyToTarget(p.CFrame) end
                end
                fireRemote({"train", "treadmill", "addspeed"})
            end
        end)
    end
end)

addToggle(PageBase, "อัปเกรดตัวละครอัตโนมัติ", "AutoUpgrades", function(v)
    if v then
        task.spawn(function()
            while Flags.AutoUpgrades do
                task.wait(1)
                fireRemote({"upgrade", "buy", "upgradespeed"})
            end
        end)
    end
end)

addButton(PageBase, "🔴 ปิดระบบทั้งหมด และ ทำลาย UI", function()
    for k in pairs(Flags) do if type(Flags[k]) == "boolean" then Flags[k] = false end end
    clearESP()
    ScreenGui:Destroy()
end)

-- Loop คุมความเร็ววิ่งต่อเนื่อง
RunService.RenderStepped:Connect(function()
    local hum = getHumanoid()
    if hum and Flags.WalkSpeed > 16 then
        hum.WalkSpeed = Flags.WalkSpeed
    end
end)
