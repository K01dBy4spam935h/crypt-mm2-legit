-- Murderer tab: Hitbox Expander section + logic

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer

local page = _G.Pages["Murderer"].page
local hbS  = _G.UI:MakeSection(page, "Hitbox Expander", 2)

_G.UI:Toggle(hbS, "Enable Hitbox", false, function(v) _G.HitboxEnabled=v end, 1)
_G.UI:Slider(hbS, "Hitbox Size", 2, 20, 6, function(v) _G.HitboxSize=v end, 2)
_G.UI:Label(hbS,  "Expands ALL parts — full coverage, walk-through on", 3)

_G.HitboxEnabled=false; _G.HitboxSize=6

local origSizes={}
RunService.Heartbeat:Connect(function()
    for _,player in ipairs(Players:GetPlayers()) do
        if player==lp then continue end
        local char=player.Character; if not char then continue end
        if _G.HitboxEnabled then
            if not origSizes[player] then origSizes[player]={} end
            local sz=_G.HitboxSize or 6
            for _,part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if not origSizes[player][part] then origSizes[player][part]=part.Size end
                    part.Size=Vector3.new(sz,sz,sz); part.CanCollide=false; part.LocalTransparencyModifier=1
                end
            end
        else
            if origSizes[player] then
                for part,sz in pairs(origSizes[player]) do
                    pcall(function() part.Size=sz; part.CanCollide=true; part.LocalTransparencyModifier=0 end)
                end
                origSizes[player]=nil
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p) origSizes[p]=nil end)
