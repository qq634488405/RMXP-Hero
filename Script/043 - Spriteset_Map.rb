#==============================================================================
# ■ Spriteset_Map
#------------------------------------------------------------------------------
# 　处理地图画面活动块和元件的类。本类在
# Scene_Map 类的内部使用。
#==============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    # 生成显示端口
    @viewport1 = Viewport.new(0, 0, 640, 480)
    @viewport2 = Viewport.new(0, 0, 640, 480)
    @viewport3 = Viewport.new(0, 0, 640, 480)
    @viewport2.z = 200
    @viewport3.z = 5000
    # 生成元件地图
    @tilemap = Tilemap.new(@viewport1)
    @tilemap.tileset = RPG::Cache.tileset($game_map.tileset_name)
    for i in 0..6
      autotile_name = $game_map.autotile_names[i]
      @tilemap.autotiles[i] = RPG::Cache.autotile(autotile_name)
    end
    @tilemap.map_data = $game_map.data
    @tilemap.priorities = $game_map.priorities
    # 生成远景平面
    @panorama = Plane.new(@viewport1)
    @panorama.z = -1000
    # 生成雾平面
    @fog = Plane.new(@viewport1)
    @fog.z = 3000
    # 生成角色活动块
    @character_sprites = []
    for i in $game_map.events.keys.sort
      sprite = Sprite_Character.new(@viewport1, $game_map.events[i])
      @character_sprites.push(sprite)
    end
    @character_sprites.push(Sprite_Character.new(@viewport1, $game_player))
    # 生成天气
    @weather = RPG::Weather.new(@viewport1)
    # 生成图片
    @picture_sprites = []
    for i in 1..50
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
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
    # 释放元件地图
    @tilemap.tileset.dispose
    for i in 0..6
      @tilemap.autotiles[i].dispose
    end
    @tilemap.dispose
    # 释放远景平面
    @panorama.dispose
    # 释放雾平面
    @fog.dispose
    # 释放角色活动块
    for sprite in @character_sprites
      sprite.dispose
    end
    # 释放天候
    @weather.dispose
    # 释放图片
    for sprite in @picture_sprites
      sprite.dispose
    end
    # 释放计时器块
    @timer_sprite.dispose
    # 释放显示端口
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 远景与现在的情况有差异发生的情况下
    if @panorama_name != $game_map.panorama_name or
       @panorama_hue != $game_map.panorama_hue
      @panorama_name = $game_map.panorama_name
      @panorama_hue = $game_map.panorama_hue
      if @panorama.bitmap != nil
        @panorama.bitmap.dispose
        @panorama.bitmap = nil
      end
      if @panorama_name != ""
        @panorama.bitmap = RPG::Cache.panorama(@panorama_name, @panorama_hue)
      end
      Graphics.frame_reset
    end
    # 雾与现在的情况有差异的情况下
    if @fog_name != $game_map.fog_name or @fog_hue != $game_map.fog_hue
      @fog_name = $game_map.fog_name
      @fog_hue = $game_map.fog_hue
      if @fog.bitmap != nil
        @fog.bitmap.dispose
        @fog.bitmap = nil
      end
      if @fog_name != ""
        @fog.bitmap = RPG::Cache.fog(@fog_name, @fog_hue)
      end
      Graphics.frame_reset
    end
    # 刷新元件地图
    @tilemap.ox = $game_map.display_x / 4
    @tilemap.oy = $game_map.display_y / 4
    @tilemap.update
    # 刷新远景平面
    @panorama.ox = $game_map.display_x / 8
    @panorama.oy = $game_map.display_y / 8
    # 刷新雾平面
    @fog.zoom_x = $game_map.fog_zoom / 100.0
    @fog.zoom_y = $game_map.fog_zoom / 100.0
    @fog.opacity = $game_map.fog_opacity
    @fog.blend_type = $game_map.fog_blend_type
    @fog.ox = $game_map.display_x / 4 + $game_map.fog_ox
    @fog.oy = $game_map.display_y / 4 + $game_map.fog_oy
    @fog.tone = $game_map.fog_tone
    # 刷新角色活动块
    for sprite in @character_sprites
      sprite.update
    end
    # 刷新天候图形
    @weather.type = $game_screen.weather_type
    @weather.max = $game_screen.weather_max
    @weather.ox = $game_map.display_x / 4
    @weather.oy = $game_map.display_y / 4
    @weather.update
    # 刷新图片
    for sprite in @picture_sprites
      sprite.update
    end
    # 刷新计时器块
    @timer_sprite.update
    # 设置画面的色调与震动位置
    @viewport1.tone = $game_screen.tone
    @viewport1.ox = $game_screen.shake
    # 设置画面的闪烁色
    @viewport3.color = $game_screen.flash_color
    # 刷新显示端口
    @viewport1.update
    @viewport3.update
  end
end
