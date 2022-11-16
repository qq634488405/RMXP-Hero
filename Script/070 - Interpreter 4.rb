#==============================================================================
# ■ Interpreter (分割定义 4)
#------------------------------------------------------------------------------
# 　执行事件命令的解释器。本类在 Game_System 类
# 和 Game_Event 类的内部使用。
#==============================================================================

class Interpreter
  #--------------------------------------------------------------------------
  # ● 开关操作
  #--------------------------------------------------------------------------
  def command_121
    # 循环全部操作
    for i in @parameters[0] .. @parameters[1]
      # 更改开关
      $game_switches[i] = (@parameters[2] == 0)
    end
    # 刷新地图
    $game_map.need_refresh = true
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 变量操作
  #--------------------------------------------------------------------------
  def command_122
    # 初始化值
    value = 0
    # 操作数的分支
    case @parameters[3]
    when 0  # 恒量
      value = @parameters[4]
    when 1  # 变量
      value = $game_variables[@parameters[4]]
    when 2  # 随机数
      value = @parameters[4] + rand(@parameters[5] - @parameters[4] + 1)
    when 3  # 物品
      value = $game_party.item_number(@parameters[4])
    when 4  # 角色
      actor = $game_actors[@parameters[4]]
      if actor != nil
        case @parameters[5]
        when 0  # 等级
          value = actor.level
        when 1  # EXP
          value = actor.exp
        when 2  # HP
          value = actor.hp
        when 3  # SP
          value = actor.sp
        when 4  # MaxHP
          value = actor.maxhp
        when 5  # MaxSP
          value = actor.maxsp
        when 6  # 力量
          value = actor.str
        when 7  # 灵巧
          value = actor.dex
        when 8  # 速度
          value = actor.agi
        when 9  # 魔力
          value = actor.int
        when 10  # 攻击力
          value = actor.atk
        when 11  # 物理防御
          value = actor.pdef
        when 12  # 魔法防御
          value = actor.mdef
        when 13  # 回避修正
          value = actor.eva
        end
      end
    when 5  # 敌人
      enemy = $game_troop.enemies[@parameters[4]]
      if enemy != nil
        case @parameters[5]
        when 0  # HP
          value = enemy.hp
        when 1  # SP
          value = enemy.sp
        when 2  # MaxHP
          value = enemy.maxhp
        when 3  # MaxSP
          value = enemy.maxsp
        when 4  # 力量
          value = enemy.str
        when 5  # 灵巧
          value = enemy.dex
        when 6  # 速度
          value = enemy.agi
        when 7  # 魔力
          value = enemy.int
        when 8  # 攻击力
          value = enemy.atk
        when 9  # 物理防御
          value = enemy.pdef
        when 10  # 魔法防御
          value = enemy.mdef
        when 11  # 回避修正
          value = enemy.eva
        end
      end
    when 6  # 角色
      character = get_character(@parameters[4])
      if character != nil
        case @parameters[5]
        when 0  # X 坐标
          value = character.x
        when 1  # Y 坐标
          value = character.y
        when 2  # 朝向
          value = character.direction
        when 3  # 画面 X 坐标
          value = character.screen_x
        when 4  # 画面 Y 坐标
          value = character.screen_y
        when 5  # 地形标记
          value = character.terrain_tag
        end
      end
    when 7  # 其它
      case @parameters[4]
      when 0  # 地图 ID
        value = $game_map.map_id
      when 1  # 同伴人数
        value = $game_party.actors.size
      when 2  # 金钱
        value = $game_party.gold
      when 3  # 步数
        value = $game_party.steps
      when 4  # 游戏时间
        value = Graphics.frame_count / Graphics.frame_rate
      when 5  # 计时器
        value = $game_system.timer / Graphics.frame_rate
      when 6  # 存档次数
        value = $game_system.save_count
      end
    end
    # 循环全部操作
    for i in @parameters[0] .. @parameters[1]
      # 操作分支
      case @parameters[2]
      when 0  # 代入
        $game_variables[i] = value
      when 1  # 加法
        $game_variables[i] += value
      when 2  # 减法
        $game_variables[i] -= value
      when 3  # 乘法
        $game_variables[i] *= value
      when 4  # 除法
        if value != 0
          $game_variables[i] /= value
        end
      when 5  # 剩余
        if value != 0
          $game_variables[i] %= value
        end
      end
      # 检查上限
      if $game_variables[i] > 99999999
        $game_variables[i] = 99999999
      end
      # 检查下限
      if $game_variables[i] < -99999999
        $game_variables[i] = -99999999
      end
    end
    # 刷新地图
    $game_map.need_refresh = true
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 独立开关操作
  #--------------------------------------------------------------------------
  def command_123
    # 事件 ID 有效的情况下
    if @event_id > 0
      # 生成独立开关
      key = [$game_map.map_id, @event_id, @parameters[0]]
      # 更改独立开关
      $game_self_switches[key] = (@parameters[1] == 0)
    end
    # 刷新地图
    $game_map.need_refresh = true
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 计时器操作
  #--------------------------------------------------------------------------
  def command_124
    # 开始的情况
    if @parameters[0] == 0
      $game_system.timer = @parameters[1] * Graphics.frame_rate
      $game_system.timer_working = true
    end
    # 停止的情况
    if @parameters[0] == 1
      $game_system.timer_working = false
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 增减金钱
  #--------------------------------------------------------------------------
  def command_125
    # 获取要操作的值
    value = operate_value(@parameters[0], @parameters[1], @parameters[2])
    # 增减金钱
    $game_party.gain_gold(value)
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 增减物品
  #--------------------------------------------------------------------------
  def command_126
    # 获取要操作的值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 增减物品
    $game_party.gain_item(@parameters[0], value)
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 增减武器
  #--------------------------------------------------------------------------
  def command_127
    # 获取要操作的值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 增减武器
    $game_party.gain_weapon(@parameters[0], value)
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 增减防具
  #--------------------------------------------------------------------------
  def command_128
    # 获取要操作的值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 增减防具
    $game_party.gain_armor(@parameters[0], value)
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 角色的替换
  #--------------------------------------------------------------------------
  def command_129
    # 获取角色
    actor = $game_actors[@parameters[0]]
    # 角色有效的情况下
    if actor != nil
      # 操作分支
      if @parameters[1] == 0
        if @parameters[2] == 1
          $game_actors[@parameters[0]].setup(@parameters[0])
        end
        $game_party.add_actor(@parameters[0])
      else
        $game_party.remove_actor(@parameters[0])
      end
    end
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改窗口外观
  #--------------------------------------------------------------------------
  def command_131
    # 设置窗口外观文件名
    $game_system.windowskin_name = @parameters[0]
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改战斗 BGM
  #--------------------------------------------------------------------------
  def command_132
    # 设置战斗 BGM
    $game_system.battle_bgm = @parameters[0]
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改战斗结束的 ME
  #--------------------------------------------------------------------------
  def command_133
    # 设置战斗结束的 ME
    $game_system.battle_end_me = @parameters[0]
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改禁止存档
  #--------------------------------------------------------------------------
  def command_134
    # 更改禁止存档标志
    $game_system.save_disabled = (@parameters[0] == 0)
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改禁止菜单
  #--------------------------------------------------------------------------
  def command_135
    # 更改禁止菜单标志
    $game_system.menu_disabled = (@parameters[0] == 0)
    # 继续
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改禁止遇敌
  #--------------------------------------------------------------------------
  def command_136
    # 更改更改禁止遇敌标志
    $game_system.encounter_disabled = (@parameters[0] == 0)
    # 生成遇敌计数
    $game_player.make_encounter_count
    # 继续
    return true
  end
end
