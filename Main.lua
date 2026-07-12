-- Crypt-MM2-Legit | Loader

local repo = "https://raw.githubusercontent.com/K01dBy4spam935h/crypt-mm2-legit/main/"

local files = {
    "Config",
    "AntiDetect",
    "UI",
    "Aimbot",
    "ESP",
    "Movement",
    "Hitbox",
    "Crosshair",
}

local loaded   = {}
local failed   = {}

for _, module in ipairs(files) do
    local ok, err = pcall(function()
        loadstring(game:HttpGet(repo .. module .. ".lua"))()
    end)
    if ok then
        table.insert(loaded, module)
    else
        table.insert(failed, module)
        warn("[Crypt] FAILED — " .. module .. ": " .. tostring(err))
    end
end

-- Wait for notification system to be ready
task.wait(1.5)

if #failed == 0 then
    if _G.Notify then
        _G.Notify("Crypt MM2 loaded — all modules OK", "success")
    end
    print("[Crypt] All modules loaded successfully: " .. table.concat(loaded, ", "))
else
    if _G.Notify then
        _G.Notify("Some modules failed: " .. table.concat(failed, ", "), "error")
    end
    warn("[Crypt] Failed modules: " .. table.concat(failed, ", "))
end
