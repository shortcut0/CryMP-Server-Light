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
            English = "Invalid CVar {CVar}"
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
                Extended = "{Red}{Name}{Gray} Disconnected from Channel {Red}{Channel}{Red} ({Red}{Time}{Gray}, {Red}{ShortReason}{Gray})",
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
        String = "ago",
        Languages = {
            English = "Ago"
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

