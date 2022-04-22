#==============================================================================
# ■ Sprite_Battler
#------------------------------------------------------------------------------
# 　战斗显示用活动块。Game_Battler 类的实例监视、
# 活动块的状态的监视。
#==============================================================================

class Sprite_Battler < RPG::Sprite
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor :battler                  # 战斗者
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     viewport : 显示端口
  #     battler  : 战斗者 (Game_Battler)
  #--------------------------------------------------------------------------
  def initialize(viewport, battler = nil)
    super(viewport)
    @battler = battler
    @battler_visible = false
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    if self.bitmap != nil
      self.bitmap.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
    # 战斗者为 nil 的情况下
    if @battler == nil
      self.bitmap = nil
      loop_animation(nil)
      return
    end
    # 文件名和色相与当前情况有差异的情况下
    if @battler.battler_name != @battler_name or
       @battler.battler_hue != @battler_hue
      # 获取、设置位图
      @battler_name = @battler.battler_name
      @battler_hue = @battler.battler_hue
      self.bitmap = RPG::Cache.battler(@battler_name, @battler_hue)
      @width = bitmap.width
      @height = bitmap.height
      self.ox = @width / 2
      self.oy = @height
      # 如果是战斗不能或者是隐藏状态就把透明度设置成 0
      if @battler.dead? or @battler.hidden
        self.opacity = 255
      end
    end
    # 动画 ID 与当前的情况有差异的情况下
    if @battler.damage == nil and
       @battler.state_animation_id != @state_animation_id
      @state_animation_id = @battler.state_animation_id
      loop_animation($data_animations[@state_animation_id])
    end
    # 明灭
    if @battler.blink
      blink_on
    else
      blink_off
    end
    # 不可见的情况下
    unless @battler_visible
      # 出现
      if not @battler.hidden and not @battler.dead? and
         (@battler.damage == nil or @battler.damage_pop)
        appear
        @battler_visible = true
      end
    end
    # 可见的情况下
    if @battler_visible
      # 逃跑
      if @battler.hidden
        $game_system.se_play($data_system.escape_se)
        escape
        @battler_visible = false
      end
      # 白色闪烁
      if @battler.white_flash
        whiten
        @battler.white_flash = false
      end
      # 动画
      if @battler.animation_id != 0
        animation = $data_animations[@battler.animation_id]
        animation(animation, @battler.animation_hit)
        @battler.animation_id = 0
      end
      # 伤害
      if @battler.damage_pop
        damage(@battler.damage, @battler.critical)
        @battler.damage = nil
        @battler.critical = false
        @battler.damage_pop = false
      end
      # korapusu
      if @battler.damage == nil and @battler.dead?
        if @battler.is_a?(Game_Enemy)
          $game_system.se_play($data_system.enemy_collapse_se)
        else
          $game_system.se_play($data_system.actor_collapse_se)
        end
        collapse
        @battler_visible = false
      end
    end
    # 设置活动块的坐标
    self.x = @battler.screen_x
    self.y = @battler.screen_y
    self.z = @battler.screen_z
  end
end
