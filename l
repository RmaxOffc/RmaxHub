-- RMAX HUB - UNIVERSAL (EXTREME EDITION)
-- Stabil + Detector + Rusuh (Grief)
-- Berdasarkan script user yang sudah work, tanpa mengubah struktur asli

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

-- ========== SETTINGS (Asli + Tambahan Rusuh & Detector) ==========
local settings = {
    -- Movement
    walkspeed = 100,
    jumppower = 50,
    infinitejump = false,
    airspeed = 200,
    fly = false,
    -- Combat
    godmode = false,
    killaura = false,
    killaurarange = 30,
    aimbot = false,
    autofarm = false,
    -- Rusuh (Grief)
    laser = false,
    laserTarget = nil,
    laserDamage = 15,
    laserTurret = false,
    laserTurretRange = 100,
    freeze = false,
    freezeTarget = nil,
    blind = false,
    blindTarget = nil,
    crash = false,
    crashTarget = nil,
    remoteSpam = false,
    remoteSpamTarget = nil,
    forceKick = false,
    forceKickTarget = nil,
    -- Detector
    detector = false,
    autoBreach = false,
}

-- ========== SAVED COORDINATES ==========
local savedCoords = {}
local function saveCoord(slot, pos)
    savedCoords[slot] = {X = pos.X, Y = pos.Y, Z = pos.Z}
end
local function getCoord(slot)
    return savedCoords[slot]
end

-- ========== FLY SYSTEM (Asli - sudah work) ==========
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
        -- Gamepad support (opsional)
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

-- ========== TELEPORT FUNCTIONS (Asli) ==========
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

-- ========== FITUR RUSUH (GRIEF) ==========
-- Laser (Follow & Damage)
local laserBeam = nil
local laserThread = nil
local function stopLaser()
    if laserBeam then laserBeam:Destroy(); laserBeam = nil end
    if laserThread then coroutine.close(laserThread); laserThread = nil end
end
local function laserDamageLoop()
    while settings.laser and settings.laserTarget and settings.laserTarget.Character and settings.laserTarget.Character:FindFirstChild("Humanoid") do
        local hum = settings.laserTarget.Character.Humanoid
        hum.Health = hum.Health - settings.laserDamage
        wait(0.2)
        if hum.Health <= 0 then break end
    end
    stopLaser()
end
spawn(function()
    while true do
        if settings.laser and settings.laserTarget and settings.laserTarget.Character then
            local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local tarRoot = settings.laserTarget.Character:FindFirstChild("HumanoidRootPart")
            if myRoot and tarRoot then
                if not laserBeam then
                    laserBeam = Instance.new("Part")
                    laserBeam.Size = Vector3.new(0.2,0.2,1)
                    laserBeam.Material = Enum.Material.Neon
                    laserBeam.BrickColor = BrickColor.new("Bright red")
                    laserBeam.Anchored = true
                    laserBeam.CanCollide = false
                    laserBeam.Parent = workspace
                end
                local dist = (tarRoot.Position - myRoot.Position).Magnitude
                laserBeam.Size = Vector3.new(0.2,0.2,dist)
                laserBeam.CFrame = CFrame.new(myRoot.Position, tarRoot.Position) * CFrame.new(0,0,-dist/2)
                if not laserThread then
                    laserThread = coroutine.create(laserDamageLoop)
                    coroutine.resume(laserThread)
                end
            end
        else
            stopLaser()
        end
        wait(0.1)
    end
end)

-- Laser Turret (Auto attack semua pemain di radius)
local turretThread = nil
local function turretLoop()
    while settings.laserTurret do
        local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            for _, plr in ipairs(game.Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local tarRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                    if tarRoot and (tarRoot.Position - myRoot.Position).Magnitude <= settings.laserTurretRange then
                        plr.Character.Humanoid.Health = plr.Character.Humanoid.Health - 5
                        local beam = Instance.new("Part")
                        beam.Size = Vector3.new(0.2,0.2,1)
                        beam.Material = Enum.Material.Neon
                        beam.BrickColor = BrickColor.new("Bright orange")
                        beam.Anchored = true
                        beam.CanCollide = false
                        beam.Parent = workspace
                        local dist = (tarRoot.Position - myRoot.Position).Magnitude
                        beam.Size = Vector3.new(0.2,0.2,dist)
                        beam.CFrame = CFrame.new(myRoot.Position, tarRoot.Position) * CFrame.new(0,0,-dist/2)
                        game:GetService("Debris"):AddItem(beam, 0.1)
                    end
                end
            end
        end
        wait(0.3)
    end
end

-- Freeze Player (WalkSpeed 0)
local freezeConn = nil
local function freezePlayer(plr)
    if not plr or not plr.Character then return end
    local hum = plr.Character:FindFirstChild("Humanoid")
    if not hum then return end
    local origSpeed = hum.WalkSpeed
    local origJump = hum.JumpPower
    if freezeConn then freezeConn:Disconnect() end
    freezeConn = runService.Heartbeat:Connect(function()
        if not settings.freeze or settings.freezeTarget ~= plr or not plr.Character then
            if freezeConn then freezeConn:Disconnect(); freezeConn = nil end
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.WalkSpeed = origSpeed
                plr.Character.Humanoid.JumpPower = origJump
            end
            return
        end
        local h = plr.Character:FindFirstChild("Humanoid")
        if h then
            h.WalkSpeed = 0
            h.JumpPower = 0
        end
    end)
end

-- Blind (Flash berulang)
local blindThread = nil
local function blindLoop(plr)
    while settings.blind and settings.blindTarget == plr and plr.Character do
        local head = plr.Character:FindFirstChild("Head")
        if head then
            local flash = Instance.new("Part")
            flash.Size = Vector3.new(8,8,8)
            flash.CFrame = head.CFrame
            flash.Material = Enum.Material.Neon
            flash.BrickColor = BrickColor.new("White")
            flash.Anchored = true
            flash.CanCollide = false
            flash.Parent = workspace
            game:GetService("Debris"):AddItem(flash, 0.1)
        end
        wait(0.2)
    end
end

-- Crash (Overload partikel & suara)
local crashThreads = {}
local function crashLoop(plr)
    while settings.crash and settings.crashTarget == plr and plr.Character do
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if root then
            for i=1,30 do
                local p = Instance.new("Part")
                p.Size = Vector3.new(1,1,1)
                p.CFrame = root.CFrame * CFrame.new(math.random(-15,15), math.random(-5,15), math.random(-15,15))
                p.Anchored = true
                p.CanCollide = false
                p.Material = Enum.Material.Neon
                p.BrickColor = BrickColor.random()
                p.Parent = workspace
                game:GetService("Debris"):AddItem(p, 0.5)
            end
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://912038123"
            s.Volume = 1
            s.Parent = root
            s:Play()
            game:GetService("Debris"):AddItem(s, 1)
        end
        wait(0.6)
    end
end

-- Remote Spam (Flood remote event ke target)
local remoteSpamThread = nil
local function remoteSpamLoop(plr)
    while settings.remoteSpam and settings.remoteSpamTarget == plr do
        for _, rem in ipairs(game:GetDescendants()) do
            if rem:IsA("RemoteEvent") then
                pcall(function() rem:FireServer(plr, "spam", math.random(1e6)) end)
            elseif rem:IsA("RemoteFunction") then
                pcall(function() rem:InvokeServer(plr, "spam") end)
            end
        end
        wait(0.1)
    end
end

-- Force Kick (coba kick target melalui remote)
local function forceKickPlayer(plr)
    for _, rem in ipairs(game:GetDescendants()) do
        if rem:IsA("RemoteEvent") and (rem.Name:lower():find("kick") or rem.Name:lower():find("ban")) then
            pcall(function() rem:FireServer(plr) end)
        end
    end
end

-- ========== DETECTOR REAL-TIME (Scan vulnerabilities) ==========
local detectorLog = {}
local function addDetectLog(msg)
    table.insert(detectorLog, 1, os.date("%H:%M:%S") .. " | " .. msg)
    if #detectorLog > 15 then table.remove(detectorLog) end
end

local function scanVulnerabilities()
    addDetectLog("[SCAN] Scanning remotes & admin scripts...")
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local success, err = pcall(function()
                if obj:IsA("RemoteEvent") then
                    obj:FireServer("__test")
                else
                    obj:InvokeServer("__test")
                end
            end)
            if not success and string.find(err or "", "not allowed") then
                -- aman
            else
                addDetectLog("[!] VULN REMOTE: " .. obj:GetFullName())
                if settings.autoBreach then
                    pcall(function() obj:Destroy() end)
                    addDetectLog("[BREACH] Remote destroyed")
                end
            end
        end
        if obj:IsA("Script") and (obj.Name:lower():find("admin") or obj.Name:lower():find("anticheat")) then
            addDetectLog("[*] ADMIN SCRIPT: " .. obj:GetFullName())
            if settings.autoBreach then
                pcall(function() obj.Disabled = true end)
                addDetectLog("[BREACH] Admin script disabled")
            end
        end
        if obj:IsA("BoolValue") and obj.Name:lower():find("exploit") then
            addDetectLog("[!] ANTI-CHEAT FLAG: " .. obj:GetFullName())
        end
    end
end

spawn(function()
    while true do
        if settings.detector then
            scanVulnerabilities()
        end
        wait(8)
    end
end)

-- ========== UI (SAMA PERSIS DENGAN SCRIPT USER, HANYA DITAMBAH KATEGORI RUSUH & DETECTOR) ==========
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
titleText.Text = "🔥 RMAX HUB 🔥 (EXTREME)"
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

-- Helper: createCategory (sama persis)
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

-- Helper UI elements (sama persis)
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
    valLabel.Size = UDim2.new(0.2, 0, 1, 0)
    valLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = Color3.fromRGB(0,255,255)
    valLabel.BackgroundTransparency = 1
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 15
    valLabel.Parent = frame
    
    local dec = Instance.new("TextButton")
    dec.Size = UDim2.new(0, 34, 0, 30)
    dec.Position = UDim2.new(0.75, 0, 0, 9)
    dec.Text = "-"
    dec.TextColor3 = Color3.new(1,1,1)
    dec.BackgroundColor3 = Color3.fromRGB(60,60,80)
    dec.Font = Enum.Font.GothamBold
    dec.TextSize = 18
    local decCorner = Instance.new("UICorner")
    decCorner.CornerRadius = UDim.new(0, 6)
    decCorner.Parent = dec
    dec.Parent = frame
    
    local inc = Instance.new("TextButton")
    inc.Size = UDim2.new(0, 34, 0, 30)
    inc.Position = UDim2.new(0.85, 0, 0, 9)
    inc.Text = "+"
    inc.TextColor3 = Color3.new(1,1,1)
    inc.BackgroundColor3 = Color3.fromRGB(60,60,80)
    inc.Font = Enum.Font.GothamBold
    inc.TextSize = 18
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

local function addButton(parent, icon, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 36)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Text = icon .. " " .. text
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    btn.Parent = frame
    btn.MouseButton1Click:Connect(callback)
    return frame
end

local function addDropdown(parent, icon, text, items, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 36)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = icon .. " " .. text
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Parent = frame
    local drop = Instance.new("TextButton")
    drop.Size = UDim2.new(0.4, 0, 0, 28)
    drop.Position = UDim2.new(0.55, 0, 0, 4)
    drop.Text = items[1] or "None"
    drop.BackgroundColor3 = Color3.fromRGB(60,60,80)
    drop.TextColor3 = Color3.new(1,1,1)
    drop.Font = Enum.Font.Gotham
    drop.TextSize = 12
    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 4)
    dropCorner.Parent = drop
    drop.Parent = frame
    local current = items[1]
    drop.MouseButton1Click:Connect(function()
        local idx = table.find(items, current)
        idx = idx and (idx % #items) + 1 or 1
        current = items[idx]
        drop.Text = current
        callback(current)
    end)
    return frame
end

-- ========== BUAT KATEGORI (Asli + Tambahan) ==========
local movementCat = createCategory("🦶", "MOVEMENT", true)
local combatCat = createCategory("⚔️", "COMBAT", false)
local utilityCat = createCategory("🔧", "UTILITY", false)
local teleportCat = createCategory("📍", "TELEPORT & SAVES", false)
local playerCat = createCategory("👥", "PLAYERS", false)
-- KATEGORI BARU (RUSUH & DETECTOR)
local griefCat = createCategory("💀", "RUSUH / GRIEF", true)
local detectCat = createCategory("🔍", "DETECTOR & BREACH", false)

-- Movement (Asli)
addToggle(movementCat.content, "🪶", "Fly (WASD)", settings.fly, function(v) settings.fly = v; if v then startFly() else stopFly() end end)
addStepper(movementCat.content, "🏃", "Walk Speed", 16, 500, settings.walkspeed, 10, function(v) settings.walkspeed = v; updateChar() end)
addStepper(movementCat.content, "🦘", "Jump Power", 30, 200, settings.jumppower, 10, function(v) settings.jumppower = v; updateChar() end)
addToggle(movementCat.content, "♾️", "Infinite Jump", settings.infinitejump, function(v) settings.infinitejump = v; updateChar() end)
addStepper(movementCat.content, "🚀", "Air Speed", 16, 500, settings.airspeed, 10, function(v) settings.airspeed = v; updateChar() end)

-- Combat (Asli)
addToggle(combatCat.content, "🛡️", "God Mode", settings.godmode, function(v) settings.godmode = v; if v then applyGodMode() end end)
addToggle(combatCat.content, "⚔️", "Kill Aura", settings.killaura, function(v) settings.killaura = v end)
addStepper(combatCat.content, "📏", "Kill Aura Range", 10, 100, settings.killaurarange, 10, function(v) settings.killaurarange = v end)
addToggle(combatCat.content, "🎯", "Aimbot", settings.aimbot, function(v) settings.aimbot = v end)

-- Utility (Asli)
addToggle(utilityCat.content, "🤖", "Auto Farm (Coin/Gem)", settings.autofarm, function(v) settings.autofarm = v; if v then startFarm() else stopFarm() end end)

-- ========== KATEGORI RUSUH (GRIEF) ==========
addToggle(griefCat.content, "🔴", "Laser (Follow Target)", settings.laser, function(v) settings.laser = v; if not v then stopLaser() end end)
addDropdown(griefCat.content, "🎯", "Laser Target", game.Players:GetChildren(), function(sel)
    for _,p in ipairs(game.Players:GetPlayers()) do if p.Name == sel then settings.laserTarget = p end end
end)
addButton(griefCat.content, "💥", "Laser Damage +5", function() settings.laserDamage = math.min(100, settings.laserDamage+5) end)

addToggle(griefCat.content, "🤖", "Laser Turret (Auto)", settings.laserTurret, function(v)
    settings.laserTurret = v
    if v then
        if turretThread then coroutine.close(turretThread) end
        turretThread = coroutine.create(turretLoop)
        coroutine.resume(turretThread)
    else
        if turretThread then coroutine.close(turretThread); turretThread = nil end
    end
end)
addButton(griefCat.content, "📏", "Turret Range +10", function() settings.laserTurretRange = math.min(200, settings.laserTurretRange+10) end)

addToggle(griefCat.content, "❄️", "Freeze Player", settings.freeze, function(v)
    settings.freeze = v
    if v and settings.freezeTarget then freezePlayer(settings.freezeTarget) end
end)
addDropdown(griefCat.content, "❄️", "Freeze Target", game.Players:GetChildren(), function(sel)
    for _,p in ipairs(game.Players:GetPlayers()) do if p.Name == sel then settings.freezeTarget = p; if settings.freeze then freezePlayer(p) end end end
end)

addToggle(griefCat.content, "👁️", "Blind (Flash)", settings.blind, function(v)
    settings.blind = v
    if v and settings.blindTarget then
        if blindThread then coroutine.close(blindThread) end
        blindThread = coroutine.create(blindLoop)
        coroutine.resume(blindThread, settings.blindTarget)
    end
end)
addDropdown(griefCat.content, "👁️", "Blind Target", game.Players:GetChildren(), function(sel)
    for _,p in ipairs(game.Players:GetPlayers()) do if p.Name == sel then settings.blindTarget = p end end
end)

addToggle(griefCat.content, "💣", "Crash Player (Lag)", settings.crash, function(v)
    settings.crash = v
    if v and settings.crashTarget then
        local th = coroutine.create(crashLoop)
        coroutine.resume(th, settings.crashTarget)
        crashThreads[settings.crashTarget] = th
    end
end)
addDropdown(griefCat.content, "💣", "Crash Target", game.Players:GetChildren(), function(sel)
    for _,p in ipairs(game.Players:GetPlayers()) do if p.Name == sel then settings.crashTarget = p end end
end)

addToggle(griefCat.content, "📡", "Remote Spam (Flood)", settings.remoteSpam, function(v)
    settings.remoteSpam = v
    if v and settings.remoteSpamTarget then
        if remoteSpamThread then coroutine.close(remoteSpamThread) end
        remoteSpamThread = coroutine.create(remoteSpamLoop)
        coroutine.resume(remoteSpamThread, settings.remoteSpamTarget)
    end
end)
addDropdown(griefCat.content, "📡", "Spam Target", game.Players:GetChildren(), function(sel)
    for _,p in ipairs(game.Players:GetPlayers()) do if p.Name == sel then settings.remoteSpamTarget = p end end
end)

addButton(griefCat.content, "👢", "Force Kick (Attempt)", function()
    if settings.forceKickTarget then forceKickPlayer(settings.forceKickTarget) end
end)
addDropdown(griefCat.content, "👢", "Kick Target", game.Players:GetChildren(), function(sel)
    for _,p in ipairs(game.Players:GetPlayers()) do if p.Name == sel then settings.forceKickTarget = p end end
end)

-- ========== KATEGORI DETECTOR ==========
addToggle(detectCat.content, "🕵️", "Real-time Detector", settings.detector, function(v) settings.detector = v end)
addToggle(detectCat.content, "💣", "Auto Breach (Destroy)", settings.autoBreach, function(v) settings.autoBreach = v end)
addButton(detectCat.content, "🔍", "Scan Now", function() scanVulnerabilities() end)

-- Log frame untuk detector
local logFrame = Instance.new("Frame")
logFrame.Size = UDim2.new(1, -10, 0, 100)
logFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
logFrame.BackgroundTransparency = 0.6
logFrame.Parent = detectCat.content
local logCorner = Instance.new("UICorner")
logCorner.CornerRadius = UDim.new(0, 6)
logCorner.Parent = logFrame
local logText = Instance.new("TextLabel")
logText.Size = UDim2.new(1, 0, 1, 0)
logText.BackgroundTransparency = 1
logText.Text = "Log will appear here"
logText.TextColor3 = Color3.fromRGB(0,255,0)
logText.TextWrapped = true
logText.TextXAlignment = Enum.TextXAlignment.Left
logText.TextYAlignment = Enum.TextYAlignment.Top
logText.Font = Enum.Font.Code
logText.TextSize = 10
logText.Parent = logFrame
spawn(function()
    while true do
        logText.Text = table.concat(detectorLog, "\n")
        wait(0.3)
    end
end)

-- ========== TELEPORT & SAVES (Asli, tidak diubah) ==========
local posFrame = Instance.new("Frame")
posFrame.Size = UDim2.new(1, -10, 0, 55)
posFrame.BackgroundTransparency = 1
posFrame.Parent = teleportCat.content

local coordText = Instance.new("TextLabel")
coordText.Size = UDim2.new(1, 0, 0, 25)
coordText.Text = "📍 Current: X:0 Y:0 Z:0"
coordText.TextColor3 = Color3.new(1,1,1)
coordText.BackgroundTransparency = 1
coordText.Font = Enum.Font.Gotham
coordText.TextSize = 12
coordText.Parent = posFrame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(1, 0, 0, 25)
copyBtn.Position = UDim2.new(0, 0, 0, 28)
copyBtn.Text = "📋 Copy Position"
copyBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
copyBtn.TextColor3 = Color3.new(1,1,1)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 12
local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 6)
copyCorner.Parent = copyBtn
copyBtn.Parent = posFrame

spawn(function()
    while true do
        wait(0.1)
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            coordText.Text = string.format("📍 Current: X:%.1f Y:%.1f Z:%.1f", pos.X, pos.Y, pos.Z)
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
        copyBtn.Text = "📋 Copy Position"
    end
end)

for i = 1, 5 do
    local slotFrame = Instance.new("Frame")
    slotFrame.Size = UDim2.new(1, -10, 0, 32)
    slotFrame.BackgroundTransparency = 1
    slotFrame.Parent = teleportCat.content
    
    local slotLabel = Instance.new("TextLabel")
    slotLabel.Size = UDim2.new(0.2, 0, 1, 0)
    slotLabel.Text = "Slot " .. i
    slotLabel.TextColor3 = Color3.fromRGB(200,200,200)
    slotLabel.BackgroundTransparency = 1
    slotLabel.Font = Enum.Font.Gotham
    slotLabel.TextSize = 12
    slotLabel.Parent = slotFrame
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0, 55, 0, 24)
    saveBtn.Position = UDim2.new(0.25, 0, 0, 4)
    saveBtn.Text = "💾 Save"
    saveBtn.BackgroundColor3 = Color3.fromRGB(60,100,60)
    saveBtn.TextColor3 = Color3.new(1,1,1)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 11
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 4)
    saveCorner.Parent = saveBtn
    saveBtn.Parent = slotFrame
    
    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0, 55, 0, 24)
    tpBtn.Position = UDim2.new(0.55, 0, 0, 4)
    tpBtn.Text = "✨ TP"
    tpBtn.BackgroundColor3 = Color3.fromRGB(60,60,100)
    tpBtn.TextColor3 = Color3.new(1,1,1)
    tpBtn.Font = Enum.Font.GothamBold
    tpBtn.TextSize = 11
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
    statusLabel.TextSize = 10
    statusLabel.Parent = slotFrame
    
    saveBtn.MouseButton1Click:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            saveCoord(i, pos)
            statusLabel.Text = string.format("%.0f,%.0f,%.0f", pos.X, pos.Y, pos.Z)
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

-- ========== PLAYER LIST (Asli, sudah work) ==========
local playerListScroll = Instance.new("ScrollingFrame")
playerListScroll.Size = UDim2.new(1, -10, 0, 130)
playerListScroll.BackgroundTransparency = 1
playerListScroll.BorderSizePixel = 0
playerListScroll.ScrollBarThickness = 4
playerListScroll.Parent = playerCat.content

local playerListContainer = Instance.new("Frame")
playerListContainer.Size = UDim2.new(1, 0, 0, 0)
playerListContainer.BackgroundTransparency = 1
playerListContainer.Parent = playerListScroll

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Padding = UDim.new(0, 4)
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Parent = playerListContainer

local function updatePlayerList()
    for _, child in ipairs(playerListContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 32)
            row.BackgroundTransparency = 1
            row.Parent = playerListContainer
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.45, 0, 1, 0)
            nameLabel.Text = plr.Name
            nameLabel.TextColor3 = Color3.new(1,1,1)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextSize = 12
            nameLabel.Parent = row
            
            local tpBtn = Instance.new("TextButton")
            tpBtn.Size = UDim2.new(0, 65, 0, 26)
            tpBtn.Position = UDim2.new(0.5, 0, 0, 3)
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
            bringBtn.Size = UDim2.new(0, 65, 0, 26)
            bringBtn.Position = UDim2.new(0.75, 0, 0, 3)
            bringBtn.Text = "📦 Bring"
            bringBtn.BackgroundColor3 = Color3.fromRGB(120,60,60)
            bringBtn.TextColor3 = Color3.new(1,1,1)
            bringBtn.Font = Enum.Font.GothamBold
            bringBtn.TextSize = 11
            local bringCorner = Instance.new("UICorner")
            bringCorner.CornerRadius = UDim.new(0, 4)
            bringCorner.Parent = bringBtn
            bringBtn.Parent = row
            
            tpBtn.MouseButton1Click:Connect(function()
                teleportToPlayer(plr)
            end)
            bringBtn.MouseButton1Click:Connect(function()
                bringPlayer(plr)
            end)
        end
    end
    
    local totalHeight = 0
    for _, child in ipairs(playerListContainer:GetChildren()) do
        if child:IsA("Frame") then
            totalHeight = totalHeight + child.Size.Y.Offset + playerListLayout.Padding.Offset
        end
    end
    playerListContainer.Size = UDim2.new(1, 0, 0, totalHeight)
    playerListScroll.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
    playerCat.updateHeight()
end

spawn(function()
    updatePlayerList()
    while true do
        wait(1)
        updatePlayerList()
    end
end)

-- ========== AUTO CP CATEGORY (Asli) ==========
if isHuaa or isValthera then
    local cpCat = createCategory("🏁", "AUTO CP - " .. currentMap, true)
    
    addButton(cpCat.content, "🏠", "TP to Lobby/Start", function()
        goToLobby()
    end)
    
    addButton(cpCat.content, "⏩", "Next CP (Manual)", function()
        local nextIdx = currentCpIndex % #cpList + 1
        teleportToCp(nextIdx)
    end)
    
    local autoFrame = Instance.new("Frame")
    autoFrame.Size = UDim2.new(1, -10, 0, 36)
    autoFrame.BackgroundTransparency = 1
    autoFrame.Parent = cpCat.content
    
    local autoBtn = Instance.new("TextButton")
    autoBtn.Size = UDim2.new(0.48, 0, 0, 30)
    autoBtn.Text = "▶ Auto Loop"
    autoBtn.BackgroundColor3 = Color3.fromRGB(60,100,60)
    autoBtn.TextColor3 = Color3.new(1,1,1)
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.TextSize = 12
    local autoCorner = Instance.new("UICorner")
    autoCorner.CornerRadius = UDim.new(0, 6)
    autoCorner.Parent = autoBtn
    autoBtn.Parent = autoFrame
    
    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0.48, 0, 0, 30)
    stopBtn.Position = UDim2.new(0.52, 0, 0, 0)
    stopBtn.Text = "⏹ Stop"
    stopBtn.BackgroundColor3 = Color3.fromRGB(120,60,60)
    stopBtn.TextColor3 = Color3.new(1,1,1)
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.TextSize = 12
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 6)
    stopCorner.Parent = stopBtn
    stopBtn.Visible = false
    stopBtn.Parent = autoFrame
    
    autoBtn.MouseButton1Click:Connect(function()
        if autoRunning then return end
        autoBtn.Visible = false
        stopBtn.Visible = true
        startAutoCp(2)
    end)
    
    stopBtn.MouseButton1Click:Connect(function()
        stopAutoCp()
        autoBtn.Visible = true
        stopBtn.Visible = false
    end)
    
    local cpListFrame = Instance.new("Frame")
    cpListFrame.Size = UDim2.new(1, -10, 0, 140)
    cpListFrame.BackgroundTransparency = 1
    cpListFrame.Parent = cpCat.content
    
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
    cpLayout.Padding = UDim.new(0, 3)
    cpLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cpLayout.Parent = cpContainer
    
    for _, cp in ipairs(cpList) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 28)
        row.BackgroundTransparency = 1
        row.Parent = cpContainer
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.25, 0, 1, 0)
        label.Text = "CP " .. cp.index
        label.TextColor3 = Color3.new(1,1,1)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.Parent = row
        
        local tpCpBtn = Instance.new("TextButton")
        tpCpBtn.Size = UDim2.new(0, 70, 0, 22)
        tpCpBtn.Position = UDim2.new(0.35, 0, 0, 3)
        tpCpBtn.Text = "📍 TP"
        tpCpBtn.BackgroundColor3 = Color3.fromRGB(60,80,120)
        tpCpBtn.TextColor3 = Color3.new(1,1,1)
        tpCpBtn.Font = Enum.Font.GothamBold
        tpCpBtn.TextSize = 11
        local tpCorner = Instance.new("UICorner")
        tpCorner.CornerRadius = UDim.new(0, 4)
        tpCorner.Parent = tpCpBtn
        tpCpBtn.Parent = row
        
        local coordLabel = Instance.new("TextLabel")
        coordLabel.Size = UDim2.new(0.4, 0, 1, 0)
        coordLabel.Position = UDim2.new(0.6, 0, 0, 0)
        coordLabel.Text = string.format("%.0f,%.0f,%.0f", cp.pos.X, cp.pos.Y, cp.pos.Z)
        coordLabel.TextColor3 = Color3.fromRGB(150,150,150)
        coordLabel.BackgroundTransparency = 1
        coordLabel.Font = Enum.Font.Gotham
        coordLabel.TextSize = 9
        coordLabel.Parent = row
        
        tpCpBtn.MouseButton1Click:Connect(function()
            teleportToCp(cp.index)
        end)
    end
    
    local function updateCpScroll()
        local total = 0
        for _, child in ipairs(cpContainer:GetChildren()) do
            if child:IsA("Frame") then
                total = total + child.Size.Y.Offset + cpLayout.Padding.Offset
            end
        end
        cpContainer.Size = UDim2.new(1, 0, 0, total)
        cpScroll.CanvasSize = UDim2.new(0, 0, 0, total + 10)
        cpListFrame.Size = UDim2.new(1, -10, 0, math.min(160, total + 20))
        cpCat.updateHeight()
    end
    cpLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCpScroll)
    wait(0.1)
    updateCpScroll()
end

-- Update akhir semua kategori
wait(0.2)
movementCat.updateHeight()
combatCat.updateHeight()
utilityCat.updateHeight()
teleportCat.updateHeight()
playerCat.updateHeight()
griefCat.updateHeight()
detectCat.updateHeight()
updateMainScroll()

-- Draggable (Asli)
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

-- Minimize (Asli)
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        scroll.Visible = false
        mainFrame:TweenSize(UDim2.new(0, 450, 0, 40), "Out", "Quad", 0.2, true)
    else
        mainFrame:TweenSize(UDim2.new(0, 450, 0, 600), "Out", "Quad", 0.2, true)
        wait(0.2)
        scroll.Visible = true
        updateMainScroll()
    end
end)

-- Show/hide Insert (Asli)
uis.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

print("✅ RMAX HUB EXTREME - Map: " .. currentMap .. " - Insert to toggle | All features stable")
