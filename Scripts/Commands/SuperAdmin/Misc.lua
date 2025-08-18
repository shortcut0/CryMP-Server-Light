-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
--                          This file Contains Chat-Commands
-- ===================================================================================

Server.ChatCommands:Add({

    -- ================================================================
    -- !BouncyVehicle <Player>
    {
        Name = "BouncyVehicle",
        Access = ServerAccess_SuperAdmin,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Type = CommandArg_TypePlayer, NotSelf = true },
        },
        Properties = {
        },
        Function = function(self, hTarget)

            local sStatus = "@enabled"
            if (hTarget) then
                sStatus = "@enabled_on"
                if (hTarget.TempData.BouncyVehicles) then
                    hTarget.TempData.BouncyVehicles = false
                    sStatus = "@disabled_on"
                else
                    hTarget.TempData.BouncyVehicles = true
                end
                return CmdResp_RawMessage, self:LocalizeText("@bouncy_vehicles " .. sStatus, {{}, { Name = (self == hTarget and "@yourself" or hTarget:GetName()) }})
            end

            if (not Server.Sandbox:ToggleState(SandboxState_BouncyVehicles)) then
                sStatus = "@disabled"
            end
            return CmdResp_RawMessage, self:LocalizeText("@bouncy_vehicles " .. sStatus)
        end
    },

    --[[
    -- ================================================================
    -- !Stalker <Player>
    {
        Name = "Stalker",
        Access = ServerAccess_SuperAdmin,
        Arguments = {
            { Name = "@target", Desc = "@arg_target_desc", Required = true, Type = CommandArg_TypePlayer, Default = "self", AcceptSelf = true },
        },
        Properties = {
        },
        Function = function(self, hTarget)

            local hStalker = Server.Utils:GetEntity(hTarget.TempData.StalkerId)
            if (hStalker) then
                if (hStalker.Whip) then
                    System.RemoveEntity(hStalker.Whip.id)
                end
                System.RemoveEntity(hStalker.id)
                return true, "@stalker_removed"
            end

            local vPosBehind = self:CalcPos(-10, true)
            local vLookDir = self:SmartGetDir(1)
            Script.SetTimer(1, function()
                local hStalker = Server.Utils:SpawnEntity({
                    class = "Player",
                    position = Vector.ModifyZ(vPosBehind, 3),
                    orientation = vLookDir,
                    name = ("%s's Stalker %d"):format(hTarget:GetName(), Server.Utils:UpdateCounter())
                })
                Script.SetTimer(10, function()
                    local hStalkersWhip = Server.Utils:SpawnEntity({
                        class = "Civ_car1",
                        position = vPosBehind,
                        orientation = vLookDir,
                        name = ("Stalkers_Whip_%d"):format(Server.Utils:UpdateCounter())
                    })
                    hStalker.Whip = hStalkersWhip
                    Script.SetTimer(10, function()
                        hStalkersWhip.vehicle:EnterVehicle(hStalker.id, 1, false)
                    end)
                    Server.Sandbox:Command_CreateStalker(hStalker, hTarget)
                end)
                hTarget.TempData.StalkerId = hStalker.id
            end)
            return CmdResp_RawMessage, self:LocalizeText("@stalker_spawnedOn", { Nam = (hTarget == self and "@yourself" or hTarget:GetName()) })
        end
    },]]
})

--Command_UniqueListUsers