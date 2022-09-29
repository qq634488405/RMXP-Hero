#==============================================================================
# ■ Scene_Map
#------------------------------------------------------------------------------
# 　处理地图画面的类。
#==============================================================================

class Scene_Map
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    $eat_flag = true
    # 生成活动块
    @spriteset = Spriteset_Map.new
    # 生成信息窗口
    @message_window = Window_Message.new
    # 生成地图名活动块
    @map_name = Sprite_Text.new
    @map_name.set_up(0,0,$game_map.map_name)
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
      # 如果画面切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放活动块
    @spriteset.dispose
    # 释放信息窗口
    @message_window.dispose
    # 释放地图名窗口
    @map_name.dispose
    # 标题画面切换中的情况下
    if $scene.is_a?(Scene_Title)
      # 淡入淡出画面
      Graphics.transition
      Graphics.freeze
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 循环
    loop do
      # 按照地图、实例、主角的顺序刷新
      # (本更新顺序不会在满足事件的执行条件下成为给予角色瞬间移动
      #  的机会的重要因素)
      $game_map.update
      $game_system.map_interpreter.update
      $game_player.update
      # 系统 (计时器)、画面刷新
      $game_system.update
      $game_screen.update
      # 如果主角在场所移动中就中断循环
      unless $game_temp.player_transferring
        break
      end
      # 执行场所移动
      transfer_player
      # 处理过渡中的情况下、中断循环
      if $game_temp.transition_processing
        break
      end
    end
    # 刷新活动块
    @spriteset.update
    # 刷新信息窗口
    @message_window.update
    # 刷新地图名活动块
    @map_name.update
    # 游戏结束的情况下
    if $game_temp.gameover
      # 切换的游戏结束画面
      $scene = Scene_Gameover.new
      return
    end
    # 返回标题画面的情况下
    if $game_temp.to_title
      # 切换到标题画面
      $scene = Scene_Title.new
      return
    end
    # 处理过渡中的情况下
    if $game_temp.transition_processing
      # 清除过渡处理中标志
      $game_temp.transition_processing = false
      # 执行过渡
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" +
          $game_temp.transition_name)
      end
    end
    # 显示信息窗口中的情况下
    if $game_temp.message_window_showing
      return
    end
    # 遇敌计数为 0 且、且遇敌列表不为空的情况下
    if $game_player.encounter_count == 0 and $game_map.encounter_list != []
      # 不是在事件执行中或者禁止遇敌中
      unless $game_system.map_interpreter.running? or
             $game_system.encounter_disabled
        # 确定队伍
        n = rand($game_map.encounter_list.size)
        troop_id = $game_map.encounter_list[n]
        # 队伍有效的话
        if $data_troops[troop_id] != nil
          # 设置调用战斗标志
          $game_temp.battle_calling = true
          $game_temp.battle_troop_id = troop_id
          $game_temp.battle_can_escape = true
          $game_temp.battle_can_lose = false
          $game_temp.battle_proc = nil
        end
      end
    end
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 不是在事件执行中或菜单禁止中
      unless $game_system.map_interpreter.running? or
             $game_system.menu_disabled
        # 设置菜单调用标志以及 SE 演奏
        $game_temp.menu_calling = true
        $game_temp.menu_beep = true
      end
    end
    # 作弊模式为 ON 并且按下 F5 键的情况下
    if $game_temp.cheat_mode and Input.press?(Input::F5)
      # 设置调用调试标志
      $game_temp.debug_calling = true
    end
    # 轻功有效等级≥30 并且按下 F6 键的情况下
    if $game_actor.dodge_kf_lv >= 30 and Input.press?(Input::F6)
      # 设置轻功标志
      $game_temp.fly_calling = true
    end
    # 不在主角移动中的情况下
    unless $game_player.moving?
      # 执行各种画面的调用
      if $game_temp.battle_calling
        call_battle
      elsif $game_temp.shop_calling
        call_shop
      elsif $game_temp.name_calling
        call_name
      elsif $game_temp.menu_calling
        call_menu
      elsif $game_temp.save_calling
        call_save
      elsif $game_temp.debug_calling
        call_debug
      elsif $game_temp.fly_calling
        call_fly
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 调用战斗
  #--------------------------------------------------------------------------
  def call_battle
    # 清除战斗调用标志
    $game_temp.battle_calling = false
    # 清除菜单调用标志
    $game_temp.menu_calling = false
    $game_temp.menu_beep = false
    # 生成遇敌计数
    $game_player.make_encounter_count
    # 记忆地图 BGM 、停止 BGM
    $game_temp.map_bgm = $game_system.playing_bgm
    $game_system.bgm_stop
    # 演奏战斗开始 SE
    $game_system.se_play($data_system.battle_start_se)
    # 演奏战斗 BGM
    $game_system.bgm_play($game_system.battle_bgm)
    # 矫正主角姿势
    $game_player.straighten
    # 切换到战斗画面
    $scene = Scene_Battle.new
  end
  #--------------------------------------------------------------------------
  # ● 调用商店
  #--------------------------------------------------------------------------
  def call_shop
    # 清除商店调用标志
    $game_temp.shop_calling = false
    # 矫正主角姿势
    $game_player.straighten
    # 切换到商店画面
    $scene = Scene_Shop.new
  end
  #--------------------------------------------------------------------------
  # ● 调用名称输入
  #--------------------------------------------------------------------------
  def call_name
    # 清除调用名称输入标志
    $game_temp.name_calling = false
    # 矫正主角姿势
    $game_player.straighten
    # 切换到名称输入画面
    $scene = Scene_Name.new
  end
  #--------------------------------------------------------------------------
  # ● 调用菜单
  #--------------------------------------------------------------------------
  def call_menu
    # 清除菜单调用标志
    $game_temp.menu_calling = false
    # 已经设置了菜单 SE 演奏标志的情况下
    if $game_temp.menu_beep
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 清除菜单演奏 SE 标志
      $game_temp.menu_beep = false
    end
    # 切换到菜单画面
    $scene = Scene_Menu.new
  end
  #--------------------------------------------------------------------------
  # ● 调用存档
  #--------------------------------------------------------------------------
  def call_save
    # 矫正主角姿势
    $game_player.straighten
    # 切换到存档画面
    $scene = Scene_Save.new
  end
  #--------------------------------------------------------------------------
  # ● 调用调试
  #--------------------------------------------------------------------------
  def call_debug
    # 清除调用调试标志
    $game_temp.debug_calling = false
    # 演奏确定 SE
    $game_system.se_play($data_system.decision_se)
    # 切换到调试画面
    $scene = Scene_Cheat.new
  end
  #--------------------------------------------------------------------------
  # ● 调用轻功
  #--------------------------------------------------------------------------
  def call_fly
    # 清除调用轻功标志
    $game_temp.fly_calling = false
    # 演奏确定 SE
    $game_system.se_play($data_system.decision_se)
    # 切换到轻功画面
    $scene = Scene_Fly.new
  end
  #--------------------------------------------------------------------------
  # ● 主角的场所移动
  #--------------------------------------------------------------------------
  def transfer_player
    # 清除主角场所移动调试标志
    $game_temp.player_transferring = false
    # 移动目标与现在的地图有差异的情况下
    if $game_map.map_id != $game_temp.player_new_map_id
      # 设置新地图
      $game_map.setup($game_temp.player_new_map_id)
      # 刷新地图名
      @map_name.set_text($game_map.map_name)
    end
    # 设置主角位置
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
    # 设置主角朝向
    case $game_temp.player_new_direction
    when 2  # 下
      $game_player.turn_down
    when 4  # 左
      $game_player.turn_left
    when 6  # 右
      $game_player.turn_right
    when 8  # 上
      $game_player.turn_up
    end
    # 矫正主角姿势
    $game_player.straighten
    # 刷新地图 (执行并行事件)
    $game_map.update
    # 在生成活动块
    @spriteset.dispose
    @spriteset = Spriteset_Map.new
    # 处理过渡中的情况下
    if $game_temp.transition_processing
      # 清除过渡处理中标志
      $game_temp.transition_processing = false
      # 执行过渡
      Graphics.transition(20)
    end
    # 执行地图设置的 BGM、BGS 的自动切换
    $game_map.autoplay
    # 设置画面
    Graphics.frame_reset
    # 刷新输入信息
    Input.update
  end
end
