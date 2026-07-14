-- Crypt-MM2-Legit | Aimbot

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput  = game:GetService("UserInputService")
local camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

-- Use shared role cache from ESP module
local function getRole(player)
    if _G.RoleCache and _G.RoleCache[player] then
        return _G.RoleCache[player]
    end
    local char = player.Character
    local bp   = player:FindFirstChild("Backpack")
    if char then
        if char:FindFirstChild("Knife") then return "Murderer" end
        if char:FindFirstChild("Gun")   then return "Sheriff"  end
    end
    if bp then
        if bp:FindFirstChild("Knife") then return "Murderer" end
        if bp:FindFirstChild("Gun")   then return "Sheriff"  end
    end
    return "Innocent"
end

-- ── RGB hue cycle ─────────────────────────────────────────────────────────────

local fovHue = 0

local function hsvToColor(h)
    return Color3.fromHSV(h, 1, 1)
end

-- ── Drawings ──────────────────────────────────────────────────────────────────

local fovCircle        = Drawing.new("Circle")
fovCircle.Thickness    = 1.5
fovCircle.Color        = Color3.fromRGB(255, 255, 255)
fovCircle.Filled       = false
fovCircle.Visible      = false
fovCircle.Transparency = 1

local tgtLine        = Drawing.new("Line")
tgtLine.Thickness    = 1.5
tgtLine.Color        = Color3.fromRGB(255, 60, 60)
tgtLine.Visible      = false
tgtLine.Transparency = 1

local currentTarget = nil

local function getTarget(fov)
    local center     = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local best, bestD = nil, fov
    local aimAll     = (not _G.AimMurderer) and (not _G.AimSheriff)

    for _, p in ipairs(Players:GetPlayers()) do
        if p == lp then continue end
        local char = p.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local role = getRole(p)
        if not aimAll then
            if not ((_G.AimMurderer and role=="Murderer") or (_G.AimSheriff and role=="Sheriff")) then continue end
        end
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not head then continue end
        local sp, vis = camera:WorldToViewportPoint(head.Position)
        if not vis then continue end
        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if d < bestD then bestD=d; best=head end
    end
    return best
end

-- ── Triggerbot ────────────────────────────────────────────────────────────────

local trigCD = 0

-- ── Main ──────────────────────────────────────────────────────────────────────

RunService.RenderStepped:Connect(function(dt)
    local enabled  = _G.AimbotEnabled    or false
    local fov      = _G.AimbotFOV        or 250
    local smooth   = _G.AimbotSmoothing  or 2
    local needRMB  = _G.AimbotRightClick or false
    local showFov  = _G.ShowFOV          or false
    local fovRGB   = _G.FovRGB           or false
    local showTgt  = _G.TargetTracer     or false
    local trigOn   = _G.TriggerEnabled   or false
    local trigFOV  = _G.TriggerFOV       or 30

    local vp     = camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)

    -- RGB hue advance
    fovHue = (fovHue + dt * 0.4) % 1

    -- FOV circle — shows regardless of aimbot on/off when ShowFOV is ticked
    fovCircle.Radius   = fov
    fovCircle.Position = center
    fovCircle.Color    = fovRGB and hsvToColor(fovHue) or Color3.fromRGB(255, 255, 255)
    fovCircle.Visible  = showFov   -- no longer gated by enabled

    tgtLine.Visible  = false
    currentTarget    = nil

    if enabled then
        if not needRMB or UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = getTarget(fov)
            currentTarget = target

            if target then
                local sp, vis = camera:WorldToViewportPoint(target.Position)
                if vis and showTgt then
                    tgtLine.From    = Vector2.new(vp.X / 2, vp.Y)   -- bottom center
                    tgtLine.To      = Vector2.new(sp.X, sp.Y)
                    tgtLine.Visible = true
                end

                local alpha = math.clamp(1 / math.max(smooth, 1), 0.08, 1)
                local cf  = camera.CFrame
                local tcf = CFrame.lookAt(cf.Position, target.Position)
                local cx, cy, cz = cf:ToOrientation()
                local tx, ty, _  = tcf:ToOrientation()

                local nx = cx + (tx-cx)*alpha + (math.random()-0.5)*0.0015
                local ny = cy + (ty-cy)*alpha + (math.random()-0.5)*0.0015
                camera.CFrame = CFrame.new(cf.Position) * CFrame.fromOrientation(nx, ny, cz)
            end
        end
    end

    -- Triggerbot
    if trigOn then
        trigCD = trigCD - dt
        if trigCD <= 0 then
            local trigAll = (not _G.TriggerMurd) and (not _G.TriggerSheriff)
            for _, p in ipairs(Players:GetPlayers()) do
                if p == lp then continue end
                local char = p.Character
                if not char then continue end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health<=0 then continue end
                local role = getRole(p)
                if not trigAll then
                    if not ((_G.TriggerMurd and role=="Murderer") or (_G.TriggerSheriff and role=="Sheriff")) then continue end
                end
                local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if not head then continue end
                local sp, vis = camera:WorldToViewportPoint(head.Position)
                if not vis then continue end
                if (Vector2.new(sp.X,sp.Y)-center).Magnitude <= trigFOV then
                    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
                    if tool then pcall(function() tool:Activate() end) end
                    trigCD = 0.18 + math.random()*0.08
                    break
                end
            end
        end
    end
end)

_G.CryptAimbotTarget = function() return currentTarget end
