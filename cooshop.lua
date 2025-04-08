local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Coo hub",
   LoadingTitle = "Coo OT",
   LoadingSubtitle = "สร้างโดย Lxwnu",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "W"
   },
   KeySystem = true,
   KeySettings = {
      Title = "Coo Hub | Key System",
      Subtitle = "กรุณาใส่คีย์",
      Note = "คีย์: 110",
      FileName = "CooHubKey",
      SaveKey = false,
      GrabKeyFromSite = false,
      Key = {"110"}
   }
})

local MainTab = Window:CreateTab("หน้าหลัก", nil)
local MainSection = MainTab:CreateSection("เมนูหลัก")

local SpeedEnabled = false
local SpeedValue = 16
local VerticalSpeed = 0
local IsFlying = false
local IsFrozen = false
local FrozenPosition = nil

local function updateSpeed()
    if SpeedEnabled and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        local rootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            if IsFrozen and FrozenPosition then
                rootPart.CFrame = FrozenPosition
                return
            end

            if not IsFrozen then
                if humanoid.MoveDirection.Magnitude > 0 then
                    local moveDirection = humanoid.MoveDirection * SpeedValue
                    rootPart.CFrame = rootPart.CFrame + moveDirection * game:GetService("RunService").Heartbeat:Wait()
                end
                
                if IsFlying then
                    rootPart.CFrame = rootPart.CFrame + Vector3.new(0, VerticalSpeed, 0) * game:GetService("RunService").Heartbeat:Wait()
                end
            end
        end
    end
end

local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if SpeedEnabled and not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Space then
            if not IsFrozen then
                VerticalSpeed = SpeedValue
                IsFlying = true
            end
        elseif input.KeyCode == Enum.KeyCode.LeftControl then
            if not IsFrozen then
                VerticalSpeed = -SpeedValue
                IsFlying = true
            end
        elseif input.KeyCode == Enum.KeyCode.T then
            IsFrozen = not IsFrozen
            
            if game.Players.LocalPlayer.Character then
                local rootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                
                if rootPart and humanoid then
                    if IsFrozen then
                        FrozenPosition = rootPart.CFrame
                        humanoid.WalkSpeed = 0
                        VerticalSpeed = 0
                        IsFlying = false
                    else
                        FrozenPosition = nil
                        humanoid.WalkSpeed = SpeedValue
                    end
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl then
        VerticalSpeed = 0
        IsFlying = false
    end
end)

local SpeedToggle = MainTab:CreateToggle({
   Name = "เปิดระบบวิ่ง/บิน",
   CurrentValue = false,
   Flag = "SpeedToggle",
   Callback = function(Value)
      SpeedEnabled = Value
      VerticalSpeed = 0
      IsFlying = false
      if not SpeedEnabled then
         if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
         end
      end
   end,
})

local SpeedSlider = MainTab:CreateSlider({
   Name = "ความเร็วในการวิ่ง",
   Range = {16, 500},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
      SpeedValue = Value
   end,
})

game:GetService("RunService").Heartbeat:Connect(function()
    if SpeedEnabled then
        updateSpeed()
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    wait(0.5)
    if SpeedEnabled then
        updateSpeed()
    end
end)

local AimbotEnabled = false
local AimbotActive = false
local FOVRadius = 100
local FOVCircle = Drawing.new("Circle")

FOVCircle.Thickness = 2
FOVCircle.NumSides = 60
FOVCircle.Radius = FOVRadius
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

local CenterDot = Drawing.new("Circle")
CenterDot.Thickness = 1
CenterDot.NumSides = 30
CenterDot.Radius = 2
CenterDot.Filled = true
CenterDot.Visible = false
CenterDot.ZIndex = 1000
CenterDot.Transparency = 1
CenterDot.Color = Color3.fromRGB(255, 0, 0)

local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = FOVRadius
    
    local localPlayer = game.Players.LocalPlayer
    local camera = game.Workspace.CurrentCamera
    local centerScreen = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    FOVCircle.Position = centerScreen
    CenterDot.Position = centerScreen
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and 
           player.Character and 
           player.Character:FindFirstChild("Head") and 
           player.Character:FindFirstChild("Humanoid") and 
           player.Character.Humanoid.Health > 0 then
            
            local head = player.Character.Head
            local screenPoint = camera:WorldToScreenPoint(head.Position)
            
            if screenPoint.Z > 0 then
                local vectorDistance = (centerScreen - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                
                if vectorDistance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = vectorDistance
                end
            end
        end
    end
    
    return closestPlayer
end

local UserInputService = game:GetService("UserInputService")
local shiftKeyDown = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        shiftKeyDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        shiftKeyDown = false
    end
end)

local AimbotToggle = MainTab:CreateToggle({
   Name = "เปิดระบบเล็ง",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
      AimbotEnabled = Value
      FOVCircle.Visible = Value
      CenterDot.Visible = Value
   end,
})

local FOVSlider = MainTab:CreateSlider({
   Name = "ขนาดวงกลม FOV",
   Range = {50, 400},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 100,
   Flag = "FOVSlider",
   Callback = function(Value)
      FOVRadius = Value
      FOVCircle.Radius = Value
   end,
})

local ESPEnabled = false
local ESPStorage = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local function createESP(player)
    if player == Players.LocalPlayer then return end
    
    if ESPStorage[player] then
        for _, drawing in pairs(ESPStorage[player].drawings) do
            drawing:Remove()
        end
    end
    
    local drawings = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        distance = Drawing.new("Text"),
        tracers = Drawing.new("Line")
    }
    
    drawings.box.Thickness = 1
    drawings.box.Filled = false
    drawings.box.Color = Color3.fromRGB(255, 255, 255)
    drawings.box.Transparency = 1
    drawings.box.Visible = false
    
    drawings.name.Size = 16
    drawings.name.Center = true
    drawings.name.Outline = true
    drawings.name.Color = Color3.fromRGB(255, 255, 255)
    drawings.name.Visible = false
    
    drawings.distance.Size = 14
    drawings.distance.Center = true
    drawings.distance.Outline = true
    drawings.distance.Color = Color3.fromRGB(255, 255, 255)
    drawings.distance.Visible = false
    
    drawings.tracers.Thickness = 1
    drawings.tracers.Color = Color3.fromRGB(255, 255, 255)
    drawings.tracers.Transparency = 1
    drawings.tracers.Visible = false
    
    ESPStorage[player] = {
        drawings = drawings,
        connection = RunService.RenderStepped:Connect(function()
            local character = player.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChild("Humanoid")
            
            if ESPEnabled and character and humanoidRootPart and humanoid and humanoid.Health > 0 then
                local rootPosition = humanoidRootPart.Position
                local screenPosition, onScreen = Camera:WorldToViewportPoint(rootPosition)
                
                if onScreen then
                    local distance = (Camera.CFrame.Position - rootPosition).Magnitude
                    local size = 1 / (distance * 0.2) * 1000
                    
                    local boxSize = Vector2.new(size, size * 1.5)
                    drawings.box.Size = boxSize
                    drawings.box.Position = Vector2.new(screenPosition.X - boxSize.X/2, screenPosition.Y - boxSize.Y/2)
                    drawings.box.Visible = true
                    
                    drawings.name.Text = player.Name
                    drawings.name.Position = Vector2.new(screenPosition.X, screenPosition.Y - boxSize.Y/2 - 20)
                    drawings.name.Visible = true
                    
                    drawings.distance.Text = math.floor(distance) .. " studs"
                    drawings.distance.Position = Vector2.new(screenPosition.X, screenPosition.Y + boxSize.Y/2 + 5)
                    drawings.distance.Visible = true
                    
                    drawings.tracers.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    drawings.tracers.To = Vector2.new(screenPosition.X, screenPosition.Y)
                    drawings.tracers.Visible = true
                else
                    for _, drawing in pairs(drawings) do
                        drawing.Visible = false
                    end
                end
            else
                for _, drawing in pairs(drawings) do
                    drawing.Visible = false
                end
            end
        end)
    }
end

local ESPToggle = MainTab:CreateToggle({
   Name = "แสดงตำแหน่งผู้เล่น (ESP)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
      ESPEnabled = Value
      if not Value then
          for player, esp in pairs(ESPStorage) do
              for _, drawing in pairs(esp.drawings) do
                  drawing.Visible = false
              end
          end
      end
   end,
})

local SimpleESPEnabled = false
local SimpleESPStorage = {}

local function createSimpleESP(player)
    if player == Players.LocalPlayer then return end
    
    if SimpleESPStorage[player] then
        for _, drawing in pairs(SimpleESPStorage[player].drawings) do
            drawing:Remove()
        end
    end
    
    local drawings = {
        name = Drawing.new("Text"),
        distance = Drawing.new("Text")
    }
    
    drawings.name.Size = 16
    drawings.name.Center = true
    drawings.name.Outline = true
    drawings.name.Color = Color3.fromRGB(255, 255, 255)
    drawings.name.Visible = false
    
    drawings.distance.Size = 14
    drawings.distance.Center = true
    drawings.distance.Outline = true
    drawings.distance.Color = Color3.fromRGB(255, 255, 255)
    drawings.distance.Visible = false
    
    SimpleESPStorage[player] = {
        drawings = drawings,
        connection = RunService.RenderStepped:Connect(function()
            local character = player.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChild("Humanoid")
            
            if SimpleESPEnabled and character and humanoidRootPart and humanoid and humanoid.Health > 0 then
                local rootPosition = humanoidRootPart.Position
                local screenPosition, onScreen = Camera:WorldToViewportPoint(rootPosition)
                
                if onScreen then
                    local distance = (Camera.CFrame.Position - rootPosition).Magnitude
                    
                    drawings.name.Text = player.Name
                    drawings.name.Position = Vector2.new(screenPosition.X, screenPosition.Y - 20)
                    drawings.name.Visible = true
                    
                    drawings.distance.Text = math.floor(distance) .. " studs"
                    drawings.distance.Position = Vector2.new(screenPosition.X, screenPosition.Y + 5)
                    drawings.distance.Visible = true
                else
                    drawings.name.Visible = false
                    drawings.distance.Visible = false
                end
            else
                drawings.name.Visible = false
                drawings.distance.Visible = false
            end
        end)
    }
end

local SimpleESPToggle = MainTab:CreateToggle({
   Name = "แสดงชื่อและระยะ",
   CurrentValue = false,
   Flag = "SimpleESPToggle",
   Callback = function(Value)
      SimpleESPEnabled = Value
      if not Value then
          for player, esp in pairs(SimpleESPStorage) do
              for _, drawing in pairs(esp.drawings) do
                  drawing.Visible = false
              end
          end
      end
   end,
})

for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        createSimpleESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    createSimpleESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if SimpleESPStorage[player] then
        SimpleESPStorage[player].connection:Disconnect()
        for _, drawing in pairs(SimpleESPStorage[player].drawings) do
            drawing:Remove()
        end
        SimpleESPStorage[player] = nil
    end
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPStorage[player] then
        ESPStorage[player].connection:Disconnect()
        for _, drawing in pairs(ESPStorage[player].drawings) do
            drawing:Remove()
        end
        ESPStorage[player] = nil
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if AimbotEnabled then
        local camera = game.Workspace.CurrentCamera
        local viewportSize = camera.ViewportSize
        
        FOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
        CenterDot.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
        
        if shiftKeyDown then
            local target = getClosestPlayerInFOV()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.Head.Position)
            end
        end
    end
end)

local NameHiderTab = Window:CreateTab("ซ่อนชื่อ", nil)
local NameHiderSection = NameHiderTab:CreateSection("ระบบซ่อนชื่อ")

local NameHiderEnabled = false
local FakeName = ""
local SelectedPlayer = nil
local PlayerList = {}

local function hidePlayerName()
    local localPlayer = game.Players.LocalPlayer
    
    PlayerList = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(PlayerList, player.Name)
        end
    end
    
    if NameHiderEnabled then
        if localPlayer.Character then
            for _, obj in pairs(localPlayer.Character:GetDescendants()) do
                if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                    obj.Enabled = false
                end
            end
            
            if localPlayer.Character:FindFirstChild("Head") then
                for _, gui in pairs(localPlayer.Character.Head:GetChildren()) do
                    if gui:IsA("BillboardGui") then
                        gui.Enabled = false
                    end
                end
            end
            
            if localPlayer.Character:FindFirstChild("Humanoid") then
                localPlayer.Character.Humanoid.DisplayName = if FakeName ~= "" and SelectedPlayer then FakeName else "Hidden"
                localPlayer.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            end
        end
    else
        if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
            localPlayer.Character.Humanoid.DisplayName = localPlayer.Name
            localPlayer.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
            
            for _, obj in pairs(localPlayer.Character:GetDescendants()) do
                if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                    obj.Enabled = true
                end
            end
        end
    end
end

local function changeFakeName()
    local localPlayer = game.Players.LocalPlayer
    if SelectedPlayer and NameHiderEnabled then
        local targetPlayer = nil
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Name == SelectedPlayer then
                targetPlayer = player
                break
            end
        end
        
        if targetPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
            if FakeName == "" then
                localPlayer.Character.Humanoid.DisplayName = targetPlayer.Name
            else
                localPlayer.Character.Humanoid.DisplayName = FakeName
            end
            
            if targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                localPlayer.Character.Humanoid.NameDisplayDistance = targetPlayer.Character.Humanoid.NameDisplayDistance
            end
        end
    end
end

local NameHiderToggle = NameHiderTab:CreateToggle({
   Name = "เปิดระบบซ่อนชื่อ",
   CurrentValue = false,
   Flag = "NameHiderToggle",
   Callback = function(Value)
      NameHiderEnabled = Value
      hidePlayerName()
   end,
})

local FakeNameInput = NameHiderTab:CreateInput({
   Name = "ชื่อปลอม (ถ้าไม่กรอกจะใช้ชื่อผู้เล่นที่เลือก)",
   PlaceholderText = "ใส่ชื่อที่ต้องการแสดง...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      FakeName = Text
      if NameHiderEnabled then
          hidePlayerName()
          changeFakeName()
      end
   end,
})

local PlayerDropdown = NameHiderTab:CreateDropdown({
   Name = "เลือกผู้เล่นที่ต้องการใช้ชื่อ",
   Options = PlayerList,
   CurrentOption = "",
   Flag = "PlayerDropdown",
   Callback = function(Option)
      SelectedPlayer = Option
      if NameHiderEnabled then
          changeFakeName()
      end
   end,
})

local RefreshButton = NameHiderTab:CreateButton({
   Name = "รีเฟรชรายชื่อผู้เล่น",
   Callback = function()
      local newPlayerList = {}
      for _, player in pairs(game.Players:GetPlayers()) do
          if player ~= game.Players.LocalPlayer then
              table.insert(newPlayerList, player.Name)
          end
      end
      
      PlayerDropdown:Refresh(newPlayerList, (SelectedPlayer and table.find(newPlayerList, SelectedPlayer)) and SelectedPlayer or "")
   end,
})

game.Players.PlayerAdded:Connect(function(player)
    RefreshButton.Callback()
end)

game.Players.PlayerRemoving:Connect(function(player)
    RefreshButton.Callback()
    
    if SelectedPlayer == player.Name then
        SelectedPlayer = nil
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1)
    
    if NameHiderEnabled then
        hidePlayerName()
        changeFakeName()
    end
end)

RefreshButton.Callback()