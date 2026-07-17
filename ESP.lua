-- Crypt-MM2-Legit | ESP + Role Detection System

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS         = game:GetService("ReplicatedStorage")
local camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

_G.RoleCache   = {}
_G.MyRole      = nil
_G.RoundActive = false

local function setRole(player, role)
    if not player or not role then return end
    local cur = _G.RoleCache[player]
    if (cur=="Murderer" or cur=="Sheriff") and role=="Innocent" then return end
    _G.RoleCache[player] = role
    if player == lp then _G.MyRole = role end
end

-- ── Layer 1: GetPlayerData (MM2 native, best method) ─────────────────────────

local function scanGetPlayerData()
    local fn = RS:FindFirstChild("GetPlayerData", true)
    if not (fn and fn:IsA("RemoteFunction")) then return false end
    local ok, result = pcall(function() return fn:InvokeServer() end)
    if not ok or type(result) ~= "table" then return false end
    for playerKey, data in pairs(result) do
        local target = type(playerKey)=="string" and Players:FindFirstChild(playerKey) or playerKey
        if target and data then
            local role = data.Role or data.role or data.Team or data.team
            if role then
                local r = tostring(role):lower()
                if r:find("murder") then setRole(target,"Murderer"); _G.RoundActive=true
                elseif r:find("sheriff") then setRole(target,"Sheriff"); _G.RoundActive=true
                elseif r:find("innocent") then setRole(target,"Innocent") end
            end
        end
    end
    return true
end

task.spawn(function()
    while task.wait(2) do pcall(scanGetPlayerData) end
end)

-- ── Layer 2: RemoteEvent broadcast hook ───────────────────────────────────────

local hooked = {}
local function hookRemote(remote)
    if hooked[remote] then return end; hooked[remote] = true
    pcall(function()
        remote.OnClientEvent:Connect(function(...)
            local args = {...}; local foundRole, foundPlayer = nil, nil
            for _,v in ipairs(args) do
                if type(v)=="string" then
                    local vl=v:lower()
                    if vl:find("murder") then foundRole="Murderer"
                    elseif vl:find("sheriff") then foundRole="Sheriff"
                    elseif vl=="innocent" then foundRole="Innocent" end
                elseif typeof(v)=="Instance" and v:IsA("Player") then foundPlayer=v
                elseif type(v)=="table" then
                    for k,val in pairs(v) do
                        if tostring(k):lower():find("role") then
                            local vs=tostring(val):lower()
                            if vs:find("murder") then foundRole="Murderer"
                            elseif vs:find("sheriff") then foundRole="Sheriff"
                            elseif vs:find("innocent") then foundRole="Innocent" end
                        end
                        if typeof(val)=="Instance" and val:IsA("Player") then foundPlayer=val end
                    end
                end
            end
            if foundRole then
                setRole(foundPlayer or lp, foundRole)
                if foundRole~="Innocent" then _G.RoundActive=true end
            end
        end)
    end)
end

task.spawn(function()
    task.wait(1)
    for _,obj in ipairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") then hookRemote(obj) end
    end
    RS.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") then hookRemote(obj) end
    end)
end)

-- ── Layer 3: PlayerGui announcement ───────────────────────────────────────────

task.spawn(function()
    local pg = lp:WaitForChild("PlayerGui")
    pg.DescendantAdded:Connect(function(desc)
        if not (desc:IsA("TextLabel") or desc:IsA("TextButton")) then return end
        local txt = (desc.Text or ""):upper()
        if txt:find("MURDERER") and (txt:find("YOU") or (desc.TextSize and desc.TextSize>=16)) then
            setRole(lp,"Murderer"); _G.RoundActive=true
            if _G.Notify then _G.Notify("🔴 You are the Murderer!","error") end
        elseif txt:find("SHERIFF") and (txt:find("YOU") or (desc.TextSize and desc.TextSize>=16)) then
            setRole(lp,"Sheriff"); _G.RoundActive=true
            if _G.Notify then _G.Notify("🔵 You are the Sheriff!","info") end
        elseif txt:find("INNOCENT") and (txt:find("YOU") or (desc.TextSize and desc.TextSize>=16)) then
            setRole(lp,"Innocent"); _G.RoundActive=true
            if _G.Notify then _G.Notify("⚪ You are Innocent","info") end
        end
    end)
end)

-- ── Layer 4: Tool fallback ────────────────────────────────────────────────────

workspace.DescendantAdded:Connect(function(desc)
    if not desc:IsA("Tool") then return end
    local name=desc.Name:lower()
    if name~="knife" and name~="gun" then return end
    task.defer(function()
        local char=desc.Parent
        if not (char and char:IsA("Model")) then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Character==char then
                local ex=_G.RoleCache[p]
                if not ex or ex=="Innocent" then
                    setRole(p, name=="knife" and "Murderer" or "Sheriff")
                end
                _G.RoundActive=true; return
            end
        end
    end)
end)

lp.CharacterAdded:Connect(function()
    task.wait(1); _G.MyRole=nil; _G.RoleCache[lp]=nil; _G.RoundActive=false
end)
Players.PlayerAdded:Connect(function(p) _G.RoleCache[p]=nil end)
Players.PlayerRemoving:Connect(function(p) _G.RoleCache[p]=nil end)
for _,p in ipairs(Players:GetPlayers()) do _G.RoleCache[p]=nil end

-- ── Role color ────────────────────────────────────────────────────────────────

local function roleColor(role)
    if role=="Murderer" then return Color3.fromRGB(255,55,55)  end
    if role=="Sheriff"  then return Color3.fromRGB(55,210,255) end
    return Color3.fromRGB(80,220,100)
end

-- ── Gun Drop drawings ─────────────────────────────────────────────────────────

local gLine  = Drawing.new("Line");  gLine.Thickness=2;  gLine.Color=Color3.fromRGB(255,230,50); gLine.Visible=false; gLine.Transparency=1
local gLabel = Drawing.new("Text");  gLabel.Size=13; gLabel.Font=Drawing.Fonts.Plex; gLabel.Center=true; gLabel.Outline=true; gLabel.Color=Color3.fromRGB(255,230,50); gLabel.Visible=false

local function findGunDrop()
    local g=workspace:FindFirstChild("GunDrop"); if g then return g end
    for _,obj in ipairs(workspace:GetChildren()) do
        if obj.Name=="Normal" or obj:FindFirstChild("CoinContainer") or obj.Name:match("Map") then
            local h=obj:FindFirstChild("GunDrop",true); if h then return h end
        end
    end
end

local function getGunPos(gd)
    if not gd then return nil end
    if gd:IsA("BasePart") then return gd.Position end
    if gd.PrimaryPart then return gd.PrimaryPart.Position end
    local h=gd:FindFirstChild("Handle"); if h then return h.Position end
    for _,c in ipairs(gd:GetChildren()) do if c:IsA("BasePart") then return c.Position end end
end

-- ── ESP Pool ──────────────────────────────────────────────────────────────────

local pool = {}

local function makeESP(p)
    if p==lp or pool[p] then return end
    local obj={}; obj.box={}
    for i=1,4 do local l=Drawing.new("Line"); l.Thickness=1.5; l.Visible=false; l.Transparency=1; obj.box[i]=l end
    obj.name=Drawing.new("Text"); obj.name.Size=13; obj.name.Font=Drawing.Fonts.Plex; obj.name.Center=true; obj.name.Outline=true; obj.name.Visible=false
    obj.dist=Drawing.new("Text"); obj.dist.Size=11; obj.dist.Font=Drawing.Fonts.Plex; obj.dist.Center=true; obj.dist.Outline=true; obj.dist.Visible=false
    obj.tracer=Drawing.new("Line"); obj.tracer.Thickness=1; obj.tracer.Visible=false; obj.tracer.Transparency=1
    obj.hl=Instance.new("Highlight"); obj.hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; obj.hl.FillTransparency=1; obj.hl.OutlineTransparency=1; obj.hl.Adornee=nil; obj.hl.Parent=workspace
    pool[p]=obj
end

local function removeESP(p)
    local obj=pool[p]; if not obj then return end
    for _,l in ipairs(obj.box) do pcall(function() l:Remove() end) end
    pcall(function() obj.name:Remove() end); pcall(function() obj.dist:Remove() end)
    pcall(function() obj.tracer:Remove() end); pcall(function() obj.hl:Destroy() end)
    pool[p]=nil
end

local function hideObj(obj)
    for _,l in ipairs(obj.box) do l.Visible=false end
    obj.name.Visible=false; obj.dist.Visible=false; obj.tracer.Visible=false
    obj.hl.FillTransparency=1; obj.hl.OutlineTransparency=1; obj.hl.Adornee=nil
end

for _,p in ipairs(Players:GetPlayers()) do makeESP(p) end
Players.PlayerAdded:Connect(makeESP)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    local botC=Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y)
    local myRoot=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

    if _G.GunESP then
        local gPos=getGunPos(findGunDrop())
        if gPos then
            local sp,vis=camera:WorldToViewportPoint(gPos)
            if vis then
                gLine.From=botC; gLine.To=Vector2.new(sp.X,sp.Y); gLine.Visible=true
                gLabel.Text="GunDrop"; gLabel.Position=Vector2.new(sp.X,sp.Y-16); gLabel.Visible=true
            else gLine.Visible=false; gLabel.Visible=false end
        else gLine.Visible=false; gLabel.Visible=false end
    else gLine.Visible=false; gLabel.Visible=false end

    for player,obj in pairs(pool) do
        local char=player.Character; local root=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not (char and root and hum and hum.Health>0) then hideObj(obj); continue end
        local role=_G.RoundActive and _G.RoleCache[player] or nil
        local color=roleColor(role)
        if _G.ChamsESP then
            obj.hl.Adornee=char; obj.hl.FillColor=color; obj.hl.OutlineColor=color
            obj.hl.FillTransparency=0.55; obj.hl.OutlineTransparency=0
        else obj.hl.FillTransparency=1; obj.hl.OutlineTransparency=1; obj.hl.Adornee=nil end
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
            local rs=(_G.RoundActive and role) and (" ["..role.."]") or ""
            obj.name.Text=player.Name..rs; obj.name.Color=color; obj.name.Position=Vector2.new(hSP.X,y-17); obj.name.Visible=true
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
