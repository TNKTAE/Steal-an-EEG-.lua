--[[
    THE CRAFT HUB - Premium Script
    Version: 2.0 (Anti-Fly-Out Fixed)
    Theme: น้ำเงิน-ดำ
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Language System
local Language = {
    Current = "TH",
    TH = {
        Title = "เดอะ คราฟท์ ฮับ",
        MainToggle = "เปิด/ปิดสคริปต์",
        AutoFarm = "ตีต้นไม้อัตโนมัติ",
        EggSteal = "ขโมยไข่",
        SpawnTreadmill = "เสกผู้วิ่ง AdminTreadmill",
        StealFX = "ขโมยไข่ FX",
        EggESP = "มองทะลุไข่",
        PlayerESP = "มองทะลุผู้เล่น",
        AutoSteal = "ขโมยอัตโนมัติ",
        SpeedHack = "ปรับความเร็ว",
        AntiDrop = "กันไข่หลุด",
        FastGrab = "เก็บไข่เร็ว",
        HighJump = "กระโดดสูง",
        InfiniteJump = "กระโดดไม่จำกัด",
        Zigzag = "ซิกแซก",
        FastAttack = "ตีไว",
        AntiKnockback = "ไม่กระเด็น",
        ServerHop = "ย้ายเซิฟเวอร์",
        ZoneSelect = "เลือกโซน",
        Enabled = "เปิด",
        Disabled = "ปิด",
        Speed = "ความเร็ว",
        JumpPower = "พลังกระโดด",
        AntiVoid = "กันตกแมพ",
        RefreshZones = "รีเฟรชโซน",
        TeleportSpeed = "ความเร็วเคลื่อนที่",
        TeleportSpeedDesc = "ความเร็วในการบินไปหาเป้าหมาย (studs/วินาที)",
    },
    EN = {
        Title = "THE CRAFT HUB",
        MainToggle = "Toggle Script",
        AutoFarm = "Auto Farm Trees",
        EggSteal = "Steal Eggs",
        SpawnTreadmill = "Spawn AdminTreadmill",
        StealFX = "Steal FX Eggs",
        EggESP = "Egg ESP",
        PlayerESP = "Player ESP",
        AutoSteal = "Auto Steal",
        SpeedHack = "Speed Hack",
        AntiDrop = "Anti Drop",
        FastGrab = "Fast Grab",
        HighJump = "High Jump",
        InfiniteJump = "Infinite Jump",
        Zigzag = "Zigzag",
        FastAttack = "Fast Attack",
        AntiKnockback = "Anti Knockback",
        ServerHop = "Server Hop",
        ZoneSelect = "Select Zone",
        Enabled = "ON",
        Disabled = "OFF",
        Speed = "Speed",
        JumpPower = "Jump Power",
        AntiVoid = "Anti Void",
        RefreshZones = "Refresh Zones",
        TeleportSpeed = "Move Speed",
        TeleportSpeedDesc = "Speed to fly to targets (studs/sec)",
    }
}

local function T(key)
    return Language[Language.Current][key] or key
end

-- Create Window (ธีมน้ำเงิน-ดำ)
local Window = Fluent:CreateWindow({
    Title = "THE CRAFT HUB",
    SubTitle = "Premium Script v2.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",  -- ใช้ธีม Dark (ดำ)
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- ปรับสีธีมให้เป็นน้ำเงิน-ดำ (ใช้ accent สีน้ำเงิน)
-- หมายเหตุ: Fluent อาจไม่รองรับ custom accent โดยตรง แต่เราสามารถตั้งค่า property หลังได้
-- แต่เพื่อความง่าย ใช้ Dark theme ซึ่งมีโทนมืด และเพิ่มสีน้ำเงินใน UI elements ต่างๆ ด้านล่าง

local Tabs = {
    Main = Window:AddTab({ Title = "หน้าหลัก", Icon = "home" }),
    Farm = Window:AddTab({ Title = "ฟาร์ม", Icon = "tree-pine" }),
    Eggs = Window:AddTab({ Title = "ไข่", Icon = "egg" }),
    Player = Window:AddTab({ Title = "ผู้เล่น", Icon = "user" }),
    Teleport = Window:AddTab({ Title = "เคลื่อนที่", Icon = "map-pin" }),
    Settings = Window:AddTab({ Title = "ตั้งค่า", Icon = "settings" })
}

-- State Variables
local State = {
    MainEnabled = false,
    AutoFarm = false,
    EggSteal = false,
    SpawnTreadmill = false,
    StealFX = false,
    EggESP = false,
    PlayerESP = false,
    AutoSteal = false,
    SpeedHack = false,
    AntiDrop = false,
    FastGrab = false,
    HighJump = false,
    InfiniteJump = false,
    Zigzag = false,
    FastAttack = false,
    AntiKnockback = false,
    ServerHop = false,
    SpeedValue = 100,
    JumpPowerValue = 100,
    SelectedZone = "ทั้งหมด",
    ESPObjects = {},
    AntiVoid = true,
    LastSafePosition = nil,
    TeleportSpeed = 80, -- ความเร็วเคลื่อนที่เริ่มต้น 80 studs/s
    IsMoving = false,
}

-- Utility Functions
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local function GetRootPart()
    local char = GetCharacter()
    if char then
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    end
    return nil
end

-- ฟังก์ชันเคลื่อนที่แบบปลอดภัย ไม่เด้งออกจากแมพ
local function MoveToPosition(targetPos)
    local root = GetRootPart()
    if not root then return false end

    -- ตรวจสอบตำแหน่งเป้าหมาย
    if targetPos.Y < -100 or targetPos.Y > 10000 then
        return false
    end

    -- บันทึกตำแหน่งปลอดภัย
    State.LastSafePosition = root.Position

    -- ใช้ BodyVelocity เพื่อเคลื่อนที่อย่างนุ่มนวล
    local humanoid = GetHumanoid()
    if humanoid then
        -- ปิดการเคลื่อนไหวปกติชั่วคราว
        local oldWalkSpeed = humanoid.WalkSpeed
        humanoid.WalkSpeed = 0

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = root

        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        bodyGyro.CFrame = root.CFrame
        bodyGyro.Parent = root

        -- คำนวณทิศทาง
        local direction = (targetPos - root.Position).Unit
        local distance = (targetPos - root.Position).Magnitude
        local speed = math.min(State.TeleportSpeed, 200) -- จำกัดความเร็วสูงสุด 200 studs/s
        local moveTime = distance / speed

        -- เคลื่อนที่แบบ step
        local startTime = tick()
        while tick() - startTime < moveTime and State.MainEnabled do
            if not root or not root.Parent then break end
            local currentPos = root.Position
            local toTarget = targetPos - currentPos
            local dist = toTarget.Magnitude

            if dist < 2 then break end -- ถึงแล้ว

            local moveDir = toTarget.Unit
            bodyVelocity.Velocity = moveDir * speed

            -- ตรวจสอบการตกแมพ
            if currentPos.Y < -50 then
                -- หลุดแล้ว ให้กลับตำแหน่งปลอดภัย
                root.CFrame = CFrame.new(State.LastSafePosition or Vector3.new(0, 50, 0))
                break
            end

            RunService.Heartbeat:Wait()
        end

        -- ทำความสะอาด
        bodyVelocity:Destroy()
        bodyGyro:Destroy()
        humanoid.WalkSpeed = oldWalkSpeed

        return true
    end
    return false
end

-- ฟังก์ชัน Teleport ทันทีแบบปลอดภัย (ใช้เมื่อระยะใกล้)
local function InstantTeleport(targetPos)
    local root = GetRootPart()
    if not root then return false end
    if targetPos.Y < -100 or targetPos.Y > 10000 then return false end
    root.CFrame = CFrame.new(targetPos)
    return true
end

-- ฟังก์ชันเลือกใช้ตามระยะทาง
local function SafeTeleport(targetPos)
    local root = GetRootPart()
    if not root then return false end
    local dist = (root.Position - targetPos).Magnitude
    if dist > 50 then
        return MoveToPosition(targetPos)
    else
        return InstantTeleport(targetPos)
    end
end

-- หา Remote
local function FindRemote(...)
    local names = {...}
    for _, name in ipairs(names) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote then return remote end
    end
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
            for _, name in ipairs(names) do
                if obj.Name == name then return obj end
            end
        end
    end
    return nil
end

local function FireServer(remoteNames, ...)
    local remote = FindRemote(unpack(remoteNames))
    if remote then
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        else
            remote:InvokeServer(...)
        end
        return true
    end
    return false
end

local function GetAllZones()
    local zones = {"ทั้งหมด"}
    pcall(function()
        local objectsFolder = Workspace:FindFirstChild("__OBJECTS")
        if objectsFolder then
            local areasFolder = objectsFolder:FindFirstChild("Areas")
            if areasFolder then
                for _, zone in ipairs(areasFolder:GetChildren()) do
                    table.insert(zones, zone.Name)
                end
            end
        end
    end)
    return zones
end

local function GetEggsInArea()
    local eggs = {}
    pcall(function()
        local areaEggSlots = Workspace:FindFirstChild("AreaEggSlotsClient")
        if areaEggSlots then
            for _, egg in ipairs(areaEggSlots:GetChildren()) do
                if egg:IsA("Model") or egg:IsA("BasePart") then
                    table.insert(eggs, egg)
                end
            end
        else
            -- ค้นหาไข่ทั่ว workspace (ใช้ MonsterParasiteVisual หรือ FX)
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj:FindFirstChild("MonsterParasiteVisual", true) or obj:FindFirstChild("FX", true)) then
                    table.insert(eggs, obj)
                end
            end
        end
    end)
    return eggs
end

local function FindTrees()
    local trees = {}
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("small") then
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                if not humanoid then
                    local primaryPart = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
                    if primaryPart and primaryPart.Position.Y > -100 and primaryPart.Position.Y < 10000 then
                        table.insert(trees, obj)
                    end
                end
            end
        end
    end)
    return trees
end

-- Anti Void
local function CheckAndTeleportBack()
    pcall(function()
        local root = GetRootPart()
        if root and State.AntiVoid and State.MainEnabled then
            if root.Position.Y < -50 or root.Position.Y > 10000 then
                local safePos = State.LastSafePosition or Vector3.new(0, 50, 0)
                root.CFrame = CFrame.new(safePos)
                -- ยกเลิกการเคลื่อนที่
                for _, v in ipairs(root:GetChildren()) do
                    if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                        v:Destroy()
                    end
                end
            end
        end
    end)
end

-- Main Toggle
local MainToggle = Tabs.Main:AddToggle("MainToggle", {
    Title = T("MainToggle"),
    Description = "เปิด/ปิดสคริปต์ทั้งหมด",
    Default = false,
    Callback = function(value)
        State.MainEnabled = value
        if not value then
            for k, v in pairs(State) do
                if type(v) == "boolean" and k ~= "MainEnabled" and k ~= "AntiVoid" then
                    State[k] = false
                end
            end
            -- ทำลาย body velocity ทั้งหมด
            pcall(function()
                local root = GetRootPart()
                if root then
                    for _, v in ipairs(root:GetChildren()) do
                        if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                            v:Destroy()
                        end
                    end
                end
            end)
        end
    end
})

-- Language Selector
local LangDropdown = Tabs.Settings:AddDropdown("Language", {
    Title = "ภาษา/Language",
    Values = {"TH", "EN"},
    Multi = false,
    Default = "TH",
    Callback = function(value)
        Language.Current = value
    end
})

-- Anti Void Toggle
local AntiVoidToggle = Tabs.Player:AddToggle("AntiVoid", {
    Title = T("AntiVoid"),
    Description = T("AntiVoidDesc"),
    Default = true,
    Callback = function(value)
        State.AntiVoid = value
    end
})

-- Teleport Speed Slider
local TeleportSpeedSlider = Tabs.Teleport:AddSlider("TeleportSpeed", {
    Title = T("TeleportSpeed"),
    Description = T("TeleportSpeedDesc"),
    Default = 80,
    Min = 20,
    Max = 200,
    Rounding = 0,
    Callback = function(value)
        State.TeleportSpeed = value
    end
})

-- Auto Farm Trees
local AutoFarmToggle = Tabs.Farm:AddToggle("AutoFarm", {
    Title = T("AutoFarm"),
    Description = T("AutoFarmDesc"),
    Default = false,
    Callback = function(value)
        State.AutoFarm = value
        if value and State.MainEnabled then
            task.spawn(function()
                while State.AutoFarm and State.MainEnabled do
                    pcall(function()
                        local trees = FindTrees()
                        for _, tree in ipairs(trees) do
                            if not State.AutoFarm or not State.MainEnabled then break end
                            local treePart = tree.PrimaryPart or tree:FindFirstChild("HumanoidRootPart")
                            if treePart then
                                SafeTeleport(treePart.Position + Vector3.new(0, 3, 0))
                                wait(0.2)
                                FireServer({"Attack", "Hit", "Damage", "AttackTree", "ChopTree"}, treePart)
                                wait(0.5)
                            end
                        end
                    end)
                    wait(1)
                end
            end)
        end
    end
})

-- Egg Steal (MonsterParasiteVisual)
local EggStealToggle = Tabs.Eggs:AddToggle("EggSteal", {
    Title = T("EggSteal"),
    Description = T("EggStealDesc"),
    Default = false,
    Callback = function(value)
        State.EggSteal = value
        if value and State.MainEnabled then
            task.spawn(function()
                while State.EggSteal and State.MainEnabled do
                    pcall(function()
                        local eggs = GetEggsInArea()
                        for _, egg in ipairs(eggs) do
                            if not State.EggSteal or not State.MainEnabled then break end
                            local hasParasite = egg:FindFirstChild("MonsterParasiteVisual", true)
                            if hasParasite then
                                local eggPart = egg:FindFirstChildOfClass("BasePart") or egg.PrimaryPart
                                if eggPart then
                                    SafeTeleport(eggPart.Position + Vector3.new(0, 2, 0))
                                    wait(0.2)
                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
                                    wait(0.1)
                                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
                                    wait(0.3)
                                end
                            end
                        end
                    end)
                    wait(1)
                end
            end)
        end
    end
})

-- Spawn Treadmill
local SpawnTreadmillToggle = Tabs.Farm:AddToggle("SpawnTreadmill", {
    Title = T("SpawnTreadmill"),
    Description = T("SpawnTreadmillDesc"),
    Default = false,
    Callback = function(value)
        State.SpawnTreadmill = value
        if value and State.MainEnabled then
            pcall(function()
                FireServer({"Spawn", "SpawnTreadmill", "SpawnItem", "Create"}, "AdminTreadmill")
            end)
        end
    end
})

-- Steal FX Eggs
local StealFXToggle = Tabs.Eggs:AddToggle("StealFX", {
    Title = T("StealFX"),
    Description = T("StealFXDesc"),
    Default = false,
    Callback = function(value)
        State.StealFX = value
        if value and State.MainEnabled then
            task.spawn(function()
                while State.StealFX and State.MainEnabled do
                    pcall(function()
                        local eggs = GetEggsInArea()
                        for _, egg in ipairs(eggs) do
                            if not State.StealFX or not State.MainEnabled then break end
                            local hasFX = egg:FindFirstChild("FX", true)
                            if hasFX then
                                local eggPart = egg:FindFirstChildOfClass("BasePart") or egg.PrimaryPart
                                if eggPart then
                                    SafeTeleport(eggPart.Position + Vector3.new(0, 2, 0))
                                    wait(0.2)
                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
                                    wait(0.1)
                                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
                                    wait(0.3)
                                end
                            end
                        end
                    end)
                    wait(1)
                end
            end)
        end
    end
})

-- Egg ESP
local EggESPToggle = Tabs.Eggs:AddToggle("EggESP", {
    Title = T("EggESP"),
    Description = T("EggESPDesc"),
    Default = false,
    Callback = function(value)
        State.EggESP = value
        if value then
            task.spawn(function()
                while State.EggESP and State.MainEnabled do
                    pcall(function()
                        local eggs = GetEggsInArea()
                        local seenNames = {}
                        for _, esp in ipairs(State.ESPObjects) do
                            if esp and esp.Parent then esp:Destroy() end
                        end
                        State.ESPObjects = {}
                        for _, egg in ipairs(eggs) do
                            if not seenNames[egg.Name] then
                                seenNames[egg.Name] = true
                                local billboard = Instance.new("BillboardGui")
                                billboard.Name = "EggESP"
                                billboard.Size = UDim2.new(0, 100, 0, 30)
                                billboard.AlwaysOnTop = true
                                billboard.Adornee = egg:FindFirstChildOfClass("BasePart") or egg.PrimaryPart
                                billboard.Parent = egg
                                local label = Instance.new("TextLabel")
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.BackgroundTransparency = 1
                                label.Text = egg.Name
                                label.TextColor3 = Color3.fromRGB(0, 150, 255) -- สีน้ำเงิน
                                label.TextStrokeTransparency = 0
                                label.Font = Enum.Font.GothamBold
                                label.TextSize = 14
                                label.Parent = billboard
                                table.insert(State.ESPObjects, billboard)
                            end
                        end
                    end)
                    wait(2)
                end
            end)
        else
            for _, esp in ipairs(State.ESPObjects) do
                if esp and esp.Parent then esp:Destroy() end
            end
            State.ESPObjects = {}
        end
    end
})

-- Player ESP
local PlayerESPToggle = Tabs.Player:AddToggle("PlayerESP", {
    Title = T("PlayerESP"),
    Description = T("PlayerESPDesc"),
    Default = false,
    Callback = function(value)
        State.PlayerESP = value
        if value then
            task.spawn(function()
                while State.PlayerESP and State.MainEnabled do
                    pcall(function()
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local head = player.Character:FindFirstChild("Head")
                                if head and not head:FindFirstChild("PlayerESP") then
                                    local billboard = Instance.new("BillboardGui")
                                    billboard.Name = "PlayerESP"
                                    billboard.Size = UDim2.new(0, 100, 0, 30)
                                    billboard.AlwaysOnTop = true
                                    billboard.Adornee = head
                                    billboard.Parent = head
                                    local label = Instance.new("TextLabel")
                                    label.Size = UDim2.new(1, 0, 1, 0)
                                    label.BackgroundTransparency = 1
                                    label.Text = player.Name
                                    label.TextColor3 = Color3.fromRGB(0, 150, 255) -- สีน้ำเงิน
                                    label.TextStrokeTransparency = 0
                                    label.Font = Enum.Font.GothamBold
                                    label.TextSize = 14
                                    label.Parent = billboard
                                end
                            end
                        end
                    end)
                    wait(1)
                end
            end)
        else
            pcall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character then
                        local head = player.Character:FindFirstChild("Head")
                        if head then
                            local esp = head:FindFirstChild("PlayerESP")
                            if esp then esp:Destroy() end
                        end
                    end
                end
            end)
        end
    end
})

-- Auto Steal (ขโมยอัตโนมัติ - แก้ไม่ให้เด้ง)
local AutoStealToggle = Tabs.Eggs:AddToggle("AutoSteal", {
    Title = T("AutoSteal"),
    Description = T("AutoStealDesc"),
    Default = false,
    Callback = function(value)
        State.AutoSteal = value
        if value and State.MainEnabled then
            task.spawn(function()
                while State.AutoSteal and State.MainEnabled do
                    pcall(function()
                        local eggs = GetEggsInArea()
                        local root = GetRootPart()
                        if root then
                            local basePosition = root.Position
                            for _, egg in ipairs(eggs) do
                                if not State.AutoSteal or not State.MainEnabled then break end
                                local eggPart = egg:FindFirstChildOfClass("BasePart") or egg.PrimaryPart
                                if eggPart then
                                    -- ไปหาไข่
                                    SafeTeleport(eggPart.Position + Vector3.new(0, 2, 0))
                                    wait(0.2)
                                    -- ขโมย
                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
                                    wait(0.1)
                                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
                                    wait(0.3)
                                    -- ซิกแซกกลับ
                                    if State.Zigzag then
                                        local currentPos = root.Position
                                        local midPoint = (basePosition + currentPos) / 2 + Vector3.new(math.random(-5,5),0,math.random(-5,5))
                                        SafeTeleport(midPoint)
                                        wait(0.2)
                                    end
                                    -- กลับฐาน
                                    SafeTeleport(basePosition)
                                    wait(0.2)
                                end
                            end
                        end
                    end)
                    wait(1)
                end
            end)
        end
    end
})

-- Speed Hack
local SpeedToggle = Tabs.Player:AddToggle("SpeedHack", {
    Title = T("SpeedHack"),
    Description = T("SpeedHackDesc"),
    Default = false,
    Callback = function(value)
        State.SpeedHack = value
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.WalkSpeed = value and State.SpeedValue or 16
        end
    end
})

local SpeedSlider = Tabs.Player:AddSlider("SpeedSlider", {
    Title = T("Speed"),
    Description = "ปรับความเร็ว 16-2000",
    Default = 100,
    Min = 16,
    Max = 2000,
    Rounding = 0,
    Callback = function(value)
        State.SpeedValue = value
        if State.SpeedHack then
            local humanoid = GetHumanoid()
            if humanoid then humanoid.WalkSpeed = value end
        end
    end
})

-- Anti Drop
local AntiDropToggle = Tabs.Eggs:AddToggle("AntiDrop", {
    Title = T("AntiDrop"),
    Description = T("AntiDropDesc"),
    Default = false,
    Callback = function(value)
        State.AntiDrop = value
        if value then
            task.spawn(function()
                while State.AntiDrop and State.MainEnabled do
                    pcall(function()
                        local char = GetCharacter()
                        if char and not char:FindFirstChildOfClass("Tool") then
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
                            wait(0.05)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
                        end
                    end)
                    wait(0.3)
                end
            end)
        end
    end
})

-- Fast Grab
local FastGrabToggle = Tabs.Eggs:AddToggle("FastGrab", {
    Title = T("FastGrab"),
    Description = T("FastGrabDesc"),
    Default = false,
    Callback = function(value)
        State.FastGrab = value
    end
})

-- High Jump
local HighJumpToggle = Tabs.Player:AddToggle("HighJump", {
    Title = T("HighJump"),
    Description = T("HighJumpDesc"),
    Default = false,
    Callback = function(value)
        State.HighJump = value
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.JumpPower = value and State.JumpPowerValue or 50
        end
    end
})

local JumpSlider = Tabs.Player:AddSlider("JumpSlider", {
    Title = T("JumpPower"),
    Description = "ปรับพลังกระโดด 50-500",
    Default = 100,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(value)
        State.JumpPowerValue = value
        if State.HighJump then
            local humanoid = GetHumanoid()
            if humanoid then humanoid.JumpPower = value end
        end
    end
})

-- Infinite Jump
local InfiniteJumpToggle = Tabs.Player:AddToggle("InfiniteJump", {
    Title = T("InfiniteJump"),
    Description = T("InfiniteJumpDesc"),
    Default = false,
    Callback = function(value)
        State.InfiniteJump = value
    end
})

-- Zigzag
local ZigzagToggle = Tabs.Eggs:AddToggle("Zigzag", {
    Title = T("Zigzag"),
    Description = T("ZigzagDesc"),
    Default = false,
    Callback = function(value)
        State.Zigzag = value
    end
})

-- Fast Attack
local FastAttackToggle = Tabs.Player:AddToggle("FastAttack", {
    Title = T("FastAttack"),
    Description = T("FastAttackDesc"),
    Default = false,
    Callback = function(value)
        State.FastAttack = value
    end
})

-- Anti Knockback
local AntiKnockbackToggle = Tabs.Player:AddToggle("AntiKnockback", {
    Title = T("AntiKnockback"),
    Description = T("AntiKnockbackDesc"),
    Default = false,
    Callback = function(value)
        State.AntiKnockback = value
        local root = GetRootPart()
        if root then
            if value then
                root.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5, 0, 0)
            else
                root.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 0, 0)
            end
        end
    end
})

-- Server Hop
local ServerHopButton = Tabs.Teleport:AddButton({
    Title = T("ServerHop"),
    Description = T("ServerHopDesc"),
    Callback = function()
        pcall(function()
            local servers = {}
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            local success, response = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)
            if success and response and response.data then
                for _, server in ipairs(response.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        table.insert(servers, server.id)
                    end
                end
                if #servers > 0 then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
                end
            end
        end)
    end
})

-- Zone Select
local ZoneDropdown = Tabs.Teleport:AddDropdown("ZoneSelect", {
    Title = T("ZoneSelect"),
    Description = T("ZoneSelectDesc"),
    Values = GetAllZones(),
    Multi = false,
    Default = "ทั้งหมด",
    Callback = function(value)
        State.SelectedZone = value
    end
})

-- Refresh Zones
local RefreshZonesButton = Tabs.Teleport:AddButton({
    Title = T("RefreshZones"),
    Description = T("RefreshZonesDesc"),
    Callback = function()
        ZoneDropdown:SetValues(GetAllZones())
        Window:Dialog({
            Title = "สำเร็จ",
            Content = "รีเฟรชโซนเรียบร้อยแล้ว",
            Buttons = {
                { Title = "OK", Callback = function() end }
            }
        })
    end
})

-- Fast Grab Function
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if State.FastGrab and State.MainEnabled and not gameProcessed then
        if input.KeyCode == Enum.KeyCode.E then
            task.spawn(function()
                while UserInputService:IsKeyDown(Enum.KeyCode.E) and State.FastGrab do
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
                    wait(0.05)
                end
            end)
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and State.MainEnabled then
        local humanoid = GetHumanoid()
        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Fast Attack
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if State.FastAttack and State.MainEnabled and not gameProcessed then
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            task.spawn(function()
                while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and State.FastAttack do
                    pcall(function()
                        local char = GetCharacter()
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end)
                    wait(0.05)
                end
            end)
        end
    end
end)

-- Anti Void Loop
RunService.Heartbeat:Connect(function()
    if State.AntiVoid and State.MainEnabled then
        CheckAndTeleportBack()
    end
end)

-- Save Safe Position
RunService.Heartbeat:Connect(function()
    pcall(function()
        local root = GetRootPart()
        if root and root.Position.Y > -100 and root.Position.Y < 10000 then
            State.LastSafePosition = root.Position
        end
    end)
end)

-- Initialize
local function Initialize()
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    InterfaceManager:SetFolder("TheCraftHub")
    SaveManager:SetFolder("TheCraftHub/specific-game")
    SaveManager:BuildConfigSection(Tabs.Settings)
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:LoadAutoloadConfig()
end

Initialize()

-- Cleanup on character added
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    if State.SpeedHack then
        local humanoid = GetHumanoid()
        if humanoid then humanoid.WalkSpeed = State.SpeedValue end
    end
    if State.HighJump then
        local humanoid = GetHumanoid()
        if humanoid then humanoid.JumpPower = State.JumpPowerValue end
    end
    if State.AntiKnockback then
        local root = GetRootPart()
        if root then root.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5, 0, 0) end
    end
end)

-- Notification
Window:Dialog({
    Title = "THE CRAFT HUB",
    Content = "โหลดสำเร็จ! v2.0 (Anti-Fly-Out) / Loaded v2.0",
    Buttons = {
        { Title = "เริ่มใช้งาน", Callback = function() end }
    }
})

-- Debug
print("THE CRAFT HUB v2.0 Loaded")
print("Zones:", #GetAllZones() - 1)
print("Eggs:", #GetEggsInArea())
print("Trees:", #Notification
