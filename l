-- RMAX HUB - VERSI MINIMALIS (TEST UI)
-- Hanya fitur dasar: Fly, Speed, Jump, God Mode, Kill Aura, Aimbot, Infinite Jump
-- Tanpa ESP/Tracer/Auto Farm (untuk menghindari Drawing & performa)

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- Settings
local settings = {
    walkspeed = 100,
    jumppower = 50,
    infinitejump = false,
    fly = false,
    godmode = false,
    killaura = false,
    killaurarange = 30,
    aimbot = false,
}

-- FLY
local bodyVel, bodyGyro, flyConn
local function stopFly()
    if flyConn then flyConn:Disconnect() end
    if bodyVel then bodyVel:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    flyConn = nil; bodyVel = nil; bodyGyro = nil
end
local function startFly()
    stopFly()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    bodyVel = Instance.new("BodyVelocity")
    bodyGyro = Instance.new("BodyGyro")
    bodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
    bodyVel.P = 1e4
    bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
    bodyGyro.P = 1e4
    bodyVel.Parent = char.HumanoidRootPart
    bodyGyro.Parent = char.HumanoidRootPart
    flyConn = runService.RenderStepped:Connect(function()
        if not settings.fly or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopFly()
            return
        end
        local move = Vector3.new()
        if uis:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0,0,-1) end
        if uis:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0,0,1) end
        if uis:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-1,0,0) end
        if uis:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(1,0,0) end
        if uis:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftControl) then move = move + Vector3.new(0,-1,0) end
        if move.Magnitude > 0 then move = move.Unit end
        local cam = workspace.CurrentCamera
        local vel = (cam.CFrame.LookVector * move.Z + cam.CFrame.RightVector * move.X + Vector3.new(0,move.Y,0)) * 100
        bodyVel.Velocity = vel
        bodyGyro.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position, player.Character.HumanoidRootPart.Position + cam.CFrame.LookVector)
    end)
end

-- Infinite Jump
uis.JumpRequest:Connect(function()
    if settings.infinitejump then
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Freefall then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Update Speed/Jump
local function updateChar()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = settings.walkspeed
        char.Humanoid.JumpPower = settings.jumppower
    end
end
player.CharacterAdded:Connect(updateChar)
runService.Heartbeat:Connect(updateChar)

-- God Mode
local function applyGodMode()
    if not settings.godmode then return end
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health = math.huge
        char.Humanoid.MaxHealth = math.huge
        char.Humanoid.BreakJointsOnDeath = false
    end
end
player.CharacterAdded:Connect(applyGodMode)
spawn(function() while true do wait(0.2); if settings.godmode then applyGodMode() end end end)

-- Kill Aura
spawn(function()
    while true do
        if settings.killaura and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            for _, plr in ipairs(game.Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
                    if (plr.Character.HumanoidRootPart.Position - root.Position).Magnitude <= settings.killaurarange then
                        plr.Character.Humanoid.Health = 0
                    end
                end
            end
        end
        wait(0.1)
    end
end)

-- Aimbot
runService.RenderStepped:Connect(function()
    if settings.aimbot and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local closest, closestDist = nil, 200
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = plr
                    end
                end
            end
        end
        if closest then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, closest.Character.HumanoidRootPart.Position)
        end
    end
end)

-- ========== UI SEDERHANA (PASTI MUNCUL) ==========
pcall(function() game.CoreGui:FindFirstChild("RmaxHubMini"):Destroy() end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RmaxHubMini"
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,40)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,35)
titleBar.BackgroundColor3 = Color3.fromRGB(50,50,70)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1,-50,1,0)
titleText.Position = UDim2.new(0,10,0,0)
titleText.BackgroundTransparency = 1
titleText.Text = "RMAX HUB (MINI)"
titleText.TextColor3 = Color3.fromRGB(0,255,255)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16
titleText.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0,28,0,28)
minimizeBtn.Position = UDim2.new(1,-35,0,3)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.TextSize = 22
minimizeBtn.Parent = titleBar

-- Konten container (tanpa scrolling dulu)
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -10, 1, -45)
container.Position = UDim2.new(0, 5, 0, 40)
container.BackgroundTransparency = 1
container.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = container

-- Helper toggle
local function addToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 28)
    btn.Position = UDim2.new(1, -70, 0, 6)
    btn.BackgroundColor3 = default and Color3.fromRGB(0,200,255) or Color3.fromRGB(80,80,100)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(0,0,0)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1,0)
    btnCorner.Parent = btn
    btn.Parent = frame
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0,200,255) or Color3.fromRGB(80,80,100)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    return frame
end

local function addSlider(text, minv, maxv, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -20, 0, 6)
    bg.Position = UDim2.new(0, 0, 0, 28)
    bg.BackgroundColor3 = Color3.fromRGB(60,60,80)
    bg.BorderSizePixel = 0
    bg.Parent = frame
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1,0)
    bgCorner.Parent = bg
    
    local fill = Instance.new("Frame")
    local percent = (default - minv) / (maxv - minv)
    fill.Size = UDim2.new(percent, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0,200,255)
    fill.BorderSizePixel = 0
    fill.Parent = bg
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1,0)
    fillCorner.Parent = fill
    
    local val = default
    local dragging = false
    local con1, con2
    local function update(input)
        if not dragging then return end
        local rel = (input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X
        rel = math.clamp(rel, 0, 1)
        val = minv + rel * (maxv - minv)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        label.Text = text .. ": " .. math.floor(val)
        callback(val)
    end
    bg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(inp)
            con1 = uis.InputChanged:Connect(update)
            con2 = uis.InputEnded:Connect(function(inp2)
                if inp2.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    if con1 then con1:Disconnect() end
                    if con2 then con2:Disconnect() end
                end
            end)
        end
    end)
    return frame
end

-- Buat UI
addToggle("Fly (WASD + Space/CTRL)", settings.fly, function(v) settings.fly = v; if v then startFly() else stopFly() end end)
addSlider("Walk Speed", 16, 500, settings.walkspeed, function(v) settings.walkspeed = v; updateChar() end)
addSlider("Jump Power", 30, 200, settings.jumppower, function(v) settings.jumppower = v; updateChar() end)
addToggle("Infinite Jump", settings.infinitejump, function(v) settings.infinitejump = v end)
addToggle("God Mode", settings.godmode, function(v) settings.godmode = v; if v then applyGodMode() end end)
addToggle("Kill Aura", settings.killaura, function(v) settings.killaura = v end)
addSlider("Kill Aura Range", 10, 100, settings.killaurarange, function(v) settings.killaurarange = v end)
addToggle("Aimbot", settings.aimbot, function(v) settings.aimbot = v end)

-- Update container height
local function updateHeight()
    local total = 0
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Frame") then
            total = total + child.Size.Y.Offset + layout.Padding.Offset
        end
    end
    container.Size = UDim2.new(1, -10, 0, total + 10)
    mainFrame.Size = UDim2.new(0, 300, 0, total + 55)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -(total+55)/2)
end
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateHeight)
task.wait(0.1)
updateHeight()

-- Draggable
local dragStart, dragStartPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        dragStartPos = mainFrame.Position
        local connMove, connEnd
        connMove = uis.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = inp.Position - dragStart
                mainFrame.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
            end
        end)
        connEnd = uis.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                connMove:Disconnect()
                connEnd:Disconnect()
            end
        end)
    end
end)

-- Minimize
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        container.Visible = false
        mainFrame:TweenSize(UDim2.new(0, 300, 0, 35), "Out", "Quad", 0.2, true)
    else
        mainFrame:TweenSize(UDim2.new(0, 300, 0, updateHeight and (container.Size.Y.Offset + 55) or 400), "Out", "Quad", 0.2, true)
        task.wait(0.2)
        container.Visible = true
    end
end)

-- Show/hide Insert
uis.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

print("RMAX HUB MINI LOADED - Tekan Insert")
