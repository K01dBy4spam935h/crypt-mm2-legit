-- LocalPlayer tab: Visibility (Invisibility) section + logic

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer

local page   = _G.Pages["LocalPlayer"].page
local invisS = _G.UI:MakeSection(page, "Visibility", 2)

_G.UI:Toggle(invisS, "Invisibility",                  false, function(v) _G.InvisEnabled=v end, 1)
_G.UI:Label(invisS,  "Re-applied every frame",        2)
_G.UI:Label(invisS,  "You see white outline of self", 3)

_G.InvisEnabled=false

local invisHL=nil; local lastInvis=false

RunService.Heartbeat:Connect(function()
    local on=_G.InvisEnabled or false
    local char=lp.Character; if not char then return end
    if on then
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Transparency=1 end
            if p:IsA("Decal") then pcall(function() p.Transparency=1 end) end
        end
        if not (invisHL and invisHL.Parent) then
            invisHL=Instance.new("Highlight"); invisHL.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
            invisHL.FillTransparency=1; invisHL.OutlineTransparency=0.1
            invisHL.OutlineColor=Color3.fromRGB(255,255,255); invisHL.Adornee=char; invisHL.Parent=char
        end
        if not lastInvis then
            lastInvis=true
            for _,acc in ipairs(char:GetChildren()) do if acc:IsA("Accessory") then acc:Destroy() end end
            if _G.Notify then _G.Notify("Invisibility ON","success") end
        end
    else
        if lastInvis then
            lastInvis=false
            if invisHL then invisHL:Destroy(); invisHL=nil end
            if _G.Notify then _G.Notify("Rejoin to restore appearance","warn") end
        end
    end
end)
lp.CharacterAdded:Connect(function() task.wait(0.3); lastInvis=false; if invisHL then invisHL:Destroy(); invisHL=nil end end)
