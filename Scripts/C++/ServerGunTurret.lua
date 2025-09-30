-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- A dummy file to demonstrate the functions provided by the ServerGunTurret
-- C++ Implementation
-- ===================================================================================

--- @class Turret The Gun Turret Entity
--- @class ServerGunTurret
ServerGunTurret = {}

--- Sets the turret's target entity and smoothly aims at it.
--- @param hEntity Turret entity
--- @param targetId EntityId entity handle
--- @param aimTime Time (seconds) to aim
ServerGunTurret.SetTarget = function(hEntity, targetId, aimTime) end

--- Sets the turret's aim toward a target entity without setting it as "locked".
--- @param hEntity Turret entity
--- @param targetId EntityId entity handle
--- @param aimTime Time (seconds) to aim
ServerGunTurret.SetAimTarget = function(hEntity, targetId, aimTime) end

--- Sets the turret's aim toward a specific world position.
--- @param hEntity Turret entity
--- @param pos Vec3 target position
--- @param aimTime Time (seconds) to aim
ServerGunTurret.SetAimPosition = function(hEntity, pos, aimTime) end

--- Starts turret firing.
--- @param hEntity Turret entity
--- @param secondary boolean Fire secondary weapon if true, otherwise primary
--- @param fireTime Time (seconds) to keep firing
ServerGunTurret.StartFire = function(hEntity, secondary, fireTime) end

--- Stops turret firing for the specified weapon.
--- @param hEntity Turret entity
--- @param secondary boolean Stop secondary weapon if true, otherwise primary
ServerGunTurret.StopFire = function(hEntity, secondary) end

--- Stops all turret firing, both primary and secondary.
--- @param hEntity Turret entity
ServerGunTurret.StopFireAll = function(hEntity) end

--- Forces the turret to look at a specific orientation.
--- @param hEntity Turret entity
--- @param yaw Yaw angle (horizontal)
--- @param pitch Pitch angle (vertical)
ServerGunTurret.SetLookAt = function(hEntity, yaw, pitch) end

--- Resets turret look direction to its default.
--- @param hEntity Turret entity
ServerGunTurret.ResetLookAt = function(hEntity) end

--- Resets turret properties to their defaults.
--- @param hEntity Turret entity
ServerGunTurret.ResetProperties = function(hEntity) end

--- Called when the turret successfully locks onto a target.
--- @param hEntity Turret entity
ServerGunTurret.OnTargetLocked = function(hEntity) end
