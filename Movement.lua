-- Crypt-MM2-Legit | Local Player

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UserInput   = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local lp          = Players.LocalPlayer
local BASE_SPEED  = 16

-- ── Noclip ────────────────────────────────────────────────────────────────────

local noclipConn = nil; local lastNoclip = false

local function setNoclip(on)
    if on then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
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

local flyConn = nil

local function applyFly(on)
    local char=lp.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end

    -- Cleanup first
    local oldBV=hrp:FindFirstChild("CryptBV"); if oldBV then oldBV:Destroy() end
    local oldBG=hrp:FindFirstChild("CryptBG"); if oldBG then oldBG:Destroy() end
    if flyConn then flyConn:Disconnect(); flyConn=nil end

    if not on then
        hum.PlatformStand = false
        return
    end

    hum.PlatformStand = true

    local bv=Instance.new("BodyVelocity"); bv.Name="CryptBV"; bv.Velocity=Vector3.new(0,0,0); bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Parent=hrp
    local bg=Instance.new("BodyGyro");    bg.Name="CryptBG"; bg.MaxTorque=Vector3.new(1e5,1e5,1e5); bg.CFrame=hrp.CFrame; bg.Parent=hrp

    flyConn = RunService.RenderStepped:Connect(function()
        if not _G.FlyEnabled then return end
        local cam   = workspace.CurrentCamera
        local speed = _G.FlySpeed or 60
        local dir   = Vector3.new(0,0,0)

        if UserInput:IsKeyDown(Enum.KeyCode.W) then dir=dir+cam.CFrame.LookVector  end
        if UserInput:IsKeyDown(Enum.KeyCode.S) then dir=dir-cam.CFrame.LookVector  end
        if UserInput:IsKeyDown(Enum.KeyCode.A) then dir=dir-cam.CFrame.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.D) then dir=dir+cam.CFrame.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.Space)       then dir=dir+Vector3.new(0,1,0) end
        if UserInput:IsKeyDown(Enum.KeyCode.LeftControl) then dir=dir-Vector3.new(0,1,0) end

        bv.Velocity = dir.Magnitude>0 and dir.Unit*speed or Vector3.new(0,0,0)
        bg.CFrame   = cam.CFrame
    end)
end

-- Watch fly toggle
local lastFly = false
RunService.Heartbeat:Connect(function()
    local now=_G.FlyEnabled or false
    if now~=lastFly then lastFly=now; applyFly(now) end
end)

lp.CharacterAdded:Connect(function()
    task.wait(0.3); lastFly=false
    if _G.FlyEnabled then applyFly(true) end
end)

_G.SetFly = function(on) _G.FlyEnabled=on; applyFly(on) end

-- ── Invisibility — transparency + size shrink (both replicate from client) ────

local invisHL  = nil
local lastInvis = false

local function applyInvis(on)
    local char=lp.Character; if not char then return end

    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
            p.Transparency = on and 1 or 0
            -- Size shrink is the most reliable — even if game resets transparency,
            -- size 0.001 means the part is physically invisible
            if on then
                pcall(function() p.Size=Vector3.new(0.001,0.001,0.001) end)
            end
        end
        if p:IsA("Decal") then pcall(function() p.Transparency=on and 1 or 0 end) end
    end
    for _,acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local h=acc:FindFirstChild("Handle")
            if h then h.Transparency=on and 1 or 0 end
        end
    end

    if on then
        if not invisHL or not invisHL.Parent then
            invisHL=Instance.new("Highlight"); invisHL.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
            invisHL.FillTransparency=1; invisHL.OutlineTransparency=0.2
            invisHL.OutlineColor=Color3.fromRGB(255,255,255); invisHL.Adornee=char; invisHL.Parent=char
        end
    else
        if invisHL then invisHL:Destroy(); invisHL=nil end
    end
end

RunService.Heartbeat:Connect(function()
    local now=_G.InvisEnabled or false
    if now~=lastInvis then
        lastInvis=now; applyInvis(now)
        if _G.Notify then _G.Notify(now and "Invisibility ON" or "Invisibility OFF", now and "success" or "info") end
    end
end)

lp.CharacterAdded:Connect(function() task.wait(0.3); lastInvis=false; if _G.InvisEnabled then applyInvis(true) end end)

-- ── Auto Gun — GunDrop CFrame teleport (confirmed working MM2 method) ─────────
-- MM2's dropped gun is a Model named "GunDrop" in workspace
-- Setting its CFrame to player position makes it auto-collect via TouchInterest

local autoGunCD = 0

RunService.Heartbeat:Connect(function(dt)
    if not _G.AutoGun then return end
    autoGunCD=autoGunCD-dt
    if autoGunCD>0 then return end
    autoGunCD=0.5

    local char=lp.Character; if not char then return end
    local bp=lp:FindFirstChild("Backpack")
    if char:FindFirstChild("Gun") or (bp and bp:FindFirstChild("Gun")) then return end

    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end

    -- Method: teleport GunDrop to player (confirmed method from MM2 scripts)
    local gunDrop = workspace:FindFirstChild("GunDrop")
    if gunDrop then
        -- CFrame the gun to player — it auto-picks up on touch
        pcall(function()
            if gunDrop:IsA("Model") and gunDrop.PrimaryPart then
                gunDrop:SetPrimaryPartCFrame(hrp.CFrame)
            elseif gunDrop:IsA("BasePart") then
                gunDrop.CFrame = hrp.CFrame
            end
        end)
        -- Also firetouchinterest as backup
        pcall(function()
            local handle = gunDrop:IsA("Model") and (gunDrop:FindFirstChild("Handle") or gunDrop.PrimaryPart) or gunDrop
            if handle then
                firetouchinterest(hrp, handle, 0)
                task.wait(0.05)
                firetouchinterest(hrp, handle, 1)
            end
        end)
        -- Verify after short wait
        task.delay(0.4, function()
            local c=lp.Character; local b=lp:FindFirstChild("Backpack")
            if (c and c:FindFirstChild("Gun")) or (b and b:FindFirstChild("Gun")) then
                if _G.Notify then _G.Notify("Gun collected!","success") end
            end
        end)
    end
end)

-- ── Anti-AFK — VirtualUser mouse wiggle ───────────────────────────────────────

local afkTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if not _G.AntiAFK then return end
    afkTimer=afkTimer+dt
    if afkTimer<20 then return end
    afkTimer=0
    pcall(function()
        VirtualUser:MouseMoveRel(Vector2.new(1,0))
        task.wait(0.05)
        VirtualUser:MouseMoveRel(Vector2.new(-1,0))
    end)
end)

-- ── Coin Farm — firetouchinterest, anti-murderer, noclip auto-on ──────────────

local coinTimer = 0

local function getMurdPos()
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local r=(_G.RoleCache and _G.RoleCache[p]) or "Innocent"
        if r=="Murderer" then
            local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if root then return root.Position end
        end
    end
    return nil
end

RunService.Heartbeat:Connect(function(dt)
    if not _G.CoinFarm then return end
    if not _G.NoclipEnabled then _G.NoclipEnabled=true end

    coinTimer=coinTimer+dt
    if coinTimer<0.15 then return end
    coinTimer=0

    local char=lp.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local mPos=_G.CoinAntiMurd and getMurdPos() or nil
    local safeR=_G.CoinSafetyRadius or 15

    for _,obj in ipairs(workspace:GetDescendants()) do
        local isCoin=(obj.Name=="Coin" or obj.Name=="coin" or obj.Name:lower():find("coin"))
        if isCoin and obj:IsA("BasePart") then
            if mPos and (obj.Position-mPos).Magnitude<safeR then continue end
            pcall(function()
                firetouchinterest(hrp,obj,0)
                firetouchinterest(hrp,obj,1)
            end)
        end
    end
end)
