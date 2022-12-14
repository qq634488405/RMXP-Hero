#--------------------------------------------------------------------------
# ● 启动窗口焦点检测（键盘记录）
#--------------------------------------------------------------------------
unless $_Start
  $_Start = Win32API.new("Lib/Background.dll","Start","V","L")
  $_Stop = Win32API.new("Lib/Background.dll","Stop","V","L")
  $_OnFocus = Win32API.new("Lib/Background.dll","OnFocus","V","L")
  begin
    $_Start.call
  rescue RuntimeError
    print("请安装VC运行库后再开始游戏。")
    $scene=nil
  end
  module Input
    InputUpdate = method :update
    InputTrigger = method :trigger?
    InputPress = method :press?
    InputRepeat = method :repeat?
    InputDir4 = method :dir4
    InputDir8 = method :dir8
    def self.update
      InputUpdate.call if $_OnFocus.call != 0
    end
    def self.trigger?(num)
      return $_OnFocus.call != 0 ? InputTrigger.call(num) : false
    end
    def self.press?(num)
      return $_OnFocus.call != 0 ? InputPress.call(num) : false
    end
    def self.repeat?(num)
      return $_OnFocus.call != 0 ? InputRepeat.call(num) : false
    end
    def self.dir4
      return $_OnFocus.call != 0 ? InputDir4.call : 0    
    end
    def self.dir8
      return $_OnFocus.call != 0 ? InputDir8.call : 0    
    end
  end
end
#--------------------------------------------------------------------------
# ● 定义深拷贝
#--------------------------------------------------------------------------
class Object
  def deep_clone
    Marshal::load(Marshal.dump(self))
  end
end
#--------------------------------------------------------------------------
# ● 定义Array额外方法
#--------------------------------------------------------------------------
class String
  #--------------------------------------------------------------------------
  # ● 获取字符串长度（半角字符记为1长度）
  #--------------------------------------------------------------------------
  def new_size
    n = 0
    # 根据字节计算字符数量，避免出现小数，乘3，最终再除以3
    self.each_byte do |i|
      # 半角符号占1字节
      if i < 128
        n += 3 
      else # 中文字符占3字节，每个字节+2
        n += 2
      end
    end
    return n/3
  end
end
#--------------------------------------------------------------------------
# ● 定义Array额外方法
#--------------------------------------------------------------------------
class Array
  #--------------------------------------------------------------------------
  # ● 获取数组元素最大长度(数组元素为字符串)
  #--------------------------------------------------------------------------
  def max_length
    max = 0
    self.each do |i|
      next if not i.is_a?(String)
      max = i.new_size if i.new_size > max
    end
    return max
  end
  #--------------------------------------------------------------------------
  # ● 字符串用空格填充至最大长度
  #--------------------------------------------------------------------------
  def fill_space_to_max
    max = self.max_length
    self.each_index do |i|
      # 跳过非字符串
      next if not self[i].is_a?(String)
      t_size = self[i].new_size
      self[i] = self[i] + " "*(max - t_size)
    end
  end
end
#--------------------------------------------------------------------------
# ● 消耗食物饮水
#--------------------------------------------------------------------------
def digesting
  return if $game_actor == nil
  actor = $game_actor
  # 判断年龄增长
  actor.play_time += 15
  # 12小时为1岁
  if actor.play_time >= 43200
    actor.age += 1
    actor.play_time -= 43200
  end
  # 消耗食物饮水的情况
  if $eat_flag
    # 食物饮水均大于0则生命内力法力自动恢复
    if actor.food > 0 and actor.water > 0
      if actor.hp < actor.maxhp
        # HP+根骨/2+内力上限/16
        actor.hp += actor.bon / 2 + actor.maxfp / 16
        actor.hp = [actor.hp,actor.maxhp].min
      else
        # 恢复伤势
        actor.maxhp += 1 if actor.maxhp < actor.full_hp
      end
      # 恢复内力
      if actor.fp < actor.maxfp
        actor.fp += actor.fp_kf_lv
        actor.fp = [actor.fp,actor.maxfp].min
      end
      # 恢复法力
      if actor.mp < actor.maxmp
        actor.mp += actor.mp_kf_lv
        actor.mp = [actor.mp,actor.maxmp].min
      end
    end
    # 食物饮水减少
    actor.food = [actor.food-1,0].max
    actor.water = [actor.water-1,0].max
  end
end