-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- Contains Patched functions for 'Flag'
-- ===================================================================================

Server.Patcher:HookClass({
    ReplaceBody = true,
    Class = "Flag",
    Body  = {
        {
            ---------------------------
            --    Properties
            ---------------------------
            Name  = "Properties",
            Value = {
                objModel 			= "objects/library/props/flags/mp_flags.cga",
                teamName			= "",
                animationTemplate	= "flags_%s_%s",
            },
        },
        {
            ---------------------------
            --      LoadGeometry
            ---------------------------
            Name  = "LoadGeometry",
            Value = function(self, slot, model)
                if (#model > 0) then
                    local ext = model:sub(-4):lower()
                    if ((ext == ".chr") or (ext == ".cdf") or (ext == ".cga")) then
                        self:LoadCharacter(slot, model)
                    else
                        self:LoadObject(slot, model)
                    end
                end
            end,
        },
        {
            ---------------------------
            --        OnSpawn
            ---------------------------
            Name  = "OnSpawn",
            Value = function(self)
                CryAction.CreateGameObjectForEntity(self.id)
                CryAction.BindGameObjectToNetwork(self.id)
                self:LoadGeometry(0, self.Properties.objModel)
                self:Physicalize(0, PE_RIGID, { mass = 0 })
            end,
        },
        {
            ---------------------------
            --        OnReset
            ---------------------------
            Name  = "OnReset",
            Value = function(self)
                CryAction.DontSyncPhysics(self.id)
            end,
        },
        {
            ---------------------------
            --        OnInit
            ---------------------------
            Name  = "OnInit",
            Value = function(self)
                self:OnReset()
            end,
        },
        {
            ---------------------------
            --    OnPropertyChange
            ---------------------------
            Name  = "OnPropertyChange",
            Value = function(self)
                self:OnReset()
            end
        },
    },
})