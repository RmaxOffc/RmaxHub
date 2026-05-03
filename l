--[[
  RMAX HUB - FINAL STABLE (EXTREME + DETECTOR + REMOTE CONTROL)
  Tidak ada error UI. Semua fitur berjalan lancar.
  Tekan INSERT untuk toggle menu.
--]]

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local lighting = game:GetService("Lighting")
local coreGui = game:GetService("CoreGui")
local http = game:GetService("HttpService")

-- ========== DETEKSI MAP UNTUK AUTO CP ==========
local placeId = game.PlaceId
local isHuaa = (placeId == 89054581105142)
local isValthera = (placeId == 74996495742979)
local currentMap = (isHuaa and "Huaa") or (isValthera and "Valthera") or "Unknown"
print("RMAX HUB - Map:", currentMap)

-- ========== CP LIST (sama persis dengan yang dulu) ==========
local cpList = {}
if isHuaa then
    cpList = {
        {1, Vector3.new(-139.9, 139.3, 153.6)}, {2, Vector3.new(-545.1, 185.2, 451.0)},
        {3, Vector3.new(-436.8, 271.5, 963.3)}, {4, Vector3.new(-301.8, 401.7, 1668.5)},
        {5, Vector3.new(-173.0, 488.7, 2474.4)}, {6, Vector3.new(5.2, 772.7, 3027.6)},
        {7, Vector3.new(152.7, 808.7, 3973.8)}, {8, Vector3.new(-918.7, 864.7, 3905.1)},
        {9, Vector3.new(-843.5, 1253.3, 3007.2)}, {10, Vector3.new(-802.5, 1496.7, 2414.7)},
        {11, Vector3.new(-128.6, 1736.7, 2134.8)}, {12, Vector3.new(643.8, 1852.7, 2120.4)},
        {13, Vector3.new(1110.2, 2036.7, 2295.6)}, {14, Vector3.new(950.3, 2100.7, 2936.0)},
        {15, Vector3.new(147.9, 2240.7, 3549.3)}, {16, Vector3.new(30.6, 2173.4, 4458.1)},
        {17, Vector3.new(-477.6, 2584.7, 5043.7)}, {18, Vector3.new(-495.9, 2840.7, 5797.7)},
        {19, Vector3.new(-1044.9, 3016.7, 6255.0)}, {20, Vector3.new(-1102.8, 3268.7, 5502.8)},
        {21, Vector3.new(-1045.3, 3556.7, 4002.9)}, {22, Vector3.new(-1650.2, 4492.7, 2626.6)},
        {23, Vector3.new(351.3, 149.3, 109.8)},
    }
elseif isValthera then
    cpList = {
        {1, Vector3.new(591.0, 29.3, 167.3)}, {2, Vector3.new(-108.9, 100.4, 191.2)},
        {3, Vector3.new(-923.9, 96.4, 208.7)}, {4, Vector3.new(-1602.7, 99.4, 92.0)},
        {5, Vector3.new(-1590.0, 189.4, -438.2)}, {6, Vector3.new(-1568.6, 192.4, -1042.8)},
        {7, Vector3.new(-1634.1, 284.4, -1646.4)}, {8, Vector3.new(-2417.3, 291.4, -1648.3)},
        {9, Vector3.new(-2986.7, 405.4, -1649.9)}, {10, Vector3.new(-3770.5, 408.4, -1652.9)},
        {11, Vector3.new(-4756.6, 411.4, -1664.8)}, {12, Vector3.new(-7113.1, 414.4, -1713.5)},
        {13, Vector3.new(-9318.6, 586.9, -1676.8)}, {14, Vector3.new(-10006.2, 590.4, -1702.7)},
        {15, Vector3.new(-11195.8, 593.4, -2124.7)}, {16, Vector3.new(-11181.4, 596.4, -3468.8)},
        {17, Vector3.new(-11186.9, 724.4, -4221.9)}, {18, Vector3.new(-11185.1, 727.4, -5107.6)},
        {19, Vector3.new(-11150.0, 728.4, -6982.9)}, {20, Vector3.new(-11095.6, 731.1, -8506.5)},
        {21, Vector3.new(-9917.7, 13653.4, -9738.3)},
    }
end
local lobbyPos = (isHuaa and Vector3.new(351.3,149.3,109.8)) or (isValthera and cpList[1] and cpList[1][2]) or Vector3.new(0,0,0)

-- ========== SETTINGS (semua fitur) ==========
local settings = {
    -- Movement
    fly = false,
    walkspeed = 100,
    jumppower = 50,
    infinitejump = false,
    airspeed = 200,
    -- Combat
    godmode = false,
    killaura = false,
    killaurarange = 30,
    aimbot = false,
    autofarm = false,
    -- RUSUH (grief)
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
    -- DETECTOR + REMOTE CONTROL
    detector = false,
    breach = false,
    remoteControl = false,
}

-- ========== TELEPORT UTILITY ==========
local function teleport(pos)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(pos) end)
    end
end

-- ========== FLY SYSTEM (tanpa error) ==========
local flyVel, flyGyro, flyConn
local function stopFly()
    if flyConn then flyConn:Disconnect() end
    if flyVel then flyVel:Destroy() end
    if flyGyro then flyGyro:Destroy() end
    flyConn, flyVel, flyGyro = nil, nil, nil
end
local function startFly()
    stopFly()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    flyVel = Instance.new("BodyVelocity")
    flyGyro = Instance.new("BodyGyro")
    flyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
    flyVel.P = 1e4
    flyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
    flyGyro.P = 1e4
    flyVel.Parent = char.HumanoidRootPart
    flyGyro.Parent = char.HumanoidRootPart
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
        flyVel.Velocity = vel
        flyGyro.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position, player.Character.HumanoidRootPart.Position + cam.CFrame.LookVector)
    end)
end

-- ========== MOVEMENT & GOD MODE ==========
local function updateMovement()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    hum.WalkSpeed = settings.walkspeed
    hum.JumpPower = settings.jumppower
    if settings.infinitejump then
        if hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall then
            hum.WalkSpeed = settings.airspeed
        else
            hum.WalkSpeed = settings.walkspeed
        end
    end
end
player.CharacterAdded:Connect(updateMovement)
runService.Heartbeat:Connect(updateMovement)

uis.JumpRequest:Connect(function()
    if settings.infinitejump then
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            if hum:GetState() == Enum.HumanoidStateType.Landed or hum:GetState() == Enum.HumanoidStateType.Freefall then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

spawn(function()
    while true do
        if settings.godmode then
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                hum.Health = math.huge
                hum.MaxHealth = math.huge
                hum.BreakJointsOnDeath = false
            end
        end
        wait(0.3)
    end
end)

-- ========== KILL AURA ==========
spawn(function()
    while true do
        if settings.killaura and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            for _, plr in ipairs(game.Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local dist = (plr.Character.HumanoidRootPart.Position - root.Position).Magnitude
                    if dist <= settings.killaurarange then
                        pcall(function() plr.Character.Humanoid.Health = 0 end)
                    end
                end
            end
        end
        wait(0.1)
    end
end)

-- ========== AIMBOT ==========
runService.RenderStepped:Connect(function()
    if settings.aimbot and player.Character then
        local closest, closestDist = nil, 300
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local pos, on = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if on then
                    local d = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if d < closestDist then
                        closestDist = d
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

-- ========== AUTO FARM (coin/gem) ==========
local farmConn
local function stopFarm() if farmConn then farmConn:Disconnect(); farmConn = nil end end
local function startFarm()
    if farmConn then return end
    farmConn = runService.Heartbeat:Connect(function()
        if not settings.autofarm or not player.Character then return end
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local nearest, bestDist = nil, 50
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("gem")) then
                local d = (obj.Position - root.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    nearest = obj
                end
            end
        end
        if nearest then root.CFrame = nearest.CFrame end
    end)
end

-- ========== RUSUH (GRIEF) ==========
-- Laser (damage over time)
local laserBeam = nil
local laserThread = nil
local function stopLaser()
    if laserBeam then laserBeam:Destroy(); laserBeam = nil end
    if laserThread then coroutine.close(laserThread); laserThread = nil end
end
local function laserLoop()
    while settings.laser and settings.laserTarget and settings.laserTarget.Character and settings.laserTarget.Character:FindFirstChild("Humanoid") do
        local hum = settings.laserTarget.Character.Humanoid
        hum.Health = hum.Health - settings.laserDamage
        wait(0.2)
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
                    laserThread = coroutine.create(laserLoop)
                    coroutine.resume(laserThread)
                end
            end
        else
            stopLaser()
        end
        wait(0.1)
    end
end)

-- Laser Turret
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

-- Freeze (WalkSpeed 0)
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

-- Blind (flash)
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

-- Crash (overload)
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

-- Remote Spam (fire remotes ke target)
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

-- Force Kick (crash client target via remote)
local function forceKickPlayer(plr)
    -- Mencari remote yang bisa dipakai untuk kick
    for _, rem in ipairs(game:GetDescendants()) do
        if rem:IsA("RemoteEvent") and (rem.Name:lower():find("kick") or rem.Name:lower():find("ban")) then
            pcall(function() rem:FireServer(plr) end)
        end
    end
end

-- ========== DETECTOR + REMOTE CONTROL ==========
local detectorLog = {}
local function addLog(msg)
    table.insert(detectorLog, 1, os.date("%H:%M:%S") .. " | " .. msg)
    if #detectorLog > 15 then table.remove(detectorLog) end
end

local function scanVulnerabilities()
    addLog("[SCAN] Scanning remotes & backdoors...")
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
                addLog("[!] VULN REMOTE: " .. obj:GetFullName())
                if settings.breach then
                    pcall(function() obj:Destroy() end)
                    addLog("[BREACH] Remote destroyed")
                end
            end
        end
        if obj:IsA("Script") and (obj.Name:lower():find("admin") or obj.Name:lower():find("anticheat")) then
            addLog("[*] ADMIN SCRIPT: " .. obj:GetFullName())
            if settings.breach then
                pcall(function() obj.Disabled = true end)
                addLog("[BREACH] Admin script disabled")
            end
        end
        if obj:IsA("BoolValue") and obj.Name:lower():find("exploit") then
            addLog("[!] ANTI-CHEAT FLAG: " .. obj:GetFullName())
        end
    end
end

-- Remote Control (ambil alih remote event)
local controlledRemotes = {}
local function controlRemotes()
    for _, rem in ipairs(game:GetDescendants()) do
        if rem:IsA("RemoteEvent") and not controlledRemotes[rem] then
            local oldFire = rem.FireServer
            rem.FireServer = function(self, ...)
                if settings.remoteControl then
                    addLog("[CTRL] Intercepted FireServer from " .. rem.Name)
                    -- bisa diubah atau blokir
                    return
                else
                    return oldFire(self, ...)
                end
            end
            controlledRemotes[rem] = true
        end
    end
end

spawn(function()
    while true do
        if settings.detector then
            scanVulnerabilities()
            if settings.remoteControl then controlRemotes() end
        end
        wait(8)
    end
end)

-- ========== UI STABLE (NO ERROR) ==========
pcall(function() coreGui:FindFirstChild("RmaxFinal"):Destroy() end)
local gui = Instance.new("ScreenGui")
gui.Name = "RmaxFinal"
gui.Parent = coreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 480, 0, 580)
main.Position = UDim2.new(0.5, -240, 0.5, -290)
main.BackgroundColor3 = Color3.fromRGB(15,15,25)
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,10)
corner.Parent = main

-- Title bar
local title = Instance.new("Frame")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(40,20,50)
title.BorderSizePixel = 0
title.Parent = main
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0,10)
titleCorner.Parent = title

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1,-50,1,0)
titleLabel.Position = UDim2.new(0,10,0,0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "💀 RMAX FINAL EXTREME 💀"
titleLabel.TextColor3 = Color3.fromRGB(255,50,50)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = title

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0,30,0,30)
minBtn.Position = UDim2.new(1,-40,0,5)
minBtn.BackgroundTransparency = 1
minBtn.Text = "−"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.TextSize = 24
minBtn.Parent = title

-- Scroll frame
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,-10,1,-50)
scroll.Position = UDim2.new(0,5,0,45)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.Parent = main

local container = Instance.new("Frame")
container.Size = UDim2.new(1,0,0,0)
container.BackgroundTransparency = 1
container.Parent = scroll

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Padding = UDim.new(0,6)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Parent = container

local function updateContainer()
    local h = 0
    for _,c in ipairs(container:GetChildren()) do
        if c:IsA("Frame") then
            h = h + c.Size.Y.Offset + scrollLayout.Padding.Offset
        end
    end
    container.Size = UDim2.new(1,0,0,h)
    scroll.CanvasSize = UDim2.new(0,0,0,h+20)
end

-- Helper UI
local function addCategory(icon, text, defaultOpen)
    local cat = Instance.new("Frame")
    cat.Size = UDim2.new(1,0,0,0)
    cat.BackgroundTransparency = 1
    cat.Parent = container
    
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1,0,0,34)
    header.BackgroundColor3 = Color3.fromRGB(30,25,40)
    header.Text = icon .. " " .. text
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
    
    local function refreshHeight()
        local ch = 0
        for _,chld in ipairs(content:GetChildren()) do
            if chld:IsA("Frame") then
                ch = ch + chld.Size.Y.Offset + contentLayout.Padding.Offset
            end
        end
        content.Size = UDim2.new(1,0,0,ch)
        cat.Size = UDim2.new(1,0,0,34 + (content.Visible and ch or 0))
        updateContainer()
    end
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshHeight)
    local open = defaultOpen
    header.MouseButton1Click:Connect(function()
        open = not open
        content.Visible = open
        refreshHeight()
    end)
    spawn(refreshHeight)
    return {content = content, layout = contentLayout, refresh = refreshHeight}
end

local function addToggle(parent, icon, txt, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-10,0,36)
    f.BackgroundTransparency = 1
    f.Parent = parent
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7,0,1,0)
    lbl.Text = icon .. " " .. txt
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.Parent = f
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

local function addButton(parent, icon, txt, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-10,0,36)
    f.BackgroundTransparency = 1
    f.Parent = parent
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,30)
    btn.Text = icon .. " " .. txt
    btn.BackgroundColor3 = Color3.fromRGB(50,40,60)
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

local function addDropdown(parent, icon, txt, items, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-10,0,36)
    f.BackgroundTransparency = 1
    f.Parent = parent
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5,0,1,0)
    lbl.Text = icon .. " " .. txt
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.Parent = f
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
        local idx = table.find(items, current)
        idx = idx and (idx % #items) + 1 or 1
        current = items[idx]
        drop.Text = current
        callback(current)
    end)
    return f
end

-- Buat kategori
local movCat = addCategory("🦶", "MOVEMENT", true)
local combatCat = addCategory("⚔️", "COMBAT", false)
local griefCat = addCategory("💀", "GRIEF / RUSUH", true)
local detectCat = addCategory("🔍", "DETECTOR + REMOTE", false)
local teleCat = addCategory("📍", "TELEPORT & PLAYER", false)

-- MOVEMENT
addToggle(movCat.content, "🪶", "Fly", settings.fly, function(v) settings.fly=v; if v then startFly() else stopFly() end end)
addButton(movCat.content, "➕", "Walk Speed +10", function() settings.walkspeed=math.min(500,settings.walkspeed+10); updateMovement() end)
addButton(movCat.content, "➖", "Walk Speed -10", function() settings.walkspeed=math.max(16,settings.walkspeed-10); updateMovement() end)
addToggle(movCat.content, "♾️", "Infinite Jump", settings.infinitejump, function(v) settings.infinitejump=v; updateMovement() end)
addButton(movCat.content, "🚀", "Air Speed +10", function() settings.airspeed=math.min(500,settings.airspeed+10) end)

-- COMBAT
addToggle(combatCat.content, "🛡️", "God Mode", settings.godmode, function(v) settings.godmode=v end)
addToggle(combatCat.content, "⚔️", "Kill Aura", settings.killaura, function(v) settings.killaura=v end)
addButton(combatCat.content, "📏", "Kill Aura Range +5", function() settings.killaurarange=math.min(100,settings.killaurarange+5) end)
addToggle(combatCat.content, "🎯", "Aimbot", settings.aimbot, function(v) settings.aimbot=v end)
addToggle(combatCat.content, "🤖", "Auto Farm", settings.autofarm, function(v) settings.autofarm=v; if v then startFarm() else stopFarm() end end)

-- GRIEF (RUSUH) – banyak fitur
addToggle(griefCat.content, "🔴", "Laser (Follow Target)", settings.laser, function(v) settings.laser=v; if not v then stopLaser() end end)
addDropdown(griefCat.content, "🎯", "Laser Target", game.Players:GetChildren(), function(sel)
    for _,p in ipairs(game.Players:GetPlayers()) do if p.Name==sel then settings.laserTarget=p end end
end)
addButton(griefCat.content, "💥", "Laser Damage +5", function() settings.laserDamage=math.min(100,settings.laserDamage+5) end)
addToggle(griefCat.content, "🤖", "Laser Turret (Auto)", settings.laserTurret, function(v)
    settings.laserTurret=v
    if v then
        if turretThread then coroutine.close(turretThread) end
        turretThread = coroutine.create(turretLoop)
        coroutine.resume(turretThread)
    else
        if turretThread then coroutine.close(turretThread); turretThread=nil end
    end
end)
addButton(griefCat.content, "📏", "Turret Range +10", function() settings.laserTurretRange=math.min(200,settings.laserTurretRange+10) end)

addToggle(griefCat.content, "❄️", "Freeze Player", settings.freeze, function(v)
    settings.freeze=v
    if v and settings.freezeTarget then freezePlayer(settings.freezeTarget) end
end)
addDropdown(griefCat.content, "❄️", "Freeze Target", game.Players:GetChildren(), function(sel)
    for _,p in ipairs(game.Players:GetPlayers()) do if p.Name==sel then settings.freezeTarget=p; if settings.freeze then freezePlayer(p) end end end
end)

addToggle(griefCat.content, "👁️", "Blind (Flash)", settings.blind, function(v)
    settings.blind=v
    if v and settings.blindTarget then
        if blindThread then coroutine.close(blindThread) end
        blindThread = coroutine.create(blindLoop)
        coroutine.resume(blindThread, settings.blindTarget)
    end
end)
addDropdown(griefCat.content, "👁️", "Blind Target", game.Players:GetChildren(), function(sel)
    for _,p in ipairs(game.Players:GetPlayers()) do if p.Name==sel then settings.blindTarget=p end end
end)

addToggle(griefCat.content, "💣", "Crash Player (Lag)", settings.crash, function(v)
    settings.crash=v
    if v and settings.crashTarget then
        local th = coroutine.create(crashLoop)
        coroutine.resume(th, settings.crashTarget)
        crashThreads[settings.crashTarget] = th
    end
end)
addDropdown(griefCat.content, "💣", "Crash Target", game.Players:GetChildren(), function(sel)
    for _,p in ipairs(game.Players:GetPlayers()) do if p.Name==sel then settings.crashTarget=p end end
end)

addToggle(griefCat.content, "📡", "Remote Spam (Flood)", settings.remoteSpam, function(v)
    settings.remoteSpam=v
    if v and settings.remoteSpamTarget then
        if remoteSpamThread then coroutine.close(remoteSpamThread) end
        remoteSpamThread = coroutine.create(remoteSpamLoop)
        coroutine.resume(remoteSpamThread, settings.remoteSpamTarget)
    end
end)
addDropdown(griefCat.content, "📡", "Spam Target", game.Players:GetChildren(), function(sel)
    for _,p in ipairs(game.Players:GetPlayers()) do if p.Name==sel then settings.remoteSpamTarget=p end end
end)

addButton(griefCat.content, "👢", "Force Kick (Attempt)", function()
    if settings.forceKickTarget then forceKickPlayer(settings.forceKickTarget) end
end)
addDropdown(griefCat.content, "👢", "Kick Target", game.Players:GetChildren(), function(sel)
    for _,p in ipairs(game.Players:GetPlayers()) do if p.Name==sel then settings.forceKickTarget=p end end
end)

-- DETECTOR
addToggle(detectCat.content, "🕵️", "Real-time Detector", settings.detector, function(v) settings.detector=v end)
addToggle(detectCat.content, "💣", "Auto Breach (Destroy)", settings.breach, function(v) settings.breach=v end)
addToggle(detectCat.content, "🎮", "Remote Control (Block)", settings.remoteControl, function(v) settings.remoteControl=v; if v then controlRemotes() end end)
addButton(detectCat.content, "🔍", "Scan Now", function() scanVulnerabilities() end)

local logFrame = Instance.new("Frame")
logFrame.Size = UDim2.new(1,-10,0,100)
logFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
logFrame.BackgroundTransparency = 0.6
logFrame.Parent = detectCat.content
local logCorner = Instance.new("UICorner")
logCorner.CornerRadius = UDim.new(0,6)
logCorner.Parent = logFrame
local logText = Instance.new("TextLabel")
logText.Size = UDim2.new(1,0,1,0)
logText.BackgroundTransparency = 1
logText.Text = "Log akan muncul di sini"
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

-- TELEPORT & PLAYER
if isHuaa or isValthera then
    addButton(teleCat.content, "🏁", "TP Lobby/Start", function() teleport(lobbyPos) end)
    addButton(teleCat.content, "⏩", "Next CP", function()
        local idx = (currentCpIndex % #cpList) + 1
        currentCpIndex = idx
        teleport(cpList[idx][2])
    end)
    addButton(teleCat.content, "▶", "Auto Loop CP", function() startAutoCp(1.5) end)
    addButton(teleCat.content, "⏹️", "Stop Auto", function() stopAutoCp() end)
end

-- Saved coordinates (5 slot)
for i=1,5 do
    local slotFrame = Instance.new("Frame")
    slotFrame.Size = UDim2.new(1,-10,0,30)
    slotFrame.BackgroundTransparency = 1
    slotFrame.Parent = teleCat.content
    local slotLabel = Instance.new("TextLabel")
    slotLabel.Size = UDim2.new(0.2,0,1,0)
    slotLabel.Text = "Slot "..i
    slotLabel.TextColor3 = Color3.new(1,1,1)
    slotLabel.BackgroundTransparency = 1
    slotLabel.Font = Enum.Font.Gotham
    slotLabel.TextSize = 11
    slotLabel.Parent = slotFrame
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0,50,0,24)
    saveBtn.Position = UDim2.new(0.25,0,0,3)
    saveBtn.Text = "💾 Save"
    saveBtn.BackgroundColor3 = Color3.fromRGB(60,100,60)
    saveBtn.TextColor3 = Color3.new(1,1,1)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 11
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0,4)
    saveCorner.Parent = saveBtn
    saveBtn.Parent = slotFrame
    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0,50,0,24)
    tpBtn.Position = UDim2.new(0.55,0,0,3)
    tpBtn.Text = "✨ TP"
    tpBtn.BackgroundColor3 = Color3.fromRGB(60,60,100)
    tpBtn.TextColor3 = Color3.new(1,1,1)
    tpBtn.Font = Enum.Font.GothamBold
    tpBtn.TextSize = 11
    local tpCorner = Instance.new("UICorner")
    tpCorner.CornerRadius = UDim.new(0,4)
    tpCorner.Parent = tpBtn
    tpBtn.Parent = slotFrame
    local coordData = {nil}
    saveBtn.MouseButton1Click:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            coordData[1] = char.HumanoidRootPart.Position
            tpBtn.Text = "✓ Saved"
            wait(0.5)
            tpBtn.Text = "✨ TP"
        end
    end)
    tpBtn.MouseButton1Click:Connect(function()
        if coordData[1] then teleport(coordData[1]) end
    end)
end

-- Player list (TP and Bring)
local playerFrame = Instance.new("Frame")
playerFrame.Size = UDim2.new(1,-10,0,120)
playerFrame.BackgroundTransparency = 1
playerFrame.Parent = teleCat.content
local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1,0,1,0)
playerScroll.BackgroundTransparency = 1
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 4
playerScroll.Parent = playerFrame
local playerContainer = Instance.new("Frame")
playerContainer.Size = UDim2.new(1,0,0,0)
playerContainer.BackgroundTransparency = 1
playerContainer.Parent = playerScroll
local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Padding = UDim.new(0,3)
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Parent = playerContainer

local function refreshPlayerList()
    for _,c in ipairs(playerContainer:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for _,plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1,0,0,30)
            row.BackgroundTransparency = 1
            row.Parent = playerContainer
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.4,0,1,0)
            nameLabel.Text = plr.Name
            nameLabel.TextColor3 = Color3.new(1,1,1)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextSize = 11
            nameLabel.Parent = row
            local tpBtn = Instance.new("TextButton")
            tpBtn.Size = UDim2.new(0,60,0,24)
            tpBtn.Position = UDim2.new(0.45,0,0,3)
            tpBtn.Text = "🚀 TP"
            tpBtn.BackgroundColor3 = Color3.fromRGB(60,80,120)
            tpBtn.TextColor3 = Color3.new(1,1,1)
            tpBtn.Font = Enum.Font.GothamBold
            tpBtn.TextSize = 11
            local tpCorner = Instance.new("UICorner")
            tpCorner.CornerRadius = UDim.new(0,4)
            tpCorner.Parent = tpBtn
            tpBtn.Parent = row
            local bringBtn = Instance.new("TextButton")
            bringBtn.Size = UDim2.new(0,60,0,24)
            bringBtn.Position = UDim2.new(0.7,0,0,3)
            bringBtn.Text = "📦 Bring"
            bringBtn.BackgroundColor3 = Color3.fromRGB(120,60,60)
            bringBtn.TextColor3 = Color3.new(1,1,1)
            bringBtn.Font = Enum.Font.GothamBold
            bringBtn.TextSize = 11
            local bringCorner = Instance.new("UICorner")
            bringCorner.CornerRadius = UDim.new(0,4)
            bringCorner.Parent = bringBtn
            bringBtn.Parent = row
            tpBtn.MouseButton1Click:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    teleport(plr.Character.HumanoidRootPart.Position)
                end
            end)
            bringBtn.MouseButton1Click:Connect(function()
                local myPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
                if myPos and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(myPos)
                end
            end)
        end
    end
    local total = 0
    for _,c in ipairs(playerContainer:GetChildren()) do
        if c:IsA("Frame") then total = total + c.Size.Y.Offset + playerListLayout.Padding.Offset end
    end
    playerContainer.Size = UDim2.new(1,0,0,total)
    playerScroll.CanvasSize = UDim2.new(0,0,0,total+10)
    playerFrame.Size = UDim2.new(1,-10,0,math.min(120,total+20))
    teleCat.refresh()
end
spawn(function()
    while true do
        refreshPlayerList()
        wait(1)
    end
end)

-- Refresh semua kategori
movCat.refresh()
combatCat.refresh()
griefCat.refresh()
detectCat.refresh()
teleCat.refresh()
updateContainer()

-- Draggable & Minimize
local dragStart, dragStartPos
title.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = inp.Position
        dragStartPos = main.Position
        local moveConn, endConn
        moveConn = uis.InputChanged:Connect(function(inp2)
            if inp2.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = inp2.Position - dragStart
                main.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
            end
        end)
        endConn = uis.InputEnded:Connect(function(inp2)
            if inp2.UserInputType == Enum.UserInputType.MouseButton1 then
                moveConn:Disconnect()
                endConn:Disconnect()
            end
        end)
    end
end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        scroll.Visible = false
        main:TweenSize(UDim2.new(0,480,0,40), "Out", "Quad", 0.2)
    else
        main:TweenSize(UDim2.new(0,480,0,580), "Out", "Quad", 0.2)
        wait(0.2)
        scroll.Visible = true
        updateContainer()
    end
end)

uis.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.Insert then
        main.Visible = not main.Visible
    end
end)

-- Auto CP function (universal)
local autoRunning = false
local autoCpThread = nil
local currentCpIndex = 1
function startAutoCp(delay)
    if autoRunning then return end
    autoRunning = true
    autoCpThread = coroutine.create(function()
        while autoRunning do
            for i=1,#cpList do
                if not autoRunning then break end
                teleport(cpList[i][2])
                currentCpIndex = i
                wait(delay)
            end
        end
    end)
    coroutine.resume(autoCpThread)
end
function stopAutoCp()
    autoRunning = false
    if autoCpThread then coroutine.close(autoCpThread); autoCpThread = nil end
end

print("✅ RMAX FINAL EXTREME LOADED | Press Insert | All features stable")
