#==============================================================================
# ■ Scene_End
#------------------------------------------------------------------------------
# 　处理游戏结局画面的类。
#==============================================================================

class Scene_End
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    # 生成主窗口
    @main_window = Window_Base.new(0,0,640,480)
    @actor = $game_actor
    # 获取游戏时间
    @time = (@actor.age-14)*43200+@actor.play_time
    @time = [@time,Graphics.frame_count/Graphics.frame_rate].max
    @end_step = 1
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入情报
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
    @main_window.dispose
    # 淡入淡出 BGM、BGS、ME
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # 退出
    $scene = nil
  end
  #--------------------------------------------------------------------------
  # ● 获取结局评价
  #--------------------------------------------------------------------------
  def get_end_com
    hour,min,sec = @time/60/60,@time/60%60,@time%60
    n_time = sprintf("%02d:%02d:%02d", hour, min, sec)
    # 杀NPC数
    npc_kill = @actor.kill_list.size
    # 去掉阴间十王，喽啰和坛主
    @actor.kill_list.each do |i|
      if (150..170).include?(i) or (173..194).include?(i)
        npc_kill -= 1
      end
    end
    npc_kill = [@actor.kill_num,npc_kill].max
    # 追杀数
    kill_num = @actor.morals >= 128? @actor.badman_kill : @actor.task_kill
    # 名声
    morals = @actor.morals
    # 最终评定
    rank = $data_text.end_com
    if morals <100 and @actor.face >=32 and kill_num >= 100
      rank_id = 0 # 邪恶天使
    elsif morals >= 160 and kill_num >=60 and @actor.face >= 22
      rank_id = 1 # 盖世大侠
    elsif npc_kill == 0 and @actor.badman_kill == 0
      rank_id = 2 # 好好先生
    elsif morals < 128 and @actor.task_kill >= 108
      rank_id = 3 # 浪子杀手
    elsif morals >= 128 and @actor.badman_kill >= 64
      rank_id = 4 # 无情名捕
    elsif npc_kill >= 120
      rank_id = 5 # 冷血屠夫
    elsif @actor.gender > 0 and @actor.face >= 36 and @actor.age < 30
      rank_id = 6 # 绝代佳人
    elsif hour < 48
      rank_id = 7 # 神行太保
    elsif @actor.dance >= 300
      rank_id = 8 # 舞林高手
    elsif @actor.ball >= 300
      rank_id = 9 # 灌篮高手
    else
      rank_id = 10 # 普通菜鸟
    end
    return [n_time,npc_kill.to_s,kill_num.to_s,morals.to_s,rank[rank_id]]
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    @main_window.update
    # 刷新主窗口
    case @end_step
    when 1
      update_end_com
    when 2
      update_to_real
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面(结局评价)
  #--------------------------------------------------------------------------
  def update_end_com
    end_text = $data_system.end_status.deep_clone
    ranks = get_end_com
    end_rep = ["all_time","kill_npc","all_kill","morals","end_lv"]
    @main_window.contents.clear
    # 替换并显示文本
    end_text.each_index do |i|
      end_text[i].gsub!(end_rep[i],ranks[i])
      @main_window.contents.draw_text(152,144+32*i,304,32,end_text[i])
    end
    # 按下 B 键或 C 键的情况
    if Input.trigger?(Input::B) or Input.trigger?(Input::C)
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 进入第二步
      @end_step = 2
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面(回到现实)
  #--------------------------------------------------------------------------
  def update_to_real
    end_id = (@actor.morals>=160 or @actor.morals<100) ? 1 : 0
    end_text = $data_text.end_text[end_id].deep_clone
    @main_window.contents.clear
    # 描绘文本
    end_text.each_index do |i|
      @main_window.contents.draw_text(32,96+32*i,576,32,end_text[i])
    end
    # 按下 B 键或 C 键的情况
    if Input.trigger?(Input::B) or Input.trigger?(Input::C)
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 退出游戏
      $scene = nil
    end
  end
end
