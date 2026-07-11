-- Crypt-MM2-Legit | Aimbot + FOV Circle

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UserInput    = game:GetService("UserInputService")
local camera       = workspace.CurrentCamera
local lp           = Players.LocalPlayer
local mouse        = lp:GetMouse()

-- ─── Role Detection ───────────────────────────────────────────────────────────
-- MM2 stores role in a StringValue inside the player or as a team.
-- We check both common MM2 methods.

local function getRole(player)
    -- Method 1: team name
    if player.Team then
        local tn = player.Team.Name:lower()
        if tn:find("murder") then return "murderer" end
        if tn:find("sheriff") then return "sheriff"  end
    end
    -- Method 2: Character attribute or leading tag (MM2 uses leaderstats sometimes)
    local char = player.Character
    if char then
        local roleVal = char:FindFirstChild("Role") or player:FindFirstChild("Role")
        if roleVal then
            local v = roleVal.Value:lower()
            if v:find("murder") then return "murderer" end
            if v:find("sheriff") then return "sheriff"  end
        end
    end
    return "innocent"
end

local function roleColor(role)
    if role == "murderer" then return Color3.fromRGB(255, 60, 60)  end
    if role == "sheriff"  then return Color3.fromRGB(60, 220, 80)  end
    return Color3.fromRGB(200, 200, 220)
end

-- ─── FOV Circle ───────────────────────────────────────────────────────────────

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness  = 1.5
fovCircle.Color      = Color3.fromRGB(180, 120, 255)
fovCircle.Filled     = false
fovCircle.Visible    = false
fovCircle.Transparency = 1

-- ─── Closest Target ───────────────────────────────────────────────────────────

local function getTarget()
    local center     = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local best, dist = nil, _G.AimbotFOV or 180

    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        if not player.Character then continue end

        local role = getRole(player)

        -- Apply target filter (stacks — either/both can be on)
        local wanted = false
        if _G.AimMurderer and role == "murderer" then wanted = true end
        if _G.AimSheriff  and role == "sheriff"  then wanted = true end
        if not wanted then continue end

        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        -- Check alive
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end

        local screenVec = Vector2.new(screenPos.X, screenPos.Y)
        local d = (screenVec - center).Magnitude

        if d < dist then
            dist  = d
            best  = root
        end
    end

    return best
end

-- ─── Smooth Step ──────────────────────────────────────────────────────────────

local function smoothStep(current, target, alpha)
    return current + (target - current) * alpha
end

-- ─── Main Loop ────────────────────────────────────────────────────────────────

-- replace the existing RunService.RenderStepped:Connect block with this:

RunService.RenderStepped:Connect(function()
    local fov     = _G.AimbotFOV       or 180
    local smooth  = _G.AimbotSmoothing or 12
    local enabled = _G.AimbotEnabled   or false
    local showFov = _G.ShowFOV         or false
    local needRMB = _G.AimbotRightClick

    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    fovCircle.Radius   = fov
    fovCircle.Position = center
    fovCircle.Visible  = (showFov == true) and (enabled == true)

    if not enabled then return end
    if needRMB and not UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

    local target = getTarget()
    if not target then return end

    local alpha    = math.clamp(1 / smooth, 0.01, 1)
    local currentCF = camera.CFrame
    local targetCF  = CFrame.new(currentCF.Position, target.Position)
    local cx, cy, cz = currentCF:ToOrientation()
    local tx, ty, _  = targetCF:ToOrientation()

    local nx = cx + (tx - cx) * alpha + (math.random() - 0.5) * 0.004
    local ny = cy + (ty - cy) * alpha + (math.random() - 0.5) * 0.004

    camera.CFrame = CFrame.new(currentCF.Position) * CFrame.fromOrientation(nx, ny, cz)
end)
