-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains Patched functions for all game modes
-- ===================================================================================

Server.Patcher:HookClass({

    -- This is the actual patching target
    Parent = "SinglePlayer",

    -- These will then use the same Parent Body to save memory!
    Class = {
        "TeamInstantAction",
        "InstantAction",
        "PowerStruggle",
    },

    -- The Actual body
    Body = {
        {
            ------------------------------
            ---        Template
            ------------------------------
            Name = "Hook_Template",
            Value = "Hook_TemplateValue",
            Value = { "Hook_TemplateValue" },
            Value = function(self) return "Hook_TemplateValue"  end,
        },
        {
            ------------------------------
            ---   Initialize_CryMP
            ------------------------------
            Name = "Initialize_CryMP",
            Value = function(self)

                self.LogClass = "GameRules"

                Server:CreateLogAbstract(self, self.LogClass)
                Server.Events:LinkEvent(ServerEvent_OnPostInit, self, self.PostInitialize)
            end,
        },
        {
            ------------------------------
            ---      PostInitialize
            ------------------------------
            Name = "PostInitialize",
            Value = function(self)

                self.IS_PS    = (self.class == GameMode_PS)
                self.IS_IA    = (self.class == GameMode_IA)
                self.IS_TIA   = (self.class == GameMode_TIA)

                self.SkipPreGame = Server.Config:Get("GameConfig.SkipPreGames", false, ConfigType_Boolean)
                if (self.SkipPreGame and self:GetState() ~= "InGame") then
                    self:GotoState("InGame")
                end

                self:Log("PostInitialize")
            end,
        },
        {
            ------------------------------
            ---        OnSpawn
            ------------------------------
            Name = "OnSpawn",
            Value = function(self)
                Server:OnGameRulesSpawn(self)
                self:Initialize_CryMP()
                self:InitHitMaterials()
                self:InitHitTypes()
            end,
        },
    }
})