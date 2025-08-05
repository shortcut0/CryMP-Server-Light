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

ServerScriptEvent_OnProfileValidated = "OnProfileValidated"
ServerScriptEvent_OnValidationFailed = "OnValidationFailed"

----------------------------
---    SERVER NETWORK    ---
ServerNetwork_GetRegister = 0
ServerNetwork_GetUpdater  = 1

----------------------------
---     SERVER TIMERS    ---
ServerTimer_ExportComponentData = "ExportComponentData"

----------------------------
---      SERVER CHAT     ---

ChatType_ToAll = 5
ChatType_ToTeam = 6
ChatType_ToTarget = 7

ChatType_Console         = TextMessageConsole
ChatType_ConsoleCentered = TextMessageConsole + 10

ChatType_Center  = TextMessageCenter
ChatType_Error   = TextMessageError
ChatType_Info    = TextMessageInfo
ChatType_Server  = TextMessageServer

----------------------------
---       GAME VARS      ---
GameTeam_NK = 1
GameTeam_US = 2
GameTeam_Neutral = 3
GameTeam_NK_String = "NK"
GameTeam_US_String = "US"
GameTeam_Neutral_String = "Neutral"

GameMode_IA = "InstantAction"
GameMode_PS = "PowerStruggle"

----------------------------
---     SERVER LOCALE    ---
Language_None       = "None"
Language_English    = "English"
Language_German     = "German"
Language_Russian    = "Russian"
Language_French     = "French"
Language_Czech      = "Czech"
Language_Spanish    = "Spanish"

----------------------------
---     ANYTHING ELSE    ---

CommandArg_TypeNumber = 1   -- number
CommandArg_TypeString = 2   -- string
CommandArg_TypeBoolean = 3  -- boolean
CommandArg_TypePlayer = 4   -- Expects a valid player
CommandArg_TypeMessage = 5  -- Concat all args
CommandArg_TypeTime = 6     -- a Time value (1d, 86400)
CommandArg_TypeAccess = 7   -- a valid server access level
CommandArg_TypeCVar = 8     -- a valid cvar

ALL_PLAYERS = 1000