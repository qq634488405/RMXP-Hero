#==============================================================================
# ■ Interpreter (分割定义 1)
#------------------------------------------------------------------------------
# 　执行事件命令的解释器。本类在 Game_System 类
# 与 Game_Event 类的内部使用。
#==============================================================================

class Interpreter
  #--------------------------------------------------------------------------
  # ● 初始化标志
  #     depth : 事件的深度
  #     main  : 主标志
  #--------------------------------------------------------------------------
  def initialize(depth = 0, main = false)
    @depth = depth
    @main = main
    # 深度超过 100 级
    if depth > 100
      print("调用公用事件超过了限制。")
      exit
    end
    # 清除注释器的内部状态
    clear
  end
  #--------------------------------------------------------------------------
  # ● 清除
  #--------------------------------------------------------------------------
  def clear
    @map_id = 0                       # 启动时的地图 ID
    @event_id = 0                     # 事件 ID
    @message_waiting = false          # 信息结束后待机中
    @move_route_waiting = false       # 移动结束后待机中
    @button_input_variable_id = 0     # 输入按钮 变量 ID
    @wait_count = 0                   # 窗口计数
    @child_interpreter = nil          # 子实例
    @branch = {}                      # 分支数据
  end
  #--------------------------------------------------------------------------
  # ● 设置事件
  #     list     : 执行内容
  #     event_id : 事件 ID
  #--------------------------------------------------------------------------
  def setup(list, event_id)
    # 清除注释器的内部状态
    clear
    # 记忆地图 ID
    @map_id = $game_map.map_id
    # 记忆事件 ID
    @event_id = event_id
    # 记忆执行内容
    @list = list
    # 初始化索引
    @index = 0
    # 清除分支数据用复述
    @branch.clear
  end
  #--------------------------------------------------------------------------
  # ● 执行中判定
  #--------------------------------------------------------------------------
  def running?
    return @list != nil
  end
  #--------------------------------------------------------------------------
  # ● 设置启动中事件
  #--------------------------------------------------------------------------
  def setup_starting_event
    # 刷新必要的地图
    if $game_map.need_refresh
      $game_map.refresh
    end
    # 如果调用的公共事件被预约的情况下
    if $game_temp.common_event_id > 0
      # 设置事件
      setup($data_common_events[$game_temp.common_event_id].list, 0)
      # 解除预约
      $game_temp.common_event_id = 0
      return
    end
    # 循环 (地图事件)
    for event in $game_map.events.values
      # 如果找到了启动中的事件
      if event.starting
        # 如果不是自动执行
        if event.trigger < 3
          # 清除启动中标志
          event.clear_starting
          # 锁定
          event.lock
        end
        # 设置事件
        setup(event.list, event.id)
        return
      end
    end
    # 循环(公共事件)
    for common_event in $data_common_events.compact
      # 目标的自动执行开关为 ON 的情况下
      if common_event.trigger == 1 and
         $game_switches[common_event.switch_id] == true
        # 设置事件
        setup(common_event.list, 0)
        return
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 初始化循环计数
    @loop_count = 0
    # 循环
    loop do
      # 循环计数加 1
      @loop_count += 1
      # 如果执行了 100 个事件指令
      if @loop_count > 100
        # 为了防止系统崩溃、调用 Graphics.update
        Graphics.update
        @loop_count = 0
      end
      # 如果地图与事件启动有差异
      if $game_map.map_id != @map_id
        # 事件 ID 设置为 0
        @event_id = 0
      end
      # 子注释器存在的情况下
      if @child_interpreter != nil
        # 刷新子注释器
        @child_interpreter.update
        # 子注释器执行结束的情况下
        unless @child_interpreter.running?
          # 删除字注释器
          @child_interpreter = nil
        end
        # 如果子注释器还存在
        if @child_interpreter != nil
          return
        end
      end
      # 信息结束待机的情况下
      if @message_waiting
        return
      end
      # 移动结束待机的情况下
      if @move_route_waiting
        # 强制主角移动路线的情况下
        if $game_player.move_route_forcing
          return
        end
        # 循环 (地图事件)
        for event in $game_map.events.values
          # 本事件为强制移动路线的情况下
          if event.move_route_forcing
            return
          end
        end
        # 清除移动结束待机中的标志
        @move_route_waiting = false
      end
      # 输入按钮待机中的情况下
      if @button_input_variable_id > 0
        # 执行按钮输入处理
        input_button
        return
      end
      # 等待中的情况下
      if @wait_count > 0
        # 减少等待计数
        @wait_count -= 1
        return
      end
      # 如果被强制行动的战斗者存在
      if $game_temp.forcing_battler != nil
        return
      end
      # 如果各画面的调用标志已经被设置
      if $game_temp.battle_calling or
         $game_temp.shop_calling or
         $game_temp.name_calling or
         $game_temp.menu_calling or
         $game_temp.save_calling or
         $game_temp.gameover
        return
      end
      # 执行内容列表为空的情况下
      if @list == nil
        # 主地图事件的情况下
        if @main
          # 设置启动中的事件
          setup_starting_event
        end
        # 什么都没有设置的情况下
        if @list == nil
          return
        end
      end
      # 尝试执行事件列表、返回值为 false 的情况下
      if execute_command == false
        return
      end
      # 推进索引
      @index += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 输入按钮
  #--------------------------------------------------------------------------
  def input_button
    # 判定按下的按钮
    n = 0
    for i in 1..18
      if Input.trigger?(i)
        n = i
      end
    end
    # 按下按钮的情况下
    if n > 0
      # 更改变量值
      $game_variables[@button_input_variable_id] = n
      $game_map.need_refresh = true
      # 输入按键结束
      @button_input_variable_id = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置选择项
  #--------------------------------------------------------------------------
  def setup_choices(parameters)
    # choice_max 为设置选择项的项目数
    $game_temp.choice_max = parameters[0].size
    # message_text 为设置选择项
    for text in parameters[0]
      $game_temp.message_text += text + "\n"
    end
    # 设置取消的情况的处理
    $game_temp.choice_cancel_type = parameters[1]
    # 返回调用设置
    current_indent = @list[@index].indent
    $game_temp.choice_proc = Proc.new { |n| @branch[current_indent] = n }
  end
  #--------------------------------------------------------------------------
  # ● 角色用 itereta (考虑全体同伴)
  #     parameter : 1 以上为 ID、0 为全体
  #--------------------------------------------------------------------------
  def iterate_actor(parameter)
    # 全体同伴的情况下
    if parameter == 0
      # 同伴全体循环
      for actor in $game_party.actors
        # 评价块
        yield actor
      end
    # 单体角色的情况下
    else
      # 获取角色
      actor = $game_actors[parameter]
      # 获取角色
      yield actor if actor != nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 敌人用 itereta (考虑队伍全体)
  #     parameter : 0 为索引、-1 为全体
  #--------------------------------------------------------------------------
  def iterate_enemy(parameter)
    # 队伍全体的情况下
    if parameter == -1
      # 队伍全体循环
      for enemy in $game_troop.enemies
        # 评价块
        yield enemy
      end
    # 敌人单体的情况下
    else
      # 获取敌人
      enemy = $game_troop.enemies[parameter]
      # 评价块
      yield enemy if enemy != nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 战斗者用 itereta (要考虑全体队伍、全体同伴)
  #     parameter1 : 0 为敌人、1 为角色
  #     parameter2 : 0 以上为索引、-1 为全体
  #--------------------------------------------------------------------------
  def iterate_battler(parameter1, parameter2)
    # 敌人的情况下
    if parameter1 == 0
      # 调用敌人的 itereta
      iterate_enemy(parameter2) do |enemy|
        yield enemy
      end
    # 角色的情况下
    else
      # 全体同伴的情况下
      if parameter2 == -1
        # 同伴全体循环
        for actor in $game_party.actors
          # 评价块
          yield actor
        end
      # 角色单体 (N 个人) 的情况下
      else
        # 获取角色
        actor = $game_party.actors[parameter2]
        # 评价块
        yield actor if actor != nil
      end
    end
  end
end
