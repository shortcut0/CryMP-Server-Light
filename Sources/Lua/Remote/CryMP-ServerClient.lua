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



--done
--<<<fix modelid material (see atomcl)

if (CryMP_Client) then
    WAS_INSTALLED=true
end

local osclock=os.clock()
CryMP_Client = {
    Timers={
        Second=osclock-1
    },
    Requests={
        ClientInstalled=10,
    },

    HIT_MARKER = nil, -- hit marker info, can be reset, np
    ---HIT_MARKERS = {}, -- hit marker info, can be reset, np
    OBJ_MATERIALS = {}, -- list of objects materials
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
        lavender= {0.8, 0.6, 0.8},},

    _MENUS = (CryMP_Client~=nil and CryMP_Client._MENUS or {}),
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
self:HookGame()
    self:AddMenus()
end


CryMP_Client.AddMenus=function(self)
do return end
    for _, tMenu in pairs(self._MENUS) do
        tMenu:Delete()
    end
    CPPAPI.RemoveTextOrImageAll()
    self._MENUS={}

    local ImgSrc = "..\\CryMP-Server-Light\\Sources\\Lua\\Remote\\PAK\\Images\\Menus\\"
    self:AddMenu("XP_Menu", {

        Items = {
         --   Icon        = { Image = "Testing\\" .. "xp_icon.dds",     PosX = 100, PosY = 100, Width = 24, Height = 21, },
            Icon        = { Text = "( XP )",     PosX = 200, PosY = 150, Width = 24, Height = 21, },
            Progress    = { Box = true, Color = { 177, 198, 164 }, Alpha = (255/213), PosX = 200, PosY = 100, Width = 53, Height = 4, },
            Bar         = { Box = true, Color = { 255, 199, 066 }, Alpha = (255/213), PosX = 200, PosY = 100, Width = 58, Height = 8, },
        },

        Update = function(this, iProgress)
            CryMP_Client:DLog("iProgress=%f",iProgress)
            local hRenderProgress = this:GetRender("Progress")
            if (hRenderProgress:GetDataValue() ~= iProgress) then
                hRenderProgress:SetDataValue(iProgress)
                hRenderProgress:SetRenderData("Width", (hRenderProgress:GetRenderData("WidthO") * iProgress))
                hRenderProgress:Delete()
                hRenderProgress:Render()
            end
        end,
        PreInit = function(this, tRenderItem)
            local hRenderProgress = this:GetRender("Progress")
            hRenderProgress:SetRenderData("Width", hRenderProgress:GetRenderData("Width") * 0.01) -- 1%
        end

        --Progress    = { Image = ImgSrc .. "xp_progress.dds", PosX = 100, PosY = 100, Width = 53, Height = 4, },
        --Bar         = { Image = ImgSrc .. "xp_bar.dds",      PosX = 100, PosY = 100, Width = 58, Height = 8 }
    })
end

CryMP_Client.AddMenu = function(self, sName, tInfo)


    --[[
    x,y,width,height,R,G,B,A
			nCX.LoadedText[CPPAPI.DrawText(380, 400, 1.2, 1.2, 1, 0.2,1,1, "Map  Test ")] = true;

			x,y,width,height,R,G,B,A
			nCX.LoadedText[CPPAPI.DrawColorBox(300, 300, 300, 200, 0, 0, 0,0.5)] = true; --"Shaders/EngineAssets/Textures/White.dds"

			x,y,width,height,src
			nCX.LoadedText[CPPAPI.DrawImage(300, 150, 300, 200,"Levels/Multiplayer/IA/SteelMill/SteelMill_Loading.dds")] = true;
    ]]

    local tMenu = {
        RENDER_ITEMS = {},

        PreInit = tInfo.PreInit,
        Update = tInfo.Update or function(this)
        end,

        Init = function(this)

            if (this.PreInit) then
                this:PreInit()
            end

            this:Render()
        end,

        GetRender = function(this, hId)
            return this.RENDER_ITEMS[hId]
        end,

        Delete = function(this)
            for _, hRender in pairs(this.RENDER_ITEMS) do
                hRender:Delete()
            end
        end,

        Destroy = function(this)
            for _, hRender in pairs(this.RENDER_ITEMS) do
                hRender:Delete()
            end
            this = nil
        end,

        Render = function(this)
            for _, hRender in pairs(this.RENDER_ITEMS) do
                hRender:Delete()
                hRender:Render()
            end
        end,
    }

    for _, tItem in pairs(tInfo.Items) do

        local iX, iY, iWidth, iHeight = tItem.PosX, tItem.PosY, tItem.Width, tItem.Height
        local aColor = tItem.Color or {0,0,0}
        local iR = (255 / aColor[1])
        local iG = (255 / aColor[2])
        local iB = (255 / aColor[3])
        local iA = (aColor[4] or tItem.Alpha or 1)

        local tNewItem = {
            HandleBox = nil,
            HandleTxt = nil,
            HandleImg = nil,
            DataValue = nil,
            RENDER_INFO = {

                Img = tItem.Image,
                Txt = tItem.Text,
                Box = tItem.Box,

                PosX = iX,
                PosY = iY,
                Width = iWidth,
                Height = iHeight,
                R = iR,
                G = iG,
                B = iB,
                A = iA,

                PosXO = iX,
                PosYO = iY,
                WidthO = iWidth,
                HeightO = iHeight,
                RO = iR,
                GO = iG,
                BO = iB,
                AO = iA,
            },
            GetRenderData = function(this, hId) return this.RENDER_INFO[hId]  end,
            SetRenderData = function(this, hId, DataValue) this.RENDER_INFO[hId] = DataValue  end,
            GetDataValue = function(this) return this.DataValue  end,
            SetDataValue = function(this, DataValue) this.DataValue = DataValue end,
            Render = function(this)
                this:Delete()
                local tRenderInfo = this.RENDER_INFO
                if (tRenderInfo.Img) then this.HandleImg = CPPAPI.DrawImage(tRenderInfo.PosX, tRenderInfo.PosY, tRenderInfo.Width, tRenderInfo.Height, tRenderInfo.Img) end
                if (tRenderInfo.Box) then this.HandleBox = CPPAPI.DrawColorBox(tRenderInfo.PosX, tRenderInfo.PosY, tRenderInfo.Width, tRenderInfo.Height, tRenderInfo.R, tRenderInfo.G, tRenderInfo.B, tRenderInfo.A) end
                if (tRenderInfo.Txt) then this.HandleTxt = CPPAPI.DrawText(tRenderInfo.PosX, tRenderInfo.PosY, tRenderInfo.Width, tRenderInfo.Height, tRenderInfo.R, tRenderInfo.G, tRenderInfo.B, tRenderInfo.A, tRenderInfo.Txt) end
            end,
            Delete = function(this)
                if (this.HandleBox) then CPPAPI.RemoveTextOrImageById(this.HandleBox) end
                if (this.HandleTxt) then CPPAPI.RemoveTextOrImageById(this.HandleTxt) end
                if (this.HandleImg) then CPPAPI.RemoveTextOrImageById(this.HandleImg) end
                this:Reset()
            end,
            Reset = function(this)
                this.HandleBox = nil
                this.HandleTxt = nil
                this.HandleImg = nil
            end,
            PreInit = tItem.PreInit
        }
        tMenu.RENDER_ITEMS[(tItem.Name or _)] = tNewItem
    end

    tMenu:Init()
    self._MENUS[sName] = tMenu
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

CryMP_Client.SLH = function(self,eId,col,time)

    local e=type(eId)=="userdata"and _S.GetEntity(eId)or self:GE(eId)
    if(not e)then
        self:DLog("no entity to SLH(%s)",tostring(eId))
        return
    end
    local r,g,b,a=col[1],col[2],col[3],(col[4]or 1)
    if (time==0)then
        HUD.SetSilhouette(e.id,0,0,0,0,0)
        return
    end

    local expire=time or-1
    HUD.SetSilhouette(e.id,r,g,b,a,expire)
    self.SLH_LIST[e.id]={Color=col,Start=_time,Expire=expire}
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

CryMP_Client.SUIT_CHANGED = function(self, p,new,old)

    self:FIX_CM_MAT(p)
end

CryMP_Client.FIX_CM_MAT = function(self, p,new,old)
    local cm=p.CM
    local cm_p=p.CM_P
    if (cm)then
        local mat=self:GET_OBJ_MAT(cm_p)
        if(not mat)then return end
        p.CM_MAT=mat
        p:ResetMaterial(0)
        p:SetMaterial(mat)
        self:DLog("fix mat..")
    end
end

CryMP_Client.GET_OBJ_MAT = function(self,m)
    if(self.OBJ_MATERIALS[m])then return self.OBJ_MATERIALS[m] end
    local o = System.SpawnEntity({ class = "BasicEntity", properties = { object_Model = m }})
    if (not o) then return end
    local mat = o:GetMaterial(0)self.OBJ_MATERIALS[m]=mat; System.RemoveEntity(o.id) return mat
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

        --if still in highlight, stop it, for ourselfs, timer is 2.5s, for othrs its 1
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
           --  a["SCAR"]="reload"
         --    a["FY71"]="reload"
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
    local p=eId~=nil and type(eId)=="string"and System.GetEntity(eId)
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
        self:DLog("inc voice vol")
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

        local s=hp.actor:GetNanoSuitMode()
        if(s~=hp.LAST_SUIT)then
            self:DLog("suit=%d",s)
            self:SUIT_CHANGED(hp,s,hp.LAST_SUIT)
            hp.LAST_SUIT=s
        elseif (hp.CM and hp.CM~=hp.LAST_CM)then
            self:FIX_CM_MAT(hp)
            hp.LAST_CM=hp.CM
        end
    end
    self:UPDATE_HIT_MARKERS()
end

CryMP_Client.AddHitMarker = function(self,pos,dist)
    if(dist and dist>80)then return end
    local lifetime=0.75
    self.HIT_MARKER={ pos = pos, time = _time, lifetime = lifetime, expire = _time + lifetime }
end

CryMP_Client.UPDATE_HIT_MARKERS = function(self)

    local hm=self.HIT_MARKER
    if(hm and _time<hm.expire)then
        local g_laPos = g_la:GetPos()
        local d = self:CALC_DIST(hm.pos, g_laPos)
        if (d <= 80) then
            -- alpha = ((x - y) / z) * -1
            local alpha = ((hm.expire - _time) / hm.lifetime) * 1
            --Msg(0, (entfernung / 100) * 0.5)
            if (alpha > 0) then
                -- (entfernung / 100) * 10
                System.DrawLabel( hm.pos, 1.5, "$4" .. "(X)", 1, 0, 0, alpha ) -- only one label can be drawn at a time :c
            end

        else
            self.HIT_MARKER=nil
        end
    else
        self.HIT_MARKER=nil
    end
    --[[
    local imc=#self.HIT_MARKERS
    if (imc>0) then
        local g_laPos = g_la:GetPos()
        for i = 1, imc do
            --Msg(0, "id = %d", i)
            local marker = self.HIT_MARKERS[i]
            local r = false
            if (marker and _time < marker.expire) then
                local entfernung = self.CALC_DIST(marker.dort, g_laPos)
                if (entfernung <= 80) then
                    -- alpha = ((x - y) / z) * -1
                    local alpha = ((marker.expire - _time) / marker.lebensdauer) * 1
                    --Msg(0, (entfernung / 100) * 0.5)
                    if (alpha > 0) then
                        -- (entfernung / 100) * 10
                        System.DrawLabel( marker.dort, 1.5, "$4" .. "(X)", 1, 0, 0, alpha ) -- only one label can be drawn at a time :c
                    end

                else
                    r = true
                end
            else -- ?
                table.remove(self.HIT_MARKERS, i)
                --HIT_MARKERS[i] = nil
                break
            end

            if (r) then
                --HIT_MARKERS[i] = nil
                table.remove(self.HIT_MARKERS, i)
            end
        end
    end]]
end

CryMP_Client.OnHit = function(self, p, hit)
    --MOVE HERE
    BasicActor.Client.OnHit(p, hit)

    --==============================
    if (not hit.shooter or not hit.target) then
        return
    end

    local ht = hit.type
    if (ht == "lockpick" or ht == "repair") then
        return
    end

    local shooter_isLa = hit.shooterId == g_laId
    local target_isLa  = hit.targetId  == g_laId
    local self_hit		= shooter_isLa and target_isLa

    local bullet = string.find(tostring(ht), "bullet")
    local melee = ht == "melee"
    local explo = hit.explosion
    local hs = g_gameRules:IsHeadShot(hit)
    local wc = hit.weapon and hit.weapon.class

    if (hit.target and hit.shooter and hit.targetId ~= hit.shooterId) then
     --   ATOMClient.AnimationHandler:OnAnimationEvent(hit.target, eCE_AnimHit, hit, (idIsBullet or idIsMelee))
    end

    if (shooter_isLa and not self_hit and bullet) then
        local s = "sounds/physics:bullet_impact:mat_armor"
        if (hs) then
            s = "sounds/physics:bullet_impact:helmet_feedback"
        end
      --  g_la:PlaySoundEvent(s, g_Vectors.v000, g_Vectors.v010, SOUND_2D, SOUND_SEMANTIC_PLAYER_FOLEY)
        if (not target_isLa and not melee and self:CALC_DIST(hit.pos,hit.target:GetPos())<5) then
            self:AddHitMarker(hit.pos, self:CALC_DIST(g_la:GetPos(), hit.pos))
        end
    end

end

CryMP_Client.CALC_DIST = function(self,a,b)
    local vec_a=a if (a.GetPos) then vec_a=a:GetPos()end
    local vec_b=b if (b.GetPos) then vec_b=b:GetPos()end
    local x = (vec_a.x - vec_b.x)
    local y = (vec_a.y - vec_b.y)
    local z = (vec_a.z - vec_b.z)
    return math.sqrt(x * x + y * y + z * z)
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
                self:Log("$4[Error] \n"..tostring(tb))
            end
        end
        return true
    end
end

CryMP_Client.HookGame = function(self)

    --========================================================
    -- Player
    if (not Player) then Script.ReloadScript("Scripts/Entities/Actor/Player.lua") end
    Player.Client.OnHit=function(this,hit)
        CryMP_Client:OnHit(this,hit)
    end
    for _,p in pairs(System.GetEntitiesByClass("Player")or{})do
        p.Client.OnHit=Player.Client.OnHit
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
