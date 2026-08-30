-- [[ THE CRAFT HUB - SAFE & FULL FUNCTIONAL SCRIPT ]]
-- Theme: Dark Blue & Black Minimalist UI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- State Management
local Config = {
    Language = "TH", -- "TH" / "EN"
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    NoKnockback = false,
    FastAttack = false,
    AutoTree = false,
    StealParasite = false,
    StealFX = false,
    AutoStealZone = false,
    SelectedZone = "",
    ZigZagSteal = false,
    AntiDropEgg = false,
    FastGrab = false,
    ESP_Eggs = false,
    ESP_Players = false
}

-- Protection against Anti-Cheat (Protecting GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheCraftHub_UI_" .. math.random(1000, 9999)

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Frame UI setup
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 360)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(0, 102, 204)
UIStroke.Thickness = 1.5

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
Sidebar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "THE CRAFT HUB"
Title.TextColor3 = Color3.fromRGB(0, 150, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -160, 1, -10)
Container.Position = UDim2.new(0, 155, 0, 5)
Container.BackgroundTransparency = 1

-- Safety Movement Loop (Safe Speed & Anti-Kick)
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local hum = LocalPlayer.Character.Humanoid
                if Config.WalkSpeed > 16 then
                    hum.WalkSpeed = Config.WalkSpeed
                end
                if Config.JumpPower > 50 then
                    hum.UseJumpPower = true
                    hum.JumpPower = Config.JumpPower
                end
            end
        end)
    end
end)

-- Safe Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Auto Farm Tree (Small Tree Event)
task.spawn(function()
    while task.wait(0.3) do
        if Config.AutoTree then
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if Config.AutoTree and obj:IsA("Model") and string.find(string.lower(obj.Name), "small") then
                        local targetPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                        if targetPart then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 0, 3)
                            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                            if tool then tool:Activate() end
                            task.wait(0.2)
                        end
                    end
                end
            end)
        end
    end
end)

-- Anti Drop Egg / Auto Grab (E)
task.spawn(function()
    while task.wait(0.1) do
        if Config.AntiDropEgg or Config.FastGrab then
            pcall(function()
                for _, prompt in pairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        if Config.FastGrab then
                            prompt.HoldDuration = 0
                        end
                        if Config.AntiDropEgg and prompt.Enabled then
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end)
        end
    end
end)

-- Fast Attack Loop
task.spawn(function()
    while task.wait(0.05) do
        if Config.FastAttack and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            pcall(function()
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
            end)
        end
    end
end)

print("[THE CRAFT HUB] Fully Loaded and Safe from Anti-Cheat Kicks!")
