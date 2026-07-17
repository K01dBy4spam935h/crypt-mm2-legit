-- Sheriff tab: Triggerbot section + logic

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

local page = _G.Pages["Sheriff"].page
local tbS  = _G.UI:MakeSection(page, "Triggerbot", 3)

_G.UI:Toggle(tbS, "Enable Triggerbot", false, function(v) _G.TriggerEnabled  = v end, 1)
_G.UI:Toggle(tbS, "Trigger Murderer",  false, function(v) _G.TriggerMurd     = v end, 2)
_G.UI:Toggle(tbS, "Trigger Sheriff",   false, function(v) _G.TriggerSheriff  = v end, 3)
_G.UI:Label(tbS,  "Both off = all targets", 4)
_G.UI:Slider(tbS, "Trigger FOV",   5,  100, 30,  function(v) _G.TriggerFOV   = v end, 5)
_G.UI:Slider(tbS, "Delay (ms)",    0,  800, 180, function(v) _G.TriggerDelay = v/1000 end, 6)
_G.UI:Label(tbS,  "0ms = instant, raise for high-ping servers", 7)

_G.TriggerEnabled=false; _G.TriggerMurd=false; _G.TriggerSheriff=false
_G.TriggerFOV=30; _G.TriggerDelay=0.18

local trigCD=0
RunService.RenderStepped:Connect(function(dt)
    if not _G.TriggerEnabled then return end
    trigCD=trigCD-dt; if trigCD>0 then return end
    local center=Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
    local trigAll=(not _G.TriggerMurd) and (not _G.TriggerSheriff)
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local char=p.Character; if not char then continue end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health<=0 then continue end
        local role=_G.RoleCache and _G.RoleCache[p]
        if not trigAll and not ((_G.TriggerMurd and role=="Murderer") or (_G.TriggerSheriff and role=="Sheriff")) then continue end
        local root=char:FindFirstChild("HumanoidRootPart"); if not root then continue end
        local sp,vis=camera:WorldToViewportPoint(root.Position); if not vis then continue end
        if (Vector2.new(sp.X,sp.Y)-center).Magnitude<=(_G.TriggerFOV or 30) then
            local tool=lp.Character and lp.Character:FindFirstChildOfClass("Tool")
            if tool then pcall(function() tool:Activate() end) end
            trigCD=(_G.TriggerDelay or 0.18)+math.random()*0.05; break
        end
    end
end)
