-- Teleport tab: All teleport buttons + logic

local Players = game:GetService("Players")
local lp      = Players.LocalPlayer

local page = _G.Pages["Teleport"].page
local tpS  = _G.UI:MakeSection(page, "Teleport", 1)

_G.TeleportToRole = function(role)
    local char=lp.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then if _G.Notify then _G.Notify("No character","error") end; return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        if (_G.RoleCache and _G.RoleCache[p])==role then
            local pC=p.Character; local pR=pC and pC:FindFirstChild("HumanoidRootPart")
            if pR then hrp.CFrame=pR.CFrame+pR.CFrame.LookVector*5+Vector3.new(0,1,0); if _G.Notify then _G.Notify("Teleported to "..role,"success") end; return end
        end
    end
    if _G.Notify then _G.Notify(role.." not found","warn") end
end

_G.TeleportToMap = function()
    local char=lp.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local bestPart=nil; local bestY=-math.huge
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n=obj.Name:lower()
            if (n:find("floor") or n:find("ground") or n:find("base") or n:find("spawn"))
            and obj.Size.X>10 and obj.Size.Z>10 and obj.Position.Y>-10 and obj.Position.Y<100 then
                if obj.Position.Y>bestY then bestY=obj.Position.Y; bestPart=obj end
            end
        end
    end
    if bestPart then
        hrp.CFrame=CFrame.new(bestPart.Position+Vector3.new(0,bestY+5,0))
        if _G.Notify then _G.Notify("Teleported to map","success") end; return
    end
    hrp.CFrame=CFrame.new(0,10,0); if _G.Notify then _G.Notify("Teleported to origin","info") end
end

_G.UI:Button(tpS, "Teleport to Murderer",   1, function() _G.TeleportToRole("Murderer") end)
_G.UI:Button(tpS, "Teleport to Sheriff",    2, function() _G.TeleportToRole("Sheriff")  end)
_G.UI:Button(tpS, "Teleport to Map Center", 3, function() _G.TeleportToMap()            end)
