#==============================================================================
# ■ Game_Battler (分割定义 3)
#------------------------------------------------------------------------------
# 　处理战斗者的类。这个类作为 Game_Actor 类与 Game_Enemy 类的
# 超级类来使用。
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # ● 获取内力消耗
  #--------------------------------------------------------------------------
  def get_fp_cost(skill_id)
    n = $data_skills[skill_id].fp_cost
    if [5,8,23,24].include?(skill_id)
      case skill_id
      when 5 # 柳浪闻莺
        n = get_kf_efflv(18) < 120 ? 200 : 400
      when 8 # 流星飞掷
        n = get_kf_efflv(24) < 150 ? 550 : 850
      when 23 # 雪花六出
        n = [250 + (get_kf_efflv(39)-90)/30*150,600].min
      when 24 # 冰心诀
        n = get_kf_efflv(41) < 90 ? 150 : 250
      end
    end
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取法力消耗
  #--------------------------------------------------------------------------
  def get_mp_cost(skill_id)
    return 0 if skill_id < 29
    n = $data_skills[skill_id].mp_cost
    return n if n > 0
    base_mp_cost = $data_skills[skill_id].magic_data[0]
    return (@mp_plus + base_mp_cost)
  end
  #--------------------------------------------------------------------------
  # ● 可以使用特技的判定
  #     skill_id : 特技 ID
  #--------------------------------------------------------------------------
  def skill_can_use?(skill_id,aim)
    # 获取绝招数据
    sp_skill = $data_skills[skill_id]
    # 检查自身是否呆若木鸡
    unless movable?
      text = $data_text.self_is_busy.dup
      return [false,text]
    end
    # 检查目标是否呆若木鸡且绝招为控制型
    if (not aim.movable? and sp_skill.type == 1)
      # 使用暴风雪
      if skill_id == 39
        text = $data_text.aim_is_busy2.dup
      else
        text = $data_text.aim_is_busy.dup
      end
      text.gsub!("target",aim.name)
      return [false,text]
    end
    result = [true]
    unless sp_skill.require.empty?
      # 判断使用要求
      sp_skill.require.each do |i|
        result = check_skill_require(skill_id,i[0],i[1])
        unless result[0]
          break
        end
      end
    end
    return result if not result[0]
    # 检查法术
    if skill_id > 28
      # 检查法术数据
      result = check_magic_require(skill_id,sp_skill.magic_data)
      return result if not result[0]
    end
    check_list = @cool_down.deep_clone & @states.deep_clone
    # 检查绝招冲突
    unless sp_skill.crash_skill.empty?
      # 冲突绝招处于冷却或持续则不可使用
      sp_skill.crash_skill.each do |i|
        if check_list.include?(i)
          text = $data_text.sp_used.dup
          text.gsub!("sp_skill",$data_skills[i].name)
          result = [false,text]
          break
        end
      end
      return result if not result[0]
    end
    # 使用的绝招处于冷却时间
    if @cool_down.include?(skill_id)
      # 使用目标为自身的则显示已经在使用
      if sp_skill.target == 0
        text = $data_text.sp_used.dup
      else
        text = $data_text.sp_is_cd
      end
      text.gsub!("sp_skill",$data_skills[skill_id].name)
      result = [false,text]
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ● 应用通常攻击效果
  #     target : 攻击目标 (battler)
  #--------------------------------------------------------------------------
  def attack_effect(target)
    hurt_num = 0
    # 清除会心一击标志
    self.critical = false
    # 命中参数
    hit_para = kf_power(0)
    # 闪避参数
    eva_para = target.kf_power(1)
    eva_para /= 3 if not target.movable?
    # 第一命中判定
    hit_result = (Integer(rand(hit_para+eva_para)) >= eva_para)
    # 第一命中的判定成功的情况
    if hit_result == true
      # 招架参数
      parry_para = target.kf_power(2)
      parry_para /= 3 if not target.movable?
      # 第二命中判定
      hit_result = (Integer(rand(hit_para+parry_para)) >= parry_para)
      # 第二命中判定成功
      if hit_result == true
        # 判断影分身，大于分身格挡率则命中
        if rand(100) > target.fenshen
          # 计算基础伤害
          damage1 = (Integer(rand(self.atk))+self.atk)/2
          damage1 = damage1 + damage1 * @kf_damage/100
          # 内力加成
          fp_add = [self.fp,self.fp_plus].min
          # 内力消耗
          self.fp -= fp_add
          if fp_add == 0 # 加力或内力任意为0无加成
            damage2 = self.str+self.str*@kf_force/100
          else
            fp_add /= 6 if self.weapon_id > 0
            fp_add += ([self.fp,3000].min/20 - target.fp_plus/25)
            # 加成小于对方加力/25则无加成
            if fp_add <= 0
              damage2 = self.str
            else
              damage2 = self.str + fp_add
              damage2 = damage2 + damage2 * @kf_force/100
            end
          end
          self.damage = damage1 + (Integer(rand(damage2))+damage2)/2
          # 判断是否受伤
          if Integer(rand(self.damage)) > target.pdef
            hurt_num = self.damage - target.pdef
            # 没装备武器概率受伤
            if self.weapon_id == 0
              hurt_num = 0 if rand(4) != 0
            end
          end
        else # 影分身格挡
          self.damage = "Miss.3"
        end
      else # 招架格挡
        self.damage = "Miss.2"
      end
    else # 轻功闪避
      self.damage = "Miss.1"
    end
    # 过程结束
    return [self.damage,@hit_type,hurt_num]
  end
  #--------------------------------------------------------------------------
  # ● 应用特技效果
  #     target  : 特技的目标 (battler)
  #     id      : 特技ID
  #--------------------------------------------------------------------------
  def skill_effect(target, id)
    sp_skill = $data_skills[id]
    # 清除会心一击标志
    self.critical = false
    # 清除伤害
    self.damage = nil
    # 根据ID结算绝招效果
    case id
    when 1 # 化掌为刀(八卦游身掌)
      turns = get_kf_efflv(12) / 25
      @hit_plus += get_kf_efflv(12) / 15
      # 附加状态，记录附加属性，记录冷却时间
      add_state(1,turns)
      add_cd_time(1,turns)
      @states_add[1] = [[1,get_kf_efflv(12) / 15]]
      return [0]
    when 2 # 化掌为刀(八阵八卦掌)
      turns = get_kf_efflv(13) / 20
      @hit_plus += get_kf_efflv(13) / 15
      @str_plus += get_kf_efflv(13) * 2 / 15
      # 附加状态，记录附加属性，记录冷却时间
      add_state(2,turns)
      add_cd_time(2,turns)
      add_state(0,2)
      @states_add[2] = [[1,get_kf_efflv(12) / 15],[5,get_kf_efflv(13) * 2 / 15]]
      return [0]
    when 3 # 八卦刀影掌
      # 记录冷却时间，附加状态
      add_cd_time(3,7)
      add_state(0,3)
      return [1,[12,1,-1],[14,1,-1]]
    when 4 # 八阵刀影掌
      # 附加状态，记录附加属性，记录冷却时间
      @hit_plus += 10
      @str_plus += get_kf_efflv(13) / 9
      add_state(3,1)
      add_cd_time(4,7)
      add_state(0,3)
      return [1,[13,2,-1,-1],[14,1,-1]]
    when 5 # 柳浪闻莺
      # 记录冷却时间，附加状态
      add_cd_time(5,7)
      add_state(0,3)
      return [1,[17,2,-1,-1],[18,1,-1]]
    when 6 # 落英缤纷
      # 记录冷却时间
      add_cd_time(6,6)
      # 目标装备有武器的情况
      if target.weapon_id > 0
        # rand(使用者敏捷)≥目标敏捷/3则成功
        if rand(self.agi) >= target.agi / 3
          # 目标是玩家则还要从背包中删除武器
          if target.is_a?(Game_Actor)
            bag_id = target.get_item_index(2,target.weapon_id,1)
            target.lose_bag_id(bag_id)
          end
          target.weapon_id = 0
          text = sp_skill.success_text[0].deep_clone
        else # 卷武器失败
          add_state(0,2)
          text = sp_skill.fail_text[0].deep_clone
          self.damage = "Miss"
        end
        return [0,text]
      else # rand(花团鞭法有效等级) ≥目标轻功有效等级/3
        hit_result = rand(get_kf_efflv(19))
        if hit_result >= target.dodge_kf_lv / 3
          # 目标收到伤害并呆若木鸡
          self.damage = hit_result
          target.hp = [target.hp-hit_result,0].max
          target.maxhp = [target.maxhp-hit_result,0].max
          target.add_state(0,2)
          text = sp_skill.success_text[1].deep_clone
        else
          self.damage = "Miss"
          add_state(0,2)
          text = sp_skill.fail_text[1].deep_clone
        end
        return [0,text]
      end
    when 7 # 三花
      # 附加状态，记录附加属性，记录冷却时间
      turns = [get_kf_efflv(21) / 20,8].min
      @agi_plus += get_kf_efflv(21)/20
      @eva_plus += get_kf_efflv(21)/5-6
      add_state(7,turns)
      add_cd_time(7,turns)
      @states_add[7] = [[2,get_kf_efflv(21)/5-6],[6,get_kf_efflv(21)/20]]
      return [0]
    when 8 # 流星飞掷
      @hit_plus += 15
      add_state(8,1)
      add_cd_time(8,9)
      state_add[8] = [[1,15]]
      # 计算命中、闪避参数
      hit_para,eva_para = kf_power(0),target.kf_power(1)
      eva_para /= 3 if not target.movable?
      # rand(命中参数+闪避参数)≥闪避参数
      if rand(hit_para + eva_para) >= eva_para
        # 计算伤害
        damage1 = (self.str + get_kf_efflv(24)) * 2
        damage2 = self.hit + get_kf_efflv(24)
        self.damage = damage1
        target.hp = [target.hp-damage1,0].max
        target.maxhp = [target.maxhp-damage2,0].max
        add_state(0,3)
        text = sp_skill.success_text[0].deep_clone
      else # 不中
        self.damage = "Miss"
        add_state(0,4)
        text = sp_skill.fail_text[0].deep_clone
      end
      # 移除武器
      # 使用者是玩家则还要从背包中删除武器
      if self.is_a?(Game_Actor)
        bag_id = get_item_index(2,@weapon_id,1)
        lose_bag_id(bag_id)
      end
      @weapon_id = 0
      return [0,text]
    when 9 # 雷动九天
      # 附加状态，记录附加属性，记录冷却时间
      turns = get_kf_efflv(26)/20
      @str_plus += get_kf_efflv(26)/6
      add_state(9,turns)
      add_cd_time(9,turns)
      @states_add[9] = [[5,get_kf_efflv(26)/6]]
      return [0]
    when 10 # 红莲出世
      # 附加状态，记录附加属性，记录冷却时间
      turns = get_kf_efflv(26)/20
      @hit_plus += get_kf_efflv(26)/9
      add_state(9,turns)
      add_state(0,1)
      add_cd_time(9,turns)
      @states_add[10] = [[5,get_kf_efflv(26)/9]]
      return [0]
    when 11 # 旋风三连斩
      add_cd_time(11,5)
      add_state(0,1)
      return [1,[59,3,0,1,2]]
    when 12 # 迎风一刀斩
      @hit_plus += 15
      @atk_plus += get_kf_efflv(29)/3+20
      add_cd_time(12,7)
      add_state(12,1)
      add_state(0,1)
      @states_add[12] = [[1,15],[3,get_kf_efflv(29)/3+20]]
      return [1,[29,1,-1]]
    when 13 # 忍术烟幕
      # rand(使用者内力) ≥ 目标内力/3
      if rand(self.fp) >= target.fp/3
        turns = get_kf_efflv(31)/20
        target.add_state(13,turns)
        target.hit_plus -= [get_kf_efflv(31)/8,20].min
        target.states_add[13] = [[1,-1*get_kf_efflv(31)/8]]
        return [0]
      else
        self.damage = "Miss"
        add_state(0,2)
        text = sp_skill.fail_text[0].deep_clone
        return[0,text]
      end
    when 14 # 忍法影分身
      turns = turns = get_kf_efflv(31)/20
      add_state(14,turns)
      @fenshen = [get_kf_efflv(31)/5,30].max
      add_cd_time(14,turns)
      @states_add[14] = [[9,-1]]
      return [0]
    when 15 # 震字诀
      hit_result = rand(@fp)
      # rand(内力)≥目标内力/3
      if hit_result >= target.fp/3
        damage = @fp/10+@fp_plus-target.fp/30
        self.damage = damage
        target.hp = [target.hp-damage,0].max
        target.maxhp = [target.maxhp-damage/2,0].max
        add_cd_time(15,2)
        text = sp_skill.success_text[0].deep_clone
      elsif hit_result < target.fp/4
        self.damage = "Miss"
        turns = rand(3)+2
        add_state(0,turns)
        text = sp_skill.fail_text[0].deep_clone
      else
        self.damage = 100
        target.fp = target.fp < 200 ? 0 : target.fp - 100
        text = sp_skill.equal_text[0].deep_clone
      end
      return [0,text]
    when 16 # 挤字诀
      hit_result = rand(@fp)
      # rand(内力)≥目标内力/3
      if hit_result >= target.fp/3
        fp_damage = @fp/10+350+@fp_plus
        self.damage = fp_damage
        target.fp = [target.fp-fp_damage,0].max
        add_cd_time(16,2)
        text = sp_skill.success_text[0].deep_clone
      elsif hit_result < target.fp/5
        self.damage = "Miss"
        turns = rand(3)+1
        add_state(0,turns)
        text = sp_skill.fail_text[0].deep_clone
      else
        self.damage = 350
        target.fp = [target.fp - 350,0].max
        text = sp_skill.equal_text[0].deep_clone
      end
      return [0,text]
    when 17 # 乱环诀
      hit_result = rand(get_kf_efflv(32))
      # rand(太极拳有效等级) ≥ 目标招架有效等级/3
      if hit_result >= target.parry_kf_lv / 3
        turns = hit_result/30+2
        target.add_state(0,turns)
        add_cd_time(17,turns+4)
        text = sp_skill.success_text[0].deep_clone
      else
        self.damage = "Miss"
        add_state(0,2)
        text = sp_skill.fail_text[0].deep_clone
      end
      return [0,text]
    when 18 # 阴阳诀
      # 目标呆若木鸡，或rand(5)=0施展阳诀
      if (not target.movable or rand(5) == 0)
        @hit_plus += 15
        @str_plus += get_kf_efflv(32)/5
        add_state(18,1)
        add_state(0,3)
        add_cd_time(18,7)
        @states_add[18] = [[1,15],[5,get_kf_efflv(32)/5]]
        return [1,[57,1,-1]]
      else
        hit_result = rand(get_kf_efflv(32))
        # rand(太极拳有效等级) ≥ 目标招架有效等级/3
        if hit_result >= target.parry_kf_lv / 3
          turns = hit_result/25+2
          target.add_state(0,turns)
          add_cd_time(18,5)
          text = sp_skill.success_text[0].deep_clone
        else
          self.damage = "Miss"
          add_state(0,2)
          text = sp_skill.fail_text[0].deep_clone
        end
        return [0,text]
      end
    when 19 # 缠字诀
      hit_result = rand(@exp)
      # rand(经验)≥目标经验/3
      if hit_result >= target.exp/3
        turns = rand(get_kf_efflv(33)/20)+1
        target.add_state(0,turns)
        text = sp_skill.success_text[0].deep_clone
      else
        self.damage = "Miss"
        add_state(0,3)
        text = sp_skill.fail_text[0].deep_clone
      end
      add_cd_time(19,6)
      return [0,text]
    when 20 # 连字诀
      # 附加状态，记录附加属性，记录冷却时间
      turns = get_kf_efflv(33)/30 + 3
      @hit_plus += 10
      @eva_plus += get_kf_efflv(33)/15
      add_stste(20,turns)
      add_cd_times(20,turns)
      @states_add[20] = [[1,10],[2,get_kf_efflv(33)/15]]
      return [0]
    when 21 # 三环套月
      @atk_plus += get_kf_efflv(33)/5
      add_state(21,1)
      add_state(0,3)
      add_cd_time(21,6)
      @states_add[21] = [[3,get_kf_efflv(33)/5]]
      return [1,[58,3,0,1,2]]
    when 22 # 神倒鬼跌
      hit_result = rand(@fp)
      # rand(内力)≥目标内力/2
      if hit_result >= target.fp/2
        turns = get_kf_efflv(37)/35+3
        target.add_state(0,turns)
        self.damage = get_kf_efflv(37)/3
        target.hp = [target.hp-get_kf_efflv(37)/3,0].max
        text = sp_skill.success_text[0].deep_clone
      else
        self.damage = "Miss"
        add_state(0,2)
        text = sp_skill.fail_text[0].deep_clone
      end
      add_cd_time(22,5)
      return [0,text]
    when 23 # 雪花六出
      @hit_plus += 10
      add_state(23,1)
      add_state(0,3)
      add_cd_time(23,10)
      @states_add[23] = [[1,10]]
      # 攻击次数
      max_times = @xue6 ? 6 : 5
      times = [(get_kf_efflv(39)-90)/30+2,max_times].min
      result = [39,times]
      for i in 1..times
        result.push(-1)
      end
      return [1,result]
    when 24 # 冰心诀
      turns = [get_kf_efflv(41)/20,10].min
      @def_plus += [get_kf_efflv(41)/4,100].min
      add_state(24,turns)
      add_cd_time(24,turns)
      @states_add[24] = [[4,[get_kf_efflv(41)/4,100].min]]
      return [0]
    when 25 # 恶虎啸
      # 龙象般若功有效等级+5≥目标内力最大值/10
      if get_kf_efflv(47)+5 >= target.maxfp/10
        turns = get_kf_efflv(47)/30+1
        self.damage = get_kf_efflv(47)+5-target.maxfp/10
        target.add_state(0,turns)
        target.hp -= self.damage
        text = sp_skill.success_text[0].deep_clone
      else
        self.damage = "Miss"
        text = sp_skill.fail_text[0].deep_clone
      end
      add_cd_time(25,5)
      return [0,text]
    when 26 # 飞鹰召唤
      turns = get_kf_efflv(44)/10
      target.add_state(26,turns)
      add_cd_time(26,11)
      return [0]
    when 27 # 变鹰术
      turns = get_kf_efflv(44)/20
      @eva_plus += get_kf_efflv(44)*(5+rand(6))/10
      add_state(27,turns)
      add_cd_time(27,turns)
      @states_add[27] = [[2,get_kf_efflv(44)*(5+rand(6))/10]]
      return [0]
    when 28 # 变熊术
      turns = get_kf_efflv(47)/20+get_kf_level(48)/15
      addition_str = get_kf_efflv(47)/10+get_kf_level(48)/8
      addition_def = get_kf_efflv(47)/2+get_kf_level(48)
      @str_plus += addition_str
      @def_plus += addition_def
      add_state(28,turns)
      add_cd_time(28,turns)
      @states_add[28] = [[5,addition_str],[4,addition_def]]
      return [0]
    end
  end
end
