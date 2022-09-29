#==============================================================================
# ■ Sprite_Timer
#------------------------------------------------------------------------------
# 　显示地图名称用的活动块。
#==============================================================================

class Sprite_Text < Sprite
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize(type=0,width=24,height=24)
    super()
    @text = " "
    @font_size = 24
    @type = type
    @width,@height = width,height
    self.bitmap = Bitmap.new(@width,@height)
    self.x = 0
    self.y = 0
    self.z = 600
    self.visible = false
    update
  end
  #--------------------------------------------------------------------------
  # ● 初始化
  #--------------------------------------------------------------------------
  def set_up(x,y,text,font_size=24,see=true)
    @text = text
    self.x = x
    self.y = y
    @font_size = font_size
    self.visible = see
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    if self.bitmap != nil
      self.bitmap.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 设置字符串
  #--------------------------------------------------------------------------
  def set_text(text)
    @text = text
    draw_string
  end
  #--------------------------------------------------------------------------
  # ● 设置大小
  #--------------------------------------------------------------------------
  def set_size(width,height)
    @width = width
    @height = height
    self.bitmap = Bitmap.new(@width,@height)
  end
  #--------------------------------------------------------------------------
  # ● 描绘字符串
  #--------------------------------------------------------------------------
  def draw_string
    self.bitmap.clear
    self.bitmap = Bitmap.new(@text.size*8,24) if @type == 0
    self.bitmap.font.size = @font_size
    # 设置背景色
    if @type == 0
      back_color = $color_mode==0 ? Color.new(144,176,87) : Color.new(204,204,204)
      font_color = Color.new(0,0,0)
    else
      back_color = Color.new(0,0,0)
      font_color = $color_mode==0 ? Color.new(144,176,87) : Color.new(204,204,204)
    end
    temp_rect=self.bitmap.rect
    # 填充
    self.bitmap.fill_rect(temp_rect,back_color)
    self.bitmap.font.color = font_color
    # 描绘字符串
    if @type == 0
      self.bitmap.draw_text(0, 0, @text.size*8, 24, @text)
    else
      self.bitmap.draw_text(0, 0, @width, @height, @text, 1)
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
    # 描绘字符串
    draw_string
  end
end
