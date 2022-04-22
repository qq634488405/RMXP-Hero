#==============================================================================
# ■ Spriteset_Battle
#------------------------------------------------------------------------------
# 　处理战斗画面的活动块的类。本类在 Scene_Battle 类
# 的内部使用。
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :viewport1                # 敌人方的显示端口
  attr_reader   :viewport2                # 角色方的显示端口
  #--------------------------------------------------------------------------
  # ● 初始化变量
  #--------------------------------------------------------------------------
  def initialize(enemy)
    # 生成显示端口
    @viewport1 = Viewport.new(0, 0, 640, 480)
    @viewport2 = Viewport.new(0, 0, 640, 480)
    @viewport3 = Viewport.new(0, 0, 640, 480)
    @viewport4 = Viewport.new(0, 0, 640, 480)
    @viewport2.z = 101
    @viewport3.z = 200
    @viewport4.z = 5000
    # 生成战斗背景活动块
    @battleback_sprite = Sprite.new(@viewport1)
    # 生成敌人活动块
    @enemy_sprites = []
    @enemy_sprites.push(Sprite_Battler.new(@viewport1, enemy))
    # 生成敌人活动块
    @actor_sprites = []
    @actor_sprites.push(Sprite_Battler.new(@viewport2))
    # 生成天候
    @weather = RPG::Weather.new(@viewport1)
    # 生成图片活动块
    @picture_sprites = []
    for i in 51..100
      @picture_sprites.push(Sprite_Picture.new(@viewport3,
        $game_screen.pictures[i]))
    end
    # 生成计时器块
    @timer_sprite = Sprite_Timer.new
    # 刷新画面
    update
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    # 如果战斗背景位图存在的情况下就释放
    if @battleback_sprite.bitmap != nil
      @battleback_sprite.bitmap.dispose
    end
    # 释放战斗背景活动块
    @battleback_sprite.dispose
    # 释放敌人活动块、角色活动块
    for sprite in @enemy_sprites + @actor_sprites
      sprite.dispose
    end
    # 释放天候
    @weather.dispose
    # 释放图片活动块
    for sprite in @picture_sprites
      sprite.dispose
    end
    # 释放计时器活动块
    @timer_sprite.dispose
    # 释放显示端口
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
    @viewport4.dispose
  end
  #--------------------------------------------------------------------------
  # ● 显示效果中判定
  #--------------------------------------------------------------------------
  def effect?
    # 如果是在显示效果中的话就返回 true
    for sprite in @enemy_sprites + @actor_sprites
      return true if sprite.effect?
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新角色的活动块 (对应角色的替换)
    @actor_sprites[0].battler = $game_actor
    # 战斗背景的文件名与现在情况有差异的情况下
    if @battleback_name != $game_temp.battleback_name
      @battleback_name = $game_temp.battleback_name
      if @battleback_sprite.bitmap != nil
        @battleback_sprite.bitmap.dispose
      end
      @battleback_sprite.bitmap = RPG::Cache.battleback(@battleback_name)
      @battleback_sprite.src_rect.set(0, 0, 640, 480)
    end
    # 刷新战斗者的活动块
    for sprite in @enemy_sprites + @actor_sprites
      sprite.update
    end
    # 刷新天气图形
    @weather.type = $game_screen.weather_type
    @weather.max = $game_screen.weather_max
    @weather.update
    # 刷新图片活动块
    for sprite in @picture_sprites
      sprite.update
    end
    # 刷新计时器活动块
    @timer_sprite.update
    # 设置画面的色调与震动位置
    @viewport1.tone = $game_screen.tone
    @viewport1.ox = $game_screen.shake
    # 设置画面的闪烁色
    @viewport4.color = $game_screen.flash_color
    # 刷新显示端口
    @viewport1.update
    @viewport2.update
    @viewport4.update
  end
end
