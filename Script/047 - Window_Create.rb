#==============================================================================
# ■ Window_Create
#------------------------------------------------------------------------------
# 　角色创建窗口
#==============================================================================

class Window_Create < Window_Base
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor :gender                   # 性别
  attr_accessor :base_attr                # 基础属性
  #--------------------------------------------------------------------------
  # ● 创建“角色创建”窗口
  #--------------------------------------------------------------------------
  def initialize
    super(160, 116, 320, 248)
    @actor=$game_actor
    @index = 0
    @phase = 1
    @gender = 0
    @base_attr = [20,20,20,20]
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 光标矩形
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
  end
  #--------------------------------------------------------------------------
  # ● 步序更新
  #--------------------------------------------------------------------------
  def phase=(phase)
    @phase = phase
  end
  #--------------------------------------------------------------------------
  # ● 描绘已选择人物形象框
  #--------------------------------------------------------------------------
  def draw_gender_selected
    # 上边框
    self.contents.fill_rect(72+@gender*96,40,48,1,normal_color)
    # 左边框
    self.contents.fill_rect(72+@gender*96,40,1,64,normal_color)
    # 右边框
    self.contents.fill_rect(119+@gender*96,40,1,64,normal_color)
    # 下边框
    self.contents.fill_rect(72+@gender*96,103,48,1,normal_color)
  end
  #--------------------------------------------------------------------------
  # ● 人物选择刷新
  #--------------------------------------------------------------------------
  def gender=(gender)
    @gender = gender
  end
  #--------------------------------------------------------------------------
  # ● 刷新光标一
  #--------------------------------------------------------------------------
  def update_cursor_rect1
    case @index
    when 0
      self.cursor_rect.set(72 + @gender*96,40,48,64)
    when 1,2,3
      self.cursor_rect.set(32, @index * 32 + 88, 224, 32)
      draw_gender_selected
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新光标二
  #--------------------------------------------------------------------------
  def update_cursor_rect2
    self.cursor_rect.empty
    bitmap = RPG::Cache.picture("Hand.png")
    self.contents.blt(28,19+32*@index,bitmap,Rect.new(0, 0, 28, 26),255)
  end
  #--------------------------------------------------------------------------
  # ● 描绘人物形象
  #--------------------------------------------------------------------------
  def draw_character
    self.contents.draw_text(0, 0, 288, 32, $data_system.chara_set[0], 1)
    bitmap = [RPG::Cache.battler("Player_Boy.png",0),
              RPG::Cache.battler("Player_Girl.png",0)]
    bitmap.each_index do |i|
      self.contents.blt(80+i*96,48,bitmap[i],Rect.new(0, 0, 32, 48),255)
    end
  end
  #--------------------------------------------------------------------------
  # ● 输入列表描绘
  #--------------------------------------------------------------------------
  def draw_content(actor, x, y)
    draw_name_input(actor, x, y)
    draw_password(x, y + 32)
    self.contents.draw_text(0, y + 64, 288, 32,$data_system.chara_set[3],1)
  end
  #--------------------------------------------------------------------------
  # ● 输入姓名
  #--------------------------------------------------------------------------
  def draw_name_input(actor,x,y)
    self.contents.draw_text(x,y,72,32,$data_system.chara_set[1])
    # 根据输入内容调整显示
    name_text = actor.name == "" ? "------" : actor.name
    self.contents.draw_text(x+72,y,88,32,name_text,2)
  end
  #--------------------------------------------------------------------------
  # ● 输入密码
  #--------------------------------------------------------------------------
  def draw_password(x,y)
    self.contents.draw_text(x,y,72,32,$data_system.chara_set[2])
    # 根据输入内容调整显示
    pas_text = $word =="" ? "------" : "******"
    self.contents.draw_text(x+72,y,88,32,pas_text,2)
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    case @phase
    when 1
      draw_character
      draw_content($game_actor,64, 120)
      update_cursor_rect1
    when 2
      draw_actor_ability($game_actor,64,16)
      update_cursor_rect2
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口
  #--------------------------------------------------------------------------
  def update
    super
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口
  #--------------------------------------------------------------------------
  def attr_sum
    return @base_attr[0]+@base_attr[1]+@base_attr[2]+@base_attr[3]
  end
  #--------------------------------------------------------------------------
  # ● 四项属性值描绘
  #     actor : 角色
  #     x     : 描画目标 X 坐标
  #     y     : 描画目标 Y 坐标
  #--------------------------------------------------------------------------
  def draw_actor_ability(actor, x, y)
    bitmap = RPG::Cache.picture("Two_Arrows.png")
    for i in 0..3
      self.contents.draw_text(x, y+32*i, 72, 32, $data_system.attr_name[i]+"：")
      self.contents.draw_text(x + 120,y+32*i,40,32,@base_attr[i].to_s, 2)
      self.contents.blt(x+90,y+32*i+7,bitmap,Rect.new(0, 0, 30, 18),255)
    end
    attr_ok= attr_sum==80 ? "确认" : "剩余属性点：#{80-attr_sum}"
    self.contents.draw_text(0,y+32*4,288,32,attr_ok,1)
  end
end