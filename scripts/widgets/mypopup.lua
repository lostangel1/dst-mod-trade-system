local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local TextEdit = require "widgets/textedit"

local mypopup = Class(Widget, function(self, remotetext)
    Widget._ctor(self, "mypopup")

    self.page_number = 1

    --定义mypopup组
    self.mypopup = self:AddChild(Widget("mypopup"))
    self.mypopup:SetPosition(0, -5)
    self.mypopup:SetScale(1.5)

    --背景
    self.bg = self.mypopup:AddChild(Image("images/shoppanel.xml", "areyousure.tex"))
    self.bg:SetPosition(0, 0)
    self.bg:SetScale(1)

    --确认按钮
    self.ok = self.mypopup:AddChild(ImageButton("images/shoppanel.xml", "ok.tex"))
    self.ok:SetPosition(-80, -55)

    --关闭按钮
    self.close = self.mypopup:AddChild(ImageButton("images/shoppanel.xml", "close.tex"))
    self.close:SetPosition(80, -55)

    --金币图标
    self.coin = self.mypopup:AddChild(Image(GetInventoryItemAtlas("pig_coin.tex"), "pig_coin.tex"))
    self.coin:SetPosition(-50, -5)
    self.coin:SetScale(0.6)

    --输入框背景
    self.textinputbg = self.mypopup:AddChild(Image("images/global_redux.xml", "textbox3_gold_small_normal.tex"))
    self.textinputbg:SetPosition(20, -6)
    self.textinputbg:SetScale(0.25, 0.5)

    --物品价格输入框
    self.textinput = self.mypopup:AddChild(TextEdit(NUMBERFONT, 35, ""))
    self.textinput:SetPosition(20, -6.5)
    self.textinput:SetColour(unpack(WHITE))
    self.textinput.edit_text_color = WHITE
    self.textinput.idle_text_color = WHITE
    self.textinput:SetEditCursorColour(unpack(WHITE))
    self.textinput:SetForceEdit(true)
    self.textinput:SetRegionSize(75, 30)
    self.textinput:SetTextLengthLimit(4)
    self.textinput:SetCharacterFilter("1234567890")
    self.textinput:SetFocusedImage(self.textinputbg, "images/global_redux.xml", "textbox3_gold_small_normal.tex", "textbox3_gold_small_hover.tex", "textbox3_gold_small_focus.tex")
end)

return mypopup