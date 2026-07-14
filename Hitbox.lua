-- Crypt-MM2-Legit | Hitbox Expander (Murderer tab)

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer

local origSizes = {}

RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        if _G.HitboxEnabled then
            if not origSizes[player] then
                origSizes[player] = root.Size
            end
            local sz = _G.HitboxSize or 6
            root.Size       = Vector3.new(sz, sz, sz)
            root.CanCollide = false                         -- walk through expanded hitbox
            root.LocalTransparencyModifier = 1             -- hide visual expansion
        else
            if origSizes[player] then
                root.Size                      = origSizes[player]
                origSizes[player]              = nil
                root.CanCollide                = true
                root.LocalTransparencyModifier = 0
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p) origSizes[p] = nil end)
