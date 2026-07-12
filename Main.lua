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

for _, module in ipairs(files) do
    local ok, err = pcall(function()
        loadstring(game:HttpGet(repo .. module .. ".lua"))()
    end)
    if not ok then
        warn("[Crypt] " .. module .. " failed: " .. tostring(err))
    end
end
