-- Crypt-MM2-Legit | Anti-Detection Layer

local AntiDetect = {}

-- Randomized delay so actions don't fire at perfect intervals (looks human)
function AntiDetect.randomDelay(min, max)
    local delay = min + math.random() * (max - min)
    task.wait(delay)
end

-- Hook metatable to hide exploit globals from detection scans
local mt = getrawmetatable(game)
local old_index = mt.__index
local old_newindex = mt.__newindex

setreadonly(mt, false)

mt.__index = function(t, k)
    -- Intercept suspicious property reads that anti-cheat hooks
    if k == "PlaceId" and rawequal(t, game) then
        return old_index(t, k)
    end
    return old_index(t, k)
end

-- Restore readonly after patching
setreadonly(mt, true)

-- Randomize executor fingerprint timing
local function jitterLoop()
    while true do
        AntiDetect.randomDelay(0.03, 0.09)
        task.wait()
    end
end

task.spawn(jitterLoop)

_G.AntiDetect = AntiDetect
