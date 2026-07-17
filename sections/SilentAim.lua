-- Sheriff tab: Silent Aim section + hitbox redirect logic

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer

local page = _G.Pages["Sheriff"].page
local saS  = _G.UI:MakeSection(page, "Silent Aim", 1)

_G.UI:Toggle(saS, "Enable Silent Aim", false, function(v) _G.SilentAim = v end, 1)
_G.UI:Slider(saS, "Aim Size",  5, 60, 30, function(v) _G.SilentAimSize = v end, 2)
_G.UI:Label(saS,  "Expands murderer hitbox — no camera snap", 3)

_G.SilentAim=false; _G.SilentAimSize=30

local saOrig = {}
RunService.Heartbeat:Connect(function()
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local char=p.Character; if not char then continue end
        local role=_G.RoleCache and _G.RoleCache[p]
        local root=char:FindFirstChild("HumanoidRootPart"); if not root then continue end
        if _G.SilentAim and role=="Murderer" then
            if not saOrig[p] then saOrig[p]=root.Size end
            root.Size=Vector3.new(_G.SilentAimSize or 30, _G.SilentAimSize or 30, _G.SilentAimSize or 30)
            root.CanCollide=false; root.LocalTransparencyModifier=1
        else
            if saOrig[p] then
                pcall(function() root.Size=saOrig[p]; root.CanCollide=true; root.LocalTransparencyModifier=0 end)
                saOrig[p]=nil
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p) saOrig[p]=nil end)

-- Sheriff status
local shStatusS = _G.UI:MakeSection(page, "My Status", 4)
local shStatus  = _G.UI:Label(shStatusS, "Checking…", 1)
task.spawn(function()
    while task.wait(1) do
        local char=game:GetService("Players").LocalPlayer.Character
        local bp=game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
        local hasGun=(char and char:FindFirstChild("Gun")) or (bp and bp:FindFirstChild("Gun"))
        if hasGun then shStatus.Text="✓ Gun equipped — Sheriff"; shStatus.TextColor3=Color3.fromRGB(60,210,255)
        else shStatus.Text="No Gun detected"; shStatus.TextColor3=Color3.fromRGB(150,150,150) end
    end
end)
