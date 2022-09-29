#==============================================================================
# ■ Scene_Menu
#------------------------------------------------------------------------------
# 　处理菜单画面的类。
#==============================================================================

class Scene_Menu
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     menu_index : 命令光标的初期位置
  #--------------------------------------------------------------------------
  def initialize(index = 0)
    $eat_flag = true
    @index = index
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    # 生成命令窗口
    @screen = Spriteset_Map.new
    @main_menu = Window_Command.new(600, $data_system.main_menu,4,1,1,@index)
    @main_menu.x=20
    @main_menu.y=10
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
      # 如果切换画面就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @main_menu.dispose
    @screen.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新窗口
    @main_menu.update
    # 命令窗口被激活的情况下: 调用 update_command
    if @main_menu.active
      update_command
      return
    end
    @screen.update
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (命令窗口被激活的情况下)
  #--------------------------------------------------------------------------
  def update_command
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换的地图画面
      $scene = Scene_Map.new
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 命令窗口的光标位置分支
      case @main_menu.index
      when 0  # 查看（状态）
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 切换到物品画面
        $scene = Scene_Status.new
      when 1  # 物品
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 激活状态窗口
        $scene = Scene_Item.new
      when 2  # 装备
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 激活状态窗口
        $scene = Scene_Skill.new
      when 3  # 功能
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 切换到游戏结束画面
        $scene = Scene_Function.new
      end
    end
  end
end
