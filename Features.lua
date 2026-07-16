-- Crypt-MM2-Legit | Features

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer

-- ── Hitbox Expander ───────────────────────────────────────────────────────────

local origSizes = {}

RunService.Heartbeat:Connect(function()
    for _,player in ipairs(Players:GetPlayers()) do
        if player==lp then continue end
        local char=player.Character; if not char then continue end
        if _G.HitboxEnabled then
            if not origSizes[player] then origSizes[player]={} end
            local sz=_G.HitboxSize or 6
            for _,part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if not origSizes[player][part] then origSizes[player][part]=part.Size end
                    part.Size=Vector3.new(sz,sz,sz); part.CanCollide=false; part.LocalTransparencyModifier=1
                end
            end
        else
            if origSizes[player] then
                for part,sz in pairs(origSizes[player]) do
                    pcall(function() part.Size=sz; part.CanCollide=true; part.LocalTransparencyModifier=0 end)
                end
                origSizes[player]=nil
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p) origSizes[p]=nil end)

-- ── Knife Aura — equips knife then fires touch ────────────────────────────────
-- "Show Murderer Marker" = draws an arrow/indicator on screen pointing at
-- the murderer's location so sheriff can track them even through walls

local auraCD=0

local function equipKnife()
    local char=lp.Character; if not char then return nil end
    local knife=char:FindFirstChild("Knife")
    if knife then return knife end
    -- Try to equip from backpack
    local bp=lp:FindFirstChild("Backpack")
    if bp then
        local bKnife=bp:FindFirstChild("Knife")
        if bKnife then
            -- Equip by humanoid
            local hum=char:FindFirstChildOfClass("Humanoid")
            if hum then hum:EquipTool(bKnife) end
            task.wait(0.1)
            return char:FindFirstChild("Knife")
        end
    end
    return nil
end

RunService.Heartbeat:Connect(function(dt)
    if not _G.KnifeAura then return end
    auraCD=auraCD-dt; if auraCD>0 then return end
    auraCD=0.08+math.random()*0.04

    local char=lp.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local range=_G.KnifeAuraRange or 15

    -- Auto-equip knife if not in hand
    local knife=char:FindFirstChild("Knife") or equipKnife()
    if not knife then return end
    local handle=knife:FindFirstChild("Handle"); if not handle then return end

    for _,player in ipairs(Players:GetPlayers()) do
        if player==lp then continue end
        local pChar=player.Character; if not pChar then continue end
        local pHum=pChar:FindFirstChildOfClass("Humanoid"); if not pHum or pHum.Health<=0 then continue end
        local pRoot=pChar:FindFirstChild("HumanoidRootPart"); if not pRoot then continue end
        if (hrp.Position-pRoot.Position).Magnitude<=range then
            -- Activate tool (swing animation) + firetouchinterest
            pcall(function() knife:Activate() end)
            for _,part in ipairs(pChar:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        firetouchinterest(handle,part,0)
                        firetouchinterest(handle,part,1)
                    end)
                end
            end
        end
    end
end)

-- ── Auto Stab ────────────────────────────────────────────────────────────────

local stabCD=0
RunService.Heartbeat:Connect(function(dt)
    if not _G.AutoStab then return end
    stabCD=stabCD-dt; if stabCD>0 then return end
    local char=lp.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local knife=char:FindFirstChild("Knife") or equipKnife(); if not knife then return end
    local handle=knife:FindFirstChild("Handle"); if not handle then return end
    local range=_G.KnifeAuraRange or 15
    local closest,closestD=nil,range
    for _,player in ipairs(Players:GetPlayers()) do
        if player==lp then continue end
        local pChar=player.Character; if not pChar then continue end
        local pHum=pChar:FindFirstChildOfClass("Humanoid"); if not pHum or pHum.Health<=0 then continue end
        local pRoot=pChar:FindFirstChild("HumanoidRootPart"); if not pRoot then continue end
        local d=(hrp.Position-pRoot.Position).Magnitude
        if d<closestD then closestD=d; closest=pChar end
    end
    if closest then
        pcall(function() knife:Activate() end)
        for _,part in ipairs(closest:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() firetouchinterest(handle,part,0); firetouchinterest(handle,part,1) end)
            end
        end
        stabCD=0.35+math.random()*0.15
    end
end)

-- ── Silent Aim (Sheriff) — hitbox-based bullet redirect ───────────────────────
-- Expands murderer hitbox massively so any shot hits without camera movement
-- This is "redirect the bullet" via making the target impossible to miss

local silentOrigSizes = {}

RunService.Heartbeat:Connect(function()
    for _,player in ipairs(Players:GetPlayers()) do
        if player==lp then continue end
        local char=player.Character; if not char then continue end
        local role=_G.RoleCache and _G.RoleCache[player]
        local isSilentTarget=_G.SilentAim and role=="Murderer"

        local root=char:FindFirstChild("HumanoidRootPart"); if not root then continue end

        if isSilentTarget then
            if not silentOrigSizes[player] then silentOrigSizes[player]=root.Size end
            local sz=_G.SilentAimSize or 30
            root.Size=Vector3.new(sz,sz,sz)
            root.CanCollide=false
            root.LocalTransparencyModifier=1
        else
            if silentOrigSizes[player] then
                pcall(function()
                    root.Size=silentOrigSizes[player]
                    root.CanCollide=true
                    root.LocalTransparencyModifier=0
                end)
                silentOrigSizes[player]=nil
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p) silentOrigSizes[p]=nil end)

-- ── Murderer Marker (Show Murderer Marker) ────────────────────────────────────
-- Draws an arrow at top of screen pointing toward murderer's position
-- Also shows distance. Helps sheriff track murderer without looking at them.

local markerArrow = Drawing.new("Triangle")
markerArrow.Color     = Color3.fromRGB(255, 55, 55)
markerArrow.Filled    = true
markerArrow.Visible   = false
markerArrow.Transparency = 1

local markerDist = Drawing.new("Text")
markerDist.Size    = 13
markerDist.Font    = Drawing.Fonts.Plex
markerDist.Center  = true
markerDist.Outline = true
markerDist.Color   = Color3.fromRGB(255, 55, 55)
markerDist.Visible = false

RunService.RenderStepped:Connect(function()
    if not _G.MurdererArrow then
        markerArrow.Visible=false; markerDist.Visible=false; return
    end

    local murdPos=nil; local murdDist=0
    local myRoot=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then markerArrow.Visible=false; markerDist.Visible=false; return end

    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        if (_G.RoleCache and _G.RoleCache[p])=="Murderer" then
            local pR=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if pR then murdPos=pR.Position; murdDist=math.floor((myRoot.Position-pR.Position).Magnitude); break end
        end
    end

    if not murdPos then markerArrow.Visible=false; markerDist.Visible=false; return end

    local cam=workspace.CurrentCamera
    local sp, onScreen = cam:WorldToViewportPoint(murdPos)

    -- Always show indicator at edge of screen pointing toward murderer
    local vp=cam.ViewportSize
    local cx,cy=vp.X/2, vp.Y/2

    if onScreen then
        -- On screen: draw at their position
        local ax,ay=sp.X,math.max(sp.Y-60, 20)
        markerArrow.PointA=Vector2.new(ax,ay+16); markerArrow.PointB=Vector2.new(ax-8,ay); markerArrow.PointC=Vector2.new(ax+8,ay)
        markerArrow.Visible=true
        markerDist.Text=murdDist.." studs"; markerDist.Position=Vector2.new(ax,ay-16); markerDist.Visible=true
    else
        -- Off screen: point arrow at edge toward murderer
        local dir=Vector2.new(sp.X-cx, sp.Y-cy).Unit
        local edgeX=math.clamp(cx+dir.X*200, 40, vp.X-40)
        local edgeY=math.clamp(cy+dir.Y*200, 40, vp.Y-40)
        local angle=math.atan2(dir.Y, dir.X)
        local size=12
        local p1=Vector2.new(edgeX+math.cos(angle)*size, edgeY+math.sin(angle)*size)
        local p2=Vector2.new(edgeX+math.cos(angle+2.4)*size, edgeY+math.sin(angle+2.4)*size)
        local p3=Vector2.new(edgeX+math.cos(angle-2.4)*size, edgeY+math.sin(angle-2.4)*size)
        markerArrow.PointA=p1; markerArrow.PointB=p2; markerArrow.PointC=p3; markerArrow.Visible=true
        markerDist.Text=murdDist.." studs"; markerDist.Position=Vector2.new(edgeX, edgeY-20); markerDist.Visible=true
    end
end)
