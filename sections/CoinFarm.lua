-- Farm tab: Coin Farm section + logic

local Players = game:GetService("Players")
local lp      = Players.LocalPlayer

local page  = _G.Pages["Farm"].page
local coinS = _G.UI:MakeSection(page, "Coin Farm", 1)

_G.UI:Toggle(coinS, "Auto Collect Coins",   false, function(v) _G.CoinFarm=v      end, 1)
_G.UI:Toggle(coinS, "Anti-Murderer Safety", true,  function(v) _G.CoinAntiMurd=v  end, 2)
_G.UI:Slider(coinS, "Safety Radius", 5, 40, 15, function(v) _G.CoinSafetyRadius=v end, 3)
_G.UI:Label(coinS,  "Noclip auto-on, auto-off when farm stops", 4)

local afkS = _G.UI:MakeSection(page, "Anti-AFK", 2)
local VirtualUser = game:GetService("VirtualUser")
_G.UI:Toggle(afkS, "Anti-AFK",false,function(v) _G.AntiAFK=v end,1)

_G.CoinFarm=false;_G.CoinAntiMurd=true;_G.CoinSafetyRadius=15;_G.AntiAFK=false

local GatheredInstances = {}
local coinFarmWasOn     = false

local function findNextValidCoin()
    local char=lp.Character; if not char then return nil end
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not GatheredInstances[obj] then
            local n=obj.Name:lower()
            if n:find("coin") or n:find("gold") or n:find("token") then
                if not obj:IsDescendantOf(char) and obj.Position.Y > -45 then
                    if obj:FindFirstChild("TouchInterest") or obj.Parent:FindFirstChild("TouchInterest") or not n:find("visual") then
                        return obj
                    end
                end
            end
        end
    end
end

local function getMurdPos()
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        if (_G.RoleCache and _G.RoleCache[p])=="Murderer" then
            local r=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if r then return r.Position end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.15)
        local farmOn=_G.CoinFarm or false
        if coinFarmWasOn and not farmOn then
            _G.NoclipEnabled=false -- turn off noclip when farm stops
        end
        if not farmOn then
            if next(GatheredInstances) then GatheredInstances={} end
            coinFarmWasOn=false; continue
        end
        coinFarmWasOn=true
        if not _G.NoclipEnabled then _G.NoclipEnabled=true end
        local char=lp.Character; if not char then continue end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
        local mPos=_G.CoinAntiMurd and getMurdPos() or nil
        local safeR=_G.CoinSafetyRadius or 15
        local coin=findNextValidCoin()
        if coin and coin.Parent then
            if mPos and (coin.Position-mPos).Magnitude<safeR then GatheredInstances[coin]=true; continue end
            pcall(function() firetouchinterest(hrp,coin,0); task.wait(0.02); firetouchinterest(hrp,coin,1) end)
            GatheredInstances[coin]=true
        else
            if not coin then task.wait(2); GatheredInstances={} end
        end
    end
end)

-- Anti-AFK
local afkTimer=0
game:GetService("RunService").Heartbeat:Connect(function(dt)
    if not _G.AntiAFK then return end
    afkTimer=afkTimer+dt; if afkTimer<20 then return end; afkTimer=0
    pcall(function() VirtualUser:MouseMoveRel(Vector2.new(1,0)); task.wait(0.05); VirtualUser:MouseMoveRel(Vector2.new(-1,0)) end)
end)
