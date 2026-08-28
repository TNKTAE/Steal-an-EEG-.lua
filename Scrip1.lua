-- [[ THE CRAFT HUB | FAST AUTO-GRAB FIX V3 ]] --
-- แก้ไขระบบถือไข่เข้ามือ: ย้ำกด Prompt + ล็อคตำแหน่งจนกว่าไข่จะเข้ามือ 100%

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
    -- Steal Modes
    AutoStealFly = false,
    AutoStealRun = false,
    GroundedFly = true,
    FreezeOnFly = true,
    ZigZagReturn = true,
    
    -- Speed Controls
    FlySpeed = 200,
    WalkSpeed = 16,
    StealDelay = 0.1,
    
    -- Egg Filters
    FilterRarity = "ทั้งหมด",
    FilterZone = "ทุกโซน",
    FilterTier = "ทุกขนาด",
    
    -- Automation & Protection
    AutoReGrabFast = true,
    AutoCollectTrash = false,
    FastPickup = true,
    AntiKnockback = true,
    
    -- Visuals
    ESP_Names = false,
    ESP_Zones = false
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

-- เช็กว่ามีไข่อยู่ในมือหรือยัง
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

-- 🔥 ฟังก์ชันบังคับเก็บไข่เข้ามือ (Spam Grab Until In Hand) 🔥
local function forceGrabEgg(eggPart)
    local hrp = getRoot()
    if not hrp or not eggPart then return end
    
    local timeout = os.clock() + 1.5 -- ตั้งเวลาลองสูงสุด 1.5 วินาทีต่อฟาร์ม 1 ใบ
    
    while os.clock() < timeout and not isHoldingEgg() and eggPart.Parent do
        -- 1. ล็อคพิกัดให้ตัวละครติดกับไข่
        hrp.CFrame = eggPart.CFrame
        
        -- 2. ย้ำกด ProximityPrompt ทั้งหมดที่อยู่ในไข่และบริเวณรอบๆ
        for _, prompt in pairs(eggPart:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                prompt.HoldDuration = 0
                fireproximityprompt(prompt)
            end
        end
        for _, prompt in pairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and (prompt.Parent.Position - hrp.Position).Magnitude < 6 then
                prompt.HoldDuration = 0
                fireproximityprompt(prompt)
            end
        end
        
        -- 3. ยิง Remote ช่วยเก็บ
        fireRemote({"steal", "take", "grab", "pickup", "collect"})
        
        task.wait(0.05)
    end
end

local function getGroundedCFrame(targetCFrame)
    if not Flags.GroundedFly then return targetCFrame + Vector3.new(0, 2, 0) end
    local rayOrigin = targetCFrame.Position + Vector3.new(0, 20, 0)
    local rayDirection = Vector3.new(0, -50, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if raycastResult then
        return CFrame.new(raycastResult.Position + Vector3.new(0, 2.5, 0))
    end
    return targetCFrame
end

local function setCharacterFrozen(frozen)
    local hum = getHumanoid()
    local hrp = getRoot()
    if hum then
        if frozen and Flags.FreezeOnFly then
            hum.PlatformStand = true
            for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:Stop() end
        else
            hum.PlatformStand = false
        end
    end
    if hrp and frozen and Flags.FreezeOnFly then
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
    end
end

local function flyToTarget(targetCFrame)
    local hrp = getRoot()
    if not hrp then return end
    
    local destination = getGroundedCFrame(targetCFrame)
    local distance = (hrp.Position - destination.Position).Magnitude
    local timeToReach = distance / math.max(Flags.FlySpeed, 10)
    
    setCharacterFrozen(true)
    
    local tweenInfo = TweenInfo.new(timeToReach, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = destination})
    tween:Play()
    tween.Completed:Wait()
    
    setCharacterFrozen(false)
end

local function flyZigZagToBase(baseCFrame)
    local hrp = getRoot()
    if not hrp then return end
    
    local startPos = hrp.Position
    local endPos = baseCFrame.Position
    local totalDistance = (endPos - startPos).Magnitude
    local segments = math.clamp(math.floor(totalDistance / 25), 2, 8)
    
    setCharacterFrozen(true)
    
    for i = 1, segments do
        if not isHoldingEgg() then break end
        local alpha = i / segments
        local currentTarget = startPos:Lerp(endPos, alpha)
        
        if i < segments then
            local offsetDirection = (i % 2 == 0) and 15 or -15
            local rightVector = CFrame.lookAt(startPos, endPos).RightVector
            currentTarget = currentTarget + (rightVector * offsetDirection)
        end
        
        local stepCFrame = getGroundedCFrame(CFrame.new(currentTarget))
        local dist = (hrp.Position - stepCFrame.Position).Magnitude
        local t = dist / math.max(Flags.FlySpeed, 10)
        
        local tween = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = stepCFrame})
        tween:Play()
        tween.Completed:Wait()
    end
    
    setCharacterFrozen(false)
end

--------------------------------------------------------------------------------
-- CUSTOM GUI BUILDER
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CraftHubUltimateFixUI"
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
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Color3.fromRGB(0, 170, 255)
ToggleStroke.Thickness = 2

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 420)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 16, 32)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 180, 255)
MainStroke.Thickness = 2

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

local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.Size = UDim2.new(1, -20, 0, 40)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Text = "⚡ THE CRAFT HUB | FIXED AUTO-GRAB EDITION ⚡"
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
    Container.Size = UDim2.new(1, -10, 0, 65)
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
    ScrollBtns.Size = UDim2.new(1, -16, 0, 38)
    ScrollBtns.Position = UDim2.new(0, 8, 0, 22)
    ScrollBtns.BackgroundTransparency = 1
    ScrollBtns.ScrollBarThickness = 2
    ScrollBtns.CanvasSize = UDim2.new(0, 0, 0, 0)

    local Layout = Instance.new("UIListLayout", ScrollBtns)
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.Padding = UDim.new(0, 6)

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
    ScrollBtns.CanvasSize = UDim2.new(0, #options * 81, 0, 0)
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
local function toggleGui()
    uiVisible = not uiVisible
    MainFrame.Visible = uiVisible
end
ToggleBtn.MouseButton1Click:Connect(toggleGui)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.K then toggleGui() end
end)

--------------------------------------------------------------------------------
-- PAGES
--------------------------------------------------------------------------------
local PageSteal = createTab("⚡ บิน/วิ่งขโมย (ล็อกมือ)")
local PageFilters = createTab("🎯 กรองความหายาก/โซน")
local PagePlayer = createTab("🏃 ความเร็ว & ป้องกัน")
local PageVisuals = createTab("👁️ ESP & ขยะ")

Pages[1].Visible = true
Tabs[1].TextColor3 = Color3.fromRGB(0, 230, 255)

--------------------------------------------------------------------------------
-- 1. TAB: บิน / วิ่งขโมย (ปรับแก้ระบบถือไข่แล้วบินกลับ)
--------------------------------------------------------------------------------
addToggle(PageSteal, "ระบบบินขโมยไข่ (ย้ำกดจนไข่เข้ามือ)", "AutoStealFly", function(v)
    if v then
        Flags.AutoStealRun = false
        task.spawn(function()
            while Flags.AutoStealFly do
                task.wait(0.1)
                
                -- เช็กถ้ามีไข่อยู่ในมือ ให้บินกลับฐานทันที
                if isHoldingEgg() then
                    local baseCF = getMyBaseCFrame()
                    if baseCF then
                        if Flags.ZigZagReturn then
                            flyZigZagToBase(baseCF)
                        else
                            flyToTarget(baseCF)
                        end
                        task.wait(0.2)
                        fireRemote({"place", "selleggs", "drop"})
                    end
                else
                    -- หาไข่และบินไปย้ำกดเก็บ
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if not Flags.AutoStealFly or isHoldingEgg() then break end
                        
                        if obj:IsA("BasePart") and obj.Name:lower():find("egg") and not obj:IsDescendantOf(LocalPlayer.Character) then
                            local passRarity, passZone, passTier = true, true, true
                            
                            if Flags.FilterRarity ~= "ทั้งหมด" then
                                local r = obj:GetAttribute("Rarity") or obj.Name
                                if not tostring(r):lower():find(Flags.FilterRarity:lower()) then passRarity = false end
                            end
                            if Flags.FilterZone ~= "ทุกโซน" then
                                local pZone = obj:FindFirstAncestorWhichIsA("Folder") or obj.Parent
                                if pZone and not pZone.Name:lower():find(Flags.FilterZone:lower()) then passZone = false end
                            end
                            if Flags.FilterTier ~= "ทุกขนาด" then
                                local sz = obj.Size.Y
                                if Flags.FilterTier == "Small" and sz > 2.5 then passTier = false
                                elseif Flags.FilterTier == "Medium" and (sz <= 2.5 or sz > 4.5) then passTier = false
                                elseif Flags.FilterTier == "Big" and sz <= 4.5 then passTier = false end
                            end
                            
                            if passRarity and passZone and passTier then
                                -- 1. บินไปหาไข่
                                flyToTarget(obj.CFrame)
                                
                                -- 2. ⚡ ย้ำกดเก็บจนกว่าไข่จะเข้ามือ ⚡
                                forceGrabEgg(obj)
                                
                                task.wait(Flags.StealDelay)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

addToggle(PageSteal, "ระบบวิ่งขโมยไข่ (ย้ำกดจนไข่เข้ามือ)", "AutoStealRun", function(v)
    if v then
        Flags.AutoStealFly = false
        task.spawn(function()
            while Flags.AutoStealRun do
                task.wait(0.2)
                local hrp = getRoot()
                local hum = getHumanoid()
                if hrp and hum then
                    if isHoldingEgg() then
                        local baseCF = getMyBaseCFrame()
                        if baseCF then hum:MoveTo(baseCF.Position) end
                    else
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if not Flags.AutoStealRun or isHoldingEgg() then break end
                            if obj:IsA("BasePart") and obj.Name:lower():find("egg") and not obj:IsDescendantOf(LocalPlayer.Character) then
                                hum:MoveTo(obj.Position)
                                if (hrp.Position - obj.Position).Magnitude < 10 then
                                    forceGrabEgg(obj)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

addToggle(PageSteal, "บินติดเรียบพื้นดิน (Grounded Fly)", "GroundedFly", function(v) Flags.GroundedFly = v end)
addToggle(PageSteal, "ตัวแข็งพุ่งตรงขณะบิน (Freeze Rig)", "FreezeOnFly", function(v) Flags.FreezeOnFly = v end)
addToggle(PageSteal, "บินกลับฐานแบบซิกแซก (Zig-Zag Fly)", "ZigZagReturn", function(v) Flags.ZigZagReturn = v end)

--------------------------------------------------------------------------------
-- OTHER TABS & SETTINGS
--------------------------------------------------------------------------------
addSelectorGrid(PageFilters, "เลือกความหายากของไข่", {"ทั้งหมด", "Common", "Rare", "Epic", "Legendary", "Mythic"}, Flags.FilterRarity, function(v) Flags.FilterRarity = v end)
addSelectorGrid(PageFilters, "เลือกโซนขโมยไข่", {"ทุกโซน", "Zone 1", "Zone 2", "Zone 3", "VIP Zone"}, Flags.FilterZone, function(v) Flags.FilterZone = v end)
addSelectorGrid(PageFilters, "เลือกขนาดของไข่", {"ทุกขนาด", "Small", "Medium", "Big"}, Flags.FilterTier, function(v) Flags.FilterTier = v end)

addSlider(PagePlayer, "ปรับความเร็วการบิน (Fly Speed)", 20, 2000, Flags.FlySpeed, function(v) Flags.FlySpeed = v end)
addSlider(PagePlayer, "ปรับความเร็วการวิ่ง (WalkSpeed)", 16, 2000, Flags.WalkSpeed, function(v)
    Flags.WalkSpeed = v
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = v end
end)

addToggle(PagePlayer, "เก็บไข่ตกพื้นกลับเข้ามือทันที (Ultra Fast)", "AutoReGrabFast", function(v)
    if v then
        task.spawn(function()
            while Flags.AutoReGrabFast do
                task.wait(0.02)
                local hrp = getRoot()
                if hrp and not isHoldingEgg() then
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and obj.Name:lower():find("egg") and (obj.Position - hrp.Position).Magnitude < 15 then
                            forceGrabEgg(obj)
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
                    hrp.RotVelocity = Vector3.zero
                end
            end
        end)
    end
end)

addToggle(PageVisuals, "ลอยไปเก็บขยะ/ไอเทมดรอปอัตโนมัติ", "AutoCollectTrash", function(v)
    if v then
        task.spawn(function()
            while Flags.AutoCollectTrash do
                task.wait(0.3)
                local hrp = getRoot()
                if hrp and not isHoldingEgg() then
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if not Flags.AutoCollectTrash then break end
                        if obj:IsA("BasePart") and (obj.Name:lower():find("trash") or obj.Name:lower():find("coin") or obj.Name:lower():find("drop")) then
                            flyToTarget(obj.CFrame)
                            task.wait(0.1)
                        end
                    end
                end
            end
        end)
    end
end)

addButton(PageVisuals, "🔴 ปิดระบบทั้งหมด และ ทำลาย UI", function()
    for k in pairs(Flags) do if type(Flags[k]) == "boolean" then Flags[k] = false end end
    for _, el in pairs(ESP_Elements) do if el then el:Destroy() end end
    setCharacterFrozen(false)
    ScreenGui:Destroy()
end)

RunService.RenderStepped:Connect(function()
    local hum = getHumanoid()
    if hum and Flags.WalkSpeed > 16 then
        hum.WalkSpeed = Flags.WalkSpeed
    end
end)
