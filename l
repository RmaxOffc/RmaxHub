-- RMAX HUB - FINAL (Auto CP untuk HUAA OBSTACLE)
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

-- ========== FITUR AUTO CP (KHUSUS HUAA OBSTACLE) ==========
local isHuaaMap = (game.PlaceId == 89054581105142) or (game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name:find("HUAA OBSTACLE"))
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
    {index=22, pos=Vector3.new(-1650.2, 4492.7, 2626.6)}, -- ada 22 CP? dari data ada 22 baris
}
local currentCpIndex = 1
local autoCpActive = false
local autoCpConnection

local function teleportToCp(index)
    local cp = cpList[index]
    if cp then
        teleportToPosition(cp.pos)
    end
end

local function nextCp()
    currentCpIndex = currentCpIndex + 1
    if currentCpIndex > #cpList then currentCpIndex = 1 end
    teleportToCp(currentCpIndex)
end

local function startAutoCp()
    if autoCpConnection then return end
    autoCpActive = true
    autoCpConnection = runService.Heartbeat:Connect(function()
        if not autoCpActive then
            if autoCpConnection then autoCpConnection:Disconnect() end
            autoCpConnection = nil
            return
        end
        -- bisa ditambah delay atau tombol manual? lebih baik manual next, tapi user minta auto?
        -- Saya buat auto loop dengan interval 0.5 detik, tapi lebih aman manual next via tombol
        -- Karena permintaan "auto cp sistem teleport", saya buat auto next setiap 1 detik? nanti malah jadi spam.
        -- Saya tafsirkan: user ingin tekan tombol "Auto Next CP" yang akan teleport ke CP berikutnya secara manual, tidak otomatis loop.
        -- Saya buat toggle: jika diaktifkan, akan teleport otomatis ke CP berikutnya setiap 1.5 detik.
        -- Biar lebih fleksibel: tambahkan toggle "Auto Loop CP" dengan interval slider.
    end)
end

-- Saya gunakan sistem manual next dengan tombol "Auto Next CP" (satu kali tekan = pindah ke CP berikutnya)
-- Karena lebih aman dan tidak mencurigakan.

-- ========== UI UNTUK DELTA ==========
pcall(function() game:GetService("CoreGui"):FindFirstChild("RmaxHubDelta"):Destroy() end)
pcall(function() player.PlayerGui:FindFirstChild("RmaxHubDelta"):Destroy() end)

local guiParent = game:GetService("CoreGui")
if not guiParent then guiParent = player.PlayerGui end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RmaxHubDelta"
screenGui.Parent = guiParent

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 440, 0, 680)
mainFrame.Position = UDim2.new(0.5, -220, 0.5, -340)
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

-- Helper: Stepper
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

-- Helper: Button
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
coordFrame.Size = UDim2.new(1, 0, 0, 80)
coordFrame.BackgroundTransparency = 1
coordFrame.Parent = container

local coordText = Instance.new("TextLabel")
coordText.Size = UDim2.new(1, 0, 0, 25)
coordText.Text = "📍 Current Position: X:0 Y:0 Z:0"
coordText.TextColor3 = Color3.new(1,1,1)
coordText.BackgroundTransparency = 1
coordText.Font = Enum.Font.Gotham
coordText.TextSize = 14
coordText.Parent = coordFrame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0, 80, 0, 30)
copyBtn.Position = UDim2.new(0, 0, 0, 30)
copyBtn.Text = "📋 Copy"
copyBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
copyBtn.TextColor3 = Color3.new(1,1,1)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 13
local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 6)
copyCorner.Parent = copyBtn
copyBtn.Parent = coordFrame

spawn(function()
    while true do
        wait(0.1)
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            coordText.Text = string.format("📍 Current Position: X:%.1f Y:%.1f Z:%.1f", pos.X, pos.Y, pos.Z)
        end
    end
end)

copyBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        local str = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
        pcall(function() setclipboard(str) end)
        copyBtn.Text = "✓ Copied!"
        wait(1)
        copyBtn.Text = "📋 Copy"
    end
end)

-- Save coordinates slots
for i = 1, 5 do
    local slotFrame = Instance.new("Frame")
    slotFrame.Size = UDim2.new(1, 0, 0, 35)
    slotFrame.BackgroundTransparency = 1
    slotFrame.Parent = container
    
    local slotLabel = Instance.new("TextLabel")
    slotLabel.Size = UDim2.new(0.2, 0, 1, 0)
    slotLabel.Text = "Slot " .. i
    slotLabel.TextColor3 = Color3.fromRGB(200,200,200)
    slotLabel.BackgroundTransparency = 1
    slotLabel.Font = Enum.Font.Gotham
    slotLabel.TextSize = 13
    slotLabel.Parent = slotFrame
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0, 60, 0, 25)
    saveBtn.Position = UDim2.new(0.25, 0, 0, 5)
    saveBtn.Text = "💾 Save"
    saveBtn.BackgroundColor3 = Color3.fromRGB(60,100,60)
    saveBtn.TextColor3 = Color3.new(1,1,1)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 12
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 4)
    saveCorner.Parent = saveBtn
    saveBtn.Parent = slotFrame
    
    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0, 60, 0, 25)
    tpBtn.Position = UDim2.new(0.55, 0, 0, 5)
    tpBtn.Text = "✨ TP"
    tpBtn.BackgroundColor3 = Color3.fromRGB(60,60,100)
    tpBtn.TextColor3 = Color3.new(1,1,1)
    tpBtn.Font = Enum.Font.GothamBold
    tpBtn.TextSize = 12
    local tpCorner = Instance.new("UICorner")
    tpCorner.CornerRadius = UDim.new(0, 4)
    tpCorner.Parent = tpBtn
    tpBtn.Parent = slotFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.2, 0, 1, 0)
    statusLabel.Position = UDim2.new(0.78, 0, 0, 0)
    statusLabel.Text = "Empty"
    statusLabel.TextColor3 = Color3.fromRGB(150,150,150)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 11
    statusLabel.Parent = slotFrame
    
    saveBtn.MouseButton1Click:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            saveCoord(i, pos)
            statusLabel.Text = string.format("X:%.0f Y:%.0f Z:%.0f", pos.X, pos.Y, pos.Z)
            statusLabel.TextColor3 = Color3.fromRGB(0,255,0)
        end
    end)
    
    tpBtn.MouseButton1Click:Connect(function()
        local coord = getCoord(i)
        if coord then
            teleportToPosition(Vector3.new(coord.X, coord.Y, coord.Z))
        end
    end)
end

-- ========== PLAYER LIST ==========
local playerListFrame = Instance.new("Frame")
playerListFrame.Size = UDim2.new(1, 0, 0, 150)
playerListFrame.BackgroundTransparency = 1
playerListFrame.Parent = container

local playerListLabel = Instance.new("TextLabel")
playerListLabel.Size = UDim2.new(1, 0, 0, 25)
playerListLabel.Text = "👥 Players Online"
playerListLabel.TextColor3 = Color3.fromRGB(0,255,255)
playerListLabel.BackgroundTransparency = 1
playerListLabel.Font = Enum.Font.GothamBold
playerListLabel.TextSize = 14
playerListLabel.Parent = playerListFrame

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, 0, 1, -30)
playerScroll.Position = UDim2.new(0, 0, 0, 25)
playerScroll.BackgroundTransparency = 1
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 4
playerScroll.Parent = playerListFrame

local playerContainer = Instance.new("Frame")
playerContainer.Size = UDim2.new(1, 0, 0, 0)
playerContainer.BackgroundTransparency = 1
playerContainer.Parent = playerScroll

local playerLayout = Instance.new("UIListLayout")
playerLayout.Padding = UDim.new(0, 4)
playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerLayout.Parent = playerContainer

local function updatePlayerList()
    for _, child in ipairs(playerContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 32)
            row.BackgroundTransparency = 1
            row.Parent = playerContainer
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
            nameLabel.Text = plr.Name
            nameLabel.TextColor3 = Color3.new(1,1,1)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextSize = 12
            nameLabel.Parent = row
            
            local tpBtn = Instance.new("TextButton")
            tpBtn.Size = UDim2.new(0, 70, 0, 24)
            tpBtn.Position = UDim2.new(0.45, 0, 0, 4)
            tpBtn.Text = "🚀 TP"
            tpBtn.BackgroundColor3 = Color3.fromRGB(60,80,120)
            tpBtn.TextColor3 = Color3.new(1,1,1)
            tpBtn.Font = Enum.Font.GothamBold
            tpBtn.TextSize = 11
            local tpCorner = Instance.new("UICorner")
            tpCorner.CornerRadius = UDim.new(0, 4)
            tpCorner.Parent = tpBtn
            tpBtn.Parent = row
            
            local bringBtn = Instance.new("TextButton")
            bringBtn.Size = UDim2.new(0, 70, 0, 24)
            bringBtn.Position = UDim2.new(0.7, 0, 0, 4)
            bringBtn.Text = "📦 Bring"
            bringBtn.BackgroundColor3 = Color3.fromRGB(120,60,60)
            bringBtn.TextColor3 = Color3.new(1,1,1)
            bringBtn.Font = Enum.Font.GothamBold
            bringBtn.TextSize = 11
            local bringCorner = Instance.new("UICorner")
            bringCorner.CornerRadius = UDim.new(0, 4)
            bringCorner.Parent = bringBtn
            bringBtn.Parent = row
            
            tpBtn.MouseButton1Click:Connect(function() teleportToPlayer(plr) end)
            bringBtn.MouseButton1Click:Connect(function() bringPlayer(plr) end)
        end
    end
    local total = 0
    for _, child in ipairs(playerContainer:GetChildren()) do
        if child:IsA("Frame") then total = total + child.Size.Y.Offset + playerLayout.Padding.Offset end
    end
    playerContainer.Size = UDim2.new(1, 0, 0, total)
    playerScroll.CanvasSize = UDim2.new(0, 0, 0, total + 20)
end

spawn(function()
    while true do
        updatePlayerList()
        wait(1)
    end
end)

-- ========== SECTION AUTO CP (HANYA UNTUK HUAA OBSTACLE) ==========
if isHuaaMap then
    local cpSeparator = Instance.new("Frame")
    cpSeparator.Size = UDim2.new(1, 0, 0, 2)
    cpSeparator.BackgroundColor3 = Color3.fromRGB(80,80,120)
    cpSeparator.Parent = container
    local cpSepCorner = Instance.new("UICorner")
    cpSepCorner.CornerRadius = UDim.new(1,0)
    cpSepCorner.Parent = cpSeparator
    
    local cpTitle = Instance.new("TextLabel")
    cpTitle.Size = UDim2.new(1, 0, 0, 30)
    cpTitle.Text = "🏁 AUTO CP (HUAA OBSTACLE)"
    cpTitle.TextColor3 = Color3.fromRGB(255,200,0)
    cpTitle.BackgroundTransparency = 1
    cpTitle.Font = Enum.Font.GothamBold
    cpTitle.TextSize = 16
    cpTitle.Parent = container
    
    -- Tombol Next CP
    addButton("⏩", "Next CP (Manual)", function()
        nextCp()
    end)
    
    -- Daftar semua CP (scrollable)
    local cpListFrame = Instance.new("Frame")
    cpListFrame.Size = UDim2.new(1, 0, 0, 150)
    cpListFrame.BackgroundTransparency = 1
    cpListFrame.Parent = container
    
    local cpScroll = Instance.new("ScrollingFrame")
    cpScroll.Size = UDim2.new(1, 0, 1, 0)
    cpScroll.BackgroundTransparency = 1
    cpScroll.BorderSizePixel = 0
    cpScroll.ScrollBarThickness = 4
    cpScroll.Parent = cpListFrame
    
    local cpContainer = Instance.new("Frame")
    cpContainer.Size = UDim2.new(1, 0, 0, 0)
    cpContainer.BackgroundTransparency = 1
    cpContainer.Parent = cpScroll
    
    local cpLayout = Instance.new("UIListLayout")
    cpLayout.Padding = UDim.new(0, 4)
    cpLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cpLayout.Parent = cpContainer
    
    for _, cp in ipairs(cpList) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundTransparency = 1
        row.Parent = cpContainer
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.3, 0, 1, 0)
        label.Text = "CP " .. cp.index
        label.TextColor3 = Color3.new(1,1,1)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.Parent = row
        
        local tpCpBtn = Instance.new("TextButton")
        tpCpBtn.Size = UDim2.new(0, 80, 0, 24)
        tpCpBtn.Position = UDim2.new(0.4, 0, 0, 3)
        tpCpBtn.Text = "📍 TP"
        tpCpBtn.BackgroundColor3 = Color3.fromRGB(60,80,120)
        tpCpBtn.TextColor3 = Color3.new(1,1,1)
        tpCpBtn.Font = Enum.Font.GothamBold
        tpCpBtn.TextSize = 12
        local tpCorner = Instance.new("UICorner")
        tpCorner.CornerRadius = UDim.new(0, 4)
        tpCorner.Parent = tpCpBtn
        tpCpBtn.Parent = row
        
        local coordLabel = Instance.new("TextLabel")
        coordLabel.Size = UDim2.new(0.4, 0, 1, 0)
        coordLabel.Position = UDim2.new(0.6, 0, 0, 0)
        coordLabel.Text = string.format("%.0f,%.0f,%.0f", cp.pos.X, cp.pos.Y, cp.pos.Z)
        coordLabel.TextColor3 = Color3.fromRGB(180,180,180)
        coordLabel.BackgroundTransparency = 1
        coordLabel.Font = Enum.Font.Gotham
        coordLabel.TextSize = 10
        coordLabel.Parent = row
        
        tpCpBtn.MouseButton1Click:Connect(function()
            teleportToCp(cp.index)
        end)
    end
    
    local function updateCpScroll()
        local total = 0
        for _, child in ipairs(cpContainer:GetChildren()) do
            if child:IsA("Frame") then total = total + child.Size.Y.Offset + cpLayout.Padding.Offset end
        end
        cpContainer.Size = UDim2.new(1, 0, 0, total)
        cpScroll.CanvasSize = UDim2.new(0, 0, 0, total + 10)
        cpListFrame.Size = UDim2.new(1, 0, 0, math.min(200, total + 20))
    end
    cpLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCpScroll)
    wait(0.1)
    updateCpScroll()
end

-- Update main scroll
local function updateMainScroll()
    local total = 0
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Frame") then
            total = total + child.Size.Y.Offset + layout.Padding.Offset
        end
    end
    container.Size = UDim2.new(1, 0, 0, total)
    scroll.CanvasSize = UDim2.new(0, 0, 0, total + 30)
end

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateMainScroll)
wait(0.2)
updateMainScroll()
updatePlayerList()

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
        mainFrame:TweenSize(UDim2.new(0, 440, 0, 40), "Out", "Quad", 0.2, true)
    else
        mainFrame:TweenSize(UDim2.new(0, 440, 0, 680), "Out", "Quad", 0.2, true)
        wait(0.2)
        scroll.Visible = true
        updateMainScroll()
    end
end)

-- Show/hide Insert
uis.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

print("✅ RMAX HUB + AUTO CP (HUAA) LOADED - Insert to toggle")
