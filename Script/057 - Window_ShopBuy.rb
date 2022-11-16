#==============================================================================
# ■ Window_ShopBuy
#------------------------------------------------------------------------------
# 　商店画面、浏览显示可以购买的商品的窗口。
#==============================================================================

class Window_ShopBuy < Window_Command
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     goods : 商品
  #--------------------------------------------------------------------------
  def initialize(width,commands,goods,column=1,type=0)
    super(width,commands,column,type)
    @goods = goods
    self.x,self.y = 8,64
  end
  #--------------------------------------------------------------------------
  # ● 获取物品
  #--------------------------------------------------------------------------
  def sell_item
    return @goods[self.index]
  end
  #--------------------------------------------------------------------------
  # ● 获取价格
  #--------------------------------------------------------------------------
  def price
    case sell_item[0]
    when 1 # 物品
      return $data_items[sell_item[1]].price
    when 2 # 武器
      return $data_weapons[sell_item[1]].price
    when 3 # 装备
      return $data_armors[sell_item[1]].price
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新帮助文本
  #--------------------------------------------------------------------------
  def update_help
    text = $data_text.shop_info.dup + "\n" + $data_text.shop_info2.dup
    text.gsub!("price",price.to_s)
    text.gsub!("gold",$game_actor.gold.to_s)
    number = $game_actor.item_number(sell_item[0],sell_item[1])
    text.gsub!("number",number.to_s)
    @help_window.auto_text(self.sell_item == nil ? "" : text)
  end
end
