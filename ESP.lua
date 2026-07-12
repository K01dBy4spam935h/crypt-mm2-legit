-- Crypt-MM2-Legit | ESP — MM2 fixed role detection

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

-- ─── MM2 Role Detection (Knife = Murderer, Gun = Sheriff) ────────────────────

local function getRole(player)
    local char    = player.Character
    local bp      = player:FindFirstChild("Backpack")

    -- check character first (equipped tool)
    if char then
        if char:FindFirstChild("Knife") then return "Murderer" end
        if char:FindFirstChild("Gun")   then return "Sheriff"  end
    end
    -- check backpack (unequipped tool)
    if bp then
        if bp:FindFirstChild("Knife") then return "Murderer" end
        if bp:FindFirstChild("Gun")   then return "Sheriff"  end
    end
    return "Innocent"
end

local function roleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255, 55, 55)  end
    if role == "Sheriff"  then return Color3.fromRGB(55, 200, 255) end
    return Color3.fromRGB(200, 200, 200)
end

-- ─── ESP Object Pool ─────────────────────────────────────────────────────────

local espObjects = {}

local function makeESP(player)
    if player == lp then return end

    local obj = {}

    -- 4 box lines
    obj.lines = {}
    for i = 1, 4 do
        local l = Drawing.new("Line")
        l.Thickness    = 1.5
        l.Color        = Color3.fromRGB(255, 255, 255)
        l.Visible      = false
        l.Transparency = 1
        obj.lines[i]   = l
    end

    -- Name
    obj.nameTag          = Drawing.new("Text")
    obj.nameTag.Size     = 13
    obj.nameTag.Font     = Drawing.Fonts.Plex
    obj.nameTag.Center   = true
    obj.nameTag.Outline  = true
    obj.nameTag.Visible  = false
    obj.nameTag.Color    = Color3.fromRGB(255, 255, 255)

    -- Distance
    obj.distTag         = Drawing.new("Text")
    obj.distTag.Size    = 11
    obj.distTag.Font    = Drawing.Fonts.Plex
    obj.distTag.Center  = true
    obj.distTag.Outline = true
    obj.distTag.Visible = false
    obj.distTag.Color   = Color3.fromRGB(200, 200, 200)

    -- Chams via Highlight
    obj.hl                      = Instance.new("Highlight")
    obj.hl.DepthMode            = Enum.HighlightDepthMode.AlwaysOnTop
    obj.hl.FillTransparency     = 0.55
    obj.hl.OutlineTransparency  = 0
    obj.hl.Adornee              = nil
    obj.hl.Parent               = workspace

    espObjects[player] = obj
end

local function removeESP(player)
    local obj = espObjects[player]
    if not obj then return end
    for _, l in ipairs(obj.lines) do pcall(function() l:Remove() end) end
    pcall(function() obj.nameTag:Remove() end)
    pcall(function() obj.distTag:Remove() end)
    pcall(function() obj.hl:Destroy() end)
    espObjects[player] = nil
end

local function hideESP(obj)
    for _, l in ipairs(obj.lines) do l.Visible = false end
    obj.nameTag.Visible = false
    obj.distTag.Visible = false
    obj.hl.Adornee      = nil
end

-- init
for _, p in ipairs(Players:GetPlayers()) do makeESP(p) end
Players.PlayerAdded:Connect(makeESP)
Players.PlayerRemoving:Connect(removeESP)

-- re-make ESP when character loads (tools change on respawn)
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not espObjects[p] then makeESP(p) end
    end)
end)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= lp then
        p.CharacterAdded:Connect(function()
            task.wait(0.5)
        end)
    end
end

-- ─── Render Loop ─────────────────────────────────────────────────────────────

RunService.RenderStepped:Connect(function()
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

    for player, obj in pairs(espObjects) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        if not (char and root and hum and hum.Health > 0) then
            hideESP(obj)
            continue
        end

        local role  = getRole(player)
        local color = roleColor(role)

        -- Chams
        if _G.ChamsESP then
            obj.hl.Adornee       = char
            obj.hl.FillColor     = color
            obj.hl.OutlineColor  = color
        else
            obj.hl.Adornee = nil
        end

        -- Screen position of head and feet
        local headPos3, headVis = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3.2, 0))
        local feetPos3, feetVis = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.8, 0))

        if not (headVis and feetVis) then
            for _, l in ipairs(obj.lines) do l.Visible = false end
            obj.nameTag.Visible = false
            obj.distTag.Visible = false
            continue
        end

        local h = math.abs(headPos3.Y - feetPos3.Y)
        local w = h * 0.5
        local x = headPos3.X - w / 2
        local y = headPos3.Y

        -- Box ESP
        if _G.BoxESP then
            local segs = {
                {Vector2.new(x,     y),     Vector2.new(x + w, y)},
                {Vector2.new(x + w, y),     Vector2.new(x + w, y + h)},
                {Vector2.new(x + w, y + h), Vector2.new(x,     y + h)},
                {Vector2.new(x,     y + h), Vector2.new(x,     y)},
            }
            for i, seg in ipairs(segs) do
                obj.lines[i].From    = seg[1]
                obj.lines[i].To      = seg[2]
                obj.lines[i].Color   = color
                obj.lines[i].Visible = true
            end
        else
            for _, l in ipairs(obj.lines) do l.Visible = false end
        end

        -- Name ESP  (shows role too)
        if _G.NameESP then
            obj.nameTag.Text     = player.Name .. " [" .. role .. "]"
            obj.nameTag.Color    = color
            obj.nameTag.Position = Vector2.new(headPos3.X, y - 17)
            obj.nameTag.Visible  = true
        else
            obj.nameTag.Visible  = false
        end

        -- Distance ESP
        if _G.DistanceESP and myRoot then
            local dist = math.floor((myRoot.Position - root.Position).Magnitude)
            obj.distTag.Text     = dist .. " studs"
            obj.distTag.Color    = Color3.fromRGB(180, 180, 180)
            obj.distTag.Position = Vector2.new(headPos3.X, y + h + 3)
            obj.distTag.Visible  = true
        else
            obj.distTag.Visible  = false
        end
    end
end)
