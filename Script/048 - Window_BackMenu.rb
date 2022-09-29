#==============================================================================
# ■ Window_BackMenu
#------------------------------------------------------------------------------
# 　背景菜单窗口
#==============================================================================

class Window_BackMenu < Window_Base
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :index                    # 光标位置
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     type     : 菜单类型
  #     index    : 光标位置
  #--------------------------------------------------------------------------
  def initialize(index,type=0)
    @type = type
    @index = index
    @width = [600,300]
    @num = [4,2]
    @txt_width = [142,134]
    @main_menu = [$data_system.main_menu,$data_system.cheat_main]
    super(0,0,640,480)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 设置光标位置
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    # 描绘主菜单
    draw_main_menu
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 描绘主菜单
  #--------------------------------------------------------------------------
  def draw_main_menu
    # 重新设置菜单大小及位置
    self.x,self.y,self.width,self.height=20,10,@width[@type],64
    w = @txt_width[@type]
    # 描绘菜单项目
    @main_menu[@type].each_index do |i|
      self.contents.draw_text(i*w,0,w,32,@main_menu[@type][i],1)
    end
    # 计算光标坐标
    x = @index % @num[@type] * w
    t_size = self.contents.text_size(@main_menu[@type][index]).width
    x_off = (w - t_size) / 2 + x - 24
    bitmap = RPG::Cache.picture("Cursor.png")
    self.contents.blt(x_off, 4,bitmap,Rect.new(0, 0, 20, 24),255)
  end
end