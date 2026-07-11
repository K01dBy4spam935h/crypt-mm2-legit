-- Crypt-MM2-Legit | Custom Crosshair

local RunService = game:GetService("RunService")
local camera     = workspace.CurrentCamera

-- 4 lines: top, bottom, left, right
local lines = {}
for i = 1, 4 do
    local l = Drawing.new("Line")
    l.Thickness    = 1
    l.Color        = Color3.fromRGB(255, 255, 255)
    l.Visible      = false
    l.Transparency = 1
    lines[i] = l
end

RunService.RenderStepped:Connect(function()
    if not _G.CrosshairEnabled then
        for _, l in ipairs(lines) do l.Visible = false end
        return
    end

    local cx    = camera.ViewportSize.X / 2
    local cy    = camera.ViewportSize.Y / 2
    local size  = (_G.CrosshairSize  or 14) / 2
    local gap   = _G.CrosshairGap    or 4
    local thick = _G.CrosshairThick  or 1

    -- top
    lines[1].From      = Vector2.new(cx, cy - gap - size)
    lines[1].To        = Vector2.new(cx, cy - gap)
    lines[1].Thickness = thick
    lines[1].Visible   = true

    -- bottom
    lines[2].From      = Vector2.new(cx, cy + gap)
    lines[2].To        = Vector2.new(cx, cy + gap + size)
    lines[2].Thickness = thick
    lines[2].Visible   = true

    -- left
    lines[3].From      = Vector2.new(cx - gap - size, cy)
    lines[3].To        = Vector2.new(cx - gap,        cy)
    lines[3].Thickness = thick
    lines[3].Visible   = true

    -- right
    lines[4].From      = Vector2.new(cx + gap,        cy)
    lines[4].To        = Vector2.new(cx + gap + size, cy)
    lines[4].Thickness = thick
    lines[4].Visible   = true
end)
