-- Murderer tab: Knife Tools section + logic

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer

local page = _G.Pages["Murderer"].page
local mkS  = _G.UI:MakeSection(page, "Knife Tools", 1)

_G.UI:Toggle(mkS, "Knife Aura", false, function(v)
    if v then
        local char=lp.Character; local bp=lp:FindFirstChild("Backpack")
        if not ((char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))) then
            if _G.Notify then _G.Notify("No Knife — you are not Murderer","warn") end
        end
    end
    _G.KnifeAura=v
end, 1)
_G.UI:Slider(mkS, "Aura Range", 5, 60, 15, function(v) _G.KnifeAuraRange=v end, 2)
_G.UI:Toggle(mkS, "Auto Stab", false, function(v)
    if v and _G.Notify then
        local char=lp.Character; local bp=lp:FindFirstChild("Backpack")
        if not ((char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))) then
            _G.Notify("No Knife — you are not Murderer","warn")
        end
    end
    _G.AutoStab=v
end, 3)

local mStatusS = _G.UI:MakeSection(page, "My Status", 3)
local mStatus  = _G.UI:Label(mStatusS, "Checking…", 1)
task.spawn(function()
    while task.wait(1) do
        local char=lp.Character; local bp=lp:FindFirstChild("Backpack")
        local hasKnife=(char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
        if hasKnife then mStatus.Text="✓ Knife — Murderer"; mStatus.TextColor3=Color3.fromRGB(255,80,80)
        else mStatus.Text="No Knife"; mStatus.TextColor3=Color3.fromRGB(150,150,150) end
    end
end)

_G.KnifeAura=false; _G.KnifeAuraRange=15; _G.AutoStab=false

local auraCD=0; local stabCD=0

local function equipKnife()
    local char=lp.Character; if not char then return nil end
    local knife=char:FindFirstChild("Knife"); if knife then return knife end
    local bp=lp:FindFirstChild("Backpack"); if not bp then return nil end
    local bk=bp:FindFirstChild("Knife"); if not bk then return nil end
    local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum:EquipTool(bk) end
    task.wait(0.1); return char:FindFirstChild("Knife")
end

RunService.Heartbeat:Connect(function(dt)
    if not (_G.KnifeAura or _G.AutoStab) then return end
    local char=lp.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local knife=char:FindFirstChild("Knife") or equipKnife(); if not knife then return end
    local handle=knife:FindFirstChild("Handle"); if not handle then return end
    local range=_G.KnifeAuraRange or 15

    if _G.KnifeAura then
        auraCD=auraCD-dt; if auraCD<=0 then
            auraCD=0.08+math.random()*0.04
            for _,player in ipairs(Players:GetPlayers()) do
                if player==lp then continue end
                local pChar=player.Character; if not pChar then continue end
                local pHum=pChar:FindFirstChildOfClass("Humanoid"); if not pHum or pHum.Health<=0 then continue end
                local pRoot=pChar:FindFirstChild("HumanoidRootPart"); if not pRoot then continue end
                if (hrp.Position-pRoot.Position).Magnitude<=range then
                    pcall(function() knife:Activate() end)
                    for _,part in ipairs(pChar:GetDescendants()) do
                        if part:IsA("BasePart") then
                            pcall(function() firetouchinterest(handle,part,0); firetouchinterest(handle,part,1) end)
                        end
                    end
                end
            end
        end
    end

    if _G.AutoStab then
        stabCD=stabCD-dt; if stabCD<=0 then
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
        end
    end
end)
