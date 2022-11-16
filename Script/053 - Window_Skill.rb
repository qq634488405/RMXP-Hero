#==============================================================================
# ■ Window_Skill
#------------------------------------------------------------------------------
# 　特技画面、战斗画面、显示可以使用的特技浏览的窗口。
#==============================================================================

class Window_Skill < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super(116, 74, 504, 322)
    @column_max = 1
    @kf_type = 0
    @width_txt = 472
    @actor = $game_actor
    # 战斗中的情况下调整窗口大小并移至中央
    if $game_temp.in_battle
      self.height,self.width = 256,320
      @width_text = self.width - 32
      self.x = (544 - self.width) / 2 + 96
      self.y = (480 - self.height) / 2
      self.z = 500
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 设置类别
  #--------------------------------------------------------------------------
  def set_kf_type(type)
    @kf_type = type
  end
  #--------------------------------------------------------------------------
  # ● 获取技能
  #--------------------------------------------------------------------------
  def skill
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # ● 获取技能对应技能列表序号
  #--------------------------------------------------------------------------
  def kf_list_index
    return @location[self.index]
  end
  #--------------------------------------------------------------------------
  # ● 物品类别判定
  #--------------------------------------------------------------------------
  def judge_kf(kf_data)
    id,lv = kf_data[0],kf_data[1]
    return false if lv == 0
    case @kf_type
    when 0 # 拳脚
      return ($data_kungfus[id].type == 2)
    when 1 # 兵刃
      return ([3,4,5,6,7].include?($data_kungfus[id].type))
    when 2 # 轻功
      return ($data_kungfus[id].type == 9)
    when 3 # 内功
      return ($data_kungfus[id].type == 1)
    when 4 # 招架
      return true if $data_kungfus[id].type == 10
      return true if id == @actor.skill_use[0] and id > 11
      return (id == @actor.skill_use[1] and id > 11)
    when 5 # 法术
      return ($data_kungfus[id].type == 8)
    when 6 # 知识
      return ($data_kungfus[id].type == 11)
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data,@location = [],[]
    # 技能列表不为0
    if @actor.skill_list.size > 0
      @actor.skill_list.each_index do |i|
        kf_data = @actor.skill_list[i]
        if judge_kf(kf_data)
          @data.push(kf_data)
          @location.push(i)
        end
      end
    end
    # 如果项目数不是 0 就生成位图、重新描绘全部项目
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
      self.contents.font.color = normal_color
      self.contents.clear
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘项目
  #     index : 项目编号
  #--------------------------------------------------------------------------
  def draw_item(index)
    skill = @data[index]
    id,lv,study,equip = skill[0],skill[1],skill[2],skill[3]
    x,y = 4,index * 32
    # 获取技能名称
    name = $data_kungfus[id].name
    rect = Rect.new(x, y, self.width / @column_max - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    # 设置图标
    bitmap = [RPG::Cache.picture("Rect_Unselected.png"),
              RPG::Cache.picture("Rect_Unselected_Equiped.png")]
    # 如果是招架
    if @kf_type == 4
      equip = @actor.skill_use[4] == id ? 1 : 0
    end
    self.contents.blt(x,y+4,bitmap[equip], Rect.new(0,0,20,24),255)
    self.contents.draw_text(x + 28, y, 212, 32, name, 0)
  end
  #--------------------------------------------------------------------------
  # ● 更新光标矩形
  #--------------------------------------------------------------------------
  def update_cursor_rect
    # 光标位置不满 0 的情况下
    if @index < 0
      self.cursor_rect.empty
      return
    end
    # 获取当前的行
    row = @index / @column_max
    # 当前行被显示开头行前面的情况下
    if row < self.top_row
      # 从当前行向开头行滚动
      self.top_row = row
    end
    # 当前行被显示末尾行之后的情况下
    if row > self.top_row + (self.page_row_max - 1)
      # 从当前行向末尾滚动
      self.top_row = row - (self.page_row_max - 1)
    end
    # 计算光标的宽
    cursor_width = @width_txt
    # 计算光标坐标
    x = @index % @column_max * cursor_width
    y = @index / @column_max * 32
    bitmap = [RPG::Cache.picture("Rect_Selected.png"),
              RPG::Cache.picture("Rect_Selected_Equiped.png")]
    if @kf_type == 4
      pic_id = @actor.skill_use[4] == self.skill[0] ? 1 : 0
    else
      pic_id = self.skill[3]
    end
    self.contents.blt(x+4,y+4,bitmap[pic_id],Rect.new(0,0,20,24),255)
  end
  #--------------------------------------------------------------------------
  # ● 刷新帮助文本
  #--------------------------------------------------------------------------
  def update_help
    if @data[self.index]!=nil
      kf_data = @data[self.index]
      level,study = kf_data[1],kf_data[2]
      lv = [level/5,49].min
      # 等级描述 等级/学习点数
      text = $data_system.levels[lv]+"  "+level.to_s+"/"+study.to_s
      @help_window.set_text(text)
    else
      @help_window.set_text("")
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
    refresh
    # 刷新光标位置
    update_cursor_rect
  end
end
