-- Crypt-MM2-Legit | ESP — instant role detection via ChildAdded events

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

-- ── Role Cache — updated INSTANTLY on tool add/remove ─────────────────────────

_G.RoleCache = {}   -- shared with Aimbot and other modules

local function computeRole(player)
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

local function refreshRole(player)
    _G.RoleCache[player] = computeRole(player)
end

local function watchPlayer(player)
    refreshRole(player)

    -- Watch character children
    local function hookChar(char)
        refreshRole(player)
        char.ChildAdded:Connect(function(c)
            if c.Name=="Knife" or c.Name=="Gun" then refreshRole(player) end
        end)
        char.ChildRemoved:Connect(function(c)
            if c.Name=="Knife" or c.Name=="Gun" then refreshRole(player) end
        end)
    end

    if player.Character then hookChar(player.Character) end
    player.CharacterAdded:Connect(function(char)
        task.wait(0.05)
        hookChar(char)
    end)

    -- Watch backpack
    local bp = player:FindFirstChild("Backpack") or player:WaitForChild("Backpack", 5)
    if bp then
        bp.ChildAdded:Connect(function(c)
            if c.Name=="Knife" or c.Name=="Gun" then refreshRole(player) end
        end)
        bp.ChildRemoved:Connect(function(c)
            if c.Name=="Knife" or c.Name=="Gun" then refreshRole(player) end
        end)
    end
end

-- Also do a periodic re-check every 2 seconds as safety net
RunService.Heartbeat:Connect(function()
end)

local function periodicRefresh()
    while true do
        task.wait(2)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then refreshRole(p) end
        end
    end
end
task.spawn(periodicRefresh)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= lp then task.spawn(watchPlayer, p) end
end
Players.PlayerAdded:Connect(function(p) task.spawn(watchPlayer, p) end)
Players.PlayerRemoving:Connect(function(p) _G.RoleCache[p] = nil end)

-- ── Role color ────────────────────────────────────────────────────────────────

local function roleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255, 55, 55)  end
    if role == "Sheriff"  then return Color3.fromRGB(55, 210, 255) end
    return Color3.fromRGB(220, 220, 220)
end

-- ── ESP pool ──────────────────────────────────────────────────────────────────

local pool = {}

local function makeESP(player)
    if player == lp then return end
    if pool[player] then return end

    local obj = {}
    obj.box = {}
    for i=1,4 do
        local l=Drawing.new("Line"); l.Thickness=1.5; l.Visible=false; l.Transparency=1; obj.box[i]=l
    end

    obj.name=Drawing.new("Text"); obj.name.Size=13; obj.name.Font=Drawing.Fonts.Plex; obj.name.Center=true; obj.name.Outline=true; obj.name.Visible=false
    obj.dist=Drawing.new("Text"); obj.dist.Size=11; obj.dist.Font=Drawing.Fonts.Plex; obj.dist.Center=true; obj.dist.Outline=true; obj.dist.Visible=false
    obj.tracer=Drawing.new("Line"); obj.tracer.Thickness=1; obj.tracer.Visible=false; obj.tracer.Transparency=1

    -- Highlight for chams — default FULLY off so no ghost images
    obj.hl=Instance.new("Highlight"); obj.hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; obj.hl.FillTransparency=1; obj.hl.OutlineTransparency=1; obj.hl.Adornee=nil; obj.hl.Parent=workspace

    pool[player] = obj
end

local function removeESP(player)
    local obj = pool[player]; if not obj then return end
    for _,l in ipairs(obj.box) do pcall(function() l:Remove() end) end
    pcall(function() obj.name:Remove() end); pcall(function() obj.dist:Remove() end)
    pcall(function() obj.tracer:Remove() end); pcall(function() obj.hl:Destroy() end)
    pool[player] = nil
end

local function hideObj(obj)
    for _,l in ipairs(obj.box) do l.Visible=false end
    obj.name.Visible=false; obj.dist.Visible=false; obj.tracer.Visible=false
    obj.hl.FillTransparency=1; obj.hl.OutlineTransparency=1; obj.hl.Adornee=nil
end

for _, p in ipairs(Players:GetPlayers()) do makeESP(p) end
Players.PlayerAdded:Connect(makeESP)
Players.PlayerRemoving:Connect(removeESP)

-- ── Render ────────────────────────────────────────────────────────────────────

RunService.RenderStepped:Connect(function()
    local botCenter  = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
    local myRoot     = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

    for player, obj in pairs(pool) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        if not (char and root and hum and hum.Health>0) then
            hideObj(obj); continue
        end

        local role  = _G.RoleCache[player] or computeRole(player)
        local color = roleColor(role)

        -- Chams
        if _G.ChamsESP then
            obj.hl.Adornee=char; obj.hl.FillColor=color; obj.hl.OutlineColor=color
            obj.hl.FillTransparency=0.55; obj.hl.OutlineTransparency=0
        else
            obj.hl.FillTransparency=1; obj.hl.OutlineTransparency=1; obj.hl.Adornee=nil
        end

        local hSP, hVis = camera:WorldToViewportPoint(root.Position + Vector3.new(0,3.2,0))
        local fSP, fVis = camera:WorldToViewportPoint(root.Position - Vector3.new(0,2.8,0))

        if not (hVis and fVis) then
            for _,l in ipairs(obj.box) do l.Visible=false end
            obj.name.Visible=false; obj.dist.Visible=false; obj.tracer.Visible=false; continue
        end

        local h = math.abs(hSP.Y-fSP.Y); local w = h*0.5
        local x = hSP.X-w/2; local y = hSP.Y

        if _G.BoxESP then
            local segs={{Vector2.new(x,y),Vector2.new(x+w,y)},{Vector2.new(x+w,y),Vector2.new(x+w,y+h)},{Vector2.new(x+w,y+h),Vector2.new(x,y+h)},{Vector2.new(x,y+h),Vector2.new(x,y)}}
            for i,s in ipairs(segs) do obj.box[i].From=s[1]; obj.box[i].To=s[2]; obj.box[i].Color=color; obj.box[i].Visible=true end
        else for _,l in ipairs(obj.box) do l.Visible=false end end

        if _G.NameESP then
            obj.name.Text=player.Name.." ["..role.."]"; obj.name.Color=color; obj.name.Position=Vector2.new(hSP.X,y-17); obj.name.Visible=true
        else obj.name.Visible=false end

        if _G.DistanceESP and myRoot then
            local d=math.floor((myRoot.Position-root.Position).Magnitude)
            obj.dist.Text=d.." studs"; obj.dist.Color=Color3.fromRGB(180,180,180); obj.dist.Position=Vector2.new(hSP.X,y+h+2); obj.dist.Visible=true
        else obj.dist.Visible=false end

        if _G.Tracers then
            obj.tracer.From=botCenter; obj.tracer.To=Vector2.new(fSP.X,fSP.Y); obj.tracer.Color=color; obj.tracer.Visible=true
        else obj.tracer.Visible=false end
    end
end)
