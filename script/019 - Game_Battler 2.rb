#==============================================================================
# ■ Game_Battler (分割定义 2)
#------------------------------------------------------------------------------
# 　处理战斗者的类。这个类作为 Game_Actor 类与 Game_Enemy 类的
# 超级类来使用。
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # ● 获取招式
  #--------------------------------------------------------------------------
  def get_kf_action(type)
    action_list = []
    case type
    when 0 # 攻击招式
      kf_action = $data_kungfus[attack_kf_id].atk_word.deep_clone
      lv = get_kf_level(attack_kf_id)
      # 根据功夫等级生成招式列表
      kf_action.each do |i|
        action_list.push(i) if i[0] <= lv
      end
    when 1 # 轻功招式
      action_list = $data_kungfus[dodge_kf_id].def_word.deep_clone
    end
    # 获取随机招式
    id = Integer(rand(action_list.size))
    action = action_list[id]
    if type == 0
      # 设置临时属性
      text,@hit_type = action[1],action[2]
      @kf_ap,@kf_dp,@kf_pp = action[3],action[4],action[5]
      @kf_damage,@kf_force = action[6],action[7]
      return text
    else
      return action
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取指定功夫的指定招式
  #--------------------------------------------------------------------------
  def get_kf_id_action(kf_id,act_id = -1)
    action_list = []
    # 获取功夫类型
    kf_type = $data_kungfus[kf_id].type
    # 内功，招架，法术，知识返回空白
    return " " if [1,8,10,11].include?(kf_type)
    # 轻功获取def_word，其余获取atk_word
    if kf_type == 9
      action_list = $data_kungfus[kf_id].def_word.deep_clone
      # 如果act_id越界，则随机获取招式
      if (0...action_list.size).include?(act_id)
        return action_list[act_id]
      else
        # 获取随机招式
        id = Integer(rand(action_list.size))
        return action_list[id]
      end
    else
      kf_action = $data_kungfus[kf_id].atk_word.deep_clone
      # 根据功夫等级生成招式列表
      lv = get_kf_level(kf_id)
      kf_action.each do |i|
        action_list.push(i) if i[0] <= lv
      end
      # 如果act_id越界，则随机获取招式
      if (0...action_list.size).include?(act_id)
        action = action_list[act_id]
      else
        # 获取随机招式
        id = Integer(rand(action_list.size))
        action = action_list[id]
      end
      # 设置临时属性
      text,@hit_type = action[1],action[2]
      @kf_ap,@kf_dp,@kf_pp = action[3],action[4],action[5]
      @kf_damage,@kf_force = action[6],action[7]
      return text
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取功夫及经验加成
  #--------------------------------------------------------------------------
  def kf_power(type)
    # 功夫加成
    case type
    when 0 # 攻击
      attr1 = hit + attack_kf_lv + @kf_ap
      attr2 = 100 + (agi - 30) / 2
    when 1 # 轻功
      attr1 = eva + dodge_kf_lv + @kf_dp
      attr2 = 100 + (int - 30) / 2
    when 2 # 招架
      attr1 = eva + parry_kf_lv + @kf_pp
      attr2 = 100 + (str - 30) / 2
    end
    attr1 = [attr1,0].max
    # 经验加成
    exp_power = @exp/100
    exp_power /= 2 if attr1 == 0
    total = (attr1 ** 3 / 300 + exp_power) * attr2 / 100
    return total
  end
  #--------------------------------------------------------------------------
  # ● 清除临时数据(战斗初始化)
  #--------------------------------------------------------------------------
  def clear_temp_data
    @states,@states_add,@cool_down,@cd_turn,@damage = [],{},[],{},nil
    @states_turn,@str_plus,@dex_plus,@agi_plus = {},0,0,0
    @int_plus,@bon_plus,@hit_plus,@eva_plus,@atk_plus = 0,0,0,0,0
    @def_plus,@luc_plus,@kf_ap,@kf_dp,@kf_pp,@fenshen = 0,0,0,0,0,-1
  end
  #--------------------------------------------------------------------------
  # ● 检查绝招要求
  #--------------------------------------------------------------------------
  def check_skill_require(skill_id,type,num)
    sp_skill = $data_skills[skill_id]
    case type
    when 1..59 # 检查技能及有效等级
      kf_type = $data_kungfus[type].type
      case kf_type
      when 1 # 内功
        id = fp_kf_id
      when 2 # 拳脚
        id = hand_kf_id
      when 3..7 # 兵刃
        id = weapon_kf_id
      when 8 # 法术
        id = mp_kf_id
      when 9 # 轻功
        id = dodge_kf_id
      when 10 # 招架
        id = skill_use[4]
      end
      unless id == type
        # 绝招需配合武功使用
        text = $data_text.sp_no_match.dup
        text.gsub!("sp_skill",sp_skill.name)
        text.gsub!("skill",$data_kungfus[type].name)
        return [false,text]
      end
      # 检查有效等级
      if get_kf_efflv(id) >= num
        return [true]
      else
        # 等级不足
        text = $data_text.sp_no_lv.dup
        text.gsub!("skill",$data_kungfus[id].name)
        return [false,text]
      end
    when -3..0 # 四维属性
      attr,id = [str,agi,int,bon],type.abs
      if attr[id] >= num
        return [true]
      else
        # 属性不足
        text = $data_text.sp_no_attr.dup
        text.gsub!("attr",$data_system.attr_name[id])
        text.gsub!("sp_skill",sp_skill.name)
        return [false,text]
      end
    when -4 # 内力
      fp_cost = [get_fp_cost(skill_id),num].max
      # 检查当前内力
      if @fp >= fp_cost
        return [true]
      else
        # 内力不足
        text = $data_text.sp_no_fp2.dup
        return [false,text]
      end
    when -5 # 内力上限
      fp_cost = [get_fp_cost(skill_id),num].max
      # 检查内力上限
      if @maxfp >= fp_cost
        return [true]
      else
        # 内力上限不足
        text = $data_text.sp_no_maxfp.dup
        text.gsub!("sp_skill",sp_skill.name)
        return [false,text]
      end
    when -6 # 生命
      # 检查当前生命
      if @hp >= num
        return [true]
      else
        # 体力不足
        text = $data_text.sp_no_hp.dup
        return [false,text]
      end
    when -7 # 生命上限
      # 检查生命上限
      if @maxhp >= num
        return [true]
      else
        # 体力不足
        text = $data_text.sp_no_hp.dup
        return [false,text]
      end
    when -8 # 法力
      # 检查当前法力
      if @mp >= num
        return [true]
      else
        # 法力不足
        text = $data_text.sp_no_mp.dup
        return [false,text]
      end
    when -9 # 法力上限
      # 检查法力上限
      if @maxmp >= num
        return [true]
      else
        # 法力上限不足
        text = $data_text.sp_no_maxmp.dup
        text.gsub!("sp_skill",sp_skill.name)
        return [false,text]
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 检查法术要求
  #--------------------------------------------------------------------------
  def check_magic_require(skill_id,magic_data)
    return [true] if magic_data.empty?
    # 检查法术等级
    if mp_kf_lv >= magic_data[1]
      return [true]
    else
      text = $data_text.sp_no_lv.dup
      text.gsub!("skill",$data_kungfus[mp_kf_id].name)
      return [false,text]
    end
    # 检查法力
    mp_cost = [@mp_plus*2+100,get_mp_cost(skill_id)].max
    if @mp >= mp_cost
      return [true]
    else
      return [false,$data_text.sp_no_mp.dup]
    end
    # 检查生命
    if @hp >= $data_skills[skill_id].hp_cost
      return [true]
    else
      return [false,$data_text.sp_no_hp.dup]
    end
  end
  #--------------------------------------------------------------------------
  # ● 检查状态
  #     state_id : 状态 ID
  #--------------------------------------------------------------------------
  def state?(state_id)
    # 如果符合被附加的状态的条件就返回 ture
    return @states.include?(state_id)
  end
  #--------------------------------------------------------------------------
  # ● 判断状态是否为 full
  #     state_id : 状态 ID
  #--------------------------------------------------------------------------
  def state_full?(state_id)
    # 如果符合被附加的状态的条件就返回 false
    unless self.state?(state_id)
      return false
    end
    # 秩序回合数 -1 (自动状态) 然后返回 true
    if @states_turn[state_id] == -1
      return true
    end
    # 当持续回合数等于自然解除的最低回合数时返回 ture
    return @states_turn[state_id] == $data_states[state_id].hold_turn
  end
  #--------------------------------------------------------------------------
  # ● 附加状态
  #     state_id : 状态 ID
  #     state_turn : 持续回合
  #--------------------------------------------------------------------------
  def add_state(state_id,turns,plus = 0)
    # 已有状态的情况下
    if state?(state_id)
      # 非增加回合的情况
      if plus == 0
        # 更新持续时间
        @states_turn[state_id] = [turns,@states_turn[state_id]].max
      else
        # 增加持续时间
        @states_turn[state_id] += turns
      end
      return
    else
      # 新增状态及持续时间
      @states.push(state_id)
      @states_turn[state_id] = turns
    end
  end
  #--------------------------------------------------------------------------
  # ● 记录冷却时间
  #--------------------------------------------------------------------------
  def add_cd_time(id,turns)
    @cool_down.push(id)
    @cd_turns[id] = turns
  end
  #--------------------------------------------------------------------------
  # ● CD自然冷却 (回合改变时调用)
  #--------------------------------------------------------------------------
  def remove_cd_auto
    for i in @cd_turns.keys.clone
      if @cd_turns[i] > 0
        @cd_turns[i] -= 1
        remove_cd_time(i) if @cd_turns[i] == 0
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 移除冷却时间
  #--------------------------------------------------------------------------
  def remove_cd_time(id)
    @cool_down.delete(id)
    @cd_turns.delete(id)
  end
  #--------------------------------------------------------------------------
  # ● 解除状态
  #     state_id : 状态 ID
  #--------------------------------------------------------------------------
  def remove_state(state_id)
    # 无法附加本状态的情况下
    if state?(state_id)
      # 将状态 ID 从 @states 队列和 @states_turn hash 中删除 
      @states.delete(state_id)
      @states_turn.delete(state_id)
      if @states_add[state_id] != nil
        @states_add[state_id].each do |i|
          # 复原属性
          case i[0]
          when 1 # 命中
            @hit_plus = [@hit_plus - i[1],0].max
          when 2 # 闪避
            @eva_plus = [@eva_plus - i[1],0].max
          when 3 # 攻击
            @atk_plus = [@atk_plus - i[1],0].max
          when 4 # 防御
            @def_plus = [@def_plus - i[1],0].max
          when 5 # 膂力
            @str_plus = [@str_plus - i[1],0].max
          when 6 # 敏捷
            @agi_plus = [@agi_plus - i[1],0].max
          when 7 # 悟性
            @int_plus = [@int_plus - i[1],0].max
          when 8 # 根骨
            @bon_plus = [@bon_plus - i[1],0].max
          when 9 # 分身标志
            @fenshen = -1
          end
        end
        @states_add.delete(state_id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取状态的动画 ID
  #--------------------------------------------------------------------------
  def state_animation_id
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 状态自然解除 (回合改变时调用)
  #--------------------------------------------------------------------------
  def remove_states_auto
    removed = []
    for i in @states_turn.keys.clone
      # 铸造武器状态则跳过
      next if [-4,-5].include?(i)
      # 持续回合减一
      if @states_turn[i] > 0
        @states_turn[i] -= 1
        if @states_turn[i] == 0
          remove_state(i)
          removed.push(i) if i > 0
        end
      end
    end
    return removed
  end
  #--------------------------------------------------------------------------
  # ● 解除所有状态 (战斗结束时调用)
  #--------------------------------------------------------------------------
  def remove_all_states
    for i in @states.clone
      remove_state(i)
    end
  end
end
