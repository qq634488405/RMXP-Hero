#==============================================================================
# ■ Scene_Study
#------------------------------------------------------------------------------
# 　处理请教画面的类。
#==============================================================================

class Scene_Study
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #    id   -- 师傅ID
  #    type -- 师傅类型，0表示NPC，1表示秘籍
  #--------------------------------------------------------------------------
  def initialize(id, type = 0)
    @id = id
    @type = type
    @actor = $game_actor
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    @screen = Spriteset_Map.new
    # 生成对话窗口
    @talk_window = Window_Help.new(480,160)
    @talk_window.visible,@talk_window.x = false,80
    @talk_window.y,@talk_window.z = 304,500
    # 生成询问窗口
    @confirm_window=Window_Command.new(240,$data_system.confirm_choice,2,3)
    @confirm_window.visible,@confirm_window.active = false,false
    @confirm_window.x,@confirm_window.y = 200,416
    @confirm_window.z = 600
    # 获取请教列表
    teacher = @type == 1 ? $data_items[@id] : $data_enemies[@id]
    @skill_list = teacher.skill_list
    # 显示文本提示
    if @type != 1
      @top_window = Window_Base.new(0, 0, 640, 64)
      @top_window.contents.draw_text(4, 0, 256, 32, $data_text.learn_what)
    end
    @list = []
    # 生成功夫命令列表
    @skill_list.each do |i|
      kf_id,kf_lv = i[0],i[1]
      kf_name = $data_kungfus[kf_id].name
      t_size = kf_name.size / 3
      command = kf_name + "  "*(5-t_size)
      command += " " if kf_lv < 100
      command += "×" + kf_lv.to_s
      @list.push(command)
    end
    # 生成请教窗口
    @skill_window = Window_Command.new(272,@list,1,3,1,0,8,64,224)
    # 生成进度条背景窗口
    @learn = Window_Base.new(160,10,352,64)
    @learn.z = 600
    @learn.visible = false
    @phase = 1
    # 执行过度
    Graphics.transition
    # 主循环
    loop do
      $scene=Scene_Map.new if @skill_list.size == 0
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新信息
      update
      # 如果画面切换就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    $eat_flag = true
    # 释放窗口
    @top_window.dispose if @top_window !=nil
    @skill_window.dispose
    @confirm_window.dispose
    @talk_window.dispose
    @learn.dispose
    @screen.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新信息
  #--------------------------------------------------------------------------
  def update
    @skill_window.update
    @confirm_window.update
    @top_window.update if @top_window != nil
    @talk_window.update
    @learn.update
    case @phase
    when 1
      update_study
    when 2
      # 确认窗口激活的情况下
      if @confirm_window.active
        $eat_flag = true
        update_confirm
        return
      end
      $eat_flag = false
      study(@list_id)
    end
    @screen.update
  end
  #--------------------------------------------------------------------------
  # ● 刷新学习画面
  #--------------------------------------------------------------------------
  def update_study
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 播放取消SE
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Map.new
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      @skill_window.active=false
      kf = @skill_list[@skill_window.index]
      kf_id,@max_lv = kf[0],kf[1]
      @list_id = @actor.get_kf_index(kf_id)
      # 检查功夫列表是否已满且未学会该武功
      if @actor.full_kf_list? and @actor.get_kf_level(kf_id) == 0
        # 播放冻结SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      if @id = -1 # 功夫未学
        @actor.skill_list.push([kf_id,0,0,0])
        @list_id = @actor.get_kf_index(kf_id)
      end
      @top_window.visible = false if @top_window != nil
      @phase = 2
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update_confirm
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 播放取消SE
      $game_system.se_play($data_system.cancel_se)
      stop_learn
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      case @confirm_window.index
      when 0 # 继续
        @confirm_window.active=false
        @talk_window.visible = false
        @confirm_window.visible = false
      when 1 # 取消继续学习
        stop_learn
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘出错信息
  #--------------------------------------------------------------------------
  def draw_error(text,time=Graphics.frame_rate)
    @talk_window.auto_text(text.dup)
    @talk_window.visible=true
    # 显示延时
    for i in 1..time
      # 刷新画面
      Graphics.update
    end
    @talk_window.visible=false
  end
  #--------------------------------------------------------------------------
  # ● 获取读书识字的学费
  #--------------------------------------------------------------------------
  def study_gold(lv)
    return 5 if lv<=20
    return 10 if lv<=30
    return 50 if lv<=60
    return 150 if lv<=80
    return 300 if lv<=100
    return 500 if lv<=120
    return 1000
  end
  #--------------------------------------------------------------------------
  # ● 学习技能
  #--------------------------------------------------------------------------
  def study(id)
    # 调整速度
    Graphics.frame_rate = 120
    now_lv = @actor.skill_list[id][1]
    kf_id = @actor.skill_list[id][0]
    point_max = (now_lv+1)**2
    # 技能等级高于师傅时
    if @actor.get_kf_level(kf_id) > @max_lv
      draw_error($data_text.no_learn)
      stop_learn
      return
    end
    # 检查经验是否充足
    unless @actor.check_kf_exp(kf_id)
      draw_error($data_text.learn_no_exp)
      stop_learn
      return
    end
    # 判断潜能是否大于0
    if @actor.pot > 0
      @actor.pot -= 1
      speed = (@actor.int/2 + rand(@actor.int))/2 + rand(@actor.luck/5)
      @actor.skill_list[id][2] += speed
      # 学习的技能是读书识字
      if kf_id == 11
        gold = study_gold(@actor.get_kf_level(11))
        # 判断学费
        if @actor.gold >= gold
          @actor.lose_gold(gold)
        else # 学费不足，复原潜能及学习点数
          @actor.pot += 1
          @actor.skill_list[id][2] -= speed
          draw_error($data_text.learn_no_gold)
          stop_learn
          return
        end
      end
    else # 潜能为0的时候
      draw_error($data_text.learn_no_pot)
      stop_learn
      return
    end
    process=[200*@actor.skill_list[id][2]/point_max,200].min
    # 描绘学习进度条
    @learn.visible = true
    draw_process(process,id)
    # 学习点数大于升级点数
    if @actor.skill_list[id][2] >= point_max
      @actor.skill_list[id][2] = 0
      @actor.skill_list[id][1] += 1
      # 你的功夫进步了
      draw_error($data_text.sk_lv_up)
      @learn.visible = false
      text = $data_text.continue_learn.dup
      @talk_window.auto_text(text)
      @talk_window.visible = true
      @confirm_window.visible = true
      @confirm_window.active = true
      @skill_window.active=false
      return
    end
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      stop_learn
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘学习进度
  #--------------------------------------------------------------------------
  def draw_process(process,id)
    kf_point = @actor.skill_list[id][2].to_s
    kf_lv = @actor.skill_list[id][1].to_s
    # 根据显示内容调整宽度
    text = kf_point+"/"+kf_lv
    @learn.width = 248 + text.size * 12
    @learn.contents = Bitmap.new(@learn.width - 32,@learn.height - 32)
    color = @learn.normal_color
    @learn.contents.font.color = color 
    @learn.contents.clear
    # 边框
    @learn.contents.fill_rect(5,9,200,1,color)
    @learn.contents.fill_rect(5,24,200,1,color)
    @learn.contents.fill_rect(5,9,1,15,color)
    @learn.contents.fill_rect(205,9,1,16,color)
    # 进度条
    @learn.contents.fill_rect(5,9,process,15,color)
    # 点数/等级
    @learn.contents.draw_text(216,0,@learn.width-248,32,text)
  end
  #--------------------------------------------------------------------------
  # ● 停止学习
  #--------------------------------------------------------------------------
  def stop_learn
    @skill_window.active=true
    @confirm_window.active=false
    @talk_window.visible = false
    @learn.visible = false
    @top_window.visible = true if @top_window != nil
    @confirm_window.visible = false
    @confirm_window.index = 0
    # 恢复帧率
    Graphics.frame_rate = 40
    @phase = 1
  end
end