#==============================================================================
# ■ Scene_Gameover
#------------------------------------------------------------------------------
# 　处理游戏结束画面的类。
#==============================================================================

class Scene_Gameover
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    # 生成游戏结束图形
    @die_window = Window_Base.new(0,0,640,480)
    $game_system.windowskin_name = "Black.png"
    # 停止 BGM、BGS
    $game_system.bgm_play(nil)
    $game_system.bgs_play(nil)
    # 演奏游戏结束 ME
    $game_system.me_play($data_system.gameover_me)
    # 执行过渡
    Graphics.transition(120)
    # 主循环
    text = $data_text.die_msg.deep_clone
    text.each do |i|
      @die_window.update
      @die_window.auto_text(i,0,@die_window.back_color)
      for j in 1..60
        # 刷新游戏画面
        Graphics.update
      end
    end
    # 恢复HP
    @actor = $game_actor
    @actor.maxhp = @actor.full_hp
    @actor.hp = 1
    # 初始化任务
    $game_task = Game_Task.new
    # 设置初期位置的地图
    $game_map.setup($data_system.start_map_id)
    # 主角向初期位置移动
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    # 调整方向与姿势
    $game_player.turn_down
    $game_player.straighten
    # 刷新主角
    $game_player.refresh
    # 执行地图设置的 BGM 与 BGS 的自动切换
    $game_map.autoplay
    # 刷新地图 (执行并行事件)
    $game_map.update
    # 返回地图
    $scene = Scene_Map.new
    # 准备过渡
    Graphics.freeze
    # 释放游戏结束图形
    @die_window.dispose
    $game_system.windowskin_name = "Window.png"
    # 执行过度
    Graphics.transition(40)
    # 准备过渡
    Graphics.freeze
    # 战斗测试的情况下
    if $BTEST
      $scene = nil
    end
  end
end
