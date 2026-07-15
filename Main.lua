-- Crypt-MM2-Legit | Loader

local repo = "https://raw.githubusercontent.com/K01dBy4spam935h/crypt-mm2-legit/main/"

local files = {
    "Config",
    "AntiDetect",
    "UI",
    "Aimbot",
    "ESP",
    "Movement",
    "Features",
    "Crosshair",
}

local loaded, failed = {}, {}

for _, module in ipairs(files) do
    local ok, err = pcall(function()
        loadstring(game:HttpGet(repo .. module .. ".lua"))()
    end)
    if ok then
        table.insert(loaded, module)
        print("[Crypt] ✓ " .. module)
    else
        table.insert(failed, module)
        warn("[Crypt] ✕ " .. module .. ": " .. tostring(err))
    end
end

task.wait(2)

if #failed == 0 then
    if _G.Notify then _G.Notify("Crypt MM2 — all modules loaded", "success") end
else
    if _G.Notify then
        _G.Notify("Failed: " .. table.concat(failed, ", "), "error")
    end
end
