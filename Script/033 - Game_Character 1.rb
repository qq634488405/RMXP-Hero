#==============================================================================
# ■ Game_Character (分割定义 1)
#------------------------------------------------------------------------------
# 　处理角色的类。本类作为 Game_Player 类与 Game_Event
# 类的超级类使用。
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :id                       # ID
  attr_reader   :x                        # 地图 X 坐标 (理论坐标)
  attr_reader   :y                        # 地图 Y 坐标 (理论坐标)
  attr_reader   :real_x                   # 地图 X 坐标 (实际坐标 * 128)
  attr_reader   :real_y                   # 地图 Y 坐标 (实际坐标 * 128)
  attr_reader   :tile_id                  # 元件 ID  (0 为无效)
  attr_reader   :character_name           # 角色 文件名
  attr_reader   :character_hue            # 角色 色相
  attr_reader   :opacity                  # 不透明度
  attr_reader   :blend_type               # 合成方式
  attr_reader   :direction                # 朝向
  attr_reader   :pattern                  # 图案
  attr_reader   :move_route_forcing       # 移动路线强制标志
  attr_reader   :through                  # 穿透
  attr_accessor :animation_id             # 动画 ID
  attr_accessor :transparent              # 透明状态
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    @id = 0
    @x = 0
    @y = 0
    @real_x = 0
    @real_y = 0
    @tile_id = 0
    @character_name = ""
    @character_hue = 0
    @opacity = 255
    @blend_type = 0
    @direction = 2
    @pattern = 0
    @move_route_forcing = false
    @through = false
    @animation_id = 0
    @transparent = false
    @original_direction = 2
    @original_pattern = 0
    @move_type = 0
    @move_speed = 4
    @move_frequency = 6
    @move_route = nil
    @move_route_index = 0
    @original_move_route = nil
    @original_move_route_index = 0
    @walk_anime = true
    @step_anime = false
    @direction_fix = false
    @always_on_top = false
    @anime_count = 0
    @stop_count = 0
    @jump_count = 0
    @jump_peak = 0
    @wait_count = 0
    @locked = false
    @prelock_direction = 0
  end
  #--------------------------------------------------------------------------
  # ● 移动中判定
  #--------------------------------------------------------------------------
  def moving?
    # 如果在移动中理论坐标与实际坐标不同
    return (@real_x != @x * 128 or @real_y != @y * 128)
  end
  #--------------------------------------------------------------------------
  # ● 跳跃中判定
  #--------------------------------------------------------------------------
  def jumping?
    # 如果跳跃中跳跃点数比 0 大
    return @jump_count > 0
  end
  #--------------------------------------------------------------------------
  # ● 矫正姿势
  #--------------------------------------------------------------------------
  def straighten
    # 移动时动画以及停止动画为 ON 的情况下
    if @walk_anime or @step_anime
      # 设置图形为 0
      @pattern = 0
    end
    # 清除动画计数
    @anime_count = 0
    # 清除被锁定的向前朝向
    @prelock_direction = 0
  end
  #--------------------------------------------------------------------------
  # ● 强制移动路线
  #     move_route : 新的移动路线
  #--------------------------------------------------------------------------
  def force_move_route(move_route)
    # 保存原来的移动路线
    if @original_move_route == nil
      @original_move_route = @move_route
      @original_move_route_index = @move_route_index
    end
    # 更改移动路线
    @move_route = move_route
    @move_route_index = 0
    # 设置强制移动路线标志
    @move_route_forcing = true
    # 清除被锁定的向前朝向
    @prelock_direction = 0
    # 清除等待计数
    @wait_count = 0
    # 自定义移动
    move_type_custom
  end
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
    # 坐标在地图以外的情况
    unless $game_map.valid?(new_x, new_y)
      # 不能通行
      return false
    end
    # 穿透是 ON 的情况下
    if @through
      # 可以通行
      return true
    end
    # 移动者的元件无法来到指定方向的情况下
    unless $game_map.passable?(x, y, d, self)
      # 通行不可
      return false
    end
    # 从指定方向不能进入到移动处的元件的情况下
    unless $game_map.passable?(new_x, new_y, 10 - d)
      # 不能通行
      return false
    end
    # 循环全部事件
    for event in $game_map.events.values
      # 事件坐标于移动目标坐标一致的情况下
      if event.x == new_x and event.y == new_y
        # 穿透为 ON
        unless event.through
          # 自己就是事件的情况下
          if self != $game_player
            # 不能通行
            return false
          end
          # 自己是主角、对方的图形是角色的情况下
          if event.character_name != ""
            # 不能通行
            return false
          end
        end
      end
    end
    # 主角的坐标与移动目标坐标一致的情况下
    if $game_player.x == new_x and $game_player.y == new_y
      # 穿透为 ON
      unless $game_player.through
        # 自己的图形是角色的情况下
        if @character_name != ""
          # 不能通行
          return false
        end
      end
    end
    # 可以通行
    return true
  end
  #--------------------------------------------------------------------------
  # ● 锁定
  #--------------------------------------------------------------------------
  def lock
    # 如果已经被锁定的情况下
    if @locked
      # 过程结束
      return
    end
    # 保存锁定前的朝向
    @prelock_direction = @direction
    # 保存主角的朝向
    turn_toward_player
    # 设置锁定中标志
    @locked = true
  end
  #--------------------------------------------------------------------------
  # ● 锁定中判定
  #--------------------------------------------------------------------------
  def lock?
    return @locked
  end
  #--------------------------------------------------------------------------
  # ● 解除锁定
  #--------------------------------------------------------------------------
  def unlock
    # 没有锁定的情况下
    unless @locked
      # 过程结束
      return
    end
    # 清除锁定中标志
    @locked = false
    # 没有固定朝向的情况下
    unless @direction_fix
      # 如果保存了锁定前的方向
      if @prelock_direction != 0
        # 还原为锁定前的方向
        @direction = @prelock_direction
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 移动到指定位置
  #     x : X 坐标
  #     y : Y 坐标
  #--------------------------------------------------------------------------
  def moveto(x, y)
    @x = x % $game_map.width
    @y = y % $game_map.height
    @real_x = @x * 128
    @real_y = @y * 128
    @prelock_direction = 0
  end
  #--------------------------------------------------------------------------
  # ● 获取画面 X 坐标
  #--------------------------------------------------------------------------
  def screen_x
    # 通过实际坐标和地图的显示位置来求得画面坐标
    return (@real_x - $game_map.display_x + 3) / 4 + 16
  end
  #--------------------------------------------------------------------------
  # ● 获取画面 Y 坐标
  #--------------------------------------------------------------------------
  def screen_y
    # 通过实际坐标和地图的显示位置来求得画面坐标
    y = (@real_y - $game_map.display_y + 3) / 4 + 32
    # 取跳跃计数小的 Y 坐标
    if @jump_count >= @jump_peak
      n = @jump_count - @jump_peak
    else
      n = @jump_peak - @jump_count
    end
    return y - (@jump_peak * @jump_peak - n * n) / 2
  end
  #--------------------------------------------------------------------------
  # ● 获取画面 Z 坐标
  #     height : 角色的高度
  #--------------------------------------------------------------------------
  def screen_z(height = 0)
    # 在最前显示的标志为 ON 的情况下
    if @always_on_top
      # 无条件设置为 999
      return 999
    end
    # 通过实际坐标和地图的显示位置来求得画面坐标
    z = (@real_y - $game_map.display_y + 3) / 4 + 32
    # 元件的情况下
    if @tile_id > 0
      # 元件的优先不足 * 32 
      return z + $game_map.priorities[@tile_id] * 32
    # 角色的场合
    else
      # 如果高度超过 32 就判定为满足 31
      return z + ((height > 32) ? 31 : 0)
    end
  end
  #--------------------------------------------------------------------------
  # ● 取得繁茂
  #--------------------------------------------------------------------------
  def bush_depth
    # 是元件、并且在最前显示为 ON 的情况下
    if @tile_id > 0 or @always_on_top
      return 0
    end
    # 在跳跃以外的状态时繁茂处元件的属性为 12，除此之外为 0
    if @jump_count == 0 and $game_map.bush?(@x, @y)
      return 12
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 取得地形标记
  #--------------------------------------------------------------------------
  def terrain_tag
    return $game_map.terrain_tag(@x, @y)
  end
end
