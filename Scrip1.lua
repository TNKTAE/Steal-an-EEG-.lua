-- [[ THE CRAFT HUB | CUSTOM BLUE GLASS EDITION ]] --
-- UI กระจกสีน้ำเงินทรงโมเดิร์น สร้างขึ้นเองทั้งหมด (ไม่ใช้ Rayfield หรือ Hub คนอื่น)
-- ระบบการเคลื่อนที่: เปลี่ยนจากวาร์ปเป็นระบบบิน (Tween/BodyVelocity) เพื่อป้องกันการโดนเตะ

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- -----------------------------------------------------------------------------
-- GLOBAL STATES
-- -----------------------------------------------------------------------------
local Flags = {
    AutoStealAll = false,
    AutoStealSelected = false,
    StealBigEggs = false,
    AutoSellEggs = false,
    AutoPlaceAll = false,
    AutoTreadmill = false,
    AutoUpgrades = false,
    AutoClaimIndex = false,
    PlayerESP = false,
    LightningAura = false,
    FlySpeed = 50,
    SellInterval = 15,
    SelectedEgg = "Epic Egg"
}

local ESP_Storage = {}

-- -----------------------------------------------------------------------------
-- CORE HELPERS & UTILITIES
-- -----------------------------------------------------------------------------
local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- ระบบส่งสัญญาณแบบไดนามิก (หา Remote อัตโนมัติ)
local function fireRemote(possibleNames)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, name in pairs(possibleNames) do
                if v.Name:lower():find(name:lower()) then
                    if v:IsA("RemoteEvent") then
                        v:FireServer()
                    elseif v:IsA("RemoteFunction") then
                        pcall(function() v:InvokeServer() end)
                    end
                    return true
                end
            end
        end
    end
    return false
end

-- ระบบบินไปยังเป้าหมาย (แทนการวาร์ป เพื่อไม่ให้โดนเตะ)
local function flyTo(targetCFrame, speedMultiplier)
    local hrp = getRoot()
    if not hrp then return end
    
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local speed = Flags.FlySpeed * (speedMultiplier or 1)
    local timeToReach = distance / math.max(speed, 10)
    
    local tweenInfo = TweenInfo.new(timeToReach, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame + Vector3.new(0, 2, 0)})
    tween:Play()
    tween.Completed:Wait()
    
    -- ทำการกด ProximityPrompt หากมี
    for _, prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and (prompt.Parent:IsA("BasePart") and (prompt.Parent.Position - hrp.Position).Magnitude < 10) then
            fireproximityprompt(prompt)
        end
    end
end

-- -----------------------------------------------------------------------------
-- CUSTOM GLASS GUI CREATION
-- -----------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CraftHubCustomUI"
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ปุ่ม Toggle เมนูเปิด-ปิด
local ToggleBtn = Instance.new("TextButton")
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
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(0, 8)

local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Color3.fromRGB(0, 170, 255)
ToggleStroke.Thickness = 2

-- หน้าต่างหลัก (Main Window)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 16, 32)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 180, 255)
MainStroke.Thickness = 2

-- เอฟเฟกต์ไฟนีออนกะพริบที่ขอบ UI
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

-- Title Bar
local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.Size = UDim2.new(1, -20, 0, 40)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Text = "⚡ THE CRAFT HUB | กระจกสีน้ำเงิน ⚡"
TitleLabel.TextColor3 = Color3.fromRGB(0, 230, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1

-- Sidebar Container (แท็บเมนู)
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(0, 130, 1, -50)
TabContainer.Position = UDim2.new(0, 10, 0, 45)
TabContainer.BackgroundColor3 = Color3.fromRGB(5, 12, 25)
TabContainer.BackgroundTransparency = 0.4

local TabCorner = Instance.new("UICorner", TabContainer)
TabCorner.CornerRadius = UDim.new(0, 8)

-- Page Content Container
local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -160, 1, -50)
ContentContainer.Position = UDim2.new(0, 150, 0, 45)
ContentContainer.BackgroundTransparency = 1

-- ระบบสลับแท็บเมนู
local Tabs = {}
local Pages = {}

local function createTab(name, pageName)
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(1, -10, 0, 32)
    TabBtn.Position = UDim2.new(0, 5, 0, #Tabs * 36 + 5)
    TabBtn.BackgroundColor3 = Color3.fromRGB(15, 30, 60)
    TabBtn.BackgroundTransparency = 0.5
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 220, 255)
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 12

    local BtnC = Instance.new("UICorner", TabBtn)
    BtnC.CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", ContentContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 4
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)

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

-- สร้างสวิตช์เปิด/ปิด (Toggle Elements)
local function addToggle(page, text, flagName, callback)
    local Frame = Instance.new("Frame", page)
    Frame.Size = UDim2.new(1, -10, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(12, 24, 48)
    Frame.BackgroundTransparency = 0.3

    local Corner = Instance.new("UICorner", Frame)
    Corner.CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Switch = Instance.new("TextButton", Frame)
    Switch.Size = UDim2.new(0, 50, 0, 22)
    Switch.Position = UDim2.new(1, -60, 0.5, -11)
    Switch.BackgroundColor3 = Flags[flagName] and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(40, 50, 70)
    Switch.Text = Flags[flagName] and "เปิด" or "ปิด"
    Switch.TextColor3 = Color3.fromRGB(255, 255, 255)
    Switch.Font = Enum.Font.GothamBold
    Switch.TextSize = 11

    local SwCorner = Instance.new("UICorner", Switch)
    SwCorner.CornerRadius = UDim.new(0, 11)

    Switch.MouseButton1Click:Connect(function()
        Flags[flagName] = not Flags[flagName]
        Switch.BackgroundColor3 = Flags[flagName] and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(40, 50, 70)
        Switch.Text = Flags[flagName] and "เปิด" or "ปิด"
        callback(Flags[flagName])
    end)
end

-- สร้างปุ่มกด (Button Elements)
local function addButton(page, text, callback)
    local Btn = Instance.new("TextButton", page)
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 210)
    Btn.BackgroundTransparency = 0.3
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12

    local Corner = Instance.new("UICorner", Btn)
    Corner.CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(callback)
end

-- ระบบ ซ่อน/แสดง UI
local uiVisible = true
local function toggleGui()
    uiVisible = not uiVisible
    MainFrame.Visible = uiVisible
end

ToggleBtn.MouseButton1Click:Connect(toggleGui)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.K then
        toggleGui()
    end
end)

-- -----------------------------------------------------------------------------
-- สร้างหมวดหมู่แท็บภาษาไทย
-- -----------------------------------------------------------------------------
local PageSteal = createTab("⚡ ระบบบินฟาร์ม", "Steal")
local PageBase = createTab("🥚 วาง/ขายไข่", "Base")
local PageStats = createTab("💎 อัปเกรดตัวละคร", "Stats")
local PageVisuals = createTab("🌌 เอฟเฟกต์/ระบบ", "Visuals")

Pages[1].Visible = true
Tabs[1].TextColor3 = Color3.fromRGB(0, 230, 255)

-- -----------------------------------------------------------------------------
-- 1. ฟังก์ชันแท็บระบบบินฟาร์ม (Flying Steal Logic)
-- -----------------------------------------------------------------------------
local function runFlyStealAll()
    while Flags.AutoStealAll do
        task.wait(0.1)
        local hrp = getRoot()
        if hrp then
            for _, obj in pairs(workspace:GetDescendants()) do
                if not Flags.AutoStealAll then break end
                if obj:IsA("BasePart") and obj.Name:lower():find("egg") and not obj:IsDescendantOf(LocalPlayer.Character) then
                    flyTo(obj.CFrame)
                end
            end
        end
    end
end

local function runFlyStealBig()
    while Flags.StealBigEggs do
        task.wait(0.2)
        local hrp = getRoot()
        if hrp then
            for _, obj in pairs(workspace:GetDescendants()) do
                if not Flags.StealBigEggs then break end
                if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("egg") then
                    local sizeY = obj:IsA("BasePart") and obj.Size.Y or (obj.PrimaryPart and obj.PrimaryPart.Size.Y or 0)
                    if sizeY > 3 then
                        local target = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                        if target then
                            flyTo(target.CFrame)
                        end
                    end
                end
            end
        end
    end
end

addToggle(PageSteal, "บินขโมยไข่ทั้งหมดในแมพ", "AutoStealAll", function(v)
    if v then task.spawn(runFlyStealAll) end
end)

addToggle(PageSteal, "บินขโมยเฉพาะไข่ฟองใหญ่", "StealBigEggs", function(v)
    if v then task.spawn(runFlyStealBig) end
end)

-- -----------------------------------------------------------------------------
-- 2. ฟังก์ชันแท็บวาง/ขายไข่
-- -----------------------------------------------------------------------------
local function runAutoSell()
    while Flags.AutoSellEggs do
        task.wait(Flags.SellInterval)
        local hrp = getRoot()
        local sellZone = workspace:FindFirstChild("SellZone", true) or workspace:FindFirstChild("SellArea", true)
        if hrp and sellZone then
            local oldCF = hrp.CFrame
            local targetPart = sellZone:IsA("Model") and (sellZone.PrimaryPart or sellZone:FindFirstChildWhichIsA("BasePart")) or sellZone
            if targetPart then
                flyTo(targetPart.CFrame)
                task.wait(0.5)
                fireRemote({"sell", "selleggs", "drop"})
                flyTo(oldCF)
            end
        else
            fireRemote({"sell", "selleggs", "drop"})
        end
    end
end

local function runAutoPlace()
    while Flags.AutoPlaceAll do
        task.wait(0.5)
        fireRemote({"place", "placeegg", "putegg"})
    end
end

addToggle(PageBase, "วางไข่อัตโนมัติ", "AutoPlaceAll", function(v)
    if v then task.spawn(runAutoPlace) end
end)

addToggle(PageBase, "บินไปขายไข่อัตโนมัติ", "AutoSellEggs", function(v)
    if v then task.spawn(runAutoSell) end
end)

-- -----------------------------------------------------------------------------
-- 3. ฟังก์ชันแท็บอัปเกรด
-- -----------------------------------------------------------------------------
local function runAutoTreadmill()
    while Flags.AutoTreadmill do
        task.wait(0.1)
        local treadmill = workspace:FindFirstChild("Treadmill", true) or workspace:FindFirstChild("Train", true)
        if treadmill then
            local targetPart = treadmill:IsA("Model") and (treadmill.PrimaryPart or treadmill:FindFirstChildWhichIsA("BasePart")) or treadmill
            if targetPart then
                flyTo(targetPart.CFrame)
            end
        end
        fireRemote({"train", "treadmill", "addspeed"})
    end
end

local function runAutoUpgrades()
    while Flags.AutoUpgrades do
        task.wait(1)
        fireRemote({"upgrade", "upgradespeed", "buy"})
    end
end

addToggle(PageStats, "วาร์ปไปวิ่งลู่วิ่งอัตโนมัติ", "AutoTreadmill", function(v)
    if v then task.spawn(runAutoTreadmill) end
end)

addToggle(PageStats, "อัปเกรดตัวละครอัตโนมัติ", "AutoUpgrades", function(v)
    if v then task.spawn(runAutoUpgrades) end
end)

addButton(PageStats, "ใส่สัตว์เลี้ยง/อุปกรณ์ที่ดีที่สุด", function()
    fireRemote({"equipbest", "equip"})
end)

-- -----------------------------------------------------------------------------
-- 4. ฟังก์ชันแท็บเอฟเฟกต์ & สวิตช์ทำลาย UI
-- -----------------------------------------------------------------------------
local LightningAtt, LightningPart

local function toggleLightningFX(val)
    if val then
        local hrp = getRoot()
        if hrp then
            LightningAtt = Instance.new("Attachment", hrp)
            LightningPart = Instance.new("ParticleEmitter", LightningAtt)
            LightningPart.Texture = "rbxassetid://258122976"
            LightningPart.Color = ColorSequence.new(Color3.fromRGB(0, 230, 255), Color3.fromRGB(0, 100, 255))
            LightningPart.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0)})
            LightningPart.Lifetime = NumberRange.new(0.1, 0.3)
            LightningPart.Rate = 35
            LightningPart.Speed = NumberRange.new(3, 8)
        end
    else
        if LightningPart then LightningPart:Destroy() end
        if LightningAtt then LightningAtt:Destroy() end
    end
end

local function toggleESP(val)
    if not val then
        for _, v in pairs(ESP_Storage) do if v then v:Destroy() end end
        ESP_Storage = {}
        return
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(0, 230, 255)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.4
            hl.Parent = player.Character
            table.insert(ESP_Storage, hl)
        end
    end
end

addToggle(PageVisuals, "เปิดออร่าสายฟ้าล้อมรอบตัว", "LightningAura", toggleLightningFX)
addToggle(PageVisuals, "มองเห็นผู้เล่นอื่นผ่านกำแพง (ESP)", "PlayerESP", toggleESP)

addButton(PageVisuals, "🔴 ปิดระบบทั้งหมด และ ทำลาย UI", function()
    for k in pairs(Flags) do
        if type(Flags[k]) == "boolean" then Flags[k] = false end
    end
    toggleESP(false)
    toggleLightningFX(false)
    ScreenGui:Destroy()
end)
