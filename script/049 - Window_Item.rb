#==============================================================================
# ■ Window_Item
#------------------------------------------------------------------------------
# 　物品画面、战斗画面、显示浏览物品的窗口。
#==============================================================================

class Window_Item < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super(116, 74, 504, 322)
    @column_max = 1
    @item_type = 0
    @page = 0
    @width_txt = 472
    @actor = $game_actor
    # 战斗中的情况下调整窗口大小并移至中央
    if $game_temp.in_battle
      self.height,self.width = 224,320
      @width_text = self.width - 32
      self.x = (544 - self.width) / 2 + 96
      self.y = (480 - self.height) / 2
      self.z = 500
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 设置类别
  #--------------------------------------------------------------------------
  def set_item_type(type)
    @item_type = type
  end
  #--------------------------------------------------------------------------
  # ● 设置描述页
  #--------------------------------------------------------------------------
  def set_page(page)
    @page = page
  end
  #--------------------------------------------------------------------------
  # ● 获取物品
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # ● 获取物品对应背包序号
  #--------------------------------------------------------------------------
  def bag_index
    return @location[self.index]
  end
  #--------------------------------------------------------------------------
  # ● 获取物品名称
  #--------------------------------------------------------------------------
  def get_item_name(type,id)
    # 获取物品名称
    case type
    when 1 # 物品
      name = $data_items[id].name
    when 2 # 武器
      name = $data_weapons[id].name
    when 3 # 装备
      name = $data_armors[id].name
    end
    return name
  end
  #--------------------------------------------------------------------------
  # ● 物品类别判定
  #--------------------------------------------------------------------------
  def judge_item(item_data)
    type,id,equip = item_data[0],item_data[1],item_data[3]
    return false if type == 0
    case @item_type
    when 0,1 # 食物、药物
      return false if type != 1
      return ($data_items[id].type == @item_type)
    when 2,3 # 武器、装备
      return (type == @item_type)
    when 4 # 其他
      return false if type != 1
      return ($data_items[id].type == 2)
    when 5 # 丢弃
      return false if equip == 1
      case type
      when 1 # 物品是否可丢弃
        return $data_items[id].can_drop
      when 2 # 武器是否可丢弃
        return $data_weapons[id].can_drop
      when 3 # 装备是否可丢弃
        return $data_armors[id].can_drop
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data,@location = [],[]
    # 背包物品不为0
    if @actor.item_bag.size > 0
      @actor.item_bag.each_index do |i|
        item_data = @actor.item_bag[i]
        if judge_item(item_data)
          @data.push(item_data)
          @location.push(i)
        end
      end
    end
    # 类别为其他，且已获得石板，则添加石板
    if @item_type == 4 and @actor.stone_list.size > 0
      @data.push([1,19,@actor.stone_list.size,0])
      @location.push(@actor.item_bag.size)
    end
    # 如果项目数不是 0 就生成位图、重新描绘全部项目
    @item_max = @data.size
    if @item_max > 0
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
  #     index : 项目编号
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    type,id,number,equip = item[0],item[1],item[2],item[3]
    x,y = 4,index * 32
    # 获取物品名称
    name = get_item_name(type,id)
    rect = Rect.new(x, y, self.width / @column_max - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    # 设置图标
    bitmap = [RPG::Cache.picture("Rect_Unselected.png"),
              RPG::Cache.picture("Rect_Unselected_Equiped.png")]
    self.contents.blt(x,y+4,bitmap[equip], Rect.new(0,0,20,24),255)
    self.contents.draw_text(x + 28, y, 212, 32, name, 0)
    unless [2,3].include?(@item_type)
      self.contents.draw_text(x + 240, y, 16, 32, "×", 1)
      self.contents.draw_text(x + 256, y, 24, 32, number.to_s, 2)
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新光标矩形
  #--------------------------------------------------------------------------
  def update_cursor_rect
    # 光标位置不满 0 的情况下
    if @index < 0
      self.cursor_rect.empty
      return
    end
    # 获取当前的行
    row = @index / @column_max
    # 当前行被显示开头行前面的情况下
    if row < self.top_row
      # 从当前行向开头行滚动
      self.top_row = row
    end
    # 当前行被显示末尾行之后的情况下
    if row > self.top_row + (self.page_row_max - 1)
      # 从当前行向末尾滚动
      self.top_row = row - (self.page_row_max - 1)
    end
    # 计算光标的宽
    cursor_width = @width_txt
    # 计算光标坐标
    x = @index % @column_max * cursor_width
    y = @index / @column_max * 32
    bitmap = [RPG::Cache.picture("Rect_Selected.png"),
              RPG::Cache.picture("Rect_Selected_Equiped.png")]
    pic_id = self.item[3]
    self.contents.blt(x+4,y+4,bitmap[pic_id],Rect.new(0,0,20,24),255)
  end
  #--------------------------------------------------------------------------
  # ● 刷新帮助文本
  #--------------------------------------------------------------------------
  def update_help
    des_text = []
    if self.item == nil
      text = ""
    else
      type,id = self.item[0],self.item[1]
      case type
      when 1 # 物品
        text = $data_items[id].description.dup
      when 2 # 武器
        text = $data_weapons[id].description.dup
      when 3 # 装备
        text = $data_armors[id].description.dup
      end
    end
    # 根据描述字数分页显示
    if text.size <= 66
      @help_window.set_text(text)
    else # 描述长则分两页显示
      des_text[0] = text.slice(0,66)+"→"
      des_text[1]="←"+text.slice(66,text.size - 66)
      @help_window.set_text(des_text[@page])
    end
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
end
