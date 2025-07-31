-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
--                  In this File you will find a General Collection-
--                   Of Various Globals used throughout the Project
-- ===================================================================================

----------------------------

INSTANT_ACTION = "InstantAction"
POWER_STRUGGLE = "PowerStruggle"

g_pGame = nil
g_sGameRules = nil

GetCVar = System.GetCVar
SetCVar = System.SetCVar

----------------------------
---    SERVER EVENTS      --
ServerEvent_OnUpdate              = Inc(1)
ServerEvent_OnTimerSecond         = Inc()
ServerEvent_OnTimerMinute         = Inc()
ServerEvent_OnTimerHourly         = Inc()
ServerEvent_OnCheat               = Inc()
ServerEvent_RequestDropWeapon     = Inc()
ServerEvent_RequestPickWeapon     = Inc()
ServerEvent_RequestUseWeapon      = Inc()
ServerEvent_OnWeaponDropped       = Inc()
ServerEvent_OnShoot               = Inc()
ServerEvent_OnStartReload         = Inc()
ServerEvent_OnEndReload           = Inc()
ServerEvent_OnMelee               = Inc()
ServerEvent_RequestPickObject     = Inc()
ServerEvent_OnObjectPicked        = Inc()
ServerEvent_OnExplosivePlaced     = Inc()
ServerEvent_OnExplosiveRemoved    = Inc()
ServerEvent_OnHitAssistance       = Inc()
ServerEvent_OnConnection          = Inc()
ServerEvent_OnChannelDisconnect   = Inc()
ServerEvent_OnClientDisconnect    = Inc()
ServerEvent_OnClientEnteredGame   = Inc()
ServerEvent_OnWallJump            = Inc()
ServerEvent_OnChatMessage         = Inc()
ServerEvent_OnEntityCollision     = Inc()
ServerEvent_OnSwitchAccessory     = Inc()
ServerEvent_OnProjectileHit       = Inc()
ServerEvent_OnLeaveWeaponModify   = Inc()
ServerEvent_OnProjectileExplosion = Inc()
ServerEvent_CanStartNextLevel     = Inc()
ServerEvent_OnRadarScanComplete   = Inc()
ServerEvent_OnGameShutdown        = Inc()
ServerEvent_OnMapStarted          = Inc()
ServerEvent_OnEntitySpawn         = Inc()
ServerEvent_OnVehicleSpawn        = Inc()
ServerEvent_OnScriptLoaded        = Inc()
ServerEvent_OnMapCommand          = Inc()

ServerEvent_MAX = IncEnd()

----------------------------
---    SERVER NETWORK    ---
ServerNetwork_GetRegister = 0
ServerNetwork_GetUpdater  = 1

----------------------------
---     FILE  SYSTEM     ---