-- Crypt-MM2-Legit | Aimbot — MM2 fixed

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput  = game:GetService("UserInputService")
local camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

-- ─── MM2 Role Detection ───────────────────────────────────────────────────────

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

-- ─── FOV Circle ──────────────────────────────────────────────────────────────

local fovCircle           = Drawing.new("Circle")
fovCircle.Thickness       = 1.5
fovCircle.Color           = Color3.fromRGB(255, 255, 255)
fovCircle.Filled          = false
fovCircle.Visible         = false
fovCircle.Transparency    = 1

-- ─── Get Closest Valid Target ────────────────────────────────────────────────

local function getTarget()
    local fov    = _G.AimbotFOV or 180
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local best, bestDist = nil, fov

    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end

        local char = player.Character
        if not char then continue end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local role = getRole(player)

        local wanted = false
        if _G.AimMurderer and role == "Murderer" then wanted = true end
        if _G.AimSheriff  and role == "Sheriff"  then wanted = true end
        if not wanted then continue end

        -- aim for head if it exists, else root
        local aimPart = char:FindFirstChild("Head")
                     or char:FindFirstChild("HumanoidRootPart")
        if not aimPart then continue end

        local screenPos, onScreen = camera:WorldToViewportPoint(aimPart.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist < bestDist then
            bestDist = dist
            best     = aimPart
        end
    end

    return best
end

-- ─── Main Loop ───────────────────────────────────────────────────────────────

RunService.RenderStepped:Connect(function()
    local fov     = _G.AimbotFOV       or 180
    local smooth  = _G.AimbotSmoothing or 12
    local enabled = _G.AimbotEnabled   or false
    local showFov = _G.ShowFOV         or false
    local needRMB = (_G.AimbotRightClick ~= false)

    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    -- Draw FOV circle
    fovCircle.Radius   = fov
    fovCircle.Position = center
    fovCircle.Visible  = showFov and enabled

    if not enabled then return end
    if needRMB and not UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        return
    end

    local target = getTarget()
    if not target then return end

    -- get current and desired camera angles
    local cf      = camera.CFrame
    local targetCF = CFrame.lookAt(cf.Position, target.Position)

    -- extract euler angles
    local cx, cy, cz = cf:ToOrientation()
    local tx, ty, _  = targetCF:ToOrientation()

    -- smooth interpolation
    local alpha = math.clamp(1 / smooth, 0.02, 1)
    local nx    = cx + (tx - cx) * alpha
    local ny    = cy + (ty - cy) * alpha

    -- tiny humanizing jitter
    nx = nx + (math.random() - 0.5) * 0.003
    ny = ny + (math.random() - 0.5) * 0.003

    -- apply
    camera.CFrame = CFrame.new(cf.Position) * CFrame.fromOrientation(nx, ny, cz)
end)
