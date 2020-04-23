local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local TheNet = GLOBAL.TheNet
local MOD_RPC = GLOBAL.MOD_RPC
local TheSim = GLOBAL.TheSim
local net_bool = GLOBAL.net_bool
local net_string = GLOBAL.net_string
local SpawnPrefab = GLOBAL.SpawnPrefab
local tonumber = GLOBAL.tonumber
local os = GLOBAL.os
local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

local ImageButton = require "widgets/imagebutton"
local containers = require("containers")
local io = GLOBAL.require("io")

local SellWidget = require("widgets/sellwidget")
local MyPopUp = require("widgets/mypopup")

Assets = {
    Asset("ATLAS", "images/shoppanel.xml"),
    Asset("IMAGE", "images/shoppanel.tex"),
}

--增加网络变量
for _, network_prefab in ipairs({"forest_network", "cave_network"}) do
    AddPrefabPostInit(network_prefab, function(inst)
        --放弃用网络变量触发自动同步事件
        --inst.shoplistschanged = net_bool(inst.GUID, "ShopListsChanged", "shoplistschanged")
        --inst.datachanged = net_bool(inst.GUID, "DataChanged", "datachanged")
        inst.databaseurl = net_string(inst.GUID, "DatabaseUrl", "databaseurlchanged")
    end)
end

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

local file, err = io.open("url.txt", "r")
local readtext
if not err then
    readtext = file:read() or ""
else
    readtext = ""
end
local destinyUrl = ByteToChar(readtext)

--添加RPC处理

AddModRPCHandler("shop", "sell", function(player, inst, itemvalue, ...)
    --冒险世界和探险大陆不能交易
    if GetModConfigData("adventure_world_limit") then
        --世界7和世界9是冒险和探险的ID
        if GLOBAL.TheShard:GetShardId() == "7" or GLOBAL.TheShard:GetShardId() == "9" then
            return
        end
    end

    local container = inst.components.container
    local item = container.slots[1]
    if not item then
        return
    end
    local itemprefabname = item.prefab
    local itemnum = item.components and item.components.stackable and item.components.stackable.stacksize or 1
    local itemowner = player.userid
    local itemstatus = item.components and (item.components.fueled and "fueled")
        or (item.components.finiteuses and "finiteuses") 
        or (item.components.perishable and "perishable") 
        or (item.components.armor and "armor") or "nil"
    local _itemstatusvalue = item.components and (item.components.fueled and item.components.fueled:GetPercent())
        or (item.components.finiteuses and item.components.finiteuses:GetPercent()) 
        or (item.components.perishable and item.components.perishable:GetPercent()) 
        or (item.components.armor and item.components.armor:GetPercent()) or 0
    local itemstatusvalue = math.floor(_itemstatusvalue * 100 + 0.5)
    local itemstackable = item.components and item.components.stackable and "true" or "false"
    local day = GLOBAL.TheWorld.state.cycles + 1 + GLOBAL.TheWorld.state.time - GLOBAL.TheWorld.state.time % 0.001
    local sellStringCombine = itemprefabname..","..itemnum..","..itemvalue..","..itemowner..","..itemstatus..","..itemstatusvalue..","..itemstackable..","..day
    --先删除物件以防止别人点击按钮后马上拿回去
    if item then
        item:Remove()
    end
    --执行访问网页
    local baseurl = destinyUrl.."/sell?sell="
    local combineurl = baseurl..sellStringCombine
    TheSim:QueryServer(combineurl,
    function(result, isSuccessful, resultCode)
        if isSuccessful and resultCode == 200 then
            --如果网页返回success 代表成功
            if string.find(result, "fail") then
                --如果库存满了 重新生成东西
                for i = 1, itemnum do
                    local spawnitem = SpawnPrefab(itemprefabname)
                    if itemstatus ~= "nil" then
                        spawnitem.components[itemstatus]:SetPercent(itemstatusvalue / 100)
                    end
                    container:GiveItem(spawnitem)
                end
            end
        else
            --如果访问失败 重新生成东西
            for i = 1, itemnum do
                local spawnitem = SpawnPrefab(itemprefabname)
                if itemstatus ~= "nil" then
                    spawnitem.components[itemstatus]:SetPercent(itemstatusvalue / 100)
                end
                container:GiveItem(spawnitem)
            end
        end
        --同步一下网络变量已触发客户端事件
        --暂时关闭买/卖时自动同步 因为可能引起卡顿
        --GLOBAL.TheWorld.net.shoplistschanged:set_local(true)
        --GLOBAL.TheWorld.net.shoplistschanged:set(true)
    end, "GET")
end)

AddModRPCHandler("shop", "buy", function(player, itemstring)
    --冒险世界和探险大陆不能交易
    if GetModConfigData("adventure_world_limit") then
        --世界7和世界9是冒险和探险的ID
        if GLOBAL.TheShard:GetShardId() == "7" or GLOBAL.TheShard:GetShardId() == "9" then
            return
        end
    end

    local iteminfo = TextToTable(itemstring)
    local itemprefabname = iteminfo[1]
    local itemnum = tonumber(iteminfo[2])
    local itemvalue = iteminfo[3]
    local itemowner = iteminfo[4]
    local itemstatus = iteminfo[5]
    local itemstatusvalue = tonumber(iteminfo[6])
    local itemstackable = iteminfo[7]
    local itemday = iteminfo[8]

    local function Give(player, itemprefabname, itemnum, itemstatus, itemstatusvalue)
        if not player then
            return
        end
        if player.components and player.components.inventory and not player:HasTag("playerghost") then
            --如果没有死亡就直接给
            for i = 1, itemnum do
                local spawnitem = SpawnPrefab(itemprefabname)
                if itemstatus ~= "nil" then
                    spawnitem.components[itemstatus]:SetPercent(itemstatusvalue / 100)
                end
                player.components.inventory:GiveItem(spawnitem)
            end
        else
            --如果死亡就直接放在地上
            local pos = Vector3(player.Transform:GetWorldPosition())
            local spawnitem = SpawnPrefab(itemprefabname)
            if itemstatus ~= "nil" then
                spawnitem.components[itemstatus]:SetPercent(itemstatusvalue / 100)
            end
            if itemnum > 1 then
                spawnitem.components.stackable.stacksize = itemnum
            end
            spawnitem.Transform:SetPosition(pos:Get())
        end
    end

    --执行访问网页 物品相关
    local worldday = GLOBAL.TheWorld.state.cycles + 1 + GLOBAL.TheWorld.state.time - GLOBAL.TheWorld.state.time % 0.001
    local playerNumInWorld = #GLOBAL.AllPlayers
    local baseurl = destinyUrl.."/buy?buy="
    local combineurl = baseurl..itemstring..","..player.userid..","..worldday..","..playerNumInWorld
    TheSim:QueryServer(combineurl,
    function(result, isSuccessful, resultCode)
        if isSuccessful and resultCode == 200 then
            --如果网页返回success 代表成功
            if string.find(result, "success") then
                Give(player, itemprefabname, itemnum, itemstatus, itemstatusvalue)
            end
        end
        --同步一下网络变量已触发客户端事件
        --暂时关闭买/卖时自动同步 因为可能引起卡顿
        --GLOBAL.TheWorld.net.shoplistschanged:set_local(true)
        --GLOBAL.TheWorld.net.shoplistschanged:set(true)
    end, "GET")
end)

--[[
AddModRPCHandler("shop", "update", function()
    --同步一下网络变量已触发客户端事件
    GLOBAL.TheWorld.net.datachanged:set_local(true)
    GLOBAL.TheWorld.net.datachanged:set(true)
end)]]

--构建出售界面的容器

local params = {}

local containers_widgetsetup_base = containers.widgetsetup
function containers.widgetsetup(container, prefab, data, ...)
    local t = params[prefab or container.inst.prefab]
    if t ~= nil then
        for k, v in pairs(t) do
            container[k] = v
        end
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
    else
        containers_widgetsetup_base(container, prefab, data, ...)
    end
end

params.shop =
{
    widget =
    {
        slotpos = {Vector3(0, 50, 0)},
        slotbg = {{atlas = "images/shoppanel.xml", image = "sell_slot_bg.tex"}},
        animbank = "ui_fish_box_3x4",
        animbuild = "ui_fish_box_3x4",
        pos = Vector3(0, 0, 0),
        buttoninfo = {
            text = "出售",
            position = Vector3(0, -100, 0),
        }
    },
    issidewidget = false,
    type = "shop",
}

--出售按钮的功能
function params.shop.widget.buttoninfo.fn(inst)
    if not GLOBAL.TheWorld.ismastersim then
        --判断是否为空
        if inst.replica.container:IsEmpty() then
           return 
        end
        --排除一些物品不能卖
        local item = inst.replica.container:GetItemInSlot(1)
        local excludeTagList = {"irreplaceable", "bundle"}
        local excludeNameList = {"sketch", "blueprint", "mapscroll", "lucy", "tacklesketch"}
        for k,v in pairs(excludeTagList) do
            if item:HasTag(v) then
                return
            end
        end
        for k,v in pairs(excludeNameList) do
            if item.prefab == v then
                return
            end
        end
        inst.replica.container:GetWidget().mypopup:Show()
    end
end

--服务端

if IsServer then

    --给实体增加容器组件和设定容器widget
    local function AddWidgetServerSide(inst)
        if not inst.components.container then
            inst:AddComponent("container")
            inst.components.container:WidgetSetup("shop")
        end
    end

    AddPrefabPostInit("researchlab4", AddWidgetServerSide)

    --把主机要访问的url传递给客机
    AddPrefabPostInit("world", function(inst)
        inst:DoTaskInTime(0, function()
            GLOBAL.TheWorld.net.databaseurl:set(readtext)
        end)
    end)

    --数据版本控制
    if not GLOBAL.TheShard:IsSlave() then
        AddPrefabPostInit("world", function(inst)
            inst:DoTaskInTime(0, function()
                local baseurl = destinyUrl.."/rollback?day="
                local worldday = GLOBAL.TheWorld.state.cycles + 1 + GLOBAL.TheWorld.state.time - GLOBAL.TheWorld.state.time % 0.001
                local combineurl = baseurl..worldday
                TheSim:QueryServer(combineurl,
                function(result, isSuccessful, resultCode)
                    if isSuccessful and resultCode == 200 then
                        if string.find(result, "ok") then
                            print("数据版本回溯：", worldday)
                        end
                    end
                end, "GET")
            end)
        end)
    end

    --冒险世界和探险大陆每天减金币
    if GetModConfigData("adventure_world_limit") then
        if GLOBAL.TheShard:GetShardId() == "7" or GLOBAL.TheShard:GetShardId() == "9" then
            AddPlayerPostInit(function(player)
                player:WatchWorldState("cycles", function()
                    local gameday = GLOBAL.TheWorld.state.cycles + 1 + GLOBAL.TheWorld.state.time - GLOBAL.TheWorld.state.time % 0.001
                    local combineurl = destinyUrl.."/adventure?userid="..player.userid.."&gameday="..gameday
                    TheSim:QueryServer(combineurl,
                    function(result, isSuccessful, resultCode)
                    --什么也不用做
                    end, "GET")
                end)
            end)
        end
    end

end

--客户端

if not IsServer then

    --给实体增加容器组件和设定容器widget
    local function AddWidgetClientSide(inst)
        inst:DoTaskInTime(0, function()
            if inst.replica then
                if inst.replica.container then
                    inst.replica.container:WidgetSetup("shop")
                    inst.replica.container.widget.isPopup = true
                end
            end
        end)
    end

    AddPrefabPostInit("researchlab4", AddWidgetClientSide)

    --出售弹窗UI
    AddClassPostConstruct("widgets/containerwidget", function(self)
        local _Open = self.Open
        self.Open = function(self, container, doer)
            _Open(self, container, doer)
            local widget = container.replica.container:GetWidget()
            if widget == nil or widget.isPopup == nil then
                return
            end
            widget.mypopup = self:AddChild(MyPopUp())
            widget.mypopup:Hide()
            --确认按钮功能
            widget.mypopup.ok:SetOnClick(
                function()
                    local itemvalue = tonumber(widget.mypopup.textinput:GetString()) or 1
                    SendModRPCToServer(MOD_RPC["shop"]["sell"], container, itemvalue)
                    widget.mypopup:Hide()
                end
            )
            --取消按钮功能
            widget.mypopup.close:SetOnClick(
                function()
                    widget.mypopup:Hide()
                end
            )
        end
    end)

    --购买界面UI
    AddClassPostConstruct("widgets/controls", function(self)

        --执行访问网页 物品相关 更新shoplists
        local databaseurl = GLOBAL.TheWorld.net.databaseurl:value()
        local databaseurl = ByteToChar(databaseurl)

        local function UpdatePanel()
            --执行访问网页 物品相关 更新shoplists
            local worldday = GLOBAL.TheWorld.state.cycles + 1 + GLOBAL.TheWorld.state.time - GLOBAL.TheWorld.state.time % 0.001
            local combineurl = databaseurl.."/update?worldday="..worldday
            TheSim:QueryServer(combineurl,
            function(shoplists, isSuccessful, resultCode)
                if isSuccessful  and resultCode == 200 then
                    --执行访问网页 金币相关 更新playermoney
                    if GLOBAL.ThePlayer and GLOBAL.ThePlayer.userid then
                        local gameday = GLOBAL.TheWorld.state.cycles + 1 + GLOBAL.TheWorld.state.time - GLOBAL.TheWorld.state.time % 0.001
                        local myurl = databaseurl.."/money?userid="..GLOBAL.ThePlayer.userid.."&gameday="..gameday
                        TheSim:QueryServer(myurl,
                        function(playermoney, isSuccessful, resultCode)
                            if isSuccessful and resultCode == 200 then
                                --修改玩家金币显示
                                if GLOBAL.ThePlayer and GLOBAL.ThePlayer.userid then
                                    local moneytable = TextToTable2(playermoney)
                                    local currentmoney = 0
                                    for k,v in pairs(moneytable) do
                                        if v[1] == GLOBAL.ThePlayer.userid then
                                            currentmoney = v[2]
                                        end
                                    end
                                    --下面3行修复金币显示n位小数 目前保留2位小数
                                    currentmoney = tonumber(currentmoney)
                                    currentmoney = currentmoney - currentmoney % 0.01
                                    currentmoney = string.format(currentmoney)
                                    --更新UI
                                    if self.sellwidget then
                                        self.sellwidget:Kill()
                                        self.sellwidget = nil
                                    end
                                    self.sellwidget = self.top_root:AddChild(SellWidget(shoplists))
                                    self.sellwidget:SetPosition(0, -700)
                                    self.sellwidget:SetScale(0.7)
                                    self.sellwidget.moneytext:SetString(currentmoney)
                                    self.sellwidget.closebutton:SetOnClick(
                                        function()
                                            self.sellwidget:Kill()
                                            self.sellwidget = nil
                                        end
                                    )
                                    self.sellwidget:Show()
                                end
                            end
                        end, "GET")
                    end
                end
            end, "GET")
        end

        --self.sellwidget = self.top_root:AddChild(SellWidget(GLOBAL.TheWorld.shoplists))
        --self.sellwidget:SetPosition(0, -700)
        --self.sellwidget:SetScale(0.7)
        --self.sellwidget:Hide()

        --触发开启商店的按钮
        self.trigerbutton = self.bottomright_root:AddChild(ImageButton("images/shoppanel.xml", "trigerbutton.tex"))
        self.trigerbutton:SetPosition(-150, 50, 0)
        self.trigerbutton:SetHoverText("交易站", {offset_y = -36, font_size = 16})
        self.trigerbutton:SetOnClick(
            function()
                if not (self.sellwidget and self.sellwidget.shown) then
                    UpdatePanel()
                end
            end
        )

        --按键盘开关猪猪币界面

        --此段代码来源于封锁 感谢封锁大佬
        local function AddComboKeyUpHandler(key_control_list, key_flag, fn)
            --检查是否在游戏画面内
            local function IsInGameScreen()
                if not GLOBAL.ThePlayer then return false end
                if not GLOBAL.ThePlayer.HUD then return false end
                local EndScreen = GLOBAL.TheFrontEnd:GetActiveScreen()
                if not EndScreen then return false end
                if not EndScreen.name then return false end
                if EndScreen.name ~= "HUD" then return false end
                return true
            end
            
            local function CheckKeyCombination(keycode)
                --检查功能键
                for index,each in pairs(key_control_list) do
                    if not GLOBAL.TheInput:IsKeyDown(each) then return end
                end
                --检查是否在游戏画面内
                if not IsInGameScreen() then return end
                fn()
            end
            GLOBAL.TheInput:AddKeyUpHandler(key_flag, CheckKeyCombination)
        end

        --LCtrl+X
        AddComboKeyUpHandler({306}, 120, function()
            if self.trigerbutton.shown then
                self.trigerbutton:Hide()
            else
                self.trigerbutton:Show()
            end
        end)

    end)

end