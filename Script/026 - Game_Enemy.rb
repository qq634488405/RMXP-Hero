#==============================================================================
# ■ Game_Enemy
#------------------------------------------------------------------------------
# 　处理敌人的类。本类在 Game_Troop 类 ($game_troop) 的
# 内部使用。
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor :type                     # 类型
  attr_accessor :item1                    # 物品一
  attr_accessor :item2                    # 物品二
  attr_accessor :item3                    # 物品三
  attr_accessor :item4                    # 物品四
  attr_accessor :sell_count               # 出售数量
  attr_accessor :sell_item                # 卖出物品
  attr_accessor :des_text                 # 查看描述
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize(id)
    super()
    @id = id
    set_up
  end
  #--------------------------------------------------------------------------
  # ● 设置数据
  #--------------------------------------------------------------------------
  def set_up
    # 初始化实例变量
    enemy = @id == 198 ? $game_task.wanted_data : $data_enemies[@id]
    @type,@gender,@age = enemy.type,enemy.gender,enemy.age
    @base_hit,@base_eva = enemy.base_hit,enemy.base_eva
    @base_atk,@base_def = enemy.base_atk,enemy.base_def
    @fp_plus,@mp_plus,@morals = enemy.fp_plus,enemy.mp_plus,enemy.morals
    @base_str,@base_agi = enemy.base_str,enemy.base_agi
    @base_int,@base_bon = enemy.base_int,enemy.base_bon
    @base_fac,@base_luc,@hp = enemy.base_fac,enemy.base_luc,enemy.hp
    @fp,@maxfp,@mp,@maxmp = enemy.fp,enemy.maxfp,enemy.mp,enemy.maxmp
    @full_hp,@item1,@item2 = enemy.full_hp,enemy.item1,enemy.item2
    @item3,@item4,@skill_use = enemy.item3,enemy.item4,enemy.skill_use
    @skill_count,@skill_list = enemy.skill_count,enemy.skill_list
    @sell_count,@sell_item = enemy.sell_count,enemy.sell_item
    @des_text,@exp,@gold = enemy.des_text,enemy.exp,enemy.gold
    @battler_name,@name = enemy.battler_name,enemy.name
    @battler_hue,@maxhp = enemy.battler_hue,enemy.maxhp
    @weapon_id,@drugs = enemy.weapon_id,[4,2]
  end
  #--------------------------------------------------------------------------
  # ● 设置新的敌人
  #--------------------------------------------------------------------------
  def set_new_id(id)
    @id = id
    set_up
  end
  #--------------------------------------------------------------------------
  # ● 获取敌人 ID
  #--------------------------------------------------------------------------
  def id
    return @id
  end
  #--------------------------------------------------------------------------
  # ● 所有物品列表
  #--------------------------------------------------------------------------
  def item_list
    n = []
    n.push([2,@weapon_id]) if @weapon_id != 0
    n.push(@item1) if @item1[0]>0
    # 如果是坛主，则将地图优先级提前
    n.reverse! if n.size == 2 and (id > 162 and id < 171)
    n.push(@item2) if @item2[0]>0
    n.push(@item3) if @item3[0]>0
    n.push(@item4) if @item4[0]>0
    return n
  end
  #--------------------------------------------------------------------------
  # ● 清空物品
  #--------------------------------------------------------------------------
  def clear_item
    return if item_list.empty?
    n = []
    item_list.each do |i|
      # 若为三角石板或坛地图则记录
      n.push(i) if (i[0] == 1 and i[1].abs == 19)
      n.push(i) if (i[0] == 1 and (21..28).include?(i[1].abs))
    end
    # 清空物品列表
    @weapon_id,@item1,@item2,@item3,@item4 = 0,[0,0],[0,0],[0,0],[0,0]
    unless n.empty?
      @item1 = n[0]
      @item2 = n[1] if n[1] != nil
      @item3 = n[2] if n[2] != nil
      @item4 = n[3] if n[3] != nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 装备列表
  #--------------------------------------------------------------------------
  def equip_list
    n = [@weapon_id,0,0,0,0]
    n[1] = (@item1[0]==3 and @item1[1]>0) ? @item1[1] : 0
    n[2] = (@item2[0]==3 and @item2[1]>0) ? @item2[1] : 0
    n[3] = (@item3[0]==3 and @item3[1]>0) ? @item3[1] : 0
    n[4] = (@item4[0]==3 and @item4[1]>0) ? @item4[1] : 0
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取装备附加膂力
  #--------------------------------------------------------------------------
  def equip_str
    n = 0
    weapon = @weapon_id > 0 ? $data_weapons[@weapon_id] : nil
    n += weapon != nil ? weapon.add_str : 0
    for i in 1..4
      armor = $data_armors[equip_list[i]]
      n += armor != nil ? armor.add_str : 0
    end
    return [n,255].min
  end
  #--------------------------------------------------------------------------
  # ● 获取装备附加敏捷
  #--------------------------------------------------------------------------
  def equip_agi
    n = 0
    weapon = @weapon_id > 0 ? $data_weapons[@weapon_id] : nil
    n += weapon != nil ? weapon.add_agi : 0
    for i in 1..4
      armor = $data_armors[equip_list[i]]
      n += armor != nil ? armor.add_agi : 0
    end
    return [n,255].min
  end
  #--------------------------------------------------------------------------
  # ● 获取装备附加悟性
  #--------------------------------------------------------------------------
  def equip_int
    n = 0
    weapon = @weapon_id > 0 ? $data_weapons[@weapon_id] : nil
    n += weapon != nil ? weapon.add_int : 0
    for i in 1..4
      armor = $data_armors[equip_list[i]]
      n += armor != nil ? armor.add_int : 0
    end
    return [n,255].min
  end
  #--------------------------------------------------------------------------
  # ● 获取装备附加根骨
  #--------------------------------------------------------------------------
  def equip_bon
    n = 0
    weapon = @weapon_id > 0 ? $data_weapons[@weapon_id] : nil
    n += weapon != nil ? weapon.add_bon : 0
    for i in 1..4
      armor = $data_armors[equip_list[i]]
      n += armor != nil ? armor.add_bon : 0
    end
    return [n,255].min
  end
  #--------------------------------------------------------------------------
  # ● 获取装备附加相貌
  #--------------------------------------------------------------------------
  def equip_fac
    n = 0
    weapon = @weapon_id > 0 ? $data_weapons[@weapon_id] : nil
    n += weapon != nil ? weapon.add_fac : 0
    for i in 1..4
      armor = $data_armors[equip_list[i]]
      n += armor != nil ? armor.add_fac : 0
    end
    return [n,255].min
  end
  #--------------------------------------------------------------------------
  # ● 获取装备附加命中
  #--------------------------------------------------------------------------
  def equip_hit
    n = 0
    weapon = @weapon_id > 0 ? $data_weapons[@weapon_id] : nil
    n += weapon != nil ? weapon.add_hit : 0
    for i in 1..4
      armor = $data_armors[equip_list[i]]
      n += armor != nil ? armor.add_hit : 0
    end
    return [n,255].min
  end
  #--------------------------------------------------------------------------
  # ● 获取装备附加闪避
  #--------------------------------------------------------------------------
  def equip_eva
    n = 0
    weapon = @weapon_id > 0 ? $data_weapons[@weapon_id] : nil
    n += weapon != nil ? weapon.add_eva : 0
    for i in 1..4
      armor = $data_armors[equip_list[i]]
      n += armor != nil ? armor.add_eva : 0
    end
    return [n,255].min
  end
  #--------------------------------------------------------------------------
  # ● 获取装备附加攻击
  #--------------------------------------------------------------------------
  def equip_atk
    n = 0
    weapon = @weapon_id > 0 ? $data_weapons[@weapon_id] : nil
    n += weapon != nil ? weapon.add_atk : 0
    for i in 1..4
      armor = $data_armors[equip_list[i]]
      n += armor != nil ? armor.add_atk : 0
    end
    return [n,255].min
  end
  #--------------------------------------------------------------------------
  # ● 获取装备附加防御
  #--------------------------------------------------------------------------
  def equip_def
    n = 0
    weapon = @weapon_id > 0 ? $data_weapons[@weapon_id] : nil
    n += weapon != nil ? weapon.add_def : 0
    for i in 1..4
      armor = $data_armors[equip_list[i]]
      n += armor != nil ? armor.add_def : 0
    end
    return [n,255].min
  end
  #--------------------------------------------------------------------------
  # ● 获取招架功夫有效等级
  #--------------------------------------------------------------------------
  def parry_kf_lv
    n = 0
    # +基本招架等级/2+使用招架等级
    n += get_kf_level(10)/2 + get_kf_level(@skill_use[4])
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取生命最大值
  #--------------------------------------------------------------------------
  def full_hp
    return @full_hp
  end
  #--------------------------------------------------------------------------
  # ● 普通攻击 获取攻击方动画 ID
  #--------------------------------------------------------------------------
  def animation1_id
    return $data_enemies[@id].animation1_id
  end
  #--------------------------------------------------------------------------
  # ● 普通攻击 获取对像方动画 ID
  #--------------------------------------------------------------------------
  def animation2_id
    return $data_enemies[@id].animation2_id
  end
  #--------------------------------------------------------------------------
  # ● 取得战斗画面 X 坐标
  #--------------------------------------------------------------------------
  def screen_x
    return 480
  end
  #--------------------------------------------------------------------------
  # ● 取得战斗画面 Y 坐标
  #--------------------------------------------------------------------------
  def screen_y
    return 160
  end
  #--------------------------------------------------------------------------
  # ● 取得战斗画面 Z 坐标
  #--------------------------------------------------------------------------
  def screen_z
    return screen_y
  end
  #--------------------------------------------------------------------------
  # ● 逃跑
  #--------------------------------------------------------------------------
  def escape
    # 设置隐藏标志
    @hidden = true
    # 清除当前行动
    self.current_action.clear
  end
  #--------------------------------------------------------------------------
  # ● 变身
  #     enemy_id : 变身为的敌人 ID
  #--------------------------------------------------------------------------
  def transform(enemy_id)
    # 更改敌人 ID
    @id = enemy_id
    # 更新数据
    set_up
  end
  #--------------------------------------------------------------------------
  # ● 全回复
  #--------------------------------------------------------------------------
  def recover_all
    @maxhp = @full_hp
    @hp = @maxhp
    @fp = @maxfp
    @mp = @maxmp
    for i in @states.clone
      remove_state(i)
    end
    clear_temp_data
  end
  #--------------------------------------------------------------------------
  # ● 金疮药数量
  #--------------------------------------------------------------------------
  def drug1_num
    return @drugs[0]
  end
  #--------------------------------------------------------------------------
  # ● 生肌膏数量
  #--------------------------------------------------------------------------
  def drug2_num
    return @drugs[1]
  end
  #--------------------------------------------------------------------------
  # ● 使用药品
  #--------------------------------------------------------------------------
  def use_drug(type)
    item_id = type + 7
    item_effect(item_id)
    @drugs[type-1] -= 1
  end
  #--------------------------------------------------------------------------
  # ● 可以使用的绝招
  #--------------------------------------------------------------------------
  def skill_is_ready(target)
    n = []
    return n if skills.empty?
    skills.each do |i|
      # 连珠雷，三昧火，火风暴，暴风雪，冰凌剑不对玩家使用
      next if [32,35,36,39,40].include?(i)
      result = skill_can_use?(i,target)
      n.push(i) if result[0]
    end
    return n
  end
  #--------------------------------------------------------------------------
  # ● 判断是否使用绝招
  #--------------------------------------------------------------------------
  def skill_judge(skill_id,target)
    # 根据绝招判断是否使用
    case skill_id
    when 6 # 落英缤纷
      # 目标有武器判断敏捷
      if target.weapon_id > 0
        result = agi * 3 / 2
        judge = target.agi
      else # 未装备武器
        result = get_kf_efflv(19) * 3 / 2
        judge = target.dodge_kf_lv
      end
    when 13,15,16,17 # 忍术烟幕，震字诀，挤字诀，乱环诀
      result = @fp * 3 / 2
      judge = target.fp
    when 19 # 缠字诀
      result = @exp * 3 / 2
      judge = target.exp
    when 22 # 神倒鬼跌
      result = @fp
      judge = target.fp
    when 25 # 恶虎啸
      result = fp_kf_lv * 10
      judge = target.maxfp
    when 29,30,31,33,34,37,38 # 闪光弹/雷火弹/掌心雷/火焰球/烈焰球/寒冰弹/雾棱镖
      sp_skill = $data_skills[skill_id]
      # 获取法术数据
      m_data = sp_skill.magic_data
      m_hit,m_damage = m_data[2],m_data[3]
      result = @mp >= target.fp * 8 / 10 ? magic_hit(target,m_hit) : 0
      judge = 50
    else
      result = 100
      judge = 0
    end
    # 自身血量低时孤注一掷(不含恶虎啸)
    result *= 2 if @hp *100 / full_hp < 30 and skill_id != 25
    return result > judge ? true : false
  end
end
