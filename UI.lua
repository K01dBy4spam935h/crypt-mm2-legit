-- Crypt-MM2-Legit | ESP + 2-Step Role Detection

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS         = game:GetService("ReplicatedStorage")
local camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

_G.RoleCache   = {}
_G.MyRole      = nil
_G.RoundActive = false

-- ── Lobby detection on execute ────────────────────────────────────────────────
-- If in lobby when script loads, set self as Innocent immediately

task.spawn(function()
    task.wait(1)
    -- Check MM2 timer text — if it says lobby/waiting, we're in lobby
    local localGui = lp:FindFirstChild("PlayerGui")
    local mainGui  = localGui and localGui:FindFirstChild("MainGui")
    local gameUI   = mainGui and mainGui:FindFirstChild("Game")
    local timerTxt = gameUI and gameUI:FindFirstChild("Timer")

    local inLobby = true

    if timerTxt and timerTxt:IsA("TextLabel") then
        local t = timerTxt.Text:lower()
        if not (t:find("lobby") or t:find("wait") or t == "00:00" or t == "") then
            inLobby = false
        end
    end

    -- Also check if GetPlayerData returns roles
    local fn = RS:FindFirstChild("GetPlayerData", true)
    if fn and fn:IsA("RemoteFunction") then
        local ok, result = pcall(function() return fn:InvokeServer() end)
        if ok and type(result) == "table" then
            for _, data in pairs(result) do
                if data and (data.Role == "Murderer" or data.Role == "Sheriff") then
                    inLobby = false; break
                end
            end
        end
    end

    if inLobby then
        _G.MyRole = "Innocent"
        _G.RoleCache[lp] = "Innocent"
        _G.RoundActive = false
        if _G.Notify then _G.Notify("⚪ In lobby — role: Innocent", "info") end
    end
end)

-- ── Role highlight pool (separate from ESP box pool) ─────────────────────────

local activeHighlights = {}

local function clearAllHighlights()
    for char, hl in pairs(activeHighlights) do
        if hl then pcall(function() hl:Destroy() end) end
    end
    activeHighlights = {}
end

-- Apply role-colored highlight — used for Murderer/Sheriff chams
local function applyRoleHighlight(player, role)
    if player == lp then return end
    local char = player.Character; if not char then return end

    local existing = activeHighlights[char]
    if existing then pcall(function() existing:Destroy() end); activeHighlights[char] = nil end

    if not _G.ChamsESP then return end
    if not _G.RoundActive then return end

    local color
    if role == "Murderer" then color = Color3.fromRGB(255, 35, 35)
    elseif role == "Sheriff" then color = Color3.fromRGB(35, 120, 255)
    else color = Color3.fromRGB(80, 220, 100) end   -- innocent = green

    local hl = Instance.new("Highlight")
    hl.Name               = "RoleESP"
    hl.FillColor          = color
    hl.OutlineColor       = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency   = 0.4
    hl.OutlineTransparency = 0
    hl.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee            = char
    hl.Parent             = char
    activeHighlights[char] = hl
end

-- ── STEP 1: Instant — GetPlayerData:InvokeServer() exact reference logic ──────

local function scanGameNetwork()
    local playerDataFunction = RS:FindFirstChild("GetPlayerData", true)
    if playerDataFunction and playerDataFunction:IsA("RemoteFunction") then
        local success, roleTable = pcall(function()
            return playerDataFunction:InvokeServer()
        end)
        if success and type(roleTable) == "table" then
            for playerInstance, data in pairs(roleTable) do
                local targetPlayer = type(playerInstance) == "string"
                    and Players:FindFirstChild(playerInstance)
                    or  playerInstance
                if targetPlayer and data and data.Role then
                    local prevRole = _G.RoleCache[targetPlayer]
                    local newRole  = data.Role

                    if prevRole ~= newRole then
                        _G.RoleCache[targetPlayer] = newRole
                        if targetPlayer == lp then
                            _G.MyRole = newRole
                            if _G.Notify and not _G._RoleNotified then
                                _G._RoleNotified = true
                                local icons = {Murderer="🔴", Sheriff="🔵", Innocent="⚪"}
                                _G.Notify((icons[newRole] or "").. " You are the " .. newRole .. "!", newRole=="Murderer" and "error" or "info")
                            end
                        end
                        if newRole == "Murderer" or newRole == "Sheriff" then
                            _G.RoundActive = true
                        end
                        applyRoleHighlight(targetPlayer, newRole)
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(1) do pcall(scanGameNetwork) end
end)

-- Reset notifier each round
lp.CharacterAdded:Connect(function()
    task.wait(0.5); _G._RoleNotified = false
end)

-- ── STEP 2: Tool verification — confirms or corrects Step 1 ─────────────────

local function verifyRolesWithTools()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        local char = player.Character
        local bp   = player:FindFirstChild("Backpack")
        local hasKnife = (char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
        local hasGun   = (char and char:FindFirstChild("Gun"))   or (bp and bp:FindFirstChild("Gun"))
        local toolRole = hasKnife and "Murderer" or (hasGun and "Sheriff" or nil)
        if toolRole and _G.RoleCache[player] ~= toolRole then
            _G.RoleCache[player] = toolRole
            _G.RoundActive = true
            applyRoleHighlight(player, toolRole)
        end
    end
end

task.spawn(function()
    while task.wait(2) do pcall(verifyRolesWithTools) end
end)

-- ── Workspace DescendantAdded — instant tool fallback ────────────────────────

workspace.DescendantAdded:Connect(function(desc)
    if not desc:IsA("Tool") then return end
    local name = desc.Name:lower()
    if name ~= "knife" and name ~= "gun" then return end
    task.defer(function()
        local char = desc.Parent
        if not (char and char:IsA("Model")) then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character == char then
                local role = name == "knife" and "Murderer" or "Sheriff"
                if _G.RoleCache[p] ~= role then
                    _G.RoleCache[p] = role
                    _G.RoundActive  = true
                    applyRoleHighlight(p, role)
                end
                return
            end
        end
    end)
end)

-- ── PlayerGui role announcement — instant MY role ────────────────────────────

task.spawn(function()
    local pg = lp:WaitForChild("PlayerGui")
    pg.DescendantAdded:Connect(function(desc)
        if not (desc:IsA("TextLabel") or desc:IsA("TextButton")) then return end
        local txt = (desc.Text or ""):upper()
        local isRoleScreen = (desc.TextSize and desc.TextSize >= 14)
            or txt:find("YOU ARE") or txt:find("YOU'RE")
        if not isRoleScreen then return end

        local role = nil
        if txt:find("MURDERER") then role = "Murderer"
        elseif txt:find("SHERIFF") then role = "Sheriff"
        elseif txt:find("INNOCENT") then role = "Innocent" end

        if role then
            _G.MyRole = role; _G.RoleCache[lp] = role
            if role ~= "Innocent" then _G.RoundActive = true end
            if _G.Notify and not _G._RoleNotified then
                _G._RoleNotified = true
                local icons = {Murderer="🔴", Sheriff="🔵", Innocent="⚪"}
                _G.Notify((icons[role] or "") .. " You are the " .. role .. "!", role=="Murderer" and "error" or "info")
            end
        end
    end)
end)

-- ── Round reset ───────────────────────────────────────────────────────────────

lp.CharacterAdded:Connect(function()
    task.wait(1)
    _G.MyRole = nil; _G.RoleCache[lp] = nil; _G.RoundActive = false
    clearAllHighlights()
end)

Players.PlayerAdded:Connect(function(p) _G.RoleCache[p] = nil end)
Players.PlayerRemoving:Connect(function(p)
    _G.RoleCache[p] = nil
    if p.Character and activeHighlights[p.Character] then
        pcall(function() activeHighlights[p.Character]:Destroy() end)
        activeHighlights[p.Character] = nil
    end
end)
for _, p in ipairs(Players:GetPlayers()) do _G.RoleCache[p] = nil end

-- ── Role color ────────────────────────────────────────────────────────────────

local function roleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255, 55, 55)  end
    if role == "Sheriff"  then return Color3.fromRGB(55, 210, 255) end
    return Color3.fromRGB(80, 220, 100)
end

-- ── Gun Drop Chams — Highlight, no tracer ─────────────────────────────────────

local gunHighlight  = nil
local gunNotifReady = true

local function findGunDrop()
    local g = workspace:FindFirstChild("GunDrop"); if g then return g end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name=="Normal" or obj:FindFirstChild("CoinContainer") or obj.Name:match("Map") then
            local h = obj:FindFirstChild("GunDrop",true); if h then return h end
        end
    end
end

local function updateGunChams()
    local gd = findGunDrop()
    if _G.GunESP and gd then
        if not (gunHighlight and gunHighlight.Parent) then
            if gunHighlight then pcall(function() gunHighlight:Destroy() end) end
            gunHighlight = Instance.new("Highlight")
            gunHighlight.FillColor          = Color3.fromRGB(255, 230, 50)
            gunHighlight.OutlineColor       = Color3.fromRGB(255, 255, 255)
            gunHighlight.FillTransparency   = 0.3
            gunHighlight.OutlineTransparency = 0
            gunHighlight.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
            gunHighlight.Parent             = workspace
        end
        gunHighlight.Adornee = gd
    else
        if gunHighlight then gunHighlight.Adornee = nil end
    end
end

workspace.ChildAdded:Connect(function(child)
    if child.Name == "GunDrop" and gunNotifReady and _G.GunDropNotif then
        gunNotifReady = false
        if _G.Notify then _G.Notify("🔫 Gun dropped!", "info") end
        task.delay(5, function() gunNotifReady = true end)
    end
end)

workspace.ChildRemoved:Connect(function(child)
    if child.Name == "GunDrop" then
        if gunHighlight then gunHighlight.Adornee = nil end
        task.delay(1, function() gunNotifReady = true end)
    end
end)

-- ── Chams for ALL players ─────────────────────────────────────────────────────
-- Pool handles box/name/dist drawing
-- Chams (Highlight) applied per-player based on role during render

local pool = {}

local function makeESP(p)
    if p == lp or pool[p] then return end
    local obj = {}; obj.box = {}
    for i=1,4 do local l=Drawing.new("Line"); l.Thickness=1.5; l.Visible=false; l.Transparency=1; obj.box[i]=l end
    obj.name   = Drawing.new("Text"); obj.name.Size=13; obj.name.Font=Drawing.Fonts.Plex; obj.name.Center=true; obj.name.Outline=true; obj.name.Visible=false
    obj.dist   = Drawing.new("Text"); obj.dist.Size=11; obj.dist.Font=Drawing.Fonts.Plex; obj.dist.Center=true; obj.dist.Outline=true; obj.dist.Visible=false
    obj.tracer = Drawing.new("Line"); obj.tracer.Thickness=1; obj.tracer.Visible=false; obj.tracer.Transparency=1
    -- Per-player highlight for full chams on EVERYONE
    obj.hl = Instance.new("Highlight")
    obj.hl.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
    obj.hl.FillTransparency   = 1
    obj.hl.OutlineTransparency = 1
    obj.hl.Adornee            = nil
    obj.hl.Parent             = workspace
    pool[p] = obj
end

local function removeESP(p)
    local obj = pool[p]; if not obj then return end
    for _,l in ipairs(obj.box) do pcall(function() l:Remove() end) end
    pcall(function() obj.name:Remove() end)
    pcall(function() obj.dist:Remove() end)
    pcall(function() obj.tracer:Remove() end)
    pcall(function() obj.hl:Destroy() end)
    pool[p] = nil
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
    local botC   = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

    updateGunChams()

    for player, obj in pairs(pool) do
        local char = player.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not (char and root and hum and hum.Health > 0) then hideObj(obj); continue end

        local role  = _G.RoundActive and _G.RoleCache[player] or nil
        local color = roleColor(role)

        -- Chams: highlights ALL players when ChamsESP is on
        -- Murderer = red, Sheriff = cyan, Innocent = green
        if _G.ChamsESP then
            obj.hl.Adornee            = char
            obj.hl.FillColor          = color
            obj.hl.OutlineColor       = Color3.fromRGB(255,255,255)
            obj.hl.FillTransparency   = 0.45
            obj.hl.OutlineTransparency = 0
        else
            obj.hl.FillTransparency   = 1
            obj.hl.OutlineTransparency = 1
            obj.hl.Adornee            = nil
        end

        local hSP,hVis = camera:WorldToViewportPoint(root.Position+Vector3.new(0,3.2,0))
        local fSP,fVis = camera:WorldToViewportPoint(root.Position-Vector3.new(0,2.8,0))
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
            local rs = (_G.RoundActive and role) and (" ["..role.."]") or ""
            obj.name.Text=player.Name..rs; obj.name.Color=color; obj.name.Position=Vector2.new(hSP.X,y-17); obj.name.Visible=true
        else obj.name.Visible=false end

        if _G.DistanceESP and myRoot then
            local d=math.floor((myRoot.Position-root.Position).Magnitude)
            obj.dist.Text=d.." studs"; obj.dist.Color=Color3.fromRGB(180,180,180); obj.dist.Position=Vector2.new(hSP.X,y+h+2); obj.dist.Visible=true
        else obj.dist.Visible=false end

        -- No tracers (removed as requested)
        obj.tracer.Visible=false
    end
end)
