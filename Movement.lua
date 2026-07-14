-- Crypt-MM2-Legit | Local Player

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UserInput   = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local lp          = Players.LocalPlayer
local BASE_SPEED  = 16

-- ── Noclip ────────────────────────────────────────────────────────────────────

local noclipConn = nil; local lastNoclip = false

local function setNoclip(on)
    if on then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            local char = lp.Character; if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        local char = lp.Character; if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end

RunService.Heartbeat:Connect(function()
    local now = _G.NoclipEnabled or false
    if now ~= lastNoclip then lastNoclip = now; setNoclip(now) end
end)

lp.CharacterAdded:Connect(function()
    task.wait(0.2); if _G.NoclipEnabled then setNoclip(true) end
end)

-- ── Speed ─────────────────────────────────────────────────────────────────────

RunService.Heartbeat:Connect(function()
    local char = lp.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local mult = math.clamp(_G.SpeedMultiplier or 1, 1, 100)
    local tgt  = _G.SpeedEnabled and (BASE_SPEED * mult) or BASE_SPEED
    hum.WalkSpeed = hum.WalkSpeed + (tgt - hum.WalkSpeed) * 0.18
end)

-- ── Infinite Jump ─────────────────────────────────────────────────────────────

UserInput.JumpRequest:Connect(function()
    if not _G.InfJumpEnabled then return end
    local char = lp.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- ── Invisibility — server-visible via character network ownership ──────────────
-- Character parts are client-owned — Transparency=1 DOES replicate to server
-- Combined with Size shrink for games that reset transparency server-side

local invisHL = nil; local lastInvis = false

local function applyInvis(on)
    local char = lp.Character; if not char then return end

    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.Transparency = on and 1 or 0
            -- Size shrink as backup (also replicates, can't be reset by game)
            if on then
                pcall(function() p.Size = Vector3.new(0.001, 0.001, 0.001) end)
            end
        end
        if p:IsA("Decal") or p:IsA("SpecialMesh") then
            pcall(function() p.Transparency = on and 1 or 0 end)
        end
    end
    -- Destroy accessories (replicates — you own them)
    if on then
        for _, acc in ipairs(char:GetChildren()) do
            if acc:IsA("Accessory") then acc:Destroy() end
        end
    end

    -- Local outline so you can see yourself
    if on then
        if not invisHL or not invisHL.Parent then
            invisHL = Instance.new("Highlight")
            invisHL.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
            invisHL.FillTransparency   = 1
            invisHL.OutlineTransparency = 0.2
            invisHL.OutlineColor       = Color3.fromRGB(255, 255, 255)
            invisHL.Adornee            = char
            invisHL.Parent             = char
        end
    else
        if invisHL then invisHL:Destroy(); invisHL = nil end
        -- Need to respawn to restore sizes — warn user
        if _G.Notify then _G.Notify("Toggle off: rejoin/respawn to restore appearance", "warn") end
    end
end

RunService.Heartbeat:Connect(function()
    local now = _G.InvisEnabled or false
    if now ~= lastInvis then
        lastInvis = now; applyInvis(now)
        if _G.Notify then _G.Notify(now and "Invisibility ON — others see nothing" or "Invisibility OFF", now and "success" or "info") end
    end
end)

lp.CharacterAdded:Connect(function()
    task.wait(0.3)
    lastInvis = false  -- reset so it re-applies
    if _G.InvisEnabled then applyInvis(true) end
end)

-- ── Auto Gun — firetouchinterest, throttled, only notify on actual collection ──

local autoGunCD = 0
local hadGunLastCheck = false

RunService.Heartbeat:Connect(function(dt)
    if not _G.AutoGun then autoGunCD = 0; return end
    autoGunCD = autoGunCD - dt
    if autoGunCD > 0 then return end
    autoGunCD = 0.4  -- check every 0.4s only

    local char = lp.Character; if not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local bp   = lp:FindFirstChild("Backpack")

    local hasGun = char:FindFirstChild("Gun") or (bp and bp:FindFirstChild("Gun"))
    if hasGun then return end  -- already have it

    -- Find dropped gun
    local found = false
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj.Name:lower():find("gun") then
            if obj.Parent == char or obj.Parent == bp then continue end
            local handle = obj:FindFirstChild("Handle")
            if handle then
                pcall(function()
                    firetouchinterest(hrp, handle, 0)
                    task.wait(0.05)
                    firetouchinterest(hrp, handle, 1)
                end)
                found = true
                break
            end
        end
    end

    -- Only notify if we actually got it (check 0.3s after firing)
    if found then
        task.delay(0.35, function()
            local c = lp.Character; local b = lp:FindFirstChild("Backpack")
            local nowHas = (c and c:FindFirstChild("Gun")) or (b and b:FindFirstChild("Gun"))
            if nowHas and _G.Notify then
                _G.Notify("Gun collected!", "success")
            end
        end)
    end
end)

-- ── Anti-AFK — VirtualUser method (more reliable than jumping) ────────────────

local afkTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if not _G.AntiAFK then return end
    afkTimer = afkTimer + dt
    if afkTimer >= 20 then
        afkTimer = 0
        pcall(function()
            -- Simulate a tiny mouse movement — breaks AFK detection without visibly moving
            VirtualUser:MouseMoveRel(Vector2.new(1, 0))
            task.wait(0.05)
            VirtualUser:MouseMoveRel(Vector2.new(-1, 0))
        end)
    end
end)

-- ── Coin Farm — firetouchinterest with anti-murderer, noclip auto-on ──────────

local coinTimer = 0

local function getMurdererPos()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player == lp then continue end
        local role = (_G.RoleCache and _G.RoleCache[player]) or "Innocent"
        if role == "Murderer" then
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then return root.Position end
        end
    end
    return nil
end

RunService.Heartbeat:Connect(function(dt)
    if not _G.CoinFarm then return end

    -- Auto-enable noclip for smooth farm
    if not _G.NoclipEnabled then
        _G.NoclipEnabled = true
        -- The noclip heartbeat above will pick this up automatically
    end

    coinTimer = coinTimer + dt
    if coinTimer < 0.15 then return end
    coinTimer = 0

    local char = lp.Character; if not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local mPos = _G.CoinAntiMurd and getMurdererPos() or nil
    local safeR = _G.CoinSafetyRadius or 15

    for _, obj in ipairs(workspace:GetDescendants()) do
        local isCoin = obj.Name == "Coin" or obj.Name == "coin"
            or obj.Name:lower():find("coin") or obj.Name:lower():find("gold")

        if isCoin and obj:IsA("BasePart") then
            -- Anti-murderer check
            if mPos and (obj.Position - mPos).Magnitude < safeR then
                continue  -- skip coins near murderer
            end
            pcall(function()
                firetouchinterest(hrp, obj, 0)
                firetouchinterest(hrp, obj, 1)
            end)
        end
    end
end)
