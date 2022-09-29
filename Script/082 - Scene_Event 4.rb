#==============================================================================
# ■ Scene_Event (分割定义 4)
#------------------------------------------------------------------------------
# 　处理各类地图事件的类。
#==============================================================================

class Scene_Event
  #--------------------------------------------------------------------------
  # ● 交谈
  #--------------------------------------------------------------------------
  def start_talk
    @npc_step = 1
    # 是否为拜访目标
    if $game_task.visit_id == @id
      show_text($data_text.i_know_text)
      # -1与村长回复去领赏
      $game_task.visit_id=-1
      @talk_step = 3
      return
    end
    case @id
    when 3 # 捕快
      talk = arrest_talk
    when 6,10,26 # 村长，中年妇人，平一指
      talk = task_talk
    when 14 # 石料管事
      talk = stone_talk1
    when 15 # 工地管事
      talk = stone_talk2
    when 25 # 老婆婆
      talk = work_talk
    when 31 # 顾炎武
      talk = reward_talk
    when 148 # 干匠
      talk = sword_talk
    when 171 # 月下老人
      talk = marry_talk
    end
    talk = common_talk if talk == nil
    return if talk == nil
    show_text(talk)
  end
  #--------------------------------------------------------------------------
  # ● 常规对话
  #--------------------------------------------------------------------------
  def common_talk
    # NPC没有特殊对话则读取常规对话
    if $data_text.sp_talk_text[@id] == nil
      talk = $data_text.normal_talk 
    else
      talk = $data_text.sp_talk_text[@id]
      # 如果为华岳且金钱超过50万
      if @id == 139 and @actor.gold >= 500000
        @actor.lose_gold(500000)
        @actor.donate_times += 1
        @phase,@text_gp = 7,[0,talk[0],0,$data_text.quest_talk[@id][0]]
        @end_text_gp,@gp_id = false,0
        return nil
      end
    end
    index = rand(talk.size)
    text = talk[index].dup
    text.gsub!("name",@npc.name)
    @talk_step=1
    # 如果为白瑞德，师父为白瑞德，雪山剑法超过150，带有王蛇胆
    flag = (@id == 111 and @actor.teacher_id == 111 and not @actor.xue6)
    if flag and @actor.get_kf_level(39)>=150 and @actor.item_number(1,30)>0
      @actor.lose_item(1,30)
      @actor.xue6 = true
      text = $data_text.quest_talk[@id][0]
    end
    return text
  end
  #--------------------------------------------------------------------------
  # ● 老婆婆对话
  #--------------------------------------------------------------------------
  def work_talk
    @talk_step = 3
    # 经验超过5000
    return $data_text.not_work_text.dup if @actor.exp>=5000
    # 已有未完成的任务
    return $data_text.work_undo_text.dup if $game_task.free_work>0
    # 生成新任务
    $game_task.give_work
    talk = $data_text.give_work_text.dup
    talk.gsub!("work",$data_text.all_work[$game_task.free_work-1])
    return talk
  end
  #--------------------------------------------------------------------------
  # ● 捕快对话
  #--------------------------------------------------------------------------
  def arrest_talk
    @talk_step = 3
    return $data_text.you_bad_text if @actor.morals<128
    # 计算当前游戏时间
    time = Graphics.frame_count/Graphics.frame_rate
    # 已有恶人的情况
    if $game_task.wanted_place>0
      # 任务时间少于20分钟
      if time-$game_task.wanted_time<1200
        talk = $data_text.bad_undo_text.dup
        talk.gsub!("name",$game_task.wanted_name)
        return talk
      else # 超过20分钟，则重置恶人
        $game_task.wanted_count -= 1
        return set_new_badman
      end
    else
      # 距离上次任务不足5分钟
      if time-$game_task.wanted_time<300
        return $data_text.no_bad_task
      else
        # 发布恶人任务
        return set_new_badman
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 石料管事对话
  #--------------------------------------------------------------------------
  def stone_talk1
    @talk_step = 3
    # 计算当前游戏时间
    time = Graphics.frame_count/Graphics.frame_rate
    # 根据石料任务状态赋予对话
    if $game_task.stone_start == true
      talk = $data_text.stone_undo_text
    elsif time-$game_task.stone_time < 180
      talk = $data_text.no_stone_task
    elsif @actor.exp<1000
      talk = $data_text.stone_less_exp
    elsif @actor.exp>=100000
      talk = $data_text.stone_more_exp
    elsif @actor.full_item_bag?
      talk = $data_text.stone_full_bag
    else # 获得石料，开始任务
      $game_task.set_stone
      talk = $data_text.give_stone_text
    end
    return talk
  end
  #--------------------------------------------------------------------------
  # ● 工地管事对话
  #--------------------------------------------------------------------------
  def stone_talk2
    @talk_step = 3
    # 判断任务状态
    if $game_task.stone_start == false
      talk = $data_text.no_stone_task2
    elsif @actor.item_number(1,29)==0
      talk = $data_text.lose_stone_text
    else # 完成石料任务
      show_text($data_text.finish_stone_text)
      for j in 0..40
        # 刷新画面
        Graphics.update
      end
      talk = $game_task.finish_stone
      # 播放奖励音效
      $game_system.se_play($data_system.actor_collapse_se)
    end    
    return talk
  end
  #--------------------------------------------------------------------------
  # ● 顾炎武对话
  #--------------------------------------------------------------------------
  def reward_talk
    @talk_step = 3
    # 已有待领赏任务
    if $game_task.finish_flag
      talk = $game_task.task_reward
    else # 没有完成任务
      talk = $data_text.gu_no_reward
    end
    return talk
  end
  #--------------------------------------------------------------------------
  # ● 村长，中年妇人，平一指对话
  #--------------------------------------------------------------------------
  def task_talk
    @talk_step = 3
    # 村长，坛任务未开始，经验超过80000，且背包未满
    if @id==6 and @actor.tan_id==0 and @actor.exp>=80000 and not @actor.full_item_bag?
      @actor.tan_id=1
      # 获得青龙坛地图
      @actor.gain_item(1,21)
      return $data_text.tan_start
    end
    # 平一指且玩家为好人
    return $data_text.no_kill_task if @id==26 and @actor.morals>=128
    # 已有任意待领赏任务
    return $data_text.has_reward_text if $game_task.finish_flag
    case @id
    when 6 # 村长
      return task_unfinish(1) if $game_task.visit_id > 0
      # 已完成拜访
      if $game_task.visit_id==-1
        # 重置任务并设置奖励
        $game_task.visit_id = 0
        $game_task.gu_reward = $game_task.visit_reward
        return task_finish(1)
      end
    when 10 # 中年妇人
      item_type = $game_task.find_type
      item_id = $game_task.find_id
      # 任务物品数量大于等于1，且存在任务
      if @actor.item_number(item_type,item_id)>=1 and $game_task.find_id>0
        @talk_step = 4
        talk = $data_text.woman_ask.dup
        talk.gsub!("item",$game_task.find_name)
        return talk
      end
      return task_unfinish(2) if $game_task.find_id>0
    when 26 # 平一指
      return task_unfinish(3) if $game_task.kill_id>0
      # 已完成击杀
      if $game_task.kill_id==-1
        # 重置任务并设置奖励
        $game_task.kill_id=0
        $game_task.gu_reward = $game_task.kill_reward
        return task_finish(3)
      end
    end
    set_new_task
  end
  #--------------------------------------------------------------------------
  # ● 村长，中年夫人，平一指任务未完成
  #--------------------------------------------------------------------------
  def task_unfinish(n)
    name=[$game_task.visit_name,$game_task.find_name,$game_task.kill_name]
    talk=$data_text.task_undo_text[n-1].dup
    talk.gsub!("name",name[n-1])
    return talk
  end
  #--------------------------------------------------------------------------
  # ● 村长，中年夫人，平一指任务完成
  #--------------------------------------------------------------------------
  def task_finish(n)
    $game_task.finish_flag=true
    # 如果完成任务时间超过20分钟则清空奖励
    time=[$game_task.visit_time,$game_task.find_time,$game_task.kill_time]
    new_time=Graphics.frame_count/Graphics.frame_rate
    $game_task.gu_reward=0 if new_time-time[n-1]>=1200
    return $data_text.finish_task_text
  end
  #--------------------------------------------------------------------------
  # ● 查看画面
  #--------------------------------------------------------------------------
  def look_status
    @npc_step = 2
    @npc_status.visible=true
    @npc_menu.visible=false
    status_data=$data_system.npc_status_text.deep_clone
    name=@npc.name
    age=[@npc.age/10,1].max
    status_data[0].gsub!("name",name)
    status_data[0].gsub!("age",age.to_s)
    status_data[1].gsub!("lv",$data_system.levels[@npc.level])
    status_data[2].gsub!("attack",$data_system.attack_lv[@npc.atk_level])
    item = " "
    # 物品列表不为空则生成物品名称
    if @npc.item_list.size>0
      @npc.item_list.each do |i|
        case i[0]
        when 1 # 物品，ID<0为隐藏物品
          item += $data_items[i[1]].name + " " if i[1]>0
        when 2 # 武器
          item += $data_weapons[i[1]].name + " " if i[1]>0
        when 3 # 防具
          item += $data_armors[i[1]].name + " " if i[1]>0
        end
      end
    end
    status_data[3].gsub!("item",item)
    status_data[4].gsub!("des1",@npc.des_text[0])
    status_data[5].gsub!("des2",@npc.des_text[1])
    status_data[6].gsub!("des3",@npc.des_text[2])
    status_data[7].gsub!("des4",@npc.des_text[3])
    status_data[8].gsub!("des5",@npc.des_text[4])
    @npc_status.contents.clear
    for i in 0..8
      @npc_status.contents.draw_text(0,i*32,480,32,status_data[i])
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成新恶人
  #--------------------------------------------------------------------------
  def set_new_badman
    $game_task.set_badman
    talk = $data_text.give_bad_text.dup
    talk.gsub!("name",$game_task.wanted_name)
    talk.gsub!("place",$data_mapinfos[$game_task.wanted_place].name)
    return talk
  end
  #--------------------------------------------------------------------------
  # ● 生成新三大任务
  #--------------------------------------------------------------------------
  def set_new_task
    case @id
    when 6
      type=1
    when 10
      type=2
    when 26
      type=3
    end
    name = $game_task.set_task(type)
    # NPC被杀光则返回相应对话
    return $data_text.no_npc_live if name == nil
    talk = $data_text.give_task_text[type-1].dup
    talk.gsub!("name",name)
    return talk
  end
  #--------------------------------------------------------------------------
  # ● 拜师
  #--------------------------------------------------------------------------
  def set_teacher
    # 获取拜师条件及对话
    need = $data_tasks.teacher_need[@id]
    result = $data_text.baishi_text[@id]
    talk_id,flag = 0,true
    need.each_index do |i|
      # 判断是否满足拜师
      suc_flag = false
      for j in 0..(need[i].size-1)
        next if j % 2 == 1 # 步长2
        suc_flag = (suc_flag or judge_teacher(need[i][j],need[i][j+1]))
      end
      flag = (flag and suc_flag)
      unless flag
        talk_id = i
        break
      end
    end
    talk_id = result.size - 1 if flag
    return [flag,result[talk_id]]
  end
  #--------------------------------------------------------------------------
  # ● 判断拜师条件
  #--------------------------------------------------------------------------
  def judge_teacher(type,num)
    case type
    when 0 # 无条件
      return true
    when 1..56 # 技能等级
      return (@actor.get_kf_level(type) >= num)
    when -1 # 性别
      return (@actor.gender == num)
    when -2 # 内力上限
      return (@actor.maxfp >= num)
    when -3 # 外貌
      return (@actor.face >= num)
    when -11..-4 # 先天/后天四维
      attr = [@actor.base_bon,@actor.base_int,@actor.base_agi,@actor.base_str,
              @actor.bon,@actor.int,@actor.agi,@actor.str]
      return num < 0 ? attr[type+11]<=num.abs : attr[type+11]>=num
    when -12 # 法力上限
      return (@actor.maxmp >= num)
    end
  end
  #--------------------------------------------------------------------------
  # ● 开始战斗
  #--------------------------------------------------------------------------
  def call_battle(id,type = 0)
    # 清除菜单调用标志
    $game_temp.menu_calling = false
    $game_temp.menu_beep = false
    # 记忆地图 BGM 、停止 BGM
    $game_temp.map_bgm = $game_system.playing_bgm
    $game_system.bgm_stop
    # 演奏战斗 BGM
    if $game_temp.boss_battle
      bgm = $data_system.boss_bgm[id-195]
    else
      bgm = $data_system.battle_bgm
    end
    $game_system.bgm_play(bgm)
    $scene = Scene_Battle.new(id,type)
  end
  #--------------------------------------------------------------------------
  # ● 释放NPC相关菜单
  #--------------------------------------------------------------------------
  def dispose_npc
    if @type == 0
      @npc_menu.dispose
      @npc_status.dispose
    end
    @npc_name.dispose
  end
  #--------------------------------------------------------------------------
  # ● 干匠对话
  #--------------------------------------------------------------------------
  def sword_talk
    # 经验不足150000返回nil，常规对话
    return nil if @actor.exp < 150000
    # 已完成铸剑挑战
    if @actor.sword_battle
      @talk_step = 5
      return $data_text.enter_sword.dup
    else # 询问是否挑战
      @talk_step = 6
      return $data_text.sword_ask.dup
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新铸剑属性
  #--------------------------------------------------------------------------
  def refresh_sword_data
    # 计算攻击力
    rand_factor = rand(100) # $3403
    n = [@actor.exp,1100000].min/20000-5 # $05FC
    c,b = n * 2,20
    factor = cal_new_factor(n,b,c)
    judge = Integer(rand(factor))
    factor = cal_new_factor(19,b,c)
    n = factor < judge ? 20 : 1
    while cal_new_factor(n,b,c) < judge
      n += 1
    end
    n = [n-1,0].max
    n = n * 5 + rand(5)
    @actor.sword1 = n
    # 设置中缀
    @actor.sword2 = 0
    rand_factor = rand(100-rand_factor)
    rand_factor += @actor.luck
    n = [rand_factor - 80,40].min
    if n >= 0
      @actor.sword2 = n / 10 * 3 + (rand(4) + 1) * 100
    end
    # 设置后缀
    @actor.sword3 = 0
    rand_factor = rand(100-rand_factor)
    if rand_factor >= 20
      n = [rand_factor + @actor.luck - 40,80].min
      if n >= 0
        @actor.sword3 = n / 20 * 5 + (rand(5) + 1) * 100
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 计算系数
  #--------------------------------------------------------------------------
  def cal_new_factor(a,b,c)
    n = (a - 1) * a * c / 4
    n += a * b
    return n
  end
  #--------------------------------------------------------------------------
  # ● 输入武器名称
  #--------------------------------------------------------------------------
  def input_sword_name
    # 输入密码
    text_thread=Thread.new{$game_system.input_text}
    text_thread.exit
    @new_name = $game_system.output_text
    $game_system.clear_input
  end
  #--------------------------------------------------------------------------
  # ● 检查武器名字
  #--------------------------------------------------------------------------
  def check_sword_name
    # 检查武器名长度
    if @new_name == "" or @new_name.new_size > 8
      print($data_system.name_error)
      return
    end
    # 检查是否与现有武器重名
    next_step = true
    for i in 1..30
      if @new_name == $data_weapons[i].name
        next_step = false
        break
      end
    end
    # 没有重名
    if next_step
      @actor.sword_name = @new_name
      # 设置铸造武器属性
      @actor.set_sword
      $game_temp.write_save_data
      @name_input.dispose
      $scene = Scene_Map.new
    else
      print($data_system.name_error)
    end
  end
  #--------------------------------------------------------------------------
  # ● 恢复菜单样式
  #--------------------------------------------------------------------------
  def resume_window_style
    $game_system.windowskin_name = "Black.png"
  end
  #--------------------------------------------------------------------------
  # ● 显示行走文本
  #--------------------------------------------------------------------------
  def show_walk_step
    text = $data_text.step_success.dup
    show_home_text(text)
  end
  #--------------------------------------------------------------------------
  # ● 显示行走文本
  #--------------------------------------------------------------------------
  def show_direction_choose
    text = $data_text.step_ask.dup
    show_home_text(text)
    @step_menu.visible = true
    @step_menu.active = true
  end
  #--------------------------------------------------------------------------
  # ● 显示黑屏文本
  #--------------------------------------------------------------------------
  def show_home_text(text)
    @black_window.auto_text(text,0,@black_window.back_color)
  end
end