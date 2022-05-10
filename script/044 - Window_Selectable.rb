#==============================================================================
# ■ Window_Selectable
#------------------------------------------------------------------------------
# 　拥有光标的移动以及滚动功能的窗口类。
#==============================================================================

class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :index                    # 光标位置
  attr_reader   :help_window              # 帮助窗口
  attr_reader   :new_command              # 反色显示块
  #--------------------------------------------------------------------------
  # ● 初始画对像
  #     x      : 窗口的 X 坐标
  #     y      : 窗口的 Y 坐标
  #     width  : 窗口的宽
  #     height : 窗口的高
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, type = 0)
    super(x, y, width, height)
    @item_max = 1
    @column_max = 1
    @index = -1
    @type = type
    if @type == 5
      @new_command = Sprite_Text.new(1,96,24)
    else
      @new_command = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置光标的位置
  #     index : 新的光标位置
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    # 刷新帮助文本 (update_help 定义了继承目标)
    if self.active and @help_window != nil
      update_help
    end
    # 刷新光标矩形
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # ● 释放窗口
  #--------------------------------------------------------------------------
  def dispose
    @new_command.dispose if @new_command !=nil
    super
  end
  #--------------------------------------------------------------------------
  # ● 获取行数
  #--------------------------------------------------------------------------
  def row_max
    # 由项目数和列数计算出行数
    return (@item_max + @column_max - 1) / @column_max
  end
  #--------------------------------------------------------------------------
  # ● 获取开头行
  #--------------------------------------------------------------------------
  def top_row
    # 将窗口内容的传送源 Y 坐标、1 行的高 32 等分
    return self.oy / 32
  end
  #--------------------------------------------------------------------------
  # ● 设置开头行
  #     row : 显示开头的行
  #--------------------------------------------------------------------------
  def top_row=(row)
    # row 未满 0 的场合更正为 0
    if row < 0
      row = 0
    end
    # row 超过 row_max - 1 的情况下更正为 row_max - 1 
    if row > row_max - 1
      row = row_max - 1
    end
    # row 1 行高的 32 倍、窗口内容的传送源 Y 坐标
    self.oy = row * 32
  end
  #--------------------------------------------------------------------------
  # ● 获取 1 页可以显示的行数
  #--------------------------------------------------------------------------
  def page_row_max
    # 窗口的高度，设置画面的高度减去 32 ，除以 1 行的高度 32 
    return (self.height - 32) / 32
  end
  #--------------------------------------------------------------------------
  # ● 获取 1 页可以显示的项目数
  #--------------------------------------------------------------------------
  def page_item_max
    # 将行数 page_row_max 乘上列数 @column_max
    return page_row_max * @column_max
  end
  #--------------------------------------------------------------------------
  # ● 帮助窗口的设置
  #     help_window : 新的帮助窗口
  #--------------------------------------------------------------------------
  def help_window=(help_window)
    @help_window = help_window
    # 刷新帮助文本 (update_help 定义了继承目标)
    if self.active and @help_window != nil
      update_help
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘项目
  #     index : 项目编号
  #     color : 文字色
  #--------------------------------------------------------------------------
  def draw_item(index, color)
    self.contents.font.color = color
    # 计算得出当前index所对应的内容所在的行
    row_index = index / @column_max
    # 根据余数得出所在的列
    for y in 0...@column_max
      if index % @column_max == y
        a = y * @width_txt
        b = 32 * row_index
        t_size = self.contents.text_size(@commands[index]).width
        a_off = (@width_txt - t_size) / 2 + a - 24
        rect = Rect.new( a, b, @width_txt, 32)
        self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
        case @type
        when 2 # 空白正方形框
          bitmap = RPG::Cache.picture("Rect_Unselected.png")
          self.contents.blt(a,b+4,bitmap,Rect.new(0,0,20,24),255)
        when 3 # 空白圆形
          bitmap = RPG::Cache.picture("Ball_Unselected.png")
          self.contents.blt(a_off,b+4,bitmap,Rect.new(0,0,20,24),255)
        when 4 # 空白正方形框及装备框
          bitmap = [RPG::Cache.picture("Rect_Unselected.png"),
                    RPG::Cache.picture("Rect_Unselected_Equiped.png")]
          self.contents.blt(a_off,b+4,bitmap[0],Rect.new(0,0,20,24),255)
        when 6 # 空白圆形反色
          bitmap = RPG::Cache.picture("GBall_Unselected.png")
          self.contents.blt(a_off,b+4,bitmap,Rect.new(0,0,20,24),255)
        end
        self.contents.draw_text(rect, @commands[index],@align)
        break
      end
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
    y = @index / @column_max * 32 - self.oy
    y += self.oy if @type != 0
    t_size = self.contents.text_size(@commands[@index]).width
    x_off = (@width_txt - t_size) / 2 + x - 24
    case @type
    when 0 # 光标矩形
      self.cursor_rect.set(x, y, @width_txt, 32)
    when 1 # 三角光标
      bitmap = RPG::Cache.picture("Cursor.png")
      self.contents.blt(x_off, y+4,bitmap,Rect.new(0, 0, 20, 24),255)
    when 2 # 正方形选择框
      bitmap = RPG::Cache.picture("Rect_Selected.png")
      self.contents.blt(x, y+4,bitmap,Rect.new(0, 0, 20, 24),255)
    when 3 # 圆形选择框
      bitmap = RPG::Cache.picture("Ball_Selected.png")
      self.contents.blt(x_off, y+4,bitmap,Rect.new(0, 0, 20, 24),255)
    when 4 # 空白正方形框及装备框
      bitmap = [RPG::Cache.picture("Rect_Selected.png"),
                RPG::Cache.picture("Rect_Selected_Equiped.png")]
      self.contents.blt(x,y+4,bitmap[0],Rect.new(0,0,20,24),255)
    when 5 # 反色显示
      @new_command.set_size(@width_txt,32)
      @new_command.set_up(16+x+self.x,16+y+self.y,@commands[@index])
      @new_command.update
    when 6 # 圆形选择框反色
      bitmap = RPG::Cache.picture("GBall_Selected.png")
      self.contents.blt(x_off, y+4,bitmap,Rect.new(0, 0, 20, 24),255)
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
    # 可以移动光标的情况下
    if self.active and @item_max > 0 and @index >= 0
      # 方向键下被按下的情况下
      if Input.repeat?(Input::DOWN)
        # 列数不是 1 并且不与方向键下的按下状态重复的情况、
        # 或光标位置在(项目数-列数)之前的情况下
        if (@column_max == 1 and Input.trigger?(Input::DOWN)) or
           @index < @item_max - @column_max
          # 光标向下移动
          $game_system.se_play($data_system.cursor_se)
          @index = (@index + @column_max) % @item_max
        end
      end
      # 方向键上被按下的情况下
      if Input.repeat?(Input::UP)
        # 列数不是 1 并且不与方向键下的按下状态重复的情况、
        # 或光标位置在列之后的情况下
        if (@column_max == 1 and Input.trigger?(Input::UP)) or
           @index >= @column_max
          # 光标向上移动
          $game_system.se_play($data_system.cursor_se)
          @index = (@index - @column_max + @item_max) % @item_max
        end
      end
      # 方向键右被按下的情况下
      if Input.repeat?(Input::RIGHT)
        # 列数不是 1
        # 光标向右移动，尾部则回到头部
        if @column_max != 1
          $game_system.se_play($data_system.cursor_se)
          @index = (@index + 1) % @item_max
        end
      end
      # 方向键左被按下的情况下
      if Input.repeat?(Input::LEFT)
        # 列数不是1
        # 光标向左移动，头部则回到尾部
        if @column_max != 1
          $game_system.se_play($data_system.cursor_se)
          @index = (@index + @item_max - 1) % @item_max
        end
      end
      # R 键被按下的情况下
      if Input.repeat?(Input::R)
        # 显示的最后行在数据中最后行上方的情况下
        if self.top_row + (self.page_row_max - 1) < (self.row_max - 1)
          # 光标向后移动一页
          $game_system.se_play($data_system.cursor_se)
          @index = [@index + self.page_item_max, @item_max - 1].min
          self.top_row += self.page_row_max
        end
      end
      # L 键被按下的情况下
      if Input.repeat?(Input::L)
        # 显示的开头行在位置 0 之后的情况下
        if self.top_row > 0
          # 光标向前移动一页
          $game_system.se_play($data_system.cursor_se)
          @index = [@index - self.page_item_max, 0].max
          self.top_row -= self.page_row_max
        end
      end
    end
    # 刷新帮助文本 (update_help 定义了继承目标)
    if self.active and @help_window != nil
      update_help
    end
    # 刷新光标矩形
    update_cursor_rect
  end
end
