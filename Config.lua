-- Crypt-MM2-Legit | Config
-- !! IMPORTANT: BackgroundDecal and MinimizeIconDecal need IMAGE IDs not Decal IDs !!
-- HOW TO GET THE CORRECT ID:
--   1. Open Roblox Studio
--   2. Insert a Part into workspace
--   3. Add a Decal object to the Part
--   4. Set Decal.Texture to rbxassetid://YOUR_DECAL_ID
--   5. The Texture field will AUTO-CHANGE to the real image ID
--   6. Copy THAT number — use it here
-- OR: The script will auto-resolve it for you via InsertService

_G.Config = {
    BackgroundDecal    = "rbxassetid://6311243701",
    MinimizeIconDecal  = "rbxassetid://10815904377",

    Icon_Main          = "rbxassetid://13060262582",
    Icon_Aimbot        = "rbxassetid://108977717302566",
    Icon_Visuals       = "rbxassetid://13321848342",
    Icon_LocalPlayer   = "rbxassetid://124871982298256",
    Icon_Murderer      = "rbxassetid://7485051733",
    Icon_Sheriff       = "rbxassetid://16029076062",
    Icon_Farm          = "rbxassetid://111098288810374",

    ToggleKey          = Enum.KeyCode.RightShift,
    WindowSize         = UDim2.new(0, 560, 0, 440),
    IconSize           = UDim2.new(0, 54, 0, 54),
    StartPosition      = UDim2.new(0.5, -280, 0.5, -220),
}
