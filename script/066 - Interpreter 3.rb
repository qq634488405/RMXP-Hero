#==============================================================================
# ■ Interpreter (分割定义 3)
#------------------------------------------------------------------------------
# 　执行事件指令的解释器。本类在 Game_System 类
# 和 Game_Event 类的内部使用。
#==============================================================================

class Interpreter
  #--------------------------------------------------------------------------
  # ● 显示文章
  #--------------------------------------------------------------------------
  def command_101
    # 另外的文章已经设置过 message_text 的情况下
    if $game_temp.message_text != nil
      # 结束
      return false
    end
    # 设置信息结束后待机和返回调用标志
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # message_text 设置为 1 行
    $game_temp.message_text = @list[@index].parameters[0] + "\n"
    line_count = 1
    # 循环
    loop do
      # 下一个事件指令为文章两行以上的情况
      if @list[@index+1].code == 401
        # message_text 添加到第 2 行以下
        $game_temp.message_text += @list[@index+1].parameters[0] + "\n"
        line_count += 1
      # 事件指令不在文章两行以下的情况
      else
        # 下一个事件指令为显示选择项的情况下
        if @list[@index+1].code == 102
          # 如果选择项能收纳在画面里
          if @list[@index+1].parameters[0].size <= 4 - line_count
            # 推进索引
            @index += 1
            # 设置选择项
            $game_temp.choice_start = line_count
            setup_choices(@list[@index].parameters)
          end
        # 下一个事件指令为处理输入数值的情况下
        elsif @list[@index+1].code == 103
          # 如果数值输入窗口能收纳在画面里
          if line_count < 4
            # 推进索引
            @index += 1
            # 设置输入数值
            $game_temp.num_input_start = line_count
            $game_temp.num_input_variable_id = @list[@index].parameters[0]
            $game_temp.num_input_digits_max = @list[@index].parameters[1]
          end
        end
        # 继续
        return true
      end
      # 推进索引
      @index += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示选择项
  #--------------------------------------------------------------------------
  def command_102
    # 文章已经设置过 message_text 的情况下
    if $game_temp.message_text != nil
      # 结束
      return false
    end
    # 设置信息结束后待机和返回调用标志
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # 设置选择项
    $game_temp.message_text = ""
    $game_temp.choice_start = 0
    setup_choices(@parameters)
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● [**] 的情况下
  #--------------------------------------------------------------------------
  def command_402
    # 如果符合的选择项被选择
    if @branch[@list[@index].indent] == @parameters[0]
      # 删除分支数据
      @branch.delete(@list[@index].indent)
      # 继续
      return true
    end
    # 不符合条件的情况下 : 指令跳转
    return command_skip
  end
  #--------------------------------------------------------------------------
  # ● 取消的情况下
  #--------------------------------------------------------------------------
  def command_403
    # 如果选择了选择项取消
    if @branch[@list[@index].indent] == 4
      # 删除分支数据
      @branch.delete(@list[@index].indent)
      # 继续
      return true
    end
    # 不符合条件的情况下 : 指令跳转
    return command_skip
  end
  #--------------------------------------------------------------------------
  # ● 处理数值输入
  #--------------------------------------------------------------------------
  def command_103
    # 文章已经设置过 message_text 的情况下
    if $game_temp.message_text != nil
      # 结束
      return false
    end
    # 设置信息结束后待机和返回调用标志
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # 设置数值输入
    $game_temp.message_text = ""
    $game_temp.num_input_start = 0
    $game_temp.num_input_variable_id = @parameters[0]
    $game_temp.num_input_digits_max = @parameters[1]
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改文章选项
  #--------------------------------------------------------------------------
  def command_104
    # 正在显示信息的情况下
    if $game_temp.message_window_showing
      # 结束
      return false
    end
    # 更改各个选项
    $game_system.message_position = @parameters[0]
    $game_system.message_frame = @parameters[1]
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 处理按键输入
  #--------------------------------------------------------------------------
  def command_105
    # 设置按键输入用变量 ID
    @button_input_variable_id = @parameters[0]
    # 推进索引
    @index += 1
    # 结束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 等待
  #--------------------------------------------------------------------------
  def command_106
    # 设置等待计数
    @wait_count = @parameters[0] * 2
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 条件分支
  #--------------------------------------------------------------------------
  def command_111
    # 初始化本地变量 result
    result = false
    # 条件判定
    case @parameters[0]
    when 0  # 开关
      result = ($game_switches[@parameters[1]] == (@parameters[2] == 0))
    when 1  # 变量
      value1 = $game_variables[@parameters[1]]
      if @parameters[2] == 0
        value2 = @parameters[3]
      else
        value2 = $game_variables[@parameters[3]]
      end
      case @parameters[4]
      when 0  # 等于
        result = (value1 == value2)
      when 1  # 以上
        result = (value1 >= value2)
      when 2  # 以下
        result = (value1 <= value2)
      when 3  # 超过
        result = (value1 > value2)
      when 4  # 未满
        result = (value1 < value2)
      when 5  # 以外
        result = (value1 != value2)
      end
    when 2  # 独立开关
      if @event_id > 0
        key = [$game_map.map_id, @event_id, @parameters[1]]
        if @parameters[2] == 0
          result = ($game_self_switches[key] == true)
        else
          result = ($game_self_switches[key] != true)
        end
      end
    when 3  # 计时器
      if $game_system.timer_working
        sec = $game_system.timer / Graphics.frame_rate
        if @parameters[2] == 0
          result = (sec >= @parameters[1])
        else
          result = (sec <= @parameters[1])
        end
      end
    when 4  # 角色
      actor = $game_actors[@parameters[1]]
      if actor != nil
        case @parameters[2]
        when 0  # 同伴
          result = ($game_party.actors.include?(actor))
        when 1  # 名称
          result = (actor.name == @parameters[3])
        when 2  # 特技
          result = (actor.skill_learn?(@parameters[3]))
        when 3  # 武器
          result = (actor.weapon_id == @parameters[3])
        when 4  # 防具
  result = (actor.armor1_id == @parameters[3] or
                    actor.armor2_id == @parameters[3] or
                    actor.armor3_id == @parameters[3] or
                    actor.armor4_id == @parameters[3])
        when 5  # 状态
          result = (actor.state?(@parameters[3]))
        end
      end
    when 5  # 敌人
      enemy = $game_troop.enemies[@parameters[1]]
      if enemy != nil
        case @parameters[2]
        when 0  # 出现
          result = (enemy.exist?)
        when 1  # 状态
          result = (enemy.state?(@parameters[3]))
        end
      end
    when 6  # 角色
      character = get_character(@parameters[1])
      if character != nil
        result = (character.direction == @parameters[2])
      end
    when 7  # 金钱
      if @parameters[2] == 0
        result = ($game_party.gold >= @parameters[1])
      else
        result = ($game_party.gold <= @parameters[1])
      end
    when 8  # 物品
      result = ($game_party.item_number(@parameters[1]) > 0)
    when 9  # 武器
      result = ($game_party.weapon_number(@parameters[1]) > 0)
    when 10  # 防具
      result = ($game_party.armor_number(@parameters[1]) > 0)
    when 11  # 按钮
      result = (Input.press?(@parameters[1]))
    when 12  # 活动块
      result = eval(@parameters[1])
    end
    # 判断结果保存在 hash 中
    @branch[@list[@index].indent] = result
    # 判断结果为真的情况下
    if @branch[@list[@index].indent] == true
      # 删除分支数据
      @branch.delete(@list[@index].indent)
      # 继续
      return true
    end
    # 不符合条件的情况下 : 指令跳转
    return command_skip
  end
  #--------------------------------------------------------------------------
  # ● 这以外的情况
  #--------------------------------------------------------------------------
  def command_411
    # 判断结果为假的情况下
    if @branch[@list[@index].indent] == false
      # 删除分支数据
      @branch.delete(@list[@index].indent)
      # 继续
      return true
    end
    # 不符合条件的情况下 : 指令跳转
    return command_skip
  end
  #--------------------------------------------------------------------------
  # ● 循环
  #--------------------------------------------------------------------------
  def command_112
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 循环上次
  #--------------------------------------------------------------------------
  def command_413
    # 获取缩进
    indent = @list[@index].indent
    # 循环
    loop do
      # 推进索引
      @index -= 1
      # 本事件指令是同等级的缩进的情况下
      if @list[@index].indent == indent
        # 继续
        return true
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 中断循环
  #--------------------------------------------------------------------------
  def command_113
    # 获取缩进
    indent = @list[@index].indent
    # 将缩进复制到临时变量中
    temp_index = @index
    # 循环
    loop do
      # 推进索引
      temp_index += 1
      # 没找到符合的循环的情况下
      if temp_index >= @list.size-1
        # 继续
        return true
      end
      # 本事件命令为 [重复上次] 的情况下
      if @list[temp_index].code == 413 and @list[temp_index].indent < indent
        # 刷新索引
        @index = temp_index
        # 继续
        return true
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 中断事件处理
  #--------------------------------------------------------------------------
  def command_115
    # 结束事件
    command_end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 事件暂时删除
  #--------------------------------------------------------------------------
  def command_116
    # 事件 ID 有效的情况下
    if @event_id > 0
      # 删除事件
      $game_map.events[@event_id].erase
    end
    # 推进索引
    @index += 1
    # 继续
    return false
  end
  #--------------------------------------------------------------------------
  # ● 公共事件
  #--------------------------------------------------------------------------
  def command_117
    # 获取公共事件
    common_event = $data_common_events[@parameters[0]]
    # 公共事件有效的情况下
    if common_event != nil
      # 生成子解释器
      @child_interpreter = Interpreter.new(@depth + 1)
      @child_interpreter.setup(common_event.list, @event_id)
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 标签
  #--------------------------------------------------------------------------
  def command_118
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 标签跳转
  #--------------------------------------------------------------------------
  def command_119
    # 获取标签名
    label_name = @parameters[0]
    # 初始化临时变量
    temp_index = 0
    # 循环
    loop do
      # 没找到符合的标签的情况下
      if temp_index >= @list.size-1
        # 继续
        return true
      end
      # 本事件指令为指定的标签的名称的情况下
      if @list[temp_index].code == 118 and
         @list[temp_index].parameters[0] == label_name
        # 刷新索引
        @index = temp_index
        # 继续
        return true
      end
      # 推进索引
      temp_index += 1
    end
  end
end
