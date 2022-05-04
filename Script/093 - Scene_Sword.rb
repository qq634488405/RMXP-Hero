#==============================================================================
# ■ Scene_Sword
#------------------------------------------------------------------------------
# 　处理铸造武器的类。
#==============================================================================

class Scene_Sword
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    @actor = $game_actor
    # 生成对话窗口
    @talk_window = Window_Help.new(480,160)
    @talk_window.visible=false
    @talk_window.x=80
    @talk_window.y=304
    # 生成地图名活动块
    @map_name = Sprite_Text.new
    @map_name.set_up(0,0,$game_map.map_name)
    # 执行过度
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果画面切换就中断循环
      if $scene != self
        break
      end
    end
    # 装备过渡
    Graphics.freeze
    # 释放窗口
    @talk_window.dispose
    @map_name.dispose
    @screen.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    
  end
end