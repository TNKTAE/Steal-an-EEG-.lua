-- ==========================================
-- THE CRAFT HUB | Steal an Egg (V2 Working)
-- Theme: Dark Cyber Blue / Neon Cyan
-- ==========================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "THE CRAFT HUB",
    SubTitle = "Steal an Egg Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "DarkBlue",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Custom Colors Overrides for Deep Aggressive Blue Theme
Fluent.Options = Fluent.Options or {}
local Elements = Window

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- State Variables
local State = {
    AutoSteal = false,
    SelectedRarity = "All",
    NoDropEgg = false,
    WalkSpeed = 16,
    FlyEnabled = false,
    FlySpeed = 50,
    PlayerESP = false,
    EggESP = false
}

-- Target Rarity Hierarchy
local RarityList = {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Godly", "Secret"}

-- Tabs Setup
local Tabs = {
    Main = Window:AddTab({ Title = "Main Features", Icon = "egg" }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "zap" }),
    Visuals = Window:AddTab({ Title = "ESP & Visuals", Icon = "eye" })
}

-- ==========================================
-- TAB 1: Main (ระบบขโมยไข่ & ป้องกัน)
-- ==========================================
Tabs.Main:AddSection("Auto Steal Configuration")

local RarityDropdown = Tabs.Main:AddDropdown("RaritySelect", {
    Title = "เลือกระดับความหายาก (Egg Rarity)",
    Values = RarityList,
    Default = "All",
    Callback = function(Value)
        State.SelectedRarity = Value
    end
})

local AutoStealToggle = Tabs.Main:AddToggle("AutoSteal", {
    Title = "วิ่งไปขโมยไข่อัตโนมัติ (Auto Steal)",
    Default = false,
    Callback = function(Value)
        State.AutoSteal = Value
    end
})

-- Core Auto Steal Engine (Scans Map dynamically)
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoSteal then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                -- Scan all possible Egg Models in Workspace
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not State.AutoSteal then break end
                    
                    local isEgg = false
                    local eggRarity = "Common"

                    -- Game specific matching
                    if obj:IsA("Model") or obj:IsA("BasePart") then
                        if obj.Name:lower():find("egg") or obj:FindFirstChild("Egg") or obj:GetAttribute("IsEgg") then
                            isEgg = true
                            if obj:FindFirstChild("Rarity") then
                                eggRarity = tostring(obj.Rarity.Value)
                            elseif obj:GetAttribute("Rarity") then
                                eggRarity = tostring(obj:GetAttribute("Rarity"))
                            end
                        end
                    end

                    -- Filter by Rarity
                    if isEgg then
                        local rarityMatches = (State.SelectedRarity == "All") or (eggRarity:lower() == State.SelectedRarity:lower())
                        
                        if rarityMatches then
                            local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                            if targetPart and (targetPart.Position - hrp.Position).Magnitude > 3 then
                                -- Smooth Move / TP to Egg
                                hrp.CFrame = targetPart.CFrame * CFrame.new(0, 2.5, 0)
                                task.wait(0.4)
                                
                                -- Auto Fire Prompt if any proximity prompt exists
                                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt then
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

Tabs.Main:AddSection("Protection Settings")

Tabs.Main:AddToggle("NoDrop", {
    Title = "โดนสัตว์ตีแล้วไข่ไม่หลุด (Anti Egg Drop)",
    Default = false,
    Callback = function(Value)
        State.NoDropEgg = Value
    end
})

-- Anti Drop Protection Engine
RunService.Stepped:Connect(function()
    if State.NoDropEgg and LocalPlayer.Character then
        pcall(function()
            -- Lock Tool/Egg to Character Hierarchy
            for _, child in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if child:IsA("Tool") and child.Name:lower():find("egg") then
                    child.Parent = LocalPlayer.Character
                end
            end
            
            -- Prevent ragdoll / drop animations
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end
        end)
    end
end)

-- ==========================================
-- TAB 2: Movement (ปรับความเร็ว & ระบบบิน)
-- ==========================================
Tabs.Movement:AddSection("Speed Settings")

Tabs.Movement:AddSlider("SpeedSlider", {
    Title = "ปรับความเร็วการวิ่ง (WalkSpeed)",
    Min = 16,
    Max = 300,
    Default = 16,
    Rounding = 0,
    Callback = function(Value)
        State.WalkSpeed = Value
    end
})

-- Continuous Speed Loop
RunService.RenderStepped:Connect(function()
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if not State.FlyEnabled and hum.WalkSpeed ~= State.WalkSpeed then
                hum.WalkSpeed = State.WalkSpeed
            end
        end
    end)
end)

Tabs.Movement:AddSection("Flight Mechanics")

local FlyToggle = Tabs.Movement:AddToggle("FlyToggle", {
    Title = "เปิดระบบบิน (Fly Mode)",
    Default = false,
    Callback = function(Value)
        State.FlyEnabled = Value
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local hrp = char.HumanoidRootPart

        if State.FlyEnabled then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "CraftHubBV"
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp

            local bg = Instance.new("BodyGyro")
            bg.Name = "CraftHubBG"
            bg.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bg.CFrame = hrp.CFrame
            bg.Parent = hrp

            task.spawn(function()
                while State.FlyEnabled and char and char:FindFirstChild("HumanoidRootPart") do
                    local cam = Workspace.CurrentCamera
                    local dir = Vector3.zero

                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end

                    bv.Velocity = dir * State.FlySpeed
                    bg.CFrame = cam.CFrame
                    task.wait()
                end
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
            end)
        else
            if hrp:FindFirstChild("CraftHubBV") then hrp.CraftHubBV:Destroy() end
            if hrp:FindFirstChild("CraftHubBG") then hrp.CraftHubBG:Destroy() end
        end
    end
})

Tabs.Movement:AddSlider("FlySpeedSlider", {
    Title = "ความเร็วการบิน (Fly Speed)",
    Min = 20,
    Max = 300,
    Default = 50,
    Rounding = 0,
    Callback = function(Value)
        State.FlySpeed = Value
    end
})

-- ==========================================
-- TAB 3: Visuals (ESP แสดงไข่ & แสดงผู้เล่น)
-- ==========================================
Tabs.Visuals:AddSection("Visual Trackers")

Tabs.Visuals:AddToggle("PlayerESP", {
    Title = "แสดงชื่อผู้เล่น (Player ESP)",
    Default = false,
    Callback = function(Value)
        State.PlayerESP = Value
    end
})

Tabs.Visuals:AddToggle("EggESP", {
    Title = "แสดงชื่อไข่บนแมพ (Egg ESP)",
    Default = false,
    Callback = function(Value)
        State.EggESP = Value
    end
})

-- Dynamic ESP Loop
task.spawn(function()
    while task.wait(0.5) do
        -- Player ESP Update
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                local existing = head:FindFirstChild("CraftHubPlayerESP")
                
                if State.PlayerESP then
                    if not existing then
                        local gui = Instance.new("BillboardGui")
                        gui.Name = "CraftHubPlayerESP"
                        gui.Adornee = head
                        gui.Size = UDim2.new(0, 150, 0, 30)
                        gui.StudsOffset = Vector3.new(0, 2.5, 0)
                        gui.AlwaysOnTop = true

                        local label = Instance.new("TextLabel")
                        label.Parent = gui
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Text = "👤 " .. plr.DisplayName .. "\n[@" .. plr.Name .. "]"
                        label.TextColor3 = Color3.fromRGB(0, 195, 255)
                        label.TextStrokeTransparency = 0
                        label.TextStrokeColor3 = Color3.fromRGB(0, 10, 30)
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 11

                        gui.Parent = head
                    end
                else
                    if existing then existing:Destroy() end
                end
            end
        end

        -- Egg ESP Update
        if State.EggESP then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name:lower():find("egg") or obj:FindFirstChild("Egg") then
                    local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                    if part and not part:FindFirstChild("CraftHubEggESP") then
                        local gui = Instance.new("BillboardGui")
                        gui.Name = "CraftHubEggESP"
                        gui.Adornee = part
                        gui.Size = UDim2.new(0, 120, 0, 25)
                        gui.StudsOffset = Vector3.new(0, 2, 0)
                        gui.AlwaysOnTop = true

                        local label = Instance.new("TextLabel")
                        label.Parent = gui
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Text = "🥚 " .. obj.Name
                        label.TextColor3 = Color3.fromRGB(0, 255, 230)
                        label.TextStrokeTransparency = 0
                        label.TextStrokeColor3 = Color3.fromRGB(0, 20, 50)
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 12

                        gui.Parent = part
                    end
                end
            end
        else
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:FindFirstChild("CraftHubEggESP") then
                    obj.CraftHubEggESP:Destroy()
                end
            end
        end
    end
end)

-- Notification Startup
Fluent:Notify({
    Title = "THE CRAFT HUB",
    Content = "โหลดสคริปต์สำเร็จแล้ว! ระบบทุกอย่างพร้อมใช้งาน",
    Duration = 5
})
