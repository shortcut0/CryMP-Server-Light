-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- A Server Configuration file
-- ===================================================================================

Server.Config:Create({
    Active = true,
    Name = "Default",
    Body = {

        ------------------------------------------
        --- Console Variables
        Network = {

            -- A list of CVars which will be forced to specified value
            ForcedCVars = {

                -- Timeout before disconnecting a channel
                net_inactivitytimeout = 50,

                -- Aim Assist Disable
                aim_assistAimEnabled = 0,
                aim_assistAutoCoeff = 0,
                aim_assistMaxDistance = 0,
                aim_assistRestrictionTimeout = 2000,
                aim_assistSearchBox = 0,
                aim_assistSingleCoeff = 0,
                aim_assistSnapDistance = 0,
                aim_assistTriggerEnabled = 0,
                aim_assistVerticalScale = 0,
                hit_assistMultiplayerEnabled = 0,
                hit_assistSingleplayerEnabled = 0,

                ca_AttachmentCullingRation = 200,

                -- Bandwidth
                cl_bandwidth = 100000,
                sv_bandwidth = 100000,

                sv_dedicatedMaxRate = 30,
                sv_cheatprotection = 0,

                -- Some performance related CVars
                e_profile_level_loading = 0,
                e_vegetation_sprites = 0,
                e_view_dist_ratio_vegetation = 30,
                fg_abortOnLoadError = -1,
                g_breakage_particles_limit = 150,
                g_enableIdleCheck = 0,
                g_enableloadingscreen = 1,
                g_radialBlur = 0,
                r_ColorGrading = 1,
                r_GlowScreenMultiplier = 0.5,
                sys_flash_warning_level = 0,
                sys_spec_MotionBlur = 4,

                -- other
                hud_onScreenFarSize = 0.5,
                hud_onScreenNearSize = 1.1,
                hud_attachBoughEquipment = 1,
                hud_showBigVehicleReload = 1,

                p_max_object_splashes = 0,
                p_max_velocity = 400,
                p_max_player_velocity = 50,
                p_max_substeps_large_group = 5,
                p_splash_force0 = 15000,
                p_splash_force1 = 150000,
                pl_zeroGAimResponsiveness = 100,
                pl_zeroGBaseSpeed = 4,
                pl_zeroGEnableGBoots = 1,
                pl_zeroGParticleTrail = 1,
                pl_zeroGSpeedModeEnergyConsumption = 0.1,
                v_altitudeLimit = 1000,
                v_vehicle_quality = 4,

                p_net_minsnapdist = 10,

                -- CryMP-Client
                MP_CRYMP          = 0,
                MP_CIRCLEJUMP     = 0.45,
                MP_WALLJUMP       = 1.75,
                MP_FLYMODE        = 0,
                MP_PICKUPOBJECTS  = 1,
                MP_PICKUPVEHICLES = 0,
                MP_WEAPONSONBACK  = 1,
                MP_THRIDPERSON    = 1,
                MP_AALOCKON       = 1,

                MP_UNRESTRICTEDRAGDOOLS   = 1,
                mp_animationGrenadeSwitch = 1,
                mp_C4StrengthThrowMult = 3.0,

                -- Server Only CVars
                SERVER_USE_HIT_QUEUE = 0,

            }, ---< ForcedCVars

            -- There is a few servers who clearly do this
            -- This is just an option for the sake of adding it, using it is something else!
            PingMultiplier = 1.0,

            -- The threshold to start logging ping warnings
            AveragePingWarningThreshold = 200,

            -- Warning Thresholds for net Usage
            NetworkUsageWarningThresholds = {
                Up = 20000,
                Down = 10000,
            },

            --- Ping Control Config
            PingControl = {

                Enabled = true,

                -- The maximum tolerated ping a player can have
                Tolerance = 300,

                -- After exceeding the tolerated limit, give them this amount of warnings
                WarningLimit = 5,

                -- With this amount of time passing between each warning
                WarningDelay = 10,

                -- Enables resetting of warnings upon players ping recovering to tolerated levels
                ResetWarnings = false

            }, ---< PingControl

            --- Connection Filter (not racially motivated)
            ConnectionFilter = {

                Enabled = true,
                Blacklist = {

                    --- You must escape all entries in here for the filters to work!
                    IPAddresses = {
                        --"127%.0%.0%.1"
                    },

                    Countries = {
                        --"Nigeria"
                    },

                    Providers = {
                        --"Starlink"
                    }

                }, ---< Blacklist

            }, ---< ConnectionFilter

        }, ---< Network

        ------------------------------------------
        --- General Server Configuration
        Server = {

            -- The Name of Server
            ServerName = "CryMP ~ {MapName} ~",
            ServerName = "Lord Farquaad's Dungeon",

            -- The Description which will appear on the Website
            ServerDescription = "When you get older, plainer, saner\nWill you remember all the danger we came from?\nBurnin' like embers, falling tender\nLonging for the days of no surrender, years ago\nAnd will you know?"

        }, ---< Server

        ------------------------------------------
        --- Game Configuration
        GameConfig = {

            --- Gun Turret Configuration
            Buying = {

                -- The maximum amount of kits a player can buy
                KitLimit = 2,

                -- Rewards scale when selling items
                SellItemPriceScale = 0.75,

                -- When someone captures a buildings, they will be marked as the "shareholders" of that building
                -- Now, when someone buys something inside one of those buildings, the shareholders will receive a .. share
                -- A Value of 0 will disable this feature
                AwardItemInvestPrestige = 0.25,
                AwardVehicleInvestPrestige = 0.15,

            }, ---< Buying

            --- Gun Turret Configuration
            TurretConfig = {

                -- Damage Scale for RPGs
                RPGDamageScale = 1,

                -- Will enable turrets shooting at players who are attacking them (within reason, of course)
                TargetPlayersOnAttack = true,

                -- Repair upon repairing a turret
                RepairReward = 100,

            }, ---< TurretConfig

            --- Prestige Configuration
            Prestige = {

                -- Multiplier for VIP Members!
                PremiumSpawnPrestigeMultiplier = 1.25,

                -- Will award prestige even to team members
                AwardDisarmPrestigeAlways = true,

                -- Reward for stealing a vehicle
                VehicleTheftReward = 50,

                -- Reward for repairing a vehicle
                VehicleRepairAward = 15,

            }, ---< Prestige

            -- Will skip the annoying Pre-Game!
            SkipPreGames = true,

            -- After this amount of time of being dead, players will be put into spectator mode
            AutoSpectateTimer = 30,

            -- Configuration for Kills
            KillConfig = {

                --- Will Split the kill reward among all players who assisted in the kill (the actual killer will receive the full reward)
                KillAssistance = {

                    Enabled = true,

                    -- The Distribution type
                    -- Type 1 means the rewards are divided by percent the damage contributed to the kill
                    -- Type 2 means the rewards are divided by the percentage of hits landed that ultimately lead to the kill
                    Type = 1,

                    -- The Assist threshold to receive a reward (0>100 in percentage)
                    Threshold = 15,

                    -- The time after which a players contribution expires
                    Timeout = 13,

                }, ---< KillAssistance

                -- if players should drop all their equipment upon death
                DropAllEquipment = true,

                -- Deduct rewards for killing bots
                DeductBotKills = false,

                -- Deduct Kills for killing teammates
                DeductTeamKills = 1,

                -- Deduct kills for suiciding
                DeductSuicideKills = 0,

                -- Add Deaths for suiciding (1 + this)
                SuicideAddDeaths = 0,

                -- Will enable new Kill Messages
                EnableNewKillMessages = true,

                -- The Rewards scale for VIP members
                PremiumRewardsScale = 1.25,

                --- Sniping Configuration
                SnipingRewards = {

                    -- Status of this feature
                    Enabled = true,

                    -- The Minimum Distance for a kill to be considered special
                    MinimumDistance = 100,

                    RewardPP = 500,

                    -- Reward scale for headshots
                    HeadshotAmplification = 1.5,

                }, ---< SnipingRewards

                --- First Blood
                FirstBlood = {

                    -- Sets the status of the first blood
                    Enabled = true,

                    Reward = {

                        -- Will reward the entire team!
                        RewardTeam = true,

                        -- Reward Amplifications for repeated first blood scores!
                        Amplifications = {
                            [ 3] = 1.25,
                            [ 5] = 1.50,
                            [ 8] = 1.75,
                            [10] = 2.00,
                            [15] = 2.50,
                            [20] = 3.00,
                            [99] = 10.0, -- !!!
                        },

                        -- The amount of prestige points
                        PP = 500,

                        -- The amount of experience points
                        CP = 35,
                    }

                }, ---< FirstBlood

                --- Kill Streaks
                KillStreaks = {

                    --- formats are:
                    --- {ShooterName} = name of the shooter
                    --- {TargetName} = name of the target
                    --- {Kills} = the amount of kills the shooter has

                    --- the message list for KILL streaks
                    KillMessages = {
                        [03] = "{ShooterName} IS on a KILLING SPREE ( #{Kills} Kills )",
                        [05] = "{ShooterName} IS on a RAMPAGE ( #{Kills} Kills )",
                        [08] = "{ShooterName} IS DOMINATING : ( #{Kills} Kills )",
                        [12] = "{ShooterName} IS AMAZING : ( #{Kills} Kills )",
                        [15] = "{ShooterName} IS UNSTOPPABLE : ( #{Kills} Kills )",
                        [19] = "{ShooterName} IS INSANE : ( #{Kills} Kills )",
                        [23] = "{ShooterName} IS OVERPOWERED : ( #{Kills} Kills )",
                        [28] = "{ShooterName} IS GODLIKE : ( #{Kills} Kills )",
                        [35] = "{ShooterName} IS MORE THAN GODLIKE : ( #{Kills} Kills )",
                        [40] = "{ShooterName} IS AMD USER : ( #{Kills} Kills )",
                        [50] = "{ShooterName} IS AMD ENTHUSIAST : ( #{Kills} Kills )",
                        [60] = "{ShooterName} IS AMD KING : ( #{Kills} Kills )",
                        [80] = "{ShooterName} IS AMD GOD : ( #{Kills} Kills )",
                        [90] = "{ShooterName} IS AMD SUPREME RULER : ( #{Kills} Kills )",
                        [100] = "{ShooterName} is LISA SU : ( #{Kills} Kills )"
                    }, ---< KillMessages

                    --- the message list for DEATH streaks
                    DeathMessages = {
                        [05] = "{TargetName} is on a DEATH STREAK : ( #{Kills} Deaths )",
                        [10] = "{TargetName} is SUICIDAL MASTER : ( #{Kills} Deaths )",
                        [15] = "{TargetName} is INTEL USER : ( #{Kills} Deaths )",
                        [20] = "{TargetName} is ASHAMED of their INTEL : ( #{Kills} Deaths )",
                        [25] = "{TargetName} is INTEL ENTHUSIAST : ( #{Kills} Deaths )",
                        [30] = "{TargetName} is MASTER of SUICIDE : ( #{Kills} Deaths )",
                        [35] = "{TargetName} is GOD of SUICIDE : ( #{Kills} Deaths )",
                        [50] = "{TargetName} is Patrick P. Gelsinger : ( #{Kills} Deaths )",
                    }, ---< DeathMessages

                    --- the message list for REPEATING kills
                    RepeatMessages = {
                        [04] = "{ShooterName} is SLAYING {TargetName} (  #{Kills} Kills )",
                        [08] = "{ShooterName} is DESTROYING {TargetName} (  #{Kills} Kills )",
                        [12] = "{ShooterName} is DOMINATING {TargetName} (  #{Kills} Kills )",
                        [14] = "{ShooterName} is ERADICATING {TargetName} (  #{Kills} Kills )",
                        [18] = "{ShooterName} is SHOWING {TargetName} the AMD WAY (  #{Kills} Kills )",
                        [22] = "{ShooterName} is FLEXING their AMD on {TargetName} (  #{Kills} Kills )",
                        [26] = "{ShooterName} is TEACHING the WAY OF AMD to {TargetName} (  #{Kills} Kills )",
                    }, ---< DeathMessages


                }, ---< KillStreaks

            }, ---< KillConfig

            -- The Spawn Equipment Config
            SpawnEquipment = {
                PowerStruggle = {

                    -- Status of this config entry
                    Active = true,

                    -- The equipment for regular players
                    Regular = {
                        -- For NK Team Members
                        NK = {
                            -- Only available to members of this rank, else Default will be equipped
                            RankRequired = GameRank_SGT,
                            Equip = {
                                { "FY71", { "Reflex" } }
                            }
                        },
                        -- For AMERICUUH Team Members
                        US = {
                            -- Only available to members of this rank, else Default will be equipped
                            RankRequired = GameRank_SGT,
                            Equip = {
                                { "SCAR", {} }
                            }
                        },

                        Default = {
                            { "SMG", { "Relfex" }}
                        }
                    },

                    -- The equipment for VIP members
                    Premium = {
                        -- For NK Team Members
                        NK = {
                            -- Only available to members of this rank, else Default will be equipped
                            RankRequired = GameRank_CPL,
                            Equip = {
                                { "FY71", { "LAMRifle", "Reflex" } }
                            }
                        },
                        -- For AMERICUUH Team Members
                        US = {
                            -- Only available to members of this rank, else Default will be equipped
                            RankRequired = GameRank_CPL,
                            Equip = {
                                { "SCAR", { "Reflex", } }
                            }
                        },

                        Default = {
                            { "FY71", { "Relfex" }}
                        }
                    },
                    AdditionalEquip = {
                        'Binoculars'
                    },

                    -- Everyone spawns with these
                    MustHave = {
                    }
                },
                InstantAction = {

                    -- Status of this config entry
                    Active = true,

                    -- The equipment for regular players
                    Regular = {
                        { "FY71", { "LAMRifle", "Reflex" } }
                    },

                    -- The equipment for VIP members
                    Premium = {
                        { "SMG",  { "LAMRifle", "Silencer", "Reflex" }},
                        { "FY71", { "LAMRifle", "Silencer", "Reflex" }}
                    },
                    AdditionalEquip = {
                        'Binoculars'
                    },

                    -- Everyone spawns with these
                    MustHave = {
                    }
                },
            }, ---< SpawnEquipment

        }, ---< GameConfig

        ------------------------------------------
        --- Map Configuration
        MapConfig = {

            -- If the server should delete all client-only entities
            -- Disabled for now. I suspect this can cause aspect errors during map change.
            DeleteClientEntities = false,

            -- A list of forbidden maps
            ForbiddenMaps = {
                PowerStruggle = {
                    "Shore"
                },
                InstantAction = {
                    DisableAll = true, -- This will disable all instant action maps at once
                },
            },

            -- The Map rotation the server will cycle through
            MapRotation = {

                -- The Default time limits for unspecific or unknown types
                DefaultTimeLimits = {

                    -- All others
                    Other = ONE_HOUR,

                    -- PS & IA
                    PowerStruggle = ONE_HOUR,
                    InstantAction = ONE_MINUTE * 30,
                }, ---< DefaultTimeLimits

                -- The Rotation will ignore all maps that do not have a download-link available
                IgnoreNonDownloadable = true,

                -- The Rotation will cycle through all available maps
                UseAvailableMaps = false,

                -- The Rotation will be shuffled each cycle
                ShuffleRotation = false,

                -- The list of Maps
                MapList = {
                    { Path = "Multiplayer/PS/Mesa",     TimeLimit = "5m", Enabled = true },
                    { Path = "Multiplayer/PS/Shore",    TimeLimit = "5m", Enabled = true },
                    { Path = "Multiplayer/PS/Beach",    TimeLimit = "5m", Enabled = true },
                    { Path = "Multiplayer/PS/Refinery", TimeLimit = "5m", Enabled = true },
                } ---< MapList

            },
        }, ---< MapConfig

        ------------------------------------------
        --- Player Name Configuration
        PlayerNames = {

            -- The Name Template for Nomads or forbidden names
            NameTemplate = "Nomad.{CountryCode} (#{Channel})",

            -- Allow Spaces in Names
            AllowSpaces = true,

            -- Forbidden Names
            ForbiddenNames = {
                "Nomad",
            },

            -- Forbidden Symbols
            ForbiddenSymbols = {
                "$",
                "@",
                "%",
                "[",
                "]",
                '"',
            },

            -- Replacement Character used in sanitization
            ReplacementCharacter = "_",

            -- Maximum length for names
            MinimumLength = 3,

            -- Maximum length for names
            MaximumLength = 18,

        }, ---< PlayerNames

    },
})