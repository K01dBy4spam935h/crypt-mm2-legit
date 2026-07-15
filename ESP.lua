-- Crypt-MM2-Legit | ESP — instant role + gun ESP

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

-- ── Role Cache ────────────────────────────────────────────────────────────────

_G.RoleCache = {}
_G.MyRole    = nil

local function setRole(player, role)
    if not player then return end
    _G.RoleCache[player] = role
    if player == lp then _G.MyRole = role end
end

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

-- ── Layer 1: workspace.DescendantAdded — fires INSTANTLY when tool appears ────

workspace.DescendantAdded:Connect(function(desc)
    if not desc:IsA("Tool") then return end
    local name = desc.Name:lower()
    if name ~= "knife" and name ~= "gun" then return end
    task.defer(function()
        local char = desc.Parent
        if not (char and char:IsA("Model")) then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character == char then
                setRole(p, name == "knife" and "Murderer" or "Sheriff")
                return
            end
        end
    end)
end)

workspace.DescendantRemoving:Connect(function(desc)
    if not desc:IsA("Tool") then return end
    local name = desc.Name:lower()
    if name ~= "knife" and name ~= "gun" then return end
    local char = desc.Parent
    if not (char and char:IsA("Model")) then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == char then
            task.defer(function() setRole(p, computeRole(p)) end)
            return
        end
    end
end)

-- ── Layer 2: Hook ALL ReplicatedStorage RemoteEvents ──────────────────────────
-- MM2 fires role-assignment remotes at round start — we catch them here

task.spawn(function()
    local RS = game:GetService("ReplicatedStorage")
    -- Wait for RS to populate
    task.wait(2)

    local function hookRemote(remote)
        pcall(function()
            remote.OnClientEvent:Connect(function(...)
                local args = {...}
                for i, v in ipairs(args) do
                    if type(v) == "string" then
                        local vl = v:lower()
                        if vl == "murderer" or vl == "murder" then
                            -- Role string found — check adjacent args for Player instance
                            for offset = -2, 2 do
                                local candidate = args[i + offset]
                                if typeof(candidate) == "Instance" and candidate:IsA("Player") then
                                    setRole(candidate, "Murderer"); break
                                end
                            end
                        elseif vl == "sheriff" then
                            for offset = -2, 2 do
                                local candidate = args[i + offset]
                                if typeof(candidate) == "Instance" and candidate:IsA("Player") then
                                    setRole(candidate, "Sheriff"); break
                                end
                            end
                        end
                    end
                    -- Also handle table args (MM2 sometimes sends {player=x, role=y})
                    if type(v) == "table" then
                        for k, val in pairs(v) do
                            local key = tostring(k):lower()
                            if key == "role" or key == "team" then
                                local valStr = tostring(val):lower()
                                -- Find player in rest of args
                                for _, arg in ipairs(args) do
                                    if typeof(arg) == "Instance" and arg:IsA("Player") then
                                        if valStr:find("murder") then setRole(arg, "Murderer")
                                        elseif valStr:find("sheriff") then setRole(arg, "Sheriff") end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end)
    end

    for _, obj in ipairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") then hookRemote(obj) end
    end
    RS.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") then hookRemote(obj) end
    end)
end)

-- ── Layer 3: My PlayerGui role announcement (my role instantly) ───────────────

task.spawn(function()
    local pg = lp:WaitForChild("PlayerGui")
    pg.DescendantAdded:Connect(function(desc)
        if not desc:IsA("TextLabel") then return end
        local txt = (desc.Text or ""):upper()
        if txt:find("MURDERER") then
            setRole(lp, "Murderer")
            if _G.Notify then _G.Notify("🔴 You are the Murderer!", "error") end
        elseif txt:find("SHERIFF") then
            setRole(lp, "Sheriff")
            if _G.Notify then _G.Notify("🔵 You are the Sheriff!", "info") end
        elseif txt:find("INNOCENT") then
            setRole(lp, "Innocent")
            if _G.Notify then _G.Notify("⚪ You are Innocent", "info") end
        end
    end)
end)

-- ── Layer 4: periodic scan every 1.5s (safety net) ───────────────────────────

task.spawn(function()
    while task.wait(1.5) do
        for _, p in ipairs(Players:GetPlayers()) do
            local computed = computeRole(p)
            if computed ~= "Innocent" then  -- only update if we found something
                setRole(p, computed)
            elseif not _G.RoleCache[p] then
                setRole(p, "Innocent")  -- set innocent if truly no role found
            end
        end
    end
end)

-- Init
for _, p in ipairs(Players:GetPlayers()) do setRole(p, computeRole(p)) end
Players.PlayerAdded:Connect(function(p)
    task.wait(0.1); setRole(p, computeRole(p))
end)
Players.PlayerRemoving:Connect(function(p) _G.RoleCache[p] = nil end)

-- ── Role color — innocents now GREEN ─────────────────────────────────────────

local function roleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255,  55,  55) end  -- red
    if role == "Sheriff"  then return Color3.fromRGB( 55, 210, 255) end  -- cyan
    return Color3.fromRGB(80, 220, 100)                                   -- green (innocent)
end

-- ── Gun Drop ESP drawing ──────────────────────────────────────────────────────

local gunEspLine = Drawing.new("Line")
gunEspLine.Thickness    = 2
gunEspLine.Color        = Color3.fromRGB(255, 230, 50)
gunEspLine.Visible      = false
gunEspLine.Transparency = 1

local gunEspLabel = Drawing.new("Text")
gunEspLabel.Size    = 13
gunEspLabel.Font    = Drawing.Fonts.Plex
gunEspLabel.Center  = true
gunEspLabel.Outline = true
gunEspLabel.Color   = Color3.fromRGB(255, 230, 50)
gunEspLabel.Visible = false

local function findGunDrop()
    local gun = workspace:FindFirstChild("GunDrop")
    if gun then return gun end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == "Normal" or obj:FindFirstChild("CoinContainer") or obj.Name:match("Map") then
            local hidden = obj:FindFirstChild("GunDrop", true)
            if hidden then return hidden end
        end
    end
    return nil
end

local function getGunPartPos(gunDrop)
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

-- ── ESP Pool ──────────────────────────────────────────────────────────────────

local pool = {}

local function makeESP(player)
    if player == lp or pool[player] then return end
    local obj = {}
    obj.box = {}
    for i = 1, 4 do
        local l = Drawing.new("Line"); l.Thickness = 1.5; l.Visible = false; l.Transparency = 1
        obj.box[i] = l
    end
    obj.name   = Drawing.new("Text"); obj.name.Size=13;  obj.name.Font=Drawing.Fonts.Plex;  obj.name.Center=true;  obj.name.Outline=true;  obj.name.Visible=false
    obj.dist   = Drawing.new("Text"); obj.dist.Size=11;  obj.dist.Font=Drawing.Fonts.Plex;  obj.dist.Center=true;  obj.dist.Outline=true;  obj.dist.Visible=false
    obj.tracer = Drawing.new("Line"); obj.tracer.Thickness=1; obj.tracer.Visible=false; obj.tracer.Transparency=1
    obj.hl     = Instance.new("Highlight"); obj.hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; obj.hl.FillTransparency=1; obj.hl.OutlineTransparency=1; obj.hl.Adornee=nil; obj.hl.Parent=workspace
    pool[player] = obj
end

local function removeESP(player)
    local obj = pool[player]; if not obj then return end
    for _, l in ipairs(obj.box) do pcall(function() l:Remove() end) end
    pcall(function() obj.name:Remove()   end)
    pcall(function() obj.dist:Remove()   end)
    pcall(function() obj.tracer:Remove() end)
    pcall(function() obj.hl:Destroy()    end)
    pool[player] = nil
end

local function hideObj(obj)
    for _, l in ipairs(obj.box) do l.Visible = false end
    obj.name.Visible=false; obj.dist.Visible=false; obj.tracer.Visible=false
    obj.hl.FillTransparency=1; obj.hl.OutlineTransparency=1; obj.hl.Adornee=nil
end

for _, p in ipairs(Players:GetPlayers()) do makeESP(p) end
Players.PlayerAdded:Connect(makeESP)
Players.PlayerRemoving:Connect(removeESP)

-- ── Render ────────────────────────────────────────────────────────────────────

RunService.RenderStepped:Connect(function()
    local botC   = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

    -- Gun Drop ESP
    if _G.GunESP then
        local gunPos = getGunPartPos(findGunDrop())
        if gunPos then
            local sp, vis = camera:WorldToViewportPoint(gunPos)
            if vis then
                local screenPt = Vector2.new(sp.X, sp.Y)
                gunEspLine.From    = botC
                gunEspLine.To      = screenPt
                gunEspLine.Visible = true
                gunEspLabel.Text     = "GunDrop"
                gunEspLabel.Position = Vector2.new(sp.X, sp.Y - 16)
                gunEspLabel.Visible  = true
            else
                gunEspLine.Visible  = false
                gunEspLabel.Visible = false
            end
        else
            gunEspLine.Visible  = false
            gunEspLabel.Visible = false
        end
    else
        gunEspLine.Visible  = false
        gunEspLabel.Visible = false
    end

    -- Player ESP
    for player, obj in pairs(pool) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not (char and root and hum and hum.Health > 0) then
            hideObj(obj); continue
        end

        local role  = _G.RoleCache[player] or "Innocent"
        local color = roleColor(role)

        if _G.ChamsESP then
            obj.hl.Adornee=char; obj.hl.FillColor=color; obj.hl.OutlineColor=color
            obj.hl.FillTransparency=0.55; obj.hl.OutlineTransparency=0
        else
            obj.hl.FillTransparency=1; obj.hl.OutlineTransparency=1; obj.hl.Adornee=nil
        end

        local hSP, hVis = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3.2, 0))
        local fSP, fVis = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.8, 0))
        if not (hVis and fVis) then
            for _, l in ipairs(obj.box) do l.Visible = false end
            obj.name.Visible=false; obj.dist.Visible=false; obj.tracer.Visible=false; continue
        end

        local h=math.abs(hSP.Y-fSP.Y); local w=h*0.5; local x=hSP.X-w/2; local y=hSP.Y

        if _G.BoxESP then
            local segs = {{Vector2.new(x,y),Vector2.new(x+w,y)},{Vector2.new(x+w,y),Vector2.new(x+w,y+h)},{Vector2.new(x+w,y+h),Vector2.new(x,y+h)},{Vector2.new(x,y+h),Vector2.new(x,y)}}
            for i, s in ipairs(segs) do obj.box[i].From=s[1]; obj.box[i].To=s[2]; obj.box[i].Color=color; obj.box[i].Visible=true end
        else for _, l in ipairs(obj.box) do l.Visible = false end end

        if _G.NameESP then
            obj.name.Text=player.Name.." ["..role.."]"; obj.name.Color=color; obj.name.Position=Vector2.new(hSP.X,y-17); obj.name.Visible=true
        else obj.name.Visible=false end

        if _G.DistanceESP and myRoot then
            local d = math.floor((myRoot.Position - root.Position).Magnitude)
            obj.dist.Text=d.." studs"; obj.dist.Color=Color3.fromRGB(180,180,180); obj.dist.Position=Vector2.new(hSP.X,y+h+2); obj.dist.Visible=true
        else obj.dist.Visible=false end

        if _G.Tracers then
            obj.tracer.From=botC; obj.tracer.To=Vector2.new(fSP.X,fSP.Y); obj.tracer.Color=color; obj.tracer.Visible=true
        else obj.tracer.Visible=false end
    end
end)
