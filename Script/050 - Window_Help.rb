#==============================================================================
# ■ Window_Help
#------------------------------------------------------------------------------
# 　特技及物品的说明、角色的状态显示的窗口。
#==============================================================================

class Window_Help < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize(w=640,h=64)
    super(0, 0, w, h)
    self.z = 700
  end
  #--------------------------------------------------------------------------
  # ● 设置文本
  #     text  : 窗口显示的字符串
  #     align : 对齐方式 (0..左对齐、1..中间对齐、2..右对齐)
  #--------------------------------------------------------------------------
  def set_text(text, align = 0)
    # 如果文本和对齐方式的至少一方与上次的不同
    if text != @text or align != @align
      # 再描绘文本
      self.contents.clear
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 0, self.width - 40, 32, text, align)
      @text = text
      @align = align
      @actor = nil
    end
    self.visible = true
  end
  #--------------------------------------------------------------------------
  # ● 设置角色
  #     actor : 要显示状态的角色
  #--------------------------------------------------------------------------
  def set_actor(actor)
    if actor != @actor
      self.contents.clear
      draw_actor_name(actor, 4, 0)
      draw_actor_state(actor, 140, 0)
      draw_actor_hp(actor, 284, 0)
      draw_actor_sp(actor, 460, 0)
      @actor = actor
      @text = nil
      self.visible = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置敌人
  #     enemy : 要显示名字和状态的敌人
  #--------------------------------------------------------------------------
  def set_enemy(enemy)
    text = enemy.name
    state_text = make_battler_state_text(enemy, 112, false)
    if state_text != ""
      text += "  " + state_text
    end
    set_text(text, 1)
  end
end
