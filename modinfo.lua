name = "荒野求生服交易系统"
description = [[
本Mod需后端数据库支持，单纯开启此Mod无效
特色：玩家之间交易，非市面上其他玩家与系统的交易Mod，支持多层世界跨世界交易
致谢：感谢Flynn在做此Mod期间对我的帮助，感谢一包硬玉溪的贴图，感谢希诺、糖糖等人帮忙测试Mod提供意见
]]

author = "辣椒小皇纸"
version = "1.4.3"
forumthread = ""
api_version = 10

icon_atlas = "modicon.xml"
icon = "modicon.tex"

dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
dst_compatible = true

client_only_mod = false
all_clients_require_mod = true

----------------------
-- General settings --
----------------------

configuration_options =
{
    {
        name = "adventure_world_limit",
        label = "冒险世界限制",
        hover = "仅用于荒野求生多层世界服务器，其他服务器请关闭",
        options =   {
                        {description = "Yes", data = true, hover = ""},
                        {description = "No", data = false, hover = ""},
                    },
        default = false,
    },
}