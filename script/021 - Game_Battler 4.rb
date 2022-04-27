#==============================================================================
# ■ Game_Battler (分割定义 4)
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
    self.damage = nil
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
  # ● 计算基础法术命中
  #     target  : 法术的目标 (battler)
  #     m_hit   : 法术基础命中
  #--------------------------------------------------------------------------
  def magic_hit(target, m_hit)
    # 计算命中参数
    user_para = (@exp/500000+1)*(mp_kf_lv**3)+@exp
    m_para = [[m_hit,20].max,500].min
    user_para *= m_para / 100
    target_para = target.exp * 4 / 3
    eva_para = target_para * 100
    total_para = user_para + target_para
    return eva_para/total_para
  end
  #--------------------------------------------------------------------------
  # ● 附加法术状态
  #--------------------------------------------------------------------------
  def add_magic_state(target,type,buff_hit,buff_eff,buff_turns)
    text = ""
    # 附加法术状态
    buff_id = -1 * type
    if buff_hit == 0 # 状态必中
      buff_para = 100
    else
      fa_lv = $data_system.falv_factor[get_kf_level(mp_kf_id)/10]
      buff_para = fa_lv - buff_eff
    end
    # 判定是否附加
    if rand(100) < buff_para
      mp_level = get_kf_level(mp_kf_id)
      case type
      when 1 # 降低命中
        turns = buff_hit == 0 ? 1 : mp_level/20
        target.hit_plus -= mp_level / buff_turns
        text = $data_system.thunder_hurt.deep_clone
        target.states_add[buff_id] = [[1,-mp_level / buff_turns]]
      when 2 # 灼烧伤害
        turns = (rand(mp_level)+mp_level)/3/2+1
      when 3 # 呆若木鸡
        turns = rand(mp_level/buff_turns)+1
        buff_id = 0
      end
      target.add_state(buff_id,turns,1)
    end
    return text
  end
  #--------------------------------------------------------------------------
  # ● 应用物品效果
  #     item : 物品
  #--------------------------------------------------------------------------
  def item_effect(item_id)
    item = $data_items[item_id]
    # 玩家物品效果
    if self.is_a?(Game_Actor)
      # 增加食物
      case item.add_food[0]
      when 0 # 实际数值
        @food += item.add_food[1]
      when 1 # 百分比
        @food += @max_food*item.add_food[1]/100
      end
      # 增加饮水
      case item.add_water[0]
      when 0 # 实际数值
        @water += item.add_water[1]
      when 1 # 百分比
        @water += @max_water*item.add_water[1]/100
      end
    end
    # 增加生命
    case item.add_hp[0]
    when 0 # 实际数值
      @hp += item.add_hp[1]
      @hp = [@hp,@maxhp].min
    when 1 # 百分比
      @hp += @full_hp*item.add_hp[1]/100
      @hp = [@hp,@maxhp].min
    end
    # 增加生命上限
    case item.add_mhp[0]
    when 0 # 实际数值
      @maxhp += item.add_mhp[1]
      @maxhp = [@maxhp,full_hp].min
    when 1 # 百分比
      @maxhp += full_hp*item.add_mhp[1]/100
      @maxhp = [@maxhp,full_hp].min
    end
    # 增加内力
    case item.add_fp[0]
    when 0 # 实际数值
      @fp += item.add_fp[1]
      @fp = [@fp,@maxfp*2].min
    when 1 # 百分比
      @fp += @maxfp*item.add_fp[1]/100
      @fp = [@fp,@maxfp*2].min
    end
    # 增加内力上限
    case item.add_mfp[0]
    when 0 # 实际数值
      @maxfp += item.add_mfp[1]
    when 1 # 百分比
      @maxfp += @maxfp*item.add_mfp[1]/100
    end
    # 增加法力
    case item.add_mp[0]
    when 0 # 实际数值
      @mp += item.add_mp[1]
      @mp = [@mp,@maxmp*2].min
    when 1 # 百分比
      @mp += @maxmp*item.add_mp[1]/100
      @mp = [@mp,@maxmp*2].min
    end
    # 增加法力上限
    case item.add_mmp[0]
    when 0 # 实际数值
      @maxmp += item.add_mmp[1]
    when 1 # 百分比
      @maxmp += @maxmp*item.add_mmp[1]/100
    end
    # 过程结束
    return true
  end
  #--------------------------------------------------------------------------
  # ● 应用连续伤害效果
  #--------------------------------------------------------------------------
  def slip_damage_effect
    # 设置伤害
    self.damage = self.maxhp / 10
    # 分散
    if self.damage.abs > 0
      amp = [self.damage.abs * 15 / 100, 1].max
      self.damage += rand(amp+1) + rand(amp+1) - amp
    end
    # HP 的伤害减法运算
    self.hp -= self.damage
    # 过程结束
    return true
  end
  #--------------------------------------------------------------------------
  # ● 状态特殊效果
  #--------------------------------------------------------------------------
  def states_effect(target)
    self.damage = nil
    # 设置使用者名字
    if self.is_a?(Game_Enemy)
      user_name = @name
    else
      user_name = "你"
    end
    text = []
    return text if @states.empty?
    for i in @states
      sp_skill = $data_skills[i] if i > 0
      case i
      when 26 # 飞鹰召唤
        # 60%造成伤害
        if rand(100) < 60
          n_text = sp_skill.success_text[0].deep_clone
          n_text.gsub!("user",user_name)
          self.damage = 50
          text.push([n_text,self.damage])
        else
          text.push([sp_skill.fail_text[0].deep_clone,self.damage])
        end
      when -2 # 灼烧
        self.damage = target.mp-Integer(rand(@fp))
        n_text = $data_system.fire_hurt.dup
        n_text.gsub!("user",user_name)
        text.push([n_text,self.damage])
      when -4 # 武器中毒
        sword_d = target.sword2 % 100
        self.damage = 5 * (sword_d + 1)
        n_text = $data_system.sword_hurt.dup
        n_text.gsub!("user",user_name)
        text.push([n_text,self.damage])
      when -5 # 武器恢复
        sword_d = @sword2 % 100
        self.damage = -5 * (sword_d + 1)
        text.push([nil,self.damage])
      end
    end
    return text
  end
  #--------------------------------------------------------------------------
  # ● 属性修正计算
  #     element_set : 属性
  #--------------------------------------------------------------------------
  def elements_correct(element_set)
    # 无属性的情况
    if element_set == []
      # 返回 100
      return 100
    end
    # 在被赋予的属性中返回最弱的
    # ※过程 element_rate 是、本类以及继承的 Game_Actor
    #   和 Game_Enemy 类的定义
    weakest = -100
    for i in element_set
      weakest = [weakest, self.element_rate(i)].max
    end
    return weakest
  end
end