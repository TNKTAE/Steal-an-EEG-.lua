-- =============================================
-- THE CRAFT HUB - Steal an Egg Script
-- สคริปต์สำหรับแมพ Steal an Egg
-- =============================================

-- สร้าง UI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")
local ContentFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local UIPadding = Instance.new("UIPadding")

-- ตั้งค่า UI หลัก
ScreenGui.Name = "THECRAFTHUB"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
MainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 320, 0, 480)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

-- Title Bar
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
TitleBar.Size = UDim2.new(1, 0, 0, 40)

TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "THE CRAFT HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ปุ่มปิด
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Size = UDim2.new(0, 35, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 5)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16

-- ปุ่มย่อ
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TitleBar
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 150, 220)
MinimizeButton.Size = UDim2.new(0, 35, 0, 30)
MinimizeButton.Position = UDim2.new(1, -80, 0, 5)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 16

-- Content Frame
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 0, 0, 45)
ContentFrame.Size = UDim2.new(1, 0, 1, -50)
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)

UIListLayout.Parent = ContentFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

UIPadding.Parent = ContentFrame
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)
UIPadding.PaddingTop = UDim.new(0, 5)

-- =============================================
-- ฟังก์ชันช่วยสร้าง UI Elements
-- =============================================
local function createSection(name)
    local Section = Instance.new("Frame")
    Section.Name = name.."Section"
    Section.BackgroundColor3 = Color3.fromRGB(35, 50, 80)
    Section.BorderColor3 = Color3.fromRGB(0, 120, 220)
    Section.BorderSizePixel = 1
    Section.Size = UDim2.new(1, 0, 0, 0)
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.LayoutOrder = #ContentFrame:GetChildren()
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Parent = Section
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Size = UDim2.new(1, 0, 0, 25)
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.Text = name
    SectionTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    SectionTitle.TextSize = 14
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local SectionPadding = Instance.new("UIPadding")
    SectionPadding.Parent = Section
    SectionPadding.PaddingLeft = UDim.new(0, 8)
    SectionPadding.PaddingRight = UDim.new(0, 8)
    SectionPadding.PaddingTop = UDim.new(0, 5)
    SectionPadding.PaddingBottom = UDim.new(0, 8)
    
    Section.Parent = ContentFrame
    return Section
end

local function createButton(parent, name, text, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Parent = parent
    Button.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    Button.BorderColor3 = Color3.fromRGB(0, 180, 255)
    Button.Size = UDim2.new(1, 0, 0, 32)
    Button.Font = Enum.Font.Gotham
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 13
    Button.AutoLocalize = false
    
    Button.MouseButton1Click:Connect(callback)
    
    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    end)
    
    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    end)
    
    return Button
end

local function createToggle(parent, name, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name.."Toggle"
    ToggleFrame.Parent = parent
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Size = UDim2.new(1, 0, 0, 28)
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ToggleFrame
    ToggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 100)
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(0, 0, 0.5, -10)
    ToggleButton.Text = ""
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 50, 0, 0)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Color3.fromRGB(220, 230, 255)
    ToggleLabel.TextSize = 13
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local enabled = default
    
    local function updateToggle()
        ToggleButton.BackgroundColor3 = enabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 100)
        callback(enabled)
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateToggle()
    end)
    
    updateToggle()
    return ToggleFrame, function() return enabled end, function(v) enabled = v; updateToggle() end
end

local function createSlider(parent, name, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = name.."Slider"
    SliderFrame.Parent = parent
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Size = UDim2.new(1, 0, 0, 45)
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Parent = SliderFrame
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.Text = text..": "..default
    SliderLabel.TextColor3 = Color3.fromRGB(220, 230, 255)
    SliderLabel.TextSize = 12
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local SliderBg = Instance.new("Frame")
    SliderBg.Parent = SliderFrame
    SliderBg.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
    SliderBg.Size = UDim2.new(1, 0, 0, 8)
    SliderBg.Position = UDim2.new(0, 0, 0, 28)
    SliderBg.BorderSizePixel = 0
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Parent = SliderBg
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BorderSizePixel = 0
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Parent = SliderBg
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderButton.Size = UDim2.new(0, 16, 0, 16)
    SliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    SliderButton.Text = ""
    SliderButton.AutoLocalize = false
    
    local value = default
    local dragging = false
    
    local function updateSlider(input)
        local pos = UDim2.new(math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1), 0, 0.5, -8)
        SliderButton.Position = pos
        SliderFill.Size = UDim2.new(pos.X.Scale, 0, 1, 0)
        value = math.floor(min + (pos.X.Scale * (max - min)))
        SliderLabel.Text = text..": "..value
        callback(value)
    end
    
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    game.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    return SliderFrame, function() return value end
end

local function createDropdown(parent, name, text, options, default, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = name.."Dropdown"
    DropdownFrame.Parent = parent
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
    DropdownFrame.ClipsDescendants = false
    
    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Parent = DropdownFrame
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Size = UDim2.new(0.4, 0, 1, 0)
    DropdownLabel.Font = Enum.Font.Gotham
    DropdownLabel.Text = text
    DropdownLabel.TextColor3 = Color3.fromRGB(220, 230, 255)
    DropdownLabel.TextSize = 12
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Parent = DropdownFrame
    DropdownButton.BackgroundColor3 = Color3.fromRGB(40, 60, 100)
    DropdownButton.BorderColor3 = Color3.fromRGB(0, 150, 255)
    DropdownButton.Size = UDim2.new(0.6, 0, 0, 28)
    DropdownButton.Position = UDim2.new(0.4, 0, 0, 0)
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.Text = default
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.TextSize = 12
    
    local DropdownList = Instance.new("Frame")
    DropdownList.Name = "DropdownList"
    DropdownList.Parent = DropdownButton
    DropdownList.BackgroundColor3 = Color3.fromRGB(30, 45, 75)
    DropdownList.BorderColor3 = Color3.fromRGB(0, 150, 255)
    DropdownList.Size = UDim2.new(1, 0, 0, #options * 25)
    DropdownList.Position = UDim2.new(0, 0, 1, 2)
    DropdownList.Visible = false
    DropdownList.ZIndex = 10
    
    local selected = default
    
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Parent = DropdownList
        OptionButton.BackgroundTransparency = 1
        OptionButton.Size = UDim2.new(1, 0, 0, 25)
        OptionButton.Position = UDim2.new(0, 0, 0, (i-1) * 25)
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.Text = option
        OptionButton.TextColor3 = Color3.fromRGB(220, 230, 255)
        OptionButton.TextSize = 12
        OptionButton.ZIndex = 11
        
        OptionButton.MouseButton1Click:Connect(function()
            selected = option
            DropdownButton.Text = selected
            DropdownList.Visible = false
            callback(selected)
        end)
        
        OptionButton.MouseEnter:Connect(function()
            OptionButton.BackgroundTransparency = 0.5
            OptionButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        end)
        
        OptionButton.MouseLeave:Connect(function()
            OptionButton.BackgroundTransparency = 1
        end)
    end
    
    DropdownButton.MouseButton1Click:Connect(function()
        DropdownList.Visible = not DropdownList.Visible
    end)
    
    return DropdownFrame, function() return selected end
end

local function createLabel(parent, name, text)
    local Label = Instance.new("TextLabel")
    Label.Name = name
    Label.Parent = parent
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 0, 22)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(180, 210, 255)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    return Label
end

-- =============================================
-- สร้างส่วนต่างๆ ของ UI
-- =============================================

-- ส่วนข้อมูลผู้เล่น
local playerSection = createSection("ข้อมูลผู้เล่น")
local playerNameLabel = createLabel(playerSection, "PlayerName", "ผู้เล่น: "..game.Players.LocalPlayer.Name)
local currentEggLabel = createLabel(playerSection, "CurrentEgg", "ไข่ปัจจุบัน: -")

-- ส่วน Auto Steal
local autoSection = createSection("อัตโนมัติ")
local autoStealToggle, getAutoSteal, setAutoSteal = createToggle(autoSection, "AutoSteal", "วิ่งขโมยไข่อัตโนมัติ", false, function() end)
local antiDropToggle, getAntiDrop, setAntiDrop = createToggle(autoSection, "AntiDrop", "ป้องกันไข่หลุดเมื่อโดนตี", false, function() end)

-- ส่วนความเร็ว
local speedSection = createSection("ความเร็ว")
local speedSlider, getSpeed = createSlider(speedSection, "Speed", "ความเร็วการวิ่ง", 16, 200, 32, function(value)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
end)

-- ส่วนบิน
local flySection = createSection("การบิน")
local flyToggle, getFly, setFly = createToggle(flySection, "Fly", "เปิดโหมดบิน", false, function() end)

-- ส่วนเลือกความหายาก
local raritySection = createSection("ความหายากไข่")
local rarityOptions = {"ทั้งหมด", "ธรรมดา", "ไม่ธรรมดา", "หายาก", "มากหายาก", "ตำนาน", "เทพนิยาย"}
local rarityDropdown, getRarity = createDropdown(raritySection, "Rarity", "เลือกความหายาก", rarityOptions, "ทั้งหมด", function() end)

-- =============================================
-- ตัวแปรและฟังก์ชันหลัก
-- =============================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local flying = false
local flyConnection = nil
local autoStealConnection = nil
local antiDropConnection = nil
local currentTargetEgg = nil

-- ฟังก์ชันหาตัวละคร
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- ฟังก์ชันหาไข่ตามความหายาก
local rarityColors = {
    ["ธรรมดา"] = Color3.fromRGB(150, 150, 150),
    ["ไม่ธรรมดา"] = Color3.fromRGB(50, 200, 50),
    ["หายาก"] = Color3.fromRGB(50, 100, 255),
    ["มากหายาก"] = Color3.fromRGB(180, 50, 200),
    ["ตำนาน"] = Color3.fromRGB(255, 150, 0),
    ["เทพนิยาย"] = Color3.fromRGB(255, 50, 100)
}

local function getEggRarity(egg)
    -- พยายามหาความหายากจากชื่อหรือ properties
    local name = egg.Name:lower()
    if name:find("legendary") or name:find("ตำนาน") then return "ตำนาน"
    elseif name:find("mythic") or name:find("เทพนิยาย") then return "เทพนิยาย"
    elseif name:find("rare") or name:find("หายาก") then return "หายาก"
    elseif name:find("epic") or name:find("มากหายาก") then return "มากหายาก"
    elseif name:find("uncommon") or name:find("ไม่ธรรมดา") then return "ไม่ธรรมดา"
    else return "ธรรมดา" end
end

local function findEggs()
    local eggs = {}
    local selectedRarity = getRarity()
    
    -- ค้นหาไข่ใน Workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("egg") then
            local rarity = getEggRarity(obj)
            if selectedRarity == "ทั้งหมด" or rarity == selectedRarity then
                table.insert(eggs, {part = obj, rarity = rarity})
            end
        end
    end
    return eggs
end

local function findNearestEgg()
    local char = getCharacter()
    if not char or not char.PrimaryPart then return nil end
    
    local eggs = findEggs()
    local nearest = nil
    local minDist = math.huge
    
    for _, eggData in ipairs(eggs) do
        local dist = (char.PrimaryPart.Position - eggData.part.Position).Magnitude
        if dist < minDist then
            minDist = dist
            nearest = eggData
        end
    end
    return nearest
end

-- ฟังก์ชันขโมยไข่อัตโนมัติ
local function autoStealLoop()
    while autoStealConnection do
        local char = getCharacter()
        if char and char:FindFirstChild("Humanoid") and char.PrimaryPart then
            local nearestEgg = findNearestEgg()
            
            if nearestEgg then
                currentTargetEgg = nearestEgg
                currentEggLabel.Text = "ไข่ปัจจุบัน: "..nearestEgg.part.Name.." ("..nearestEgg.rarity..")"
                
                -- เลื่อนไปหาไข่
                local humanoid = char.Humanoid
                humanoid:MoveTo(nearestEgg.part.Position)
                
                -- ถ้าใกล้มากแล้วให้หยิบ
                if (char.PrimaryPart.Position - nearestEgg.part.Position).Magnitude < 5 then
                    -- พยายามกระตุ้น event หยิบไข่
                    pcall(function()
                        -- ลองใช้ ClickDetector
                        if nearestEgg.part:FindFirstChild("ClickDetector") then
                            fireclickdetector(nearestEgg.part.ClickDetector)
                        end
                        -- ลองส่งสัญญาณ ProximityPrompt
                        if nearestEgg.part:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(nearestEgg.part.ProximityPrompt)
                        end
                        -- ลองแตะสัมผัส
                        char.PrimaryPart.CFrame = nearestEgg.part.CFrame + Vector3.new(0, 2, 0)
                    end)
                    wait(0.5)
                end
            else
                currentEggLabel.Text = "ไข่ปัจจุบัน: ไม่พบไข่"
            end
        end
        wait(0.3)
    end
end

-- ฟังก์ชันบิน
local function startFly()
    if flying then return end
    flying = true
    
    local char = getCharacter()
    local humanoid = char:WaitForChild("Humanoid")
    local rootPart = char.PrimaryPart
    
    humanoid.PlatformStand = true
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.P = 10000
    bodyVelocity.Parent = rootPart
    
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 10000
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    local keys = {}
    
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        keys[input.KeyCode] = true
    end)
    
    UserInputService.InputEnded:Connect(function(input, gp)
        keys[input.KeyCode] = false
    end)
    
    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying or not rootPart or not rootPart.Parent then
            stopFly()
            return
        end
        
        local camera = workspace.CurrentCamera
        local speed = getSpeed() / 2
        
        local moveDir = Vector3.new()
        
        if keys[Enum.KeyCode.W] then moveDir = moveDir + camera.CFrame.LookVector end
        if keys[Enum.KeyCode.S] then moveDir = moveDir - camera.CFrame.LookVector end
        if keys[Enum.KeyCode.A] then moveDir = moveDir - camera.CFrame.RightVector end
        if keys[Enum.KeyCode.D] then moveDir = moveDir + camera.CFrame.RightVector end
        if ke
