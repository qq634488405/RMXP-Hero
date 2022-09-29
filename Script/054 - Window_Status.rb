#==============================================================================
# ■ Window_Status
#------------------------------------------------------------------------------
# 　显示状态画面、完全规格的状态窗口。
#==============================================================================

class Window_Status < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     actor : 角色
  #--------------------------------------------------------------------------
  def initialize
    @actor = $game_actor
    height = @actor.class_id == 8 ? 312 : 280
    super(122, 74, 396, height)
    @index = 0
    @status_data=[]
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 光标矩形
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @status_data=[]
    draw_head
    case @index
    when 0
      draw_status
    when 1
      draw_describe
    when 2
      draw_attr
    when 3
      draw_marry
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 描绘顶部
  #--------------------------------------------------------------------------
  def draw_head
    self.contents.draw_text(24,0,60,32,$data_system.look_menu[@index])
    bitmap = [RPG::Cache.picture("Rect_Unselected.png"),
              RPG::Cache.picture("Rect_Selected.png")]
    for i in 0..3
      j= @index==i ? 1 : 0
      self.contents.blt(80+24*i, 4,bitmap[j],Rect.new(0, 0, 20, 24),255)
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘状态
  #--------------------------------------------------------------------------
  def draw_status
    @status_data=$data_system.player_status[@index].deep_clone
    # 替换字符串
    @status_data[0].gsub!("food",@actor.food.to_s)
    @status_data[0].gsub!("max_f",@actor.max_food.to_s)
    @status_data[1].gsub!("water",@actor.water.to_s)
    @status_data[1].gsub!("max_w",@actor.max_water.to_s)
    @status_data[2].gsub!("hp",@actor.hp.to_s)
    @status_data[2].gsub!("max_h",@actor.maxhp.to_s)
    percent=@actor.maxhp*100/@actor.full_hp
    @status_data[2].gsub!("percent",percent.to_s)
    @status_data[3].gsub!("fp",@actor.fp.to_s)
    @status_data[3].gsub!("max_f",@actor.maxfp.to_s)
    @status_data[3].gsub!("f_plus",@actor.fp_plus.to_s)
    @status_data[4].gsub!("mp",@actor.mp.to_s)
    @status_data[4].gsub!("max_m",@actor.maxmp.to_s)
    @status_data[4].gsub!("m_plus",@actor.fp_plus.to_s)
    @status_data[5].gsub!("exp",@actor.exp.to_s)
    @status_data[6].gsub!("pot",@actor.pot.to_s)
    # 描绘字符串
    line = 0
    @status_data.each_index do |i|
      if not (@actor.class_id != 8 and i == 4)
        self.contents.draw_text(8,48+32*line,364,32,@status_data[i])
        line +=1
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘描述
  #--------------------------------------------------------------------------
  def draw_describe
    @status_data=$data_system.player_status[@index].deep_clone
    # 替换字符串
    @status_data[0].gsub!("school",@actor.class_name)
    @status_data[0].gsub!("name",@actor.name)
    @status_data[1].gsub!("age",@actor.age.to_s)
    @status_data[1].gsub!("gender",$data_text.gender[@actor.gender])
    if @actor.age<16 # 16岁前一脸稚气
      face = $data_system.young_face
    else
      face_arr = [$data_system.boy_face,$data_system.girl_face]
      face_id = @actor.gender
      if face_id == 2 # 玩家为？性
        # 获取游戏时间(小时)
        time = Graphics.frame_count/Graphics.frame_rate/3600
        # 如果已婚则固定否则每小时切换一次外貌描述
        face_id = @actor.marry > 0 ? @actor.marry % 2 : time % 2
      end
      face = face_arr[face_id][@actor.face_level]
    end
    @status_data[2].gsub!("face",face)
    @status_data[3].gsub!("lv",$data_system.levels[@actor.level])
    @status_data[4].gsub!("attack",$data_system.attack_lv[@actor.atk_level])
    # 描绘字符串
    @status_data.each_index do |i|
      self.contents.draw_text(8,48+32*i,364,32,@status_data[i])
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘属性
  #--------------------------------------------------------------------------
  def draw_attr
    @status_data=$data_system.player_status[@index].deep_clone
    # 替换字符串
    @status_data[0].gsub!("gold",@actor.gold.to_s)
    @status_data[1].gsub!("str",@actor.str.to_s)
    @status_data[1].gsub!("base_s",@actor.base_str.to_s)
    @status_data[2].gsub!("agi",@actor.agi.to_s)
    @status_data[2].gsub!("base_a",@actor.base_agi.to_s)
    @status_data[3].gsub!("int",@actor.int.to_s)
    @status_data[3].gsub!("base_i",@actor.base_int.to_s)
    @status_data[4].gsub!("bon",@actor.bon.to_s)
    @status_data[4].gsub!("base_b",@actor.base_bon.to_s)
    @status_data[5].gsub!("hit",@actor.hit.to_s)
    @status_data[6].gsub!("eva",@actor.eva.to_s)
    @status_data[7].gsub!("atk",@actor.atk.to_s)
    @status_data[8].gsub!("defence",@actor.pdef.to_s)
    self.contents.draw_text(8,48,364,32,@status_data[0])
    for i in 1..4
      self.contents.draw_text(8,48+32*i,174,32,@status_data[i])
      self.contents.draw_text(190,48+32*i,174,32,@status_data[i+4])
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘婚姻
  #--------------------------------------------------------------------------
  def draw_marry
    @status_data=$data_system.player_status[@index].deep_clone
    # 替换字符串
    if @actor.marry > 0
      marry_id = 1
      gender_id = @actor.gender == 2 ? @actor.marry % 2 : @actor.gender
    else # 未婚
      marry_id = 0
      # 获取游戏时间(小时)
      time = Graphics.frame_count/Graphics.frame_rate/3600
      # 如果为？性每小时切换一次婚姻描述
      gender_id = @actor.gender == 2 ? time % 2 : @actor.gender
    end
    @status_data[0].gsub!("marry",$data_system.marry_text[gender_id][marry_id])
    @status_data[0].gsub!("name",@actor.marry_name) if marry_id == 1
    self.contents.draw_text(8,48,364,32,@status_data[0])
  end
end
