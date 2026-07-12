-- Crypt-MM2-Legit | Aimbot

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput  = game:GetService("UserInputService")
local camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

local function getRole(player)
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

-- ── Drawings ─────────────────────────────────────────────────────────────────

local fovCircle        = Drawing.new("Circle")
fovCircle.Thickness    = 1.2
fovCircle.Color        = Color3.fromRGB(255, 255, 255)
fovCircle.Filled       = false
fovCircle.Visible      = false
fovCircle.Transparency = 1

local targetTracer        = Drawing.new("Line")
targetTracer.Thickness    = 1.5
targetTracer.Color        = Color3.fromRGB(255, 60, 60)
targetTracer.Visible      = false
targetTracer.Transparency = 1

-- ── Closest Target ───────────────────────────────────────────────────────────

local currentTarget = nil  -- exposed for other modules

local function getTarget()
    local fov    = _G.AimbotFOV or 250
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local best, bestDist = nil, fov

    local aimAll = (not _G.AimMurderer) and (not _G.AimSheriff)

    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local role = getRole(player)
        if not aimAll then
            local wanted = false
            if _G.AimMurderer and role == "Murderer" then wanted = true end
            if _G.AimSheriff  and role == "Sheriff"  then wanted = true end
            if not wanted then continue end
        end

        local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not head then continue end

        local sp, onScreen = camera:WorldToViewportPoint(head.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if dist < bestDist then
            bestDist = dist
            best     = head
        end
    end

    return best
end

-- ── Main Loop ────────────────────────────────────────────────────────────────

RunService.RenderStepped:Connect(function()
    local enabled = _G.AimbotEnabled    or false
    local fov     = _G.AimbotFOV        or 250
    local smooth  = _G.AimbotSmoothing  or 5
    local needRMB = _G.AimbotRightClick or false
    local showFov = _G.ShowFOV          or false
    local showTgt = _G.TargetTracer     or false

    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    -- FOV circle
    fovCircle.Radius   = fov
    fovCircle.Position = center
    fovCircle.Visible  = showFov and enabled

    -- Clear target tracer by default
    targetTracer.Visible = false
    currentTarget = nil

    if not enabled then return end
    if needRMB and not UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

    local target = getTarget()
    currentTarget = target
    if not target then return end

    -- Target tracer line (bottom-center → target screen pos)
    if showTgt then
        local sp, onScreen = camera:WorldToViewportPoint(target.Position)
        if onScreen then
            targetTracer.From    = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
            targetTracer.To      = Vector2.new(sp.X, sp.Y)
            targetTracer.Visible = true
        end
    end

    -- Snap aim — high alpha = snappier
    local alpha = math.clamp(1 / math.max(smooth, 1), 0.05, 1)

    local cf       = camera.CFrame
    local targetCF = CFrame.lookAt(cf.Position, target.Position)

    local cx, cy, cz = cf:ToOrientation()
    local tx, ty, _  = targetCF:ToOrientation()

    -- snappy lerp — with smooth = 1, alpha = 1.0 = instant lock
    local nx = cx + (tx - cx) * alpha + (math.random() - 0.5) * 0.002
    local ny = cy + (ty - cy) * alpha + (math.random() - 0.5) * 0.002

    camera.CFrame = CFrame.new(cf.Position) * CFrame.fromOrientation(nx, ny, cz)
end)

_G.CryptAimbotTarget = function() return currentTarget end
