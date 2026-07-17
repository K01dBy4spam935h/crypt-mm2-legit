-- LocalPlayer tab: Auto Gun section + logic

local Players = game:GetService("Players")
local lp      = Players.LocalPlayer

local page = _G.Pages["LocalPlayer"].page
local gunS = _G.UI:MakeSection(page, "Auto Gun", 3)

_G.UI:Toggle(gunS, "Auto Collect Gun",             false, function(v) _G.AutoGun=v end, 1)
_G.UI:Label(gunS,  "Continuous — grabs GunDrop instantly", 2)

_G.AutoGun=false

local function findGunDrop()
    local g=workspace:FindFirstChild("GunDrop"); if g then return g end
    for _,obj in ipairs(workspace:GetChildren()) do
        if obj.Name=="Normal" or obj:FindFirstChild("CoinContainer") or obj.Name:match("Map") then
            local h=obj:FindFirstChild("GunDrop",true); if h then return h end
        end
    end
end

local function getGunPart(gd)
    if not gd then return nil end
    if gd:IsA("BasePart") then return gd end
    if gd:FindFirstChild("Handle") then return gd.Handle end
    for _,c in ipairs(gd:GetChildren()) do if c:IsA("BasePart") then return c end end
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if not _G.AutoGun then continue end
        local char=lp.Character; if not char then continue end
        local root=char:FindFirstChild("HumanoidRootPart"); if not root then continue end
        local bp=lp:FindFirstChild("Backpack")
        if char:FindFirstChild("Gun") or (bp and bp:FindFirstChild("Gun")) then continue end
        local gi=findGunDrop(); local tp=getGunPart(gi)
        if tp and firetouchinterest then
            pcall(function() firetouchinterest(root,tp,0); task.wait(0.02); firetouchinterest(root,tp,1) end)
            pcall(function()
                if gi:IsA("Model") and gi.PrimaryPart then gi:SetPrimaryPartCFrame(root.CFrame)
                elseif gi:IsA("BasePart") then gi.CFrame=root.CFrame end
            end)
            task.wait(0.35)
            local c=lp.Character; local b=lp:FindFirstChild("Backpack")
            if (c and c:FindFirstChild("Gun")) or (b and b:FindFirstChild("Gun")) then
                if _G.Notify then _G.Notify("Gun collected!","success") end
            end
        end
    end
end)
