-- Crypt-MM2-Legit | ESP — Multi-layer role detection, tools as fallback only

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS         = game:GetService("ReplicatedStorage")
local camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

-- ── Role Cache ────────────────────────────────────────────────────────────────

_G.RoleCache   = {}  -- [player] = "Murderer" | "Sheriff" | "Innocent"
_G.MyRole      = nil
_G.RoundActive = false

local rolePriority = {Murderer=3, Sheriff=2, Innocent=1}

local function setRole(player, role, priority)
    if not player or not role then return end
    -- Only upgrade if new info is higher priority than what we have
    local current = _G.RoleCache[player]
    local curPri  = (current and rolePriority[current]) or 0
    local newPri  = rolePriority[role] or 0
    -- Always accept Murderer/Sheriff, only accept Innocent if nothing set yet
    if role == "Innocent" and curPri > 1 then return end
    _G.RoleCache[player] = role
    if player == lp then _G.MyRole = role end
end

local function clearRoles()
    _G.RoleCache   = {}
    _G.MyRole      = nil
    _G.RoundActive = false
end

-- ── Layer 1: BillboardGui color scan ─────────────────────────────────────────
-- MM2 places a BillboardGui above each character. The text or frame color
-- reveals role. Murderer = red-ish, Sheriff = blue/teal, Innocent = white/default

local function getBillboardRole(player)
    local char = player.Character
    if not char then return nil end

    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BillboardGui") then
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    local c = child.TextColor3
                    -- Red/orange = murderer
                    if c.R > 0.6 and c.G < 0.35 and c.B < 0.35 then
                        return "Murderer"
                    end
                    -- Blue/teal/cyan = sheriff
                    if c.B > 0.5 and c.R < 0.4 then
                        return "Sheriff"
                    end
                end
                -- Check frame background colors too
                if child:IsA("Frame") or child:IsA("ImageLabel") then
                    local c = child.BackgroundColor3
                    if child.BackgroundTransparency < 0.8 then
                        if c.R > 0.6 and c.G < 0.35 and c.B < 0.35 then
                            return "Murderer"
                        end
                        if c.B > 0.5 and c.R < 0.4 then
                            return "Sheriff"
                        end
                    end
                end
            end
        end
        -- Check for Highlight objects MM2 adds to denote role
        if obj:IsA("Highlight") and obj.Parent == char then
            local c = obj.FillColor
            if c.R > 0.6 and c.G < 0.35 then return "Murderer" end
            if c.B > 0.5 and c.R < 0.4  then return "Sheriff"  end
        end
    end
    return nil
end

-- ── Layer 2: ReplicatedStorage attribute/value scan ───────────────────────────
-- MM2 stores role data in RS folders or player attributes

local function getRSRole(player)
    -- Check player attributes (MM2 sometimes uses these)
    local attr = player:GetAttribute("Role") or player:GetAttribute("role")
    if attr then
        local a = tostring(attr):lower()
        if a:find("murder") then return "Murderer" end
        if a:find("sheriff") then return "Sheriff"  end
        if a:find("innocent") then return "Innocent" end
    end

    -- Check character attributes
    local char = player.Character
    if char then
        local cattr = char:GetAttribute("Role") or char:GetAttribute("role")
        if cattr then
            local a = tostring(cattr):lower()
            if a:find("murder") then return "Murderer" end
            if a:find("sheriff") then return "Sheriff"  end
        end
    end

    -- Check for named StringValue/IntValue in player or char
    for _, name in ipairs({"Role","role","RoleValue","Team","GameRole"}) do
        local v = player:FindFirstChild(name)
                or (player.Character and player.Character:FindFirstChild(name))
        if v and (v:IsA("StringValue") or v:IsA("IntValue")) then
            local val = tostring(v.Value):lower()
            if val:find("murder") then return "Murderer" end
            if val:find("sheriff") then return "Sheriff"  end
            if val:find("innocent") then return "Innocent" end
        end
    end
    return nil
end

-- ── Layer 3: RemoteEvent hook — catches role assignment at round start ─────────

local hookedRemotes = {}

local function hookRemote(remote)
    if hookedRemotes[remote] then return end
    hookedRemotes[remote] = true
    pcall(function()
        remote.OnClientEvent:Connect(function(...)
            local args = {...}

            local function processArgs(list)
                local foundRole, foundPlayer = nil, nil
                for _, v in ipairs(list) do
                    if type(v) == "string" then
                        local vl = v:lower()
                        if vl == "murderer" or vl == "murder" then foundRole = "Murderer"
                        elseif vl == "sheriff" then foundRole = "Sheriff"
                        elseif vl == "innocent" then foundRole = "Innocent" end
                    elseif typeof(v) == "Instance" then
                        if v:IsA("Player") then foundPlayer = v end
                        if v:IsA("Model") then
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p.Character == v then foundPlayer = p; break end
                            end
                        end
                    elseif type(v) == "table" then
                        for k, val in pairs(v) do
                            local ks = tostring(k):lower()
                            if ks:find("role") or ks:find("team") then
                                local vs = tostring(val):lower()
                                if vs:find("murder") then foundRole = "Murderer"
                                elseif vs:find("sheriff") then foundRole = "Sheriff"
                                elseif vs:find("innocent") then foundRole = "Innocent" end
                            end
                            if typeof(val) == "Instance" and val:IsA("Player") then
                                foundPlayer = val
                            end
                        end
                    end
                end
                if foundRole and foundPlayer then
                    setRole(foundPlayer, foundRole)
                    if foundRole ~= "Innocent" then _G.RoundActive = true end
                elseif foundRole == "Murderer" or foundRole == "Sheriff" then
                    -- Role announced without player — must be for local player
                    setRole(lp, foundRole)
                    _G.RoundActive = true
                end
            end

            processArgs(args)
        end)
    end)
end

-- Hook all existing remotes and watch for new ones
task.spawn(function()
    task.wait(1)
    for _, obj in ipairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") then hookRemote(obj) end
    end
    RS.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") then hookRemote(obj) end
    end)
end)

-- ── Layer 4: My PlayerGui role screen scan ────────────────────────────────────

task.spawn(function()
    local pg = lp:WaitForChild("PlayerGui")
    pg.DescendantAdded:Connect(function(desc)
        if not (desc:IsA("TextLabel") or desc:IsA("TextButton")) then return end
        local txt = (desc.Text or ""):upper()
        -- Only fire if it's a full role announcement screen
        if txt:find("YOU ARE") or txt:find("YOU'RE") or desc.TextSize and desc.TextSize >= 18 then
            if txt:find("MURDERER") then
                setRole(lp, "Murderer"); _G.RoundActive = true
                if _G.Notify then _G.Notify("🔴 You are the Murderer!", "error") end
            elseif txt:find("SHERIFF") then
                setRole(lp, "Sheriff"); _G.RoundActive = true
                if _G.Notify then _G.Notify("🔵 You are the Sheriff!", "info") end
            elseif txt:find("INNOCENT") then
                setRole(lp, "Innocent"); _G.RoundActive = true
                if _G.Notify then _G.Notify("⚪ You are Innocent", "info") end
            end
        end
    end)
end)

-- ── Layer 5: workspace.DescendantAdded (instant tool detection as FALLBACK) ────

workspace.DescendantAdded:Connect(function(desc)
    if not desc:IsA("Tool") then return end
    local name = desc.Name:lower()
    if name ~= "knife" and name ~= "gun" then return end
    task.defer(function()
        local char = desc.Parent
        if not (char and char:IsA("Model")) then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character == char then
                -- Only use tool detection if RS/billboard didn't already assign
                local existing = _G.RoleCache[p]
                if not existing or existing == "Innocent" then
                    setRole(p, name == "knife" and "Murderer" or "Sheriff")
                end
                _G.RoundActive = true
                return
            end
        end
    end)
end)

-- ── Layer 6: Round end / lobby detection ─────────────────────────────────────
-- When players respawn into lobby, clear roles

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        -- If character spawns and has no knife/gun and round isn't active, clear their role
        if not _G.RoundActive then
            _G.RoleCache[p] = nil
        end
    end)
end)

-- Watch for round reset — MM2 kills everyone at round end
-- When most players die simultaneously → round ended → clear
lp.CharacterAdded:Connect(function()
    task.wait(1)
    -- Fresh spawn = new round starting or lobby
    -- Clear MY role so it can be reassigned
    _G.MyRole = nil
    _G.RoleCache[lp] = nil
    _G.RoundActive = false
end)

-- Periodic billboard scan every 2s during active round
task.spawn(function()
    while task.wait(2) do
        if not _G.RoundActive then
            -- In lobby — ensure all roles cleared
            for _, p in ipairs(Players:GetPlayers()) do
                _G.RoleCache[p] = nil
            end
            _G.MyRole = nil
        else
            -- Scan billboards for anyone not yet assigned
            for _, p in ipairs(Players:GetPlayers()) do
                if not _G.RoleCache[p] or _G.RoleCache[p] == "Innocent" then
                    local r = getBillboardRole(p) or getRSRole(p)
                    if r then setRole(p, r) end
                end
            end
        end
    end
end)

-- Init
for _, p in ipairs(Players:GetPlayers()) do
    _G.RoleCache[p] = nil
end
Players.PlayerAdded:Connect(function(p) _G.RoleCache[p] = nil end)
Players.PlayerRemoving:Connect(function(p) _G.RoleCache[p] = nil end)

-- ── Role color ────────────────────────────────────────────────────────────────

local function roleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255, 55, 55)  end
    if role == "Sheriff"  then return Color3.fromRGB(55, 210, 255) end
    return Color3.fromRGB(80, 220, 100)
end

-- ── Gun Drop drawings ─────────────────────────────────────────────────────────

local gunLine = Drawing.new("Line")
gunLine.Thickness = 2; gunLine.Color = Color3.fromRGB(255,230,50); gunLine.Visible = false; gunLine.Transparency = 1

local gunLabel = Drawing.new("Text")
gunLabel.Size = 13; gunLabel.Font = Drawing.Fonts.Plex; gunLabel.Center = true; gunLabel.Outline = true
gunLabel.Color = Color3.fromRGB(255,230,50); gunLabel.Visible = false

local gunNotifFired = false

local function findGunDrop()
    local gun = workspace:FindFirstChild("GunDrop")
    if gun then return gun end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == "Normal" or obj:FindFirstChild("CoinContainer") or obj.Name:match("Map") then
            local h = obj:FindFirstChild("GunDrop", true)
            if h then return h end
        end
    end
    return nil
end

local function getGunPos(gunDrop)
    if not gunDrop then return nil end
    if gunDrop:IsA("BasePart") then return gunDrop.Position end
    if gunDrop:IsA("Model") then
        if gunDrop.PrimaryPart then return gunDrop.PrimaryPart.Position end
        local h = gunDrop:FindFirstChild("Handle")
        if h then return h.Position end
        for _, c in ipairs(gunDrop:GetChildren()) do
            if c:IsA("BasePart") then return c.Position end
        end
    end
    return nil
end

-- Gun drop notifier
workspace.ChildAdded:Connect(function(child)
    if child.Name == "GunDrop" then
        if not gunNotifFired then
            gunNotifFired = true
            if _G.Notify then _G.Notify("🔫 Gun dropped — Auto Collect will grab it", "info") end
            task.delay(5, function() gunNotifFired = false end)
        end
    end
end)
workspace.ChildRemoved:Connect(function(child)
    if child.Name == "GunDrop" then gunNotifFired = false end
end)

-- ── ESP Pool ──────────────────────────────────────────────────────────────────

local pool = {}

local function makeESP(player)
    if player == lp or pool[player] then return end
    local obj = {}
    obj.box = {}
    for i=1,4 do
        local l=Drawing.new("Line"); l.Thickness=1.5; l.Visible=false; l.Transparency=1; obj.box[i]=l
    end
    obj.name   = Drawing.new("Text"); obj.name.Size=13; obj.name.Font=Drawing.Fonts.Plex; obj.name.Center=true; obj.name.Outline=true; obj.name.Visible=false
    obj.dist   = Drawing.new("Text"); obj.dist.Size=11; obj.dist.Font=Drawing.Fonts.Plex; obj.dist.Center=true; obj.dist.Outline=true; obj.dist.Visible=false
    obj.tracer = Drawing.new("Line"); obj.tracer.Thickness=1; obj.tracer.Visible=false; obj.tracer.Transparency=1
    obj.hl     = Instance.new("Highlight"); obj.hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; obj.hl.FillTransparency=1; obj.hl.OutlineTransparency=1; obj.hl.Adornee=nil; obj.hl.Parent=workspace
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

for _,p in ipairs(Players:GetPlayers()) do makeESP(p) end
Players.PlayerAdded:Connect(makeESP)
Players.PlayerRemoving:Connect(removeESP)

-- ── Render ────────────────────────────────────────────────────────────────────

RunService.RenderStepped:Connect(function()
    local botC   = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

    -- Gun Drop ESP
    if _G.GunESP then
        local gPos = getGunPos(findGunDrop())
        if gPos then
            local sp, vis = camera:WorldToViewportPoint(gPos)
            if vis then
                local sv = Vector2.new(sp.X, sp.Y)
                gunLine.From=botC; gunLine.To=sv; gunLine.Visible=true
                gunLabel.Text="GunDrop"; gunLabel.Position=Vector2.new(sp.X,sp.Y-16); gunLabel.Visible=true
            else gunLine.Visible=false; gunLabel.Visible=false end
        else gunLine.Visible=false; gunLabel.Visible=false end
    else gunLine.Visible=false; gunLabel.Visible=false end

    -- Player ESP — only show roles when round is active
    for player, obj in pairs(pool) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not (char and root and hum and hum.Health>0) then hideObj(obj); continue end

        -- During lobby, don't show roles
        local role = (_G.RoundActive and _G.RoleCache[player]) or nil
        local color = roleColor(role)

        if _G.ChamsESP then
            obj.hl.Adornee=char; obj.hl.FillColor=color; obj.hl.OutlineColor=color
            obj.hl.FillTransparency=0.55; obj.hl.OutlineTransparency=0
        else
            obj.hl.FillTransparency=1; obj.hl.OutlineTransparency=1; obj.hl.Adornee=nil
        end

        local hSP,hVis=camera:WorldToViewportPoint(root.Position+Vector3.new(0,3.2,0))
        local fSP,fVis=camera:WorldToViewportPoint(root.Position-Vector3.new(0,2.8,0))
        if not (hVis and fVis) then
            for _,l in ipairs(obj.box) do l.Visible=false end
            obj.name.Visible=false; obj.dist.Visible=false; obj.tracer.Visible=false; continue
        end

        local h=math.abs(hSP.Y-fSP.Y); local w=h*0.5; local x=hSP.X-w/2; local y=hSP.Y

        if _G.BoxESP then
            local segs={{Vector2.new(x,y),Vector2.new(x+w,y)},{Vector2.new(x+w,y),Vector2.new(x+w,y+h)},{Vector2.new(x+w,y+h),Vector2.new(x,y+h)},{Vector2.new(x,y+h),Vector2.new(x,y)}}
            for i,s in ipairs(segs) do obj.box[i].From=s[1]; obj.box[i].To=s[2]; obj.box[i].Color=color; obj.box[i].Visible=true end
        else for _,l in ipairs(obj.box) do l.Visible=false end end

        if _G.NameESP then
            local roleStr = (_G.RoundActive and role) and (" ["..role.."]") or ""
            obj.name.Text=player.Name..roleStr; obj.name.Color=color; obj.name.Position=Vector2.new(hSP.X,y-17); obj.name.Visible=true
        else obj.name.Visible=false end

        if _G.DistanceESP and myRoot then
            local d=math.floor((myRoot.Position-root.Position).Magnitude)
            obj.dist.Text=d.." studs"; obj.dist.Color=Color3.fromRGB(180,180,180); obj.dist.Position=Vector2.new(hSP.X,y+h+2); obj.dist.Visible=true
        else obj.dist.Visible=false end

        if _G.Tracers then
            obj.tracer.From=botC; obj.tracer.To=Vector2.new(fSP.X,fSP.Y); obj.tracer.Color=color; obj.tracer.Visible=true
        else obj.tracer.Visible=false end
    end
end)
