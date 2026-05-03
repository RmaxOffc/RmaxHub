-- RMAX HUB - LOOPING AUTO CP (tidak berhenti sampai di-stop)
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
    airspeed = 200,
    fly = false,
    godmode = false,
    killaura = false,
    killaurarange = 30,
    aimbot = false,
    autofarm = false,
}

-- ========== SAVED COORDINATES ==========
local savedCoords = {}
local function saveCoord(slot, pos)
    savedCoords[slot] = {X = pos.X, Y = pos.Y, Z = pos.Z}
end
local function getCoord(slot)
    return savedCoords[slot]
end

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

-- ========== INFINITE JUMP + AIR SPEED ==========
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

local function updateChar()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    hum.JumpPower = settings.jumppower
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

-- ========== TELEPORT FUNCTIONS ==========
local function teleportToPosition(pos)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos.X, pos.Y, pos.Z)
    end
end

local function teleportToPlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = targetPlayer.Character.HumanoidRootPart.Position
        teleportToPosition(pos)
    end
end

local function bringPlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.new(0,0,0)
        targetPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(myPos)
    end
end

-- ========== FITUR AUTO CP LOOPING (HUAA OBSTACLE) ==========
local isHuaaMap = (game.PlaceId == 89054581105142) or (pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name:find("HUAA OBSTACLE") end) and true or false)
local cpList = {
    {index=1, pos=Vector3.new(-139.9, 139.3, 153.6)},
    {index=2, pos=Vector3.new(-545.1, 185.2, 451.0)},
    {index=3, pos=Vector3.new(-436.8, 271.5, 963.3)},
    {index=4, pos=Vector3.new(-301.8, 401.7, 1668.5)},
    {index=5, pos=Vector3.new(-173.0, 488.7, 2474.4)},
    {index=6, pos=Vector3.new(5.2, 772.7, 3027.6)},
    {index=7, pos=Vector3.new(152.7, 808.7, 3973.8)},
    {index=8, pos=Vector3.new(-918.7, 864.7, 3905.1)},
    {index=9, pos=Vector3.new(-843.5, 1253.3, 3007.2)},
    {index=10, pos=Vector3.new(-802.5, 1496.7, 2414.7)},
    {index=11, pos=Vector3.new(-128.6, 1736.7, 2134.8)},
    {index=12, pos=Vector3.new(643.8, 1852.7, 2120.4)},
    {index=13, pos=Vector3.new(1110.2, 2036.7, 2295.6)},
    {index=14, pos=Vector3.new(950.3, 2100.7, 2936.0)},
    {index=15, pos=Vector3.new(147.9, 2240.7, 3549.3)},
    {index=16, pos=Vector3.new(30.6, 2173.4, 4458.1)},
    {index=17, pos=Vector3.new(-477.6, 2584.7, 5043.7)},
    {index=18, pos=Vector3.new(-495.9, 2840.7, 5797.7)},
    {index=19, pos=Vector3.new(-1044.9, 3016.7, 6255.0)},
    {index=20, pos=Vector3.new(-1102.8, 3268.7, 5502.8)},
    {index=21, pos=Vector3.new(-1045.3, 3556.7, 4002.9)},
    {index=22, pos=Vector3.new(-1650.2, 4492.7, 2626.6)},
    {index=23, pos=Vector3.new(351.3, 149.3, 109.8)},
}
local lobbyPos = Vector3.new(351.3, 149.3, 109.8)

local currentCpIndex = 1
local autoRunning = false
local autoThread = nil

local function teleportToCp(index)
    local cp = cpList[index]
    if cp then
        teleportToPosition(cp.pos)
        currentCpIndex = index
    end
end

local function goToLobby()
    teleportToPosition(lobbyPos)
end

-- LOOPING AUTO CP (tidak pernah berhenti sampai di-stop)
local function startAutoCp(delaySec)
    if autoRunning then return end
    autoRunning = true
    autoThread = coroutine.create(function()
        while autoRunning do
            for i = 1, #cpList do
                if not autoRunning then break end
                teleportToCp(i)
                if i < #cpList then
                    -- delay antar CP
                    local start = tick()
                    while tick() - start < delaySec and autoRunning do
                        wait(0.1)
                    end
                else
                    -- setelah CP terakhir, delay sebelum balik ke CP1
                    if autoRunning then
                        local start = tick()
                        while tick() - start < delaySec and autoRunning do
                            wait(0.1)
                        end
                    end
                end
            end
        end
    end)
    coroutine.resume(autoThread)
end

local function stopAutoCp()
    autoRunning = false
    if autoThread then
        autoThread = nil
    end
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
mainFrame.Size = UDim2.new(0, 440, 0, 720)
mainFrame.Position = UDim2.new(0.5, -220, 0.5, -360)
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

-- Helper functions for UI
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

local function addButton(icon, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = container
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 32)
    btn.Position = UDim2.new(0.1, 0, 0, 4)
    btn.Text = icon .. " " .. text
    btn.BackgroundColor3 = Color3.fromRGB(60,60,80)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    btn.Parent = frame
    btn.MouseButton1Click:Connect(callback)
    return frame
end

-- ========== SECTION CHEATS ==========
addToggle("🪶", "Fly (WASD + Gamepad)", settings.fly, function(v) settings.fly = v; if v then startFly() else stopFly() end end)
addStepper("🏃", "Walk Speed (Ground)", 16, 500, settings.walkspeed, 10, function(v) settings.walkspeed = v; updateChar() end)
addStepper("🦘", "Jump Power", 30, 200, settings.jumppower, 10, function(v) settings.jumppower = v; updateChar() end)
addToggle("♾️", "Infinite Jump", settings.infinitejump, function(v) settings.infinitejump = v; updateChar() end)
addStepper("🚀", "Air Speed", 16, 500, settings.airspeed, 10, function(v) settings.airspeed = v; updateChar() end)
addToggle("🛡️", "God Mode", settings.godmode, function(v) settings.godmode = v; if v then applyGodMode() end end)
addToggle("⚔️", "Kill Aura", settings.killaura, function(v) settings.killaura = v end)
addStepper("📏", "Kill Aura Range", 10, 100, settings.killaurarange, 10, function(v) settings.killaurarange = v end)
addToggle("🎯", "Aimbot", settings.aimbot, function(v) settings.aimbot = v end)
addToggle("🤖", "Auto Farm (Coin/Gem)", settings.autofarm, function(v) settings.autofarm = v; if v then startFarm() else stopFarm() end end)

-- ========== SEPARATOR ==========
local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, 0, 0, 2)
sep.BackgroundColor3 = Color3.fromRGB(80,80,120)
sep.Parent = container
local sepCorner = Instance.new("UICorner")
sepCorner.CornerRadius = UDim.new(1,0)
sepCorner.Parent = sep

-- ========== SECTION COORDINATES & TELEPORT ==========
local coordFrame = Instance.new("Frame")
coordFrame.Size = UDim2
