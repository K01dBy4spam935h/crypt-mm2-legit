-- Crypt-MM2-Legit | ESP (Box, Chams, Name, Distance — team colored)

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

local espObjects = {}  -- [player] = { box, nameTag, chamParts }

local function getRole(player)
    if player.Team then
        local tn = player.Team.Name:lower()
        if tn:find("murder") then return "murderer" end
        if tn:find("sheriff") then return "sheriff"  end
    end
    local char = player.Character
    if char then
        local rv = char:FindFirstChild("Role") or player:FindFirstChild("Role")
        if rv then
            local v = rv.Value:lower()
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

local function makeESP(player)
    local obj = {}

    -- Box (4 Drawing lines = rectangle)
    obj.boxLines = {}
    for i = 1, 4 do
        local line = Drawing.new("Line")
        line.Thickness  = 1.5
        line.Color      = Color3.fromRGB(255, 255, 255)
        line.Visible    = false
        line.Transparency = 1
        obj.boxLines[i] = line
    end

    -- Name tag
    obj.nameTag = Drawing.new("Text")
    obj.nameTag.Size     = 13
    obj.nameTag.Font     = Drawing.Fonts.Plex
    obj.nameTag.Center   = true
    obj.nameTag.Outline  = true
    obj.nameTag.Visible  = false
    obj.nameTag.Color    = Color3.fromRGB(255, 255, 255)

    -- Distance tag
    obj.distTag = Drawing.new("Text")
    obj.distTag.Size     = 11
    obj.distTag.Font     = Drawing.Fonts.Plex
    obj.distTag.Center   = true
    obj.distTag.Outline  = true
    obj.distTag.Visible  = false
    obj.distTag.Color    = Color3.fromRGB(200, 200, 200)

    -- Chams: stored as a list of highlight instances
    obj.highlight = Instance.new("Highlight")
    obj.highlight.DepthMode    = Enum.HighlightDepthMode.AlwaysOnTop
    obj.highlight.FillTransparency = 0.6
    obj.highlight.OutlineTransparency = 0
    obj.highlight.Parent = workspace

    espObjects[player] = obj
end

local function removeESP(player)
    local obj = espObjects[player]
    if not obj then return end
    for _, line in ipairs(obj.boxLines) do line:Remove() end
    obj.nameTag:Remove()
    obj.distTag:Remove()
    obj.highlight:Destroy()
    espObjects[player] = nil
end

-- Init existing players
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= lp then makeESP(p) end
end

Players.PlayerAdded:Connect(function(p)
    makeESP(p)
end)

Players.PlayerRemoving:Connect(function(p)
    removeESP(p)
end)

-- ─── Render Loop ──────────────────────────────────────────────────────────────

RunService.RenderStepped:Connect(function()
    for player, obj in pairs(espObjects) do
        local char  = player.Character
        local root  = char and char:FindFirstChild("HumanoidRootPart")
        local hum   = char and char:FindFirstChildOfClass("Humanoid")
        local alive = hum and hum.Health > 0

        if not (char and root and alive) then
            for _, l in ipairs(obj.boxLines) do l.Visible = false end
            obj.nameTag.Visible  = false
            obj.distTag.Visible  = false
            obj.highlight.Adornee = nil
            continue
        end

        local role  = getRole(player)
        local color = roleColor(role)

        -- Chams
        if _G.ChamsESP then
            obj.highlight.Adornee             = char
            obj.highlight.FillColor           = color
            obj.highlight.OutlineColor        = color
        else
            obj.highlight.Adornee = nil
        end

        -- Get screen bounding box
        local hrpPos  = root.Position
        local topPos  = hrpPos + Vector3.new(0, 3, 0)
        local botPos  = hrpPos - Vector3.new(0, 3, 0)

        local topScreen, topVis = camera:WorldToViewportPoint(topPos)
        local botScreen, botVis = camera:WorldToViewportPoint(botPos)

        if not (topVis and botVis) then
            for _, l in ipairs(obj.boxLines) do l.Visible = false end
            obj.nameTag.Visible = false
            obj.distTag.Visible = false
            continue
        end

        local height = math.abs(topScreen.Y - botScreen.Y)
        local width  = height * 0.55

        local x = topScreen.X - width / 2
        local y = topScreen.Y
        local w = width
        local h = height

        -- Box ESP — 4 line rectangle
        if _G.BoxESP then
            local corners = {
                {Vector2.new(x,     y),     Vector2.new(x + w, y)},      -- top
                {Vector2.new(x + w, y),     Vector2.new(x + w, y + h)},  -- right
                {Vector2.new(x + w, y + h), Vector2.new(x,     y + h)},  -- bottom
                {Vector2.new(x,     y + h), Vector2.new(x,     y)},      -- left
            }
            for i, seg in ipairs(corners) do
                obj.boxLines[i].From    = seg[1]
                obj.boxLines[i].To      = seg[2]
                obj.boxLines[i].Color   = color
                obj.boxLines[i].Visible = true
            end
        else
            for _, l in ipairs(obj.boxLines) do l.Visible = false end
        end

        -- Name ESP
        if _G.NameESP then
            obj.nameTag.Text     = player.Name
            obj.nameTag.Color    = color
            obj.nameTag.Position = Vector2.new(topScreen.X, y - 16)
            obj.nameTag.Visible  = true
        else
            obj.nameTag.Visible = false
        end

        -- Distance ESP
        if _G.DistanceESP then
            local dist = math.floor((lp.Character
                and lp.Character:FindFirstChild("HumanoidRootPart")
                and (lp.Character.HumanoidRootPart.Position - hrpPos).Magnitude)
                or 0)
            obj.distTag.Text     = dist .. " studs"
            obj.distTag.Color    = Color3.fromRGB(180, 180, 180)
            obj.distTag.Position = Vector2.new(topScreen.X, y + h + 2)
            obj.distTag.Visible  = true
        else
            obj.distTag.Visible = false
        end
    end
end)
