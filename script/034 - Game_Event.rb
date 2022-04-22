#==============================================================================
# ■ Game_Event
#------------------------------------------------------------------------------
# 　处理事件的类。条件判断、事件页的切换、并行处理、执行事件功能
# 在 Game_Map 类的内部使用。
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :trigger                  # 目标
  attr_reader   :list                     # 执行内容
  attr_reader   :starting                 # 启动中标志
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     map_id : 地图 ID
  #     event  : 事件 (RPG::Event)
  #--------------------------------------------------------------------------
  def initialize(map_id, event)
    super()
    @map_id = map_id
    @event = event
    @id = @event.id
    @erased = false
    @starting = false
    @through = true
    # 初期位置的移动
    moveto(@event.x, @event.y)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 清除移动中标志
  #--------------------------------------------------------------------------
  def clear_starting
    @starting = false
  end
  #--------------------------------------------------------------------------
  # ● 越过目标判定 (不能将相同位置作为启动条件)
  #--------------------------------------------------------------------------
  def over_trigger?
    # 图形是角色、没有开启穿透的情况下
    if @character_name != "" and not @through
      # 启动判定是正面
      return false
    end
    # 地图上的这个位置不能通行的情况下
    unless $game_map.passable?(@x, @y, 0)
      # 启动判定是正面
      return false
    end
    # 启动判定在同位置
    return true
  end
  #--------------------------------------------------------------------------
  # ● 启动事件
  #--------------------------------------------------------------------------
  def start
    # 执行内容不为空的情况下
    if @list.size > 1
      @starting = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 暂时消失
  #--------------------------------------------------------------------------
  def erase
    @erased = true
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    # 初始化本地变量 new_page
    new_page = nil
    # 无法暂时消失的情况下
    unless @erased
      # 从编号大的事件页按顺序调查
      for page in @event.pages.reverse
        # 可以参考事件条件 c
        c = page.condition
        # 确认开关条件 1 
        if c.switch1_valid
          if $game_switches[c.switch1_id] == false
            next
          end
        end
        # 确认开关条件 2 
        if c.switch2_valid
          if $game_switches[c.switch2_id] == false
            next
          end
        end
        # 确认变量条件
        if c.variable_valid
          if $game_variables[c.variable_id] < c.variable_value
            next
          end
        end
        # 确认独立开关条件
        if c.self_switch_valid
          key = [@map_id, @event.id, c.self_switch_ch]
          if $game_self_switches[key] != true
            next
          end
        end
        # 设置本地变量 new_page
        new_page = page
        # 跳出循环
        break
      end
    end
    # 与上次同一事件页的情况下
    if new_page == @page
      # 过程结束
      return
    end
    # @page 设置为现在的事件页
    @page = new_page
    # 清除启动中标志
    clear_starting
    # 没有满足条件的页面的时候
    if @page == nil
      # 设置各实例变量
      @tile_id = 0
      @character_name = ""
      @character_hue = 0
      @move_type = 0
      @through = true
      @trigger = nil
      @list = nil
      @interpreter = nil
      # 过程结束
      return
    end
    # 设置各实例变量
    @tile_id = @page.graphic.tile_id
    @character_name = @page.graphic.character_name
    @character_hue = @page.graphic.character_hue
    if @original_direction != @page.graphic.direction
      @direction = @page.graphic.direction
      @original_direction = @direction
      @prelock_direction = 0
    end
    if @original_pattern != @page.graphic.pattern
      @pattern = @page.graphic.pattern
      @original_pattern = @pattern
    end
    @opacity = @page.graphic.opacity
    @blend_type = @page.graphic.blend_type
    @move_type = @page.move_type
    @move_speed = @page.move_speed
    @move_frequency = @page.move_frequency
    @move_route = @page.move_route
    @move_route_index = 0
    @move_route_forcing = false
    @walk_anime = @page.walk_anime
    @step_anime = @page.step_anime
    @direction_fix = @page.direction_fix
    @through = @page.through
    @always_on_top = @page.always_on_top
    @trigger = @page.trigger
    @list = @page.list
    @interpreter = nil
    # 目标是 [并行处理] 的情况下
    if @trigger == 4
      # 生成并行处理用解释器
      @interpreter = Interpreter.new
    end
    # 自动事件启动判定
    check_event_trigger_auto
  end
  #--------------------------------------------------------------------------
  # ● 接触事件启动判定
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    # 事件执行中的情况下
    if $game_system.map_interpreter.running?
      return
    end
    # 目标为 [与事件接触] 以及和主角坐标一致的情况下
    if @trigger == 2 and x == $game_player.x and y == $game_player.y
      # 除跳跃中以外的情况、启动判定就是正面的事件
      if not jumping? and not over_trigger?
        start
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 自动事件启动判定
  #--------------------------------------------------------------------------
  def check_event_trigger_auto
    # 目标为 [与事件接触] 以及和主角坐标一致的情况下
    if @trigger == 2 and @x == $game_player.x and @y == $game_player.y
      # 除跳跃中以外的情况、启动判定就是同位置的事件
      if not jumping? and over_trigger?
        start
      end
    end
    # 目标是 [自动执行] 的情况下
    if @trigger == 3
      start
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    # 自动启动事件判定
    check_event_trigger_auto
    # 并行处理有效的情况下
    if @interpreter != nil
      # 不在执行中的场合的情况下
      unless @interpreter.running?
        # 设置事件
        @interpreter.setup(@list, @event.id)
      end
      # 更新解释器
      @interpreter.update
    end
  end
end
