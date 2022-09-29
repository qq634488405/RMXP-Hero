#==============================================================================
# ■ Sprite_Character
#------------------------------------------------------------------------------
# 　角色显示用脚本。监视 Game_Character 类的实例、
# 自动变化脚本状态。
#==============================================================================

class Sprite_Character < RPG::Sprite
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor :character                # 角色
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     viewport  : 查看端口
  #     character : 角色 (Game_Character)
  #--------------------------------------------------------------------------
  def initialize(viewport, character = nil)
    super(viewport)
    @character = character
    update
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    # 元件 ID、文件名、色相与现在的情况存在差异的情况下
    if @tile_id != @character.tile_id or
       @character_name != @character.character_name or
       @character_hue != @character.character_hue
      # 记忆元件 ID 与文件名、色相
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_hue = @character.character_hue
      # 元件 ID 为有效值的情况下
      if @tile_id >= 384
        self.bitmap = RPG::Cache.tile($game_map.tileset_name,
          @tile_id, @character.character_hue)
        self.src_rect.set(0, 0, 32, 32)
        self.ox = 16
        self.oy = 32
      # 元件 ID 为无效值的情况下
      else
        self.bitmap = RPG::Cache.character(@character.character_name,
          @character.character_hue)
        @cw = bitmap.width / 4
        @ch = bitmap.height / 4
        self.ox = @cw / 2
        self.oy = @ch
      end
    end
    # 设置可视状态
    self.visible = (not @character.transparent)
    # 图形是角色的情况下
    if @tile_id == 0
      # 设置传送目标的矩形
      sx = @character.pattern * @cw
      sy = (@character.direction - 2) / 2 * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
    # 设置脚本的坐标
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z(@ch)
    # 设置不透明度、合成方式、茂密
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    # 动画
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
  end
end
