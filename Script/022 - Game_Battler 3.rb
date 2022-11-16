#==============================================================================
# ■ Game_Battler (分割定义 3)
#------------------------------------------------------------------------------
# 　处理战斗者的类。这个类作为 Game_Actor 类与 Game_Enemy 类的
# 超级类来使用。
#==============================================================================

class Game_Battler
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
      @states_add[2] = [[1,get_kf_efflv(13) / 15],[5,get_kf_efflv(13) * 2 / 15]]
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
      add_state(4,0)
      add_cd_time(4,7)
      add_state(0,3)
      @states_add[4] = [[1,10],[5,get_kf_efflv(13) / 9]]
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
            # 若为铸造武器，则清空铸造武器信息
            target.clear_sword if target.weapon_id == 31
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
          # 目标受到伤害并呆若木鸡
          self.damage = hit_result
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
      add_state(8,0)
      add_cd_time(8,9)
      states_add[8] = [[1,15]]
      # 计算命中、闪避参数
      hit_para,eva_para = kf_power(0),target.kf_power(1)
      eva_para /= 3 if not target.movable?
      # rand(命中参数+闪避参数)≥闪避参数
      if rand(hit_para + eva_para) >= eva_para
        # 计算伤害
        damage1 = (self.str + get_kf_efflv(24)) * 2
        damage2 = self.hit + get_kf_efflv(24)
        self.damage = damage1
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
        # 若为铸造武器，则清空铸造武器信息
        clear_sword if @weapon_id == 31
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
      add_state(10,turns)
      add_state(0,1)
      add_cd_time(10,turns)
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
      add_state(12,0)
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
        target.maxhp = [target.maxhp-damage/2,0].max
        add_cd_time(15,2)
        text = sp_skill.success_text[0].deep_clone
      elsif hit_result < target.fp/4
        self.damage = "Miss"
        turns = rand(3)+2
        add_state(0,turns)
        text = sp_skill.fail_text[0].deep_clone
      else
        self.damage = 0
        target.fp = target.fp < 200 ? 0 : target.fp - 100
        text = sp_skill.equal_text[0].deep_clone
      end
      return [0,text]
    when 16 # 挤字诀
      hit_result = rand(@fp)
      # rand(内力)≥目标内力/3
      if hit_result >= target.fp/3
        fp_damage = @fp/10+350+@fp_plus
        self.damage = 0
        target.fp = [target.fp-fp_damage,0].max
        add_cd_time(16,2)
        text = sp_skill.success_text[0].deep_clone
      elsif hit_result < target.fp/5
        self.damage = "Miss"
        turns = rand(3)+1
        add_state(0,turns)
        text = sp_skill.fail_text[0].deep_clone
      else
        self.damage = 0
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
      if (not target.movable? or rand(5) == 0)
        @hit_plus += 15
        @str_plus += get_kf_efflv(32)/5
        add_state(18,0)
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
      add_state(20,turns)
      add_cd_time(20,turns)
      @states_add[20] = [[1,10],[2,get_kf_efflv(33)/15]]
      return [0]
    when 21 # 三环套月
      @atk_plus += get_kf_efflv(33)/5
      add_state(21,0)
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
      add_state(23,0)
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
    when 29,30,31,33,34,37,38 # 闪光弹/雷火弹/掌心雷/火焰球/烈焰球/寒冰弹/雾棱镖
      if id == 31 # 掌心雷自身呆若木鸡1回合
        add_state(0,1)
      end
      # 获取法术数据
      m_data = sp_skill.magic_data
      m_hit,m_damage = m_data[2],m_data[3]
      m_type,damage_type,buff_type = m_data[4],m_data[5],m_data[6]
      buff_hit,buff_eff,buff_turns = m_data[7],m_data[8],m_data[9]
      # 法术使用判定
      if rand(100) >= magic_hit(target,m_hit)
        # 法术命中，判定命中目标
        m_damage = [[m_damage,20].max,200].min
        user_damage = (rand(@maxhp) + [@mp,@maxmp*2].min) / 20
        target_damage = (rand(target.maxhp) + target.fp) / 20
        user_damage += m_damage * 2 / 100 * @mp_plus
        target_damage += m_damage * 2 / 100 * Integer(rand(target.fp_plus))
        # 命中对手
        if user_damage >= target_damage
          damage1 = (user_damage-target_damage)*m_damage/100
          damage_aim = 1
          text = ["damage"]
          # 附加状态判定
          state_text = add_magic_state(target,buff_type,buff_hit,buff_eff,buff_turns)
          text.push(state_text) if state_text != ""
        else # 反弹
          damage1 = (target_damage-user_damage+target.fp_plus)*m_damage/100
          damage_aim = 2
          text = [sp_skill.equal_text[0].deep_clone,"damage"]
        end
        damage2 = damage1 * mp_kf_lv / 200
        self.damage = (damage1+damage2)*2
        return [2,damage_aim,damage_type,self.damage,text]
      else # 法术失败
        text = [sp_skill.fail_text[0].deep_clone]
        self.damage = "Miss"
        # 闪光弹/掌心雷/火焰弹失败也可附加状态
        if [29,31,33].include?(id)
          state_text = add_magic_state(target,buff_type,buff_hit,buff_eff,buff_turns)
          text.push(state_text) if state_text != ""
        end
        return [2,0,damage_type,self.damage,text]
      end
    when 35 # 三昧火
      # 获取法术数据
      m_hit = sp_skill.magic_data[2]
      # 法术成功判定
      if rand(100) >= magic_hit(target,m_hit)
        self.damage = mp_kf_lv
        add_state(0,2)
        # 目标是NPC则清空物品
        if target.is_a?(Game_Enemy)
          target.clear_item
        end
        # 25%附加灼烧状态
        if rand(100) < 25
          target.add_state(-2,2)
        end
        text = sp_skill.success_text[0].deep_clone
      else # 未命中
        add_state(0,5)
        self.damage = "Miss"
        text = sp_skill.fail_text[0].deep_clone
      end
      return [0,text]
    when 39 # 暴风雪
      # 经验判定
      hit1 = (rand(mp_kf_lv**3+@exp+target.exp)>=target.exp)
      # 内力上限判定
      hit2 = (rand(@maxmp+target.maxfp)>=target.maxfp)
      # 内力判定
      hit3 = (rand(@mp+target.fp)>=target.fp)
      if hit1 and hit2 and hit3
        turns = rand(15) + 5
        target.add_state(0,turns)
        text = sp_skill.success_text[0].deep_clone
      else
        self.damage = "Miss"
        turns = rand(2) + 1
        add_state(0,turns)
        text = sp_skill.fail_text[0].deep_clone
      end
      return [0,text]
    end
  end
end
