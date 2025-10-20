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
-- !push boats
-- third eye
-- menus
-- ccm
-- flvshing for chvtters
-- vtol/heli: square on enemies (in fp only?)


--done
--<<<fix modelid material (see atomcl)

if (CryMP_Client) then
    WAS_INSTALLED=true
end

local osclock=os.clock()
CryMP_Client = {
    DEBUG_DL={},
    menus={
      corner_hud="corner_hud_menu",
      xp_info="xp_info",
      debug="dg"
    },
    Timers={
     --   Second=osclock-1
    },
    --,

    HIT_MARKER = nil, -- hit marker info, can be reset, np
    ---HIT_MARKERS = {}, -- hit marker info, can be reset, np
    OBJ_MATERIALS = {}, -- list of objects materials
    SLH_LIST = {}, -- a list of persistent silhouettes
    CLOAKED_VEHICLES = {}, -- a list of cloaked vehicles (table=driver)

    CROSSHAIR_ENT=nil,

    -- Voices
    PATCHED_VOICES = {},
    INCREASE_VOICE_VOLUMES=1,
    ENABLE_VEHICLE_WEAPONS=1,

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



    _RND = {},
    rnd=function(self,i,min,max)
        min,max=min or 0,max or 1
        local v=frnd(min,max)
        if (not i) then return v end
        if (not self._RND[i]) then
            self._RND[i]={v=v,set=function(r)r.v=frnd(min,max)return r.v;end}
        end
        return self._RND[i]
    end,
}
CryMP_Client.Requests={
    ClientInstalled=10,
    OpenChat=11,
    OpenTeamChat=12,
}
ClEvents={
    XP=0,
}
ClGlobalKeys = {
    VehicleLocked = 10,
    VehicleReserved = 11,
    PlayerUUIDCheck = 245,
    PlayerUUIDSalt = 246,
    PlayerModel = 1000,
    PlayerModelNK = 1000 + 1,
    PlayerModelUS = 1000 + 2,
    PlayerUsabilityMessage = 1010,
    PlayerAccessName = 1011,
    PlayerLevelXP = 1018,
    PlayerRankXP = 1019,
    PlayerChattingStatus = 1014,
    EntityUsabilityMessage = 1250,
}
CryMP_Client.VERSION="0.0"
CryMP_Client.DEBUG=tostring(System.GetCVar("cl_hud"))=="999"
CryMP_Client.FPS = 1/40

 TS_Spec,TS_Chat="spec","chat"
_S=System
 g_laId=g_localActorId
 g_la=g_localActor
g_laChan=g_localActor.actor:GetChannel()
 g_game=g_gameRules.game
_gg=g_game
_gr=g_gameRules
LAYER_CLOAK=4

IS_PS=_gr.class=="PowerStruggle"
IS_IA=not IS_PS
_AddComm = function(name, func, desc)
    desc=desc or"no description"
    if (CPPAPI.AddCommand) then CPPAPI.AddCCommand(name, func, desc) else System.AddCCommand(name, func, desc) end
end
timerinit=function(t,ms)
    return os.clock()+(ms or 0)
end
timerexpired=function(t,ms)
    return t==nil or (os.clock()-t>=ms)
end
rndT=function(t)
    return t[math.random(#t)]
end
vec_s=function(v,s) return{x=v.x*s,y=v.y*s,z=v.z*s} end
frnd=randomF
str_lspc=function(str,spc)return string.rep(" ",spc-#str)..str  end
-- vec helpers




-- ===================================================================================

CryMP_Client.INSTALL = function(self)

    HUD.BattleLogEvent(eBLE_Information,"Client v" .. self.VERSION .. " Installed Successfully!")
    self:DLog("CryMP: %d, Client: %s",GetVersion()or -1,self.VERSION)
    self:TS(TS_Spec,self.Requests.ClientInstalled)
    self:PATCH_BUY_LISTS()
    self:HookGame()
    self:AddMenus()
    self:AddLocale()

    self.sl:Init()


    --==============
    self:rnd("hit_scree_blood",0.75,1.85)


    _AddComm("crymp_test_menudimXY",[[CryMP_Client:_test_menu_dims(%1, %2)]])
    _AddComm("crymp_test_sb",[[CryMP_Client:SCREEN_BLOOD()]])
    _AddComm("crymp_test_flip",[[CryMP_Client:FLIP_MY_WHIP(%%)]])
    _AddComm("crymp_lload",[[CryMP_Client:LoadLocal()]])
end


CryMP_Client.LoadLocal=function(self)
    loadfile("CryMP-Server-Light/Sources/Lua/Remote/CryMP-ServerClient.lua")()
end


CryMP_Client.Event=function(self,e,info)

    local tpe=(info.Type or"def"):lower()
    local v=info.Value
    if(e==ClEvents.XP)then

        self:DLog("event xp=%f",v)
        if(tpe=="level")then
            self:CornerMsg("XP " ..(v>=0 and "+"or"")..v,CryMP_Client.COLORS.grey,2.5)
        elseif(tpe=="rank")then
            self:CornerMsg("XP " ..(v>=0 and "+"or"")..v,CryMP_Client.COLORS.grey,2.5)
        else
            self:DLog("bad type!!!! :(")
        end
    end
end

CryMP_Client.AddLocale=function(self)
    if (CPPAPI.AddLocalizedLabel) then
        local sTut = "Sells your currently equipped item"
        local sTutV = "Sells any vehicles you currently have parked inside the Garage"
        CPPAPI.AddLocalizedLabel("@mp_TutSell_I", { english_text = sTut, languages = { english = sTut }})
        CPPAPI.AddLocalizedLabel("@mp_TutSell_A", { english_text = sTut, languages = { english = sTut }})
        CPPAPI.AddLocalizedLabel("@mp_TutSell_V", { english_text = sTutV, languages = { english = sTutV }})

        -- crysis wiki.. i didn't write this nonsense..
        local shit_en = "The Shi Ten can kill most enemy units in a few shots. It has unlimited ammo, meaning that it's reusable and saves ammo."
        CPPAPI.AddLocalizedLabel("@mp_TutShiTen", { english_text = shit_en, languages = { english = shit_en }})
    end
end
CryMP_Client.PATCH_BUY_LISTS=function(self)

    if (not IS_PS) then return end
   -- self.buyList["usvtol"].price = 800
   -- self.buyList["nkhelicopter"].price = 600
  ----  self.buyList["nkapc"].price = 600
  --  self.buyList["ustank"].price = 700
   -- self.buyList["nktank"].price = 700

    -- Weapons!
   -- self.weaponList["shiten"] = { id = "shiten", name = "ShiTen", category = "@mp_catWeapons", price = 400, loadout = 1, weapon = true, class = "ShiTen", uniqueId = 620, uniqueloadoutgroup = 1, uniqueloadoutcount =2};
   -- self.buyList["rpg"].price = 200
   -- self.buyList["dsg1"].price = 350
   -- self.buyList["gauss"].price = 650

    -- Ammo!
    --self.weaponList["sell_1"]  = { id = "sell_1",   name = "Sell Current Item", 		category = "@mp_catExplosives", 	price = 0, 		loadout = 1};
  --  self.ammoList["sell_2"]  = { id = "sell_2",   name = "Sell Current Item", 		ammo = true, category = "@mp_catAmmo", 	price = 0, 		loadout = 1};
   -- self.buyList["rocket"]   = { id = "rocket", name = "@mp_eRocket",       invisible = true, ammo = true, price = 25, amount = 1, category="@mp_catAmmo", loadout = 1 }

    _gr.weaponList["shiten"] = { id = "shiten", name = "@mp_TutShiTen", category = "@mp_catWeapons", price = 400, loadout = 1, weapon = true, class = "ShiTen", uniqueId = 620, uniqueloadoutgroup = 1, uniqueloadoutcount =2};
    _gr.weaponList["sell"]  = { id = "Sell_I",   name = "@mp_TutSell_I", 		category = "@mp_catExplosives", 	price = 0, 		loadout = 1};
    _gr.ammoList["sell"]  = { id = "Sell_A",   name = "@mp_TutSell_A", 		category = "@mp_catAmmo", 	price = 0, 		loadout = 1};
    _gr.vehicleList["sell"]  = { id = "Sell_V",   name = "@mp_TutSell_V", 		category = "@mp_catVehicles", 	price = 0, 	};


    _gr.buyList["shiten"]  = _gr.weaponList["shiten"]
    _gr.buyList["sell_i"]  = _gr.weaponList["sell"]
    _gr.buyList["sell_a"]  = _gr.ammoList["sell"]
    _gr.buyList["sell_v"]  = _gr.vehicleList["sell"]


    HUD.UpdateBuyList()
end

CryMP_Client.OnAction=function(self,la,action,activation,value)

    local w = g_la.inventory:GetCurrentItem()
    local v = g_la.actor:GetLinkedVehicleId()
    if (v) then
        v = _S.GetEntity(v)
    end
    local ch_ent = self.CROSSHAIR_ENT
    local wCount = g_la:GetSeatWeaponCount() or 0
    self:DLog("%s %s %d",action,activation,value)


    if(value==1)then
        self:DLog("cc")
        if (action=="hud_openchat")then
            self:TS(TS_Spec,CryMP_Client.Requests.OpenChat)
        elseif(action=="hud_openteamchat")then
            self:TS(TS_Spec,CryMP_Client.Requests.OpenTeamChat)
        end
    end


    local door_anim = 0+1
    if (action == "use" and value == 1) then
        if (ch_ent and ((door_anim==1 and ch_ent.class=="Door") or ch_ent.vehicle and ch_ent.vehicle:GetMovementType()=="sea"and not ch_ent.vehicle:IsSubmerged())) then
            self:FP_ANIM(g_laChan,"hands_up_01")--NOT punchDoor_01
        end
    end
    if (action == "binoculars" and v) then
        if (self.ENABLE_VEHICLE_WEAPONS and wCount < 1) then
            local binoId = g_la.inventory:GetItemByClass("Binoculars")
            if (binoId) then
                local bino = _S.GetEntity(binoId)
                if (not bino.Selected or g_localActor.inventory:GetCurrentItem().id ~= binoId) then
                    g_la.actor:SelectItemByName("Binoculars")
                    bino.Selected = true
                else
                    bino.item:Select(false);
                    g_la.actor:HolsterItem(true)
                    --g_la.actor:SelectItemByName("Fists")
                    bino.Selected = false
                end
            end
        end
    end
end

CryMP_Client.IsSpeed=function(self,p)
    return p.actor:GetNanoSuitMode()==NANOMODE_SPEED
end

CryMP_Client.FP_ANIM=function(self,chan,anim)

    local p=self:GP(chan)
    if(not p)then return end
    if(p.id~=g_laId)then return end
    local item = p.inventory:GetCurrentItem()
    if (item and item.class == "Fists") then
        local speed = self:IsSpeed(g_la) and 2 or 1.3
        item:StartAnimation(0, anim or "punchDoor_01", 1, 0.15, speed)
    end

end

CryMP_Client.GetMenu=function(self,id)
    return self._MENUS[id]
end

CryMP_Client.AddMenus=function(self)

    local hDrawText = CPPAPI.DrawText
    if (not hDrawText) then

        self:DLog("Bad CLIENT for MENUS!!")
        return

    end
    CPPAPI.RemoveTextOrImageAll()
    for _, tMenu in pairs(self._MENUS) do
        tMenu:Delete()
    end
    self._MENUS={}

    -- =======================================
    local sRank = (g_game:GetSynchedEntityValue(g_laId,ClGlobalKeys.PlayerAccessName)) or "Unknown"
    self:AddMenu("server_info", {
        Items = {
            A        = { Text = "Cry-MP",     PosX = 10, PosY = 5, Width = 1, Height = 1, Alpha = 1, Color = { 255, 1, 1 } },
            B        = { Text = "Server - v" .. self.VERSION.." - Access",     PosX = 50, PosY = 5, Width = 1, Height = 1, Alpha = 1, Color = { 255, 255, 255 } },
            C        = { Text = sRank,     PosX = 190, PosY = 5, Width = 1, Height = 1, Alpha = 1, Color = { 255, 1, 1 } },
        },
    })



    if (self.DEBUG) then
        local xpinfo_add=0
        if (true) then
            self:AddMenu(self.menus.xp_info, {
                Items = {
                    img={Image = "Testing\\" .. "xp_icon_2025.dds", Width=20,Height=20,PosY=65,PosX=  168+590},
                    xp={Text="0",Color={255,223,0},Width=1.3,Height=1.3,PosX=590-17,PosY=67},
                },
                Update=function(this)
                    local rnd=this:GetRender("xp")
                    local xp=(rnd:GetDataValue()or 0)--+math.random(1,10)
                    --self:DLog(xp)
                    rnd:SetRenderData("Txt",str_lspc(tostring(xp),23))
                    rnd:Render()
                   -- rnd:SetDataValue(xp)
                end
            })
            xpinfo_add=25
        end
        self:AddMenu(self.menus.debug, {
            Items = {
                t1={Box="debug",Width=10,Height=10,Color={255,1,1},PosX=0,PosY=0,}
            },
        })
        self:AddMenu(self.menus.corner_hud, {
            Items = {
            },
            DefaultRenderInfo={
                PosX=590,
                PosY=65+xpinfo_add,
                Width=1.1,
                Height=1.1,
                Alpha=1,
                Color={255,223,0},
            },
            Update=function(this)
                local render_list={}
                for _,hRnd in pairs(this:GetRenders()) do
                    --disp only 5
                    local rnd_data=hRnd:GetDataValue()
                    --if render_list==nil or #render_list<5 then
                    if (rnd_data) then -- not icon..
                        if( rnd_data.disp_t and _time>= rnd_data.disp_t+rnd_data.delete) then
                            local childNum=1
                            local icon=this:GetRender(hRnd:GetRenderId().."_child_"..childNum)
                            while icon do
                                this:DeleteRender(icon:GetRenderId())
                                childNum=childNum+1
                                icon=this:GetRender(hRnd:GetRenderId().."_child_"..childNum)
                            end
                            this:DeleteRender(hRnd:GetRenderId())
                        else
                            table.insert(render_list,{r=hRnd,v=rnd_data and rnd_data.time})
                        end
                    end
                    --end
                end
                --older first, then newer...............
                table.sort(render_list,function(a,b)return a.v<b.v  end)
                if(#render_list>0)then
                    local tdel={}
                    local item_c=math.min(10,#render_list)
                    local posy_d=this.DEF_RENDER_INFO.PosY+(item_c*10)
                    for i=1,item_c do
                        local r=render_list[i]
                        if (r) then
                            local rnd=r.r

                            local dv=rnd:GetDataValue()
                            dv.disp_t=dv.disp_t or _time

                            local posy=posy_d-(i*10)

                            local alpha=1
                            local f_sT =  dv.disp_t + dv.fadeStart
                            local endTime =  dv.disp_t + dv.delete
                            if _time >= endTime then
                                alpha = 0 --delete next round..
                            else
                                local f_p = (_time - f_sT) / (endTime - f_sT)
                                alpha = 1 - f_p
                            end

                            --   self:DLog(i)
                            alpha=math.max(0.05,alpha)
                            --rnd:SetRenderData("Txt","mod"..i)
                            rnd:SetRenderData("PosY",posy)
                            rnd:SetRenderData("A",alpha)
                            rnd:Render()

                            local childNum=1
                            local icon=this:GetRender(rnd:GetRenderId().."_child_"..childNum)
                            while icon do
                                --icon:SetRenderData("PosY",50)
                                --icon:SetRenderData("PosX",50)
                                icon:SetRenderData("A",alpha)
                                icon:SetRenderData("PosY",posy)
                                icon:Render()
                                --  self:DLog("icon on index %d",childNum)
                                childNum=childNum+1
                                icon=this:GetRender(rnd:GetRenderId().."_child_"..childNum)
                            end
                        end
                    end
                end
            end
        })


    end




    --[[
    local ImgSrc = "..\\CryMP-Server-Light\\Sources\\Lua\\Remote\\PAK\\Images\\Menus\\"
    self:AddMenu("XP_Menu", {

        Items = {
           Icon        = { Image = "Testing\\" .. "xp_icon.dds",     PosX = 100, PosY = 100, Width = 24, Height = 21, },
            Icon        = { Text = "(XP)",    Color={177,198,164}, PosX = 250, PosY = 97, Width = 1, Height = 1, },
            Bar         = { Box = true, Color = { 255, 199, 066 }, Alpha = (255/213), PosX = 200, PosY = 100, Width = 58, Height = 8, },
            Progress    = { Box = true, Color = { 177, 198, 164 }, Alpha = (255/213), PosX = 200, PosY = 100, Width = 53, Height = 4, },
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
    })]]
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
        DEF_RENDER_INFO = {},
        RENDER_ITEMS = {},
        RC = 0,

        PreInit = tInfo.PreInit,
        Update = tInfo.Update or function(this)
        end,

        Init = function(this)
            if (this.PreInit) then
                this:PreInit()
            end
            this:Render()
        end,

        GetDefaultRenderInfo = function(this)
            return this.DEF_RENDER_INFO
        end,

        AddRender = function(menu, tItem, sName)

            menu.RC=menu.RC+1
            local tDef = menu:GetDefaultRenderInfo()
            local iX, iY, iWidth, iHeight = tItem.PosX or tDef.PosX, tItem.PosY or tDef.PosY, tItem.Width or tDef.Width, tItem.Height or tDef.Height
            local aColor = tItem.Color or tDef.Color or {0,0,0}
            local iR = (aColor[1]) / 255
            local iG = (aColor[2]) / 255
            local iB = ( aColor[3]) / 255
            local iA = (aColor[4] or tItem.Alpha or tDef.Alpha or 1)

            self:DLog("R:%f,G:%f,B:%f",iR,iG,iB)

            local hId=(tItem.Name or sName or menu.RC)
            local tNewItem = {

                Priority = 0,
                HandleBox = nil,
                HandleTxt = nil,
                HandleImg = nil,
                DataValue = nil,
                RENDER_ID = hId,
                RENDER_INFO = {

                    Img = tItem.Image or tItem.Img,
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
                GetRenderId = function(this) return this.RENDER_ID  end,
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
            menu.RENDER_ITEMS[hId] = tNewItem

            return tNewItem
        end,

        GetRender = function(this, hId)
            return this.RENDER_ITEMS[hId]
        end,

        GetRenders = function(this)
            return this.RENDER_ITEMS
        end,

        Delete = function(this)
            for _, hRender in pairs(this.RENDER_ITEMS) do
                hRender:Delete()
            end
        end,

        DeleteRender = function(this, hId)
            local hRender = this:GetRender(hId)
            if (hRender) then hRender:Delete() end
            this.RENDER_ITEMS[hId]=nil
        end,

        Destroy = function(this)
            for _, hRender in pairs(this.RENDER_ITEMS) do
                hRender:Delete()
            end
            this = nil
        end,

        Render = function(this)
           -- local aOrdered = {}
            for _, hRender in pairs(this.RENDER_ITEMS) do
                hRender:Delete()
                --table.insert(aOrdered, { V = hRender.Priority, R = hRender })
                hRender:Render()
            end
            --table.sort(aOrdered, function(a, b) return a.V>b.V  end)
           -- for i=1,#aOrdered do
            --    aOrdered[i].R(aOrdered[i].R)
            --end
        end,
    }

    if (tInfo.DefaultRenderInfo) then
        for k,v in pairs(tInfo.DefaultRenderInfo) do
            tMenu.DEF_RENDER_INFO[k]=v
        end
    end

    local function AddRenderItem(tMenu, tItem, sName)

    end

    for _, tItem in pairs(tInfo.Items) do
        tMenu:AddRender(tItem, _)
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
    --self:CLOAK_VEHICLE(p,new==NANOMODE_CLOAK)
    self:FIX_CM_MAT(p)
end

CryMP_Client.CLOAK_VEHICLE = function(self,v,e)--p,v,e)



    local ok={Civ_car1=1,US_ltv=1,US_smallboat=1}
    if ((ok[v.class] or self.DEBUG)) then
        local cv = self.CLOAKED_VEHICLES[v.id]
        if (e) then
            if (not cv) then
                self:DLog("cloak v")
                v:EnableMaterialLayer(true,LAYER_CLOAK)
                self.CLOAKED_VEHICLES[v.id] = v
            end
        elseif (cv) then
            self:DLog("uncloak v")
            v:EnableMaterialLayer(false,LAYER_CLOAK)
            self.CLOAKED_VEHICLES[v.id] = nil
        end
    end


--[[
    local vId = p.actor:GetLinkedVehicleId()
    local cv=self.CLOAKED_VEHICLES
    if (vId) then
        local v = System.GetEntity(vId)
        if (v) then
            if (e and ok[v.class]) then
                if (cv[v]==nil) then
                    cv[v]=p

                end
            end
        end

        if (hVehicle and CLOAKABLE_VEHICLES[hVehicle.class] == true and hVehicle:GetDriverId() == hPlayer.id) then
            Msg(1, "vehicle okie ")
            if (hPlayer.actor:GetNanoSuitMode() == NANOMODE_CLOAK and hPlayer.actor:GetNanoSuitEnergy() >= 35) then
                self.CloakVehicle(idVehicle)
            elseif (CLOAKED_VEHICLES[idVehicle]) then
                self.UncloakVehicle(idVehicle)
            end
        end
    end]]
end

CryMP_Client.CM_REVIVE = function(self, p,new,old)
    if(p.actor:GetHealth()<=0)then return end

    -- vehicle check (revive in vehicle will bug pose)
    p.actor:Revive()
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

CryMP_Client.PATCH_SELL_ITEM = function(self)
    if (not IS_PS) then return end
    if (not g_gameRules.buyList) then return end

    -- whats even the point of this
    -- Point is: With a little C++ change, we could make certain items ALWAYS available to buy (despite not having enough PP)
    g_gameRules.buyList["sell_i"].price=0 -- item
    g_gameRules.buyList["sell_i"].available=0 -- item
    g_gameRules.buyList["sell_a"].price=0 -- ammo ??
    g_gameRules.buyList["sell_a"].available=0 -- ammo ??
    g_gameRules.buyList["sell_v"].price=0 --vehicle (put in garage then "purchase" this
    g_gameRules.buyList["sell_v"].available=0 --vehicle (put in garage then "purchase" this
    HUD.UpdateBuyList()
end

CryMP_Client.ITEM_CHANGED = function(self,p,new,old)

    if (p.id==g_laId and IS_PS) then
        --xTODO
       -- self:UpdateBLSell()
        self:PATCH_SELL_ITEM()
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

    if(not timerexpired(self.Timers.ClientFps,self.FPS))then
        return
    end


    --self:_test_box_on_wts()

    for _,tm in pairs(self._MENUS) do
        if(tm.Update) then tm:Update() end
    end

    self.Timers.ClientFps=timerinit()

    -- FIXME to disco()
    if (not g_la)then
        WAS_INSTALLED=false
        return
    end

    local clock=os.clock()
    if (timerexpired(self.Timers.Second,1)) then
        self.Timers.Second=timerinit()
        self:OnTimer()
    end
    if(timerexpired(self.Timers.QuickTick, 0.07)) then
        self.Timers.QuickTick=timerinit()
        self:QuickTick()
    end
    if(timerexpired(self.Timers.Tick, 1)) then
        self.Timers.Tick=timerinit()
        self:Tick()
    end
    --self:DLog("in %f",self.Timers.Second-clock)

    self:UPDATE_FLIPS()

    if (self.DEBUG_DL) then
       local m_dbg=self:GetMenu(self.menus.debug)
        if (m_dbg) then
            local rnd_1 = m_dbg:GetRender("t1")
            rnd_1:SetRenderData("PosX",self.DEBUG_DL.x or 0)
            rnd_1:SetRenderData("PosY",self.DEBUG_DL.y or 0)
            rnd_1:Render()
        end
    end

    if (g_la) then
        local stats=g_la.actorStats
        local tp=stats.thirdPerson
        if (self.IS_IN_TP ~= tp) then
            self.IS_IN_TP=tp
            self:VIEW_CHANGED(tp,not tp)
            self:DLog("v changed")
        end


        local use_msg = self.USABILITY_MSG or g_game:GetSynchedEntityValue(g_laId,ClGlobalKeys.PlayerUsabilityMessage)
        if (use_msg and #use_msg>0) then
            self.USABILITY_MSG_ON=1
            HUD.SetUsability(1,use_msg)
        elseif(self.USABILITY_MSG_ON) then
            self.USABILITY_MSG_ON=nil
            HUD.SetUsability(0,"")
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

CryMP_Client.STOP_FLIP = function(self)
    if (self.CURRENT_FLIP) then
        self:DLog("end flup")
    end
    self.CURRENT_FLIP=nil
end

CryMP_Client.FLIP_MY_WHIP = function(self,f)

    local v=g_la:GetVehicle()
    if(not v)then self:DLog("no whip to flip") return end

    if(f)then

        self:DLog("inpatient")
        self:STOP_FLIP()
    end
    if(self.CURRENT_FLIP)then
        return self:DLog("wait for flip to finish idiot")
    end
    self.CURRENT_FLIP={
        start_t=_time,
        start=v:GetPos(),
        stage=0,
        v=v
    }

    self:DLog("flip")
end

CryMP_Client.UPDATE_FLIPS = function(self)

    local flip=self.CURRENT_FLIP
    if (not flip or flip.v:GetDriverId()~=g_laId or flip.v.vehicle:IsDestroyed())then
        return self:STOP_FLIP()
    end
--[[
    local v=flip.v
    v:SetWorldPos({x=2061,y=2008,z=56})
    flip.angz=(flip.angz or -math.pi) + 0.01
    if (flip.angz>math.pi)then
        flip.angz=-math.pi
    end

    v:SetAngles({y=0,z=0,x=flip.angz})
    self:DLog(Vec2Str(v:GetAngles()))
    do return end]]

    if(_time-flip.start_t>5)then
        return self:STOP_FLIP()
    end

    local v=flip.v
    local flip_start=flip.start
    local up=(v:GetPos().z-flip_start.z)
    local down
    if (flip.last_up and up < flip.last_up) then
      --  return self:STOP_FLIP()
        down=1
    end
    flip.last_up=up

    if(up>3 or down)then
        if(flip.stage<2)then
            flip.stage=2
            local engine=v:GetCenterOfMassPos()--v:GetHelperPos("Engine")
            local dv=v:GetDirectionVector()

            engine.x=engine.x+(dv.x*2.5)
            engine.y=engine.y+(dv.y*2.5)
            engine.z=engine.z+(dv.z*2.5)
            if(not engine)then
            --    engine=v:ToGlobal({x=1,y=0,z=0})--forward
             --   self:DLog("no engine")
            end
            self:DLog("flip stage 2")
            v:AddImpulse(-1,engine,g_Vectors.up,v:GetMass()*5,1)
        elseif(flip.stage<3)then
            flip.stage=3
            local ang=v:GetAngles()
            if (ang.x>-0.8 and ang.x<0.5)then
                v:SetAngles(ang)
                v:AddImpulse(-1,v:GetCenterOfMassPos(),g_Vectors.down,v:GetMass()*10,1)
                self:STOP_FLIP()
            end
            self:DLog("flip stage 3: %s",Vec2Str(ang))
        end
    else
        if(flip.stage<1)then
            flip.stage=1
            v:AddImpulse(-1,v:GetCenterOfMassPos(),g_Vectors.up,v:GetMass()*15,1)
            self:DLog("flip stage 1")
        end
    end
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

CryMP_Client.CornerMsg = function(self, msg, color, time)
    time=5--time or 5
    color={255,255,255}--color or CryMP_Client.COLORS.grey



    local menu=self:GetMenu(CryMP_Client.menus.corner_hud)
    if (not menu) then
        return self:DLog("no menu-. .."..tostring(self.menus.corner_hud))
    end
    local hnd=menu:AddRender({Color =color,Text=str_lspc(msg, 25),})
    hnd:SetDataValue({
        time=_time,
        delete=time*0.8,
        fadeStart=(time*0.5),
    })

    -- not for now..
    if (true) then
        --menu:AddRender({ Img = "Testing\\" .. "icon_2.dds", Width=20,Height=20,PosY=nil,PosX=  menu:GetDefaultRenderInfo().PosX-25 },hnd:GetRenderId().."_child_1")
     --   menu:AddRender({ Img = "Testing\\" .. "icon_3.dds", Width=20,Height=20,PosX=  168+menu:GetDefaultRenderInfo().PosX-0,PosY=menu:GetDefaultRenderInfo().PosY-10 },hnd:GetRenderId().."_child_1")
    end
end

CryMP_Client.HUD_INFO = function(self, m, t, e)
    t=t or 2.5
    if (t) then if (not timerexpired(self.Timers.HudMessage, t)) then return end end
    if (e) then e:PlaySoundEvent("Sounds/interface:suit:suit_vehicle_ready",g_Vectors.v000,g_Vectors.v010,SOUND_DEFAULT_3D,SOUND_SEMANTIC_PLAYER_FOLEY);end
    self.Timers.HudMessage = timerinit()
    HUD.DrawStatusText(m)
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
    --local wc = hit.weapon and hit.weapon.class

    if (hit.target and hit.shooter and hit.targetId ~= hit.shooterId) then
     --   ATOMClient.AnimationHandler:OnAnimationEvent(hit.target, eCE_AnimHit, hit, (idIsBullet or idIsMelee))
        if (shooter_isLa and not explo) then
            if (hit.target.is_chatting) then
                self:HUD_INFO("This Player is Currently Chatting!", 8, g_la)
            end
        end
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

    if (target_isLa and not self_hit and (bullet or melee) and hs) then
        self:SCREEN_BLOOD()
    end

end

CryMP_Client.SCREEN_BLOOD = function(self)--,a,b)
    if (timerexpired(self.Timers.hit_scree_blood, self:rnd("hit_scree_blood").v))then
        self.Timers.hit_scree_blood=timerinit()
        self:rnd("hit_scree_blood"):new()
        System.SetScreenFx("BloodSplats_Scale", frnd(0.3,0.1));
        CryAction.ActivateEffect("BloodSplats_Human");
        self:PlaySoundEvent("sounds/interface:hud:hud_blood", g_Vectors.v000, g_Vectors.v010, SOUND_2D, SOUND_SEMANTIC_PLAYER_FOLEY);
    end
end


VecSub=function(a,b)return{x=a.x-b.x,y=a.y-b.y,z=a.z-b.z}end
VecDot=function(a,b)return a.x*b.x+a.y*b.y+a.z*b.z end
VecCross=function(a,b)return{x=a.y*b.z-a.z*b.y,y=a.z*b.x-a.x*b.z,z=a.x*b.y-a.y*b.x}end
VecLen=function(v)return math.sqrt(v.x*v.x+v.y*v.y+v.z*v.z)end
VecNorm=function(v)local l=VecLen(v)return{x=v.x/l,y=v.y/l,z=v.z/l}end

WorldToScreen=function(worldPos)
    local camPos=System.GetViewCameraPos()
    local f=(System.GetViewCameraDir())
    local up={x=0,y=0,z=1}               -- Z-up
    local r=VecNorm(VecCross(f,up))      -- right = forward × up
    local u=VecCross(r,f)                -- up = right × forward

    local rel=VecSub(worldPos,camPos)
    local x,y,z=VecDot(rel,r),VecDot(rel,u),VecDot(rel,f)
    if z<=0 then return nil end -- behind camera

    local sw,sh=System.GetCVar("r_width"),System.GetCVar("r_height")
    local fov=math.rad(System.GetCVar("cl_fov"))
    local aspect=sw/sh
    local tanFov=math.tan(fov*0.5)

    local ndcX=(x/(z*tanFov*aspect))*0.5+0.5
    local ndcY=(-y/(z*tanFov))*0.5+0.5

    return ndcX*sw,ndcY*sh
end



CryMP_Client._test_menu_dims = function(self,a,b)

    --800
    --600
    a=tonumber(a)
    b=tonumber(b)

    if (MENU_DIM_ID1) then CPPAPI.RemoveTextOrImageById(MENU_DIM_ID1) end

    MENU_DIM_ID1=CPPAPI.DrawText(a, b, 1.2, 1.2, 1, 0.2,1,1, "[]")
end

CryMP_Client.CALC_DIST = function(self,a,b)
    local vec_a=a if (a.GetPos) then vec_a=a:GetPos()end
    local vec_b=b if (b.GetPos) then vec_b=b:GetPos()end
    local x = (vec_a.x - vec_b.x)
    local y = (vec_a.y - vec_b.y)
    local z = (vec_a.z - vec_b.z)
    return math.sqrt(x * x + y * y + z * z)
end

CryMP_Client.GetHitPos = function(self, p, dst, t, dir, pos)
    t = t or ent_all
    dst = dst or 5
    if (dst < 1) then
        dst = 1
    end
    dir = vec_s(dir,dst)
    local num=1
    local iHits = Physics.RayWorldIntersection(pos, dir, num, t, p.id, p:GetVehicleId(), g_HitTable)
    local aHit = g_HitTable[1]
    if (iHits and iHits > 0) then
        aHit.surfaceName = System.GetSurfaceTypeNameById( aHit.surface )
        return aHit
    end
    return
end

CryMP_Client.UpdateUseMsg = function(self)
    -- usability| to frame?
    local use_msg
    self.CROSSHAIR_ENT=nil
    local hit = self:GetHitPos(g_la,2,nil,g_la.actor:GetHeadDir(),g_la.actor:GetHeadPos())
    local hit_down = self:GetHitPos(g_la,4,nil,g_Vectors.down,g_la:GetPos())
    if (hit and hit.entity) then
        local hit_ent = hit.entity
        self.CROSSHAIR_ENT=hit_ent

       -- self:DLog("hi %s",tostring(hit_ent.class))
        --[[ if (hit_ent.CMID and hit_ent.CMID > 0) then

             self.USABILITY_MSG = "@use_vehicle"
             self.USABILITY_ENT = hit.entity
             bUsability = true
             DebugLog("ok")



         else]]if ((not hit_down or hit_down.entity ~= hit_ent) and hit_ent.vehicle and hit_ent.vehicle:GetMovementType()=="sea" and not hit_ent.vehicle:IsSubmerged()) then
        use_msg = "Push Boat"


        --[[elseif (hit_ent.vehicle and (g_pGame:GetSynchedEntityValue(hit_ent.id, 100))==1 and self:LADS(hit_ent,hit.pos)) then
            self.USABILITY_MSG = "[ VEHICLE LOCKED ]"
            self.USABILITY_ENT = hit.entity
            bUsability = true

        elseif (hit_ent.USABILITY_MSG) then
            local sMsg = hit_ent.USABILITY_MSG
            if (type(sMsg) == "function") then
                sMsg = sMsg(hit_ent)
            end
            self.USABILITY_MSG = sMsg--hit_ent.USABILITY_MSG
            self.USABILITY_ENT = hit.entity

            bUsability=true

        elseif (true) then--hit_ent.class=="TagAmmo") then

            local sMsg = hit_ent.USABILITY_MSG or string.match(hit_ent:GetName(), "Usability={(.-)}")
            if (hit_ent.is_helimg) then
                sMsg = ""
            end
            if (sMsg) then
                hit_ent.USABILITY_MSG = sMsg
                self.USABILITY_MSG = hit_ent.USABILITY_MSG
                self.USABILITY_ENT = hit.entity
                bUsability=true
            end
        ]]end
    end
    if(use_msg~=self.USABILITY_MSG and self.USABILITY_MSG~=nil)then
        self:DLog("new msg: "..tostring(use_msg))
    end
    self.USABILITY_MSG=use_msg
end

CryMP_Client.QuickTick = function(self)

    self:UpdateUseMsg()
    self.sl:Update()
end

CryMP_Client.Tick = function(self)


    --do return end


  --  self:CornerMsg("hi..".._time)
end

CryMP_Client._test_box_on_wts = function(self)


    local e=self:GE("test_wts")
    if (not e) then return self:DLog("no e") end

    local epos=e:GetBonePos("Bip01 Spine")
    local x,y=WorldToScreen(epos)


    local e_pos_down = e:GetBonePos("Bip01 R Foot")
    local e_pos_up = e:GetBonePos("Bip01 Head")

    local x_up, y_up = WorldToScreen(e_pos_up)
    local x_down, y_down = WorldToScreen(e_pos_down)

    if (not (x_up or x_down)) then
        return self:DLog("off screen")
    end

    x_up=(x_up/_S.GetCVar("r_height"))*800
    y_up=(y_up/_S.GetCVar("r_height"))*800
    x_down=(x_down/_S.GetCVar("r_width"))*600
    y_down=(y_down/_S.GetCVar("r_width"))*600


    local dist=VecLen(VecSub(System.GetViewCameraPos(),epos))
    local x_len = (10)
    local x_height



    local sizeX=10
    local sizeY=10

    self:DLog("%f,%f,%d",dist,x,y)

    if (MENU_DIM_ID1) then CPPAPI.RemoveTextOrImageById(MENU_DIM_ID1) end
    if (MENU_DIM_ID2) then CPPAPI.RemoveTextOrImageById(MENU_DIM_ID2) end
    if (MENU_DIM_ID3) then CPPAPI.RemoveTextOrImageById(MENU_DIM_ID3) end
    if (MENU_DIM_ID4) then CPPAPI.RemoveTextOrImageById(MENU_DIM_ID4) end
    --MENU_DIM_ID1=CPPAPI.DrawText(x-11,y-9, sizeX, sizeY, 1, 0.2,1,1, "[ ]")
    --(300, 300, 300, 200, 0, 0, 0,0.5)
    MENU_DIM_ID1=CPPAPI.DrawColorBox(x-11,y-9, 30, 3, 1, 0.2,1,1)--, "[ ]")
    MENU_DIM_ID2=CPPAPI.DrawColorBox(x-11,y-9, 3, 30, 1, 0.2,1,1)--, "[ ]")
    MENU_DIM_ID3=CPPAPI.DrawColorBox(x-11,y-9+30, 33, 3, 1, 0.2,1,1)--, "[ ]")
    MENU_DIM_ID4=CPPAPI.DrawColorBox(x-11+30,y-9, 3, 30, 1, 0.2,1,1)--, "[ ]")

  --  self:CornerMsg("hi..".._time)
end

CryMP_Client.GET_S = function(self,chan,id)
    local p=self:GP(chan)
    if(not p) then return end
    return g_game:GetSynchedEntityValue(p.id,id)
end

CryMP_Client.OnTimer = function(self)

    --quick tick now
    --self:UpdateUseMsg()

    -- cloaked vehicles
    for _,hp in pairs(g_gameRules.game:GetPlayers() or {}) do
        local vId=hp.actor:GetLinkedVehicleId()
        if (vId) then
            local v=System.GetEntity(vId)
            if (v:GetDriverId()==hp.id) then
                self:CLOAK_VEHICLE(v,hp.actor:GetNanoSuitMode()==NANOMODE_CLOAK)
            end
        end

        --chat effect
        local c_s=self:GET_S(hp.actor:GetChannel(),ClGlobalKeys.PlayerChattingStatus)
        hp.is_chatting=false
        if (c_s and c_s>0)then
            local c_c=CryMP_Client.COLORS.red
            local hpt=g_game:GetTeam(hp.id)
            local lat=g_game:GetTeam(g_laId)
            if(hpt==lat)then
                c_c=CryMP_Client.COLORS.green
            end
            if(c_s==1)then
                --all
            elseif(c_s==2)then
                --team
                c_c=CryMP_Client.COLORS.blue
                if(hpt~=lat)then
                 --   c_c=nil--hide from others? its team
                end
            end
            if(c_c)then
                hp.is_chatting=1
                self:SLH(hp.id,c_c,1)
             --   self:DLog("eff")
            end
        end
    end
    for vId,v in pairs(self.CLOAKED_VEHICLES) do
        if (not v or not System.GetEntity(vId)) then
            self.CLOAKED_VEHICLES[vId]=nil
        elseif (not v:GetDriverId()) then
            self:CLOAK_VEHICLE(v,false)
        end
    end
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

CryMP_Client.HookFunc = function(self, class, stack, func, patchClass)

    if(type(stack)=="table")then
        for i,v in pairs(stack) do
            self:HookFunc(class,v,func,patchClass)
        end
        return
    end
    local t = {class}
    for t_stack in stack:gmatch("([^%.]+)") do
        t[#t+1]=t_stack
       -- self:DLog("%d.%s",#t,t_stack)
    end

    local _g = _G[t[1]]
    if not _g then
        self:DLog("%s not loaded", t[1])
        if (System.GetEntityScriptPath) then
            local src=System.GetEntityScriptPath
            if (src and #src>0) then
                Script.ReloadScript(src,1,1)
                _g = _G[t[1]]
                if (not _g) then return end
            else
                return
            end
        else
            return
        end
    end
    local _g_type = type(_g)
    if (_g_type~="table") then
        self:DLog("%s is not table",t[1])
        return
    end

    local l=nil
    local function inj(e,ec)
        local c=e
        local pt=t[#t]
        for i=2,#t-1 do
            if (not t[i]) then
                break
            end
           -- self:DLog("i=%d,cs=%s",i,t[i])
            if (c[t[i]]==nil) then c[t[i]] = {} end
            c=c[t[i]]
            if (type(c)~="table") then
                self:DLog("target %s not table on class %s",t[i],ec or class)
            end
        end

        if (not l) then
        self:DLog("injected the victim %s$1 at %s with %s",ec or class,table.concat(t,"."),tostring(func)) l=1 end
        c[pt]=func
    end

    local c=_g
    inj(c,("_G.%s"):format(class))

    if (patchClass) then
        for _,e in pairs(self.PATCH_ENTITIES or System.GetEntities() or {}) do
            local m=patchClass:match("^m:(.*)")
            if ((m and e[m]) or e.class==patchClass) then
                self:DLog("m=%s",tostring(m))
                l=nil
                inj(e,("Ent.%s"):format(class))
            end
        end
    end
end

CryMP_Client.HookGame = function(self)

    self.PATCH_ENTITIES = System.GetEntities()

    --========================================================
    -- gr

    self:HookFunc("g_gameRules", "Client.ClPP", function(this, amount)
        if (amount>0) then
            HUD.BattleLogEvent(eBLE_Currency, "@mp_BLAwardedPP", amount);
        elseif (amount<0) then
            HUD.BattleLogEvent(eBLE_Currency, "@mp_BLLostPP", -amount);
        end
        CryMP_Client:CornerMsg("PP "..amount)
    end)

    --========================================================
    -- DOOR

    self:HookFunc("Door", "OnUsed", function(door, user)
        if(not user) then return end
        if (user.id~=g_laId) then return System.Quit() end
        door.server:SvRequestOpen(user.id, door.action~=DOOR_OPEN)
    end)

    --========================================================
    -- Player
    --[[
    if (not Player) then Script.ReloadScript("Scripts/Entities/Actor/Player.lua") end
    Player.Client.OnHit=function(this,hit)
        CryMP_Client:OnHit(this,hit)
    end
    for _,p in pairs(System.GetEntitiesByClass("Player")or{})do
        p.Client.OnHit=Player.Client.OnHit
    end]]

    self:HookFunc("Player", "Client.OnHit", function(this, hit)CryMP_Client:OnHit(this,hit)end,"m:actor")
    self:HookFunc("Player", "GetSeatWeaponCount", function(this, tSeat)
        local V = this:GetVehicle()
        if (V) then
            local seat = (tSeat or this:GetUsedSeat())
            if (seat) then local wc = seat.seat:GetWeaponCount() return wc end
        end
        return
    end,"m:actor")
    self:HookFunc("Player", "GetUsedSeat", function(this)
        local V = this:GetVehicle()
        if (V) then
            for i, v in pairs(V.Seats) do if (v:GetPassengerId() == this.id) then return v end end
        end
        return nil
    end,"m:actor")
    self:HookFunc("Player", "GetVehicle", function(this)
        local vId = this.actor:GetLinkedVehicleId()
        if (vId) then
            return _S.GetEntity(vId)
        end return
    end,"m:actor")
    self:HookFunc("Player", "GetVehicleId", function(this)
        local vId = this.actor:GetLinkedVehicleId()
        return vId
    end,"m:actor")
    self:HookFunc("g_localActor", "OnAction", function(this, action,activation,value)
        CryMP_Client:OnAction(this,action,activation,value)
        if (_gr and _gr.Client.OnActorAction) then
            if (not _gr.Client.OnActorAction(_gr, this, action, activation, value)) then
                return
            end
        end
        if (action == "use" or action == "xi_use") then
            this:UseEntity( this.OnUseEntityId, this.OnUseSlot, activation == "press");
        end
    end)
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

SEARCHLASER_SCALE=15
CryMP_Client.sl={
    Init = function(self)
        if(not IS_PS)then return end
        self:EnableAASearchLaser("AutoTurret",   true)
        self:EnableAASearchLaser("AutoTurretAA", true)
    end,
    EnableAASearchLaser = function(self, class, enable)
        for i, v in pairs(System.GetEntitiesByClass(class) or {}) do
            self:SpawnSearchLaser(v, enable)
        end
    end,
    Update = function(self, class)
        self:PostUpdate("AutoTurret")
        self:PostUpdate("AutoTurretAA")
    end,
    PostUpdate = function(self, class)
        -- update
        for i, v in pairs(System.GetEntitiesByClass(class) or {}) do
            if (v.item:IsDestroyed()) then
                if (v.SearchLaser and not v.HadSearchLaser) then
                    self:SpawnSearchLaser(v, false)
                    v.HadSearchLaser = true;
                end
            else
                if (v.HadSearchLaser) then
                    self:SpawnSearchLaser(v, true)
                    v.HadSearchLaser = false;
                end
                if (v.SearchLaser) then
                    if (v.SearchLaser:GetScale() ~= SEARCHLASER_SCALE) then
                        v.SearchLaser:SetScale(SEARCHLASER_SCALE)
                    end
                    v.SearchLaser:SetAngles(v:GetSlotAngles(1))
                end
            end
        end
    end,
    SpawnSearchLaser = function(self, entity, enable)
        if (enable) then
            self:LoadAALaser(entity)
        else
            self:UnloadLaser(entity, entity.SearchLaser)
        end
    end,
    UnloadLaser = function(self, entity, laser)
        if (laser) then
            --Msg(0, "del %s", laser:GetName())
            System.RemoveEntity(laser.id)
            entity.SearchLaser = nil;
        end
    end,
    LoadAALaser = function(self, entity)
        if (entity.SearchLaser and System.GetEntity(entity.SearchLaser.id)) then
            if (self.RESET) then
                System.RemoveEntity(entity.SearchLaser.id)
            else
                return;
            end
        end
        local laser = System.SpawnEntity({
            class = "BasicEntity",
            name = entity:GetName() .. "_sl", -- prolly not unique, but who cares
            scale = 2,
            properties = {
                object_Model = "objects/effects/beam_laser_02.cgf", -- better than the other one
            }, fMass = -1,
        })
        laser:SetScale(SEARCHLASER_SCALE) -- scale (!)LASER(!) before attaching!
        entity.SearchLaser = laser
        entity:AttachChild(laser.id, 8)
        laser:SetLocalPos({ x = 0, y = 0, z = 1.8 }) -- set (!)LASER(!) position after attaching!
    end
}


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
