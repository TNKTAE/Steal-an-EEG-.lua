-- ==========================================
-- THE CRAFT HUB - Steal an Egg Script
-- Theme: Blue | Developed for Roblox
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "THE CRAFT HUB | Steal an Egg",
   LoadingTitle = "THE CRAFT HUB Loading...",
   LoadingSubtitle = "by The Craft Hub Team",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TheCraftHub",
      FileName = "StealAnEggConfig"
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false
})

-- Change Theme to Blue / Cyan
Rayfield:ChangeTheme("Ocean")

-- Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local AutoSteal = false
local SelectedRarity = "All"
local NoDropEgg = false
local WalkSpeedValue = 16
local FlyEnabled = false
local FlySpeed = 50

-- ==========================================
-- TAB 1: Main Features (ขโมยไข่ & ป้องกัน)
-- ==========================================
local MainTab = Window:CreateTab("Main", 4483362458) -- Title, Image

MainTab:CreateSection("Auto Steal Settings")

MainTab:CreateDropdown({
   Name = "เลือกระดับความหายาก (Egg Rarity)",
   Options = {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"},
   CurrentOption = {"All"},
   MultipleOptions = false,
   Callback = function(Option)
      SelectedRarity = Option[1]
   end,
})

MainTab:CreateToggle({
   Name = "วิ่งไปขโมยไข่อัตโนมัติ (Auto Steal Egg)",
   CurrentValue = false,
   Flag = "AutoStealToggle",
   Callback = function(Value)
      AutoSteal = Value
      if AutoSteal then
         task.spawn(function()
            while AutoSteal do
               pcall(function()
                  local character = LocalPlayer.Character
                  if character and character:FindFirstChild("HumanoidRootPart") then
                     -- ค้นหาไข่ใน workspace
                     for _, obj in pairs(workspace:GetDescendants()) do
                        if not AutoSteal then break end
                        
                        -- ตรวจสอบเงื่อนไข Object ของไข่ในแมพ
                        if obj:IsA("Model") or obj:IsA("BasePart") then
                           local isEgg = obj.Name:lower():find("egg") or obj:FindFirstChild("Egg")
                           local matchesRarity = (SelectedRarity == "All") or (obj:FindFirstChild("Rarity") and obj.Rarity.Value == SelectedRarity)
                           
                           if isEgg and matchesRarity then
                              local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                              if targetPart then
                                 -- วาร์ป/เดินไปที่ไข่
                                 character.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
                                 task.wait(0.5)
                              end
                           end
                        end
                     end
                  end
               end)
               task.wait(1)
            end
         end)
      end
   end,
})

MainTab:CreateSection("Protection Features")

MainTab:CreateToggle({
   Name = "โดนสัตว์ตีแล้วไข่ไม่หลุด (No Egg Drop on Hit)",
   CurrentValue = false,
   Flag = "NoDropToggle",
   Callback = function(Value)
      NoDropEgg = Value
      
      -- ระบบป้องกันการสั่งงานอนิเมชั่น Drop หรือการเปลี่ยน Parent ของไข่เมื่อโดนโจมตี
      if NoDropEgg then
         _G.NoDropConnection = RunService.Stepped:Connect(function()
            if NoDropEgg and LocalPlayer.Character then
               local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
               if tool and tool.Name:lower():find("egg") then
                  tool.Parent = LocalPlayer.Character
               end
            end
         end)
      else
         if _G.NoDropConnection then
            _G.NoDropConnection:Disconnect()
         end
      end
   end,
})

-- ==========================================
-- TAB 2: Player Movement (บิน & Speed)
-- ==========================================
local MovementTab = Window:CreateTab("Movement", 4483362458)

MovementTab:CreateSlider({
   Name = "ปรับความเร็วการวิ่ง (WalkSpeed)",
   Range = {16, 250},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "WalkSpeedSlider",
   Callback = function(Value)
      WalkSpeedValue = Value
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeedValue
      end
   end,
})

-- ลูปให้ความเร็วคงที่เสมอแม้ตัวละครจะเกิดใหม่
RunService.RenderStepped:Connect(function()
   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
      if LocalPlayer.Character.Humanoid.WalkSpeed ~= WalkSpeedValue and not FlyEnabled then
         LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeedValue
      end
   end
end)

MovementTab:CreateToggle({
   Name = "เปิดระบบบิน (Fly Mode)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      FlyEnabled = Value
      local char = LocalPlayer.Character
      if not char or not char:FindFirstChild("HumanoidRootPart") then return end
      
      local hrp = char.HumanoidRootPart
      
      if FlyEnabled then
         local bodyVelocity = Instance.new("BodyVelocity")
         bodyVelocity.Name = "CraftHubFly"
         bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
         bodyVelocity.Velocity = Vector3.zero
         bodyVelocity.Parent = hrp
         
         local bodyGyro = Instance.new("BodyGyro")
         bodyGyro.Name = "CraftHubGyro"
         bodyGyro.MaxForce = Vector3.new(1e6, 1e6, 1e6)
         bodyGyro.CFrame = hrp.CFrame
         bodyGyro.Parent = hrp
         
         task.spawn(function()
            while FlyEnabled and char:FindFirstChild("HumanoidRootPart") do
               local camera = workspace.CurrentCamera
               local moveDir = Vector3.zero
               
               local UIS = game:GetService("UserInputService")
               if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
               if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
               if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
               if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
               if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
               if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
               
               bodyVelocity.Velocity = moveDir * FlySpeed
               bodyGyro.CFrame = camera.CFrame
               task.wait()
            end
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
         end)
      else
         if hrp:FindFirstChild("CraftHubFly") then hrp.CraftHubFly:Destroy() end
         if hrp:FindFirstChild("CraftHubGyro") then hrp.CraftHubGyro:Destroy() end
      end
   end,
})

MovementTab:CreateSlider({
   Name = "ปรับความเร็วการบิน (Fly Speed)",
   Range = {10, 200},
   Increment = 5,
   Suffix = "Speed",
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
      FlySpeed = Value
   end,
})

-- ==========================================
-- TAB 3: Visuals / ESP (แสดงไข่ & ผู้เล่น)
-- ==========================================
local VisualsTab = Window:CreateTab("ESP / Visuals", 4483362458)

local ShowPlayers = false
local ShowEggs = false

VisualsTab:CreateToggle({
   Name = "แสดงชื่อผู้เล่น (Player ESP)",
   CurrentValue = false,
   Flag = "PlayerESPToggle",
   Callback = function(Value)
      ShowPlayers = Value
      for _, player in pairs(Players:GetPlayers()) do
         if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if ShowPlayers then
               if not player.Character.Head:FindFirstChild("PlayerESP") then
                  local bb = Instance.new("BillboardGui")
                  bb.Name = "PlayerESP"
                  bb.Adornee = player.Character.Head
                  bb.Size = UDim2.new(0, 100, 0, 30)
                  bb.StudsOffset = Vector3.new(0, 2, 0)
                  bb.AlwaysOnTop = true
                  
                  local txt = Instance.new("TextLabel")
                  txt.Parent = bb
                  txt.Size = UDim2.new(1, 0, 1, 0)
                  txt.BackgroundTransparency = 1
                  txt.Text = player.DisplayName .. " (@" .. player.Name .. ")"
                  txt.TextColor3 = Color3.fromRGB(0, 170, 255)
                  txt.TextScaled = true
                  
                  bb.Parent = player.Character.Head
               end
            else
               if player.Character.Head:FindFirstChild("PlayerESP") then
                  player.Character.Head.PlayerESP:Destroy()
               end
            end
         end
      end
   end,
})

VisualsTab:CreateToggle({
   Name = "แสดงชื่อและตำแหน่งไข่ (Egg ESP)",
   CurrentValue = false,
   Flag = "EggESPToggle",
   Callback = function(Value)
      ShowEggs = Value
      for _, obj in pairs(workspace:GetDescendants()) do
         local isEgg = obj.Name:lower():find("egg")
         if isEgg then
            local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
            if targetPart then
               if ShowEggs then
                  if not targetPart:FindFirstChild("EggESP") then
                     local bb = Instance.new("BillboardGui")
                     bb.Name = "EggESP"
                     bb.Adornee = targetPart
                     bb.Size = UDim2.new(0, 120, 0, 30)
                     bb.StudsOffset = Vector3.new(0, 2, 0)
                     bb.AlwaysOnTop = true
                     
                     local txt = Instance.new("TextLabel")
                     txt.Parent = bb
                     txt.Size = UDim2.new(1, 0, 1, 0)
                     txt.BackgroundTransparency = 1
                     txt.Text = "[EGG] " .. obj.Name
                     txt.TextColor3 = Color3.fromRGB(85, 255, 255)
                     txt.TextScaled = true
                     
                     bb.Parent = targetPart
                  end
               else
                  if targetPart:FindFirstChild("EggESP") then
                     targetPart.EggESP:Destroy()
                  end
               end
            end
         end
      end
   end,
})

Rayfield:Notify({
   Title = "THE CRAFT HUB Loaded",
   Content = "สคริปต์เปิดใช้งานสำเร็จแล้ว! UI โทนสีฟ้าพร้อมใช้งาน",
   Duration = 5,
   Image = 4483362458,
})
