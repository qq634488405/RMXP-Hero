#==============================================================================
# ■ Sprite_Picture
#------------------------------------------------------------------------------
# 　显示图片用的活动块。Game_Picture 类的实例监视、
# 活动块状态的自动变化。
#==============================================================================

class Sprite_Picture < Sprite
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     viewport : 显示端口
  #     picture  : 图片 (Game_Picture)
  #--------------------------------------------------------------------------
  def initialize(viewport, picture)
    super(viewport)
    @picture = picture
    update
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
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    # 图片的文件名与当前的情况有差异的情况下
    if @picture_name != @picture.name
      # 将文件名记忆到实例变量
      @picture_name = @picture.name
      # 文件名不为空的情况下
      if @picture_name != ""
        # 获取图片图形
        self.bitmap = RPG::Cache.picture(@picture_name)
      end
    end
    # 文件名是空的情况下
    if @picture_name == ""
      # 将活动块设置为不可见
      self.visible = false
      return
    end
    # 将活动块设置为可见
    self.visible = true
    # 设置传送原点
    if @picture.origin == 0
      self.ox = 0
      self.oy = 0
    else
      self.ox = self.bitmap.width / 2
      self.oy = self.bitmap.height / 2
    end
    # 设置活动块的坐标
    self.x = @picture.x
    self.y = @picture.y
    self.z = @picture.number
    # 设置放大率、不透明度、合成方式
    self.zoom_x = @picture.zoom_x / 100.0
    self.zoom_y = @picture.zoom_y / 100.0
    self.opacity = @picture.opacity
    self.blend_type = @picture.blend_type
    # 设置旋转角度、色调
    self.angle = @picture.angle
    self.tone = @picture.tone
  end
end
