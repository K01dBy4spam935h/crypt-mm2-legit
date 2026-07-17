-- LocalPlayer tab: Movement section + logic

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput  = game:GetService("UserInputService")
local lp         = Players.LocalPlayer
local BASE_SPEED = 16

local page = _G.Pages["LocalPlayer"].page
local mvS  = _G.UI:MakeSection(page, "Movement", 1)

_G.UI:Toggle(mvS, "Noclip",        false, function(v) _G.NoclipEnabled  = v end, 1)
_G.UI:Toggle(mvS, "Speedhack",     false, function(v) _G.SpeedEnabled   = v end, 2)
_G.UI:Toggle(mvS, "Infinite Jump", false, function(v) _G.InfJumpEnabled = v end, 3)
_G.UI:Toggle(mvS, "Fly",           false, function(v) _G.FlyEnabled=v; if _G.SetFly then _G.SetFly(v) end end, 4)
_G.UI:Slider(mvS, "Speed Mult",  1, 100, 1,   function(v) _G.SpeedMultiplier=v end, 5)
_G.UI:Slider(mvS, "Fly Speed",   10, 200, 60, function(v) _G.FlySpeed=v        end, 6)

_G.NoclipEnabled=false;_G.SpeedEnabled=false;_G.InfJumpEnabled=false
_G.FlyEnabled=false;_G.SpeedMultiplier=1;_G.FlySpeed=60

-- Noclip
local noclipConn=nil; local lastNoclip=false
local function setNoclip(on)
    if on then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn=RunService.Stepped:Connect(function()
            local char=lp.Character; if not char then return end
            for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
        task.defer(function()
            local char=lp.Character; if not char then return end
            for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end
        end)
    end
end
RunService.Heartbeat:Connect(function()
    local now=_G.NoclipEnabled or false
    if now~=lastNoclip then lastNoclip=now; setNoclip(now) end
end)
lp.CharacterAdded:Connect(function() task.wait(0.2); if _G.NoclipEnabled then setNoclip(true) end end)

-- Speed
RunService.Heartbeat:Connect(function()
    local char=lp.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local mult=math.clamp(_G.SpeedMultiplier or 1,1,100)
    local tgt=_G.SpeedEnabled and (BASE_SPEED*mult) or BASE_SPEED
    hum.WalkSpeed=hum.WalkSpeed+(tgt-hum.WalkSpeed)*0.18
end)

-- Infinite jump
UserInput.JumpRequest:Connect(function()
    if not _G.InfJumpEnabled then return end
    local char=lp.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- Fly
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
