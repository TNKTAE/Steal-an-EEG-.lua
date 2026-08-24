-- ==========================================
-- Script: THE CRAFT HUB (Steal an Egg)
-- Language: Lua (Roblox LocalScript)
-- Theme: Modern Cyan / Light Blue UI
-- Features: Auto Steal, Auto Return Base, WalkSpeed, Fly, Anti-Egg Drop, UI Toggle
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Global Variables / State
local AutoStealEnabled = false
local AutoReturnEnabled = false
local FlyEnabled = false
local NoDropEnabled = false
local WalkSpeedValue = 16
local SelectedRarity = "All"
local FlySpeed = 50
local BaseCFrame = nil -- ตำแหน่งฐานของตัวผู้เล่น

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 390)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -195)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 28, 38)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 10)
MainUICorner.Parent = MainFrame

-- Top Bar Header
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 10)
TopBarFix.Position = UDim2.new(0, 0, 1, -10)
TopBarFix.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

-- Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "THE CRAFT HUB | Steal an Egg"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Close / Minimize Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(15, 20, 28)
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.Text = "-"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TopBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 6)
CloseBtnCorner.Parent = CloseBtn

-- Floating Toggle Button
local ToggleGuiBtn = Instance.new("TextButton")
ToggleGuiBtn.Name = "ToggleUIBtn"
ToggleGuiBtn.Size = UDim2.new(0, 110, 0, 36)
ToggleGuiBtn.Position = UDim2.new(0, 15, 0.5, -18)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
ToggleGuiBtn.Text = "THE CRAFT"
ToggleGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleGuiBtn.Font = Enum.Font.GothamBold
ToggleGuiBtn.TextSize = 13
ToggleGuiBtn.Active = true
ToggleGuiBtn.Draggable = true
ToggleGuiBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleGuiBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
ToggleStroke.Thickness = 1.5
ToggleStroke.Parent = ToggleGuiBtn

local function ToggleMainUI()
    MainFrame.Visible = not MainFrame.Visible
end

ToggleGuiBtn.MouseButton1Click:Connect(ToggleMainUI)
CloseBtn.MouseButton1Click:Connect(ToggleMainUI)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.K or input.KeyCode == Enum.KeyCode.RightControl then
            ToggleMainUI()
        end
    end
end)

-- Content Scroll Container
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(1, -20, 1, -55)
ScrollContainer.Position = UDim2.new(0, 10, 0, 45)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
ScrollContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- Helper Functions
local function CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(30, 42, 56)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 230, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.AutoButtonColor = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 170, 230)
    stroke.Thickness = 1
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    btn.Parent = ScrollContainer
    return btn
end

local function CreateLabel(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(0, 210, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = ScrollContainer
    return lbl
end

-- ==========================================
-- UI CONTROLS & FEATURES
-- ==========================================

CreateLabel("Player: " .. LocalPlayer.Name)

-- Check if Character is holding an Egg
local function HasEgg()
    local char = LocalPlayer.Character
    if not char then return false end
    
    -- ตรวจสอบจาก Tool ใน Character หรือวัตถุติดตัว
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") or item.Name:lower():find("egg") then
            return true
        end
    end
    return false
end

-- Function Find Base Position
local function GetPlayerBaseCFrame()
    if BaseCFrame then return BaseCFrame end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        -- ค้นหา Base/Plot ใน Workspace ที่ตรงกับชื่อผู้เล่น
        for _, plot in ipairs(workspace:GetDescendants()) do
            if plot.Name:find(LocalPlayer.Name) or (plot:FindFirstChild("Owner") and tostring(plot.Owner.Value) == LocalPlayer.Name) then
                local spawnPart = plot:FindFirstChild("Spawn") or plot:FindFirstChild("Base") or plot:FindFirstChildWhichIsA("BasePart")
                if spawnPart then
                    return spawnPart.CFrame * CFrame.new(0, 3, 0)
                end
            end
        end
    end
    return nil
end

-- 1. Set Base Position Button
local SetBaseBtn = CreateButton("Set Current Position as Base", function(btn)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        BaseCFrame = char.HumanoidRootPart.CFrame
        btn.Text = "Base Set Success!"
        task.wait(1.5)
        btn.Text = "Set Current Position as Base"
    end
end)

-- 2. Auto Return to Base Toggle
local AutoReturnBtn = CreateButton("Auto Return Base: OFF", function(btn)
    AutoReturnEnabled = not AutoReturnEnabled
    btn.Text = "Auto Return Base: " .. (AutoReturnEnabled and "ON" or "OFF")
    btn.TextColor3 = AutoReturnEnabled and Color3.fromRGB(80, 255, 140) or Color3.fromRGB(200, 230, 255)
end)

-- 3. Anti-Egg Drop (ป้องกันไข่หลุด)
local NoDropBtn = CreateButton("No Egg Drop [Anti-Hit]: OFF", function(btn)
    NoDropEnabled = not NoDropEnabled
    btn.Text = "No Egg Drop [Anti-Hit]: " .. (NoDropEnabled and "ON" or "OFF")
    btn.TextColor3 = NoDropEnabled and Color3.fromRGB(80, 255, 140) or Color3.fromRGB(200, 230, 255)
end)

RunService.Stepped:Connect(function()
    if NoDropEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name:lower():find("egg") then
                part.CanCollide = false
            end
        end
    end
end)

-- 4. Auto Steal Egg
local TargetEggInfo = CreateLabel("Nearest Egg: Searching...")
local AutoStealBtn = CreateButton("Auto Steal Egg: OFF", function(btn)
    AutoStealEnabled = not AutoStealEnabled
    btn.Text = "Auto Steal Egg: " .. (AutoStealEnabled and "ON" or "OFF")
    btn.TextColor3 = AutoStealEnabled and Color3.fromRGB(80, 255, 140) or Color3.fromRGB(200, 230, 255)
end)

-- Find Eggs Function
local function GetTargetEgg()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

    local closestEgg = nil
    local shortestDistance = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local isEgg = obj.Name:lower():find("egg")
            local rarityMatch = (SelectedRarity == "All") or (obj:FindFirstChild("Rarity") and tostring(obj.Rarity.Value) == SelectedRarity)

            if isEgg and rarityMatch then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    local dist = (character.HumanoidRootPart.Position - part.Position).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestEgg = {Object = obj, Part = part, Name = obj.Name}
                    end
                end
            end
        end
    end
    return closestEgg
end

-- Auto Steal & Auto Return Loop
task.spawn(function()
    while task.wait(0.2) do
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            -- ถ้าถือไข่อยู่ และเปิด Auto Return -> วาร์ปกลับฐานทันที
            if AutoReturnEnabled and HasEgg() then
                local targetBase = GetPlayerBaseCFrame()
                if targetBase then
                    TargetEggInfo.Text = "Status: Holding Egg -> Returning to Base..."
                    char.HumanoidRootPart.CFrame = targetBase
                    task.wait(1)
                end
            elseif AutoStealEnabled then
                local target = GetTargetEgg()
                if target then
                    TargetEggInfo.Text = "Nearest Egg: " .. target.Name
                    char.HumanoidRootPart.CFrame = target.Part.CFrame * CFrame.new(0, 3, 0)
                else
                    TargetEggInfo.Text = "Nearest Egg: None Found"
                end
            end
        end
    end
end)

-- 5. Select Rarity Filter
local Rarities = {"All", "Common", "Rare", "Epic", "Legendary", "Mythic"}
local CurrentRarityIndex = 1
local RarityBtn = CreateButton("Selected Rarity: All", function(btn)
    CurrentRarityIndex = (CurrentRarityIndex % #Rarities) + 1
    SelectedRarity = Rarities[CurrentRarityIndex]
    btn.Text = "Selected Rarity: " .. SelectedRarity
end)

-- 6. Speed Hack
local SpeedBtn = CreateButton("WalkSpeed: 16 (Normal)", function(btn)
    if WalkSpeedValue == 16 then
        WalkSpeedValue = 50
    elseif WalkSpeedValue == 50 then
        WalkSpeedValue = 100
    else
        WalkSpeedValue = 16
    end
    btn.Text = "WalkSpeed: " .. tostring(WalkSpeedValue)
end)

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeedValue
    end
end)

-- 7. Fly Hack
local FlyBtn = CreateButton("Fly: OFF", function(btn)
    FlyEnabled = not FlyEnabled
    btn.Text = "Fly: " .. (FlyEnabled and "ON" or "OFF")
    btn.TextColor3 = FlyEnabled and Color3.fromRGB(80, 255, 140) or Color3.fromRGB(200, 230, 255)

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    if FlyEnabled then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(1, 1, 1) * 1000000
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        
        task.spawn(function()
            while FlyEnabled and char:FindFirstChild("HumanoidRootPart") do
                local camCFrame = workspace.CurrentCamera.CFrame
                local moveDir = Vector3.zero

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

                bv.Velocity = moveDir * FlySpeed
                task.wait()
            end
            if bv then bv:Destroy() end
        end)
    else
        if hrp:FindFirstChild("FlyVelocity") then
            hrp.FlyVelocity:Destroy()
        end
    end
end)

-- Dynamic Canvas Resizing
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end)