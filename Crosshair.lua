-- Crypt-MM2-Legit | Crosshair — RGB + spinning

local RunService = game:GetService("RunService")
local camera     = workspace.CurrentCamera

local lines = {}
for i = 1, 4 do
    local l = Drawing.new("Line")
    l.Thickness    = 1
    l.Color        = Color3.fromRGB(255, 255, 255)
    l.Visible      = false
    l.Transparency = 1
    lines[i] = l
end

local angle = 0
local hue   = 0

local function hsvToRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if     i == 0 then r,g,b = v,t,p
    elseif i == 1 then r,g,b = q,v,p
    elseif i == 2 then r,g,b = p,v,t
    elseif i == 3 then r,g,b = p,q,v
    elseif i == 4 then r,g,b = t,p,v
    elseif i == 5 then r,g,b = v,p,q
    end
    return Color3.new(r, g, b)
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

    -- Advance angle and hue
    angle = angle + spin * dt
    hue   = (hue + dt * 0.3) % 1

    local color = _G.CrosshairRGB
        and hsvToRGB(hue, 1, 1)
        or  Color3.fromRGB(255, 255, 255)

    local cos_a = math.cos(angle)
    local sin_a = math.sin(angle)

    -- Rotate 4 tip vectors around center
    local tips = {
        Vector2.new(0, -(gap + size)),    -- up
        Vector2.new(0,  (gap + size)),    -- down
        Vector2.new(-(gap + size), 0),   -- left
        Vector2.new( (gap + size), 0),   -- right
    }
    local bases = {
        Vector2.new(0, -gap),
        Vector2.new(0,  gap),
        Vector2.new(-gap, 0),
        Vector2.new( gap, 0),
    }

    local function rot(v)
        return Vector2.new(
            v.X * cos_a - v.Y * sin_a + cx,
            v.X * sin_a + v.Y * cos_a + cy
        )
    end

    for i = 1, 4 do
        lines[i].From      = rot(bases[i])
        lines[i].To        = rot(tips[i])
        lines[i].Color     = color
        lines[i].Thickness = thick
        lines[i].Visible   = true
    end
end)
