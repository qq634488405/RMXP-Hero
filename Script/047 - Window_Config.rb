#==============================================================================
# ■ Window_Config
#------------------------------------------------------------------------------
# 　游戏设置窗口
#==============================================================================

class Window_Config < Window_Base
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :index                    # 光标位置
  attr_reader   :help_window              # 帮助窗口
  #--------------------------------------------------------------------------
  # ● 创建“游戏设置”窗口
  #--------------------------------------------------------------------------
  def initialize(title,config_set,config_data,config_help,set_data)
    super(80,32,480,320)
    @index = 0
    @title = title
    @config_set = config_set
    @config_data = config_data
    @config_help = config_help
    @set_data = set_data
    @help_window = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 光标矩形
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
  end
  #--------------------------------------------------------------------------
  # ● 选项设定
  #--------------------------------------------------------------------------
  def set_data=(set_data)
    @set_data = set_data
  end
  #--------------------------------------------------------------------------
  # ● 获取设定值
  #--------------------------------------------------------------------------
  def get_set_data
    return @set_data
  end
  #--------------------------------------------------------------------------
  # ● 获取设定值
  #--------------------------------------------------------------------------
  def update_set_data(n)
    case n
    when 1 # 右
      @set_data[@index] = (@set_data[@index] + 1) % @config_data[@index].size
    when 2 # 左
      new_data = @set_data[@index] + @config_data[@index].size - 1
      @set_data[@index] = new_data % @config_data[@index].size
    end
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
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    # 设置图标及左右箭头
    bitmap = RPG::Cache.picture("Config.png")
    l_bitmap = RPG::Cache.picture("Left.png")
    r_bitmap = RPG::Cache.picture("Right.png")
    # 描绘标题栏
    self.contents.blt(144,0,bitmap,Rect.new(0,0,32,32),255)
    self.contents.draw_text(176,0,128,32,@title)
    # 描绘各个选项
    @config_set.each_index do |i|
      self.contents.draw_text(32,32*i+32,192,32,@config_set[i])
      self.contents.draw_text(256,32*i+32,128,32,@config_data[i][@set_data[i]],1)
      # 不为恢复默认和确认选项时描绘左右箭头
      if i < @config_set.size-2
        self.contents.blt(236,32*i+40,l_bitmap,Rect.new(0,0,16,16),255)
        self.contents.blt(388,32*i+40,r_bitmap,Rect.new(0,0,16,16),255)
      end
    end
    # 刷新光标位置
    update_cursor_rect
    # 刷新帮助文本
    update_help
  end
  #--------------------------------------------------------------------------
  # ● 刷新光标
  #--------------------------------------------------------------------------
  def update_cursor_rect
    bitmap = RPG::Cache.picture("Hand.png")
    # 描绘手指指向
    y = @index * 32 + 35
    self.contents.blt(2,y,bitmap,Rect.new(0,0,28,26),255)
    # 选项上描绘闪烁光标
    if @index < @config_set.size - 2
      self.cursor_rect.set(264,y-5,112,36)
    else
      self.cursor_rect.empty
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新帮助窗口
  #--------------------------------------------------------------------------
  def update_help
    text = @config_help[@index][@set_data[@index]].deep_clone
    @help_window.auto_text(text) if @help_window != nil
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口
  #--------------------------------------------------------------------------
  def update
    super
    # 可以移动光标的情况下
    if self.active and @index >= 0
      # 方向下被按下的情况
      if Input.trigger?(Input::DOWN)
        # 光标向下移动
        $game_system.se_play($data_system.cursor_se)
        @index = (@index + 1) % 8
      end
      # 方向上被按下的情况
      if Input.trigger?(Input::UP)
        # 光标向下移动
        $game_system.se_play($data_system.cursor_se)
        @index = (@index + 7) % 8
      end
    end
    refresh
  end
end