-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
--                            English Server-Dictionary
-- ===================================================================================

Server.LocalizationManager:Add({
    {
        String = "commands_loaded",
        Languages = {
            English = "Loaded {Red}{Count}{Gray} Chat-Commands.."
        }
    },
    {
        String = "users_loaded",
        Languages = {
            English = "Loaded {Red}{Count}{Gray} Registered Users.."
        }
    },
})

Server.LocalizationManager:Add({
    {
        String = "post_initialization_time",
        Languages = {
            English = "Post-Initialization took {Red}{Time}"
        }
    },
    {
        String = "initialization_time",
        Languages = {
            English = "Full Initialization took {Red}{Time}"
        }
    },
    {
        String = "initialization_start",
        Languages = {
            English = "Server is Re-Initializing, Prepare for {Red}Interruptions"
        }
    },
    {
        String = "post_initialization_start",
        Languages = {
            English = "Server is Post-Initializing, Prepare for {Red}Interruptions"
        }
    },
})

Server.LocalizationManager:Add({
    {
        String = "commandList_help_1",
        Languages = {
            English = "{Yellow}INFO: {Gray}Type {White}!{Gray}Command {Yellow}--help {Gray} To View Detailed Info about a Command"
        }
    },
    {
        String = "commandList_help_2",
        Languages = {
            English = "      {Red}Red {Gray}Commands are Temporarily {Red}Unavailable{Gray} to you"
        }
    },
    {
        String = "commandHelp_Chat",
        Languages = {
            English = "Info sent to Console"
        }
    },
    {
        String = "command_reserved",
        Languages = {
            English = "Reserved for {Class} Users"
        }
    },
    {
        String = "command_notFound",
        Languages = {
            English = "Unknown Command"
        }
    },
    {
        String = "command_listFound",
        Languages = {
            English = "Open your Console to View the {Count} Matches"
        }
    },
    {
        String = "command_gameRules",
        Languages = {
            English = "Only in {Class}"
        }
    },
    {
        String = "command_inVehicle",
        Languages = {
            English = "Only inside Vehicles"
        }
    },
    {
        String = "command_notInVehicle",
        Languages = {
            English = "Leave your Vehicle"
        }
    },
    {
        String = "command_inDoors",
        Languages = {
            English = "Only inside Buildings"
        }
    },
    {
        String = "command_notInDoors",
        Languages = {
            English = "Leave the Building"
        }
    },
    {
        String = "command_spectating",
        Languages = {
            English = "Only for Spectators"
        }
    },
    {
        String = "command_notSpectating",
        Languages = {
            English = "Only In-Game"
        }
    },
    {
        String = "command_onlyAlive",
        Languages = {
            English = "Only while Alive"
        }
    },
    {
        String = "command_onlyDead",
        Languages = {
            English = "Only while Dead"
        }
    },
    {
        String = "command_coolDown",
        Languages = {
            English = "Please wait {Time}"
        }
    },
    {
        String = "command_scriptError",
        Languages = {
            English = "Script Error! Please report this using !report"
        }
    },
    {
        String = "command_broken",
        Languages = {
            English = "Script Broken! Please report this using !report"
        }
    },
    {
        String = "command_disabled",
        Languages = {
            English = "Command Disabled{Reason}"
        }
    },
    {
        String = "command_consoleLog",
        Languages = {
            English = "{Red}{Name}{Gray} Executed {White}!{Command}{Gray} {Reply}"
        }
    },
    {
        String = "command_argNMissing",
        Languages = {
            English = "Argument {Index} is Required"
        }
    },
    {
        String = "command_argPlayerNotFound",
        Languages = {
            English = "Player {Player} not Found"
        }
    },
    {
        String = "command_argNotSelf",
        Languages = {
            English = "Cannot target yourself"
        }
    },
    {
        String = "command_argNotNumber",
        Languages = {
            English = "Argument {Index} expects a Number"
        }
    },
    {
        String = "command_argTooHigh",
        Languages = {
            English = "Argument {Index} Value too high"
        }
    },
    {
        String = "command_argTooLow",
        Languages = {
            English = "Argument {Index} Value too low"
        }
    },
    {
        String = "command_argInvalidTime",
        Languages = {
            English = "Argument {Index} expects a Duration"
        }
    },
    {
        String = "command_argNotACVar",
        Languages = {
            English = "CVar {CVar} does not exist"
        }
    },
    {
        String = "command_argInvalidTeam",
        Languages = {
            English = "Team {Team} is Invalid"
        }
    },
    {
        String = "command_argNotAccess",
        Languages = {
            English = "Invalid Access"
        }
    },
    {
        String = "command_noFilterMatch",
        Languages = {
            English = "No Commands Match your Filter '{Red}{Filter}{Gray}'"
        }
    },
})

Server.LocalizationManager:Add({
    {
        String = "channel_created",
        Extended = ServerAccess_Admin,
        Languages = {
            -- PirateSoftware (CA, Canada) Connecting on Channel 5
            English = {
                Regular = "({Red}{CountryCode}{Gray}, {Red}{Country}{Gray}) {Red}{Nick}{Gray} Connecting on Channel {Red}{Channel}",
                Extended = "({Red}{CountryCode}{Gray}, {Red}{Country}{Gray}) {Red}{Nick}{Gray} Connecting on Channel {Red}{Channel} {Gray}({Red}{IP}{Gray})",
            },
        },
    },
    {
        String = "channel_disconnect",
        Extended = ServerAccess_Admin,
        Languages = {
            -- PirateSoftware Disconnecting from Channel 5 (Disconnected, NetAspect7: Crysis had a Stroke!)
            English = {
                Regular = "{Red}{Nick}{Gray} Disconnecting from Channel {Red}{Channel}{Gray} ({Red}{ShortReason}{Gray})",
                Extended = "{Red}{Nick}{Gray} Disconnecting from Channel {Red}{Channel}{Gray} ({Red}{ShortReason}{Gray}, {Red}{Reason}{Gray})",
            },
        },
    },
    {
        String = "player_connected",
        Extended = ServerAccess_Admin,
        Languages = {
            -- (CA) PirateSoftware Connected on Channel 5 (16s)
            English = {
                Regular = "{Red}{Name}{Gray} Connected on Channel {Red}{Channel}{Gray} In {Red}{Time}{Gray} ({Red}{CountryCode}{Gray}, {Red}{CountryName}{Gray})",
                Extended = "{Red}{Name}{Gray} Connected on Channel {Red}{Channel}{Gray} In {Red}{Time}{Gray} ({Red}{CountryCode}{Gray}, {Red}{CountryName}{Gray})",
            },
        },
    },
    {
        String = "player_connectedChat",
        Languages = {
            -- (CA) PirateSoftware Connected on Channel 5 (16s)
            English = {
                Regular = "{Name} Connected on Channel {Channel} ({CountryCode}, {ISP})",
            },
        },
    },
    {
        String = "player_disconnected",
        Extended = ServerAccess_Admin,
        Languages = {
            -- PirateSoftware Disconnected (15h: 31m: 10s, Disconnected)
            English = {
                Regular = "{Red}{Name}{Gray} Disconnected ({Red}{Time}{Gray}, {Red}{ShortReason}{Gray})",
                Extended = "{Red}{Name}{Gray} Disconnected from Channel {Red}{Channel}{Gray} ({Red}{Time}{Gray}, {Red}{ShortReason}{Gray})",
            },
        },
    },
    {
        String = "player_disconnectedChat",
        Languages = {
            -- PirateSoftware Disconnected (15h: 31m: 10s, Disconnected)
            English = {
                Regular = "{Name} Disconnected ({Time}, {ShortReason}}",
            },
        },
    },
})

Server.LocalizationManager:Add({
    {
        String = "user_notValidatedQuit",
        Languages = {
            English = "User {Red}{UserName}{Gray} Quit before Validation could finish"
        }
    },
    {
        String = "user_validating",
        Languages = {
            English = "Validating Profile {Red}{ProfileId}{Gray} from User {Red}{UserName}"
        }
    },
    {
        String = "user_notValidated",
        Languages = {
            English = "Failed to Validate Profile {Red}{ProfileId}{Gray} from User {Red}{UserName}{Gray}"
        }
    },
    {
        String = "user_validated",
        Languages = {
            English = "Profile {Red}{ProfileId}{Gray} from User {Red}{UserName}{Gray} Has been Verified"
        }
    },
    {
        String = "user_restored",
        Languages = {
            English = "Granting Access {AccessColor}{AccessName}{Gray} to Registered User {Red}{UserName}"
        }
    },
    {
        String = "user_accessAssigned",
        Languages = {
            English = "{Temporary}Assigning Access {AccessColor}{AccessName}{Gray} to {Local}Player {Red}{UserName}"
        }
    },
    {
        String = "user_ipIdAssigned",
        Languages = {
            English = "Assigned IP-Profile {Red}{ID}{Gray} to User {Red}{UserName}"
        }
    },
    {
        String = "user_deleted",
        Languages = {
            English = "Registered User {Red}{UserName}{Gray} ({Red}{ProfileID}{Gray}) has been {Red}Deleted{Gray} by {Orange}{AdminName}"
        }
    },
    {
        String = "user_registered",
        Languages = {
            -- Shortcut0 has Registered User PirateSoftware (1008858) As Admin
            English = "{Red}{AdminName}{Gray} Has Registered User {Red}{UserName}{Gray} ({Red}{ProfileID}{Gray}) As {AccessColor}{AccessName}{Gray}"
        }
    },
    {
        String = "user_renamed",
        Languages = {
            English = "{Red}{OldName}{Gray} has been renamed to {Red}{NewName}{Gray} ({Red}{Reason}{Gray})"
        }
    },
})


-- ===================================================================================

Server.LocalizationManager:Add({
    {
        String = "str_arguments",
        Languages = {
            English = "Arguments"
        }
    },
    {
        String = "str_team",
        Languages = {
            English = "Team"
        }
    },
    {
        String = "str_pm",
        Languages = {
            English = "PM"
        }
    },
    {
        String = "str_disabled",
        Languages = {
            English = "Disabled"
        }
    },
    {
        String = "str_failed",
        Languages = {
            English = "Failed"
        }
    },
    {
        String = "str_noFeedback",
        Languages = {
            English = "No Feedback"
        }
    },
    {
        String = "str_success",
        Languages = {
            English = "Success"
        }
    },
    {
        String = "str_broken",
        Languages = {
            English = "Broken"
        }
    },
    {
        String = "str_command",
        Languages = {
            English = "Command"
        }
    },
    {
        String = "str_usedX",
        Languages = {
            English = "{X} Used"
        }
    },
    {
        String = "str_used",
        Languages = {
            English = "Used"
        }
    },
    {
        String = "str_temporarily",
        Languages = {
            English = "Temporarily"
        }
    },
    {
        String = "str_demoted",
        Languages = {
            English = "Demoted"
        }
    },
    {
        String = "str_promoted",
        Languages = {
            English = "Promoted"
        }
    },
    {
        String = "str_local",
        Languages = {
            English = "Local"
        }
    },
    {
        String = "str_Never",
        Languages = {
            English = "Never"
        }
    },
    {
        String = "str_Today",
        Languages = {
            English = "Today"
        }
    },
    {
        String = "str_ago",
        Languages = {
            English = "Ago"
        }
    },
    {
        String = "str_online",
        Languages = {
            English = "Online"
        }
    },
    {
        String = "str_offline",
        Languages = {
            English = "Offline"
        }
    },
    {
        String = "str_usage",
        Languages = {
            English = "Usage"
        }
    },
    {
        String = "str_prefixes",
        Languages = {
            English = "Prefixes"
        }
    },
    {
        String = "str_description",
        Languages = {
            English = "Description"
        }
    },
})


-- ===================================================================================

Server.LocalizationManager:Add({
    {
        String = "user_decision",
        Languages = {
            English = "User Decision"
        }
    },
    {
        String = "admin_decision",
        Languages = {
            English = "Admin Decision"
        }
    },
    {
        String = "admin",
        Languages = {
            English = "Admin"
        }
    },
    {
        String = "expiry",
        Languages = {
            English = "Expiry"
        }
    },
    {
        String = "insufficientAccess",
        Languages = {
            English = "Insufficient Access"
        }
    },
    {
        String = "alreadyAccess",
        Languages = {
            English = "Access already {Class}"
        }
    },
    {
        String = "insufficientPrestige",
        Languages = {
            English = "Insufficient Prestige"
        }
    },
    {
        String = "classList",
        Languages = {
            English = "{Class} - List"
        }
    },
    {
        String = "entitiesListedInConsole",
        Languages = {
            English = "Open your Console to View the List of {Count} {Class}"
        }
    },
    {
        String = "noClassToDisplay",
        Languages = {
            English = "No {Class} to Display Available"
        }
    },
    {
        String = "noClassMatchingFilter",
        Languages = {
            English = "No {Class} Matching Filter '{Filter}' Available"
        }
    },
    {
        String = "welcome_toTheServer",
        Languages = {
            English = "Welcome to the Server"
        }
    },
    {
        String = "yourLastVisit",
        Languages = {
            English = "Your Last Visit"
        }
    },
    {
        String = "nextMap",
        Languages = {
            English = "Next Map"
        }
    },
    {
        String = "no_description",
        Languages = {
            English = "No Description"
        }
    },
    {
        String = "rmi_flags_fixed",
        Languages = {
            English = "Fixed {Red}{Count}{Gray} Dangerous RMI Flags for Class {Red}{Class}"
        }
    },
    {
        String = "patcher_initialized",
        Languages = {
            English = "Patched {Red}{Functions}{Gray} Members from {Red}{Classes}{Gray} Classes"
        }
    },
    {
        String = "next",
        Languages = {
            English = "Next"
        }
    },
    {
        String = "never",
        Languages = {
            English = "Never"
        }
    },
    {
        String = "ago",
        Languages = {
            English = "Ago"
        }
    },
    {
        String = "too_short",
        Languages = {
            English = "too short"
        }
    },
    {
        String = "too_long",
        Languages = {
            English = "too long"
        }
    },
    {
        String = "name_in_use",
        Languages = {
            English = "Name already in Use"
        }
    },
    {
        String = "count_players_renamed",
        Languages = {
            English = "{Count} Players have been Renamed"
        }
    },
    {
        String = "reason",
        Languages = {
            English = "Reason"
        }
    },
    {
        String = "target",
        Languages = {
            English = "Target"
        }
    },
    {
        String = "name",
        Languages = {
            English = "Name"
        }
    },
    {
        String = "invalid_name",
        Languages = {
            English = "Invalid Name"
        }
    },
    {
        String = "forbidden",
        Languages = {
            English = "Forbidden"
        }
    },
    {
        String = "enabled",
        Languages = {
            English = "Enabled"
        }
    },
    {
        String = "enabled_on",
        Languages = {
            English = "Enabled On {Name}"
        }
    },
    {
        String = "disabled",
        Languages = {
            English = "Disabled"
        }
    },
    {
        String = "disabled_on",
        Languages = {
            English = "Disabled On {Name}"
        }
    },
    {
        String = "projectile_eliminated",
        Languages = {
            English = "{Pre}Projectile Eliminated"
        }
    },
    {
        String = "this_is_friendlyExplosive",
        Languages = {
            English = "WARNiNG: This is a Friendly Explosive"
        }
    },
    {
        String = "this_is_yourExplosive",
        Languages = {
            English = "WARNiNG: This is your Explosive"
        }
    },
    {
        String = "yourself",
        Languages = {
            English = "Yourself"
        }
    },
    {
        String = "Friendly",
        Languages = {
            English = "Friendly"
        }
    },
    {
        String = "reserved",
        Languages = {
            English = "Reserved"
        }
    },
    {
        String = "Option",
        Languages = {
            English = "Option"
        }
    },
    {
        String = "you_were",
        Languages = {
            English = "You were"
        }
    },
    {
        String = "you_were_revived",
        Languages = {
            English = "You have been Revived"
        }
    },
    {
        String = "you_were_broughtTo",
        Languages = {
            English = "You have been Brought to {To}"
        }
    },
    {
        String = "you_teleportedTo",
        Languages = {
            English = "You Teleported to {To} Location"
        }
    },
    {
        String = "x_teleportedToYou",
        Languages = {
            English = "{X} Teleported to your Location"
        }
    },
    {
        String = "hitaccuracy",
        Languages = {
            English = "HIT:ACCURACY"
        }
    },
    {
        String = "hit_accuracy_0",
        Languages = {
            English = "COMPLETE AZZ ({Percent}%%)"
        }
    },
    {
        String = "hit_accuracy_5",
        Languages = {
            English = "SLiNGSHOT GRANNY ({Percent}%%)"
        }
    },
    {
        String = "hit_accuracy_10",
        Languages = {
            English = "STORMTROOPER ({Percent}%%)"
        }
    },
    {
        String = "hit_accuracy_20",
        Languages = {
            English = "NiGHTMARE ({Percent}%%)"
        }
    },
    {
        String = "hit_accuracy_30",
        Languages = {
            English = "SHAMEFUL ({Percent}%%)"
        }
    },
    {
        String = "hit_accuracy_40",
        Languages = {
            English = "WEAK ({Percent}%%)"
        }
    },
    {
        String = "hit_accuracy_50",
        Languages = {
            English = "NOT GOOD ({Percent}%%)"
        }
    },
    {
        String = "hit_accuracy_60",
        Languages = {
            English = "NOT BAD ({Percent}%%)"
        }
    },
    {
        String = "hit_accuracy_70",
        Languages = {
            English = "VERY DECENT ({Percent}%%)"
        }
    },
    {
        String = "hit_accuracy_80",
        Languages = {
            English = "SNiPER LiKE ({Percent}%%)"
        }
    },
    {
        String = "hit_accuracy_90",
        Languages = {
            English = "GOD LiKE ({Percent}%%)"
        }
    },
    {
        String = "hit_accuracy_99",
        Languages = {
            English = "FUCKiNG AiMBOT ({Percent}%%)"
        }
    },
    {
        String = "first_blood_instantAction",
        Languages = {
            English = "{Shooter} SCORED FIRST:BLOOD ( +{XP} XP )"
        }
    },
    {
        String = "first_blood_teamRwd",
        Languages = {
            English = "First Blood Share"
        }
    },
    {
        String = "first_blood_soloRwd",
        Languages = {
            English = "First Blood"
        }
    },
    {
        String = "first_blood_powerStruggle",
        Languages = {
            -- [ PirateSoftware ] SCORED FIRST:BLOOD for TEAM US (WiNS +500 PP, +25 CP)
            -- [ PirateSoftware ] SCORED FIRST:BLOOD for TEAM US (Entire Team +500 PP, +25 CP)
            English = "{Red}{Shooter}{Gray} SCORED {Red}{Amplified}{Gray}FIRST{Red}:{Gray}BLOOD for TEAM {Red}{Team}{Gray} ({TeamReward}+{Red}{PP}{Gray} PP, +{Red}{CP}{Gray} XP)"
        }
    },
    {
        String = "entire_team",
        Languages = {
            English = "Entire Team"
        }
    },
    {
        String = "enemy",
        Languages = {
            English = "Enemy"
        }
    },
    {
        String = "Eliminated",
        Languages = {
            English = "Eliminated"
        }
    },
    {
        String = "factory_defended",
        Languages = {
            English = "Factory Defended"
        }
    },
    {
        String = "suicide",
        Languages = {
            English = "Suicide"
        }
    },
    {
        String = "special_sniper_kill",
        Languages = {
            English = "SNiPER:KiLL {Distance}m"
        }
    },
    {
        String = "team_kill",
        Languages = {
            English = "Team Kill"
        }
    },
    {
        String = "vehicle",
        Languages = {
            English = "Vehicle"
        }
    },
    {
        String = "Ammo",
        Languages = {
            English = "Ammo"
        }
    },
    {
        String = "Refund",
        Languages = {
            English = "Refund"
        }
    },
    {
        String = "Bought",
        Languages = {
            English = "Bought"
        }
    },
    {
        String = "sold",
        Languages = {
            English = "Sold"
        }
    },
    {
        String = "destroyed",
        Languages = {
            English = "Destroyed"
        }
    },
    {
        String = "disarmed",
        Languages = {
            English = "Disarmed"
        }
    },
    {
        String = "repaired",
        Languages = {
            English = "Repaired"
        }
    },
    {
        String = "stolen",
        Languages = {
            English = "Stolen"
        }
    },
    {
        String = "team",
        Languages = {
            English = "Team"
        }
    },
    {
        String = "headquarters",
        Languages = {
            English = "HQ"
        }
    },
    {
        String = "captured",
        Languages = {
            English = "Captured"
        }
    },
    {
        String = "kill_assist",
        Languages = {
            -- KiLL:ASSiSTANCE 53.11% ( +60 PP, +30 CP )
            English = "KiLL:ASSiSTANCE"
        }
    },
    {
        String = "item_invest_reward",
        Languages = {
            English = "Item Share"
        }
    },
    {
        String = "hostiles_on_radar",
        Languages = {
            English = "Detected {Count} Hostiles Nearby"
        }
    },
    {
        String = "spawn_prestige",
        Languages = {
            English = "Spawn Prestige"
        }
    },
    {
        String = "spawning_as",
        Languages = {
            English = "Spawning As"
        }
    },
    {
        String = "x_entities_scanned",
        Languages = {
            English = "{Count} Entities Scanned"
        }
    },
    {
        String = "no_entities_scanned",
        Languages = {
            English = "No Activity Nearby"
        }
    },
    {
        String = "hits_remaining",
        Languages = {
            English = "Hits Remaining"
        }
    },
    {
        String = "turret",
        Languages = {
            English = "Turret"
        }
    },
    {
        String = "Item",
        Languages = {
            English = "Item"
        }
    },
    {
        String = "Filter",
        Languages = {
            English = "Filter"
        }
    },
    {
        String = "unclaimed_vehicle_countdown",
        Languages = {
            English = "Unclaimed Vehicle will be Removed in ({Time}) Seconds"
        }
    },
    {
        String = "cannot_sell_item",
        Languages = {
            English = "{Class} - Cannot be Sold"
        }
    },
    {
        String = "no_item_to_sell",
        Languages = {
            English = "No sellable Item Holstered"
        }
    },
    {
        String = "ammo_not_found",
        Languages = {
            English = "Ammo {Class} Not Found"
        }
    },
    {
        String = "item_not_found",
        Languages = {
            English = "Item {Class} Not Found"
        }
    },
    {
        String = "insufficient_pp_vehicle",
        Languages = {
            English = "You need {Missing} more Prestige to buy the Vehicle {Class}"
        }
    },
    {
        String = "insufficient_pp_item",
        Languages = {
            English = "You need {Missing} more Prestige to buy the Item {Class}"
        }
    },
    {
        String = "sellItem_not_inside_buyZone",
        Languages = {
            English = "Enter a Buy Zone to sell Equipment"
        }
    },
    {
        String = "everyone_movedToTeam",
        Languages = {
            English = "Moved all Players to Team {TeamName}"
        }
    },
    {
        String = "you_were_movedToTeam",
        Languages = {
            English = "You have been moved to Team {TeamName}"
        }
    },
    {
        String = "already_inTeam",
        Languages = {
            English = "{Target} already in Team {TeamName}"
        }
    },
    {
        String = "movedToTeam",
        Languages = {
            English = "{Target} Moved to Team {TeamName}"
        }
    },
    {
        String = "you_are",
        Languages = {
            English = "You are"
        }
    },
    {
        String = "unknown",
        Languages = {
            English = "Unknown"
        }
    },
    {
        String = "average_ping_warning",
        Languages = {
            English = "{Yellow}Warning:{Gray} Average Ping above {Red}{Threshold}{Gray} ({Red}{Average}{Gray})"
        }
    },
    {
        String = "ping_warning",
        Languages = {
            English = "WARNiNG #{Count}/{Limit} | Your Ping is too High! ({Ping} / {PingLimit})"
        }
    },
    {
        String = "banlist",
        Languages = {
            English = "BAN{Red}:{Gray}LIST"
        }
    },
    {
        String = "baninfo",
        Languages = {
            English = "BAN{Red}:{Gray}iNFO"
        }
    },
    {
        String = "unique_name",
        Languages = {
            English = "Unique Name"
        }
    },
    {
        String = "unique_id",
        Languages = {
            English = "Unique ID"
        }
    },
    {
        String = "access",
        Languages = {
            English = "Access"
        }
    },
    {
        String = "time_ago",
        Languages = {
            English = "Time Ago"
        }
    },
    {
        String = "banned_by",
        Languages = {
            English = "Banned By"
        }
    },
    {
        String = "hard_ban",
        Languages = {
            English = "Hard-Ban"
        }
    },
    {
        String = "bans",
        Languages = {
            English = "Bans"
        }
    },
    {
        String = "ban_index_info",
        Languages = {
            English = "For {Red}Detailed{Gray} Info, Index a Ban using {White}!{Gray}BanInfo <#{Red}ID{Gray}>"
        }
    },
    {
        String = "ban_not_found",
        Languages = {
            English = "Ban not Found"
        }
    },
    {
        String = "no_bans_found",
        Languages = {
            English = "No Bans Found"
        }
    },
    {
        String = "arg_banIndex_desc",
        Languages = {
            English = "The Index of the BanList"
        }
    },
    {
        String = "identifiers",
        Languages = {
            English = "Identifiers"
        }
    },
    {
        String = "for_map",
        Languages = {
            English = "For Map"
        }
    },
    {
        String = "ban_action_info1",
        Languages = {
            English = "Possible Actions: Del, Erase, Flush, Unban, Delete, Remove"
        }
    },
    {
        String = "invalid_action",
        Languages = {
            English = "Invalid Action"
        }
    },
    {
        String = "arg_banAction_desc",
        Languages = {
            English = "The Action you wish to perform on the indexed ban"
        }
    },
    {
        String = "you_are_muted",
        Languages = {
            -- You are Muted | You're out of Mana | Expiry: Never
            -- You are Muted | You're out of Mana | Expiry: 10m 15s
            -- You are Muted | Reason (You're out of Mana) | Expiry: (10m 15s)
            English = "You are Muted | {Reason} | Expiry: {Expiry}"
        }
    },
    {
        String = "player_alreadyMuted",
        Languages = {
            English = "Player Already Muted"
        }
    },
    {
        String = "player_muted",
        Extended = ServerAccess_Moderator,
        Languages = {
            English = {
                Regular = "{Red}{Name}{Gray} Has been {Red}Muted{Gray} ({Red}{Time}{Gray}, {Red}{Reason}{Gray})",
                Extended = "{Red}{Name}{Gray} Has been {Red}Muted{Gray} By {Red}{Admin}{Gray} ({Red}{Time}{Gray}, {Red}{Reason}{Gray})"
            }
        }
    },
    {
        String = "player_unMuted",
        Extended = ServerAccess_Moderator,
        Languages = {
            English = {
                Regular = "{Red}{Name}{Gray} Has been {Red}UnMuted{Gray} ({Red}{Reason}{Gray})",
                Extended = "{Red}{Name}{Gray} Has been {Red}UnMuted{Gray} By {Red}{Admin}{Gray} ({Red}{Reason}{Gray})"
            }
        }
    },
    {
        String = "mute_expired",
        Languages = {
            English = "Mute Expired",
        }
    },
    {
        String = "player_kicked",
        Extended = ServerAccess_Moderator,
        Languages = {
            English = {
                Regular = "{Red}{Name}{Gray} Has been {Red}Kicked{Gray} from the Server ({Red}{Reason}{Gray})",
                Extended = "{Red}{Name}{Gray} Has been {Red}Kicked{Gray} By {Red}{Admin}{Gray} ({Red}{Reason}{Gray})"
            }
        }
    },
    {
        String = "player_banned",
        Extended = ServerAccess_Moderator,
        Languages = {
            English = {
                -- PirateSoftware Has been Banned form the Server (Hes out of mana)
                -- PirateSoftware Banned shortcut0 for 10d:05h:15m (Working at blizzard sucked)

                Regular = "{Red}{Name}{Gray} Has been {Red}Banned{Gray} from the Server (Expiry: {Time}, {Reason})",
                Extended = "{Red}{Admin}{Gray} Banned {Red}{Name}{Gray} (Expiry: {Time}, {Red}{Reason}{Gray})"
            }
        }
    },
    {
        String = "player_banned_ex",
        Extended = ServerAccess_Moderator,
        Languages = {
            English = {
                -- PirateSoftware Has been Banned form the Server (Hes out of mana)
                -- PirateSoftware Banned shortcut0 for 10d:05h:15m (Working at blizzard sucked)

                Regular = "{Red}{Name}{Gray} Was Denied Entry to the Server (Ban Expiry: {Time}, {Reason})",
                Extended = "{Red}{Admin}{Gray} Has Denied {Red}{Name}{Gray} Entry to the Server (Ban Expiry: {Time}, {Reason})"
            }
        }
    },
    {
        String = "player_unbanned",
        Extended = ServerAccess_Moderator,
        Languages = {
            English = {
                Regular  = "{Red}{Name}{Gray} Has been {Green}Unbanned{Gray} ({UnbanReason})",
                Extended = "{Red}{Admin}{Gray} Has been Unbanned by {Red}{Name}{Gray} ({UnbanReason})"
            }
        }
    },
    {
        String = "ban_expired",
        Languages = {
            English = "Ban Expired"
        }
    },
    {
        String = "no_maps_found",
        Languages = {
            English = "No Playable Maps found"
        }
    },
    {
        String = "no_maps_foundOfType",
        Languages = {
            English = "No Maps of Type {Type} found"
        }
    },
    {
        String = "no_maps_foundMatching",
        Languages = {
            English = "No Maps Matching {Filter} found"
        }
    },
    {
        String = "map_restarting",
        Languages = {
            English = "Map Restarting in {Red}{Time}"
        }
    },
    {
        String = "map_timeLimit_changed",
        Languages = {
            English = "Changed Time Limit to {Red}{Time}"
        }
    },
    {
        String = "map_list_info1",
        Languages = {
            English = "Note: {Yellow}YELLOW{Gray} Maps have {Red}NO{Gray} Download-Link | {Red}RED{Gray} Maps are {Red}FORBIDDEN"
        }
    },
    {
        String = "channel",
        Languages = {
            English = "Channel"
        }
    },
    {
        String = "invalid_channel",
        Languages = {
            English = "Invalid Channel"
        }
    },
    {
        String = "last_used_name",
        Languages = {
            English = "Last Used Name"
        }
    },
    {
        String = "no_spawnGroup_selected",
        Languages = {
            English = "You have no Spawn Group Selected!"
        }
    },
    {
        String = "rank_advanced",
        Languages = {
            -- Nomad just Advanced to [ PLASTIC III ]
            -- Nomad just Advanced to ~ PLASTIC III ~
            -- Nomad just Advanced to < PLASTIC III >
            -- Nomad just Advanced to PLASTIC (III)
            English = "{Red}{Name}{Gray} Just Advanced to TIER [ {Red}{Rank}{Gray} ]"
        }
    },
    {
        String = "rank_reset_confirmation",
        Languages = {
            English = "Are you sure you want to Reset your Rank? This Action is Irreversible."
        }
    },
    {
        String = "rank_reset_by",
        Languages = {
            English = "{Red}{Name}{Gray} Rank has been Reset ({Red}{Reason}{Gray})",
        }
    },
    {
        String = "rank_reset_by_admin",
        Extended = ServerAccess_Admin,
        Languages = {
            English = {
                Regular = "{Red}{Name}{Gray} Rank has been Reset ({Red}{Reason}{Gray})",
                Extended = "{Red}{Name}{Gray} Rank has been Reset by {Red}{Admin}{Gray} ({Red}{Reason}{Gray})"
            },
        }
    },
    {
        String = "gift_from",
        Languages = {
            English = "Gift From {Name}",
        }
    },
    {
        String = "Transferred_to",
        Languages = {
            English = "Transferred to {Name}",
        }
    },
    {
        String = "duping_not_allowed",
        Languages = {
            English = "Duping Items or Currency is not Allowed",
        }
    },
    {
        String = "rank_reset",
        Languages = {
            English = "Your Rank has Been Reset!",
        }
    },
    {
        String = "rank_reset_confirmation2",
        Languages = {
            English = "You will lose all Privileges and Bonuses associated with your Current Rank"
        }
    },
    {
        String = "rank_reset_confirmation3",
        Languages = {
            English = "Use this Command Again to proceed with the Reset."
        }
    },
    {
        String = "building_type_alien",
        Languages = {
            English = "Alien Energy Site"
        }
    },
    {
        String = "building_type_prototypeFac",
        Languages = {
            English = "Frodotype Factory"
        }
    },
    {
        String = "building_type_warFac",
        Languages = {
            English = "War Factory"
        }
    },
    {
        String = "building_type_smallFac",
        Languages = {
            English = "Arms Factory"
        }
    },
    {
        String = "building_type_air",
        Languages = {
            English = "Aviation Factory"
        }
    },
    {
        String = "building_type_hq",
        Languages = {
            English = "Headquarters"
        }
    },
    {
        String = "building_type_base",
        Languages = {
            English = "Spawn Base"
        }
    },
    {
        String = "building_type_bunker",
        Languages = {
            English = "Spawn Bunker"
        }
    },
    {
        String = "building_type_navalFac",
        Languages = {
            English = "Naval Factory"
        }
    },
    {
        String = "value",
        Languages = {
            English = "Value"
        }
    },
    {
        String = "cvar_setTo",
        Languages = {
            English = "{Red}{Admin}{Gray} Has Changed CVar {Red}{CVar}{Gray} to {Red}{Value}{Gray}"
        }
    },
    {
        String = "cvar_setTo_chat",
        Languages = {
            English = "{Red}{CVar}{Gray} Changed to {Red}{Value}{Gray}"
        }
    },
    {
        String = "cvar_setRestored",
        Languages = {
            English = "{Red}{CVar}{Gray} Restored to {Red}{Value}{Gray}"
        }
    },
    {
        String = "no_default_value_found",
        Languages = {
            English = "No default Value Found"
        }
    },
    {
        String = "attempt",
        Languages = {
            English = "Attempt"
        }
    },
    {
        String = "commands",
        Languages = {
            English = "Commands"
        }
    },
    {
        String = "cannot_open_door",
        Languages = {
            English = "You cannot Open this Door"
        }
    },
    {
        String = "player",
        Languages = {
            English = "Player"
        }
    },
    {
        String = "defended_our_factory",
        Languages = {
            English = "{Name} Defended Our {Type}!"
        }
    },
    {
        String = "unique_users",
        Languages = {
            English = "Unique Users"
        }
    },
    {
        String = "uniqueId_assigned",
        Languages = {
            English = "Assigned Unique ID {Red}{ID}{Gray} to User {Red}{Name}{Gray} ({Red}{UniqueName}{Gray})"
        }
    },
    {
        String = "user_not_registered",
        Languages = {
            English = "User not Registered"
        }
    },
    {
        String = "unique_name_changed",
        Languages = {
            English = "Update Unique Name from User {Red}{OldName}{Gray} to {Red}{NewName}{Gray}"
        }
    },
    {
        String = "unique_name_changedChat",
        Languages = {
            English = "Updated Name to {NewName}"
        }
    },
    {
        String = "user__count",
        Languages = {
            English = "USER:COUNT"
        }
    },
    {
        String = "registry_date",
        Languages = {
            English = "Registry Date"
        }
    },
    {
        String = "No",
        Languages = {
            English = "No"
        }
    },
    {
        String = "Entries",
        Languages = {
            English = "Entries"
        }
    },
    {
        String = "Online",
        Languages = {
            English = "Online"
        }
    },
    {
        String = "Yes",
        Languages = {
            English = "Yes"
        }
    },
    {
        String = "gameEnd_countDown",
        Languages = {
            English = "Game OVER in ( {Seconds} ) - SECONDS"
        }
    },
    {
        String = "cm_activated",
        Languages = {
            English = "{Name} SELECTED to PLAY as {ModelName}"
        }
    },
    {
        String = "cm_removedCl",
        Languages = {
            English = "Custom Model Removed! You're Playing as Nomad Again"
        }
    },
    {
        String = "you_have_noCM",
        Languages = {
            English = "Already Playing as Nomad"
        }
    },
    {
        String = "choose_different_cm",
        Languages = {
            English = "Already Playing as {Name}"
        }
    },
    {
        String = "cm_reservedForTeam",
        Languages = {
            English = "RESERVED for TEAM {TeamName}"
        }
    },
    {
        String = "custom_models",
        Languages = {
            English = "Custom Models"
        }
    },
    {
        String = "arg_cmId_desc",
        Languages = {
            English = "The Index of the Model List"
        }
    },
    {
        String = "fiveMinutesToDestroyHQ",
        Languages = {
            English = "You get FIVE for MINUTES to FINISH THE MISSION"
        }
    },
    {
        String = "hq_notDestroyable",
        Languages = {
            English = "HQs are Currently not Destroyable"
        }
    },
    {
        String = "hq_protectedTime",
        Languages = {
            English = "HQs Are Currently Protected! Destroyable in [ {Time} ]"
        }
    },
    {
        String = "enemy_hq_hit",
        Languages = {
            English = "Enemy HQ Hit"
        }
    },
    {
        String = "our_hq_wasHit",
        Languages = {
            English = "Our HQ has been HIT by {Red}{Name}{Gray} (Remaining Hits: {Red}{Remaining}{Gray})"
        }
    },
    {
        String = "enemy_hq_wasHit",
        Languages = {
            English = "{Red}{Name}{Gray} Has Successfully Hit the Enemy HQ! {Reward}"
        }
    },
    {
        String = "our_hq_wasDestroyed",
        Languages = {
            English = "{Red}{Name}{Gray} Has DESTROYED Our HQ"
        }
    },
    {
        String = "enemy_hq_wasDestroyed",
        Languages = {
            English = "{Red}{Name}{Gray} Has DESTROYED the Enemy HQ"
        }
    },
    {
        String = "items",
        Languages = {
            English = "Items"
        }
    },
    {
        String = "item_given_to",
        Languages = {
            English = "Gave x{Count} {Item} to {Name}"
        }
    },
    {
        String = "item_Received",
        Languages = {
            English = "Received x{Count} {Item} From {Name}"
        }
    },
    {
        String = "all_players",
        Languages = {
            English = "All Players"
        }
    },
})


-- ===================================================================================

Server.LocalizationManager:Add({
    {
        String = "v_yielded",
        Languages = {
            English = "VEHICLE:YIELDED"
        }
    },
    {
        String = "v_unlocked_u",
        Languages = {
            English = "VEHICLE:UNLOCKED"
        }
    },
    {
        String = "v_locked_u",
        Languages = {
            English = "VEHICLE:LOCKED"
        }
    },
    {
        String = "vehicle_isNot_locked",
        Languages = {
            English = "Vehicle is not Locked"
        }
    },
    {
        String = "vehicle_yield_tip",
        Languages = {
            English = "Yield Access to this Vehicle using !Yield"
        }
    },
    {
        String = "here_is_your_taxi",
        Languages = {
            English = "Farquaad's TAXI:SERViCE - Enjoy your Ride"
        }
    },
    {
        String = "vehicle_hasNoOwner",
        Languages = {
            English = "Vehicle has No Owner"
        }
    },
    {
        String = "vehicle_ownerNotEntered",
        Languages = {
            English = "The Owner has not Unlocked this Vehicle yet!"
        }
    },
    {
        String = "cannot_enter_vehicle",
        Languages = {
            English = "Cannot enter Vehicle{Reason}"
        }
    },
    {
        String = "cannot_enter_driverSeat",
        Languages = {
            English = "Cannot enter Driver Seat{Reason}"
        }
    },
    {
        String = "not_your_vehicle",
        Languages = {
            English = "Not your Vehicle"
        }
    },
    {
        String = "bouncy_vehicles",
        Languages = {
            English = "BOUNCY:VEHICLES"
        }
    },
    {
        String = "developerMode",
        Languages = {
            English = "Developer Mode"
        }
    },
    {
        String = "tox_pass",
        Languages = {
            English = "Toxicity Pass"
        }
    },
})


-- ===================================================================================

Server.LocalizationManager:Add({
    {
        String = "cmd_toxPass_desc",
        Languages = {
            English = "Enables the Toxicity Pass (Allows the usage of Swear Words) On yourself or a selected Player."
        }
    },
})


-- ===================================================================================

Server.LocalizationManager:Add({
    {
        String = "clientMod_synched",
        Languages = {
            English = "Synched {Red}{Items}{Gray} Items on the Client"
        }
    },
    {
        String = "clientMod_disabled",
        Languages = {
            English = "Client-Mod is Disabled"
        }
    },
    {
        String = "clientMod_installingOn",
        Languages = {
            English = "Installing Client Mod on {Client}.."
        }
    },
    {
        String = "clientMod_installedOn",
        Languages = {
            English = "Successfully Installed Client Mod on {Client} (Took {Red}{Time}{Gray})"
        }
    },
})


-- ===================================================================================

Server.LocalizationManager:Add({
    {
        String = "no_map_start_stopped",
        Languages = {
            English = "There is no Map Change Queued"
        }
    },
    {
        String = "map_start_stopped",
        Languages = {
            English = "Map Change has been {Red}Stopped"
        }
    },
    {
        String = "map_not_found",
        Languages = {
            English = "Map {Map} not Found"
        }
    },
    {
        String = "maps",
        Languages = {
            English = "Maps"
        }
    },
    {
        String = "map_start_queued",
        Languages = {
            English = "Starting {Next}Map {Red}{Map}{Gray} ({Red}{Mode}{Gray}) In {Red}{Time}{Gray}"
        }
    },
})


-- ===================================================================================

Server.LocalizationManager:Add({
    {
        String = "command_commands",
        Languages = {
            English = "Lists all Available Console Commands to your Console"
        }
    },
})


-- ===================================================================================

Server.LocalizationManager:Add({
    {
        String = "arg_cvar_desc",
        Languages = {
            English = "The target CVar for the command"
        }
    },
    {
        String = "arg_filter_desc",
        Languages = {
            English = "The desired filter to apply to the results or action"
        }
    },
    {
        String = "arg_team_desc",
        Languages = {
            English = "The name or id of the team you wish to switch the target entity to"
        }
    },
    {
        String = "arg_channel_desc",
        Languages = {
            English = "The target Channel ID"
        }
    },
    {
        String = "arg_goto_option_desc",
        Languages = {
            English = "Directly teleport into the targets vehicle"
        }
    },
    {
        String = "arg_bring_option_desc",
        Languages = {
            English = "Bring the target Player(s) directly into your Vehicle"
        }
    },
    {
        String = "arg_revive_option_desc",
        Languages = {
            English = "Option to Revive the target at their death, or the default location"
        }
    },
    {
        String = "arg_reason_desc",
        Languages = {
            English = "The reason for your Action"
        }
    },
    {
        String = "arg_amount_desc",
        Languages = {
            English = "The amount you wish to apply" -- ???
        }
    },
    {
        String = "arg_item_class",
        Languages = {
            English = "The Item class to Spawn or Equip on the target entity" -- ???
        }
    },
    {
        String = "arg_rename_desc",
        Languages = {
            English = "The new name your wish to be renamed to"
        }
    },
    {
        String = "arg_name_desc",
        Languages = {
            English = "The new Name to apply to the target"
        }
    },
    {
        String = "arg_renameT_desc",
        Languages = {
            English = "The new name your wish to be renamed the target to"
        }
    },
    {
        String = "arg_target_desc",
        Languages = {
            English = "The target player for your devious action"
        }
    },
    {
        String = "arg_profileId",
        Languages = {
            English = "ProfileID"
        }
    },
    {
        String = "arg_hash",
        Languages = {
            English = "Hash"
        }
    },
    {
        String = "arg_name",
        Languages = {
            English = "Name"
        }
    },
    {
        String = "arg_number",
        Languages = {
            English = "Number"
        }
    },
    {
        String = "arg_unknown",
        Languages = {
            English = "Unknown"
        }
    },
    {
        String = "arg_time",
        Languages = {
            English = "Time"
        }
    },
    {
        String = "arg_time_desc",
        Languages = {
            English = "The Time in Seconds (or Value Format e.g 1d50m) for the Action"
        }
    },
    {
        String = "arg_map_desc",
        Languages = {
            English = "The Map you wish to Start"
        }
    },
    {
        String = "arg_stop",
        Languages = {
            English = "Stop"
        }
    },
    {
        String = "arg_stop_desc",
        Languages = {
            English = "Stops the Current Action"
        }
    },
    {
        String = "arg_boolean",
        Languages = {
            English = "Boolean"
        }
    },
    {
        String = "arg_cvar",
        Languages = {
            English = "CVar"
        }
    },
    {
        String = "arg_string",
        Languages = {
            English = "String"
        }
    },
    {
        String = "arg_message",
        Languages = {
            English = "Message"
        }
    },
    {
        String = "arg_access",
        Languages = {
            English = "Access"
        }
    },
    {
        String = "arg_access_desc",
        Languages = {
            English = "The specific Access Class to Apply"
        }
    },
    {
        String = "arg_consoleHelpLine1",
        Languages = {
            English = "{Red}<>{Gray} Arguments are Required, {Blue}<>{Gray} are Optional."
        }
    },
})

