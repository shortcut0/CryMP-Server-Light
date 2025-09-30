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
    -- !Spawn <Class> <Count> <Formation>
    {
        Name = "Spawn",
        Access = ServerAccess_Admin,
        Arguments = {
            { Name = "@class", Desc = "@arg_class_desc", Required = false,  },
            { Name = "@count", Desc = "@arg_count_desc", Required = true, Default = 1, Type = CommandArg_TypeNumber, Maximum = 30, Minimum = 1  },
            { Name = "@option1", Desc = "@arg_formation_desc", Required = true, Default = 1, Type = CommandArg_TypeNumber, Maximum = 3, Minimum = 1  },
        },
        Properties = {
        },
        Function = function(self, sClass, iCount, iFormation, ...)

            local bOk, sEntityClass, sError = Server.Utils:FindClassByName(self, sClass)
            if (not bOk) then
                return false, (sError)
            end

            local aEquip = { ... }

            -- Because of Vehicles
            Script.SetTimer(1, function()
                local iBaseDistance = 4.5
                local bVehicleClass = Server.Utils:IsVehicleClass(sEntityClass)
                local bItemClass = Server.Utils:IsItemClass(sEntityClass)

                if (bVehicleClass) then
                    iBaseDistance = 10
                elseif (bVehicleClass) then
                    iBaseDistance = 1.25
                end
                local vBasePos = self:CalcPos(iBaseDistance, true)
                if (bVehicleClass) then
                    vBasePos = Server.Utils:FollowTerrain(vBasePos, 1.75)
                end
                local vBaseDir = self:GetDirectionVector()
                local hLastEntity
                for i = 1, iCount do
                    local vSpawnPos = table.Copy(vBasePos)
                    local vSpawnDir = table.Copy(vBaseDir)
                    if (iFormation == 1) then
                        -- Nothing
                        if (hLastEntity) then
                            vSpawnPos.z = vSpawnPos.z + (i * 0.25)
                        end
                    end

                    local hEntity = Server.Utils:SpawnEntity({
                        class = sEntityClass,
                        name = ("Spawned %s (%d)"):format(sEntityClass, Server.Utils:UpdateCounter()),
                        position = vSpawnPos,
                        orientation = vSpawnDir,
                        fMass = 100,
                        properties = {
                            bPhysics = 1,
                        }
                    })

                    if (hEntity.actor) then
                        for _, sItem in pairs(aEquip or {}) do
                            local hItemId = ItemSystem.GiveItem(sItem, hEntity.id, true)
                            local hItem = (hItemId and Server.Utils:GetEntity(hItemId))
                            if (hItem) then
                                hItem.weapon:AttachAccessory("LAMRifle", true, true)
                            end
                        end
                    elseif (hEntity.vehicle) then
                        hEntity.vehicle:StartAbandonTimer(true, 120)

                    else--if (hEntity.weapon) then
                        g_gameRules.game:ScheduleEntityRemoval(hEntity.id, 120, true)
                    end

                    hLastEntity = hEntity
                    Server.Utils:AwakeEntity(hEntity.id)
                end
            end)
        end
    },
})