#==============================================================================
# ■ Game_Character (分割定义 2)
#------------------------------------------------------------------------------
# 　处理角色的类。本类作为 Game_Player 类与 Game_Event
# 类的超级类使用。
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 跳跃中、移动中、停止中的分支
    if jumping?
      update_jump
    elsif moving?
      update_move
    else
      update_stop
    end
    # 动画计数超过最大值的情况下
    # ※最大值等于基本值减去移动速度 * 1 的值
    if @anime_count > 14 - @move_speed * 2
      # 停止动画为 OFF 并且在停止中的情况下
      if not @step_anime and @stop_count > 0
        # 还原为原来的图形
        #@pattern = @original_pattern
      # 停止动画为 ON 并且在移动中的情况下
      else
        # 更新图形
        @pattern = (@pattern + 1) % 4
      end
      # 清除动画计数
      @anime_count = 0
    end
    # 等待中的情况下
    if @wait_count > 0
      # 减少等待计数
      @wait_count -= 1
      return
    end
    # 强制移动路线的场合
    if @move_route_forcing
      # 自定义移动
      move_type_custom
      return
    end
    # 事件执行待机中并且为锁定状态的情况下
    if @starting or lock?
      # 不做规则移动
      return
    end
    # 如果停止计数超过了一定的值(由移动频度算出)
    if @stop_count > (40 - @move_frequency * 2) * (6 - @move_frequency)
      # 移动类型分支
      case @move_type
      when 1  # 随机
        move_type_random
      when 2  # 接近
        move_type_toward_player
      when 3  # 自定义
        move_type_custom
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新画面 (跳跃)
  #--------------------------------------------------------------------------
  def update_jump
    # 跳跃计数减 1
    @jump_count -= 1
    # 计算新坐标
    @real_x = (@real_x * @jump_count + @x * 128) / (@jump_count + 1)
    @real_y = (@real_y * @jump_count + @y * 128) / (@jump_count + 1)
  end
  #--------------------------------------------------------------------------
  # ● 更新画面 (移动)
  #--------------------------------------------------------------------------
  def update_move
    # 移动速度转换为地图坐标系的移动距离
    distance = 2 ** @move_speed
    # 理论坐标在实际坐标下方的情况下
    if @y * 128 > @real_y
      # 向下移动
      @real_y = [@real_y + distance, @y * 128].min
    end
    # 理论坐标在实际坐标左方的情况下
    if @x * 128 < @real_x
      # 向左移动
      @real_x = [@real_x - distance, @x * 128].max
    end
    # 理论坐标在实际坐标右方的情况下
    if @x * 128 > @real_x
      # 向右移动
      @real_x = [@real_x + distance, @x * 128].min
    end
    # 理论坐标在实际坐标上方的情况下
    if @y * 128 < @real_y
      # 向上移动
      @real_y = [@real_y - distance, @y * 128].max
    end
    # 移动时动画为 ON 的情况下
    if @walk_anime
      # 动画计数增加 1.5
      @anime_count += 1.5
    # 移动时动画为 OFF、停止时动画为 ON 的情况下
    elsif @step_anime
      # 动画计数增加 1.5
      @anime_count += 1.5
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新画面 (停止)
  #--------------------------------------------------------------------------
  def update_stop
    # 停止时动画为 ON 的情况下
    if @step_anime
      # 动画计数增加 1.5
      @anime_count += 1.5
    # 停止时动画为 OFF 并且、现在的图像与原来的不同的情况下
    elsif @pattern != @original_pattern
      # 动画计数增加 1.5
      @anime_count += 1.5
    end
    # 事件执行待机中并且不是锁定状态的情况下
    # ※锁定、处理成立刻停止执行中的事件
    unless @starting or lock?
      # 停止计数增加 1.5
      @stop_count += 1.5
    end
  end
  #--------------------------------------------------------------------------
  # ● 移动类型 : 随机
  #--------------------------------------------------------------------------
  def move_type_random
    # 随机 0～5 的分支
    case rand(6)
    when 0..3  # 随机
      move_random
    when 4  # 前进一步
      move_forward
    when 5  # 暂时停止
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 移动类型 : 接近
  #--------------------------------------------------------------------------
  def move_type_toward_player
    # 求得与主角坐标的差
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # 求得差的绝对值
    abs_sx = sx > 0 ? sx : -sx
    abs_sy = sy > 0 ? sy : -sy
    # 如果纵横共计离开 20 个元件
    if sx + sy >= 20
      # 随机
      move_random
      return
    end
    # 随机 0～5 的分支
    case rand(6)
    when 0..3  # 接近主角
      move_toward_player
    when 4  # 随机
      move_random
    when 5  # 前进一步
      move_forward
    end
  end
  #--------------------------------------------------------------------------
  # ● 移动类型 : 自定义
  #--------------------------------------------------------------------------
  def move_type_custom
    # 如果不是停止中就中断
    if jumping? or moving?
      return
    end
    # 如果在移动指令列表最后结束还没到达就循环执行
    while @move_route_index < @move_route.list.size
      # 获取移动指令
      command = @move_route.list[@move_route_index]
      # 指令编号 0 号 (列表最后) 的情况下
      if command.code == 0
        # 选项 [反复动作] 为 ON 的情况下
        if @move_route.repeat
          # 还原为移动路线的最初索引
          @move_route_index = 0
        end
        # 选项 [反复动作] 为 OFF 的情况下
        unless @move_route.repeat
          # 强制移动路线的场合
          if @move_route_forcing and not @move_route.repeat
            # 强制解除移动路线
            @move_route_forcing = false
            # 还原为原始的移动路线
            @move_route = @original_move_route
            @move_route_index = @original_move_route_index
            @original_move_route = nil
          end
          # 清除停止计数
          @stop_count = 0
        end
        return
      end
      # 移动系指令 (向下移动～跳跃) 的情况下
      if command.code <= 14
        # 命令编号分支
        case command.code
        when 1  # 向下移动
          move_down
        when 2  # 向左移动
          move_left
        when 3  # 向右移动
          move_right
        when 4  # 向上移动
          move_up
        when 5  # 向左下移动
          move_lower_left
        when 6  # 向右下移动
          move_lower_right
        when 7  # 向左上移动
          move_upper_left
        when 8  # 向右上
          move_upper_right
        when 9  # 随机移动
          move_random
        when 10  # 接近主角
          move_toward_player
        when 11  # 远离主角
          move_away_from_player
        when 12  # 前进一步
          move_forward
        when 13  # 后退一步
          move_backward
        when 14  # 跳跃
          jump(command.parameters[0], command.parameters[1])
        end
        # 选项 [无视无法移动的情况] 为 OFF 、移动失败的情况下
        if not @move_route.skippable and not moving? and not jumping?
          return
        end
        @move_route_index += 1
        return
      end
      # 等待的情况下
      if command.code == 15
        # 设置等待计数
        @wait_count = command.parameters[0] * 2 - 1
        @move_route_index += 1
        return
      end
      # 朝向变更系指令的情况下
      if command.code >= 16 and command.code <= 26
        # 命令编号分支
        case command.code
        when 16  # 面向下
          turn_down
        when 17  # 面向左
          turn_left
        when 18  # 面向右
          turn_right
        when 19  # 面向上
          turn_up
        when 20  # 向右转 90 度
          turn_right_90
        when 21  # 向左转 90 度
          turn_left_90
        when 22  # 旋转 180 度
          turn_180
        when 23  # 从右向左转 90 度
          turn_right_or_left_90
        when 24  # 随机变换方向
          turn_random
        when 25  # 面向主角的方向
          turn_toward_player
        when 26  # 背向主角的方向
          turn_away_from_player
        end
        @move_route_index += 1
        return
      end
      # 其它指令的场合
      if command.code >= 27
        # 命令编号分支
        case command.code
        when 27  # 开关 ON
          $game_switches[command.parameters[0]] = true
          $game_map.need_refresh = true
        when 28  # 开关 OFF
          $game_switches[command.parameters[0]] = false
          $game_map.need_refresh = true
        when 29  # 更改移动速度
          @move_speed = command.parameters[0]
        when 30  # 更改移动频度
          @move_frequency = command.parameters[0]
        when 31  # 移动时动画 ON
          @walk_anime = true
        when 32  # 移动时动画 OFF
          @walk_anime = false
        when 33  # 停止时动画 ON
          @step_anime = true
        when 34  # 停止时动画 OFF
          @step_anime = false
        when 35  # 朝向固定 ON
          @direction_fix = true
        when 36  # 朝向固定 OFF
          @direction_fix = false
        when 37  # 穿透 ON
          @through = true
        when 38  # 穿透 OFF
          @through = false
        when 39  # 在最前面显示 ON
          @always_on_top = true
        when 40  # 在最前面显示 OFF
          @always_on_top = false
        when 41  # 更改图形
          @tile_id = 0
          @character_name = command.parameters[0]
          @character_hue = command.parameters[1]
          if @original_direction != command.parameters[2]
            @direction = command.parameters[2]
            @original_direction = @direction
            @prelock_direction = 0
          end
          if @original_pattern != command.parameters[3]
            @pattern = command.parameters[3]
            @original_pattern = @pattern
          end
        when 42  # 更改不透明度
          @opacity = command.parameters[0]
        when 43  # 更改合成方式
          @blend_type = command.parameters[0]
        when 44  # 演奏 SE
          $game_system.se_play(command.parameters[0])
        when 45  # 脚本
          result = eval(command.parameters[0])
        end
        @move_route_index += 1
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 增加步数
  #--------------------------------------------------------------------------
  def increase_steps
    # 清除停止步数
    @stop_count = 0
  end
end
