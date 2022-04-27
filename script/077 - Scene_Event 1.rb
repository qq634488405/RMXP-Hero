#==============================================================================
# ■ Scene_Event (分割定义 1)
#------------------------------------------------------------------------------
# 　处理各类地图事件的类。
#==============================================================================

class Scene_Event
  #--------------------------------------------------------------------------
  # ● 初始化
  #     type : 事件类型
  #           0--NPC事件，id--NPC ID
  #           1--发现物品，id--物品ID，number--数量
  #           2--发现武器，id--武器ID，number--数量
  #           3--发现防具，id--防具ID，number--数量
  #           4--钓鱼
  #           5--喝水
  #           6--游戏厅
  #           7--义工，id--义工ID
  #           8--BOSS对战，id--BOSS ID
  #           9--告示牌
  #           10--上吊
  #           11--喝酒
  #           12--联机
  #--------------------------------------------------------------------------
  def initialize(type,id=0,number=1)
    $eat_flag = true
    @type,@id,@number = type,id,number
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    @actor = $game_actor
    @screen = Spriteset_Map.new
    # 生成对话窗口
    @talk_window = Window_Help.new(480,160)
    @talk_window.visible=false
    @talk_window.x=80
    @talk_window.y=304
    # 生成地图名活动块
    @map_name = Sprite_Text.new
    @map_name.set_up(0,0,$game_map.map_name)
    # 执行过度
    Graphics.transition
    # 事件处理并生成选项窗口
    case @type
    when 0 # NPC事件
      npc_event
      @phase = 4
    when 1,2,3 # 发现物品
      get_item
      @phase = 1
    when 4 # 钓鱼
      fish
    when 5 # 喝水
      drink_water
      @phase = 1
    when 6 # 游戏厅
      @confirm_window=Window_Command.new(480,$data_system.game_choice,3,3)
      @confirm_window.y=416
      game_hall
    when 7 # 义工任务
      free_work
    when 8 # BOSS战斗
      @confirm_window=Window_Command.new(480,$data_system.boss3_choice,1,3)
      @confirm_window.y=384
      boss_fight
    when 9 # 通缉告示牌
      arrest_board
      @phase = 1
    when 10 # 自杀
      suicide
    when 11 # 喝酒
      drink_wine
      @phase = 1
    when 12 # 联机对战
      @confirm_window=Window_Command.new(320,$data_system.net_battle_choice,1,2)
      @confirm_window.y=304
      net_battle
    end
    if @confirm_window == nil
      @confirm_window=Window_Command.new(240,$data_system.confirm_choice,2,3)
      @confirm_window.y=416
    end
    @confirm_window.z=800
    @confirm_window.x=200
    @confirm_window.visible=false
    @confirm_window.active=false
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果画面切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @screen.dispose
    @map_name.dispose if @map_name != nil
    @talk_window.dispose
    @confirm_window.dispose
    @confirm_game.dispose if @confirm_game != nil
    dispose_npc if @type == 0 or @type == 8
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新窗口
    @talk_window.update
    @confirm_window.update
    # 根据不同阶段进行刷新
    case @phase
    when 1 # 显示文本按任意键结束
      update_text
    when 2 # 刷新游戏厅选项
      update_hall
    when 3 # 刷新钓鱼
      update_fish
    when 4 # 刷新NPC事件
      update_npc
    when 5 # 刷新BOSS事件
      update_boss
    when 6
      update_net
    when 7 # 连续显示文本
      update_text_gp
    when 8
      update_choose
    when 9 # 自杀
      update_kill_self
    end
    # 刷新活动块
    @screen.update
    @map_name.update
  end
  #--------------------------------------------------------------------------
  # ● 显示文本
  #--------------------------------------------------------------------------
  def show_text(text)
    @talk_window.auto_text(text.dup)
    @talk_window.visible=true
  end
  #--------------------------------------------------------------------------
  # ● NPC事件
  #--------------------------------------------------------------------------
  def npc_event
    @npc = Game_Enemy.new(@id)
    @menu = @npc.type
    # 商人
    @menu=1 if @npc.type==-1
    # 门派师父
    @menu=2 if @npc.type>0
    # 师父或独行大侠或顾炎武
    @menu=3 if (@menu==2 and @actor.teacher_id == @id) or @id==7 or @id==31
    @npc_menu=Window_Command.new(104,$data_system.menu_type[@menu],1,2,2)
    h = $data_system.menu_type[@menu].size * 32 + 24
    # 根据玩家朝向位置设置菜单偏移
    case $game_player.direction
    when 2 # 向下
      x_offset,y_offset=32,32-h/2
    when 4 # 向左
      x_offset,y_offset=-136,-h/2
    when 6 # 向右
      x_offset,y_offset=64,-h/2
    when 8 # 向上
      x_offset,y_offset=32,-32-h/2
    end
    x=[[$game_player.screen_x+x_offset,376].min,0].max
    y=[[$game_player.screen_y+y_offset,512].min,24].max
    @npc_menu.x,@npc_menu.y=x,y
    @npc_name=Sprite_Text.new
    @npc_name.set_up(x,y-24,@npc.name)
    @npc_name.update
    @npc_status=Window_Base.new(64,80,512,320)
    @npc_status.visible=false
    @npc_step=0
  end
  #--------------------------------------------------------------------------
  # ● 获得物品
  #--------------------------------------------------------------------------
  def get_item
    text=$data_text.find_item_text.dup
    case @type
    when 1 # 物品
      name=$data_items[@id].name
    when 2
      name=$data_weapons[@id].name
    when 2
      name=$data_armors[@id].name
    end
    text.gsub!("name",name)
    # 可以获得物品的情况
    if @actor.can_get_item?(@type,@id,@number)
      @actor.gain_item(@type,@id,@number)
      # 播放奖励音效
      $game_system.se_play($data_system.actor_collapse_se)
      show_text(text)
    end
  end
  #--------------------------------------------------------------------------
  # ● 钓鱼
  #--------------------------------------------------------------------------
  def fish
    # 装备有钓竿时
    if @actor.armor7_id !=0
      # 当前生命>40可钓鱼
      if @actor.hp>40
        show_text($data_text.start_fish)
        @actor.hp -= 40
        @phase=3
        # 随机生成钓鱼结果
        if rand(100)<50
          @fish_step=1
        else
          @fish_step=2
        end
      else # 体力不足
        show_text($data_text.fish_no_hp)
        @phase=1
      end
    else # 没有钓竿
      show_text($data_text.fish_no_item[0])
      @phase=1
    end
  end
  #--------------------------------------------------------------------------
  # ● 喝水
  #--------------------------------------------------------------------------
  def drink_water
    # 饮水满的情况
    if @actor.water>=@actor.max_water
      text=$data_text.not_drink_text
    else
      # 饮水 +20
      @actor.water+=20
      text=$data_text.drink_water_text
    end
    show_text(text)
  end
  #--------------------------------------------------------------------------
  # ● 游戏厅
  #--------------------------------------------------------------------------
  def game_hall
    show_text($data_text.game_hall_text)
    @confirm_game=Window_Command.new(240,$data_system.confirm_choice,2,3)
    @confirm_game.y=416
    @confirm_game.x=200
    @confirm_game.z=800
    @confirm_game.active=true
    @confirm_game.visible=true
    @phase = 2
    @game_step = 1
  end
  #--------------------------------------------------------------------------
  # ● 义工任务
  #--------------------------------------------------------------------------
  def free_work
    # ID不匹配则返回
    if $game_task.free_work != @id
      $scene=Scene_Map.new
      return
    end
    # 生命值足够的情况下
    if $game_task.check_work_hp
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 获取描述
      text=$data_text.work_text[@id-1].deep_clone
      text.push($data_text.finish_work_text.dup)
      for i in 0..4
        # 显示描述
        show_text(text[i])
        for j in 0..40
          # 刷新画面
          Graphics.update
          @map_name.update
        end
      end
      talk = $game_task.give_reward(20,10,50)
      show_text(talk)
      # 播放奖励音效
      $game_system.se_play($data_system.actor_collapse_se)
      $game_task.free_work=0
      @phase=1
    else
      # 显示劳累文本
      show_text($data_text.work_tired_text)
      @phase=1
    end
  end
  #--------------------------------------------------------------------------
  # ● BOSS战斗
  #--------------------------------------------------------------------------
  def boss_fight
    # 道德≥160，东方求败
    if @actor.morals >= 160
      @boss_id = 1
    # 道德<100且道德和尚被杀，道德和尚
    elsif @actor.morals < 100 and @actor.kill_list.include?(125)
      @boss_id = 2
    else # 我是谁
      @boss_id = 0
    end
    # 获取BOSS数据
    @npc = Game_Enemy.new(@boss_id + 195)
    @text_gp = $data_text.boss_text[@boss_id].deep_clone
    @gp_id = 0
    @end_text_gp = false
    @npc_name=Sprite_Text.new
    @npc_name.set_up(80,280,@npc.name)
    @npc_name.update
    @npc_name.visible = false
    @boss_select = false
    @phase = 5
  end
  #--------------------------------------------------------------------------
  # ● 通缉告示牌
  #--------------------------------------------------------------------------
  def arrest_board
    if @actor.morals < 128
      name = @actor.name 
      talk = $data_text.wanted_text.dup
    else
      # 已有恶人任务
      if $game_task.wanted_place > 0
        name = $game_task.wanted_name
        talk = $data_text.wanted_text.dup
      else
        name = ""
        talk = $data_text.no_wanted_text.dup
      end
    end
    talk.gsub!("name",name)
    show_text(talk)
  end
  #--------------------------------------------------------------------------
  # ● 自杀
  #--------------------------------------------------------------------------
  def suicide
    show_text($data_text.suicide_text)
    # 有麻绳
    if @actor.item_number(2,5) > 0
      @phase,@suicide_step = 9,1
    else
      @phase = 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 喝酒
  #--------------------------------------------------------------------------
  def drink_wine
    # 没有女儿红则返回
    if @actor.item_number(1,16)==0
      $scene=Scene_Map.new
      return
    end
    # 失去一个女儿红
    @actor.lose_item([1,16])
    # 时间+3小时
    @actor.time+=10800
    show_text($data_text.drink_wine_text)
    # 闪烁
    $game_screen.start_flash(Color.new(144,176,87,255),50)
  end
  #--------------------------------------------------------------------------
  # ● 联机对战
  #--------------------------------------------------------------------------
  def net_battle
  end
end