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
-- buylists, rocket ammo, sell item, autoaim rpg?
-- push boats
-- third eye
-- menus
-- ccm

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

    SLH_LIST = {}, -- a list of persistent silhouettes

    -- Voices
    PATCHED_VOICES = {},
    INCREASE_VOICE_VOLUMES=1,

    COLORS={
        red     = {0.91, 0.1, 0.1},
        green   = {0, 1, 0},
        blue    = {0.041, 0.6, 0.9},
        grey    = {0.4, 0.4, 0.4},
        orange  = {1, 0.647, 0},
        yellow  = {1,1,0},
        pink    = {1, 0.75, 0.8},
        purple  = {0.5, 0, 0.5},
        cyan    = {0, 1, 1},
        magenta = {1, 0, 1},
        brown   = {0.6, 0.3, 0.1},
        teal    = {0, 0.5, 0.5},
        maroon  = {0.5, 0, 0},
        olive   = {0.5, 0.5, 0},
        lavender= {0.8, 0.6, 0.8},}
}

CryMP_Client.VERSION="0.0"
CryMP_Client.DEBUG=tostring(System.GetCVar("cl_hud"))=="999"

local TS_Spec,TS_Chat="spec","chat"
_S=System
 g_laId=g_localActorId
 g_la=g_localActor
 g_game=g_gameRules.game

IS_PS=g_gameRules.class=="PowerStruggle"
IS_IA=not IS_PS

timerinit=function(t,ms)
    return os.clock()
end
timerexpired=function(t,ms)
    return t==nil or (os.clock()-t>=ms)
end
rndT=function(t)
    return t[math.random(#t)]
end

-- ===================================================================================

CryMP_Client.INSTALL = function(self)

    HUD.BattleLogEvent(eBLE_Information,"Client v" .. self.VERSION .. " Installed Successfully!")
    self:DLog("CryMP: %d, Client: %s",GetVersion()or -1,self.VERSION)
    self:TS(TS_Spec,self.Requests.ClientInstalled)

end

CryMP_Client.GET_INFO = function(self,x,y)
    self:TS(TS_Chat,"/HereIsMyID "..x..CPPAPI.MakeUUID(y or"<null>"))
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

CryMP_Client.GE = function(self,n)
    return System.GetEntityByName(n)
end

CryMP_Client.SLH = function(self,eId,color,time)

    local e=type(eId)=="userdata"and _S.GetEntity(eId)or self:GE(eId)
    if(not e)then
        self:DLog("no entity to SLH(%s)",tostring(eId))
        return
    end
    local r,g,b,a=color[1],color[2],color[3],(color[4]or 1)
    if (time==0)then
        HUD.SetSilhouette(e.id,0,0,0,0,0)
        return
    end

    local expire=time or-1
    HUD.SetSilhouette(e.id,r,g,b,a,expire)
    self.SLH_LIST[e.id]={Color=color,Start=_time,Expire=expire}
end

CryMP_Client.UpdateSLH = function(self)
    for eId,info in pairs(self.SLH_LIST)do
        if(not _S.GetEntity(eId))then
            self.SLH_LIST[eId]=nil
            self:DLog("deleted invalid SLH")
        elseif(info.Expire~=-1 and _time>=info.Expire+info.Start)then
            HUD.SetSilhouette(eId,0,0,0,0,0)
            self.SLH_LIST[eId]=nil
            self:DLog("deleted SLH")
        else
            local color=info.Color
            local r,g,b,a=color[1],color[2],color[3],(color[4]or 1)
            self:DLog("time new:%f",(info.Expire+info.Start)-_time)
            HUD.SetSilhouette(eId,r,g,b,a,(info.Expire+info.Start)-_time)
            self:DLog("refreshed SLH")
        end
    end
end

CryMP_Client.IS_CARRIED = function(self, w)
    return not w.item:GetOwnerId()-- or w.item:GetOwnerId()~=NULL_ENTITY
end

CryMP_Client.VIEW_CHANGED = function(self, in_tp, was_in_tp)
    self:UpdateSLH()
end

CryMP_Client.ITEM_CHANGED = function(self,p,new,old)

    if (p.id==g_laId and IS_PS) then
        --TODO
       -- self:UpdateBLSell()
    end

    p.PREVIOUS_INV=p.PREVIOUS_INV or {}
    -- slh?
    local hOld = old--GetEntity(old)
    local iTeam = g_game:GetTeam(p.id)
    local cg,cr=self.COLORS.green,self.COLORS.red
    if (hOld) then
        local bDropped = false

        bDropped = not self:IS_CARRIED(hOld)
        if (bDropped)then
            p.PREVIOUS_INV[old.id]=nil
        end
        Script.SetTimer(25,function()

            bDropped = not self:IS_CARRIED(hOld)

            if (bDropped) then
                if (g_laId==p.id or (IS_PS and iTeam == g_game:GetTeam(g_laId))) then
                    --DebugLog("GREEN!")
                    self:SLH(hOld.id,cg,5) -- highlight GREEN
                else
                    --DebugLog("RED")
                    self:SLH(hOld.id,cr,5) -- highlight RED
                end
            end
        end)
    end

    local pick
    if (new) then

        if (new.class=="ShiTen") then
            --[[ n.Properties.Mount = {
                 eye_height = -1,
             }
             n.Properties.mount = {
                 eye_height = -1,
             }
             n.Properties.selectable=1
             n.Properties.droppable=1
             n.item:Reset()
             p.actor:DropItem(n.id)
             n.item:OnUsed(p.id)--]]
        end


        --[[
        new.CMI = new.CMI or ({ ["ShiTen"] = {
            NoFP = true,
            --Anim = "idle_01",
            --Model = "Objects/weapons/asian/shi_ten/shi_ten_mounted_fp.chr"
            Anim = "idle_vehicle_01",
            Model = "objects/weapons/asian/shi_ten/shi_ten_vehicle.chr"
        }, ["Golfclub"] = {
            Model = "Objects/library/architecture/aircraftcarrier/props/misc/golfclub.cgf",
            ModelFP = "Objects/library/architecture/aircraftcarrier/props/misc/golfclub.cgf",
            LPos = { x = 0.15, y = 0.4, z = -0.25 },
            LDir = { x = 0,y = 0, z = 0 }
        }})[new.class]
        ]]

        --if still in highlight, stop it, for ourselfs, timer is 2.5s, for othrs its
        if (true or not timerexpired(new.SLH_TIMER, new.SLH_TIME)) then
            self:SLH(new.id,((p.id~=g_laId and (not IS_PS or iTeam~=g_game:GetTeam(g_laId)))) and cr or cg,(new.id==g_laId and 2.5 or 1))
        else
        end

        local a={["AVMine"]="arm_01",}
        pick = (p.PREVIOUS_INV[new.id] == nil or (new.class~="GaussRifle" and timerexpired(p.PREVIOUS_INV[new.id],math.random(45,72))))
      --  if (GetCVar("crymp_weapon_cockingalways") >0 or pick)then
        if ( pick)then
            self:DLog("new!")
            a["DSG1"]="cock_right_01"
            a["GaussRifle"]=rndT({"cock_right_akimbo_01","cock_right_01"})
            a["SMG"]="select_cock_01"
            a["Shotgun"]=rndT({"post_reload_01","post_reload_02"})
             a["SCAR"]="reload"
             a["FY71"]="reload"
            --a["LAW"]="idle_01"
        end
        if (p.id==g_laId)then
            if (new) then
                local an=a[new.class]
                if (an) then new:StartAnimation(0,an,8)
                self:DLog("start COCK anim")
                end
            end
           -- if (old) then
             --   old.FPARM = nil
           -- end
        end
    end

    local tnew={}
    for _,y in pairs(p.inventory:GetInventoryTable()or{}) do
        tnew[y]=not pick and p.PREVIOUS_INV[y] or timerinit()
    end
    p.PREVIOUS_INV = tnew
end

CryMP_Client.PSE = function(self,eId,se)
    local s = bor(bor(SOUND_EVENT, SOUND_VOICE),SOUND_DEFAULT_3D);
    local v = SOUND_SEMANTIC_PLAYER_FOLEY;

    self:DLog("pse:eid="..tostring(eId))
    self:DLog("pse:laid="..tostring(g_laId))
    local p=eId~=nil and System.GetEntity(eId)
    if(type(eId)=="number")then p=self:GP(eId)end
    if(not p)then
        self:DLog("no flags & SOUND_SEMANTIC_SOUNDSPOT on local")
        g_la:PlaySoundEvent(se, g_Vectors.v000, g_Vectors.v010, s, SOUND_SEMANTIC_SOUNDSPOT); --
        return
    end


    -- gracias a fapp
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

    -- FIXME to disco()
    if (not g_la)then
        WAS_INSTALLED=false
        return
    end

    local clock=os.clock()
    if (self.Timers.Second-clock>=1) then
        self.Timers.second=clock+1
        self:OnTimer()
    end

    if (g_la) then
        local stats=g_la.actorStats
        local tp=stats.thirdPerson
        if (self.IS_IN_TP ~= tp) then
            self.IS_IN_TP=tp
            self:VIEW_CHANGED(tp,not tp)
            self:DLog("v changed")
        end
    end
    for _,hp in pairs(g_game:GetPlayers()) do
        local c=hp.inventory:GetCurrentItem()
        if(hp.LAST_ITEM~=c)then
            self:ITEM_CHANGED(hp,c,hp.LAST_ITEM)
            hp.LAST_ITEM=c
        end
    end
end

CryMP_Client.OnTimer = function(self)

    --self:UpdateSLH()
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

if (not System.GetEntityByName("__ClientUpdater__")) then
    local entity = GetVersion()>=20 and System.SpawnEntity({
        class = "Updater",
        position = g_Vectors.up,
        orientation = g_Vectors.up,
        name = "__ClientUpdater__",
        properties = {
            Callback = function()
                CryMP_Client:DLog("HellO?ß")
                CryMP_Client:OnUpdate()
            end,
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
