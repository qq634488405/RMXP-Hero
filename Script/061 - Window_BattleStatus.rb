#==============================================================================
# ■ Window_BattleStatus
#------------------------------------------------------------------------------
# 　显示战斗画面同伴状态的窗口。
#==============================================================================

class Window_BattleStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize(enemy)
    super(0, 0, 640, 278)
    @actor,@enemy = $game_actor,enemy
    self.opacity,self.z = 0,170
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.size = 16
    self.contents.font.color = normal_color
    draw_vs
    for i in 0..2
      draw_status(@actor,i)
      draw_status(@enemy,i)
    end
    draw_buff if $battle_info == 1
  end
  #--------------------------------------------------------------------------
  # ● 描绘状态
  #--------------------------------------------------------------------------
  def draw_vs
    # 设置图片
    bitmap = RPG::Cache.picture("VS.png")
    # 描绘VS图片
    self.contents.blt(275,107,bitmap,Rect.new(0,0,58,42),255)
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 描绘状态(HP FP MP)
  #--------------------------------------------------------------------------
  def draw_status(battler,type)
    # 设置图片
    bitmap = [RPG::Cache.picture("HP.png"),RPG::Cache.picture("FP.png"),
              RPG::Cache.picture("MP.png")]
    x = battler.screen_x - 79
    y,max = 174 + type * 18,78
    # 设置血条及上限条长度
    case type
    when 0 # 生命
      max = [78*battler.maxhp/battler.full_hp,78].min
      now = [78*battler.hp/battler.full_hp,78].min
      state = battler.hp.to_s+"/"+battler.maxhp.to_s
    when 1 # 内力
      # 无内力则返回
      return if battler.maxfp == 0
      now = [78*battler.fp/battler.maxfp,78].min
      state = battler.fp.to_s+"/"+battler.maxfp.to_s
    when 2 # 法力
      # 无法力则返回
      return if battler.maxmp == 0
      # 有法力无内力则将位置上提
      y -= 18 if battler.maxfp == 0
      now = [78*battler.mp/battler.maxmp,78].min
      state = battler.mp.to_s+"/"+battler.maxmp.to_s
    end
    # 描绘HP/FP/MP图片
    self.contents.blt(x,y,bitmap[type],Rect.new(0,0,24,16),255)
    # 描绘上限条
    self.contents.fill_rect(x+24,y+12,max,2,normal_color)
    # 描绘当前条
    self.contents.fill_rect(x+24,y+4,now,6,normal_color)
    # 仅玩家描绘数值
    if battler.is_a?(Game_Actor)
      # 描绘数值信息
      self.contents.draw_text(x+105,y-6,120,32,state)
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘状态(Buff & Debuff)
  #--------------------------------------------------------------------------
  def draw_buff
    battlers = [@actor,@enemy]
    text,y = "",0
    battlers.each_index do |i|
      b_type=[battlers[i].str_plus,battlers[i].dex_plus,battlers[i].int_plus,
              battlers[i].bon_plus,battlers[i].hit_plus,battlers[i].eva_plus,
              battlers[i].atk_plus,battlers[i].def_plus,]
      b_type.each_index do |j|
        # 临时属性不为0，则描述文本
        if b_type[j] != 0
          num_text = b_type[j].to_s
          num_text = "+" + num_text if b_type[j] > 0
          text = $data_system.attr_name[j] + num_text
          self.contents.draw_text(i*480,y,128,32,text)
          y += 32
        end
      end
    end
  end
end
