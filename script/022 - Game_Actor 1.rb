#==============================================================================
# ■ Game_Actor (分割定义 1)
#------------------------------------------------------------------------------
# 　处理角色的类。本类在 Game_Actors 类 ($game_actors)
# 的内部使用、Game_Party 类请参考 ($game_party) 。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor :character_name           # 角色 文件名
  attr_accessor :character_hue            # 角色 色相
  attr_accessor :class_id                 # 门派 ID
  attr_accessor :teacher_id               # 师父 ID
  attr_accessor :weapon_id                # 武器 ID
  attr_accessor :armor1_id                # 衣服 ID
  attr_accessor :armor2_id                # 背心 ID
  attr_accessor :armor3_id                # 饰品 ID
  attr_accessor :armor4_id                # 鞋子 ID
  attr_accessor :armor5_id                # 腰带 ID
  attr_accessor :armor6_id                # 披风 ID
  attr_accessor :armor7_id                # 钓竿 ID
  attr_accessor :pot                      # 潜能
  attr_accessor :food                     # 食物
  attr_accessor :water                    # 饮水
  attr_accessor :max_food                 # 食物最大值
  attr_accessor :max_water                # 饮水最大值
  attr_accessor :marry                    # 结婚标志0-单身，1-已婚
  attr_accessor :marry_name               # 对象名字
  attr_accessor :item_bag                 # 背包
  attr_accessor :stone_list               # 已获得石板NPC列表
  attr_accessor :kill_list                # 击杀NPC列表
  attr_accessor :kill_num                 # 总杀人数
  attr_accessor :badman_kill              # 击杀恶人数量
  attr_accessor :task_kill                # 平一指任务完成数量
  attr_accessor :sword_battle             # 铸剑挑战
  attr_accessor :sword_name               # 铸剑名称
  attr_accessor :sword_type               # 铸剑类型
  attr_accessor :sword1                   # 铸剑前缀参数
  attr_accessor :sword2                   # 铸剑中缀参数
  attr_accessor :sword3                   # 铸剑后缀参数
  attr_accessor :sword_exp                # 铸剑经验
  attr_accessor :sword_gold               # 铸剑金钱
  attr_accessor :sword_times              # 铸剑次数
  attr_accessor :dance                    # 跳舞最高分
  attr_accessor :ball                     # 铅球高分
  attr_accessor :play_time                # 游戏时间（单位秒）
  attr_accessor :donate_times             # 捐款次数
  attr_accessor :tan_id                   # 坛任务序号
  attr_accessor :xue6                     # 雪花六出标志
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super()
    @name,@character_name,@character_hue,@battler_name = "","",0,""
    @battler_hue,@class_id,@weapon_id,@armor1_id,@armor2_id = 0,0,0,0,0
    @armor3_id,@armor4_id,@armor5_id,@armor6_id,@armor7_id = 0,0,0,0,0
    @age,@morals,@base_str,@base_agi,@base_int = 14,128,20,20,20
    @base_bon,@base_fac,@base_luc,@maxhp,@pot = 20,20,20,100,100
    @food,@water,@marry,@marry_name,@gold = 100,100,0,"",100
    @item_bag,@play_time,@hp,@xue6 = [],0,100,false
    @skill_use,@badman_kill,@dance,@ball = [0,0,0,0,0,0],0,100,100
    @states,@stone_list,@kill_list,@task_kill = [],[],[],0
    @states_turn,@tan_id,@sword_battle,@sword_name = {},0,false,""
    @sword_times,@sword_type,@sword1,@sword2,@sword3 = 0,0,0,0,0
    @sword_exp,@sword_gold,@kill_num = 0,0,0
    @donate_times = 0
  end
  #--------------------------------------------------------------------------
  # ● 获取角色 ID 
  #--------------------------------------------------------------------------
  def id
    return 1
  end
  #--------------------------------------------------------------------------
  # ● 设置铸造武器属性 
  #--------------------------------------------------------------------------
  def set_sword
    return if @sword_type == 0
    # 攻击为前缀参数
    $data_weapons[31].atk = @sword1
    # 中缀、后缀参数/100为类型
    sword2_type = @sword2 / 100
    sword3_type = @sword3 / 100
    # 中缀、后缀参数%100为数值
    sword2_data = @sword2 % 100
    sword3_data = @sword3 % 100
    # 设置中缀属性
    if sword2_type > 2
      # 中缀1，2为战斗中状态效果
      case sword2_type
      when 3 # 增加闪避
        $data_weapons[31].add_eva = sword2_data
      when 4 # 增加命中
        $data_weapons[31].add_hit = sword2_data
      end
    end
    # 设置后缀属性
    if sword3_type > 0
      case sword3_type
      when 1 # 增加膂力
        $data_weapons[31].add_str = sword3_data
      when 2 # 增加敏捷
        $data_weapons[31].add_agi = sword3_data
      when 3 # 增加悟性
        $data_weapons[31].add_int = sword3_data
      when 4 # 增加根骨
        $data_weapons[31].add_bon = sword3_data
      when 5 # 增加外貌
        $data_weapons[31].add_fac = sword3_data
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 出售列表，每条数据格式[type,id,num,equip],bag_id
  #--------------------------------------------------------------------------
  def sell_list
    return nil if @item_bag.empty?
    list = []
    @item_bag.each_index do |i|
      # 跳过已装备物品
      next if @item_bag[i][3] == 1
      type,id = @item_bag[i][0],@item_bag[i][1]
      case type
      when 1 # 物品
        list.push([@item_bag[i],i]) if $data_items[id].can_sell
      when 2 # 武器
        list.push([@item_bag[i],i]) if $data_weapons[id].can_sell
      when 3 # 装备
        list.push([@item_bag[i],i]) if $data_armors[id].can_sell
      end
    end
    list = nil if list.empty?
    return list
  end
  #--------------------------------------------------------------------------
  # ● 获取指定物品首个位置序号
  #--------------------------------------------------------------------------
  def get_item_index(type,id,equip=0)
    # 背包为空
    return -1 if @item_bag.size == 0
    n = -1
    @item_bag.each_index do |i|
      item_data = @item_bag[i]
      if type == item_data[0] and id == item_data[1] and equip == item_data[3]
        n = i
        break
      end
    end
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获得物品
  #--------------------------------------------------------------------------
  def gain_item(type,id,number=1)
    return if full_item_bag?
    # 类型不是物品的情况
    if type != 1
      @item_bag.push([type,id,number,0])
      return
    end
    # 物品可叠加，则寻找物品位置增加数量
    n = get_item_index(type,id)
    if $data_items[id].can_add and n > -1
      @item_bag[n][2] += number
      @item_bag[n][2] = [@item_bag[n][2],255].min
    else # 背包没有该物品
      @item_bag.push([type,id,number,0])
    end
  end
  #--------------------------------------------------------------------------
  # ● 失去物品(指定物品类型和ID)
  #--------------------------------------------------------------------------
  def lose_item(type,id,number=1)
    # 背包为空或没有该物品
    return if get_item_index(type,id) == -1
    for i in 1..number
      index = get_item_index(type,id)
      @item_bag[index][2] -= 1
      # 数量归零则从背包中删除数据
      @item_bag.delete_at(index) if @item_bag[index][2] == 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 失去物品(指定背包位置)
  #--------------------------------------------------------------------------
  def lose_bag_id(bag_id,number=1)
    @item_bag[bag_id][2] -= number
    # 数量归零则从背包中删除数据
    if @item_bag[bag_id][2] == 0
      @item_bag.delete_at(bag_id)
      return true
    else
      return false
    end
  end
  #--------------------------------------------------------------------------
  # ● 是否可以获得指定物品
  #--------------------------------------------------------------------------
  def can_get_item?(type,id,number=1)
    # 背包未满可获得
    return true if not full_item_bag?
    # 背包已满且类别不为物品则不可获得
    return false if type != 1
    # 背包已满，类别为物品，且背包已有物品则可获得
    return true if $data_items[id].can_add and item_number(type,id)>0
    return false
  end
  #--------------------------------------------------------------------------
  # ● 是否可以获得菜花宝典
  #--------------------------------------------------------------------------
  def can_get_caihua?
    # 物品栏可以获得物品，道德<128，装备老花镜，年龄<18，男性
    flag = (can_get_item?(1,20) and @morals<128 and @armor3_id == 2)
    flag = (flag and @age<18 and @gender == 0)
    return flag
  end
  #--------------------------------------------------------------------------
  # ● 获取物品数量
  #--------------------------------------------------------------------------
  def item_number(type,id)
    return 0 if @item_bag.size == 0
    return @stone_list.size if type == 1 and id == 19
    n = 0
    # 不可叠加的物品统计所有数量，已装备物品不计入
    @item_bag.each do |i|
      n += i[2] if type == i[0] and id == i[1] and i[3] != 1
    end
    return n
  end
  #--------------------------------------------------------------------------
  # ● 判断物品可以使用
  #     item_id : 物品 ID
  #--------------------------------------------------------------------------
  def item_can_use?(item_id)
    # 物品个数为 0 的情况
    if item_number(1,item_id) == 0
      # 不能使用
      return false
    end
    # 获取可以使用的时候
    occasion = $data_items[item_id].occasion
    # 战斗的情况
    if $game_temp.in_battle
      # 可以使用时为 0 (平时) 或者是 1 (战斗时) 可以使用
      return (occasion == 0 or occasion == 1)
    end
    # 可以使用时为 0 (平时) 或者是 2 (菜单时) 可以使用
    return (occasion == 0 or occasion == 2)
  end
  #--------------------------------------------------------------------------
  # ● 获取最大生命值
  #--------------------------------------------------------------------------
  def full_hp
    n = 100 + @maxfp / 4 + ([@age,29].min - 14) * 20
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取最大内力值
  #--------------------------------------------------------------------------
  def full_fp
    n = fp_kf_lv*10 + @exp/1000 + ([@age,60].min-14)*@base_bon
    return [n,65535].min
  end
  #--------------------------------------------------------------------------
  # ● 获取最大法力值
  #--------------------------------------------------------------------------
  def full_mp
    n = mp_kf_lv*10 + @exp/1000 + ([@age,60].min-14)*@base_bon
    return [n,65535].min
  end
  #--------------------------------------------------------------------------
  # ● 获取食物上限
  #--------------------------------------------------------------------------
  def max_food
    return (@base_str+5)*15
  end
  #--------------------------------------------------------------------------
  # ● 获取饮水上限
  #--------------------------------------------------------------------------
  def max_water
    return (@base_str+4)*15
  end
  #--------------------------------------------------------------------------
  # ● 获取相貌等级
  #--------------------------------------------------------------------------
  def face_level
    return [[face-12,0].max,18].min/3
  end
  #--------------------------------------------------------------------------
  # ● 背包是否已满
  #--------------------------------------------------------------------------
  def full_item_bag?
    return @item_bag.size == 20 ? true : false
  end
  #--------------------------------------------------------------------------
  # ● 背包剩余空间
  #--------------------------------------------------------------------------
  def item_bag_space
    return 20-@item_bag.size
  end
  #--------------------------------------------------------------------------
  # ● 功夫列表是否已满
  #--------------------------------------------------------------------------
  def full_kf_list?
    return @skill_list.size == 20 ? true : false
  end
  #--------------------------------------------------------------------------
  # ● 功夫列表剩余空间
  #--------------------------------------------------------------------------
  def kf_list_space
    return 20-@skill_list.size
  end
  #--------------------------------------------------------------------------
  # ● 检查经验是否满足功夫提升需求
  #--------------------------------------------------------------------------
  def check_kf_exp(id)
    kf_lv = get_kf_level(id)
    return (self.exp >= kf_lv**3/10)
  end
  #--------------------------------------------------------------------------
  # ● 练功列表
  #--------------------------------------------------------------------------
  def practice_list
    n = [@skill_use[0],@skill_use[1],@skill_use[2]]
    list = []
    n.each do |i|
      list.push(i) if i>11
    end
    return list
  end
  #--------------------------------------------------------------------------
  # ● 获取普通攻击状态变化 (+)
  #--------------------------------------------------------------------------
  def plus_state_set
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.plus_state_set : []
  end
  #--------------------------------------------------------------------------
  # ● 获取普通攻击状态变化 (-)
  #--------------------------------------------------------------------------
  def minus_state_set
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.minus_state_set : []
  end
  #--------------------------------------------------------------------------
  # ● 获取基本 MaxHP
  #--------------------------------------------------------------------------
  def base_maxhp
    return 100
  end
  #--------------------------------------------------------------------------
  # ● 装备列表
  #--------------------------------------------------------------------------
  def equip_list
    n = [@weapon_id,@armor1_id,@armor2_id,@armor3_id,@armor4_id,@armor5_id,
         @armor6_id,@armor7_id]
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取福缘
  #--------------------------------------------------------------------------
  def luck
    return [@base_luc+@donate_times,250].min
  end
  #--------------------------------------------------------------------------
  # ● 获得金钱
  #--------------------------------------------------------------------------
  def gain_gold(n)
    @gold = [[@gold + n, 0].max, 4294967295].min
  end
  #--------------------------------------------------------------------------
  # ● 失去金钱
  #--------------------------------------------------------------------------
  def lose_gold(n)
    gain_gold(-n)
  end
  #--------------------------------------------------------------------------
  # ● 获取装备附加膂力
  #--------------------------------------------------------------------------
  def equip_str
    n = 0
    weapon = $data_weapons[@weapon_id]
    n += weapon != nil ? weapon.add_str : 0
    for i in 1..7
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
    weapon = $data_weapons[@weapon_id]
    n += weapon != nil ? weapon.add_agi : 0
    for i in 1..7
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
    weapon = $data_weapons[@weapon_id]
    n += weapon != nil ? weapon.add_int : 0
    for i in 1..7
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
    weapon = $data_weapons[@weapon_id]
    n += weapon != nil ? weapon.add_bon : 0
    for i in 1..7
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
    weapon = $data_weapons[@weapon_id]
    n += weapon != nil ? weapon.add_fac : 0
    for i in 1..7
      armor = $data_armors[equip_list[i]]
      n += armor != nil ? armor.add_fac : 0
    end
    return [n,255].min
  end
  #--------------------------------------------------------------------------
  # ● 获取装备攻击力
  #--------------------------------------------------------------------------
  def equip_atk
    n = 0
    weapon = $data_weapons[@weapon_id]
    n += weapon != nil ? weapon.add_atk : 0
    for i in 1..7
      armor = $data_armors[equip_list[i]]
      n += armor != nil ? armor.add_atk : 0
    end
    return [n,255].min
  end
  #--------------------------------------------------------------------------
  # ● 获取装备防御
  #--------------------------------------------------------------------------
  def equip_def
    n = 0
    weapon = $data_weapons[@weapon_id]
    n += weapon != nil ? weapon.add_def : 0
    for i in 1..7
      armor = $data_armors[equip_list[i]]
      n += armor != nil ? armor.add_def : 0
    end
    return [n,255].min
  end
  #--------------------------------------------------------------------------
  # ● 获取装备命中
  #--------------------------------------------------------------------------
  def equip_hit
    n = 0
    weapon = $data_weapons[@weapon_id]
    n += weapon != nil ? weapon.add_hit : 0
    for i in 1..7
      armor = $data_armors[equip_list[i]]
      n += armor != nil ? armor.add_hit : 0
    end
    return [n,255].min
  end
  #--------------------------------------------------------------------------
  # ● 获取装备闪避
  #--------------------------------------------------------------------------
  def equip_eva
    n = 0
    weapon = $data_weapons[@weapon_id]
    n += weapon != nil ? weapon.add_eva : 0
    for i in 1..7
      armor = $data_armors[equip_list[i]]
      n += armor != nil ? armor.add_eva : 0
    end
    return [n,255].min
  end
  #--------------------------------------------------------------------------
  # ● 普通攻击 获取攻击方动画 ID
  #--------------------------------------------------------------------------
  def animation1_id
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.animation1_id : 0
  end
  #--------------------------------------------------------------------------
  # ● 普通攻击 获取对像方动画 ID
  #--------------------------------------------------------------------------
  def animation2_id
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.animation2_id : 0
  end
  #--------------------------------------------------------------------------
  # ● 获取门派名
  #--------------------------------------------------------------------------
  def class_name
    return $data_system.school[@class_id]
  end
end
