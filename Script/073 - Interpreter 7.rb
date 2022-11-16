#==============================================================================
# ■ Interpreter (分割定义 7)
#------------------------------------------------------------------------------
# 　执行事件命令的解释器。本类在 Game_System 类
# 和 Game_Event 类的内部使用。
#==============================================================================

class Interpreter
  #--------------------------------------------------------------------------
  # ● 增减敌人的 HP
  #--------------------------------------------------------------------------
  def command_331
    # 获取操作值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 处理循环
    iterate_enemy(@parameters[0]) do |enemy|
      # HP 不为 0 的情况下
      if enemy.hp > 0
        # 更改 HP (如果不允许战斗不能的状态就设置为 1)
        if @parameters[4] == false and enemy.hp + value <= 0
          enemy.hp = 1
        else
          enemy.hp += value
        end
      end
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 增减敌人的 SP
  #--------------------------------------------------------------------------
  def command_332
    # 获取操作值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 处理循环
    iterate_enemy(@parameters[0]) do |enemy|
      # 更改 SP
      enemy.sp += value
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改敌人的状态
  #--------------------------------------------------------------------------
  def command_333
    # 处理循环
    iterate_enemy(@parameters[0]) do |enemy|
      # 状态选项 [当作 HP 为 0 的状态] 有效的情况下
      if $data_states[@parameters[2]].zero_hp
        # 清除不死身标志
        enemy.immortal = false
      end
      # 更改状态
      if @parameters[1] == 0
        enemy.add_state(@parameters[2])
      else
        enemy.remove_state(@parameters[2])
      end
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 敌人的全回复
  #--------------------------------------------------------------------------
  def command_334
    # 处理循环
    iterate_enemy(@parameters[0]) do |enemy|
      # 全回复
      enemy.recover_all
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 敌人出现
  #--------------------------------------------------------------------------
  def command_335
    # 获取敌人
    enemy = $game_troop.enemies[@parameters[0]]
    # 清除隐藏标志
    if enemy != nil
      enemy.hidden = false
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 敌人变身
  #--------------------------------------------------------------------------
  def command_336
    # 获取敌人
    enemy = $game_troop.enemies[@parameters[0]]
    # 变身处理
    if enemy != nil
      enemy.transform(@parameters[1])
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 显示动画
  #--------------------------------------------------------------------------
  def command_337
    # 处理循环
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # 战斗者存在的情况下
      if battler.exist?
        # 设置动画 ID
        battler.animation_id = @parameters[2]
      end
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 伤害处理
  #--------------------------------------------------------------------------
  def command_338
    # 获取操作值
    value = operate_value(0, @parameters[2], @parameters[3])
    # 处理循环
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # 战斗者存在的情况下
      if battler.exist?
        # 更改 HP
        battler.hp -= value
        # 如果在战斗中
        if $game_temp.in_battle
          # 设置伤害
          battler.damage = value
          battler.damage_pop = true
        end
      end
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 强制行动
  #--------------------------------------------------------------------------
  def command_339
    # 忽视是否在战斗中
    unless $game_temp.in_battle
      return true
    end
    # 忽视回合数为 0
    if $game_temp.battle_turn == 0
      return true
    end
    # 处理循环 (为了方便、不需要存在复数)
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # 战斗者存在的情况下
      if battler.exist?
        # 设置行动
        battler.current_action.kind = @parameters[2]
        if battler.current_action.kind == 0
          battler.current_action.basic = @parameters[3]
        else
          battler.current_action.skill_id = @parameters[3]
        end
        # 设置行动对像
        if @parameters[4] == -2
          if battler.is_a?(Game_Enemy)
            battler.current_action.decide_last_target_for_enemy
          else
            battler.current_action.decide_last_target_for_actor
          end
        elsif @parameters[4] == -1
          if battler.is_a?(Game_Enemy)
            battler.current_action.decide_random_target_for_enemy
          else
            battler.current_action.decide_random_target_for_actor
          end
        elsif @parameters[4] >= 0
          battler.current_action.target_index = @parameters[4]
        end
        # 设置强制标志
        battler.current_action.forcing = true
        # 行动有效并且是 [立即执行] 的情况下
        if battler.current_action.valid? and @parameters[5] == 1
          # 设置强制对像的战斗者
          $game_temp.forcing_battler = battler
          # 推进索引
          @index += 1
          # 结束
          return false
        end
      end
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 战斗中断
  #--------------------------------------------------------------------------
  def command_340
    # 设置战斗中断标志
    $game_temp.battle_abort = true
    # 推进索引
    @index += 1
    # 结束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 调用菜单画面
  #--------------------------------------------------------------------------
  def command_351
    # 设置战斗中断标志
    $game_temp.battle_abort = true
    # 设置调用菜单标志
    $game_temp.menu_calling = true
    # 推进索引
    @index += 1
    # 结束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 调用存档画面
  #--------------------------------------------------------------------------
  def command_352
    # 设置战斗中断标志
    $game_temp.battle_abort = true
    # 设置调用存档标志
    $game_temp.save_calling = true
    # 推进索引
    @index += 1
    # 结束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 游戏结束
  #--------------------------------------------------------------------------
  def command_353
    # 设置游戏结束标志
    $game_temp.gameover = true
    # 结束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 返回标题画面
  #--------------------------------------------------------------------------
  def command_354
    # 设置返回标题画面标志
    $game_temp.to_title = true
    # 结束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 脚本
  #--------------------------------------------------------------------------
  def command_355
    # 刷新地图
    $game_map.need_refresh = true
    # script 设置第一行
    script = @list[@index].parameters[0] + "\n"
    # 循环
    loop do
      # 下一个事件指令在脚本 2 行以上的情况下
      if @list[@index+1].code == 655
        # 添加到 script 2 行以后
        script += @list[@index+1].parameters[0] + "\n"
      # 事件指令不在脚本 2 行以上的情况下
      else
        # 中断循环
        break
      end
      # 推进索引
      @index += 1
    end
    # 评价
    result = eval(script)
    # 返回值为 false 的情况下
    if result == false
      # 结束
      return false
    end
    # 继续
    return true
  end
end
