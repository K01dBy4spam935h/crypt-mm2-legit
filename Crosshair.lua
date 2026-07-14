-- Crypt-MM2-Legit | Crosshair — RGB spin + red on player (whole body)

local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

local lines = {}
for i=1,4 do
    local l=Drawing.new("Line"); l.Thickness=1; l.Color=Color3.fromRGB(255,255,255); l.Visible=false; l.Transparency=1
    lines[i]=l
end

local angle=0; local hue=0

local function hsvCol(h) return Color3.fromHSV(h,1,1) end

-- Whole-body player detection — check screen distance to HumanoidRootPart
-- Much more reliable than raycast (works through walls with hitbox expander)
local function isOnPlayer()
    local center=Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
    local threshold=40  -- pixels — generous to work with whole body

    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local char=p.Character; if not char then continue end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health<=0 then continue end
        local root=char:FindFirstChild("HumanoidRootPart"); if not root then continue end
        local sp,vis=camera:WorldToViewportPoint(root.Position)
        if vis and (Vector2.new(sp.X,sp.Y)-center).Magnitude<=threshold then
            return true
        end
    end
    return false
end

RunService.RenderStepped:Connect(function(dt)
    if not _G.CrosshairEnabled then
        for _,l in ipairs(lines) do l.Visible=false end; return
    end

    local cx=camera.ViewportSize.X/2; local cy=camera.ViewportSize.Y/2
    local size=(_G.CrosshairSize or 14)/2; local gap=_G.CrosshairGap or 4
    local thick=_G.CrosshairThick or 1; local spin=_G.CrosshairRGB and (_G.CrosshairSpin or 5) or 0

    angle=angle+spin*dt; hue=(hue+dt*0.35)%1

    local onPlayer=(_G.CrosshairRedOnPlayer~=false) and isOnPlayer()
    local color
    if onPlayer then color=Color3.fromRGB(255,40,40)
    elseif _G.CrosshairRGB then color=hsvCol(hue)
    else color=Color3.fromRGB(255,255,255) end

    local ca=math.cos(angle); local sa=math.sin(angle)
    local tips={Vector2.new(0,-(gap+size)),Vector2.new(0,gap+size),Vector2.new(-(gap+size),0),Vector2.new(gap+size,0)}
    local bases={Vector2.new(0,-gap),Vector2.new(0,gap),Vector2.new(-gap,0),Vector2.new(gap,0)}
    local function rot(v) return Vector2.new(v.X*ca-v.Y*sa+cx, v.X*sa+v.Y*ca+cy) end

    for i=1,4 do
        lines[i].From=rot(bases[i]); lines[i].To=rot(tips[i])
        lines[i].Color=color; lines[i].Thickness=thick; lines[i].Visible=true
    end
end)
