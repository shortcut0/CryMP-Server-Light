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
ServerEvent_OnScriptLoading       = Inc()
ServerEvent_OnMapCommand          = Inc()
ServerEvent_OnPostInit            = Inc()
ServerEvent_OnInit          = Inc()

ServerEvent_MAX = IncEnd()

ServerScriptEvent_OnProfileValidated = "OnProfileValidated"
ServerScriptEvent_OnValidationFailed = "OnValidationFailed"
ServerScriptEvent_OnPostInit = "OnPostInitialize"
ServerScriptEvent_OnInit = "OnInitialize"

----------------------------
---    SERVER NETWORK    ---
ServerNetwork_GetRegister = 0
ServerNetwork_GetUpdater  = 1

----------------------------
---     SERVER TIMERS    ---
ServerTimer_ExportComponentData = "ExportComponentData"

----------------------------
---      SERVER CHAT     ---

BattleLog_Information = 1

ChatType_ToAll = 5
ChatType_ToTeam = 6
ChatType_ToTarget = 7

ChatType_Console         = TextMessageConsole
ChatType_ConsoleCentered = TextMessageConsole + 10

ChatType_Center  = TextMessageCenter
ChatType_Error   = TextMessageError
ChatType_Info    = TextMessageInfo
ChatType_Server  = TextMessageServer

ChatEntity_Server = -1000

----------------------------
---       GAME VARS      ---
GameTeam_US = 2
GameTeam_NK = 1
GameTeam_Neutral = 0
GameTeam_NK_String = "NK"
GameTeam_US_String = "US"
GameTeam_Neutral_String = "Neutral"

GameMode_IA = "InstantAction"
GameMode_PS = "PowerStruggle"
GameMode_TIA = "TeamInstantAction"

GameRank_PVT = 1
GameRank_CPL = 2
GameRank_SGT = 3
GameRank_LT = 4
GameRank_CPT = 5
GameRank_MAJ = 6
GameRank_COL = 7
GameRank_GEN = 8

KillType_Unknown   = 0
KillType_Suicide   = 1
KillType_Team      = 2
KillType_Enemy     = 3
KillType_Bot       = 4
KillType_BotDeath  = 5

----------------------------

XPEvent_ChatMessage = 1
XPEvent_CommandUsed = 2

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
CommandArg_TypeTeam = 9     -- a valid team name or id

----------------------------
ALL_PLAYERS = 1000

----------------------------
CmdResp_Success = 3
CmdResp_SuccessQuiet = 4
CmdResp_RawMessage = 5

----------------------------
ConfigType_Any = 1
ConfigType_String = 2
ConfigType_Number = 3
ConfigType_Array = 4
ConfigType_Boolean = 5

----------------------------

PlayerData_Equipment = "Equipment"

----------------------------
---
StatisticsEvent_OnNewChannel = 1
StatisticsEvent_ServerLifetime = 2
StatisticsEvent_OnCommandUsed = 3
StatisticsEvent_OnWallJumped = 4
StatisticsEvent_PlayerRecord = 5
StatisticsEvent_ClientDataSent = 6

StatisticsValue_ServerLifetime = "ServerLifetime"
StatisticsValue_ChannelCount = "ChannelCount"
StatisticsValue_ChannelRecord = "ChannelRecord"
StatisticsValue_ChatCommandsUsed = "ChatCommandsUsed"
StatisticsValue_TotalWallJumps = "TotalWallJumps"
StatisticsValue_PlayerRecord = "PlayerRecord"
StatisticsValue_ClientDataSent = "ClientDataTransferred"

----------------------------

Effect_LightExplosion   = "explosions.light.portable_light";
Effect_Flare		    = "explosions.flare.a";
Effect_FlareNight	    = "explosions.flare.night_time";
Effect_Firework	        = "misc.extremly_important_fx.celebrate";
Effect_C4Explosive      = "explosions.C4_explosion.ship_door";
Effect_Claymore	        = "explosions.mine.claymore";
Effect_AlienBeam	    = "alien_weapons.singularity.Tank_Singularity_Spinup";

----------------------------

DisconnectType_Timeout                 = 0
DisconnectType_ProtocolError           = 1
DisconnectType_ResolveFailed           = 2
DisconnectType_VersionMismatch         = 3
DisconnectType_ServerFull              = 4
DisconnectType_Kicked                  = 5
DisconnectType_Banned                  = 6
DisconnectType_ContextCorruption       = 7
DisconnectType_AuthenticationFailed    = 8
DisconnectType_NotLoggedIn             = 9
DisconnectType_CDKeyCheckFailed        = 10
DisconnectType_GameError               = 11
DisconnectType_NotDX10Capable          = 12
DisconnectType_NubDestroyed            = 13
DisconnectType_ICMPError               = 14
DisconnectType_NatNegError             = 15
DisconnectType_PunkDetected            = 16
DisconnectType_DmoPlaybackFinished     = 17
DisconnectType_DmoPlaybackFileNotFound = 18
DisconnectType_UserRequested           = 19
DisconnectType_NoController            = 20
DisconnectType_CantConnect             = 21
DisconnectType_ModMismatch             = 22
DisconnectType_MapNotFound             = 23
DisconnectType_MapVersion              = 24
DisconnectType_Unknown                 = 25

----------------------------
GLOBAL_SERVER_IP_KEY            = 1000
GLOBAL_SERVER_PUBLIC_PORT_KEY	= 1001
GLOBAL_SERVER_NAME_KEY          = 1002

----------------------------
BuildingType_Bunker = "Bunker"
BuildingType_Base = "Base"
BuildingType_Alien = "Alien"
BuildingType_HQ = "HQ"
BuildingType_Air = "Air"
BuildingType_Small = "Small"
BuildingType_War = "War"
BuildingType_Boat = "Boat"
BuildingType_Proto = "Proto"

----------------------------

GlobalKeys = {

    -- ================================
    -- Vehicles
    VehicleLocked = 10,
    VehicleReserved = 11,

    -- ================================
    -- Players
    PlayerUUIDCheck = 245,
    PlayerUUIDSalt = 246,
    PlayerModel = 1000,
    PlayerModelNK = 1000 + GameTeam_NK,
    PlayerModelUS = 1000 + GameTeam_US,

    -- ================================
    -- Misc
    -- ...
}


----------------------------

SandboxState_BouncyVehicles = 0

----------------------------
PRIORITY_NONE = 1
PRIORITY_LOWEST = 2
PRIORITY_LOWER = 3
PRIORITY_LOW = 4
PRIORITY_NORMAL = 5
PRIORITY_HIGH = 6
PRIORITY_HIGHER = 7
PRIORITY_HIGHEST = 8