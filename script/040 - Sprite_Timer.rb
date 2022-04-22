#==============================================================================
# ■ Sprite_Timer
#------------------------------------------------------------------------------
# 　显示计时器用的活动块。监视 $game_system 、活动块状态
# 自动变化。
#==============================================================================

class Sprite_Timer < Sprite
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super
    self.bitmap = Bitmap.new(88, 48)
    self.bitmap.font.name = "Arial"
    self.bitmap.font.size = 32
    self.x = 640 - self.bitmap.width
    self.y = 0
    self.z = 500
    update
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
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
    # 设置计时器执行中为可见
    self.visible = $game_system.timer_working
    # 如果有必要再次描绘计时器
    if $game_system.timer / Graphics.frame_rate != @total_sec
      # 清除窗口内容
      self.bitmap.clear
      # 计算总计秒数
      @total_sec = $game_system.timer / Graphics.frame_rate
      # 生成计时器显示用字符串
      min = @total_sec / 60
      sec = @total_sec % 60
      text = sprintf("%02d:%02d", min, sec)
      # 描绘计时器
      self.bitmap.font.color.set(255, 255, 255)
      self.bitmap.draw_text(self.bitmap.rect, text, 1)
    end
  end
end
