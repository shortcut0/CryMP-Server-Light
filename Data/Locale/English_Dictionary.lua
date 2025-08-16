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
            English = "[ {Name} ] Info sent to Console"
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
            English = "Command{Name}"
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
                Extended = "{Red}{Admin}{Gray} Has Unbanned {Red}{Name}{Gray} ({UnbanReason})"
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
            English = "The new name your wish to be renamed to"
        }
    },
    {
        String = "arg_rename_desc",
        Languages = {
            English = "The new name your wish to be renamed to"
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
        String = "arg_filter",
        Languages = {
            English = "Filter"
        }
    },
    {
        String = "arg_filter_desc",
        Languages = {
            English = "The desired Filter to Apply"
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

