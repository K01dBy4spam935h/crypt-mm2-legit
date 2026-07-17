-- Sheriff tab: Aimbot section + logic

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput  = game:GetService("UserInputService")
local camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

local page = _G.Pages["Sheriff"].page
local abS  = _G.UI:MakeSection(page, "Aimbot", 2)

_G.UI:Toggle(abS, "Enable Aimbot",       false, function(v) _G.AimbotEnabled    = v end, 1)
_G.UI:Toggle(abS, "Require Right Click", false, function(v) _G.AimbotRightClick = v end, 2)
_G.UI:Slider(abS, "Smoothing",  1, 15, 2,   function(v) _G.AimbotSmoothing = v end, 3)
_G.UI:Slider(abS, "FOV Radius", 20,600, 250, function(v) _G.AimbotFOV       = v end, 4)
_G.UI:Toggle(abS, "Show FOV",   false, function(v) _G.ShowFOV  = v end, 5)
_G.UI:Toggle(abS, "FOV RGB",    false, function(v) _G.FovRGB   = v end, 6)
_G.UI:Toggle(abS, "Target Tracer", false, function(v) _G.TargetTracer = v end, 7)

_G.AimbotEnabled=false; _G.AimbotRightClick=false; _G.AimbotSmoothing=2
_G.AimbotFOV=250; _G.ShowFOV=false; _G.FovRGB=false; _G.TargetTracer=false

local fovHue = 0
local function hsvCol(h) return Color3.fromHSV(h,1,1) end

local fovCircle=Drawing.new("Circle"); fovCircle.Thickness=1.5; fovCircle.Color=Color3.fromRGB(255,255,255); fovCircle.Filled=false; fovCircle.Visible=false; fovCircle.Transparency=1
local tgtLine=Drawing.new("Line"); tgtLine.Thickness=1.5; tgtLine.Color=Color3.fromRGB(255,60,60); tgtLine.Visible=false; tgtLine.Transparency=1

local function getTarget(fov)
    local center=Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
    local best,bD=nil,fov
    local aimAll=(not _G.AimMurderer) and (not _G.AimSheriff)
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local char=p.Character; if not char then continue end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health<=0 then continue end
        local role=_G.RoleCache and _G.RoleCache[p]
        if not aimAll and not ((_G.AimMurderer and role=="Murderer") or (_G.AimSheriff and role=="Sheriff")) then continue end
        local root=char:FindFirstChild("HumanoidRootPart"); if not root then continue end
        local sp,vis=camera:WorldToViewportPoint(root.Position); if not vis then continue end
        local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude
        if d<bD then bD=d; best=root end
    end
    return best
end

RunService.RenderStepped:Connect(function(dt)
    local fov=_G.AimbotFOV or 250; local smooth=_G.AimbotSmoothing or 2
    local vp=camera.ViewportSize; local center=Vector2.new(vp.X/2,vp.Y/2)
    fovHue=(fovHue+dt*0.4)%1
    fovCircle.Radius=fov; fovCircle.Position=center
    fovCircle.Color=(_G.FovRGB) and hsvCol(fovHue) or Color3.fromRGB(255,255,255)
    fovCircle.Visible=_G.ShowFOV or false
    tgtLine.Visible=false

    if not _G.AimbotEnabled then return end
    if _G.AimbotRightClick and not UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

    local target=getTarget(fov)
    if not target then return end

    local sp,vis=camera:WorldToViewportPoint(target.Position)
    if vis and _G.TargetTracer then
        tgtLine.From=Vector2.new(vp.X/2,vp.Y); tgtLine.To=Vector2.new(sp.X,sp.Y); tgtLine.Visible=true
    end

    local alpha=math.clamp(1/math.max(smooth,1),0.08,1)
    local cf=camera.CFrame; local tcf=CFrame.lookAt(cf.Position,target.Position)
    local cx,cy,cz=cf:ToOrientation(); local tx,ty,_=tcf:ToOrientation()
    local nx=cx+(tx-cx)*alpha+(math.random()-0.5)*0.0015
    local ny=cy+(ty-cy)*alpha+(math.random()-0.5)*0.0015
    camera.CFrame=CFrame.new(cf.Position)*CFrame.fromOrientation(nx,ny,cz)
end)
