-- RMAX HUB - Delta Compatible + Air Speed (Fast Infinite Jump)
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- ========== DETEKSI GAMEPAD ==========
local hasGamepad = false
local function checkGamepad()
    local gamepads = uis:GetGamepads()
    hasGamepad = #gamepads > 0
end
pcall(function()
    uis.GamepadConnected:Connect(function() hasGamepad = true end)
    uis.GamepadDisconnected:Connect(function() hasGamepad = false end)
    checkGamepad()
end)

-- ========== SETTINGS ==========
local settings = {
    walkspeed = 100,
    jumppower = 50,
    infinitejump = false,
    airspeed = 200,        -- kecepatan saat infinite jump aktif di udara
    fly = false,
    godmode = false,
    killaura = false,
    killaurarange = 30,
    aimbot = false,
    autofarm = false,
}

-- ========== FLY SYSTEM ==========
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
    bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVel.P = 1e4
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
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
        if hasGamepad then
            local gamepad = uis:GetGamepads()[1]
            if gamepad then
                local state = gamepad:GetUserGamepadState()
                local leftStick = state.LeftStick
                local rightStick = state.RightStick
                move = move + Vector3.new(leftStick.X, rightStick.Y, -leftStick.Y)
            end
        end
        if move.Magnitude > 0 then move = move.Unit else move = Vector3.new() end
        local cam = workspace.CurrentCamera
        local vel = (cam.CFrame.LookVector * move.Z + cam.CFrame.RightVector * move.X + Vector3.new(0,move.Y,0)) * 100
        bodyVel.Velocity = vel
        bodyGyro.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position, player.Character.HumanoidRootPart.Position + cam.CFrame.LookVector)
    end)
end

-- ========== INFINITE JUMP (dengan fast air speed) ==========
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

-- ========== UPDATE SPEED & JUMP + AIR SPEED ==========
local function updateChar()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    
    -- Set jump power (selalu)
    hum.JumpPower = settings.jumppower
    
    -- Logika kecepatan: jika infinite jump aktif dan karakter di udara -> pakai airspeed, else walkspeed
    if settings.infinitejump then
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
            hum.WalkSpeed = settings.airspeed
        else
            hum.WalkSpeed = settings.walkspeed
        end
    else
        hum.WalkSpeed = settings.walkspeed
    end
end

player.CharacterAdded:Connect(updateChar)
runService.Heartbeat:Connect(updateChar)

-- ========== GOD MODE ==========
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
spawn(function()
    while true do
        wait(0.2)
        if settings.godmode then applyGodMode() end
    end
end)

-- ========== KILL AURA ==========
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

-- ========== AIMBOT ==========
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

-- ========== AUTO FARM ==========
local farmConn
local function stopFarm()
    if farmConn then farmConn:Disconnect() farmConn = nil end
end
local function startFarm()
    if farmConn then return end
    farmConn = runService.Heartbeat:Connect(function()
        if not settings.autofarm or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local root = player.Character.HumanoidRootPart
        local nearest, nearestDist = nil, 50
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("gem")) then
                local dist = (obj.Position - root.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = obj
                end
            end
        end
        if nearest then root.CFrame = nearest.CFrame end
    end)
end

-- ========== UI UNTUK DELTA ==========
pcall(function() game:GetService("CoreGui"):FindFirstChild("RmaxHubDelta"):Destroy() end)
pcall(function() player.PlayerGui:FindFirstChild("RmaxHubDelta"):Destroy() end)

local guiParent = game:GetService("CoreGui")
if not guiParent then guiParent = player.PlayerGui end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RmaxHubDelta"
screenGui.Parent = guiParent

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 560)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -280)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -50, 1, 0)
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "🔥 RMAX HUB 🔥"
titleText.TextColor3 = Color3.fromRGB(0, 255, 255)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 18
titleText.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -40, 0, 5)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.TextSize = 24
minimizeBtn.Parent = titleBar

-- ScrollingFrame
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -50)
scroll.Position = UDim2.new(0, 5, 0, 45)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.Parent = mainFrame

local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 0, 0)
container.BackgroundTransparency = 1
container.Parent = scroll

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = container

-- Helper: Toggle
local function addToggle(icon, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.BackgroundTransparency = 1
    frame.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = icon .. " " .. text
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 65, 0, 30)
    btn.Position = UDim2.new(1, -75, 0, 6)
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

-- Helper: Stepper (tombol +/-)
local function addStepper(icon, text, minv, maxv, default, step, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.BackgroundTransparency = 1
    frame.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = icon .. " " .. text
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame
    
    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.2, 0, 1, 0)
    valLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = Color3.fromRGB(0,255,255)
    valLabel.BackgroundTransparency = 1
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 16
    valLabel.Parent = frame
    
    local dec = Instance.new("TextButton")
    dec.Size = UDim2.new(0, 36, 0, 32)
    dec.Position = UDim2.new(0.75, 0, 0, 10)
    dec.Text = "-"
    dec.TextColor3 = Color3.new(1,1,1)
    dec.BackgroundColor3 = Color3.fromRGB(60,60,80)
    dec.Font = Enum.Font.GothamBold
    dec.TextSize = 20
    local decCorner = Instance.new("UICorner")
    decCorner.CornerRadius = UDim.new(0, 6)
    decCorner.Parent = dec
    dec.Parent = frame
    
    local inc = Instance.new("TextButton")
    inc.Size = UDim2.new(0, 36, 0, 32)
    inc.Position = UDim2.new(0.85, 0, 0, 10)
    inc.Text = "+"
    inc.TextColor3 = Color3.new(1,1,1)
    inc.BackgroundColor3 = Color3.fromRGB(60,60,80)
    inc.Font = Enum.Font.GothamBold
    inc.TextSize = 20
    local incCorner = Instance.new("UICorner")
    incCorner.CornerRadius = UDim.new(0, 6)
    incCorner.Parent = inc
    inc.Parent = frame
    
    local val = default
    local function update(newVal)
        val = math.clamp(newVal, minv, maxv)
        valLabel.Text = tostring(math.floor(val))
        callback(val)
    end
    dec.MouseButton1Click:Connect(function() update(val - step) end)
    inc.MouseButton1Click:Connect(function() update(val + step) end)
    return frame
end

-- ========== MEMBUAT UI ==========
addToggle("🪶", "Fly (WASD + Gamepad)", settings.fly, function(v) settings.fly = v; if v then startFly() else stopFly() end end)
addStepper("🏃", "Walk Speed (Ground)", 16, 500, settings.walkspeed, 10, function(v) settings.walkspeed = v; updateChar() end)
addStepper("🦘", "Jump Power", 30, 200, settings.jumppower, 10, function(v) settings.jumppower = v; updateChar() end)
addToggle("♾️", "Infinite Jump", settings.infinitejump, function(v) settings.infinitejump = v; updateChar() end)
addStepper("🚀", "Air Speed (when Infinite Jump)", 16, 500, settings.airspeed, 10, function(v) settings.airspeed = v; updateChar() end)
addToggle("🛡️", "God Mode", settings.godmode, function(v) settings.godmode = v; if v then applyGodMode() end end)
addToggle("⚔️", "Kill Aura", settings.killaura, function(v) settings.killaura = v end)
addStepper("📏", "Kill Aura Range", 10, 100, settings.killaurarange, 10, function(v) settings.killaurarange = v end)
addToggle("🎯", "Aimbot", settings.aimbot, function(v) settings.aimbot = v end)
addToggle("🤖", "Auto Farm (Coin/Gem)", settings.autofarm, function(v) settings.autofarm = v; if v then startFarm() else stopFarm() end end)

-- Update scroll height
local function updateScroll()
    local total = 0
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Frame") then
            total = total + child.Size.Y.Offset + layout.Padding.Offset
        end
    end
    container.Size = UDim2.new(1, 0, 0, total)
    scroll.CanvasSize = UDim2.new(0, 0, 0, total + 20)
end
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScroll)
wait(0.1)
updateScroll()

-- Draggable
local dragStart, dragStartPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        dragStartPos = mainFrame.Position
        local moveConn, endConn
        moveConn = uis.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = inp.Position - dragStart
                mainFrame.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
            end
        end)
        endConn = uis.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                moveConn:Disconnect()
                endConn:Disconnect()
            end
        end)
    end
end)

-- Minimize
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        scroll.Visible = false
        mainFrame:TweenSize(UDim2.new(0, 380, 0, 40), "Out", "Quad", 0.2, true)
    else
        mainFrame:TweenSize(UDim2.new(0, 380, 0, 560), "Out", "Quad", 0.2, true)
        wait(0.2)
        scroll.Visible = true
        updateScroll()
    end
end)

-- Show/hide Insert
uis.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

print("✅ RMAX HUB + AIR SPEED LOADED - Tekan Insert")
