-- Crypt-MM2-Legit | Silent Aim (Sheriff tab, murderer only)

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer
local Mouse      = lp:GetMouse()

local page = _G.Pages["Sheriff"].page
local saS  = _G.UI:MakeSection(page, "Silent Aim", 1)

_G.UI:Toggle(saS, "Enable Silent Aim",  false, function(v) _G.SilentAim=v end, 1)
_G.UI:Label(saS,  "Redirects bullet to Murderer — no camera snap", 2)
_G.UI:Label(saS,  "Uses server-side hook on ShootGun remote", 3)

_G.SilentAim = false

-- Target tracker — murderer only, exact reference logic
local SilentTarget = nil

local function getMurdererTarget()
    local closestPlayer = nil
    local shortestDist  = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        if not player.Character then continue end
        local root = player.Character:FindFirstChild("HumanoidRootPart"); if not root then continue end
        local hum  = player.Character:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health<=0 then continue end

        -- Murderer only
        local role = _G.RoleCache and _G.RoleCache[player]
        if role ~= "Murderer" then continue end

        local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end

        local mousePos  = Vector2.new(Mouse.X, Mouse.Y)
        local targetPos = Vector2.new(screenPos.X, screenPos.Y)
        local dist      = (mousePos - targetPos).Magnitude

        if dist < shortestDist then
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {lp.Character, player.Character}
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local origin    = workspace.CurrentCamera.CFrame.Position
            local direction = root.Position - origin
            local result    = workspace:Raycast(origin, direction, rp)
            if not result then
                closestPlayer = root; shortestDist = dist
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if _G.SilentAim then
        SilentTarget = getMurdererTarget()
    else
        SilentTarget = nil
    end
end)

-- hookmetamethod — intercepts ShootGun and ThrowKnife server calls
-- ShootGun = sheriff fires gun → redirects to murderer
-- ThrowKnife = murderer throws knife → redirected by KnifeTools section

local OldNamecall
pcall(function()
    OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
        local Method = getnamecallmethod()
        local Args   = {...}

        if not checkcaller() and (Method == "FireServer" or Method == "fireServer") then
            -- Silent aim: sheriff gun → murderer
            if Self.Name == "ShootGun" and _G.SilentAim and SilentTarget then
                Args[1] = SilentTarget.Position
            end

            -- Auto throw: murderer knife → auto throw target (set by KnifeTools.lua)
            if Self.Name == "ThrowKnife" and _G.AutoThrow then
                local at = _G._AutoThrowTarget
                if at then Args[1] = at end
            end
        end

        return OldNamecall(Self, table.unpack(Args))
    end)
end)

-- Expose auto throw target for the hook to read
RunService.RenderStepped:Connect(function()
    _G._AutoThrowTarget = nil
end)
