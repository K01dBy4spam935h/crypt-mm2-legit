-- Crypt-MM2-Legit | Features: Knife Aura, Auto Stab, Hitbox, Silent Aim

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer

local origSizes = {}

-- ── Hitbox Expander + Silent Aim ──────────────────────────────────────────────

RunService.Heartbeat:Connect(function()
    for _,player in ipairs(Players:GetPlayers()) do
        if player==lp then continue end
        local char=player.Character; if not char then continue end
        local root=char:FindFirstChild("HumanoidRootPart"); if not root then continue end

        local role=(_G.RoleCache and _G.RoleCache[player]) or "Innocent"
        local isSilentTarget=_G.SilentAim and (role=="Murderer" or role=="Sheriff" or role=="Innocent")

        if _G.HitboxEnabled or isSilentTarget then
            if not origSizes[player] then origSizes[player]=root.Size end
            local sz=isSilentTarget and (_G.SilentAimSize or 40) or (_G.HitboxSize or 6)
            root.Size=Vector3.new(sz,sz,sz)
            root.CanCollide=false
            root.LocalTransparencyModifier=1
        else
            if origSizes[player] then
                root.Size=origSizes[player]; origSizes[player]=nil
                root.CanCollide=true; root.LocalTransparencyModifier=0
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p) origSizes[p]=nil end)

-- ── Knife Aura — firetouchinterest between knife and nearby players ────────────

local auraCD = 0

RunService.Heartbeat:Connect(function(dt)
    if not _G.KnifeAura then return end
    auraCD=auraCD-dt
    if auraCD>0 then return end
    auraCD=0.1 + math.random()*0.05  -- slight randomization to look less bot-like

    local char=lp.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end

    -- Find equipped knife handle
    local knife=char:FindFirstChild("Knife")
    if not knife then return end
    local handle=knife:FindFirstChild("Handle")
    if not handle then return end

    local range=_G.KnifeAuraRange or 15

    for _,player in ipairs(Players:GetPlayers()) do
        if player==lp then continue end
        local pChar=player.Character; if not pChar then continue end
        local pHum=pChar:FindFirstChildOfClass("Humanoid"); if not pHum or pHum.Health<=0 then continue end
        local pRoot=pChar:FindFirstChild("HumanoidRootPart"); if not pRoot then continue end

        if (hrp.Position-pRoot.Position).Magnitude<=range then
            -- Touch the knife handle against all character parts for reliable hit
            for _,part in ipairs(pChar:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        firetouchinterest(handle, part, 0)
                        firetouchinterest(handle, part, 1)
                    end)
                end
            end
        end
    end
end)

-- ── Auto Stab — activate knife when target in range ───────────────────────────

local stabCD = 0

RunService.Heartbeat:Connect(function(dt)
    if not _G.AutoStab then return end
    stabCD=stabCD-dt
    if stabCD>0 then return end

    local char=lp.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local knife=char:FindFirstChild("Knife"); if not knife then return end
    local handle=knife:FindFirstChild("Handle"); if not handle then return end

    local closest, closestDist = nil, _G.KnifeAuraRange or 15

    for _,player in ipairs(Players:GetPlayers()) do
        if player==lp then continue end
        local pChar=player.Character; if not pChar then continue end
        local pHum=pChar:FindFirstChildOfClass("Humanoid"); if not pHum or pHum.Health<=0 then continue end
        local pRoot=pChar:FindFirstChild("HumanoidRootPart"); if not pRoot then continue end
        local dist=(hrp.Position-pRoot.Position).Magnitude
        if dist<closestDist then closestDist=dist; closest=pChar end
    end

    if closest then
        -- Touch all parts of target
        for _,part in ipairs(closest:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    firetouchinterest(handle,part,0)
                    firetouchinterest(handle,part,1)
                end)
            end
        end
        stabCD = 0.4 + math.random()*0.15  -- humanized cooldown
    end
end)
