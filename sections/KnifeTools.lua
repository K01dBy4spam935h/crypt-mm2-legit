-- Crypt-MM2-Legit | Knife Tools + Auto Throw

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer
local Mouse      = lp:GetMouse()

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
_G.UI:Toggle(mkS, "Auto Stab", false, function(v) _G.AutoStab=v end, 3)
_G.UI:Toggle(mkS, "Auto Throw", false, function(v)
    if v then
        local char=lp.Character; local bp=lp:FindFirstChild("Backpack")
        if not ((char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))) then
            if _G.Notify then _G.Notify("No Knife — you are not Murderer","warn") end
        end
    end
    _G.AutoThrow=v
end, 4)
_G.UI:Label(mkS, "Auto Throw uses silent aim hook — targets nearest innocent", 5)

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

_G.KnifeAura=false; _G.KnifeAuraRange=15; _G.AutoStab=false; _G.AutoThrow=false

local auraCD=0; local stabCD=0; local throwCD=0

-- Auto throw target (nearest innocent or anyone — for murderer, "targets" = innocents)
local autoThrowTarget = nil

local function getAutoThrowTarget()
    local char=lp.Character; if not char then return nil end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local closest, closestD = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player==lp then continue end
        local pChar=player.Character; if not pChar then continue end
        local pHum=pChar:FindFirstChildOfClass("Humanoid"); if not pHum or pHum.Health<=0 then continue end
        local pRoot=pChar:FindFirstChild("HumanoidRootPart"); if not pRoot then continue end
        -- Auto throw at anyone (murderer targets innocents + sheriff)
        local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(pRoot.Position)
        if not onScreen then continue end
        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
        local targetPos = Vector2.new(screenPos.X, screenPos.Y)
        local dist = (mousePos - targetPos).Magnitude
        if dist < closestD then
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {char, pChar}
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local origin = workspace.CurrentCamera.CFrame.Position
            local direction = pRoot.Position - origin
            local result = workspace:Raycast(origin, direction, rp)
            if not result then
                closest = pRoot; closestD = dist
            end
        end
    end
    return closest
end

-- Keep auto throw target updated
RunService.RenderStepped:Connect(function()
    if _G.AutoThrow then
        autoThrowTarget = getAutoThrowTarget()
    else
        autoThrowTarget = nil
    end
end)

local function equipKnife()
    local char=lp.Character; if not char then return nil end
    local knife=char:FindFirstChild("Knife"); if knife then return knife end
    local bp=lp:FindFirstChild("Backpack"); if not bp then return nil end
    local bk=bp:FindFirstChild("Knife"); if not bk then return nil end
    local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum:EquipTool(bk) end
    task.wait(0.1); return char:FindFirstChild("Knife")
end

RunService.Heartbeat:Connect(function(dt)
    local char=lp.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local knife=(char:FindFirstChild("Knife") or equipKnife())
    local handle = knife and knife:FindFirstChild("Handle")

    -- Knife Aura
    if _G.KnifeAura and handle then
        auraCD=auraCD-dt; if auraCD<=0 then
            auraCD=0.08+math.random()*0.04
            local range=_G.KnifeAuraRange or 15
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

    -- Auto Stab
    if _G.AutoStab and handle then
        stabCD=stabCD-dt; if stabCD<=0 then
            local range=_G.KnifeAuraRange or 15
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

    -- Auto Throw — activates knife, hookmetamethod redirects the server position
    if _G.AutoThrow and knife and autoThrowTarget then
        throwCD=throwCD-dt; if throwCD<=0 then
            pcall(function() knife:Activate() end)
            throwCD=0.6+math.random()*0.2
        end
    end
end)
