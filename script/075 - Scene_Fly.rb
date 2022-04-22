#==============================================================================
# ■ Scene_Fly
#------------------------------------------------------------------------------
# 　处理轻功传送的类。
#==============================================================================

class Scene_Fly
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    $eat_flag = true
    @actor = $game_actor
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    # 生成命令窗口
    @screen = Spriteset_Map.new
    @fly_menu = Window_Command.new(96,$data_system.fly_menu,1,1)
    @fly_menu.visible,@fly_menu.active = false,false
    # 生成对话窗口
    @talk_window = Window_Help.new(480,160)
    text = $data_text.fly_no_fp.dup
    @talk_window.auto_text(text)
    @talk_window.visible = false
    @talk_window.x,@talk_window.y = 80,304
    @can_fly = (@actor.fp >= 200)
    # 执行过渡
    Graphics.transition
    # 根据标志显示对应界面
    if @can_fly
      @fly_menu.active,@fly_menu.visible = true,true
    else
      @talk_window.visible = true
    end
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
    @fly_menu.dispose
    @screen.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新窗口
    @fly_menu.update
    @talk_window.update
    if @can_fly # 满足内力条件刷新命令窗口
      update_command
      return
    else # 不满足刷新文本
      update_text
    end
    @screen.update
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
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
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 扣除内力消耗
      @actor.fp -= 200
      # 获取目的地
      fly_target = $data_system.fly_position[@fly_menu.index]
      map_id,x,y = fly_target[0],fly_target[1],fly_target[2]
      direction = fly_target[3]
      # 设置地图
      $game_map.setup(map_id)
      # 主角移动
      $game_player.moveto(x,y)
      # 设置主角朝向
      case direction
      when 2 # 向下
        $game_player.turn_down
      when 4 # 向左
        $game_player.turn_left
      when 6 # 向右
        $game_player.turn_right
      when 8 # 向上
        $game_player.turn_up
      end
      # 刷新主角
      $game_player.refresh
      # 切换地图场景
      $scene = Scene_Map.new
      # 自动播放BGM
      $game_map.autoplay
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update_text
    # 按下 B 键或 C 键的情况下
    if Input.trigger?(Input::B) or Input.trigger?(Input::C)
      # 切换的地图画面
      $scene = Scene_Map.new
      return
    end
  end
end