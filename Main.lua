-- Crypt-MM2-Legit | Loader

local repo = "https://raw.githubusercontent.com/K01dBy4spam935h/crypt-mm2-legit/main/"

local files = {
    "Config",       -- must be first
    "AntiDetect",
    "UI",
    "Aimbot",
    "ESP",
    "Movement",
    "Crosshair"
}

for _, module in ipairs(files) do
    local success, err = pcall(function()
        loadstring(game:HttpGet(repo .. module .. ".lua"))()
    end)
    if not success then
        warn("[Crypt] Failed to load " .. module .. ": " .. err)
    end
end
