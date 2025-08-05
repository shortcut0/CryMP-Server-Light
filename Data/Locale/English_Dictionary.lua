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
        String = "initialization_time",
        Languages = {
            English = "Initialization took {Red}{Time}"
        }
    },
    {
        String = "initialization_start",
        Languages = {
            English = "Server is Re-Initializing, Prepare for {Red}Interruptions"
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
            English = "{Red}{Name}{Gray} Executed {White}!{Red}{Command}{Gray} {Reply}"
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
            English = "Failed to Validate Profile {Red}{ProfileId}{Gray} from User {Red}{Name}{Gray}"
        }
    },
    {
        String = "user_validated",
        Languages = {
            English = "Profile {Red}{ProfileId}{Gray} from User {Red}{Name}{Gray} Has been Verified"
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
            English = "Assigning Default Access {AccessColor}{AccessName}{Gray} to Player {Red}{UserName}"
        }
    },
    {
        String = "user_ipIdAssigned",
        Languages = {
            English = "Assigned IP-Profile {Red}{ID}{Gray} to User {Red}{UserName}"
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
})


-- ===================================================================================

Server.LocalizationManager:Add({
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
})

