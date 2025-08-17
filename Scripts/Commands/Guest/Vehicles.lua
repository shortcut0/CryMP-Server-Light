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
    -- =================================================================================
    -- !Taxi
    {
        Name        = "Taxi",
        Access      = ServerAccess_Guest,

        Arguments = {
        },

        Properties = {
            InDoors     = false,
            Vehicle     = false, -- only allow inside vehicles
            Alive       = true,
            Spectating  = false,
            Price       = 50,
            CoolDown    = 15,
        },

        Function = function(self)

            local vPos = self:CalcPos(4.25, true)
            local vDir = self:SmartGetDir(true)

            Script.SetTimer(1, function()
                local hOldTaxi = Server.Utils:GetEntity(self.TempData.LastSpawnedTaxiId)
                if (hOldTaxi) then
                    if (not hOldTaxi:IsDestroyed() and hOldTaxi:IsEmpty()) then
                        hOldTaxi.vehicle:StartAbandonTimer(true, 10)
                    end
                end
                local hTaxi = Server.Utils:SpawnEntity({
                    class = "Civ_car1",
                    name = "Uber" .. Server.Utils:UpdateCounter(),
                    position = vPos,
                    orientation = vDir,
                    properties = {
                        Paint = table.Random({"green","red","blue","gray","black"})
                    },
                    SpawnEffect = Effect_LightExplosion
                })
                self.TempData.LastSpawnedTaxiId = hTaxi.id
            end)

            Server.Chat:TextMessage(ChatType_Info, self, self:LocalizeText("@here_is_your_taxi"))
            return true
        end
    },
    -- =================================================================================
    -- !Lock
    {
        Name        = "lock",
        Access      = ServerAccess_Guest,

        Arguments = {
        },

        Properties = {
            This = "Server.VehicleSystem",
            Vehicle = true, -- only allow inside vehicles
        },

        Function = function(self, hPlayer)
            local hVehicle = hPlayer:GetVehicle()
            return self:Command_LockVehicle(hPlayer, hVehicle)
        end
    },
    -- =================================================================================
    -- !Yield
    {
        Name        = "Yield",
        Access      = ServerAccess_Guest,

        Arguments = {
        },

        Properties = {
            This = "Server.VehicleSystem",
            Vehicle = true, -- only allow inside vehicles
        },

        Function = function(self, hPlayer)
            local hVehicle = hPlayer:GetVehicle()
            return self:Command_YieldVehicle(hPlayer, hVehicle)
        end
    },
})