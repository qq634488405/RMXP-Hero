#==============================================================================
# ■ Scene_Battle (分割定义 3)
#------------------------------------------------------------------------------
# 　处理战斗画面的类。
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # ● 开始使用绝招
  #--------------------------------------------------------------------------
  def start_phase3(user)
    # 转移到回合 3
    @phase = 3
    hide_main_menu
    case @skill_id
    when 32,36,40
      @using_flag = true
      use_magic(user,@skill_id)
    else
      use_skill(user,@skill_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (绝招回合)
  #--------------------------------------------------------------------------
  def update_phase3
    step,n_phase = @phase3_step[0],@phase3_step[1]
    combo = @phase3_step[2] if @phase3_step[2] != nil
    target = @phase3_step[3] if @phase3_step[3] != nil
    case step
    when 1 # 进入下一回合
      update_phase3_next(n_phase)
    when 2 # 刷新连招
      update_phase3_combo(n_phase,combo)
    when 3 # 刷新法术连招
      update_phase3_magic(n_phase,combo)
    when 4 # 刷新连续文本
      update_phase3_text(n_phase,combo,target)
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (下一回合)
  #--------------------------------------------------------------------------
  def update_phase3_next(n_phase)
    if n_phase == 1
      start_phase1
    elsif n_phase == 2
      start_phase2
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (连招)
  #--------------------------------------------------------------------------
  def update_phase3_combo(n_phase,combo)
    # 根据n_phase设定使用者和目标
    case n_phase
    when 1
      user = @enemy
    when 2
      user = @actor
    end
    # 获取当前连招
    combo_act = combo[@combo_id]
    kf_id,max_times = combo_act[0],combo_act[1]
    act_id = combo_act[2+@combo_times[@combo_id]]
    # 进行普通攻击
    common_attack(user,kf_id,act_id)
    @combo_times[@combo_id] += 1
    # 如果已达当前连招最大次数，则进行下一连招
    if @combo_times[@combo_id] == max_times
      @combo_id += 1
      # 如果下一连招为空则进入下一回合
      if combo[@combo_id] == nil
        @phase3_step = [1,n_phase]
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (法术连招)
  #--------------------------------------------------------------------------
  def update_phase3_magic(n_phase,combo)
    # 根据n_phase设定使用者和目标
    case n_phase
    when 1
      user = @enemy
      target = @actor
    when 2
      user = @actor
      target = @enemy
    end
    # 如果下一法术为空则进入下一回合
    if combo[@combo_id] == nil
      @using_flag = false
      @phase3_step = [1,n_phase]
    else
      # 获取待使用法术ID
      id = combo[@combo_id]
      result = user.skill_can_use?(id,target)
      # 可以使用的情况
      if result[0]
        # 开始使用绝招
        use_skill(user,id)
        @combo_id += 1
      else
        # 显示错误文本
        show_text(result[1])
        @using_flag = false
        @phase3_step = [1,n_phase]
        return
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (连续文本)
  #--------------------------------------------------------------------------
  def update_phase3_text(n_phase,combo,target)
    # 根据下回合设置使用者
    case n_phase
    when 1
      user = @enemy
    when 2
      user = @actor
    end
    # 如果下一文本为空则进入下一回合
    if combo[@text_id] == nil
      @phase3_step = [1,n_phase]
      @phase3_step = [3,n_phase,@id_gp] if @using_flag
    else
      # 当前文本为damage
      if combo[@text_id][0,6] == "damage"
        n_text = combo[@text_id].dup.gsub!("damage","")
        # 目标结算伤害
        target.hp = [target.hp-user.damage,0].max
        @msg_window.auto_text(n_text)
        @msg_window.visible = true
        # 播放击中动画
        target.animation_id = 1
        target.animation_hit = true
        @wait_count = 18
      else
        show_text(combo[@text_id])
      end
      @text_id += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 开始结束战斗回合
  #--------------------------------------------------------------------------
  def start_phase4
    # 转移到回合 4
    @phase = 4
    # 隐藏窗口
    hide_main_menu
    # 调整信息窗口位置
    @msg_window.contents.clear
    # 如果为铸剑挑战
    if @type == 1
      remove_sword_weapon
      # 显示挑战失败对话
      @msg_window.auto_text($data_text.sword_fail.dup)
    else
      # 玩家不为坏人且NPC为好人
      if @actor.morals >=128 and @enemy.morals > 0
        # 显示承让了
        @msg_window.auto_text($data_text.no_die_text.dup)
      else # 其他情况玩家被杀死
        text = $data_text.go_die_text.dup
        text.gsub!("actor",@actor.name)
        # 显示去死吧
        @msg_window.auto_text(text)
        # 设置游戏结束标志
        $game_temp.gameover = true
      end
    end
    @msg_window.visible = true
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (玩家失败)
  #--------------------------------------------------------------------------
  def update_phase4
    @result_window.update if @result_window != nil
    # 按下 B 或 C 键的情况下
    if Input.trigger?(Input::C) or Input.trigger?(Input::B)
      # 还原为战斗开始前的 BGM
      $game_system.bgm_play($game_temp.map_bgm)
      # 清除战斗中标志
      $game_temp.in_battle = false
      # 清除临时数据
      @actor.clear_temp_data
      @enemy.clear_temp_data
      if @result_window != nil
        @result_window.dispose 
        @result_window = nil
      end
      # 游戏结束的情况下
      if $game_temp.gameover
        $game_temp.gameover = false
        # 切换到游戏结束画面
        $scene = Scene_Gameover.new
        return
      else
        # 山大王挑战胜利则转移至桃花源
        if @enemy.id == 162
          # 播放移动SE
          $game_system.se_play($data_system.move_se)
          $scene = Scene_Map.new
          # 调整主角姿势
          $game_player.turn_up
          $game_player.straighten
          # 刷新主角
          $game_player.refresh
          # 设置主角的移动目标
          $game_map.setup(57)
          $game_player.moveto(9,13)
          $game_map.autoplay
          # 准备过渡
          Graphics.freeze
          # 设置过渡处理中标志
          $game_temp.transition_processing = true
          $game_temp.transition_name = ""
        else
          # 切换到地图画面
          $scene = Scene_Map.new
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 开始结束战斗回合
  #--------------------------------------------------------------------------
  def start_phase5
    # 转移到回合 5
    @phase = 5
    $game_temp.gameover = false
    if $game_temp.boss_battle
      $game_temp.to_end = @enemy.id - 193
    end
    # 隐藏窗口
    hide_main_menu
    # 调整信息窗口位置
    @msg_window.contents.clear
    # 铸剑挑战胜利
    if @type == 1
      # 使用武器与挑战要求不符
      if @actor.weapon_id != $data_tasks.sword_weapon[@sword_step]
        # 显示挑战失败对话
        @msg_window.auto_text($data_text.sword_no_match[@sword_step].deep_clone)
        @msg_window.visible = true
        remove_sword_weapon
        @phase5_step = 2
        return
      else
        # 挑战阶段+1
        @sword_step += 1
        remove_sword_weapon
        # 莫邪重置所有状态
        @enemy.recover_all
        @phase = 6
        @sword_talk = 0
        # 显示对话
        @msg_window.auto_text($data_text.sword_win.dup)
        @msg_window.visible = true
        return
      end
    end
    # 山大王挑战胜利
    if @enemy.id == 162
      @actor.have_new_home = true
      @actor.room_level = 1
      # 显示对话
      @msg_window.auto_text($data_text.win_shan_king.dup)
      @msg_window.visible = true
      @phase5_step = 4
      return
    end
    @msg_window.y = 0
    # 询问劈不劈
    text = $data_text.kill_text.dup
    text.gsub!("actor",@actor.name)
    @msg_window.auto_text(text)
    @msg_window.visible = false
    # 生成确认窗口
    @confirm_window=Window_Command.new(240,$data_system.confirm_choice,2,3)
    @confirm_window.y,@confirm_window.z = @msg_window.height-24,800
    @confirm_window.x,@confirm_window.index = 200,0
    @confirm_window.visible,@confirm_window.active = false,false
    @phase5_step = 1
  end
  #--------------------------------------------------------------------------
  # ● 画面更新 (玩家胜利)
  #--------------------------------------------------------------------------
  def update_phase5
    case @phase5_step
    when 1 # 确认砍头
      update_phase5_confirm
    when 2 # 按键返回地图
      update_phase4
    when 3 # 捕快任务奖励
      update_phase5_reward
    when 4 # 战利品
      update_phase5_end
    when 5 # XX坛奖励
      update_phase5_tan
    end
  end
  #--------------------------------------------------------------------------
  # ● 画面更新 (确认杀头)
  #--------------------------------------------------------------------------
  def update_phase5_confirm
    @msg_window.visible = true
    @confirm_window.visible,@confirm_window.active = true,true
    @confirm_window.update
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 播放冻结 SE
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 播放确认 SE
      $game_system.se_play($data_system.decision_se)
      case @confirm_window.index
      when 0 # 砍头
        # 显示对话
        text = $data_text.die_text.deep_clone
        id = rand(text.size)
        @msg_window.auto_text(text[id])
        @msg_window.visible = true
        # 如果被杀的是恶人
        if @enemy.id == 198
          # 追杀数+1
          @actor.badman_kill += 1
          # 更新任务信息
          $game_task.wanted_place = 0
          $game_temp.badman_place = 0
          # 更新地图事件
          $game_map.refresh_map_events
          @phase5_step = 3
        # 如果是坛主
        elsif @enemy.id > 162 and @enemy.id < 171
          # 更新杀人列表
          @actor.kill_list.push(@enemy.id)
          # 更新地图事件
          $game_map.refresh_map_events
          # 移除当前的坛地图
          @actor.lose_item(1,20 + @actor.tan_id)
          @phase5_step = 5
        # 其他NPC
        else
          # 更新杀人列表
          @actor.kill_list.push(@enemy.id)
          # 更新地图事件
          $game_map.refresh_map_events
          # 更新平一指任务
          if $game_task.kill_id == @enemy.id
            $game_task.finish_flag = true
            $game_task.kill_id = -1
            @actor.task_kill += 1
          end
          # 结算道德值
          if @actor.morals >= 128
            @actor.morals -= @enemy.morals
          else # 玩家是恶人，NPC是好人
            if @enemy.morals > 0
              @actor.morals -= @enemy.morals/2
            end
          end
          @phase5_step = 4
        end
      when 1 # 不杀
        text = $data_text.live_text.deep_clone
        id = rand(text.size)
        @msg_window.auto_text(text[id])
        @msg_window.visible = true
        @phase5_step = 4
      end
      @confirm_window.dispose
      @confirm_window = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 画面更新 (获得经验潜能)
  #--------------------------------------------------------------------------
  def update_phase5_reward
    # 按下 B 或 C 键的情况下
    if Input.trigger?(Input::C) or Input.trigger?(Input::B)
      @msg_window.visible = true
      # 播放奖励音效
      $game_system.se_play($data_system.actor_collapse_se)
      text = $game_task.give_wanted_reward
      @msg_window.auto_text(text)
      @phase5_step = 4
    end
  end
  #--------------------------------------------------------------------------
  # ● 画面更新 (获得战利品)
  #--------------------------------------------------------------------------
  def update_phase5_end
    # 按下 B 或 C 键的情况下
    if Input.trigger?(Input::C) or Input.trigger?(Input::B)
      @msg_window.visible = false
      # 获取战利品
      gold,all_item,item_name = @enemy.gold,@enemy.item_list,""
      @actor.gold += gold
      unless all_item.empty?
        all_item.each do |i|
          # 如果是三角石板，该掌门已获得则跳过
          if i[0]==1 and i[1].abs==19
            if @actor.stone_list.include?(@enemy.id)
              next
            else
              @actor.stone_list.push(@enemy.id)
              item_name += $data_items[19].name + " "
              next
            end
          end
          # 如果是XX坛地图，对比坛ID才可获得，即要砍头
          if i[0]==1 and (21..28).include?(i[1].abs)
            if @actor.tan_id+20 != i[1].abs
              next
            end
          end
          # 获得物品
          @actor.gain_item(i[0],i[1].abs) if @actor.can_get_item?(i[0],i[1].abs)
          case i[0]
          when 1 # 物品
            item_name += $data_items[i[1].abs].name + " "
          when 2 # 武器
            item_name += $data_weapons[i[1].abs].name + " "
          when 3 # 装备
            item_name += $data_armors[i[1].abs].name + " "
          end
        end
      end
      # 播放奖励音效
      $game_system.se_play($data_system.shop_se)
      # 生成战斗结果窗口
      @result_window = Window_BattleResult.new(gold, item_name)
      @phase5_step = 2
    end
  end
  #--------------------------------------------------------------------------
  # ● 画面更新 (XX坛任务奖励)
  #--------------------------------------------------------------------------
  def update_phase5_tan
    # 按下 B 或 C 键的情况下
    if Input.trigger?(Input::C) or Input.trigger?(Input::B)
      @msg_window.visible = true
      # 播放奖励音效
      $game_system.se_play($data_system.actor_collapse_se)
      if @actor.tan_id != 8
        @phase5_step = 4
      end
      text = $game_task.give_tan_reward
      @msg_window.auto_text(text)
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示铸剑战斗对话
  #--------------------------------------------------------------------------
  def show_sword_battle
    # 显示对话并获得武器
    @msg_window.auto_text($data_text.sword_battle[@sword_step].deep_clone)
    @msg_window.visible = true
    @actor.gain_item(2,$data_tasks.sword_weapon[@sword_step])
    @sword_talk = 1
  end
  #--------------------------------------------------------------------------
  # ● 显示铸剑战斗通过对话
  #--------------------------------------------------------------------------
  def show_sword_pass
    # 显示对话并设置铸剑挑战标志
    @msg_window.auto_text($data_text.sword_pass.dup)
    @msg_window.visible = true
    @actor.sword_battle = true
    @sword_talk = 2
  end
  #--------------------------------------------------------------------------
  # ● 移除铸剑挑战武器
  #--------------------------------------------------------------------------
  def remove_sword_weapon
    # 移除铸剑挑战武器，设置玩家为空手
    bag_id = @actor.get_item_index(2,$data_tasks.sword_weapon[@sword_step],1)
    @actor.lose_bag_id(bag_id)
    @actor.weapon_id = 0
  end
  #--------------------------------------------------------------------------
  # ● 刷新铸剑挑战
  #--------------------------------------------------------------------------
  def update_phase6
    # 按下 B 键的情况或按下 C 键的情况
    if Input.trigger?(Input::B) or Input.trigger?(Input::C)
      case @sword_talk
      when 0 # 判定是否挑战通过
        if @sword_step < 4
          show_sword_battle
        else
          show_sword_pass
        end
      when 1 # 转入战斗
        start_battle
      when 2 # 进入铸剑谷
        # 还原为战斗开始前的 BGM
        $game_system.bgm_play($game_temp.map_bgm)
        # 清除战斗中标志
        $game_temp.in_battle = false
        # 清除临时数据
        @actor.clear_temp_data
        @enemy.clear_temp_data
        # 播放移动SE
        $game_system.se_play($data_system.move_se)
        $scene = Scene_Map.new
        # 设置主角的移动目标
        $game_map.setup(67)
        $game_player.moveto(9,11)
        $game_player.turn_up
        $game_player.straighten
        $game_map.autoplay
        # 准备过渡
        Graphics.freeze
        # 设置过渡处理中标志
        $game_temp.transition_processing = true
        $game_temp.transition_name = ""
      end
    end
  end
end