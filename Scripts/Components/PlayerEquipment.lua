-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This File contains the Server Player Spawn Equipment Component
-- ===================================================================================

Server:CreateComponent({
    Name = "PlayerEquipment",
    FriendlyName = "Equip",
    Body = {

        Properties = {
            SpawnEquipment = {
                PowerStruggle = {
                    Active = true,
                    Regular = {
                        { "SMG", { "Reflex" }}
                    },
                    Premium = {
                        { "FY71", { "LAMRifle", "Reflex" }},
                    },
                    AdditionalEquip = {
                        'Binoculars'
                    },
                    MustHave = {
                    }
                },
                InstantAction = {
                    Active = true,
                    Regular = {
                        { "FY71", { "LAMRifle", "Reflex" }}
                    },
                    Premium = {
                        { "SMG",  { "LAMRifle", "Silencer", "Reflex" }},
                        { "FY71", { "LAMRifle", "Silencer", "Reflex" }}
                    },
                    AdditionalEquip = {
                        'Binoculars'
                    },
                    MustHave = {
                    }
                },
            }
        },

        Initialize = function(self)
            self.Properties.SpawnEquipment = Server.Config:Get("GameConfig.SpawnEquipment", {}, ConfigType_Array)
        end,

        PostInitialize = function(self)
        end,

        EquipPlayer = function(self, hPlayer, aForcedEquipment, bForced)

            if (aForcedEquipment) then
                self:Equip(hPlayer, aForcedEquipment, bForced)
                return true
            end

            local aEquipment = (self.Properties.SpawnEquipment[g_gameRules.class])
            if (table.empty(aEquipment) or aEquipment.Active == false) then
                return false
            end

            local aRegular = aEquipment.Regular
            local aPremium = aEquipment.Premium
            local aAdmin   = aEquipment.Admin


            if (g_gameRules.IS_PS) then
                local iPlayerRank = 69--g_gameRules:GetPlayerRank(hPlayer.id)
                local sTeamName = "US"
                if (hPlayer:GetTeam() == GameTeam_NK) then
                    sTeamName = "NK"
                end

                if (aRegular) then
                    if (aRegular.US and sTeamName == "US" and (aRegular.US.RankRequired == nil or iPlayerRank >= aRegular.US.RankRequired)) then
                        aRegular = aRegular.US.Equip
                    elseif (aRegular.NK and sTeamName == "NK" and (aRegular.NK.RankRequired == nil or iPlayerRank >= aRegular.NK.RankRequired)) then
                        aRegular = aRegular.NK.Equip
                    else
                        aRegular = aRegular.Default
                    end
                end

                if (aPremium) then
                    if (aPremium.US and sTeamName == "US" and (aPremium.US.RankRequired == nil or iPlayerRank >= aPremium.US.RankRequired)) then
                        aPremium = aPremium.US.Equip
                    elseif (aPremium.NK and sTeamName == "NK" and (aPremium.NK.RankRequired == nil or iPlayerRank >= aPremium.NK.RankRequired)) then
                        aPremium = aPremium.NK.Equip
                    else
                        aPremium = aPremium.Default
                    end
                end

                if (aAdmin) then
                    if (aAdmin.US and sTeamName == "US" and (aAdmin.US.RankRequired == nil or iPlayerRank >= aAdmin.US.RankRequired)) then
                        aAdmin = aAdmin.US.Equip
                    elseif (aAdmin.NK and sTeamName == "NK" and (aAdmin.NK.RankRequired == nil or iPlayerRank >= aAdmin.NK.RankRequired)) then
                        aAdmin = aAdmin.NK.Equip
                    else
                        aAdmin = aAdmin.Default
                    end
                end
            end

            local aRequired   = aEquipment.MustHave
            local aAdditional = aEquipment.AdditionalEquip
            for _, sClass in pairs(table.append(
                    (aRequired or {}),
                    (aAdditional or {})
            )) do
                hPlayer:GiveItem(sClass)
            end

            -- Mains
            if (hPlayer:IsAdministrator() and aAdmin ~= nil) then
                self:Equip(hPlayer, aAdmin, bForced)

            elseif (hPlayer:IsPremium() and aPremium ~= nil) then
                self:Equip(hPlayer, aPremium, bForced)

            elseif (aRegular) then
                self:Equip(hPlayer, aRegular, bForced)
            end

            return true
        end,

        Equip = function(self, hPlayer, aList)

            local hWeapon, aStored
            for _, aInfo in pairs(aList) do
                hWeapon = Server.Utils:GetEntity(hPlayer:GiveItem(aInfo[1]))
                if (hWeapon) then
                    for _, sAttach in pairs((aInfo[2] or {})) do
                        hPlayer:GiveItem(IsArray(sAttach) and sAttach.class or sAttach) -- give the player the spawn attachment regardless of stored data...
                    end

                    aStored =  (hPlayer.Data[PlayerData_Equipment] or {})[hWeapon.class]
                    if (aStored) then
                        self:AttachOnWeapon(hPlayer, hWeapon, aStored)
                    else
                        self:AttachOnWeapon(hPlayer, hWeapon, aInfo[2])
                    end

                    local iAmmoLimit = aInfo.AmmoCount
                    if (iAmmoLimit) then
                        hPlayer.actor:SetInventoryAmmo(hWeapon.weapon:GetAmmoType() or "", iAmmoLimit)
                    end
                end
            end

            return true
        end,

        AttachOnWeapon = function(self, hPlayer, hWeapon, aList, tInfo)

            tInfo = (tInfo or {})

            local bOk = true
            local sClass
            for _, hClass in pairs(aList) do
                if (IsArray(hClass)) then
                    sClass = hClass.class
                else
                    sClass = hClass
                end
                if (hWeapon.weapon:SupportsAccessory(sClass)) then

                    bOk = true
                    if (not hPlayer:HasItem(sClass)) then
                        if ((tInfo.NeedsAttachment or tInfo.IsPickup)) then
                            bOk = false
                        else
                            hPlayer:GiveItem(sClass, true)
                        end
                    end

                    if (bOk) then
                        if (tInfo.IsPickup) then
                            hWeapon.weapon:SvChangeAccessory(sClass)
                        else
                            hWeapon.weapon:AttachAccessory(sClass, true, true)
                        end
                    end
                end
            end
        end,

        RefillAmmo = function(self, hPlayer, hWeaponID)

            local hWeapon = (Server.Utils:GetEntity(hWeaponID) or hPlayer.inventory:GetCurrentItem())
            if (hWeapon and hWeapon.weapon) then

                local ammoType = hWeapon.weapon:GetAmmoType()
                if (ammoType) then

                    local iCapacity = hPlayer.inventory:GetAmmoCapacity(ammoType)
                    if (iCapacity) then

                        local iRefilled 		= (iCapacity - hPlayer.inventory:GetAmmoCount(ammoType))
                        local iItemRefilled 	= (hWeapon.weapon:GetClipSize()+1 - hWeapon.weapon:GetAmmoCount())

                        hWeapon.weapon:SetAmmoCount(nil, hWeapon.weapon:GetClipSize()+1)
                        hPlayer.actor:SetInventoryAmmo(ammoType, iCapacity)
                        hPlayer.inventory:SetAmmoCount(ammoType, iCapacity)

                        return iRefilled, iItemRefilled
                    end
                end
            end
            return
        end,

        OnWeaponFired = function(self, hShooter, hWeapon, hAmmo, sAmmo, vPos, vHit, vDir)

            if (hShooter and hShooter.IsPlayer) then
                if (hShooter:HitAccuracyExpired()) then
                    hShooter:RefreshHitAccuracy()
                end
                hShooter:UpdateHitAccuracy("Shot")
            end
        end,

        OnWeaponMelee = function(self, hShooterId, hWeaponId)

            local hUtils = Server.Utils
            local hShooter = hUtils:GetEntity(hShooterId)
            local hWeapon = hUtils:GetEntity(hWeaponId)

            if (hShooter and hShooter.IsPlayer) then
                if (hShooter:HitAccuracyExpired()) then
                    hShooter:RefreshHitAccuracy()
                end
                hShooter:UpdateHitAccuracy("Shot")
            end
        end,

        CanBuyItem = function(self, hPlayer, sItem, aDef)
            DebugLog("check buy!")

            return true
        end,

        OnItemBought = function(self, hPlayer, hItem, aDef, iPrice, aFactory)

            if (not hItem) then
                return
            end

            --[[
            local aEquipConfig = (hPlayer.Data[PlayerData_Equipment] or {})[hItem.class]
            if (aEquipConfig) then
                if (self:AttachOnWeapon(hPlayer, hItem, { IsPickup = false })) then
                    if (hPlayer:TimerExpired(ePlayerTimer_EquipmentLoadedMsg, 120, true)) then
                        SendMsg(CHAT_EQUIP, hPlayer, hPlayer:Localize("@l_ui_accessoryloaded", { string.upper(hItem.class) }))
                    end
                end
            end

            local hWeapon = hPlayer:GetCurrentItem()
            if (not hItem.weapon and (hWeapon and hWeapon.weapon)) then
                self:AttachOnWeapon(hPlayer, hWeapon, { hItem.class }, true, false)
            end
            ]]

            --hUser:Execute([[ClientEvent(eEvent_BLE,eBLE_Currency,"]]..hUser:LocalizeNest("@l_ui_investmentShare ( +" .. iShare .. " PP )")..[[")]])
        end
    },
})