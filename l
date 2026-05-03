-- RMAX HUB - UNIVERSAL (Huaa Obstacle + Mount Valthera)
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- ========== DETEKSI MAP ==========
local placeId = game.PlaceId
local isHuaa = (placeId == 89054581105142)
local isValthera = (placeId == 74996495742979)

local currentMap = nil
if isHuaa then currentMap = "Huaa"
elseif isValthera then currentMap = "Valthera"
else currentMap = "Unknown" end

print("Map detected:", currentMap)

-- ========== CP LIST ==========
local cpList = {}
if isHuaa then
    cpList = {
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
        {index=23, pos=Vector3.new(351.3, 149.3, 109.8)}, -- lobby
    }
elseif isValthera then
    -- Urutan berdasarkan jam (dari awal ke summit)
    cpList = {
        {index=1, pos=Vector3.new(591.0, 29.3, 167.3)},
        {index=2, pos=Vector3.new(-108.9, 100.4, 191.2)},
        {index=3, pos=Vector3.new(-923.9, 96.4, 208.7)},
        {index=4, pos=Vector3.new(-1602.7, 99.4, 92.0)},
        {index=5, pos=Vector3.new(-1590.0, 189.4, -438.2)},
        {index=6, pos=Vector3.new(-1568.6, 192.4, -1042.8)},
        {index=7, pos=Vector3.new(-1634.1, 284.4, -1646.4)},
        {index=8, pos=Vector3.new(-2417.3, 291.4, -1648.3)},
        {index=9, pos=Vector3.new(-2986.7, 405.4, -1649.9)},
        {index=10, pos=Vector3.new(-3770.5, 408.4, -1652.9)},
        {index=11, pos=Vector3.new(-4756.6, 411.4, -1664.8)},
        {index=12, pos=Vector3.new(-7113.1, 414.4, -1713.5)},
        {index=13, pos=Vector3.new(-9318.6, 586.9, -1676.8)},
        {index=14, pos=Vector3.new(-10006.2, 590.4, -1702.7)},
        {index=15, pos=Vector3.new(-11195.8, 593.4, -2124.7)},
        {index=16, pos=Vector3.new(-11181.4, 596.4, -3468.8)},
        {index=17, pos=Vector3.new(-11186.9, 724.4, -4221.9)},
        {index=18, pos=Vector3.new(-11185.1, 727.4, -5107.6)},
        {index=19, pos=Vector3.new(-11150.0, 728.4, -6982.9)},
        {index=20, pos=Vector3.new(-11095.6, 731.1, -8506.5)},
        {index=21, pos=Vector3.new(-9917.7, 13653.4, -9738.3)}, -- summit
    }
end

local lobbyPos = isHuaa and Vector3.new(351.3, 149.3, 109.8) or (isValthera and cpList[1].pos or Vector3.new(0,0,0))

local currentCpIndex = 1
local autoRunning = false
local autoThread = nil

local function teleportToPosition(pos)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos.X, pos.Y, pos.Z)
    end
end

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

local function startAutoCp(delaySec)
    if autoRunning then return end
    autoRunning = true
    autoThread = coroutine.create(function()
        while autoRunning do
            for i = 1, #cpList do
                if not autoRunning then break end
                teleportToCp(i)
                if i < #cpList then
                    local start = tick()
                    while tick() - start < delaySec and autoRunning do
                        wait(0.1)
                    end
                else
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

-- ========== SETTINGS (Sama seperti sebelumnya) ==========
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

-- ========== UI ==========
pcall(function() game:GetService("CoreGui"):FindFirstChild("RmaxHubDelta"):Destroy() end)
pcall(function() player.PlayerGui:FindFirstChild("RmaxHubDelta"):Destroy() end)

local guiParent = game:GetService("CoreGui")
if not guiParent then guiParent = player.PlayerGui end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RmaxHubDelta"
screenGui.Parent = guiParent

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 600)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
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
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = container

local function updateMainScroll()
    local totalHeight = 0
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Frame") then
            totalHeight = totalHeight + child.Size.Y.Offset + layout.Padding.Offset
        end
    end
    container.Size = UDim2.new(1, 0, 0, totalHeight)
    scroll.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
end

-- Helper: createCategory
local function createCategory(icon, title, defaultOpen)
    local categoryFrame = Instance.new("Frame")
    categoryFrame.Size = UDim2.new(1, 0, 0, 0)
    categoryFrame.BackgroundTransparency = 1
    categoryFrame.Parent = container
    
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 35)
    header.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    header.Text = icon .. " " .. title
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Font = Enum.Font.GothamBold
    header.TextSize = 15
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 6)
    headerCorner.Parent = header
    header.Parent = categoryFrame
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.Visible = defaultOpen
    content.Parent = categoryFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 4)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content
    
    local function updateCategoryHeight()
        local contentHeight = 0
        for _, child in ipairs(content:GetChildren()) do
            if child:IsA("Frame") then
                contentHeight = contentHeight + child.Size.Y.Offset + contentLayout.Padding.Offset
            end
        end
        content.Size = UDim2.new(1, 0, 0, contentHeight)
        categoryFrame.Size = UDim2.new(1, 0, 0, 35 + (content.Visible and contentHeight or 0))
        updateMainScroll()
    end
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCategoryHeight)
    
    local isOpen = defaultOpen
    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        content.Visible = isOpen
        updateCategoryHeight()
    end)
    
    spawn(function()
        wait(0.05)
        updateCategoryHeight()
    end)
    
    return {
        content = content,
        layout = contentLayout,
        header = header,
        updateHeight = updateCategoryHeight
    }
end

-- Helper UI elements
local function addToggle(parent, icon, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 38)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = icon .. " " .. text
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 28)
    btn.Position = UDim2.new(1, -70, 0, 5)
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

local function addStepper(parent, icon, text, minv, maxv, default, step, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 48)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = icon .. " " .. text
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame
    
    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2
