#==============================================================================
# ■ Game_Actor (分割定义 2)
#------------------------------------------------------------------------------
# 　处理角色的类。本类在 Game_Actors 类 ($game_actors)
# 的内部使用、Game_Party 类请参考 ($game_party) 。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 卸下所有装备
  #--------------------------------------------------------------------------
  def unequip_all
    @weapon_id,@armor1_id,@armor2_id,@armor3_id = 0,0,0,0
    @armor4_id,@armor5_id,@armor6_id,@armor7_id = 0,0,0,0
    return if @item_bag.empty?
    @item_bag.each do |i|
      i[3] = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新装备状态
  #--------------------------------------------------------------------------
  def refresh_equip
    if @item_bag.empty?
      unequip_all 
      return
    end
    all_equip = []
    # 获取所有已装备的物品
    @item_bag.each do |i|
      all_equip.push(i) if i[3] == 0
    end
    if all_equip.empty?
      unequip_all 
      return
    end
    # 依次判定装备
    all_equip.each do |i|
      type,id = [i][0],i[1]
      if type == 2
        @weapon_id = id
      else
        armor = $data_armors[i[1]]
        case armor.kind
        when 0
          @armor1_id = i[1]
        when 1
          @armor2_id = i[1]
        when 2
          @armor3_id = i[1]
        when 3
          @armor4_id = i[1]
        when 4
          @armor5_id = i[1]
        when 5
          @armor6_id = i[1]
        when 6
          @armor7_id = i[1]
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 变更装备
  #     type  : 装备类型
  #     id    : 背包位置
  #--------------------------------------------------------------------------
  def equip(type, id)
    case type
    when 1 # 武器
      # 获取当前装备武器的背包位置
      old_id = get_item_index(2,@weapon_id,1)
      # 如果存在已装备武器，则将其装备标志置为0
      if old_id > -1 and old_id != id
        @item_bag[old_id][3] = 0
        @weapon_id = 0
      end
      # 更新装备标志
      @item_bag[id][3] = (@item_bag[id][3] + 1) % 2
      @weapon_id = @item_bag[id][1] if @item_bag[id][3] == 1
    when 2 # 装备
      # 获取新装备类型
      new_armor_id = @item_bag[id][1]
      armor_type = $data_armors[new_armor_id].kind+1
      # 获取当前装备防具的背包位置
      old_id = get_item_index(3,equip_list[armor_type],1)
      # 如果存在已装备防具，则将其装备标志置为0
      set_armor = "@armor" + armor_type.to_s + "_id"
      if old_id > -1 and old_id != id
        @item_bag[old_id][3] = 0
        clear_armor = set_armor + "=0"
        eval(clear_armor)
      end
      # 更新装备标志
      @item_bag[id][3] = (@item_bag[id][3] + 1) % 2
      set_armor += "=@item_bag[id][1]"
      eval(set_armor) if @item_bag[id][3] == 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 变更技能
  #     type  : 技能类型
  #     id    : 技能列表位置
  #--------------------------------------------------------------------------
  def equip_kf(type, id)
    kf = @skill_list[id]
    # 变更招架的状况
    if type == 4 
      @skill_use[4] = @skill_use[4] == kf[0] ? 0 : kf[0]
      return
    end
    # 获得当前已装备的同类型技能位置
    old_id = get_kf_index(@skill_use[type])
    # 如果已存在装备的同类技能
    if old_id > -1 and old_id != id
      @skill_list[old_id][3] = 0
      @skill_use[type] = 0
      # 如果是装备的招架，则移除招架
      @skill_use[4] = 0 if @skill_list[old_id][0] == @skill_use[4]
    end
    # 更新装备标志
    @skill_list[id][3] = (@skill_list[id][3] + 1) % 2
    @skill_use[type] = skill_list[id][0] if @skill_list[id][3] == 1
  end
  #--------------------------------------------------------------------------
  # ● 更改 EXP
  #     exp : 新的 EXP
  #--------------------------------------------------------------------------
  def exp=(exp)
    @exp = [[exp, 4294967295].min, 0].max
  end
  #--------------------------------------------------------------------------
  # ● 更改 POT
  #     exp : 新的 POT
  #--------------------------------------------------------------------------
  def pot=(pot)
    @pot = [[pot, 4294967295].min, 0].max
  end
  #--------------------------------------------------------------------------
  # ● 更改名称
  #     name : 新的名称
  #--------------------------------------------------------------------------
  def name=(name)
    @name = name
  end
  #--------------------------------------------------------------------------
  # ● 更改图形
  #     character_name : 新的角色 文件名
  #     character_hue  : 新的角色 色相
  #     battler_name   : 新的战斗者 文件名
  #     battler_hue    : 新的战斗者 色相
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_hue, battler_name, battler_hue)
    @character_name = character_name
    @character_hue = character_hue
    @battler_name = battler_name
    @battler_hue = battler_hue
  end
  #--------------------------------------------------------------------------
  # ● 取得战斗画面的 X 坐标
  #--------------------------------------------------------------------------
  def screen_x
    return 160
  end
  #--------------------------------------------------------------------------
  # ● 取得战斗画面的 Y 坐标
  #--------------------------------------------------------------------------
  def screen_y
    return 160
  end
  #--------------------------------------------------------------------------
  # ● 取得战斗画面的 Z 坐标
  #--------------------------------------------------------------------------
  def screen_z
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 获取相应属性(调试用)
  #--------------------------------------------------------------------------
  def get_status(type)
    case type
    when 0 # 金钱
      return @gold
    when 1 # 经验
      return @exp
    when 2 # 潜能
      return @pot
    when 3 # 内力
      return @maxfp
    when 4 # 法力
      return @maxmp
    when 5 # 声望
      return @morals
    when 6 # 杀手
      return @task_kill
    when 7 # 追杀
      return @badman_kill
    when 8 # 屠杀
      return @kill_list.size
    when 9 # 性别
      return @gender
    when 10 # 外貌
      return face
    when 11 # 福缘
      return luck
    when 12 # 年龄
      return @age
    when 13 # 时间
      return @play_time
    when 14 # 跳舞
      return @dance
    when 15 # 铅球
      return @ball
    end
  end
  #--------------------------------------------------------------------------
  # ● 修改相应属性(调试用)
  #--------------------------------------------------------------------------
  def cheat_status(type,number)
    case type
    when 0 # 金钱
      @gold = number
    when 1 # 经验
      @exp = number
    when 2 # 潜能
      @pot = number
    when 3 # 内力
      @maxfp = number
    when 4 # 法力
      @maxmp = number
    when 5 # 声望
      @morals = number
    when 6 # 杀手
      @task_kill = number
    when 7 # 追杀
      @badman_kill = number
    when 8 # 屠杀
      @kill_num = number
    when 9 # 性别
      @gender = number
    when 10 # 外貌
      @base_fac = number - get_kf_level(22)/10 - equip_fac
    when 11 # 福缘
      @base_luc = number - @donate_times
    when 12 # 年龄
      @age = number
    when 13 # 时间
      @play_time = number
    when 14 # 跳舞
      @dance = number
    when 15 # 铅球
      @ball = number
    end
  end
end