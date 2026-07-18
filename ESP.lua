-- Crypt-MM2-Legit | ESP + 2-Step Role Detection

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS         = game:GetService("ReplicatedStorage")
local camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

_G.RoleCache   = {}
_G.MyRole      = nil
_G.RoundActive = false

-- Active highlight pool (matches reference applyESP pattern)
local activeHighlights = {}

local function clearAllESP()
    for char, highlight in pairs(activeHighlights) do
        if highlight then pcall(function() highlight:Destroy() end) end
    end
    activeHighlights = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("RoleESP") then
            pcall(function() player.Character.RoleESP:Destroy() end)
        end
    end
end

-- Re-apply ESP highlight when role is known
local function applyRoleESP(player, role)
    if player == lp then return end
    local char = player.Character; if not char then return end

    -- Remove old highlight if role changed
    local old = char:FindFirstChild("RoleESP")
    if old then old:Destroy() end
    if activeHighlights[char] then
        pcall(function() activeHighlights[char]:Destroy() end)
        activeHighlights[char] = nil
    end

    if not (_G.ChamsESP or _G.BoxESP or _G.NameESP) then return end
    if not _G.RoundActive then return end

    local color
    if role == "Murderer" then color = Color3.fromRGB(255, 35, 35)
    elseif role == "Sheriff" then color = Color3.fromRGB(35, 120, 255)
    else return end  -- don't highlight innocents with role esp

    local highlight = Instance.new("Highlight")
    highlight.Name               = "RoleESP"
    highlight.FillColor          = color
    highlight.OutlineColor       = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency   = 0.4
    highlight.OutlineTransparency = 0
    highlight.Adornee            = char
    highlight.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent             = char
    activeHighlights[char]       = highlight
end

-- ── STEP 1: Instant — GetPlayerData:InvokeServer() ───────────────────────────
-- EXACT reference logic, no modifications to the core scan

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

                    -- Only update if changed
                    if prevRole ~= newRole then
                        _G.RoleCache[targetPlayer] = newRole
                        if targetPlayer == lp then
                            _G.MyRole = newRole
                            -- Instant role notifier
                            if _G.Notify and newRole ~= "Innocent" then
                                local icons = {Murderer="🔴", Sheriff="🔵", Innocent="⚪"}
                                _G.Notify((icons[newRole] or "") .. " You are the " .. newRole .. "!", newRole=="Murderer" and "error" or "info")
                            end
                        end
                        if newRole == "Murderer" or newRole == "Sheriff" then
                            _G.RoundActive = true
                            applyRoleESP(targetPlayer, newRole)
                        end
                    end
                end
            end
        end
    end
end

-- Run Step 1 every 1s — GetPlayerData is not expensive, works well at this rate
task.spawn(function()
    while task.wait(1) do
        pcall(scanGameNetwork)
    end
end)

-- ── STEP 2: Tool verification — checks weapons to confirm/correct Step 1 ──────
-- If GetPlayerData says Innocent but player has knife → override to Murderer
-- If GetPlayerData says Murderer but tool says Gun → switch

local function verifyRolesWithTools()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        local char = player.Character
        local bp   = player:FindFirstChild("Backpack")
        local hasKnife = (char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
        local hasGun   = (char and char:FindFirstChild("Gun"))   or (bp and bp:FindFirstChild("Gun"))

        local toolRole = nil
        if hasKnife then toolRole = "Murderer"
        elseif hasGun then toolRole = "Sheriff" end

        if toolRole then
            local currentRole = _G.RoleCache[player]
            if currentRole ~= toolRole then
                -- Tool verification found a conflict — switch
                _G.RoleCache[player] = toolRole
                _G.RoundActive = true
                applyRoleESP(player, toolRole)
            end
        end
    end
end

task.spawn(function()
    while task.wait(2) do
        pcall(verifyRolesWithTools)
    end
end)

-- ── Tool DescendantAdded for instant tool detection ───────────────────────────

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
                _G.RoleCache[p] = role
                _G.RoundActive  = true
                applyRoleESP(p, role)
                return
            end
        end
    end)
end)

-- ── PlayerGui role announcement — instant MY role detector ────────────────────
-- Fires exactly when StartRound fires, before tools appear

task.spawn(function()
    local pg = lp:WaitForChild("PlayerGui")
    pg.DescendantAdded:Connect(function(desc)
        if not (desc:IsA("TextLabel") or desc:IsA("TextButton")) then return end
        local txt = (desc.Text or ""):upper()
        -- Match MM2's role screen (large text, contains role keyword)
        local isRoleScreen = (desc.TextSize and desc.TextSize >= 14)
            or txt:find("YOU ARE") or txt:find("YOU'RE")

        if not isRoleScreen then return end

        local role = nil
        if txt:find("MURDERER") then role = "Murderer"
        elseif txt:find("SHERIFF") then role = "Sheriff"
        elseif txt:find("INNOCENT") then role = "Innocent" end

        if role then
            _G.MyRole = role
            _G.RoleCache[lp] = role
            if role ~= "Innocent" then _G.RoundActive = true end
            if _G.Notify then
                local icons = {Murderer="🔴", Sheriff="🔵", Innocent="⚪"}
                _G.Notify((icons[role] or "") .. " You are the " .. role .. "!", role=="Murderer" and "error" or "info")
            end
        end
    end)
end)

-- ── Round reset on character spawn ───────────────────────────────────────────

lp.CharacterAdded:Connect(function()
    task.wait(1); _G.MyRole=nil; _G.RoleCache[lp]=nil; _G.RoundActive=false; clearAllESP()
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

-- ── Gun Drop — Chams (Highlight), no tracer ───────────────────────────────────

local gunHighlight = nil
local gunNotifReady = true

local function findGunDrop()
    local g = workspace:FindFirstChild("GunDrop"); if g then return g end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name=="Normal" or obj:FindFirstChild("CoinContainer") or obj.Name:match("Map") then
            local h = obj:FindFirstChild("GunDrop", true); if h then return h end
        end
    end
end

local function updateGunChams()
    local gd = findGunDrop()
    if _G.GunESP and gd then
        if not gunHighlight or not gunHighlight.Parent then
            gunHighlight = Instance.new("Highlight")
            gunHighlight.FillColor          = Color3.fromRGB(255, 230, 50)
            gunHighlight.OutlineColor       = Color3.fromRGB(255, 255, 255)
            gunHighlight.FillTransparency   = 0.3
            gunHighlight.OutlineTransparency = 0
            gunHighlight.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
            gunHighlight.Adornee            = gd
            gunHighlight.Parent             = workspace
        else
            gunHighlight.Adornee = gd
        end
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
        gunNotifReady = false
        task.delay(1, function() gunNotifReady = true end)
    end
end)

-- ── ESP Pool ──────────────────────────────────────────────────────────────────

local pool = {}

local function makeESP(p)
    if p == lp or pool[p] then return end
    local obj = {}; obj.box = {}
    for i=1,4 do local l=Drawing.new("Line"); l.Thickness=1.5; l.Visible=false; l.Transparency=1; obj.box[i]=l end
    obj.name   = Drawing.new("Text"); obj.name.Size=13; obj.name.Font=Drawing.Fonts.Plex; obj.name.Center=true; obj.name.Outline=true; obj.name.Visible=false
    obj.dist   = Drawing.new("Text"); obj.dist.Size=11; obj.dist.Font=Drawing.Fonts.Plex; obj.dist.Center=true; obj.dist.Outline=true; obj.dist.Visible=false
    obj.tracer = Drawing.new("Line"); obj.tracer.Thickness=1; obj.tracer.Visible=false; obj.tracer.Transparency=1
    pool[p] = obj
end

local function removeESP(p)
    local obj=pool[p]; if not obj then return end
    for _,l in ipairs(obj.box) do pcall(function() l:Remove() end) end
    pcall(function() obj.name:Remove() end); pcall(function() obj.dist:Remove() end)
    pcall(function() obj.tracer:Remove() end)
    pool[p] = nil
end

local function hideObj(obj)
    for _,l in ipairs(obj.box) do l.Visible=false end
    obj.name.Visible=false; obj.dist.Visible=false; obj.tracer.Visible=false
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

        local hSP,hVis = camera:WorldToViewportPoint(root.Position+Vector3.new(0,3.2,0))
        local fSP,fVis = camera:WorldToViewportPoint(root.Position-Vector3.new(0,2.8,0))
        if not (hVis and fVis) then hideObj(obj); continue end

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

        if _G.Tracers then
            obj.tracer.From=botC; obj.tracer.To=Vector2.new(fSP.X,fSP.Y); obj.tracer.Color=color; obj.tracer.Visible=true
        else obj.tracer.Visible=false end
    end
end)
