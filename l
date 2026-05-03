--[[
  RMAX HUB - EXTREME EDITION (DARK / GORE)
  Fitur Rusuh + Detector Celah Sistem Real-Time
  Map: Huaa Obstacle / Mount Valthera + Universal
--]]

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local lighting = game:GetService("Lighting")
local http = game:GetService("HttpService")
local coreGui = game:GetService("CoreGui")

-- ========== DETEKSI MAP ==========
local placeId = game.PlaceId
local isHuaa = (placeId == 89054581105142)
local isValthera = (placeId == 74996495742979)
local currentMap = (isHuaa and "Huaa") or (isValthera and "Valthera") or "Unknown"
print("Map detected:", currentMap)

-- ========== CP LIST (sama seperti sebelumnya) ==========
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
        {index=23, pos=Vector3.new(351.3, 149.3, 109.8)},
    }
elseif isValthera then
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
        {index=21, pos=Vector3.new(-9917.7, 13653.4, -9738.3)},
    }
end
local lobbyPos = (isHuaa and Vector3.new(351.3,149.3,109.8)) or (isValthera and cpList[1] and cpList[1].pos) or Vector3.new(0,0,0)

local currentCpIndex = 1
local autoRunning = false
local autoThread = nil

-- ========== FUNGSI TELEPORT DASAR ==========
local function teleportToPosition(pos)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end
local function teleportToCp(index)
    if cpList[index] then teleportToPosition(cpList[index].pos); currentCpIndex = index end
end
local function goToLobby() teleportToPosition(lobbyPos) end

local function startAutoCp(delaySec)
    if autoRunning then return end
    autoRunning = true
    autoThread = coroutine.create(function()
        while autoRunning do
            for i=1,#cpList do
                if not autoRunning then break end
                teleportToCp(i)
                wait(delaySec)
            end
        end
    end)
    coroutine.resume(autoThread)
end
local function stopAutoCp() autoRunning = false end

-- ========== SETTINGS (Baru + Rusuh) ==========
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
    -- FITUR RUSUH
    laserActive = false,
    laserTarget = nil,
    laserDamage = 15,
    laserRange = 150,
    laserTurret = false,
    laserTurretRadius = 100,
    laserTurretDamage = 10,
    freezePlayer = false,
    freezeTarget = nil,
    blindPlayer = false,
    blindTarget = nil,
    crashPlayer = false,
    crashTarget = nil,
    -- DETECTOR
    detectorEnabled = false,
    systemBreach = false,
}

-- ========== SAVED COORD ==========
local savedCoords = {}
local function saveCoord(slot, pos) savedCoords[slot] = {X=pos.X, Y=pos.Y, Z=pos.Z} end
local function getCoord(slot) return savedCoords[slot] end

-- ========== FLY SYSTEM (sama) ==========
local bodyVel, bodyGyro, flyConn
local function stopFly()
    if flyConn then flyConn:Disconnect() end
    if bodyVel then bodyVel:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    flyConn, bodyVel, bodyGyro = nil, nil, nil
end
local function startFly()
    stopFly()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    bodyVel = Instance.new("BodyVelocity"); bodyGyro = Instance.new("BodyGyro")
    bodyVel.MaxForce = Vector3.new(1e5,1e5,1e5); bodyVel.P = 1e4
    bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5); bodyGyro.P = 1e4
    bodyVel.Parent = char.HumanoidRootPart; bodyGyro.Parent = char.HumanoidRootPart
    flyConn = runService.RenderStepped:Connect(function()
        if not settings.fly or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopFly(); return
        end
        local move = Vector3.new()
        if uis:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0,0,-1) end
        if uis:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0,0,1) end
        if uis:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-1,0,0) end
        if uis:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(1,0,0) end
        if uis:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftControl) then move = move + Vector3.new(0,-1,0) end
        if move.Magnitude>0 then move=move.Unit end
        local cam = workspace.CurrentCamera
        local vel = (cam.CFrame.LookVector * move.Z + cam.CFrame.RightVector * move.X + Vector3.new(0,move.Y,0)) * 100
        bodyVel.Velocity = vel
        bodyGyro.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position, player.Character.HumanoidRootPart.Position + cam.CFrame.LookVector)
    end)
end

-- ========== MOVEMENT / GOD / KILL AURA / AIMBOT / AUTO FARM (sama seperti sebelumnya, dipertahankan) ==========
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
    if settings.infinitejump and (hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall) then
        hum.WalkSpeed = settings.airspeed
    else
        hum.WalkSpeed = settings.walkspeed
    end
end
player.CharacterAdded:Connect(updateChar)
runService.Heartbeat:Connect(updateChar)

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

runService.RenderStepped:Connect(function()
    if settings.aimbot and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local closest, closestDist = nil, 200
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if dist < closestDist then
                        closestDist = dist; closest = plr
                    end
                end
            end
        end
        if closest then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, closest.Character.HumanoidRootPart.Position)
        end
    end
end)

local farmConn
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
                    nearestDist = dist; nearest = obj
                end
            end
        end
        if nearest then root.CFrame = nearest.CFrame end
    end)
end
local function stopFarm() if farmConn then farmConn:Disconnect(); farmConn = nil end end

-- ========== FITUR RUSUH ==========
-- Laser (continuous damage ke target)
local laserBeam = nil
local laserDamageThread = nil
local function stopLaser()
    if laserBeam then laserBeam:Destroy(); laserBeam = nil end
    if laserDamageThread then coroutine.close(laserDamageThread); laserDamageThread = nil end
end

local function createLaserBeam(fromPos, toPos, color)
    local beam = Instance.new("Part")
    beam.Size = Vector3.new(0.2, 0.2, (toPos - fromPos).Magnitude)
    beam.CFrame = CFrame.new(fromPos, toPos) * CFrame.new(0,0, -beam.Size.Z/2)
    beam.BrickColor = BrickColor.new(color)
    beam.Material = Enum.Material.Neon
    beam.Anchored = true
    beam.CanCollide = false
    beam.Parent = workspace
    return beam
end

local function laserDamageLoop(target)
    while settings.laserActive and target and target.Character and target.Character:FindFirstChild("Humanoid") do
        local hum = target.Character.Humanoid
        hum.Health = hum.Health - settings.laserDamage
        if hum.Health <= 0 then break end
        wait(0.2)
    end
end

local function updateLaser()
    if not settings.laserActive or not settings.laserTarget or not settings.laserTarget.Character or not settings.laserTarget.Character:FindFirstChild("HumanoidRootPart") then
        stopLaser()
        return
    end
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = settings.laserTarget.Character.HumanoidRootPart
    if not myRoot or not targetRoot then return end
    if (myRoot.Position - targetRoot.Position).Magnitude > settings.laserRange then
        stopLaser()
        return
    end
    if not laserBeam then
        laserBeam = createLaserBeam(myRoot.Position, targetRoot.Position, "Bright red")
    else
        local dist = (targetRoot.Position - myRoot.Position).Magnitude
        laserBeam.Size = Vector3.new(0.2, 0.2, dist)
        laserBeam.CFrame = CFrame.new(myRoot.Position, targetRoot.Position) * CFrame.new(0,0, -dist/2)
    end
    if not laserDamageThread then
        laserDamageThread = coroutine.create(laserDamageLoop)
        coroutine.resume(laserDamageThread, settings.laserTarget)
    end
end

-- Laser Turret (otomatis serang semua pemain di radius)
local turretThread = nil
local function turretLoop()
    while settings.laserTurret do
        local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            for _, plr in ipairs(game.Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
                    local dist = (plr.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
                    if dist <= settings.laserTurretRadius then
                        local hum = plr.Character.Humanoid
                        hum.Health = hum.Health - settings.laserTurretDamage
                        -- efek laser sesaat
                        local beam = createLaserBeam(myRoot.Position, plr.Character.HumanoidRootPart.Position, "New Yeller")
                        game:GetService("Debris"):AddItem(beam, 0.1)
                    end
                end
            end
        end
        wait(0.2)
    end
end

local function startTurret()
    if turretThread then coroutine.close(turretThread) end
    turretThread = coroutine.create(turretLoop)
    coroutine.resume(turretThread)
end

-- Freeze Player (bekukan movement)
local freezeConnection = nil
local function freezeTargetPlayer(plr)
    if not plr or not plr.Character or not plr.Character:FindFirstChild("Humanoid") then return end
    local hum = plr.Character.Humanoid
    local originalSpeed = hum.WalkSpeed
    local originalJump = hum.JumpPower
    hum.WalkSpeed = 0
    hum.JumpPower = 0
    if freezeConnection then freezeConnection:Disconnect() end
    freezeConnection = runService.Heartbeat:Connect(function()
        if not settings.freezePlayer or settings.freezeTarget ~= plr or not plr.Character or not plr.Character:FindFirstChild("Humanoid") then
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.WalkSpeed = originalSpeed
                plr.Character.Humanoid.JumpPower = originalJump
            end
            if freezeConnection then freezeConnection:Disconnect(); freezeConnection = nil end
            return
        end
        local h = plr.Character.Humanoid
        h.WalkSpeed = 0
        h.JumpPower = 0
    end)
end

-- Blind Player (flash berulang)
local blindThread = nil
local function blindLoop(plr)
    while settings.blindPlayer and settings.blindTarget == plr and plr and plr.Character do
        local char = plr.Character
        local head = char:FindFirstChild("Head")
        if head then
            local flash = Instance.new("Part")
            flash.Size = Vector3.new(10,10,10)
            flash.CFrame = head.CFrame
            flash.Anchored = true
            flash.CanCollide = false
            flash.Material = Enum.Material.Neon
            flash.BrickColor = BrickColor.new("White")
            flash.Parent = workspace
            game:GetService("Debris"):AddItem(flash, 0.1)
        end
        wait(0.3)
    end
end

-- Crash Player (overload partikel)
local crashThreads = {}
local function crashPlayerLoop(plr)
    while settings.crashPlayer and settings.crashTarget == plr and plr and plr.Character do
        local char = plr.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            for i=1,50 do
                local part = Instance.new("Part")
                part.Size = Vector3.new(1,1,1)
                part.CFrame = root.CFrame * CFrame.new(math.random(-10,10), math.random(-10,10), math.random(-10,10))
                part.Anchored = true
                part.CanCollide = false
                part.BrickColor = BrickColor.random()
                part.Material = Enum.Material.Neon
                part.Parent = workspace
                game:GetService("Debris"):AddItem(part, 0.5)
            end
            -- juga mainkan suara
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://912038123" -- suara ledakan
            sound.Volume = 1
            sound.Parent = root
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 1)
        end
        wait(0.5)
    end
end

-- ========== DETECTOR REAL-TIME (backdoor, celah, anti-cheat) ==========
local detectorOutput = ""
local detectorLog = {}
local function addDetectorLog(msg)
    table.insert(detectorLog, 1, os.date("%H:%M:%S") .. " | " .. msg)
    if #detectorLog > 20 then table.remove(detectorLog) end
    detectorOutput = table.concat(detectorLog, "\n")
end

local function scanForBackdoors()
    addDetectorLog("[SCAN] Scanning Remotes...")
    local vulnerableRemotes = {}
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local success, result = pcall(function()
                -- cek apakah remote bisa di-fire dari client tanpa authentication
                if obj:IsA("RemoteEvent") then
                    obj:FireServer("__test_backdoor")
                else
                    obj:InvokeServer("__test_backdoor")
                end
            end)
            if not success and string.find(result, "not allowed") then
                -- aman
            else
                table.insert(vulnerableRemotes, obj:GetFullName())
                addDetectorLog("[!] VULNERABLE: " .. obj:GetFullName() .. " (no auth)")
            end
        end
        -- Deteksi admin scripts
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            if obj.Name:lower():find("admin") or obj.Name:lower():find("anticheat") then
                addDetectorLog("[*] Found: " .. obj:GetFullName())
            end
        end
        -- Deteksi exploit detector
        if obj:IsA("BoolValue") and obj.Name:lower():find("exploit") then
            addDetectorLog("[!] Anti-cheat flag: " .. obj:GetFullName())
        end
    end
    -- Cek wrapper vulnerability
    local success, fenv = pcall(function() return getfenv() end)
    if success and fenv then
        if rawget(fenv, "loadstring") and rawget(fenv, "getrenv") then
            addDetectorLog("[OK] Full execution environment accessible")
        end
    end
    -- Cek backdoor di workspace
    for _, part in ipairs(workspace:GetDescendants()) do
        if part.Name:lower():find("backdoor") or (part:IsA("Script") and part.Name:lower():find("backdoor")) then
            addDetectorLog("[!] BACKDOOR FOUND: " .. part:GetFullName())
            if settings.systemBreach then
                -- exploit backdoor
                pcall(function() part:Destroy() end)
                addDetectorLog("[SYSTEM BREACH] Backdoor destroyed")
            end
        end
    end
end

local function continuousDetector()
    while settings.detectorEnabled do
        scanForBackdoors()
        wait(5)
    end
end

-- ========== UI MODERN (EXTREME) ==========
pcall(function() coreGui:FindFirstChild("RmaxHubExtreme"):Destroy() end)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RmaxHubExtreme"
screenGui.Parent = coreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 650)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -325)
mainFrame.BackgroundColor3 = Color3.fromRGB(10,10,20)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,40)
titleBar.BackgroundColor3 = Color3.fromRGB(40,0,40)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0,12)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1,-50,1,0)
titleText.Position = UDim2.new(0,12,0,0)
titleText.BackgroundTransparency = 1
titleText.Text = "💀 RMAX EXTREME | RUSUH + DETECTOR 💀"
titleText.TextColor3 = Color3.fromRGB(255,0,0)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16
titleText.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0,30,0,30)
minimizeBtn.Position = UDim2.new(1,-40,0,5)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.TextSize = 24
minimizeBtn.Parent = titleBar

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,-10,1,-50)
scroll.Position = UDim2.new(0,5,0,45)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.Parent = mainFrame

local container = Instance.new("Frame")
container.Size = UDim2.new(1,0,0,0)
container.BackgroundTransparency = 1
container.Parent = scroll

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = container

local function updateScroll()
    local total = 0
    for _,child in ipairs(container:GetChildren()) do
        if child:IsA("Frame") then
            total = total + child.Size.Y.Offset + layout.Padding.Offset
        end
    end
    container.Size = UDim2.new(1,0,0,total)
    scroll.CanvasSize = UDim2.new(0,0,0,total+20)
end

local function createCategory(icon, title, defaultOpen)
    local cat = Instance.new("Frame")
    cat.Size = UDim2.new(1,0,0,0)
    cat.BackgroundTransparency = 1
    cat.Parent = container
    
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1,0,0,36)
    header.BackgroundColor3 = Color3.fromRGB(30,20,40)
    header.Text = icon .. " " .. title
    header.TextColor3 = Color3.new(1,1,1)
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Font = Enum.Font.GothamBold
    header.TextSize = 14
    local headCorner = Instance.new("UICorner")
    headCorner.CornerRadius = UDim.new(0,6)
    headCorner.Parent = header
    header.Parent = cat
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,0,0,0)
    content.BackgroundTransparency = 1
    content.Visible = defaultOpen
    content.Parent = cat
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0,4)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content
    
    local function updateHeight()
        local ch = 0
        for _,c in ipairs(content:GetChildren()) do
            if c:IsA("Frame") then
                ch = ch + c.Size.Y.Offset + contentLayout.Padding.Offset
            end
        end
        content.Size = UDim2.new(1,0,0,ch)
        cat.Size = UDim2.new(1,0,0,36 + (content.Visible and ch or 0))
        updateScroll()
    end
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateHeight)
    local open = defaultOpen
    header.MouseButton1Click:Connect(function()
        open = not open
        content.Visible = open
        updateHeight()
    end)
    spawn(updateHeight)
    return {content=content, layout=contentLayout, update=updateHeight}
end

-- Helper UI
local function addToggle(parent, icon, text, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-10,0,36)
    f.BackgroundTransparency = 1
    f.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7,0,1,0)
    label.Text = icon .. " " .. text
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = f
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,60,0,28)
    btn.Position = UDim2.new(1,-70,0,4)
    btn.BackgroundColor3 = default and Color3.fromRGB(200,0,0) or Color3.fromRGB(80,80,100)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(0,0,0)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1,0)
    btnCorner.Parent = btn
    btn.Parent = f
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(200,0,0) or Color3.fromRGB(80,80,100)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    return f
end

local function addButton(parent, icon, text, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-10,0,36)
    f.BackgroundTransparency = 1
    f.Parent = parent
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,30)
    btn.Text = icon .. " " .. text
    btn.BackgroundColor3 = Color3.fromRGB(50,30,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,6)
    btnCorner.Parent = btn
    btn.Parent = f
    btn.MouseButton1Click:Connect(callback)
    return f
end

local function addDropdown(parent, icon, text, items, callback)
    -- sederhana
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-10,0,36)
    f.BackgroundTransparency = 1
    f.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5,0,1,0)
    label.Text = icon .. " " .. text
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Parent = f
    local drop = Instance.new("TextButton")
    drop.Size = UDim2.new(0.4,0,0,28)
    drop.Position = UDim2.new(0.55,0,0,4)
    drop.Text = items[1] or "None"
    drop.BackgroundColor3 = Color3.fromRGB(60,60,80)
    drop.TextColor3 = Color3.new(1,1,1)
    drop.Font = Enum.Font.Gotham
    drop.TextSize = 12
    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0,4)
    dropCorner.Parent = drop
    drop.Parent = f
    local current = items[1]
    drop.MouseButton1Click:Connect(function()
        -- siklus sederhana
        local idx = table.find(items, current)
        idx = idx and (idx % #items) + 1 or 1
        current = items[idx]
        drop.Text = current
        callback(current)
    end)
    return f
end

-- Buat kategori
local movCat = createCategory("🦶", "MOVEMENT", true)
local combatCat = createCategory("⚔️", "COMBAT", false)
local rusuhCat = createCategory("💀", "RUSUH (GRIEF)", true)
local detectorCat = createCategory("🔍", "DETECTOR & BREACH", true)
local teleportCat = createCategory("📍", "TELEPORT", false)

-- Isi MOVEMENT
addToggle(movCat.content, "🪶", "Fly", settings.fly, function(v) settings.fly=v; if v then startFly() else stopFly() end end)
addButton(movCat.content, "➕", "Walk Speed +10", function() settings.walkspeed=math.min(500,settings.walkspeed+10); updateChar() end)
addButton(movCat.content, "➖", "Walk Speed -10", function() settings.walkspeed=math.max(16,settings.walkspeed-10); updateChar() end)
addToggle(movCat.content, "♾️", "Infinite Jump", settings.infinitejump, function(v) settings.infinitejump=v; updateChar() end)
addToggle(movCat.content, "🛡️", "God Mode", settings.godmode, function(v) settings.godmode=v end)

-- Combat
addToggle(combatCat.content, "⚔️", "Kill Aura", settings.killaura, function(v) settings.killaura=v end)
addButton(combatCat.content, "📏", "Range +10", function() settings.killaurarange=math.min(100,settings.killaurarange+10) end)
addToggle(combatCat.content, "🎯", "Aimbot", settings.aimbot, function(v) settings.aimbot=v end)

-- RUSUH
addToggle(rusuhCat.content, "🔴", "Laser Active", settings.laserActive, function(v) settings.laserActive=v; if not v then stopLaser() end end)
addDropdown(rusuhCat.content, "🎯", "Laser Target", game.Players:GetChildren(), function(selected)
    for _,plr in ipairs(game.Players:GetPlayers()) do
        if plr.Name == selected then settings.laserTarget = plr end
    end
end)
addButton(rusuhCat.content, "➕", "Laser Damage +5", function() settings.laserDamage=math.min(100,settings.laserDamage+5) end)
addToggle(rusuhCat.content, "🤖", "Laser Turret (Auto)", settings.laserTurret, function(v) settings.laserTurret=v; if v then startTurret() else if turretThread then coroutine.close(turretThread); turretThread=nil end end end)
addToggle(rusuhCat.content, "❄️", "Freeze Player", settings.freezePlayer, function(v)
    settings.freezePlayer=v
    if v and settings.freezeTarget then freezeTargetPlayer(settings.freezeTarget) end
end)
addDropdown(rusuhCat.content, "❄️", "Freeze Target", game.Players:GetChildren(), function(selected)
    for _,plr in ipairs(game.Players:GetPlayers()) do
        if plr.Name == selected then settings.freezeTarget = plr; if settings.freezePlayer then freezeTargetPlayer(plr) end end
    end
end)
addToggle(rusuhCat.content, "👁️", "Blind Player (Flash)", settings.blindPlayer, function(v)
    settings.blindPlayer=v
    if v and settings.blindTarget then
        if blindThread then coroutine.close(blindThread) end
        blindThread = coroutine.create(blindLoop)
        coroutine.resume(blindThread, settings.blindTarget)
    end
end)
addDropdown(rusuhCat.content, "👁️", "Blind Target", game.Players:GetChildren(), function(selected)
    for _,plr in ipairs(game.Players:GetPlayers()) do if plr.Name==selected then settings.blindTarget=plr end end
end)
addToggle(rusuhCat.content, "💥", "Crash Player (Overload)", settings.crashPlayer, function(v)
    settings.crashPlayer=v
    if v and settings.crashTarget then
        local th = coroutine.create(crashPlayerLoop)
        coroutine.resume(th, settings.crashTarget)
        crashThreads[settings.crashTarget] = th
    end
end)
addDropdown(rusuhCat.content, "💥", "Crash Target", game.Players:GetChildren(), function(selected)
    for _,plr in ipairs(game.Players:GetPlayers()) do if plr.Name==selected then settings.crashTarget=plr end end
end)

-- DETECTOR
addToggle(detectorCat.content, "🕵️", "Real-time Detector", settings.detectorEnabled, function(v)
    settings.detectorEnabled=v
    if v then spawn(continuousDetector) end
end)
addToggle(detectorCat.content, "💣", "System Breach (Auto Destroy Backdoor)", settings.systemBreach, function(v) settings.systemBreach=v end)
addButton(detectorCat.content, "🔍", "Scan Now", function() scanForBackdoors() end)

local detectorLogFrame = Instance.new("Frame")
detectorLogFrame.Size = UDim2.new(1,-10,0,120)
detectorLogFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
detectorLogFrame.BackgroundTransparency = 0.5
detectorLogFrame.Parent = detectorCat.content
local logCorner = Instance.new("UICorner")
logCorner.CornerRadius = UDim.new(0,6)
logCorner.Parent = detectorLogFrame

local logText = Instance.new("TextLabel")
logText.Size = UDim2.new(1,0,1,0)
logText.BackgroundTransparency = 1
logText.Text = "Log akan muncul di sini"
logText.TextColor3 = Color3.fromRGB(0,255,0)
logText.TextWrapped = true
logText.TextXAlignment = Enum.TextXAlignment.Left
logText.TextYAlignment = Enum.TextYAlignment.Top
logText.Font = Enum.Font.Code
logText.TextSize = 11
logText.Parent = detectorLogFrame

spawn(function()
    while true do
        logText.Text = detectorOutput
        wait(0.5)
    end
end)

-- Teleport / CP
if isHuaa or isValthera then
    addButton(teleportCat.content, "🏁", "TP to Lobby", function() goToLobby() end)
    addButton(teleportCat.content, "⏩", "Next CP", function() teleportToCp((currentCpIndex % #cpList)+1) end)
    addButton(teleportCat.content, "▶", "Auto Loop CP", function() startAutoCp(1.5) end)
    addButton(teleportCat.content, "⏹️", "Stop Auto", function() stopAutoCp() end)
end

-- Update height all
for _,cat in pairs({movCat, combatCat, rusuhCat, detectorCat, teleportCat}) do
    cat.update()
end
updateScroll()

-- Draggable + Minimize (sama seperti script user)
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
                moveConn:Disconnect(); endConn:Disconnect()
            end
        end)
    end
end)

local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        scroll.Visible = false
        mainFrame:TweenSize(UDim2.new(0,500,0,40), "Out", "Quad", 0.2)
    else
        mainFrame:TweenSize(UDim2.new(0,500,0,650), "Out", "Quad", 0.2)
        wait(0.2)
        scroll.Visible = true
        updateScroll()
    end
end)

uis.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Loop untuk update laser
spawn(function()
    while true do
        if settings.laserActive and settings.laserTarget then
            updateLaser()
        else
            stopLaser()
        end
        wait(0.1)
    end
end)

print("✅ RMAX EXTREME LOADED | Tekan Insert | Mode GORE AKTIF")
