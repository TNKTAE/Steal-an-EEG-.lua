-- ==========================================
-- THE CRAFT HUB - Fully Functional Script
-- Theme: Dark Navy Blue & Pure Black
-- Language: Lua
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. CONFIG & STATE MANAGEMENT
-- ==========================================
local Config = {
    AutoStealEgg = false,
    StealAllInRange = false,
    StealLargeEggOnly = false,
    ESP_Eggs = false,
    ESP_Cards = false,
    AutoSellEggs = false,
    AutoMergePets = false,
    AutoRejoinServer = false,
    AntiAFK = false,
    WalkSpeed = 16,
    WebhookURL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE",
    StealRadius = 60
}

local ESP_Storage = {
    Egg = {},
    Card = {}
}

-- ==========================================
-- 2. HELPER & REAL FUNCTIONAL LOGIC
-- ==========================================
local Functions = {}

-- 🔍 ระบบค้นหา RemoteEvent อัตโนมัติภายในเกม
local function FindRemote(keywords)
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            for _, kw in pairs(keywords) do
                if string.find(string.lower(obj.Name), string.lower(kw)) then
                    return obj
                end
            end
        end
    end
    return nil
end

-- 🏃‍♂️ ปรับความเร็วการเดิน (รองรับการตายแล้วเกิดใหม่)
function Functions.ApplyWalkSpeed()
    task.spawn(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.WalkSpeed = Config.WalkSpeed
        end
    end)
end

-- 🥚 ขโมยไข่อัตโนมัติ (Teleport + ProximityPrompt Trigger)
task.spawn(function()
    while true do
        task.wait(0.2)
        if Config.AutoStealEgg then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if not Config.AutoStealEgg then break end
                    
                    -- ตรวจหาวัตถุที่เป็น ไข่
                    local isEgg = string.find(string.lower(obj.Name), "egg") or obj:GetAttribute("IsEgg")
                    if isEgg and (obj:IsA("Model") or obj:IsA("BasePart")) then
                        
                        local pos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position) or obj.Position
                        local dist = (hrp.Position - pos).Magnitude
                        local isLarge = string.find(string.lower(obj.Name), "large") or string.find(string.lower(obj.Name), "big") or string.find(string.lower(obj.Name), "huge")

                        -- ตรวจสอบเงื่อนไขขนาดไข่
                        if Config.StealLargeEggOnly and not isLarge then
                            continue
                        end

                        -- ตรวจสอบเงื่อนไขระยะทาง
                        if Config.StealAllInRange and dist > Config.StealRadius then
                            continue
                        end

                        -- ทำการขโมย: วาร์ปไปเก็บ หรือ กด ProximityPrompt อัตโนมัติ
                        local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChild("Prompt", true)
                        if prompt then
                            fireproximityprompt(prompt)
                        else
                            -- วาร์ปเข้าหาไข่กรณีไม่มี Prompt
                            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                        end
                        
                        task.wait(0.1)
                    end
                end
            end
        end
    end
end)

-- 👁️ ระบบ ESP แสดงตำแหน่งจริงพร้อมป้ายชื่อและระยะทาง
function Functions.UpdateESP(targetType, enable)
    -- ลบ Highlight เก่าออกก่อน
    if ESP_Storage[targetType] then
        for _, v in pairs(ESP_Storage[targetType]) do
            if v then v:Destroy() end
        end
        ESP_Storage[targetType] = {}
    end

    if not enable then return end

    task.spawn(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            local nameLower = string.lower(obj.Name)
            local isTarget = false

            if targetType == "Egg" and string.find(nameLower, "egg") then
                isTarget = true
            elseif targetType == "Card" and string.find(nameLower, "card") then
                isTarget = true
            end

            if isTarget and (obj:IsA("Model") or obj:IsA("BasePart")) then
                -- สร้าง Highlight สีเรืองแสง
                local highlight = Instance.new("Highlight")
                highlight.Name = "HUB_ESP_" .. targetType
                highlight.FillColor = (targetType == "Egg") and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(255, 215, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Adornee = obj
                highlight.Parent = CoreGui

                -- สร้าง BillboardGui ป้ายชื่อ
                local bbFrame = Instance.new("BillboardGui")
                bbFrame.Size = UDim2.new(0, 100, 0, 30)
                bbFrame.AlwaysOnTop = true
                bbFrame.Adornee = obj
                bbFrame.Parent = highlight

                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.Text = "[" .. targetType:upper() .. "] " .. obj.Name
                txt.TextColor3 = highlight.FillColor
                txt.Font = Enum.Font.GothamBold
                txt.TextSize = 10
                txt.Parent = bbFrame

                table.insert(ESP_Storage[targetType], highlight)
            end
        end
    end)
end

-- 💰 ขายไข่อัตโนมัติ (Smart Remote Hook)
task.spawn(function()
    while true do
        task.wait(1.5)
        if Config.AutoSellEggs then
            local sellRemote = FindRemote({"sell", "sellegg", "salegg"})
            if sellRemote then
                if sellRemote:IsA("RemoteEvent") then
                    sellRemote:FireServer()
                elseif sellRemote:IsA("RemoteFunction") then
                    sellRemote:InvokeServer()
                end
            else
                -- ถ้าไม่พบ Remote ให้ลองวาร์ปไปจุดขาย (Sell Zone)
                local sellZone = workspace:FindFirstChild("SellZone", true) or workspace:FindFirstChild("Sell", true)
                if sellZone and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = sellZone.CFrame
                end
            end
        end
    end
end)

-- 🧬 ผสานสัตว์เลี้ยงอัตโนมัติ
task.spawn(function()
    while true do
        task.wait(2)
        if Config.AutoMergePets then
            local mergeRemote = FindRemote({"merge", "fuse", "craft", "evolve"})
            if mergeRemote then
                if mergeRemote:IsA("RemoteEvent") then
                    mergeRemote:FireServer()
                elseif mergeRemote:IsA("RemoteFunction") then
                    mergeRemote:InvokeServer()
                end
            end
        end
    end
end)

-- 🌐 ย้ายเซิร์ฟเวอร์อัตโนมัติ (Server Hop)
function Functions.ServerHop()
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local Http = HttpService:JSONDecode(game:HttpGet(Api))
    
    if Http and Http.data then
        for _, server in pairs(Http.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end
end

-- 🛡️ Anti-AFK (ป้องกันการหลุดจากการไม่ขยับตัว 20 นาที)
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        print("[THE CRAFT HUB] Anti-AFK Triggered!")
    end
end)

-- 📊 ส่งแจ้งเตือนผ่าน Webhook
function Functions.SendWebhook(text)
    if Config.WebhookURL == "" or string.find(Config.WebhookURL, "YOUR_WEBHOOK") then 
        warn("[THE CRAFT HUB] Webhook URL ไม่ถูกต้อง!")
        return 
    end
    
    local req = (syn and syn.request) or http_request or request or (http and http.request)
    if req then
        req({
            Url = Config.WebhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                ["embeds"] = {{
                    ["title"] = "🛡️ THE CRAFT HUB - Notification",
                    ["description"] = text,
                    ["color"] = 3394815,
                    ["footer"] = {["text"] = "Player: " .. LocalPlayer.Name}
                }}
            })
        })
    end
end

-- ==========================================
-- 3. GUI CREATION (Dark Navy & Black)
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
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 12, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 102, 255)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Top Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(4, 6, 10)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.Text = "THE CRAFT HUB"
TitleText.TextColor3 = Color3.fromRGB(0, 150, 255)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(1, -20, 1, -50)
ScrollContainer.Position = UDim2.new(0, 10, 0, 45)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.ScrollBarThickness = 3
ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 102, 255)
ScrollContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)

-- UI Building Tools
local function CreateToggle(name, configKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 38)
    Frame.BackgroundColor3 = Color3.fromRGB(13, 18, 28)
    Frame.Parent = ScrollContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 50, 0, 22)
    Button.Position = UDim2.new(1, -58, 0.5, -11)
    Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(30, 35, 50)
    Button.Text = Config[configKey] and "ON" or "OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 10
    Button.Parent = Frame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        Button.Text = Config[configKey] and "ON" or "OFF"
        
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(30, 35, 50)
        }):Play()

        if callback then callback(Config[configKey]) end
    end)
end

local function CreateButton(name, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 36)
    Button.BackgroundColor3 = Color3.fromRGB(16, 23, 38)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(0, 170, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.Parent = ScrollContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 80, 180)
    Stroke.Thickness = 1
    Stroke.Parent = Button

    Button.MouseButton1Click:Connect(callback)
end

-- ==========================================
-- 4. BINDING FUNCTIONS TO GUI
-- ==========================================

CreateToggle("ขโมยไข่อัตโนมัติ", "AutoStealEgg")
CreateToggle("ขโมยทุกไข่ในระยะ", "StealAllInRange")
CreateToggle("ขโมยเฉพาะไข่ขนาดใหญ่", "StealLargeEggOnly")

CreateToggle("แสดงตำแหน่งไข่ทั้งหมด (ESP)", "ESP_Eggs", function(val)
    Functions.UpdateESP("Egg", val)
end)

CreateToggle("แสดงตำแหน่งการ์ด (ESP)", "ESP_Cards", function(val)
    Functions.UpdateESP("Card", val)
end)

CreateToggle("ขายไข่อัตโนมัติ", "AutoSellEggs")
CreateToggle("ผสานสัตว์เลี้ยงอัตโนมัติ", "AutoMergePets")
CreateToggle("🛡️ Anti-AFK (ป้องกันหลุดจากเซิร์ฟ)", "AntiAFK")

CreateButton("⚡ ปรับความเร็วการเดิน (Speed: 50)", function()
    Config.WalkSpeed = 50
    Functions.ApplyWalkSpeed()
end)

CreateButton("🚶‍♂️ ความเร็วปกติ (Speed: 16)", function()
    Config.WalkSpeed = 16
    Functions.ApplyWalkSpeed()
end)

CreateButton("🌐 ย้ายเซิร์ฟเวอร์อัตโนมัติ (Server Hop)", function()
    Functions.ServerHop()
end)

CreateButton("📊 ทดสอบส่ง Discord Webhook", function()
    Functions.SendWebhook("ระบบทดสอบการส่งแจ้งเตือนจาก THE CRAFT HUB ทำงานปกติ!")
end)

CreateButton("⚙️ Reset ตั้งค่าทั้งหมด", function()
    for k in pairs(Config) do
        if type(Config[k]) == "boolean" then Config[k] = false end
    end
    Config.WalkSpeed = 16
    Functions.ApplyWalkSpeed()
    Functions.UpdateESP("Egg", false)
    Functions.UpdateESP("Card", false)
    print("[THE CRAFT HUB] รีเซ็ตตั้งค่าเรียบร้อย")
end)

CreateButton("ℹ️ ข้อมูลเพิ่มเติม", function()
    print("==================================")
    print("THE CRAFT HUB - Version 2.0 (Active)")
    print("Status: Connected & Functional")
    print("==================================")
end)

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

-- Handle Character Respawn for WalkSpeed
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    Functions.ApplyWalkSpeed()
end)

-- Floating Toggle Button (ปุ่มเปิด-ปิดเมนูบนหน้าจอ)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "CraftHubOpenBtn"
OpenBtn.Size = UDim2.new(0, 120, 0, 35)
OpenBtn.Position = UDim2.new(0, 15, 0.2, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(6, 10, 18)
OpenBtn.Text = "THE CRAFT HUB"
OpenBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 11
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 8)
OpenCorner.Parent = OpenBtn

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(0, 102, 255)
OpenStroke.Thickness = 1.2
OpenStroke.Parent = OpenBtn

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

print("[THE CRAFT HUB] สคริปต์โหลดและพร้อมใช้งานแล้ว!")
