-- Crypt-MM2-Legit | Movement

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UserInput   = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local lp          = Players.LocalPlayer
local BASE_SPEED  = 16

-- ── Noclip ────────────────────────────────────────────────────────────────────

local noclipConn=nil; local lastNoclip=false

local function setNoclip(on)
    if on then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn=RunService.Stepped:Connect(function()
            local char=lp.Character; if not char then return end
            for _,p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=false end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
        task.defer(function()
            local char=lp.Character; if not char then return end
            for _,p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=true end
            end
        end)
    end
end

RunService.Heartbeat:Connect(function()
    local now=_G.NoclipEnabled or false
    if now~=lastNoclip then lastNoclip=now; setNoclip(now) end
end)
lp.CharacterAdded:Connect(function() task.wait(0.2); if _G.NoclipEnabled then setNoclip(true) end end)

-- ── Speed ─────────────────────────────────────────────────────────────────────

RunService.Heartbeat:Connect(function()
    local char=lp.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local mult=math.clamp(_G.SpeedMultiplier or 1,1,100)
    local tgt=_G.SpeedEnabled and (BASE_SPEED*mult) or BASE_SPEED
    hum.WalkSpeed=hum.WalkSpeed+(tgt-hum.WalkSpeed)*0.18
end)

-- ── Infinite Jump ─────────────────────────────────────────────────────────────

UserInput.JumpRequest:Connect(function()
    if not _G.InfJumpEnabled then return end
    local char=lp.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- ── Fly ───────────────────────────────────────────────────────────────────────

local flyConn=nil; local lastFly=false

local function applyFly(on)
    local char=lp.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local oldBV=hrp:FindFirstChild("CryptBV"); if oldBV then oldBV:Destroy() end
    local oldBG=hrp:FindFirstChild("CryptBG"); if oldBG then oldBG:Destroy() end
    if flyConn then flyConn:Disconnect(); flyConn=nil end
    if not on then hum.PlatformStand=false; return end
    hum.PlatformStand=true
    local bv=Instance.new("BodyVelocity"); bv.Name="CryptBV"; bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Velocity=Vector3.zero; bv.Parent=hrp
    local bg=Instance.new("BodyGyro"); bg.Name="CryptBG"; bg.MaxTorque=Vector3.new(1e5,1e5,1e5); bg.CFrame=hrp.CFrame; bg.Parent=hrp
    flyConn=RunService.RenderStepped:Connect(function()
        if not _G.FlyEnabled then return end
        local cam=workspace.CurrentCamera; local speed=_G.FlySpeed or 60; local dir=Vector3.zero
        if UserInput:IsKeyDown(Enum.KeyCode.W) then dir=dir+cam.CFrame.LookVector  end
        if UserInput:IsKeyDown(Enum.KeyCode.S) then dir=dir-cam.CFrame.LookVector  end
        if UserInput:IsKeyDown(Enum.KeyCode.A) then dir=dir-cam.CFrame.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.D) then dir=dir+cam.CFrame.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.Space)       then dir=dir+Vector3.new(0,1,0) end
        if UserInput:IsKeyDown(Enum.KeyCode.LeftControl) then dir=dir-Vector3.new(0,1,0) end
        bv.Velocity=dir.Magnitude>0 and dir.Unit*speed or Vector3.zero; bg.CFrame=cam.CFrame
    end)
end

RunService.Heartbeat:Connect(function()
    local now=_G.FlyEnabled or false
    if now~=lastFly then lastFly=now; applyFly(now) end
end)
lp.CharacterAdded:Connect(function() task.wait(0.3); lastFly=false; if _G.FlyEnabled then applyFly(true) end end)
_G.SetFly=applyFly

-- ── Invisibility — reapplied every single Heartbeat ───────────────────────────

local invisHL=nil; local lastInvis=false

RunService.Heartbeat:Connect(function()
    local on=_G.InvisEnabled or false
    local char=lp.Character; if not char then return end

    if on then
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                p.Transparency=1
            end
            if p:IsA("Decal") then pcall(function() p.Transparency=1 end) end
        end
        if not (invisHL and invisHL.Parent) then
            invisHL=Instance.new("Highlight")
            invisHL.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
            invisHL.FillTransparency=1; invisHL.OutlineTransparency=0.1
            invisHL.OutlineColor=Color3.fromRGB(255,255,255)
            invisHL.Adornee=char; invisHL.Parent=char
        end
        if not lastInvis then
            lastInvis=true
            for _,acc in ipairs(char:GetChildren()) do
                if acc:IsA("Accessory") then acc:Destroy() end
            end
            if _G.Notify then _G.Notify("Invisibility ON","success") end
        end
    else
        if lastInvis then
            lastInvis=false
            if invisHL then invisHL:Destroy(); invisHL=nil end
            if _G.Notify then _G.Notify("Rejoin to restore appearance","warn") end
        end
    end
end)

lp.CharacterAdded:Connect(function()
    task.wait(0.3); lastInvis=false
    if invisHL then invisHL:Destroy(); invisHL=nil end
end)

-- ── Auto Gun ─────────────────────────────────────────────────────────────────

local function findGunDrop()
    local g=workspace:FindFirstChild("GunDrop"); if g then return g end
    for _,obj in ipairs(workspace:GetChildren()) do
        if obj.Name=="Normal" or obj:FindFirstChild("CoinContainer") or obj.Name:match("Map") then
            local h=obj:FindFirstChild("GunDrop",true); if h then return h end
        end
    end
end

local function getGunPart(gd)
    if not gd then return nil end
    if gd:IsA("BasePart") then return gd end
    if gd:FindFirstChild("Handle") then return gd.Handle end
    for _,c in ipairs(gd:GetChildren()) do if c:IsA("BasePart") then return c end end
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if not _G.AutoGun then continue end
        local char=lp.Character; if not char then continue end
        local root=char:FindFirstChild("HumanoidRootPart"); if not root then continue end
        local bp=lp:FindFirstChild("Backpack")
        if char:FindFirstChild("Gun") or (bp and bp:FindFirstChild("Gun")) then continue end
        local gi=findGunDrop(); local tp=getGunPart(gi)
        if tp and firetouchinterest then
            pcall(function() firetouchinterest(root,tp,0); task.wait(0.02); firetouchinterest(root,tp,1) end)
            pcall(function()
                if gi:IsA("Model") and gi.PrimaryPart then gi:SetPrimaryPartCFrame(root.CFrame)
                elseif gi:IsA("BasePart") then gi.CFrame=root.CFrame end
            end)
            task.wait(0.35)
            local c=lp.Character; local b=lp:FindFirstChild("Backpack")
            if (c and c:FindFirstChild("Gun")) or (b and b:FindFirstChild("Gun")) then
                if _G.Notify then _G.Notify("Gun collected!","success") end
            end
        end
    end
end)

-- ── Anti-AFK ─────────────────────────────────────────────────────────────────

local afkTimer=0
RunService.Heartbeat:Connect(function(dt)
    if not _G.AntiAFK then return end
    afkTimer=afkTimer+dt; if afkTimer<20 then return end; afkTimer=0
    pcall(function() VirtualUser:MouseMoveRel(Vector2.new(1,0)); task.wait(0.05); VirtualUser:MouseMoveRel(Vector2.new(-1,0)) end)
end)

-- ── Coin Farm — exact reference implementation ────────────────────────────────

local GatheredInstances = {}
local coinFarmWasOn     = false

local function findNextValidCoin()
    local char=lp.Character; if not char then return nil end
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not GatheredInstances[obj] then
            local n=obj.Name:lower()
            if n:find("coin") or n:find("gold") or n:find("token") then
                if not obj:IsDescendantOf(char) and obj.Position.Y > -45 then
                    if obj:FindFirstChild("TouchInterest")
                    or obj.Parent:FindFirstChild("TouchInterest")
                    or not n:find("visual") then
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

local function getMurdPos()
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        if (_G.RoleCache and _G.RoleCache[p])=="Murderer" then
            local r=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if r then return r.Position end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.15)
        local farmOn=_G.CoinFarm or false

        -- Turn off noclip when farm turns off
        if coinFarmWasOn and not farmOn then
            _G.NoclipEnabled=false
        end

        if not farmOn then
            if next(GatheredInstances) then GatheredInstances={} end
            coinFarmWasOn=false
            continue
        end

        coinFarmWasOn=true

        -- Enable noclip via toggle (UI reflects this)
        if not _G.NoclipEnabled then _G.NoclipEnabled=true end

        local char=lp.Character; if not char then continue end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end

        local mPos=_G.CoinAntiMurd and getMurdPos() or nil
        local safeR=_G.CoinSafetyRadius or 15

        local coin=findNextValidCoin()
        if coin and coin.Parent then
            if mPos and (coin.Position-mPos).Magnitude<safeR then
                GatheredInstances[coin]=true; continue
            end
            pcall(function()
                firetouchinterest(hrp,coin,0)
                task.wait(0.02)
                firetouchinterest(hrp,coin,1)
            end)
            GatheredInstances[coin]=true
        else
            if not coin then task.wait(2); GatheredInstances={} end
        end
    end
end)

-- ── Teleport ─────────────────────────────────────────────────────────────────

_G.TeleportToRole=function(role)
    local char=lp.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then if _G.Notify then _G.Notify("No character","error") end; return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        if (_G.RoleCache and _G.RoleCache[p])==role then
            local pC=p.Character; local pR=pC and pC:FindFirstChild("HumanoidRootPart")
            if pR then
                hrp.CFrame=pR.CFrame+pR.CFrame.LookVector*5+Vector3.new(0,1,0)
                if _G.Notify then _G.Notify("Teleported to "..role,"success") end; return
            end
        end
    end
    if _G.Notify then _G.Notify(role.." not found yet","warn") end
end

-- Advanced map teleport — finds spawn area, not top of skybox
_G.TeleportToMap=function()
    local char=lp.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end

    -- Strategy: find CoinContainer area which marks the map's playable area
    local bestPart = nil
    local bestY    = -math.huge

    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(lp.Character or Instance.new("Part")) then
            local n=obj.Name:lower()
            -- Look for floor-like parts: large, horizontal, named ground/floor/map
            if (n:find("floor") or n:find("ground") or n:find("base") or n:find("spawn"))
            and obj.Size.X > 10 and obj.Size.Z > 10
            and obj.Position.Y > -10 and obj.Position.Y < 100 then
                if obj.Position.Y > bestY then
                    bestY    = obj.Position.Y
                    bestPart = obj
                end
            end
        end
    end

    if bestPart then
        -- Teleport to 5 studs ABOVE the floor (not into it)
        hrp.CFrame=CFrame.new(bestPart.Position+Vector3.new(0, bestY+5, 0))
        if _G.Notify then _G.Notify("Teleported to map","success") end
        return
    end

    -- Fallback: teleport to map center at reasonable height
    local mapCenter = Vector3.new(0, 5, 0)
    for _,obj in ipairs(workspace:GetChildren()) do
        if obj:FindFirstChild("CoinContainer") then
            if obj:IsA("Model") then
                pcall(function()
                    local cf = obj:GetModelCFrame()
                    mapCenter = cf.Position + Vector3.new(0, 5, 0)
                end)
            end
            break
        end
    end
    hrp.CFrame=CFrame.new(mapCenter)
    if _G.Notify then _G.Notify("Teleported to map center","info") end
end
