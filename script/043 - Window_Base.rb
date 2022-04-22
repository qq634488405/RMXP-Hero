#==============================================================================
# ■ Window_Base
#------------------------------------------------------------------------------
# 　游戏中全部窗口的超级类。
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     x      : 窗口的 X 坐标
  #     y      : 窗口的 Y 坐标
  #     width  : 窗口的宽
  #     height : 窗口的宽
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super()
    @windowskin_name = $game_system.windowskin_name
    self.windowskin = RPG::Cache.windowskin(@windowskin_name)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.z = 100
    self.contents = Bitmap.new(width - 32, height - 32)
    self.contents.font.color = normal_color
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    # 如果窗口的内容已经被设置就被释放
    if self.contents != nil
      self.contents.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 获取文字色
  #     n : 文字色编号 (0～7)
  #--------------------------------------------------------------------------
  def text_color(n)
    case n
    when 0
      return Color.new(0, 0, 0, 255)
    when 1
      return Color.new(128, 128, 255, 255)
    when 2
      return Color.new(255, 128, 128, 255)
    when 3
      return Color.new(128, 255, 128, 255)
    when 4
      return Color.new(128, 255, 255, 255)
    when 5
      return Color.new(255, 128, 255, 255)
    when 6
      return Color.new(255, 255, 128, 255)
    when 7
      return Color.new(192, 192, 192, 255)
    else
      normal_color
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取普通文字色
  #--------------------------------------------------------------------------
  def normal_color
    return Color.new(0, 0, 0, 255)
  end
  #--------------------------------------------------------------------------
  # ● 获取背景色
  #--------------------------------------------------------------------------
  def back_color
    return Color.new(144, 176, 87, 255)
  end
  #--------------------------------------------------------------------------
  # ● 获取无效文字色
  #--------------------------------------------------------------------------
  def disabled_color
    return Color.new(255, 255, 255, 128)
  end
  #--------------------------------------------------------------------------
  # ● 获取系统文字色
  #--------------------------------------------------------------------------
  def system_color
    return Color.new(192, 224, 255, 255)
  end
  #--------------------------------------------------------------------------
  # ● 获取危机文字色
  #--------------------------------------------------------------------------
  def crisis_color
    return Color.new(255, 255, 64, 255)
  end
  #--------------------------------------------------------------------------
  # ● 获取战斗不能文字色
  #--------------------------------------------------------------------------
  def knockout_color
    return Color.new(255, 64, 0)
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
    # 如果窗口的外观被变更了、再设置
    if $game_system.windowskin_name != @windowskin_name
      @windowskin_name = $game_system.windowskin_name
      self.windowskin = RPG::Cache.windowskin(@windowskin_name)
    end
  end
  #--------------------------------------------------------------------------
  # ● 图形的描绘
  #     actor : 角色
  #     x     : 描画目标 X 坐标
  #     y     : 描画目标 Y 坐标
  #--------------------------------------------------------------------------
  def draw_actor_graphic(actor, x, y)
    bitmap = RPG::Cache.character(actor.character_name, actor.character_hue)
    cw = bitmap.width / 4
    ch = bitmap.height / 4
    src_rect = Rect.new(0, 0, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
  #--------------------------------------------------------------------------
  # ● 名称的描绘
  #     actor : 角色
  #     x     : 描画目标 X 坐标
  #     y     : 描画目标 Y 坐标
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, x, y)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, 120, 32, actor.name)
  end
  #--------------------------------------------------------------------------
  # ● 职业的描绘
  #     actor : 角色
  #     x     : 描画目标 X 坐标
  #     y     : 描画目标 Y 坐标
  #--------------------------------------------------------------------------
  def draw_actor_class(actor, x, y)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, 236, 32, actor.class_name)
  end
  #--------------------------------------------------------------------------
  # ● 等级的描绘
  #     actor : 角色
  #     x     : 描画目标 X 坐标
  #     y     : 描画目标 Y 坐标
  #--------------------------------------------------------------------------
  def draw_actor_level(actor, x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 32, 32, "Lv")
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 32, y, 24, 32, actor.level.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # ● 生成描绘用的状态字符串
  #     actor       : 角色
  #     width       : 描画目标的宽度
  #     need_normal : [正常] 是否为必须 (true / false)
  #--------------------------------------------------------------------------
  def make_battler_state_text(battler, width, need_normal)
    # 获取括号的宽
    brackets_width = self.contents.text_size("[]").width
    # 生成状态名字符串
    text = ""
    for i in battler.states
      if $data_states[i].rating >= 1
        if text == ""
          text = $data_states[i].name
        else
          new_text = text + "/" + $data_states[i].name
          text_width = self.contents.text_size(new_text).width
          if text_width > width - brackets_width
            break
          end
          text = new_text
        end
      end
    end
    # 状态名空的字符串是 "[正常]" 的情况下
    if text == ""
      if need_normal
        text = "[正常]"
      end
    else
      # 加上括号
      text = "[" + text + "]"
    end
    # 返回完成后的文字类
    return text
  end
  #--------------------------------------------------------------------------
  # ● 描绘状态
  #     actor : 角色
  #     x     : 描画目标 X 坐标
  #     y     : 描画目标 Y 坐标
  #     width : 描画目标的宽
  #--------------------------------------------------------------------------
  def draw_actor_state(actor, x, y, width = 120)
    text = make_battler_state_text(actor, width, true)
    self.contents.font.color = actor.hp == 0 ? knockout_color : normal_color
    self.contents.draw_text(x, y, width, 32, text)
  end
  #--------------------------------------------------------------------------
  # ● 描绘 EXP
  #     actor : 角色
  #     x     : 描画目标 X 坐标
  #     y     : 描画目标 Y 坐标
  #--------------------------------------------------------------------------
  def draw_actor_exp(actor, x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 24, 32, "E")
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 24, y, 84, 32, actor.exp_s, 2)
    self.contents.draw_text(x + 108, y, 12, 32, "/", 1)
    self.contents.draw_text(x + 120, y, 84, 32, actor.next_exp_s)
  end
  #--------------------------------------------------------------------------
  # ● 描绘 HP
  #     actor : 角色
  #     x     : 描画目标 X 坐标
  #     y     : 描画目标 Y 坐标
  #     width : 描画目标的宽
  #--------------------------------------------------------------------------
  def draw_actor_hp(actor, x, y, width = 144)
    # 描绘字符串 "HP"
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 32, 32, $data_system.words.hp)
    # 计算描绘 MaxHP 所需的空间 
    if width - 32 >= 108
      hp_x = x + width - 108
      flag = true
    elsif width - 32 >= 48
      hp_x = x + width - 48
      flag = false
    end
    # 描绘 HP
    self.contents.font.color = actor.hp == 0 ? knockout_color :
      actor.hp <= actor.maxhp / 4 ? crisis_color : normal_color
    self.contents.draw_text(hp_x, y, 48, 32, actor.hp.to_s, 2)
    # 描绘 MaxHP
    if flag
      self.contents.font.color = normal_color
      self.contents.draw_text(hp_x + 48, y, 12, 32, "/", 1)
      self.contents.draw_text(hp_x + 60, y, 48, 32, actor.maxhp.to_s)
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘 SP
  #     actor : 角色
  #     x     : 描画目标 X 坐标
  #     y     : 描画目标 Y 坐标
  #     width : 描画目标的宽
  #--------------------------------------------------------------------------
  def draw_actor_sp(actor, x, y, width = 144)
    # 描绘字符串 "SP" 
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 32, 32, $data_system.words.sp)
    # 计算描绘 MaxSP 所需的空间
    if width - 32 >= 108
      sp_x = x + width - 108
      flag = true
    elsif width - 32 >= 48
      sp_x = x + width - 48
      flag = false
    end
    # 描绘 SP
    self.contents.font.color = actor.sp == 0 ? knockout_color :
      actor.sp <= actor.maxsp / 4 ? crisis_color : normal_color
    self.contents.draw_text(sp_x, y, 48, 32, actor.sp.to_s, 2)
    # 描绘 MaxSP
    if flag
      self.contents.font.color = normal_color
      self.contents.draw_text(sp_x + 48, y, 12, 32, "/", 1)
      self.contents.draw_text(sp_x + 60, y, 48, 32, actor.maxsp.to_s)
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘能力值
  #     actor : 角色
  #     x     : 描画目标 X 坐标
  #     y     : 描画目标 Y 坐标
  #     type  : 能力值种类 (0～6)
  #--------------------------------------------------------------------------
  def draw_actor_parameter(actor, x, y, type)
    case type
    when 0
      parameter_name = $data_system.words.atk
      parameter_value = actor.atk
    when 1
      parameter_name = $data_system.words.pdef
      parameter_value = actor.pdef
    when 2
      parameter_name = $data_system.words.mdef
      parameter_value = actor.mdef
    when 3
      parameter_name = $data_system.words.str
      parameter_value = actor.str
    when 4
      parameter_name = $data_system.words.dex
      parameter_value = actor.dex
    when 5
      parameter_name = $data_system.words.agi
      parameter_value = actor.agi
    when 6
      parameter_name = $data_system.words.int
      parameter_value = actor.int
    end
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, 32, parameter_name)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 120, y, 36, 32, parameter_value.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # ● 描绘物品名
  #     item : 物品
  #     x    : 描画目标 X 坐标
  #     y    : 描画目标 Y 坐标
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y)
    if item == nil
      return
    end
    bitmap = RPG::Cache.icon(item.icon_name)
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24))
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 28, y, 212, 32, item.name)
  end
  #--------------------------------------------------------------------------
  # ● 自动换行文字描绘
  #--------------------------------------------------------------------------
  def auto_text(text,align=0,color=self.normal_color)
    self.contents.clear
    self.contents.font.color = color
    x = y = 0
    # 限制文字处理
    begin
      last_text = text.clone
      text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
    end until text == last_text
    text.gsub!(/\\[Nn]\[([0-9]+)\]/) do
      $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
    end
    # 为了方便、将 "\\\\" 变换为 "\000" 
    text.gsub!(/\\\\/) { "\000" }
    # "\\C" 变为 "\001" 、"\\G" 变为 "\002"
    text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
    text.gsub!(/\\[Gg]/) { "\002" }
    # c 获取 1 个字 (如果不能取得文字就循环)
    while ((c = text.slice!(/./m)) != nil)
      # \\ 的情况下
      if c == "\000"
        # 还原为本来的文字
        c = "\\"
      end
      # \C[n] 的情况下
      if c == "\001"
        # 更改文字色
        text.sub!(/\[([0-9]+)\]/, "")
        color = $1.to_i
        if color >= 0 and color <= 7
          self.contents.font.color = text_color(color)
        end
        # 下面的文字
        next
      end
      # 另起一行文字的情况下
      if c == "\n" # 换行符
        # y 加 1
        y += 1
        x = 0
        # 下面的文字
        next
      end
      # 文字至窗口末端
      if (x + 4 + self.contents.text_size(c).width) > self.contents.width
        y += 1
        x = 0
      end
      # 描绘文字
      self.contents.draw_text( x + 4, 32 * y, 40, 32, c)
      # x 为要描绘文字的加法运算
      x += self.contents.text_size(c).width
    end
  end
end
