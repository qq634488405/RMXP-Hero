#==============================================================================
# ■ Game_Character (分割定义 3)
#------------------------------------------------------------------------------
# 　处理角色的类。本类作为 Game_Player 类与 Game_Event
# 类的超级类使用。
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # ● 向下移动
  #     turn_enabled : 本场地位置更改许可标志
  #--------------------------------------------------------------------------
  def move_down(turn_enabled = true)
    # 面向下
    if turn_enabled
      turn_down
    end
    # 可以通行的场合
    if passable?(@x, @y, 2)
      # 面向下
      turn_down
      # 更新坐标
      @y += 1
      # 增加步数
      increase_steps
    # 不能通行的情况下
    else
      # 接触事件的启动判定
      check_event_trigger_touch(@x, @y+1)
      @scratch = true
      @step_anime = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 向左移动
  #     turn_enabled : 本场地位置更改许可标志
  #--------------------------------------------------------------------------
  def move_left(turn_enabled = true)
    # 面向左
    if turn_enabled
      turn_left
    end
    # 可以通行的情况下
    if passable?(@x, @y, 4)
      # 面向左
      turn_left
      # 更新坐标
      @x -= 1
      # 增加步数
      increase_steps
    # 不能通行的情况下
    else
      # 接触事件的启动判定
      check_event_trigger_touch(@x-1, @y)
      @scratch = true
      @step_anime = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 向右移动
  #     turn_enabled : 本场地位置更改许可标志
  #--------------------------------------------------------------------------
  def move_right(turn_enabled = true)
    # 面向右
    if turn_enabled
      turn_right
    end
    # 可以通行的场合
    if passable?(@x, @y, 6)
      # 面向右
      turn_right
      # 更新坐标
      @x += 1
      # 增加步数
      increase_steps
    # 不能通行的情况下
    else
      # 接触事件的启动判定
      check_event_trigger_touch(@x+1, @y)
      @scratch = true
      @step_anime = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 向上移动
  #     turn_enabled : 本场地位置更改许可标志
  #--------------------------------------------------------------------------
  def move_up(turn_enabled = true)
    # 面向上
    if turn_enabled
      turn_up
    end
    # 可以通行的情况下
    if passable?(@x, @y, 8)
      # 面向上
      turn_up
      # 更新坐标
      @y -= 1
      # 歩数増加
      increase_steps
    # 不能通行的情况下
    else
      # 接触事件的启动判定
      check_event_trigger_touch(@x, @y-1)
      @scratch = true
      @step_anime = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 向左下移动
  #--------------------------------------------------------------------------
  def move_lower_left
    # 没有固定面向的场合
    unless @direction_fix
      # 朝向是右的情况下适合的面是左面、朝向是上的情况下适合的面是下面
      @direction = (@direction == 6 ? 4 : @direction == 8 ? 2 : @direction)
    end
    # 下→左、左→下 的通道可以通行的情况下
    if (passable?(@x, @y, 2) and passable?(@x, @y + 1, 4)) or
       (passable?(@x, @y, 4) and passable?(@x - 1, @y, 2))
      # 更新坐标
      @x -= 1
      @y += 1
      # 增加步数
      increase_steps
    end
  end
  #--------------------------------------------------------------------------
  # ● 向右下移动
  #--------------------------------------------------------------------------
  def move_lower_right
    # 没有固定面向的场合
    unless @direction_fix
      # 朝向是右的情况下适合的面是左面、朝向是上的情况下适合的面是下面
      @direction = (@direction == 4 ? 6 : @direction == 8 ? 2 : @direction)
    end
    # 下→右、右→下 的通道可以通行的情况下
    if (passable?(@x, @y, 2) and passable?(@x, @y + 1, 6)) or
       (passable?(@x, @y, 6) and passable?(@x + 1, @y, 2))
      # 更新坐标
      @x += 1
      @y += 1
      # 增加步数
      increase_steps
    end
  end
  #--------------------------------------------------------------------------
  # ● 向左上移动
  #--------------------------------------------------------------------------
  def move_upper_left
    # 没有固定面向的场合
    unless @direction_fix
      # 朝向是右的情况下适合的面是左面、朝向是上的情况下适合的面是下面
      @direction = (@direction == 6 ? 4 : @direction == 2 ? 8 : @direction)
    end
    # 上→左、左→上 的通道可以通行的情况下
    if (passable?(@x, @y, 8) and passable?(@x, @y - 1, 4)) or
       (passable?(@x, @y, 4) and passable?(@x - 1, @y, 8))
      # 更新坐标
      @x -= 1
      @y -= 1
      # 增加步数
      increase_steps
    end
  end
  #--------------------------------------------------------------------------
  # ● 向右上移动
  #--------------------------------------------------------------------------
  def move_upper_right
    # 没有固定面向的场合
    unless @direction_fix
      # 朝向是右的情况下适合的面是左面、朝向是上的情况下适合的面是下面
      @direction = (@direction == 4 ? 6 : @direction == 2 ? 8 : @direction)
    end
    # 上→右、右→上 的通道可以通行的情况下
    if (passable?(@x, @y, 8) and passable?(@x, @y - 1, 6)) or
       (passable?(@x, @y, 6) and passable?(@x + 1, @y, 8))
      # 更新坐标
      @x += 1
      @y -= 1
      # 增加步数
      increase_steps
    end
  end
  #--------------------------------------------------------------------------
  # ● 随机移动
  #--------------------------------------------------------------------------
  def move_random
    case rand(4)
    when 0  # 向下移动
      move_down(false)
    when 1  # 向左移动
      move_left(false)
    when 2  # 向右移动
      move_right(false)
    when 3  # 向上移动
      move_up(false)
    end
  end
  #--------------------------------------------------------------------------
  # ● 接近主角
  #--------------------------------------------------------------------------
  def move_toward_player
    # 求得与主角的坐标差
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # 坐标相等情况下
    if sx == 0 and sy == 0
      return
    end
    # 求得差的绝对值
    abs_sx = sx.abs
    abs_sy = sy.abs
    # 横距离与纵距离相等的情况下
    if abs_sx == abs_sy
      # 随机将边数增加 1
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    # 横侧距离长的情况下
    if abs_sx > abs_sy
      # 左右方向优先。向主角移动
      sx > 0 ? move_left : move_right
      if not moving? and sy != 0
        sy > 0 ? move_up : move_down
      end
    # 竖侧距离长的情况下
    else
      # 上下方向优先。向主角移动
      sy > 0 ? move_up : move_down
      if not moving? and sx != 0
        sx > 0 ? move_left : move_right
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 远离主角
  #--------------------------------------------------------------------------
  def move_away_from_player
    # 求得与主角的坐标差
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # 坐标相等情况下
    if sx == 0 and sy == 0
      return
    end
    # 求得差的绝对值
    abs_sx = sx.abs
    abs_sy = sy.abs
    # 横距离与纵距离相等的情况下
    if abs_sx == abs_sy
      # 随机将边数增加 1
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    # 横侧距离长的情况下
    if abs_sx > abs_sy
      # 左右方向优先。远离主角移动
      sx > 0 ? move_right : move_left
      if not moving? and sy != 0
        sy > 0 ? move_down : move_up
      end
    # 竖侧距离长的情况下
    else
      # 上下方向优先。远离主角移动
      sy > 0 ? move_down : move_up
      if not moving? and sx != 0
        sx > 0 ? move_right : move_left
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 前进一步
  #--------------------------------------------------------------------------
  def move_forward
    case @direction
    when 2
      move_down(false)
    when 4
      move_left(false)
    when 6
      move_right(false)
    when 8
      move_up(false)
    end
  end
  #--------------------------------------------------------------------------
  # ● 后退一步
  #--------------------------------------------------------------------------
  def move_backward
    # 记忆朝向固定信息
    last_direction_fix = @direction_fix
    # 强制固定朝向
    @direction_fix = true
    # 朝向分支
    case @direction
    when 2  # 下
      move_up(false)
    when 4  # 左
      move_right(false)
    when 6  # 右
      move_left(false)
    when 8  # 上
      move_down(false)
    end
    # 还原朝向固定信息
    @direction_fix = last_direction_fix
  end
  #--------------------------------------------------------------------------
  # ● 跳跃
  #     x_plus : X 坐标增加值
  #     y_plus : Y 坐标增加值
  #--------------------------------------------------------------------------
  def jump(x_plus, y_plus)
    # 增加值不是 (0,0) 的情况下
    if x_plus != 0 or y_plus != 0
      # 横侧距离长的情况下
      if x_plus.abs > y_plus.abs
        # 变更左右方向
        x_plus < 0 ? turn_left : turn_right
      # 竖侧距离长的情况下
      else
        # 变更上下方向
        y_plus < 0 ? turn_up : turn_down
      end
    end
    # 计算新的坐标
    new_x = @x + x_plus
    new_y = @y + y_plus
    # 增加值为 (0,0) 的情况下、跳跃目标可以通行的场合
    if (x_plus == 0 and y_plus == 0) or passable?(new_x, new_y, 0)
      # 矫正姿势
      straighten
      # 更新坐标
      @x = new_x
      @y = new_y
      # 距计算距离
      distance = Math.sqrt(x_plus * x_plus + y_plus * y_plus).round
      # 设置跳跃记数
      @jump_peak = 10 + distance - @move_speed
      @jump_count = @jump_peak * 2
      # 清除停止记数信息
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 面向向下
  #--------------------------------------------------------------------------
  def turn_down
    unless @direction_fix
      @direction = 2
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 面向向左
  #--------------------------------------------------------------------------
  def turn_left
    unless @direction_fix
      @direction = 4
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 面向向右
  #--------------------------------------------------------------------------
  def turn_right
    unless @direction_fix
      @direction = 6
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 面向向上
  #--------------------------------------------------------------------------
  def turn_up
    unless @direction_fix
      @direction = 8
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 向右旋转 90 度
  #--------------------------------------------------------------------------
  def turn_right_90
    case @direction
    when 2
      turn_left
    when 4
      turn_up
    when 6
      turn_down
    when 8
      turn_right
    end
  end
  #--------------------------------------------------------------------------
  # ● 向左旋转 90 度
  #--------------------------------------------------------------------------
  def turn_left_90
    case @direction
    when 2
      turn_right
    when 4
      turn_down
    when 6
      turn_up
    when 8
      turn_left
    end
  end
  #--------------------------------------------------------------------------
  # ● 旋转 180 度
  #--------------------------------------------------------------------------
  def turn_180
    case @direction
    when 2
      turn_up
    when 4
      turn_right
    when 6
      turn_left
    when 8
      turn_down
    end
  end
  #--------------------------------------------------------------------------
  # ● 从右向左旋转 90 度
  #--------------------------------------------------------------------------
  def turn_right_or_left_90
    if rand(2) == 0
      turn_right_90
    else
      turn_left_90
    end
  end
  #--------------------------------------------------------------------------
  # ● 随机变换方向
  #--------------------------------------------------------------------------
  def turn_random
    case rand(4)
    when 0
      turn_up
    when 1
      turn_right
    when 2
      turn_left
    when 3
      turn_down
    end
  end
  #--------------------------------------------------------------------------
  # ● 接近主角的方向
  #--------------------------------------------------------------------------
  def turn_toward_player
    # 求得与主角的坐标差
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # 坐标相等的场合下
    if sx == 0 and sy == 0
      return
    end
    # 横侧距离长的情况下
    if sx.abs > sy.abs
      # 将左右方向变更为朝向主角的方向
      sx > 0 ? turn_left : turn_right
    # 竖侧距离长的情况下
    else
      # 将上下方向变更为朝向主角的方向
      sy > 0 ? turn_up : turn_down
    end
  end
  #--------------------------------------------------------------------------
  # ● 背向主角的方向
  #--------------------------------------------------------------------------
  def turn_away_from_player
    # 求得与主角的坐标差
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # 坐标相等的场合下
    if sx == 0 and sy == 0
      return
    end
    # 横侧距离长的情况下
    if sx.abs > sy.abs
      # 将左右方向变更为背离主角的方向
      sx > 0 ? turn_right : turn_left
    # 竖侧距离长的情况下
    else
      # 将上下方向变更为背离主角的方向
      sy > 0 ? turn_down : turn_up
    end
  end
end
