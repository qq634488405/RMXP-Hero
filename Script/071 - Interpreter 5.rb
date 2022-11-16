#==============================================================================
# ■ Interpreter (分割定义 5)
#------------------------------------------------------------------------------
# 　执行事件命令的注释器。本类在 Game_System 类
# 和 Game_Event 类的内部使用。
#==============================================================================

class Interpreter
  #--------------------------------------------------------------------------
  # ● 场所移动
  #--------------------------------------------------------------------------
  def command_201
    # 战斗中的情况
    if $game_temp.in_battle
      # 继续
      return true
    end
    # 场所移动中、信息显示中、过渡处理中的情况下
    if $game_temp.player_transferring or
       $game_temp.message_window_showing or
       $game_temp.transition_processing
      # 结束
      return false
    end
    # 设置场所移动标志
    $game_temp.player_transferring = true
    # 指定方法为 [直接指定] 的情况下
    if @parameters[0] == 0
      # 设置主角的移动目标
      $game_temp.player_new_map_id = @parameters[1]
      $game_temp.player_new_x = @parameters[2]
      $game_temp.player_new_y = @parameters[3]
      $game_temp.player_new_direction = @parameters[4]
    # 指定方法为 [使用变量指定] 的情况下
    else
      # 设置主角的移动目标
      $game_temp.player_new_map_id = $game_variables[@parameters[1]]
      $game_temp.player_new_x = $game_variables[@parameters[2]]
      $game_temp.player_new_y = $game_variables[@parameters[3]]
      $game_temp.player_new_direction = @parameters[4]
    end
    # 推进索引
    @index += 1
    # 有淡入淡出的情况下
    if @parameters[5] == 0
      # 准备过渡
      Graphics.freeze
      # 设置过渡处理中标志
      $game_temp.transition_processing = true
      $game_temp.transition_name = ""
    end
    # 结束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 设置事件位置
  #--------------------------------------------------------------------------
  def command_202
    # 战斗中的情况下
    if $game_temp.in_battle
      # 继续
      return true
    end
    # 获取角色
    character = get_character(@parameters[0])
    # 角色不存在的情况下
    if character == nil
      # 继续
      return true
    end
    # 指定方法为 [直接指定] 的情况下
    if @parameters[1] == 0
      # 设置角色的位置
      character.moveto(@parameters[2], @parameters[3])
    # 指定方法为 [使用变量指定] 的情况下
    elsif @parameters[1] == 1
      # 设置角色的位置
      character.moveto($game_variables[@parameters[2]],
        $game_variables[@parameters[3]])
    # 指定方法为 [与其它事件交换] 的情况下
    else
      old_x = character.x
      old_y = character.y
      character2 = get_character(@parameters[2])
      if character2 != nil
        character.moveto(character2.x, character2.y)
        character2.moveto(old_x, old_y)
      end
    end
    # 设置角色的朝向
    case @parameters[4]
    when 8  # 上
      character.turn_up
    when 6  # 右
      character.turn_right
    when 2  # 下
      character.turn_down
    when 4  # 左
      character.turn_left
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 地图的滚动
  #--------------------------------------------------------------------------
  def command_203
    # 战斗中的情况下
    if $game_temp.in_battle
      # 继续
      return true
    end
    # 已经在滚动中的情况下
    if $game_map.scrolling?
      # 结束
      return false
    end
    # 开始滚动
    $game_map.start_scroll(@parameters[0], @parameters[1], @parameters[2])
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改地图设置
  #--------------------------------------------------------------------------
  def command_204
    case @parameters[0]
    when 0  # 远景
      $game_map.panorama_name = @parameters[1]
      $game_map.panorama_hue = @parameters[2]
    when 1  # 雾
      $game_map.fog_name = @parameters[1]
      $game_map.fog_hue = @parameters[2]
      $game_map.fog_opacity = @parameters[3]
      $game_map.fog_blend_type = @parameters[4]
      $game_map.fog_zoom = @parameters[5]
      $game_map.fog_sx = @parameters[6]
      $game_map.fog_sy = @parameters[7]
    when 2  # 战斗背景
      $game_map.battleback_name = @parameters[1]
      $game_temp.battleback_name = @parameters[1]
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改雾的色调
  #--------------------------------------------------------------------------
  def command_205
    # 开始更改色调
    $game_map.start_fog_tone_change(@parameters[0], @parameters[1] * 2)
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改雾的不透明度
  #--------------------------------------------------------------------------
  def command_206
    # 开始更改不透明度
    $game_map.start_fog_opacity_change(@parameters[0], @parameters[1] * 2)
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 显示动画
  #--------------------------------------------------------------------------
  def command_207
    # 获取角色
    character = get_character(@parameters[0])
    # 角色不存在的情况下
    if character == nil
      # 继续
      return true
    end
    # 设置动画 ID
    character.animation_id = @parameters[1]
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改透明状态
  #--------------------------------------------------------------------------
  def command_208
    # 设置主角的透明状态
    $game_player.transparent = (@parameters[0] == 0)
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 设置移动路线
  #--------------------------------------------------------------------------
  def command_209
    # 获取角色
    character = get_character(@parameters[0])
    # 角色不存在的情况下
    if character == nil
      # 继续
      return true
    end
    # 强制移动路线
    character.force_move_route(@parameters[1])
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 移动结束后等待
  #--------------------------------------------------------------------------
  def command_210
    # 如果不在战斗中
    unless $game_temp.in_battle
      # 设置移动结束后待机标志
      @move_route_waiting = true
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 开始过渡
  #--------------------------------------------------------------------------
  def command_221
    # 显示信息窗口中的情况下
    if $game_temp.message_window_showing
      # 结束
      return false
    end
    # 准备过渡
    Graphics.freeze
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 执行过渡
  #--------------------------------------------------------------------------
  def command_222
    # 已经设置了过渡处理中标志的情况下
    if $game_temp.transition_processing
      # 结束
      return false
    end
    # 设置过渡处理中标志
    $game_temp.transition_processing = true
    $game_temp.transition_name = @parameters[0]
    # 推进索引
    @index += 1
    # 结束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 更改画面色调
  #--------------------------------------------------------------------------
  def command_223
    # 开始更改色调
    $game_screen.start_tone_change(@parameters[0], @parameters[1] * 2)
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 画面闪烁
  #--------------------------------------------------------------------------
  def command_224
    # 开始闪烁
    $game_screen.start_flash(@parameters[0], @parameters[1] * 2)
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 画面震动
  #--------------------------------------------------------------------------
  def command_225
    # 震动开始
    $game_screen.start_shake(@parameters[0], @parameters[1],
      @parameters[2] * 2)
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 显示图片
  #--------------------------------------------------------------------------
  def command_231
    # 获取图片编号
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # 指定方法为 [直接指定] 的情况下
    if @parameters[3] == 0
      x = @parameters[4]
      y = @parameters[5]
    # 指定方法为 [使用变量指定] 的情况下
    else
      x = $game_variables[@parameters[4]]
      y = $game_variables[@parameters[5]]
    end
    # 显示图片
    $game_screen.pictures[number].show(@parameters[1], @parameters[2],
      x, y, @parameters[6], @parameters[7], @parameters[8], @parameters[9])
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 移动图片
  #--------------------------------------------------------------------------
  def command_232
    # 获取图片编号
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # 指定方法为 [直接指定] 的情况下
    if @parameters[3] == 0
      x = @parameters[4]
      y = @parameters[5]
    # 指定方法为 [使用变量指定] 的情况下
    else
      x = $game_variables[@parameters[4]]
      y = $game_variables[@parameters[5]]
    end
    # 移动图片
    $game_screen.pictures[number].move(@parameters[1] * 2, @parameters[2],
      x, y, @parameters[6], @parameters[7], @parameters[8], @parameters[9])
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 旋转图片
  #--------------------------------------------------------------------------
  def command_233
    # 获取图片编号
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # 设置旋转速度
    $game_screen.pictures[number].rotate(@parameters[1])
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改图片色调
  #--------------------------------------------------------------------------
  def command_234
    # 获取图片编号
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # 开始更改色调
    $game_screen.pictures[number].start_tone_change(@parameters[1],
      @parameters[2] * 2)
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 删除图片
  #--------------------------------------------------------------------------
  def command_235
    # 获取图片编号
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # 删除图片
    $game_screen.pictures[number].erase
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 天候设置
  #--------------------------------------------------------------------------
  def command_236
    # 设置天候
    $game_screen.weather(@parameters[0], @parameters[1], @parameters[2])
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 演奏 BGM
  #--------------------------------------------------------------------------
  def command_241
    # 演奏 BGM
    $game_system.bgm_play(@parameters[0])
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● BGM 的淡入淡出
  #--------------------------------------------------------------------------
  def command_242
    # 淡入淡出 BGM
    $game_system.bgm_fade(@parameters[0])
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 演奏 BGS
  #--------------------------------------------------------------------------
  def command_245
    # 演奏 BGS
    $game_system.bgs_play(@parameters[0])
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● BGS 的淡入淡出
  #--------------------------------------------------------------------------
  def command_246
    # 淡入淡出 BGS
    $game_system.bgs_fade(@parameters[0])
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 记忆 BGM / BGS
  #--------------------------------------------------------------------------
  def command_247
    # 记忆 BGM / BGS
    $game_system.bgm_memorize
    $game_system.bgs_memorize
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 还原 BGM / BGS
  #--------------------------------------------------------------------------
  def command_248
    # 还原 BGM / BGS
    $game_system.bgm_restore
    $game_system.bgs_restore
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 演奏 ME
  #--------------------------------------------------------------------------
  def command_249
    # 演奏 ME
    $game_system.me_play(@parameters[0])
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 演奏 SE
  #--------------------------------------------------------------------------
  def command_250
    # 演奏 SE
    $game_system.se_play(@parameters[0])
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 停止 SE
  #--------------------------------------------------------------------------
  def command_251
    # 停止 SE
    Audio.se_stop
    # 继续
    return true
  end
end
