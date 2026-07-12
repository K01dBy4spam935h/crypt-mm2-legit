-- Crypt-MM2-Legit | ESP — tracers, fixed chams, no ghost highlights

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
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

local function roleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255, 55, 55)  end
    if role == "Sheriff"  then return Color3.fromRGB(55, 210, 255) end
    return Color3.fromRGB(220, 220, 220)
end

-- ── ESP Pool ─────────────────────────────────────────────────────────────────

local pool = {}

local function makeESP(player)
    if player == lp then return end
    if pool[player] then return end

    local obj = {}

    obj.box = {}
    for i = 1, 4 do
        local l = Drawing.new("Line")
        l.Thickness    = 1.5
        l.Visible      = false
        l.Transparency = 1
        obj.box[i] = l
    end

    obj.name           = Drawing.new("Text")
    obj.name.Size      = 13
    obj.name.Font      = Drawing.Fonts.Plex
    obj.name.Center    = true
    obj.name.Outline   = true
    obj.name.Visible   = false

    obj.dist           = Drawing.new("Text")
    obj.dist.Size      = 11
    obj.dist.Font      = Drawing.Fonts.Plex
    obj.dist.Center    = true
    obj.dist.Outline   = true
    obj.dist.Visible   = false

    obj.tracer         = Drawing.new("Line")
    obj.tracer.Thickness = 1
    obj.tracer.Visible   = false
    obj.tracer.Transparency = 1

    -- Highlight for chams — starts fully disabled
    obj.hl                       = Instance.new("Highlight")
    obj.hl.DepthMode             = Enum.HighlightDepthMode.AlwaysOnTop
    obj.hl.FillTransparency      = 1    -- invisible until ChamsESP on
    obj.hl.OutlineTransparency   = 1
    obj.hl.Adornee               = nil
    obj.hl.Parent                = workspace

    pool[player] = obj
end

local function removeESP(player)
    local obj = pool[player]
    if not obj then return end
    for _, l in ipairs(obj.box) do pcall(function() l:Remove() end) end
    pcall(function() obj.name:Remove()   end)
    pcall(function() obj.dist:Remove()   end)
    pcall(function() obj.tracer:Remove() end)
    pcall(function() obj.hl:Destroy()    end)
    pool[player] = nil
end

local function hideObj(obj)
    for _, l in ipairs(obj.box) do l.Visible = false end
    obj.name.Visible         = false
    obj.dist.Visible         = false
    obj.tracer.Visible       = false
    -- always hide chams cleanly
    obj.hl.FillTransparency    = 1
    obj.hl.OutlineTransparency = 1
    obj.hl.Adornee             = nil
end

for _, p in ipairs(Players:GetPlayers()) do makeESP(p) end
Players.PlayerAdded:Connect(makeESP)
Players.PlayerRemoving:Connect(removeESP)

-- ── Render ───────────────────────────────────────────────────────────────────

local screenBottom = Vector2.new(0, 0)

RunService.RenderStepped:Connect(function()
    screenBottom = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)

    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

    for player, obj in pairs(pool) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        if not (char and root and hum and hum.Health > 0) then
            hideObj(obj)
            continue
        end

        local role  = getRole(player)
        local color = roleColor(role)

        -- Chams — only show when toggle is on
        if _G.ChamsESP then
            obj.hl.Adornee             = char
            obj.hl.FillColor           = color
            obj.hl.OutlineColor        = color
            obj.hl.FillTransparency    = 0.55
            obj.hl.OutlineTransparency = 0
        else
            obj.hl.FillTransparency    = 1
            obj.hl.OutlineTransparency = 1
            obj.hl.Adornee             = nil
        end

        local headSP, headVis = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3.2, 0))
        local feetSP, feetVis = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.8, 0))
        local rootSP, rootVis = camera:WorldToViewportPoint(root.Position)

        if not (headVis and feetVis) then
            for _, l in ipairs(obj.box) do l.Visible = false end
            obj.name.Visible   = false
            obj.dist.Visible   = false
            obj.tracer.Visible = false
            continue
        end

        local h = math.abs(headSP.Y - feetSP.Y)
        local w = h * 0.5
        local x = headSP.X - w / 2
        local y = headSP.Y

        -- Box
        if _G.BoxESP then
            local segs = {
                {Vector2.new(x,     y),     Vector2.new(x + w, y)},
                {Vector2.new(x + w, y),     Vector2.new(x + w, y + h)},
                {Vector2.new(x + w, y + h), Vector2.new(x,     y + h)},
                {Vector2.new(x,     y + h), Vector2.new(x,     y)},
            }
            for i, seg in ipairs(segs) do
                obj.box[i].From    = seg[1]
                obj.box[i].To      = seg[2]
                obj.box[i].Color   = color
                obj.box[i].Visible = true
            end
        else
            for _, l in ipairs(obj.box) do l.Visible = false end
        end

        -- Name
        if _G.NameESP then
            obj.name.Text     = player.Name .. "  [" .. role .. "]"
            obj.name.Color    = color
            obj.name.Position = Vector2.new(headSP.X, y - 17)
            obj.name.Visible  = true
        else
            obj.name.Visible = false
        end

        -- Distance
        if _G.DistanceESP and myRoot then
            local d = math.floor((myRoot.Position - root.Position).Magnitude)
            obj.dist.Text     = d .. " studs"
            obj.dist.Color    = Color3.fromRGB(180, 180, 180)
            obj.dist.Position = Vector2.new(headSP.X, y + h + 2)
            obj.dist.Visible  = true
        else
            obj.dist.Visible = false
        end

        -- Tracer (screen bottom → player feet)
        if _G.Tracers and rootVis then
            obj.tracer.From    = screenBottom
            obj.tracer.To      = Vector2.new(feetSP.X, feetSP.Y)
            obj.tracer.Color   = color
            obj.tracer.Visible = true
        else
            obj.tracer.Visible = false
        end
    end
end)
