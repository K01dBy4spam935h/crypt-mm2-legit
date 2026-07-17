-- Visuals tab: Gun Drop / Notifications section

local page  = _G.Pages["Visuals"].page
local notifS = _G.UI:MakeSection(page, "Notifications", 3)

_G.UI:Toggle(notifS, "Gun Drop Notifier", false, function(v) _G.GunDropNotif  = v end, 1)
_G.UI:Toggle(notifS, "Show Round Timer",  false, function(v) _G.ShowRoundTimer = v end, 2)
_G.UI:Toggle(notifS, "Gun Drop ESP",      false, function(v) _G.GunESP         = v end, 3)

_G.GunDropNotif=false; _G.ShowRoundTimer=false; _G.GunESP=false

local gunNotifReady = true
workspace.ChildAdded:Connect(function(child)
    if child.Name=="GunDrop" and gunNotifReady and _G.GunDropNotif then
        gunNotifReady=false
        if _G.Notify then _G.Notify("🔫 Gun dropped!","info") end
        task.delay(5, function() gunNotifReady=true end)
    end
end)

-- ESP section (in Visuals tab)
local espS = _G.UI:MakeSection(page, "ESP", 1)
_G.UI:Toggle(espS, "Box ESP",      false, function(v) _G.BoxESP=v      end, 1)
_G.UI:Toggle(espS, "Chams ESP",    false, function(v) _G.ChamsESP=v    end, 2)
_G.UI:Toggle(espS, "Name ESP",     false, function(v) _G.NameESP=v     end, 3)
_G.UI:Toggle(espS, "Distance ESP", false, function(v) _G.DistanceESP=v end, 4)
_G.UI:Toggle(espS, "Tracers",      false, function(v) _G.Tracers=v     end, 5)

_G.BoxESP=false;_G.ChamsESP=false;_G.NameESP=false;_G.DistanceESP=false;_G.Tracers=false
