#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　处理同伴的类。包含金钱以及物品的信息。本类的实例
# 请参考 $game_party。
#==============================================================================

class Game_Party
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :actors                   # 角色
  attr_reader   :gold                     # 金钱
  attr_reader   :steps                    # 步数
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    # 建立角色序列
    @actors = []
    # 初始化金钱与步数
    @gold = 0
    @steps = 0
    # 生成物品、武器、防具的所持数 hash
    @items = {}
    @weapons = {}
    @armors = {}
  end
  #--------------------------------------------------------------------------
  # ● 设置初期同伴
  #--------------------------------------------------------------------------
  def setup_starting_members
    @actors = []
    for i in $data_system.party_members
      @actors.push($game_actors[i])
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置战斗测试用同伴
  #--------------------------------------------------------------------------
  def setup_battle_test_members
    @actors = []
    for battler in $data_system.test_battlers
      actor = $game_actors[battler.actor_id]
      actor.level = battler.level
      gain_weapon(battler.weapon_id, 1)
      gain_armor(battler.armor1_id, 1)
      gain_armor(battler.armor2_id, 1)
      gain_armor(battler.armor3_id, 1)
      gain_armor(battler.armor4_id, 1)
      actor.equip(0, battler.weapon_id)
      actor.equip(1, battler.armor1_id)
      actor.equip(2, battler.armor2_id)
      actor.equip(3, battler.armor3_id)
      actor.equip(4, battler.armor4_id)
      actor.recover_all
      @actors.push(actor)
    end
    @items = {}
    for i in 1...$data_items.size
      if $data_items[i].name != ""
        occasion = $data_items[i].occasion
        if occasion == 0 or occasion == 1
          @items[i] = 99
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 同伴成员的还原
  #--------------------------------------------------------------------------
  def refresh
    # 游戏数据载入后角色对像直接从 $game_actors
    # 分离。
    # 回避由于载入造成的角色再设置的问题。
    new_actors = []
    for i in 0...@actors.size
      if $data_actors[@actors[i].id] != nil
        new_actors.push($game_actors[@actors[i].id])
      end
    end
    @actors = new_actors
  end
  #--------------------------------------------------------------------------
  # ● 获取最大等级
  #--------------------------------------------------------------------------
  def max_level
    # 同伴人数为 0 的情况下
    if @actors.size == 0
      return 0
    end
    # 初始化本地变量 level
    level = 0
    # 求得同伴的最大等级
    for actor in @actors
      if level < actor.level
        level = actor.level
      end
    end
    return level
  end
  #--------------------------------------------------------------------------
  # ● 加入同伴
  #     actor_id : 角色 ID
  #--------------------------------------------------------------------------
  def add_actor(actor_id)
    # 获取角色
    actor = $game_actors[actor_id]
    # 同伴人数未满 4 人、本角色不在队伍中的情况下
    if @actors.size < 4 and not @actors.include?(actor)
      # 添加角色
      @actors.push(actor)
      # 还原主角
      $game_player.refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● 角色离开
  #     actor_id : 角色 ID
  #--------------------------------------------------------------------------
  def remove_actor(actor_id)
    # 删除角色
    @actors.delete($game_actors[actor_id])
    # 还原主角
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # ● 增加金钱 (减少)
  #     n : 金额
  #--------------------------------------------------------------------------
  def gain_gold(n)
    @gold = [[@gold + n, 0].max, 9999999].min
  end
  #--------------------------------------------------------------------------
  # ● 减少金钱
  #     n : 金额
  #--------------------------------------------------------------------------
  def lose_gold(n)
    # 调用数值逆转 gain_gold 
    gain_gold(-n)
  end
  #--------------------------------------------------------------------------
  # ● 增加步数
  #--------------------------------------------------------------------------
  def increase_steps
    @steps = [@steps + 1, 9999999].min
  end
  #--------------------------------------------------------------------------
  # ● 获取物品的所持数
  #     item_id : 物品 ID
  #--------------------------------------------------------------------------
  def item_number(item_id)
    # 如果 hash 个数数值不存在就返回 0
    return @items.include?(item_id) ? @items[item_id] : 0
  end
  #--------------------------------------------------------------------------
  # ● 获取武器所持数
  #     weapon_id : 武器 ID
  #--------------------------------------------------------------------------
  def weapon_number(weapon_id)
    # 如果 hash 个数数值不存在就返回 0
    return @weapons.include?(weapon_id) ? @weapons[weapon_id] : 0
  end
  #--------------------------------------------------------------------------
  # ● 获取防具所持数
  #     armor_id : 防具 ID
  #--------------------------------------------------------------------------
  def armor_number(armor_id)
    # 如果 hash 个数数值不存在就返回 0
    return @armors.include?(armor_id) ? @armors[armor_id] : 0
  end
  #--------------------------------------------------------------------------
  # ● 增加物品 (减少)
  #     item_id : 物品 ID
  #     n       : 个数
  #--------------------------------------------------------------------------
  def gain_item(item_id, n)
    # 更新 hash 的个数数据
    if item_id > 0
      @items[item_id] = [[item_number(item_id) + n, 0].max, 99].min
    end
  end
  #--------------------------------------------------------------------------
  # ● 增加武器 (减少)
  #     weapon_id : 武器 ID
  #     n         : 个数
  #--------------------------------------------------------------------------
  def gain_weapon(weapon_id, n)
    # 更新 hash 的个数数据
    if weapon_id > 0
      @weapons[weapon_id] = [[weapon_number(weapon_id) + n, 0].max, 99].min
    end
  end
  #--------------------------------------------------------------------------
  # ● 增加防具 (减少)
  #     armor_id : 防具 ID
  #     n        : 个数
  #--------------------------------------------------------------------------
  def gain_armor(armor_id, n)
    # 更新 hash 的个数数据
    if armor_id > 0
      @armors[armor_id] = [[armor_number(armor_id) + n, 0].max, 99].min
    end
  end
  #--------------------------------------------------------------------------
  # ● 减少物品
  #     item_id : 物品 ID
  #     n       : 个数
  #--------------------------------------------------------------------------
  def lose_item(item_id, n)
    # 调用 gain_item 的数值逆转
    gain_item(item_id, -n)
  end
  #--------------------------------------------------------------------------
  # ● 减少武器
  #     weapon_id : 武器 ID
  #     n         : 个数
  #--------------------------------------------------------------------------
  def lose_weapon(weapon_id, n)
    # 调用 gain_weapon 的数值逆转
    gain_weapon(weapon_id, -n)
  end
  #--------------------------------------------------------------------------
  # ● 减少防具
  #     armor_id : 防具 ID
  #     n        : 个数
  #--------------------------------------------------------------------------
  def lose_armor(armor_id, n)
    # 调用 gain_armor 的数值逆转
    gain_armor(armor_id, -n)
  end
  #--------------------------------------------------------------------------
  # ● 判断物品可以使用
  #     item_id : 物品 ID
  #--------------------------------------------------------------------------
  def item_can_use?(item_id)
    # 物品个数为 0 的情况
    if item_number(item_id) == 0
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
  # ● 清除全体的行动
  #--------------------------------------------------------------------------
  def clear_actions
    # 清除全体同伴的行为
    for actor in @actors
      actor.current_action.clear
    end
  end
  #--------------------------------------------------------------------------
  # ● 可以输入命令的判定
  #--------------------------------------------------------------------------
  def inputable?
    # 如果一可以输入命令就返回 true
    for actor in @actors
      if actor.inputable?
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 全灭判定
  #--------------------------------------------------------------------------
  def all_dead?
    # 同伴人数为 0 的情况下
    if $game_party.actors.size == 0
      return false
    end
    # 同伴中无人 HP 在 0 以上
    for actor in @actors
      if actor.hp > 0
        return false
      end
    end
    # 全灭
    return true
  end
  #--------------------------------------------------------------------------
  # ● 检查连续伤害 (地图用)
  #--------------------------------------------------------------------------
  def check_map_slip_damage
    for actor in @actors
      if actor.hp > 0 and actor.slip_damage?
        actor.hp -= [actor.maxhp / 100, 1].max
        if actor.hp == 0
          $game_system.se_play($data_system.actor_collapse_se)
        end
        $game_screen.start_flash(Color.new(255,0,0,128), 4)
        $game_temp.gameover = $game_party.all_dead?
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 对像角色的随机确定
  #     hp0 : 限制为 HP 0 的角色
  #--------------------------------------------------------------------------
  def random_target_actor(hp0 = false)
    # 初始化轮流
    roulette = []
    # 循环
    for actor in @actors
      # 符合条件的场合
      if (not hp0 and actor.exist?) or (hp0 and actor.hp0?)
        # 获取角色职业的位置 [位置]
        position = $data_classes[actor.class_id].position
        # 前卫的话 n = 4、中卫的话 n = 3、后卫的话 n = 2
        n = 4 - position
        # 添加角色的轮流 n 回
        n.times do
          roulette.push(actor)
        end
      end
    end
    # 轮流大小为 0 的情况
    if roulette.size == 0
      return nil
    end
    # 转轮盘赌，决定角色
    return roulette[rand(roulette.size)]
  end
  #--------------------------------------------------------------------------
  # ● 对像角色的随机确定 (HP 0)
  #--------------------------------------------------------------------------
  def random_target_actor_hp0
    return random_target_actor(true)
  end
  #--------------------------------------------------------------------------
  # ● 对像角色的顺序确定
  #     actor_index : 角色索引
  #--------------------------------------------------------------------------
  def smooth_target_actor(actor_index)
    # 取得对像
    actor = @actors[actor_index]
    # 对像存在的情况下
    if actor != nil and actor.exist?
      return actor
    end
    # 循环
    for actor in @actors
      # 对像存在的情况下
      if actor.exist?
        return actor
      end
    end
  end
end
