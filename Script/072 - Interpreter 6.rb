#==============================================================================
# ■ Interpreter (分割定义 6)
#------------------------------------------------------------------------------
# 　执行事件命令的解释器。本类在 Game_System 类
# 和 Game_Event 类的内部使用。
#==============================================================================

class Interpreter
  #--------------------------------------------------------------------------
  # ● 战斗处理
  #--------------------------------------------------------------------------
  def command_301
    # 如果不是无效的队伍
    if $data_troops[@parameters[0]] != nil
      # 设置中断战斗标志
      $game_temp.battle_abort = true
      # 设置战斗调用标志
      $game_temp.battle_calling = true
      $game_temp.battle_troop_id = @parameters[0]
      $game_temp.battle_can_escape = @parameters[1]
      $game_temp.battle_can_lose = @parameters[2]
      # 设置返回调用
      current_indent = @list[@index].indent
      $game_temp.battle_proc = Proc.new { |n| @branch[current_indent] = n }
    end
    # 推进索引
    @index += 1
    # 结束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 胜利的情况下
  #--------------------------------------------------------------------------
  def command_601
    # 战斗结果为胜利的情况下
    if @branch[@list[@index].indent] == 0
      # 删除分支数据
      @branch.delete(@list[@index].indent)
      # 继续
      return true
    end
    # 不符合条件的情况下 : 指令跳转
    return command_skip
  end
  #--------------------------------------------------------------------------
  # ● 逃跑的情况下
  #--------------------------------------------------------------------------
  def command_602
    # 战斗结果为逃跑的情况下
    if @branch[@list[@index].indent] == 1
      # 删除分支数据
      @branch.delete(@list[@index].indent)
      # 继续
      return true
    end
    # 不符合条件的情况下 : 指令跳转
    return command_skip
  end
  #--------------------------------------------------------------------------
  # ● 失败的情况下
  #--------------------------------------------------------------------------
  def command_603
    # 战斗结果为失败的情况下
    if @branch[@list[@index].indent] == 2
      # 删除分支数据
      @branch.delete(@list[@index].indent)
      # 继续
      return true
    end
    # 不符合条件的情况下 : 指令跳转
    return command_skip
  end
  #--------------------------------------------------------------------------
  # ● 商店的处理
  #--------------------------------------------------------------------------
  def command_302
    # 设置战斗中断标志
    $game_temp.battle_abort = true
    # 设置商店调用标志
    $game_temp.shop_calling = true
    # 设置商品列表的新项目
    $game_temp.shop_goods = [@parameters]
    # 循环
    loop do
      # 推进索引
      @index += 1
      # 下一个事件命令在商店两行以上的情况下
      if @list[@index].code == 605
        # 在商品列表中添加新项目
        $game_temp.shop_goods.push(@list[@index].parameters)
      # 事件命令不在商店两行以上的情况下
      else
        # 技术
        return false
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 名称输入处理
  #--------------------------------------------------------------------------
  def command_303
    # 如果不是无效的角色
    if $data_actors[@parameters[0]] != nil
      # 设置战斗中断标志
      $game_temp.battle_abort = true
      # 设置名称输入调用标志
      $game_temp.name_calling = true
      $game_temp.name_actor_id = @parameters[0]
      $game_temp.name_max_char = @parameters[1]
    end
    # 推进索引
    @index += 1
    # 结束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 增减 HP
  #--------------------------------------------------------------------------
  def command_311
    # 获取操作值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 处理重复
    iterate_actor(@parameters[0]) do |actor|
      # HP 不为 0 的情况下
      if actor.hp > 0
        # 更改 HP (如果不允许战斗不能的状态就设置为 1)
        if @parameters[4] == false and actor.hp + value <= 0
          actor.hp = 1
        else
          actor.hp += value
        end
      end
    end
    # 游戏结束判定
    $game_temp.gameover = $game_party.all_dead?
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 增减 SP
  #--------------------------------------------------------------------------
  def command_312
    # 获取操作值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 处理重复
    iterate_actor(@parameters[0]) do |actor|
      # 更改角色的 SP
      actor.sp += value
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改状态
  #--------------------------------------------------------------------------
  def command_313
    # 处理重复
    iterate_actor(@parameters[0]) do |actor|
      # 更改状态
      if @parameters[1] == 0
        actor.add_state(@parameters[2])
      else
        actor.remove_state(@parameters[2])
      end
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 全回复
  #--------------------------------------------------------------------------
  def command_314
    # 处理重复
    iterate_actor(@parameters[0]) do |actor|
      # 角色全回复
      actor.recover_all
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 增减 EXP
  #--------------------------------------------------------------------------
  def command_315
    # 获取操作值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 处理重复
    iterate_actor(@parameters[0]) do |actor|
      # 更改角色 EXP
      actor.exp += value
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 增减等级
  #--------------------------------------------------------------------------
  def command_316
    # 获取操作值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 处理重复
    iterate_actor(@parameters[0]) do |actor|
      # 更改角色的等级
      actor.level += value
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 增减能力值
  #--------------------------------------------------------------------------
  def command_317
    # 获取操作值
    value = operate_value(@parameters[2], @parameters[3], @parameters[4])
    # 获取角色
    actor = $game_actors[@parameters[0]]
    # 更改能力值
    if actor != nil
      case @parameters[1]
      when 0  # MaxHP
        actor.maxhp += value
      when 1  # MaxSP
        actor.maxsp += value
      when 2  # 力量
        actor.str += value
      when 3  # 灵巧
        actor.dex += value
      when 4  # 速度
        actor.agi += value
      when 5  # 魔力
        actor.int += value
      end
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 增减特技
  #--------------------------------------------------------------------------
  def command_318
    # 获取角色
    actor = $game_actors[@parameters[0]]
    # 增减特技
    if actor != nil
      if @parameters[1] == 0
        actor.learn_skill(@parameters[2])
      else
        actor.forget_skill(@parameters[2])
      end
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 变更装备
  #--------------------------------------------------------------------------
  def command_319
    # 获取角色
    actor = $game_actors[@parameters[0]]
    # 变更角色
    if actor != nil
      actor.equip(@parameters[1], @parameters[2])
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改角色的名字
  #--------------------------------------------------------------------------
  def command_320
    # 获取角色
    actor = $game_actors[@parameters[0]]
    # 更改名字
    if actor != nil
      actor.name = @parameters[1]
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改角色的职业
  #--------------------------------------------------------------------------
  def command_321
    # 获取角色
    actor = $game_actors[@parameters[0]]
    # 更改职业
    if actor != nil
      actor.class_id = @parameters[1]
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改角色的图形
  #--------------------------------------------------------------------------
  def command_322
    # 获取角色
    actor = $game_actors[@parameters[0]]
    # 更改图形
    if actor != nil
      actor.set_graphic(@parameters[1], @parameters[2],
        @parameters[3], @parameters[4])
    end
    # 刷新角色
    $game_player.refresh
    # 继续
    return true
  end
end
