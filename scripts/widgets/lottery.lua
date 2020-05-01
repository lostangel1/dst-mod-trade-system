local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local TextEdit = require "widgets/textedit"
local Text = require "widgets/text"
--local TemplateLottery = require "widgets/templatelottery"

local TemplateLottery = Class(Widget, function(self)
    Widget._ctor(self, "TemplateLottery")

    self.main = self:AddChild(Widget("main"))

    --输入框1 百位
    self.select_1_bg = self.main:AddChild(Image("images/shoppanel.xml", "lottery_select_bg.tex"))
    self.select_1_bg:SetScale(0.7)
    self.select_1_bg:SetPosition(-170, 0)
    self.select_1_text = self.select_1_bg:AddChild(TextEdit(NUMBERFONT, 64, ""))
    self.select_1_text:SetColour(unpack(WHITE))
    self.select_1_text.edit_text_color = WHITE
    self.select_1_text.idle_text_color = WHITE
    self.select_1_text:SetEditCursorColour(unpack(WHITE))
    self.select_1_text:SetForceEdit(true)
    self.select_1_text:SetRegionSize(50, 50)
    self.select_1_text:SetTextLengthLimit(1)
    self.select_1_text:SetCharacterFilter("1234567890")
    self.select_1_text:SetHoverText("百位", {offset_y = -36, font_size = 16})

    --输入框2 十位
    self.select_2_bg = self.main:AddChild(Image("images/shoppanel.xml", "lottery_select_bg.tex"))
    self.select_2_bg:SetScale(0.7)
    self.select_2_bg:SetPosition(-110, 0)
    self.select_2_text = self.select_2_bg:AddChild(TextEdit(NUMBERFONT, 64, ""))
    self.select_2_text:SetColour(unpack(WHITE))
    self.select_2_text.edit_text_color = WHITE
    self.select_2_text.idle_text_color = WHITE
    self.select_2_text:SetEditCursorColour(unpack(WHITE))
    self.select_2_text:SetForceEdit(true)
    self.select_2_text:SetRegionSize(50, 50)
    self.select_2_text:SetTextLengthLimit(1)
    self.select_2_text:SetCharacterFilter("1234567890")
    self.select_2_text:SetHoverText("十位", {offset_y = -36, font_size = 16})

    --输入框3 个位
    self.select_3_bg = self.main:AddChild(Image("images/shoppanel.xml", "lottery_select_bg.tex"))
    self.select_3_bg:SetScale(0.7)
    self.select_3_bg:SetPosition(-50, 0)
    self.select_3_text = self.select_3_bg:AddChild(TextEdit(NUMBERFONT, 64, ""))
    self.select_3_text:SetColour(unpack(WHITE))
    self.select_3_text.edit_text_color = WHITE
    self.select_3_text.idle_text_color = WHITE
    self.select_3_text:SetEditCursorColour(unpack(WHITE))
    self.select_3_text:SetForceEdit(true)
    self.select_3_text:SetRegionSize(50, 50)
    self.select_3_text:SetTextLengthLimit(1)
    self.select_3_text:SetCharacterFilter("1234567890")
    self.select_3_text:SetHoverText("个位", {offset_y = -36, font_size = 16})

    --输入框4 数量
    self.select_4_bg = self.main:AddChild(Image("images/shoppanel.xml", "lottery_select_bg.tex"))
    self.select_4_bg:SetScale(0.7)
    self.select_4_bg:SetPosition(25, 0)
    self.select_4_text = self.select_4_bg:AddChild(TextEdit(NUMBERFONT, 64, ""))
    self.select_4_text:SetColour(unpack(WHITE))
    self.select_4_text.edit_text_color = WHITE
    self.select_4_text.idle_text_color = WHITE
    self.select_4_text:SetEditCursorColour(unpack(WHITE))
    self.select_4_text:SetForceEdit(true)
    self.select_4_text:SetRegionSize(50, 50)
    self.select_4_text:SetTextLengthLimit(1)
    self.select_4_text:SetCharacterFilter("123456789")
    self.select_4_text:SetHoverText("数量", {offset_y = -36, font_size = 16})

    --购买
    self.buy = self.main:AddChild(ImageButton("images/button_icons.xml", "apply_skins.tex"))
    self.buy:SetScale(0.2)
    self.buy:SetPosition(110, 0)
    self.buy:SetHoverText("购买", {offset_y = -36, font_size = 16})

    --兑奖
    self.check = self.main:AddChild(ImageButton("images/button_icons.xml", "more_games.tex"))
    self.check:SetScale(0.2)
    self.check:SetPosition(170, 0)
    self.check:SetHoverText("兑奖", {offset_y = -36, font_size = 16})
end)

local Lottery = Class(Widget, function(self, numbers, databaseurl)
    Widget._ctor(self, "Lottery")

    self.lottery_num = ""
    self.slot = ""

    --定义main组
    self.main = self:AddChild(Widget("main"))
    self.main:SetPosition(0, -5)

    --背景
    self.mainbackground = self.main:AddChild(Image("images/shoppanel.xml", "lottery_bg.tex"))
    self.mainbackground:SetPosition(0, 410)
    self.mainbackground:SetScale(1.1)

    --第一组彩票
    self.lottery1 = self.main:AddChild(TemplateLottery("lottery1"))
    self.lottery1:SetPosition(5, 470)
    if string.sub(numbers, 4, 4) ~= "0" then
        self.lottery1.select_1_text:SetString(string.sub(numbers, 1, 1))
        self.lottery1.select_2_text:SetString(string.sub(numbers, 2, 2))
        self.lottery1.select_3_text:SetString(string.sub(numbers, 3, 3))
        self.lottery1.select_4_text:SetString(string.sub(numbers, 4, 4))
    end
    self.lottery1.buy:SetOnClick(
        function()
            self.lottery_num = self.lottery1.select_1_text:GetString()..self.lottery1.select_2_text:GetString()..self.lottery1.select_3_text:GetString()..self.lottery1.select_4_text:GetString()
            self.slot = "slot1"
            --四个格子不完整就不触发弹窗
            if #self.lottery_num < 4 then
                return
            end 
            if self.popup and not self.popup.shown then
                local cost = tonumber(string.sub(self.lottery_num,4,4)) * 5
                self.popup_text:SetString("号码"..string.sub(self.lottery_num,1,3).." 数量"..string.sub(self.lottery_num,4,4).."\n需要"..cost.."金币")
                self.popup:Show()
            end
        end
    )
    self.lottery1.check:SetOnClick(
        function()
            self.lottery_num = self.lottery1.select_1_text:GetString()..self.lottery1.select_2_text:GetString()..self.lottery1.select_3_text:GetString()..self.lottery1.select_4_text:GetString()
            --四个格子不完整就不触发弹窗
            if #self.lottery_num < 4 then
                return
            end 
            if ThePlayer then
                local gameday = TheWorld.state.cycles + 1 + TheWorld.state.time - TheWorld.state.time % 0.001
                local combineurl = databaseurl.."/checklottery?userid="..ThePlayer.userid.."&gameday="..gameday.."&slot=slot1"
                TheSim:QueryServer(combineurl,
                function(result, isSuccessful, resultCode)
                    if isSuccessful and resultCode == 200 then
                        if self.resultpop then
                            self.resultpop_text:SetString(result)
                            self.resultpop:Show()
                        end
                    end
                end, "GET")
            end
        end
    )

    --第二组彩票
    self.lottery2 = self.main:AddChild(TemplateLottery("lottery1"))
    self.lottery2:SetPosition(5, 390)
    if string.sub(numbers, 8, 8) ~= "0" then
        self.lottery2.select_1_text:SetString(string.sub(numbers, 5, 5))
        self.lottery2.select_2_text:SetString(string.sub(numbers, 6, 6))
        self.lottery2.select_3_text:SetString(string.sub(numbers, 7, 7))
        self.lottery2.select_4_text:SetString(string.sub(numbers, 8, 8))
    end
    self.lottery2.buy:SetOnClick(
        function()
            self.lottery_num = self.lottery2.select_1_text:GetString()..self.lottery2.select_2_text:GetString()..self.lottery2.select_3_text:GetString()..self.lottery2.select_4_text:GetString()
            self.slot = "slot2"
            --四个格子不完整就不触发弹窗
            if #self.lottery_num < 4 then
                return
            end 
            if self.popup and not self.popup.shown then
                local cost = tonumber(string.sub(self.lottery_num,4,4)) * 5
                self.popup_text:SetString("号码"..string.sub(self.lottery_num,1,3).." 数量"..string.sub(self.lottery_num,4,4).."\n需要"..cost.."金币")
                self.popup:Show()
            end
        end
    )
    self.lottery2.check:SetOnClick(
        function()
            self.lottery_num = self.lottery2.select_1_text:GetString()..self.lottery2.select_2_text:GetString()..self.lottery2.select_3_text:GetString()..self.lottery2.select_4_text:GetString()
            --四个格子不完整就不触发弹窗
            if #self.lottery_num < 4 then
                return
            end 
            if ThePlayer then
                local gameday = TheWorld.state.cycles + 1 + TheWorld.state.time - TheWorld.state.time % 0.001
                local combineurl = databaseurl.."/checklottery?userid="..ThePlayer.userid.."&gameday="..gameday.."&slot=slot2"
                TheSim:QueryServer(combineurl,
                function(result, isSuccessful, resultCode)
                    if isSuccessful and resultCode == 200 then
                        if self.resultpop then
                            self.resultpop_text:SetString(result)
                            self.resultpop:Show()
                        end
                    end
                end, "GET")
            end
        end
    )

    --第三组彩票
    self.lottery3 = self.main:AddChild(TemplateLottery("lottery1"))
    self.lottery3:SetPosition(5, 310)
    if string.sub(numbers, 12, 12) ~= "0" then
        self.lottery3.select_1_text:SetString(string.sub(numbers, 9, 9))
        self.lottery3.select_2_text:SetString(string.sub(numbers, 10, 10))
        self.lottery3.select_3_text:SetString(string.sub(numbers, 11, 11))
        self.lottery3.select_4_text:SetString(string.sub(numbers, 12, 12))
    end
    self.lottery3.buy:SetOnClick(
        function()
            self.lottery_num = self.lottery3.select_1_text:GetString()..self.lottery3.select_2_text:GetString()..self.lottery3.select_3_text:GetString()..self.lottery3.select_4_text:GetString()
            self.slot = "slot3"
            --四个格子不完整就不触发弹窗
            if #self.lottery_num < 4 then
                return
            end 
            if self.popup and not self.popup.shown then
                local cost = tonumber(string.sub(self.lottery_num,4,4)) * 5
                self.popup_text:SetString("号码"..string.sub(self.lottery_num,1,3).." 数量"..string.sub(self.lottery_num,4,4).."\n需要"..cost.."金币")
                self.popup:Show()
            end
        end
    )
    self.lottery3.check:SetOnClick(
        function()
            self.lottery_num = self.lottery3.select_1_text:GetString()..self.lottery3.select_2_text:GetString()..self.lottery3.select_3_text:GetString()..self.lottery3.select_4_text:GetString()
            --四个格子不完整就不触发弹窗
            if #self.lottery_num < 4 then
                return
            end 
            if ThePlayer then
                local gameday = TheWorld.state.cycles + 1 + TheWorld.state.time - TheWorld.state.time % 0.001
                local combineurl = databaseurl.."/checklottery?userid="..ThePlayer.userid.."&gameday="..gameday.."&slot=slot3"
                TheSim:QueryServer(combineurl,
                function(result, isSuccessful, resultCode)
                    if isSuccessful and resultCode == 200 then
                        if self.resultpop then
                            self.resultpop_text:SetString(result)
                            self.resultpop:Show()
                        end
                    end
                end, "GET")
            end
        end
    )

    --关闭按钮
    self.closebutton = self.main:AddChild(ImageButton("images/shoppanel.xml", "close.tex"))
    self.closebutton:SetPosition(220, 540)
    self.closebutton:SetScale(0.9)
    self.closebutton:SetHoverText("关闭", {offset_y = -36, font_size = 16})

    --确认购买弹窗
    self.popup = self.main:AddChild(Widget("popup"))
    self.popup:SetPosition(0, 400)
    self.popup_bg = self.popup:AddChild(Image("images/shoppanel.xml", "commonpop.tex"))
    self.popup_bg:SetScale(0.7)
    self.popup_text = self.popup:AddChild(Text(DEFAULTFONT, 40, ""))
    self.popup_text:SetPosition(0, 15)
    self.popup_ok = self.popup:AddChild(ImageButton("images/shoppanel.xml", "ok.tex"))
    self.popup_ok:SetPosition(-60, -30)
    self.popup_ok:SetScale(0.8)
    self.popup_ok:SetOnClick(
        function()
            if ThePlayer then
                local gameday = TheWorld.state.cycles + 1 + TheWorld.state.time - TheWorld.state.time % 0.001
                local combineurl = databaseurl.."/buylottery?userid="..ThePlayer.userid.."&gameday="..gameday.."&slot="..self.slot.."&lottery_num="..self.lottery_num
                TheSim:QueryServer(combineurl,
                function(result, isSuccessful, resultCode)
                    if isSuccessful and resultCode == 200 then
                        self.popup:Hide()
                        if self.resultpop and not self.resultpop.shown then
                            self.resultpop_text:SetString(result)
                            self.resultpop:Show()
                        end
                    end
                end, "GET")
            end
        end
    )
    self.popup_close = self.popup:AddChild(ImageButton("images/shoppanel.xml", "close.tex"))
    self.popup_close:SetPosition(60, -30)
    self.popup_close:SetScale(0.8)
    self.popup_close:SetOnClick(
        function()
            self.popup:Hide()
        end
    )
    self.popup:Hide()

    --购买结果/彩票结果弹窗
    self.resultpop = self.main:AddChild(Widget("resultpop"))
    self.resultpop:SetPosition(0, 400)
    self.resultpop_bg = self.resultpop:AddChild(Image("images/shoppanel.xml", "commonpop.tex"))
    self.resultpop_bg:SetScale(0.7)
    self.resultpop_text = self.resultpop:AddChild(Text(DEFAULTFONT, 40, ""))
    self.resultpop_text:SetPosition(0, 15)
    self.resultpop_ok = self.resultpop:AddChild(ImageButton("images/shoppanel.xml", "ok.tex"))
    self.resultpop_ok:SetPosition(0, -30)
    self.resultpop_ok:SetOnClick(
        function()
            self.resultpop:Hide()
        end
    )
    self.resultpop:Hide()

    --提示窗口
    self.tipswidget = self.main:AddChild(Widget("tipswidget"))
    self.tipswidget:SetPosition(-550, 450)
    self.tipswidget:SetScale(1)
    self.tipswidet_background = self.tipswidget:AddChild(Image("images/fepanels.xml", "wideframe.tex"))
    self.tipswidet_background:SetScale(0.6, 0.6)
    self.tipswidget_text = self.tipswidget:AddChild(Text(DEFAULTFONT, 40, ""))
    self.tipswidget:Hide()

    --提示按钮
    self.tips_button = self.main:AddChild(ImageButton("images/button_icons.xml", "info.tex"))
    self.tips_button:SetPosition(-220, 540)
    self.tips_button:SetScale(0.14)
    self.tips_button:SetHoverText("提示", {offset_y = -36, font_size = 16})
    self.tips_button:SetOnClick(
        function()
            if self.tipswidget.shown then
                self.tipswidget:Hide()
            else
                --设置提示文本
                TheSim:QueryServer(databaseurl.."/lotterytips",
                function(result, isSuccessful, resultCode)
                    if isSuccessful and resultCode == 200 then
                        self.tipswidget_text:SetMultilineTruncatedString(result, 8, 420, 50, false, false)
                    end
                end, "GET")
                self.tipswidget:Show()
            end
        end
    )

    --显示金币 之前是用pigcoin图标 故取名
    self.pigcoin = self.main:AddChild(ImageButton("images/shoppanel.xml", "coin.tex"))
    self.pigcoin:SetPosition(-200+150, 540)
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
    self.moneytext = self.main:AddChild(Text(NUMBERFONT, 40, ""))
    self.moneytext:SetPosition(-105+150, 540)
    self.moneytext:SetRegionSize(120,30)
    self.moneytext:SetHAlign(1) --ANCHOR_LEFT 详细见constant.lua
end)

return Lottery