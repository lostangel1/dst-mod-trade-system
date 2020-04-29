local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local Text = require "widgets/text"

local defined_categories = require "category"

local function TextToTable(text)
    local resultStrList = {}
    if text then
        string.gsub(text, "[^,]+", function(w)
            table.insert(resultStrList, w)
        end)
    end
    return resultStrList
end

local function TextToTable2(text)
    local resultStrList = {}
    if text then
        string.gsub(text, '[^\n]+', function(w)
            local listInList = {}
            string.gsub(w, '[^,]+', function(v)
                table.insert(listInList, v)
            end)
            table.insert(resultStrList, listInList)
        end)
    end
    return resultStrList
end

local function ByteToChar(text)
    local result = ""
    local temptable = TextToTable(text)
    if temptable ~= {} then
        for k,v in pairs(temptable) do
            result = result..string.char(tonumber(v))
        end
    end
    return result
end

local function GetName(item)
    if string.find(item, "_spice_chili") then
        item = string.sub(item,1,-13)
        return "辣"..STRINGS.NAMES[string.upper(item)]
    elseif string.find(item, "_spice_garlic") then
        item = string.sub(item,1,-14)
        return "蒜香"..STRINGS.NAMES[string.upper(item)]
    elseif string.find(item, "_spice_salt") then
        item = string.sub(item,1,-12)
        return "咸"..STRINGS.NAMES[string.upper(item)]
    elseif string.find(item, "_spice_sugar") then
        item = string.sub(item,1,-13)
        return "甜"..STRINGS.NAMES[string.upper(item)]
    elseif string.find(item,"winter_ornament_light") then
        return "圣诞灯"
    elseif item == "wobster_sheller_land" then
        return STRINGS.NAMES[string.upper("wobster_sheller")]
    end
    return STRINGS.NAMES[string.upper(item)] or "神马东东"
end

local function ModifyPrefabName(name)
    --一些蔬菜
    local prefabNameToModify1 = {
        "tomato",
        "tomato_cooked",
        "garlic",
        "garlic_cooked",
        "potato",
        "potato_cooked",
        "onion",
        "onion_cooked",
    }
    for k,v in pairs(prefabNameToModify1) do
        if v == name then
            return "quagmire_"..name, ""
        end
    end

    --料理
    local prefabNameToModify2 = {
        "_spice_chili",
        "_spice_garlic",
        "_spice_salt",
        "_spice_sugar"
    }
    for k,v in pairs(prefabNameToModify2) do
        if string.find(name, v) then
            name = string.gsub(name, v, "")
            local spicename = string.sub(v, 2).."_over.tex"
            return name, spicename
        end
    end

    --贝壳
    if string.find(name, "singingshell_octave") then
        name = name.."_1"
    end

    --改石果的名字
    if name == "rock_avocado_fruit" then
        return "rock_avocado_fruit_rockhard", ""
    end

    return name, ""
end

local function IsInList(tbl, name)
    for k,v in pairs(tbl) do
        if v == name then
            return true
        end
    end
    return false
end

local SellWidget = Class(Widget, function(self, remotetext)
    Widget._ctor(self, "SellWidget")

    self.page_number = 1
    self.tableamounts = 1
    self.itemstring = nil
    self.categorypage = 1

    --定义sellwidget组
    self.sellwidget = self:AddChild(Widget("sellwidget"))
    self.sellwidget:SetPosition(0, 0)

    --背景
    self.mainbackground = self.sellwidget:AddChild(Image("images/shoppanel.xml", "shopbackground.tex"))
    self.mainbackground:SetPosition(0, 333)
    self.mainbackground:SetScale(1)

    --标题
    self.title = self.sellwidget:AddChild(Image("images/shoppanel.xml", "title.tex"))
    self.title:SetPosition(0, 725)
    self.title:SetScale(0.7)

    --生成5x5界面
    self:MakeFullListButton(self, remotetext)

    --分类

    local category_options = {"全部", "基础", "高级", "工具", "武器", "护甲", "衣帽", "食物", "其他"}

    self.category_list = self.sellwidget:AddChild(Widget("category_list"))
    self.category_list:SetPosition(10, 640) --100 640

    self.text_category_list_bg = self.category_list:AddChild(Image("images/frontend.xml", "char_shadow.tex"))
    self.text_category_list_bg:SetScale(0.5)

    self.text_category_list = self.category_list:AddChild(Text(DEFAULTFONT, 40, "全部"))
    self.text_category_list:SetPosition(4, 0)
    self.text_category_list:SetHoverText("分类切换", {offset_y = -36, font_size = 16})

    self.category_list_previous = self.category_list:AddChild(ImageButton("images/lobbyscreen.xml", "DSTMenu_PlayerLobby_arrow_paperHL_L.tex"))
    self.category_list_previous:SetPosition(-50, 0)
    self.category_list_previous:SetNormalScale(0.25)
    self.category_list_previous:SetFocusScale(0.275)
    self.category_list_previous:SetOnClick(
        function()
            self.categorypage = self.categorypage - 1 ~= 0 and self.categorypage - 1 or 9
            self.text_category_list:SetString(category_options[self.categorypage])
            self:MakeCategoryListButton(self, remotetext, self.categorypage)
            self.page_number = 1
            if self.pageindicator then
                self.pageindicator:SetString(self.page_number.."/"..self.tableamounts)
            end
        end
    )
    self.category_list_next = self.category_list:AddChild(ImageButton("images/lobbyscreen.xml", "DSTMenu_PlayerLobby_arrow_paperHL_R.tex"))
    self.category_list_next:SetPosition(50, 0)
    self.category_list_next:SetNormalScale(0.25)
    self.category_list_next:SetFocusScale(0.275)
    self.category_list_next:SetOnClick(
        function()
            self.categorypage = self.categorypage + 1 ~= 10 and self.categorypage + 1 or 1
            self.text_category_list:SetString(category_options[self.categorypage])
            self:MakeCategoryListButton(self, remotetext, self.categorypage)
            self.page_number = 1
            if self.pageindicator then
                self.pageindicator:SetString(self.page_number.."/"..self.tableamounts)
            end
        end
    )

    --切换全部和自己的库存的按钮和显示文字

    self.myselllist = self.sellwidget:AddChild(Widget("myselllist"))
    self.myselllist:SetPosition(160, 640) --100 640

    self.text_myselllist_bg = self.myselllist:AddChild(Image("images/frontend.xml", "char_shadow.tex"))
    self.text_myselllist_bg:SetScale(0.5)

    self.text_myselllist = self.myselllist:AddChild(Text(DEFAULTFONT, 40, "全部"))
    self.text_myselllist:SetPosition(4, 0)
    self.text_myselllist:SetHoverText("库存切换", {offset_y = -36, font_size = 16})

    self.myselllist_previous = self.myselllist:AddChild(ImageButton("images/lobbyscreen.xml", "DSTMenu_PlayerLobby_arrow_paperHL_L.tex"))
    self.myselllist_previous:SetPosition(-50, 0)
    self.myselllist_previous:SetNormalScale(0.25)
    self.myselllist_previous:SetFocusScale(0.275)
    self.myselllist_previous:SetOnClick(
        function()
            self.text_myselllist:SetString("全部")
            self:MakeFullListButton(self, remotetext)
            self.button_page:Show()
            self.page_number = 1
            if self.pageindicator then
                self.pageindicator:SetString(self.page_number.."/"..self.tableamounts)
            end
            --把分类按钮启用
            self.category_list:Enable()
            --分类按钮切回第一个选项卡 即“全部”选项
            if self.category_list then
                self.categorypage = 1
                self.text_category_list:SetString("全部")
            end
        end
    )
    self.myselllist_next = self.myselllist:AddChild(ImageButton("images/lobbyscreen.xml", "DSTMenu_PlayerLobby_arrow_paperHL_R.tex"))
    self.myselllist_next:SetPosition(50, 0)
    self.myselllist_next:SetNormalScale(0.25)
    self.myselllist_next:SetFocusScale(0.275)
    self.myselllist_next:SetOnClick(
        function()
            self.text_myselllist:SetString("我的")
            self:MakeOnesListButton(self, remotetext)
            self.button_page:Hide()
            --把分类按钮禁用
            self.category_list:Disable()
        end
    )

    --翻页按钮
    self.button_page = self.sellwidget:AddChild(Widget("button_page"))
    self.button_page:SetPosition(0, 0)
    --页数显示
    self.pageindicator = self.button_page:AddChild(Text(NUMBERFONT, 40, self.page_number.."/"..self.tableamounts)) --以1/3的形式显示页数
    self.pageindicator:SetPosition(0, 0)
    --上一页
    self.button_page_previous = self.button_page:AddChild(ImageButton("images/shoppanel.xml", "button_previous.tex"))
    self.button_page_previous:SetPosition(-230, 0)
    self.button_page_previous:SetNormalScale(1.3, 1.2)
    self.button_page_previous:SetFocusScale(1.41, 1.32)
    self.button_page_previous:SetOnClick(
        function()
            if self["shoplists"..self.page_number] ~= nil then
                self["shoplists"..self.page_number]:Hide()
            end
            self.page_number = self.page_number - 1 > 0 and self.page_number - 1 or self.tableamounts 
            if self["shoplists"..self.page_number] ~= nil then
                self["shoplists"..self.page_number]:Show()
            end
            self.pageindicator:SetString(self.page_number.."/"..self.tableamounts)
        end
    )
    --下一页
    self.button_page_next = self.button_page:AddChild(ImageButton("images/shoppanel.xml", "button_next.tex"))
    self.button_page_next:SetPosition(230, 0)
    self.button_page_next:SetNormalScale(1.3, 1.2)
    self.button_page_next:SetFocusScale(1.41, 1.32)
    self.button_page_next:SetOnClick(
        function()
            if self["shoplists"..self.page_number] ~= nil then
                self["shoplists"..self.page_number]:Hide()
            end
            self.page_number = self.page_number + 1 <= self.tableamounts and self.page_number + 1 or 1
            if self["shoplists"..self.page_number] ~= nil then
                self["shoplists"..self.page_number]:Show()
            end
            self.pageindicator:SetString(self.page_number.."/"..self.tableamounts)
        end
    )

    --显示金币 之前是用pigcoin图标 故取名
    self.pigcoin = self.sellwidget:AddChild(ImageButton("images/shoppanel.xml", "coin.tex"))
    self.pigcoin:SetPosition(-200, 637)
    self.pigcoin:SetScale(1)
    self.pigcoin:SetOnClick(
        function()
            if self.moneytext and ThePlayer then
                if self.moneytext:GetString() and self.moneytext:GetString() ~= "" then
                    if ThePlayer.coin_just_say == nil or (os.time() - ThePlayer.coin_just_say) > 5 then
                        TheNet:Say(STRINGS.LMB.." 我拥有 "..self.moneytext:GetString().." 个金币")
                        ThePlayer.coin_just_say = os.time()
                    end
                end
            end
        end
    )
    self.moneytext = self.sellwidget:AddChild(Text(NUMBERFONT, 40, ""))
    self.moneytext:SetPosition(-105, 637)
    self.moneytext:SetRegionSize(120,30)
    self.moneytext:SetHAlign(1) --ANCHOR_LEFT 详细见constant.lua

    --关闭按钮
    self.closebutton = self.sellwidget:AddChild(ImageButton("images/shoppanel.xml", "close.tex"))
    self.closebutton:SetPosition(260, 637)
    self.closebutton:SetScale(0.9)
    self.closebutton:SetHoverText("关闭", {offset_y = -36, font_size = 16})

    --购买确认弹窗

    self.sellpopup = self.sellwidget:AddChild(Widget("sellpopup"))
    self.sellpopup:SetPosition(0, 350)
    self.sellpopup:SetScale(1.5)

    self.sellpopup_bg = self.sellpopup:AddChild(Image("images/shoppanel.xml", "areyousure.tex"))

    self.sellpopup_text = self.sellpopup:AddChild(Text(DEFAULTFONT, 32, ""))
    self.sellpopup_text:SetPosition(0, -5)

    self.sellpopup_ok = self.sellpopup:AddChild(ImageButton("images/shoppanel.xml", "ok.tex"))
    self.sellpopup_ok:SetPosition(-80, -55)
    self.sellpopup_ok:SetOnClick(
        function()
            if self.itemstring then
                SendModRPCToServer(MOD_RPC["shop"]["buy"], self.itemstring)
                self.sellpopup:Hide()
                --self.myselllist:Enable()
            end
        end
    )

    self.sellpopup_close = self.sellpopup:AddChild(ImageButton("images/shoppanel.xml", "close.tex"))
    self.sellpopup_close:SetPosition(80, -55)
    self.sellpopup_close:SetOnClick(
        function()
            self.sellpopup:Hide()
            --self.myselllist:Enable()
        end
    )

    self.sellpopup:Hide()

    --提示窗口

    self.tipswidget = self.sellwidget:AddChild(Widget("tipswidget"))
    self.tipswidget:SetPosition(-700, 520)

    self.tipswidet_background = self.tipswidget:AddChild(Image("images/fepanels.xml", "wideframe.tex"))
    self.tipswidet_background:SetScale(0.6, 0.9)

    self.tipswidget_text = self.tipswidget:AddChild(Text(DEFAULTFONT, 40, ""))

    self.tipswidget:Hide()

    --提示按钮
    self.tips_button = self.sellwidget:AddChild(ImageButton("images/button_icons.xml", "info.tex"))
    self.tips_button:SetPosition(-260, 637)
    self.tips_button:SetScale(0.14)
    self.tips_button:SetHoverText("提示", {offset_y = -36, font_size = 16})
    self.tips_button:SetOnClick(
        function()
            if self.tipswidget.shown then
                self.tipswidget:Hide()
            else
                --设置提示文本
                local databaseurl = TheWorld.net.databaseurl:value()
                databaseurl = ByteToChar(databaseurl)
                TheSim:QueryServer(databaseurl.."/tips",
                function(result, isSuccessful, resultCode)
                    if isSuccessful and resultCode == 200 then
                        self.tipswidget_text:SetMultilineTruncatedString(result, 8, 450, 50, false, false)
                    end
                end, "GET")
                self.tipswidget:Show()
            end
        end
    )

    --每次进入游戏第一次打开UI通知
    self.server_notice = self.sellwidget:AddChild(Widget("server_notice"))
    self.server_notice:SetPosition(700, 520)
    self.server_notice_bg = self.server_notice:AddChild(Image("images/fepanels.xml", "wideframe.tex"))
    self.server_notice_bg:SetScale(0.6, 0.9)
    self.server_notice_text = self.server_notice:AddChild(Text(DEFAULTFONT, 40, ""))
    self.server_notice_ok = self.server_notice:AddChild(ImageButton("images/shoppanel.xml", "ok.tex"))
    self.server_notice_ok:SetPosition(0, -120)
    self.server_notice_ok:SetScale(0.8)
    self.server_notice_ok:SetOnClick(
        function()
            self.server_notice:Hide()
        end
    )
    self.server_notice:Hide()
end)

function SellWidget:MakeFullListButton(self, remotetext)
    if not remotetext then
        return
    end

    --先删除之前所有的按钮
    for i = 1, self.tableamounts do
        if self["shoplists"..i] ~= nil then
            self["shoplists"..i]:Kill()
            self["shoplists"..i] = nil
        end
    end

    --根据库存生成待售列表
    local shoplist = TextToTable2(remotetext)

    --动态生成待售列表的5x5界面
    local shoplistnum = #shoplist --总数
    local tablemod = math.mod(shoplistnum, 25) --余数
    self.tableamounts = (shoplistnum - tablemod) / 25 + 1 --要拆分成的列表数
    local shoplistsplit = {} -- 定义要拆分成的列表

    for i = 1, self.tableamounts do
        shoplistsplit[i] = {}
    end

    --拆分列表
    local index_1 = 1
    for k,v in ipairs(shoplist) do
        if #shoplistsplit[index_1] >= 25 then
            index_1 = index_1 + 1
        end
        table.insert(shoplistsplit[index_1], v)
    end

    --可能出现最后一个列表是空的情况，这一步用来忽略空的列表
    if #shoplistsplit[self.tableamounts] == 0 then
        self.tableamounts = math.max(self.tableamounts - 1, 1)
    end

    --生成5x5界面
    for i = 1, self.tableamounts do
        self["shoplists"..i] = self.sellwidget:AddChild(Widget("shoplists"..i))
        local count = 1
        for y = 5, 1, -1 do
            for x = 1, 5 do
                if shoplistsplit[i][count] then
                    local itemprefabname = shoplistsplit[i][count][1]
                    local itemnum = shoplistsplit[i][count][2]
                    local itemvalue = shoplistsplit[i][count][3]
                    local itemowner = shoplistsplit[i][count][4]
                    local itemstatus = shoplistsplit[i][count][5]
                    local itemstatusvalue = shoplistsplit[i][count][6]
                    local itemstackable = shoplistsplit[i][count][7]
                    local itemday = shoplistsplit[i][count][8]
                    local itemstring = itemprefabname..","..itemnum..","..itemvalue..","..itemowner..","..itemstatus..","..itemstatusvalue..","..itemstackable..","..itemday
                    --定义每个格子
                    local buttonname = "shoplists"..i.."item"..count
                    self[buttonname] = self["shoplists"..i]:AddChild(Widget(buttonname))
                    self[buttonname]:SetPosition(x * 102 - 310, y * 102)
                    --每个格子的背景图
                    self[buttonname.."bg"] = self[buttonname]:AddChild(Image("images/shoppanel.xml", "buy_slot_bg.tex"))
                    --每个格子的物品图
                    local _itemprefabname, spicename = ModifyPrefabName(itemprefabname)
                    if spicename ~= "" then --附上料理的食物设置
                        self[buttonname.."prefabspice"] = self[buttonname]:AddChild(Image(GetInventoryItemAtlas(spicename), spicename))
                        self[buttonname.."prefabspice"]:SetPosition(40, -20)
                    end
                    self[buttonname.."prefab"] = self[buttonname]:AddChild(ImageButton(GetInventoryItemAtlas(_itemprefabname..".tex"), _itemprefabname..".tex"))
                    self[buttonname.."prefab"]:SetNormalScale(1)
                    self[buttonname.."prefab"]:SetFocusScale(1.2)
                    self[buttonname.."prefab"]:SetOnClick(
                        function() --每个物品按钮的触发函数
                            self[buttonname]:Hide()
                            self.myselllist:Disable()
                            self.itemstring = itemstring
                            self.sellpopup_text:SetString(GetName(itemprefabname).."x"..itemnum.." 金币x"..itemvalue)
                            self.sellpopup:Show()
                            self.sellpopup:MoveToFront()
                        end
                    )
                    --每个格子物品数量显示
                    if itemstackable == "true" then
                        self[buttonname.."num"] = self[buttonname]:AddChild(Text(NUMBERFONT, 43, itemnum))
                        self[buttonname.."num"]:SetPosition(0, 20)
                    end
                    --每个格子物品价格显示
                    self[buttonname.."value"] = self[buttonname]:AddChild(Text(NUMBERFONT, 35, itemvalue))
                    self[buttonname.."value"]:SetPosition(0, -36)
                    self[buttonname.."value"]:SetRegionSize(50,30)
                    self[buttonname.."value"]:SetHAlign(1) --ANCHOR_LEFT 详细见constant.lua
                    --每个格子品耐久或保险度显示
                    if itemstatus ~= "nil" then
                        local itemstatus_text = itemstatus == "perishable" and "保鲜度" or "耐久"
                        self[buttonname.."prefab"]:SetHoverText(itemstatus_text..itemstatusvalue.."%", {offset_y = -36, font_size = 16})
                    end
                end
                count = count + 1
            end
        end
    end

    --除了了一个列表以外，其他都隐藏
    if self.tableamounts >=2 then
        for i = 2, self.tableamounts do
            self["shoplists"..i]:Hide()
        end
    end
end

function SellWidget:MakeOnesListButton(self, remotetext)
    if not remotetext then
        return
    end

    --先删除之前所有的按钮
    for i = 1, self.tableamounts do
        if self["shoplists"..i] ~= nil then
            self["shoplists"..i]:Kill()
            self["shoplists"..i] = nil
        end
    end

    --根据库存生成待售列表
    local _shoplist = TextToTable2(remotetext)
    local shoplist = {}

    --保留是自己userid的列表 别的都删除
    for k,v in pairs(_shoplist) do
        if v[4] == ThePlayer.userid then
            table.insert(shoplist, v)
        end
    end

    --动态生成待售列表的5x5界面
    local shoplistnum = #shoplist --总数
    local tablemod = math.mod(shoplistnum, 25) --余数
    self.tableamounts = (shoplistnum - tablemod) / 25 + 1 --要拆分成的列表数
    local shoplistsplit = {} -- 定义要拆分成的列表

    for i = 1, self.tableamounts do
        shoplistsplit[i] = {}
    end

    --拆分列表
    local index_1 = 1
    for k,v in ipairs(shoplist) do
        if #shoplistsplit[index_1] >= 25 then
            index_1 = index_1 + 1
        end
        table.insert(shoplistsplit[index_1], v)
    end

    --可能出现最后一个列表是空的情况，这一步用来忽略空的列表
    if #shoplistsplit[self.tableamounts] == 0 then
        self.tableamounts = math.max(self.tableamounts - 1, 1)
    end

    --生成5x5界面
    for i = 1, self.tableamounts do
        self["shoplists"..i] = self.sellwidget:AddChild(Widget("shoplists"..i))
        local count = 1
        for y = 5, 1, -1 do
            for x = 1, 5 do
                if shoplistsplit[i][count] then
                    local itemprefabname = shoplistsplit[i][count][1]
                    local itemnum = shoplistsplit[i][count][2]
                    local itemvalue = shoplistsplit[i][count][3]
                    local itemowner = shoplistsplit[i][count][4]
                    local itemstatus = shoplistsplit[i][count][5]
                    local itemstatusvalue = shoplistsplit[i][count][6]
                    local itemstackable = shoplistsplit[i][count][7]
                    local itemday = shoplistsplit[i][count][8]
                    local itemstring = itemprefabname..","..itemnum..","..itemvalue..","..itemowner..","..itemstatus..","..itemstatusvalue..","..itemstackable..","..itemday
                    --定义每个格子
                    local buttonname = "shoplists"..i.."item"..count
                    self[buttonname] = self["shoplists"..i]:AddChild(Widget(buttonname))
                    self[buttonname]:SetPosition(x * 102 - 310, y * 102)
                    --每个格子的背景图
                    self[buttonname.."bg"] = self[buttonname]:AddChild(Image("images/shoppanel.xml", "ones_slot_bg.tex"))
                    --每个格子的物品图
                    local _itemprefabname, spicename = ModifyPrefabName(itemprefabname)
                    if spicename ~= "" then --附上料理的食物设置
                        print(spicename)
                        self[buttonname.."prefabspice"] = self[buttonname]:AddChild(Image(GetInventoryItemAtlas(spicename), spicename))
                        self[buttonname.."prefabspice"]:SetPosition(40, -20)
                    end
                    self[buttonname.."prefab"] = self[buttonname]:AddChild(ImageButton(GetInventoryItemAtlas(_itemprefabname..".tex"), _itemprefabname..".tex"))
                    self[buttonname.."prefab"]:SetNormalScale(1)
                    self[buttonname.."prefab"]:SetFocusScale(1.2)
                    self[buttonname.."prefab"]:SetOnClick(
                        function() --每个物品按钮的触发函数
                            self[buttonname]:Hide()
                            self.myselllist:Disable()
                            self.itemstring = itemstring
                            self.sellpopup_text:SetString("取回"..GetName(itemprefabname))
                            self.sellpopup:Show()
                            self.sellpopup:MoveToFront()
                        end
                    )
                    --每个格子物品数量显示
                    if itemstackable == "true" then
                        self[buttonname.."num"] = self[buttonname]:AddChild(Text(NUMBERFONT, 43, itemnum))
                        self[buttonname.."num"]:SetPosition(0, 20)
                    end
                    --每个格子物品价格显示
                    self[buttonname.."value"] = self[buttonname]:AddChild(Text(NUMBERFONT, 35, itemvalue))
                    self[buttonname.."value"]:SetPosition(0, -36)
                    self[buttonname.."value"]:SetRegionSize(50,30)
                    self[buttonname.."value"]:SetHAlign(1) --ANCHOR_LEFT 详细见constant.lua
                    --每个格子品显示物品挂上去的时间
                    itemday = math.floor(tonumber(itemday) + 0.5)
                    self[buttonname.."prefab"]:SetHoverText("上架时间 第"..itemday.."天", {offset_y = -36, font_size = 16})
                end
                count = count + 1
            end
        end
    end

    --除了了一个列表以外，其他都隐藏
    if self.tableamounts >=2 then
        for i = 2, self.tableamounts do
            self["shoplists"..i]:Hide()
        end
    end
end

function SellWidget:MakeCategoryListButton(self, remotetext, cat)
    if not remotetext then
        return
    end

    --如果cat是1说明是全部 就调用MakeFullListButton
    if cat == 1 then
        self:MakeFullListButton(self, remotetext)
        return
    end

    --先删除之前所有的按钮
    for i = 1, self.tableamounts do
        if self["shoplists"..i] ~= nil then
            self["shoplists"..i]:Kill()
            self["shoplists"..i] = nil
        end
    end

    --根据库存生成待售列表
    local _shoplist = TextToTable2(remotetext)
    local shoplist = {}

    --根据分类保留
    if cat ~= 9 then -- 如果不是其他分类
        for k,v in pairs(_shoplist) do
            local realname = ModifyPrefabName(v[1])
            if IsInList(defined_categories[cat], realname) then
                table.insert(shoplist, v)
            end
        end
    else
        for k,v in pairs(_shoplist) do
            local isfind = false
            local realname = ModifyPrefabName(v[1])
            for i,j in pairs(defined_categories) do
                if IsInList(j, realname) then
                    isfind = true
                end
            end
            if not isfind then
                table.insert(shoplist, v)
            end
        end
    end

    --动态生成待售列表的5x5界面
    local shoplistnum = #shoplist --总数
    local tablemod = math.mod(shoplistnum, 25) --余数
    self.tableamounts = (shoplistnum - tablemod) / 25 + 1 --要拆分成的列表数
    local shoplistsplit = {} -- 定义要拆分成的列表

    for i = 1, self.tableamounts do
        shoplistsplit[i] = {}
    end

    --拆分列表
    local index_1 = 1
    for k,v in ipairs(shoplist) do
        if #shoplistsplit[index_1] >= 25 then
            index_1 = index_1 + 1
        end
        table.insert(shoplistsplit[index_1], v)
    end

    --可能出现最后一个列表是空的情况，这一步用来忽略空的列表
    if #shoplistsplit[self.tableamounts] == 0 then
        self.tableamounts = math.max(self.tableamounts - 1, 1)
    end

    --生成5x5界面
    for i = 1, self.tableamounts do
        self["shoplists"..i] = self.sellwidget:AddChild(Widget("shoplists"..i))
        local count = 1
        for y = 5, 1, -1 do
            for x = 1, 5 do
                if shoplistsplit[i][count] then
                    local itemprefabname = shoplistsplit[i][count][1]
                    local itemnum = shoplistsplit[i][count][2]
                    local itemvalue = shoplistsplit[i][count][3]
                    local itemowner = shoplistsplit[i][count][4]
                    local itemstatus = shoplistsplit[i][count][5]
                    local itemstatusvalue = shoplistsplit[i][count][6]
                    local itemstackable = shoplistsplit[i][count][7]
                    local itemday = shoplistsplit[i][count][8]
                    local itemstring = itemprefabname..","..itemnum..","..itemvalue..","..itemowner..","..itemstatus..","..itemstatusvalue..","..itemstackable..","..itemday
                    --定义每个格子
                    local buttonname = "shoplists"..i.."item"..count
                    self[buttonname] = self["shoplists"..i]:AddChild(Widget(buttonname))
                    self[buttonname]:SetPosition(x * 102 - 310, y * 102)
                    --每个格子的背景图
                    self[buttonname.."bg"] = self[buttonname]:AddChild(Image("images/shoppanel.xml", "buy_slot_bg.tex"))
                    --每个格子的物品图
                    local _itemprefabname, spicename = ModifyPrefabName(itemprefabname)
                    if spicename ~= "" then --附上料理的食物设置
                        self[buttonname.."prefabspice"] = self[buttonname]:AddChild(Image(GetInventoryItemAtlas(spicename), spicename))
                        self[buttonname.."prefabspice"]:SetPosition(40, -20)
                    end
                    self[buttonname.."prefab"] = self[buttonname]:AddChild(ImageButton(GetInventoryItemAtlas(_itemprefabname..".tex"), _itemprefabname..".tex"))
                    self[buttonname.."prefab"]:SetNormalScale(1)
                    self[buttonname.."prefab"]:SetFocusScale(1.2)
                    self[buttonname.."prefab"]:SetOnClick(
                        function() --每个物品按钮的触发函数
                            self[buttonname]:Hide()
                            self.myselllist:Disable()
                            self.itemstring = itemstring
                            self.sellpopup_text:SetString(GetName(itemprefabname).."x"..itemnum.." 金币x"..itemvalue)
                            self.sellpopup:Show()
                            self.sellpopup:MoveToFront()
                        end
                    )
                    --每个格子物品数量显示
                    if itemstackable == "true" then
                        self[buttonname.."num"] = self[buttonname]:AddChild(Text(NUMBERFONT, 43, itemnum))
                        self[buttonname.."num"]:SetPosition(0, 20)
                    end
                    --每个格子物品价格显示
                    self[buttonname.."value"] = self[buttonname]:AddChild(Text(NUMBERFONT, 35, itemvalue))
                    self[buttonname.."value"]:SetPosition(0, -36)
                    self[buttonname.."value"]:SetRegionSize(50,30)
                    self[buttonname.."value"]:SetHAlign(1) --ANCHOR_LEFT 详细见constant.lua
                    --每个格子品耐久或保险度显示
                    if itemstatus ~= "nil" then
                        local itemstatus_text = itemstatus == "perishable" and "保鲜度" or "耐久"
                        self[buttonname.."prefab"]:SetHoverText(itemstatus_text..itemstatusvalue.."%", {offset_y = -36, font_size = 16})
                    end
                end
                count = count + 1
            end
        end
    end

    --除了了一个列表以外，其他都隐藏
    if self.tableamounts >=2 then
        for i = 2, self.tableamounts do
            self["shoplists"..i]:Hide()
        end
    end
end

return SellWidget