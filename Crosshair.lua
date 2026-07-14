-- Crypt-MM2-Legit | Crosshair — RGB spin + red on player

local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

local lines = {}
for i = 1, 4 do
    local l = Drawing.new("Line"); l.Thickness=1; l.Color=Color3.fromRGB(255,255,255); l.Visible=false; l.Transparency=1
    lines[i] = l
end

local angle = 0
local hue   = 0

local function hsvToColor(h) return Color3.fromHSV(h, 1, 1) end

-- Raycast to check if crosshair is over a player
local function isOnPlayer()
    local unitRay = camera:ScreenPointToRay(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    local params  = RaycastParams.new()
    params.FilterDescendantsInstances = {lp.Character or workspace}
    params.FilterType = Enum.RaycastFilterType.Exclude

    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)
    if not result then return false end

    local hit = result.Instance
    -- Walk up to find character
    local model = hit:FindFirstAncestorOfClass("Model")
    if not model then return false end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character == model then return true end
    end
    return false
end

RunService.RenderStepped:Connect(function(dt)
    if not _G.CrosshairEnabled then
        for _, l in ipairs(lines) do l.Visible = false end
        return
    end

    local cx    = camera.ViewportSize.X / 2
    local cy    = camera.ViewportSize.Y / 2
    local size  = (_G.CrosshairSize  or 14) / 2
    local gap   = _G.CrosshairGap    or 4
    local thick = _G.CrosshairThick  or 1
    local spin  = _G.CrosshairRGB    and (_G.CrosshairSpin or 5) or 0

    angle = angle + spin * dt
    hue   = (hue + dt * 0.35) % 1

    -- Determine color: red if over player, else RGB or white
    local onPlayer = (_G.CrosshairRedOnPlayer ~= false) and isOnPlayer()
    local color
    if onPlayer then
        color = Color3.fromRGB(255, 40, 40)
    elseif _G.CrosshairRGB then
        color = hsvToColor(hue)
    else
        color = Color3.fromRGB(255, 255, 255)
    end

    local cos_a = math.cos(angle); local sin_a = math.sin(angle)

    local tips = {
        Vector2.new(0, -(gap+size)), Vector2.new(0, gap+size),
        Vector2.new(-(gap+size), 0), Vector2.new(gap+size, 0),
    }
    local bases = {
        Vector2.new(0, -gap), Vector2.new(0, gap),
        Vector2.new(-gap, 0), Vector2.new(gap, 0),
    }
    local function rot(v)
        return Vector2.new(v.X*cos_a - v.Y*sin_a + cx, v.X*sin_a + v.Y*cos_a + cy)
    end

    for i = 1, 4 do
        lines[i].From=rot(bases[i]); lines[i].To=rot(tips[i])
        lines[i].Color=color; lines[i].Thickness=thick; lines[i].Visible=true
    end
end)
