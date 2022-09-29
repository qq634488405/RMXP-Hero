#==============================================================================
# ■ Arrow_Actor
#------------------------------------------------------------------------------
# 　选择角色的箭头光标。本类继承 Arrow_Base 
# 类。
#==============================================================================

class Arrow_Actor < Arrow_Base
  #--------------------------------------------------------------------------
  # ● 获取光标指向的角色
  #--------------------------------------------------------------------------
  def actor
    return $game_party.actors[@index]
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
    # 光标右
    if Input.repeat?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      @index += 1
      @index %= $game_party.actors.size
    end
    # 光标左
    if Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      @index += $game_party.actors.size - 1
      @index %= $game_party.actors.size
    end
    # 设置活动块坐标
    if self.actor != nil
      self.x = self.actor.screen_x
      self.y = self.actor.screen_y
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新帮助文本
  #--------------------------------------------------------------------------
  def update_help
    # 帮助窗口显示角色的状态
    @help_window.set_actor(self.actor)
  end
end
