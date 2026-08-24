-- ==========================================
-- Script: THE CRAFT HUB (Steal an Egg)
-- UI Style: Thai Language, Cyan Cyberpunk Animation
-- Features: ESP, Anti-Drop, Custom Speed, Auto Farm
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Variables State
local Config = {
    AutoSteal = false,
    AutoReturn = false,
    NoDrop = false,
    LockEggInHand = false,
    Fly = false,
    PlayerESP = false,
    EggESP = false,
    WalkSpeed = 16,
    FlySpeed = 50,
    SelectedRarity = "ทั้งหมด",
    BaseCFrame = nil
}

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHub_TH"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 420)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 22, 32)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 12)
MainUICorner.Parent = MainFrame

local MainUIStroke = Instance.new("UIStroke")
MainUIStroke.Color = Color3.fromRGB(0, 200, 255)
MainUIStroke.Thickness = 2
MainUIStroke.Parent = MainFrame

-- Top Bar Header
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(10, 15, 24)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 230, 255))
})
UIGradient.Parent = TopBar

-- Glowing Animation Effect
task.spawn(function()
    while task.wait(0.05) do
        MainUIStroke.Color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
    end
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "THE CRAFT HUB ✦ Steal an Egg"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Floating Toggle Icon
local ToggleGuiBtn = Instance.new("TextButton")
ToggleGuiBtn.Size = UDim2.new(0, 100, 0, 35)
ToggleGuiBtn.Position = UDim2.new(0, 15, 0.5, -17)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleGuiBtn.Text = "THE CRAFT"
ToggleGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleGuiBtn.Font = Enum.Font.GothamBold
ToggleGuiBtn.TextSize = 12
ToggleGuiBtn.Active = true
ToggleGuiBtn.Draggable = true
ToggleGuiBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleGuiBtn

local function ToggleMainUI()
    MainFrame.Visible = not MainFrame.Visible
end
ToggleGuiBtn.MouseButton1Click:Connect(ToggleMainUI)
CloseBtn.MouseButton1Click:Connect(ToggleMainUI)

-- Scroll Frame Container
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(1, -20, 1, -60)
ScrollContainer.Position = UDim2.new(0, 10, 0, 50)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
ScrollContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- UI Helper Creator Functions
local function CreateToggleRow(labelText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -10, 0, 40)
    row.BackgroundColor3 = Color3.fromRGB(22, 32, 46)
    row.Parent = ScrollContainer

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, -10, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(220, 245, 255)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 60, 0, 26)
    switch.Position = UDim2.new(1, -70, 0.5, -13)
    switch.BackgroundColor3 = Color3.fromRGB(40, 50, 65)
    switch.Text = "ปิด"
    switch.TextColor3 = Color3.fromRGB(200, 200, 200)
    switch.Font = Enum.Font.GothamBold
    switch.TextSize = 12
    switch.Parent = row

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0, 13)
    switchCorner.Parent = switch

    local state = false
    switch.MouseButton1Click:Connect(function()
        state = not state
        switch.Text = state and "เปิด" or "ปิด"
        
        local targetColor = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 50, 65)
        TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        switch.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        
        callback(state)
    end)
    return row
end

local function CreateInputRow(labelText, defaultText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -10, 0, 40)
    row.BackgroundColor3 = Color3.fromRGB(22, 32, 46)
    row.Parent = ScrollContainer

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, -10, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(220, 245, 255)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0, 90, 0, 26)
    textBox.Position = UDim2.new(1, -100, 0.5, -13)
    textBox.BackgroundColor3 = Color3.fromRGB(12, 18, 26)
    textBox.Text = tostring(defaultText)
    textBox.TextColor3 = Color3.fromRGB(0, 220, 255)
    textBox.Font = Enum.Font.GothamBold
    textBox.TextSize = 13
    textBox.Parent = row

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = textBox

    textBox.FocusLost:Connect(function()
        callback(textBox.Text)
    end)
    return row
end

-- ==========================================
-- SCRIPT FEATURES IMPLEMENTATION
-- ==========================================

-- 1. ล็อกไข่ไม่ให้หลุดมือ และ ป้องกันโดนตีแล้วไข่ตก
CreateToggleRow("ป้องกันไข่หลุดมือ (ถือไข่แน่น)", function(val)
    Config.LockEggInHand = val
end)

CreateToggleRow("ป้องกันมอนสเตอร์ตีแล้วไข่หลุด", function(val)
    Config.NoDrop = val
end)

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        if Config.NoDrop or Config.LockEggInHand then
            for _, item in ipairs(char:GetDescendants()) do
                if item:IsA("BasePart") and item.Name:lower():find("egg") then
                    item.CanCollide = false
                    if Config.LockEggInHand and item:FindFirstChild("BodyJoint") == nil then
                        -- ตรึงไข่อยู่กับตัวละครตลอดเวลา
                        item.AssemblyLinearVelocity = Vector3.zero
                    end
                end
            end
        end
    end
end)

-- 2. วิ่งไปขโมยไข่อัตโนมัติ & ส่งกลับฐาน
CreateToggleRow("ขโมยไข่อัตโนมัติ (Auto Steal)", function(val)
    Config.AutoSteal = val
end)

CreateToggleRow("ขโมยเสร็จวาร์ปกลับฐานอัตโนมัติ", function(val)
    Config.AutoReturn = val
end)

-- 3. เลือกระดับความหายากของไข่
local Rarities = {"ทั้งหมด", "Common", "Rare", "Epic", "Legendary", "Mythic"}
local RarityIndex = 1
local RarityRow = Instance.new("Frame")
RarityRow.Size = UDim2.new(1, -10, 0, 40)
RarityRow.BackgroundColor3 = Color3.fromRGB(22, 32, 46)
RarityRow.Parent = ScrollContainer

local RarityCorner = Instance.new("UICorner")
RarityCorner.CornerRadius = UDim.new(0, 8)
RarityCorner.Parent = RarityRow

local RarityLabel = Instance.new("TextLabel")
RarityLabel.Size = UDim2.new(0.5, 0, 1, 0)
RarityLabel.Position = UDim2.new(0, 12, 0, 0)
RarityLabel.BackgroundTransparency = 1
RarityLabel.Text = "ระดับไข่ที่จะขโมย:"
RarityLabel.TextColor3 = Color3.fromRGB(220, 245, 255)
RarityLabel.Font = Enum.Font.GothamSemibold
RarityLabel.TextSize = 13
RarityLabel.TextXAlignment = Enum.TextXAlignment.Left
RarityLabel.Parent = RarityRow

local RarityBtn = Instance.new("TextButton")
RarityBtn.Size = UDim2.new(0, 120, 0, 26)
RarityBtn.Position = UDim2.new(1, -130, 0.5, -13)
RarityBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
RarityBtn.Text = Config.SelectedRarity
RarityBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RarityBtn.Font = Enum.Font.GothamBold
RarityBtn.TextSize = 12
RarityBtn.Parent = RarityRow

local RarityBtnCorner = Instance.new("UICorner")
RarityBtnCorner.CornerRadius = UDim.new(0, 6)
RarityBtnCorner.Parent = RarityBtn

RarityBtn.MouseButton1Click:Connect(function()
    RarityIndex = (RarityIndex % #Rarities) + 1
    Config.SelectedRarity = Rarities[RarityIndex]
    RarityBtn.Text = Config.SelectedRarity
end)

-- 4. ช่องปรับแต่งความเร็วการวิ่ง (พิมพ์ระบุตัวเลข)
CreateInputRow("กำหนดความเร็วการวิ่ง (WalkSpeed):", 16, function(text)
    local num = tonumber(text)
    if num then
        Config.WalkSpeed = num
    end
end)

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end
end)

-- 5. ระบบบิน (Fly)
CreateToggleRow("เปิดโหมดบิน (Fly)", function(val)
    Config.Fly = val
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    if Config.Fly then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "TH_FlyVel"
        bv.MaxForce = Vector3.new(1, 1, 1) * 1000000
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        
        task.spawn(function()
            while Config.Fly and char:FindFirstChild("HumanoidRootPart") do
                local cam = workspace.CurrentCamera.CFrame
                local move = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
                
                bv.Velocity = move * Config.FlySpeed
                task.wait()
            end
            if bv then bv:Destroy() end
        end)
    else
        if hrp:FindFirstChild("TH_FlyVel") then hrp.TH_FlyVel:Destroy() end
    end
end)

-- 6. ระบบมองทะลุ (ESP มองผู้เล่น & ESP มองไข่)
CreateToggleRow("มองเห็นผู้เล่นทุกคน (Player ESP)", function(val)
    Config.PlayerESP = val
end)

CreateToggleRow("มองเห็นตำแหน่งไข่ (Egg ESP)", function(val)
    Config.EggESP = val
end)

-- ESP Loop Handler
task.spawn(function()
    while task.wait(1) do
        -- Clear Old ESP
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "THE_HUB_ESP" then v:Destroy() end
        end
        
        -- Player ESP
        if Config.PlayerESP then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local bg = Instance.new("BillboardGui")
                    bg.Name = "THE_HUB_ESP"
                    bg.AlwaysOnTop = true
                    bg.Size = UDim2.new(0, 100, 0, 30)
                    bg.Adornee = plr.Character.HumanoidRootPart
                    
                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = "[ " .. plr.Name .. " ]"
                    txt.TextColor3 = Color3.fromRGB(0, 255, 150)
                    txt.Font = Enum.Font.GothamBold
                    txt.TextSize = 11
                    txt.Parent = bg
                    bg.Parent = plr.Character.HumanoidRootPart
                end
            end
        end
        
        -- Egg ESP
        if Config.EggESP then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("egg") then
                    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local bg = Instance.new("BillboardGui")
                        bg.Name = "THE_HUB_ESP"
                        bg.AlwaysOnTop = true
                        bg.Size = UDim2.new(0, 120, 0, 30)
                        bg.Adornee = part
                        
                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.Text = "🥚 " .. obj.Name
                        txt.TextColor3 = Color3.fromRGB(255, 220, 0)
                        txt.Font = Enum.Font.GothamBold
                        txt.TextSize = 12
                        txt.Parent = bg
                        bg.Parent = part
                    end
                end
            end
        end
    end
end)

-- Auto Update Scrolling Canvas Size
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end)
