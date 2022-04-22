#==============================================================================
# ■ Scene_Status
#------------------------------------------------------------------------------
# 　处理状态画面的类。
#==============================================================================

class Scene_Status
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    $eat_flag = true
    @actor = $game_actor
    @index = 0
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    @screen = Spriteset_Map.new
    # 生成状态窗口
    @status_window = Window_Status.new
    @main_menu = Window_BackMenu.new(0)
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果画面被切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @status_window.dispose
    @main_menu.dispose
    @screen.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到菜单画面
      $scene = Scene_Menu.new(0)
      return
    end
    # 按下 左 键的情况下
    if Input.trigger?(Input::LEFT)
      # 演奏光标 SE
      $game_system.se_play($data_system.cursor_se)
      # 索引调整
      @index = (@index + 3) % 4
      @status_window.index=@index
      @status_window.update
      return
    end
    # 按下 右 键的情况下
    if Input.trigger?(Input::RIGHT)
      # 演奏光标 SE
      $game_system.se_play($data_system.cursor_se)
      # 索引调整
      @index = (@index + 1) % 4
      @status_window.index=@index
      @status_window.update
      return
    end
    @screen.update
  end
end
