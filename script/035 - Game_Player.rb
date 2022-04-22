#==============================================================================
# ■ Game_Player
#------------------------------------------------------------------------------
# 　处理主角的类。事件启动的判定、以及地图的滚动等功能。
# 本类的实例请参考 $game_player。
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● 常量
  #--------------------------------------------------------------------------
  CENTER_X = (320 - 16) * 4   # 画面中央的 X 坐标 * 4
  CENTER_Y = (240 - 16) * 4   # 画面中央的 Y 坐标 * 4
  #--------------------------------------------------------------------------
  # ● 可以通行判定
  #     x : X 坐标
  #     y : Y 坐标
  #     d : 方向 (0,2,4,6,8)  ※ 0 = 全方向不能通行的情况判定 (跳跃用)
  #--------------------------------------------------------------------------
  def passable?(x, y, d)
    # 求得新的坐标
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # 坐标在地图外的情况下
    unless $game_map.valid?(new_x, new_y)
      # 不能通行
      return false
    end
    # 调试模式为 ON 并且 按下 CTRL 键的情况下
    if $DEBUG and Input.press?(Input::CTRL)
      # 可以通行
      return true
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 以画面中央为基准设置地图的显示位置
  #--------------------------------------------------------------------------
  def center(x, y)
    max_x = ($game_map.width - 20) * 128
    max_y = ($game_map.height - 15) * 128
    $game_map.display_x = [0, [x * 128 - CENTER_X, max_x].min].max
    $game_map.display_y = [0, [y * 128 - CENTER_Y, max_y].min].max
  end
  #--------------------------------------------------------------------------
  # ● 向指定的位置移动
  #     x : X 坐标
  #     y : Y 坐标
  #--------------------------------------------------------------------------
  def moveto(x, y)
    super
    # 自连接
    center(x, y)
    # 生成遇敌计数
    make_encounter_count
  end
  #--------------------------------------------------------------------------
  # ● 增加步数
  #--------------------------------------------------------------------------
  def increase_steps
    super
    # 不是强制移动路线的场合
    unless @move_route_forcing
      # 增加步数
      $game_party.increase_steps
      # 步数是偶数的情况下
      if $game_party.steps % 2 == 0
        # 检查连续伤害
        $game_party.check_map_slip_damage
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取遇敌计数
  #--------------------------------------------------------------------------
  def encounter_count
    return @encounter_count
  end
  #--------------------------------------------------------------------------
  # ● 生成遇敌计数
  #--------------------------------------------------------------------------
  def make_encounter_count
    # 两种颜色震动的图像
    if $game_map.map_id != 0
      n = $game_map.encounter_step
      @encounter_count = rand(n) + rand(n) + 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    # 获取带头的角色
    actor = $game_actor
    # 设置角色的文件名及对像
    @character_name = actor.character_name
    @character_hue = actor.character_hue
    # 初始化不透明度和合成方式
    @opacity = 255
    @blend_type = 0
  end
  #--------------------------------------------------------------------------
  # ● 同位置的事件启动判定
  #--------------------------------------------------------------------------
  def check_event_trigger_here(triggers)
    result = false
    # 事件执行中的情况下
    if $game_system.map_interpreter.running?
      return result
    end
    # 全部事件的循环
    for event in $game_map.events.values
      # 事件坐标与目标一致的情况下
      if event.x == @x and event.y == @y and triggers.include?(event.trigger)
        # 跳跃中以外的情况下、启动判定是同位置的事件
        if not event.jumping? and event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ● 正面事件的启动判定
  #--------------------------------------------------------------------------
  def check_event_trigger_there(triggers)
    result = false
    # 事件执行中的情况下
    if $game_system.map_interpreter.running?
      return result
    end
    # 计算正面坐标
    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    # 全部事件的循环
    for event in $game_map.events.values
      # 事件坐标与目标一致的情况下
      if event.x == new_x and event.y == new_y and
         triggers.include?(event.trigger)
        # 跳跃中以外的情况下、启动判定是正面的事件
        if not event.jumping? and not event.over_trigger?
          event.start
          result = true
        end
      end
    end
    # 找不到符合条件的事件的情况下
    if result == false
      # 正面的元件是计数器的情况下
      if $game_map.counter?(new_x, new_y)
        # 计算 1 元件里侧的坐标
        new_x += (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
        new_y += (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
        # 全事件的循环
        for event in $game_map.events.values
          # 事件坐标与目标一致的情况下
          if event.x == new_x and event.y == new_y and
             triggers.include?(event.trigger)
            # 跳跃中以外的情况下、启动判定是正面的事件
            if not event.jumping? and not event.over_trigger?
              event.start
              result = true
            end
          end
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ● 接触事件启动判定
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    result = false
    # 事件执行中的情况下
    if $game_system.map_interpreter.running?
      return result
    end
    # 全事件的循环
    for event in $game_map.events.values
      # 事件坐标与目标一致的情况下
      if event.x == x and event.y == y and [1,2].include?(event.trigger)
        # 跳跃中以外的情况下、启动判定是正面的事件
        if not event.jumping? and not event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ● 画面更新
  #--------------------------------------------------------------------------
  def update
    # 本地变量记录移动信息
    last_moving = moving?
    # 移动中、事件执行中、强制移动路线中、
    unless moving?
      @scratch = false
      @step_anime = false
    end
    # 信息窗口一个也不显示的时候
    unless moving? or $game_system.map_interpreter.running? or
           @move_route_forcing or $game_temp.message_window_showing
      # 如果方向键被按下、主角就朝那个方向移动
      case Input.dir4
      when 2
        move_down
      when 4
        move_left
      when 6
        move_right
      when 8
        move_up
      end
    end
    # 本地变量记忆坐标
    last_real_x = @real_x
    last_real_y = @real_y
    super
    # 角色向下移动、画面上的位置在中央下方的情况下
    if @real_y > last_real_y and @real_y - $game_map.display_y > CENTER_Y
      # 画面向下卷动
      $game_map.scroll_down(@real_y - last_real_y)
    end
    # 角色向左移动、画面上的位置在中央左方的情况下
    if @real_x < last_real_x and @real_x - $game_map.display_x < CENTER_X
      # 画面向左卷动
      $game_map.scroll_left(last_real_x - @real_x)
    end
    # 角色向右移动、画面上的位置在中央右方的情况下
    if @real_x > last_real_x and @real_x - $game_map.display_x > CENTER_X
      # 画面向右卷动
      $game_map.scroll_right(@real_x - last_real_x)
    end
    # 角色向上移动、画面上的位置在中央上方的情况下
    if @real_y < last_real_y and @real_y - $game_map.display_y < CENTER_Y
      # 画面向上卷动
      $game_map.scroll_up(last_real_y - @real_y)
    end
    # 不在移动中的情况下
    unless moving?
      # 上次主角移动中的情况
      if last_moving
        # 与同位置的事件接触就判定为事件启动
        result = check_event_trigger_here([1,2])
        # 没有可以启动的事件的情况下
        if result == false
          # 调试模式为 ON 并且按下 CTRL 键的情况下除外
          unless $DEBUG and Input.press?(Input::CTRL)
            # 遇敌计数下降
            if @encounter_count > 0
              @encounter_count -= 1
            end
          end
        end
      end
      # 按下 C 键的情况下
      if Input.trigger?(Input::C)
        # 判定为同位置以及正面的事件启动
        check_event_trigger_here([0])
        check_event_trigger_there([0,1,2])
      end
    end
  end
end
