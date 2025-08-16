-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
-- This is the Remote Client-Script
-- ===================================================================================

-- show capture speed mult

if (CryMP_Client) then
    WAS_INSTALLED=true
end

CryMP_Client = {
    Timers={
        Second=os.clock()-1
    },
    Requests={
        ClientInstalled=10,
    },

    -- Voices
    PATCHED_VOICES = {},
    INCREASE_VOICE_VOLUMES=1,
}

CryMP_Client.VERSION="0.0"
CryMP_Client.DEBUG=tostring(System.GetCVar("cl_hud"))=="999"

local TS_Spec,TS_Chat="spec","chat"
 g_laId=g_localActorId
 g_la=g_localActor
 g_game=g_gameRules.game

-- ===================================================================================

CryMP_Client.INSTALL = function(self)

    HUD.BattleLogEvent(eBLE_Information,"Client v" .. self.VERSION .. " Installed Successfully!")
    self:DLog("CryMP: %d, Client: %s",GetVersion()or -1,self.VERSION)
    self:TS(TS_Spec,self.Requests.ClientInstalled)
end

CryMP_Client.TS = function(self,t,n)

    if(t==TS_Spec)then
        g_gameRules.server:RequestSpectatorTarget(g_laId,n)
    else
        g_game:SendChatMessage(ChatToTarget,g_laId,g_laId,n)
    end
end

CryMP_Client.GP = function(self,chan)
    return g_game:GetPlayerByChannelId(chan)
end

CryMP_Client.PSE = function(self,eId,se)

    self:DLog("eid="..tostring(eId))
    self:DLog("laid="..tostring(g_laId))
    local p=eId~=nil and System.GetEntity(eId)
    if(type(eId)=="number")then p=self:GP(eId)end
    if(not p)then
        return
    end


    -- gracias a fapp
    local s = bor(bor(SOUND_EVENT, SOUND_VOICE),SOUND_DEFAULT_3D);
    local v = SOUND_SEMANTIC_PLAYER_FOLEY;
    if (self.INCREASE_VOICE_VOLUMES and not self.PATCHED_VOICES[se] and CPPAPI.GetLanguage and CPPAPI.AddLocalizedLabel and se:sub(1, 3) ~= "mp_") then
        local language = CPPAPI.GetLanguage()
        local tbl = {
            languages = {},
            english_text = se,
            sound_volume = 0.8,
            sound_event = "",
            sound_radio_ratio = 0,
            sound_radio_background = 0,
            sound_radio_squelch = 0,
            sound_ducking = 0,
            --keep_existing = true,
            use_subtitle = false,
        }
        tbl.languages[language:lower()] = {
            sound_volume = 0.8,
            sound_radio_ratio = 0.0,
            sound_radio_background = 0,
            sound_radio_squelch = 0,
            sound_event = "",
            --localized_text = "30 seconds until mission termination.",
        }
        local ok = CPPAPI.AddLocalizedLabel(se, tbl);
        if (ok) then self.PATCHED_VOICES[se] = true else end
    end
    local sndFlags = bor(bor(SOUND_EVENT, SOUND_VOICE), SOUND_DEFAULT_3D);
    p.lastPainSound = p:PlaySoundEvent(se, g_Vectors.v000, g_Vectors.v010, sndFlags, SOUND_SEMANTIC_PLAYER_FOLEY);
    p.lastPainTime = _time;
    return p.lastPainSound;
end

-- ===================================================================================

CryMP_Client.OnUpdate = function(self)

    local clock=os.clock()
    if (self.Timers.Second-clock>=1) then
        self.Timers.second=clock+1
        self:OnTimer()
    end
end

CryMP_Client.OnTimer = function(self)
end

CryMP_Client.CheckWork = function(self, work, entityId)
    local t=work:sub(1,4)
    if(t=="lua:")then
        local id=work:sub(5,10)
        local func=work:sub(12)
        if(func)then
            local ok,ret=pcall(loadstring(func))
            local tb = (debug.traceback(tostring(ret) or "NIL",2) or ret or "<traceback failed>")
            if (not ok) then
                self:TS(TS_Chat,("/clError %d %s"):format(id,ret or "nil"))
                Log("$4[Error] \n"..tostring(tb))
            end
        end
        return true
    end
end


-- ===================================================================================

g_gameRules.Client.ClWorkComplete = function(self,entityId,work)
    if (CryMP_Client:CheckWork(work, entityId))then
        return
    end;
    local sound;
    if (work=="repair") then
        sound="sounds/weapons:repairkit:repairkit_successful"
    elseif (work=="lockpick") then
        sound="sounds/weapons:lockpick:lockpick_successful"
    end
    if (sound) then
        local entity=System.GetEntity(entityId);
        if (entity) then
            local sndFlags = SOUND_DEFAULT_3D;
            sndFlags = band(sndFlags, bnot(SOUND_OBSTRUCTION));
            sndFlags = bor(sndFlags, SOUND_LOAD_SYNCHRONOUSLY);

            local pos=entity:GetWorldPos(g_Vectors.temp_v1);
            pos.z=pos.z+1;

            return Sound.Play(sound, pos, sndFlags, SOUND_SEMANTIC_MP_CHAT); --return Sound.Play(s,p,49152,1024);
        end
    end
end


-- ===================================================================================

CryMP_Client.Log = function(this, s, ...)
    System.LogAlways(string.format(s, unpack({...})))
end
CryMP_Client.DLog = function(this, s, ...)
    if(not this.DEBUG)then return end
    System.LogAlways(string.format(s, unpack({...})))
end

function GetVersion()
    local version = CRYMP_CLIENT or 0;
    if (CRYMP_CLIENT_STRING and #CRYMP_CLIENT_STRING > 3) then
        version = version + 1;
        local custom = "dirty";
        if (CRYMP_CLIENT_STRING:sub(#CRYMP_CLIENT_STRING-#custom+1, #CRYMP_CLIENT_STRING) == custom) then
            version = version + 1;
        end
    end
    return version;
end

if (not System.GetEntityByName("ClientUpdater")) then
    local entity = GetVersion()>=20 and System.SpawnEntity({
        class = "Updater",
        position = g_Vectors.up,
        orientation = g_Vectors.up,
        name = "ClientUpdater",
        properties = {
            Callback = CryMP_Client.OnUpdate,
        },
    })
    if (not entity) then
        --older client users(like myself)
        if (AddHook ~= nil and not WAS_INSTALLED) then
            AddHook("OnUpdate", function()
                CryMP_Client:OnUpdate()
            end)
        end
    end
end

-- ===================================================================================
CryMP_Client:INSTALL()
