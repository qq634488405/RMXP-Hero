#==============================================================================
# ■ Window_ShopSell
#------------------------------------------------------------------------------
# 　商店画面、浏览显示可以卖掉的商品的窗口。
#==============================================================================

class Window_ShopSell < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    @actor = $game_actor
    # 生成出售列表
    @commands = make_sell_list
    height = [@commands.size*32+32,256].min
    super(8,64,268,height,3)
    @column_max = 1
    @width_txt = 236
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 生成出售物品列表
  #--------------------------------------------------------------------------
  def make_sell_list
    list,@location,@data = [],[],[]
    @actor.sell_list.each do |i|
      item_data,bag_id = i[0],i[1]
      case item_data[0]
      when 1 # 物品
        litem = $data_items[item_data[1]]
      when 2 # 武器
        litem = $data_weapons[item_data[1]]
      when 3 # 装备
        litem = $data_armors[item_data[1]]
      end
      name,num = litem.name,item_data[2]
      # 调整物品名称长度
      name = name + "  "*(5 - name.size/3)
      name = name + " "*(3 - num.to_s.size) + "×" + num.to_s
      list.push(name)
      @location.push(bag_id)
      @data.push(item_data)
    end
    return list
  end
  #--------------------------------------------------------------------------
  # ● 获取物品
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # ● 获取价格
  #--------------------------------------------------------------------------
  def price
    case item[0]
    when 1 # 物品
      return $data_items[item[1]].price*7/10
    when 2 # 武器
      return $data_weapons[item[1]].price*7/10
    when 3 # 装备
      return $data_armors[item[1]].price*7/10
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取物品所在背包位置
  #--------------------------------------------------------------------------
  def bag_position
    return @location[self.index]
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @commands = make_sell_list
    # 如果项目数不是 0 就生成位图、描绘全部项目
    @item_max = @commands.size
    if @item_max > 0
      self.height = [@item_max*32+32,256].min
      self.contents = Bitmap.new(width - 32, row_max * 32)
      self.contents.font.color = normal_color
      self.contents.clear
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘项目
  #     index : 项目标号
  #--------------------------------------------------------------------------
  def draw_item(index)
    x,y = 0,index * 32
    t_size = self.contents.text_size(@commands[index]).width
    x_off = (@width_txt - t_size) / 2 + x - 24
    rect = Rect.new( x, y, @width_txt, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.picture("Ball_Unselected.png")
    self.contents.blt(x_off,y+4,bitmap,Rect.new(0,0,20,24),255)
    self.contents.draw_text(rect, @commands[index],1)
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
    refresh
    # 刷新光标位置
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # ● 刷新帮助文本
  #--------------------------------------------------------------------------
  def update_help
    text = $data_text.shop_info.dup
    text.gsub!("price",price.to_s)
    text.gsub!("gold",$game_actor.gold.to_s)
    @help_window.auto_text(self.item == nil ? "" : text)
  end
end
