#==============================================================================
# ■ Game_Battler (分割定义 4)
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
  def magic_effect(target, id)
    sp_skill = $data_skills[id]
    # 清除会心一击标志
    self.critical = false
    # 根据ID结算绝招效果
    case id
    when 29,30,33,34,37,38 # 闪光弹/雷火弹/火焰球/烈焰球/寒冰弹/雾棱镖
    when 31 # 掌心雷
    when 35 # 三昧火
    when 39 # 暴风雪
    end
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
  def states_effect
    # 飞鹰召唤
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