#==============================================================================
# ■ Game_Troop
#------------------------------------------------------------------------------
# 　处理队伍的类。本类的实例请参考 $game_troop
# 
#==============================================================================

class Game_Troop
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    # 建立敌人序列
    @enemies = []
  end
  #--------------------------------------------------------------------------
  # ● 获取敌人
  #--------------------------------------------------------------------------
  def enemies
    return @enemies
  end
  #--------------------------------------------------------------------------
  # ● 设置
  #     troop_id : 敌人 ID
  #--------------------------------------------------------------------------
  def setup(troop_id)
    # 由敌人序列的设置来确定队伍的设置
    @enemies = []
    troop = $data_troops[troop_id]
    for i in 0...troop.members.size
      enemy = $data_enemies[troop.members[i].enemy_id]
      if enemy != nil
        @enemies.push(Game_Enemy.new(troop_id, i))
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 对像敌人的随机确定
  #     hp0 : 限制 HP 0 的敌人
  #--------------------------------------------------------------------------
  def random_target_enemy(hp0 = false)
    # 初始化轮流
    roulette = []
    # 循环
    for enemy in @enemies
      # 条件符合的情况下
      if (not hp0 and enemy.exist?) or (hp0 and enemy.hp0?)
        # 添加敌人到轮流
        roulette.push(enemy)
      end
    end
    # 轮流尺寸为 0 的情况下
    if roulette.size == 0
      return nil
    end
    # 转轮盘赌，决定敌人
    return roulette[rand(roulette.size)]
  end
  #--------------------------------------------------------------------------
  # ● 对像敌人的随机确定 (HP 0)
  #--------------------------------------------------------------------------
  def random_target_enemy_hp0
    return random_target_enemy(true)
  end
  #--------------------------------------------------------------------------
  # ● 对像角色的顺序确定
  #     enemy_index : 敌人索引
  #--------------------------------------------------------------------------
  def smooth_target_enemy(enemy_index)
    # 获取敌人
    enemy = @enemies[enemy_index]
    # 敌人存在的场合
    if enemy != nil and enemy.exist?
      return enemy
    end
    # 循环
    for enemy in @enemies
      # 敌人存在的场合
      if enemy.exist?
        return enemy
      end
    end
  end
end
