#==============================================================================
# ■ Scene_Battle (分割定义 3)
#------------------------------------------------------------------------------
# 　处理战斗画面的类。
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # ● 开始NPC命令回合
  #--------------------------------------------------------------------------
  def start_phase2
    # 转移到回合 2
    @phase = 2
    # 敌人状态改变
    @enemy_states_refresh = true
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (NPC命令回合)
  #--------------------------------------------------------------------------
  def update_phase2
    # 设置行动
    if @enemy.movable?
      common_attack(@enemy)
    else
      text = $data_text.cannot_move.dup
      text.gsub!("user",@enemy.name)
      show_text(text)
    end
    # 进入玩家回合
    start_phase1
  end
  #--------------------------------------------------------------------------
  # ● 普通攻击
  #--------------------------------------------------------------------------
  def common_attack(user,kf_id = 0,act_id = -1)
    # 设置目标
    t_arr = set_target(user)
    target,user_name,target_name,n_phase = t_arr[0],t_arr[1],t_arr[2],t_arr[3]
    # 获取攻击位置
    id = rand($data_system.hit_place.size)
    @atk_pos = $data_system.hit_place[id].deep_clone
    # 获取攻击招式
    if kf_id > 0
      atk_text = user.get_kf_id_action(kf_id,act_id)
    else
      atk_text = user.get_kf_action(0)
    end
    atk_text = replace_text(atk_text,user,user_name,target_name)
    # 显示攻击文本
    show_text(atk_text)
    # 应用普通攻击效果
    hit_para = user.attack_effect(target)
    damage,hit_type,hurt_num = hit_para[0],hit_para[1],hit_para[2]
    # 伤害为字符串，即未命中的情况
    if damage.is_a?(String)
      eva_result = damage.split(".")
      text = get_eva_text(eva_result[1].to_i,target,@atk_pos)
      # 播放闪避音效
      $game_system.se_play($data_system.enemy_collapse_se)
      show_text(text)
    else # 造成伤害
      target.hp = [target.hp - damage, 0].max
      target.maxhp = [target.maxhp - hurt_num, 0].max
      text = get_hit_text(damage,hit_type,hurt_num,target)
      # 应用吸血大法效果
      xi_lv = user.get_kf_level(56)
      user.hp = [user.hp+xi_lv*damage/100,user.maxhp].min
      @msg_window.auto_text(text)
      @msg_window.visible = true
      # 播放击中动画
      target.animation_id = 1
      target.animation_hit = true
      @wait_count = 18
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取闪避文本，user为轻功使用者，即被攻击者
  #--------------------------------------------------------------------------
  def get_eva_text(type,user,pos)
    # 设置目标
    t_arr = set_target(user)
    target,user_name,target_name,n_phase = t_arr[0],t_arr[1],t_arr[2],t_arr[3]
    case type
    when 1 # 轻功闪避
      text = user.get_kf_action(1)
      text = replace_text(text,user,user_name,target_name)
    when 2 # 招架
      t = user.weapon_id == 0 ? $data_system.hand_def : $data_system.weapon_def
      text = t[rand(t.size)].deep_clone
      text.gsub!("user",user_name)
    when 3 # 影分身
      text = $data_text.sp_def.dup
      text.gsub!("user",user_name)
    end
    return text
  end
  #--------------------------------------------------------------------------
  # ● 获取伤害文本
  #--------------------------------------------------------------------------
  def get_hit_text(damage,type,hurt,target)
    # 设置目标
    if target.is_a?(Game_Actor)
      target_name = "你"
    else
      target_name = target.name
    end
    # 获取伤害文本
    if damage == 0
      text1 = $data_system.no_damage.deep_clone
    else
      text1 = $data_system.hit_word[type][damage_index(damage)].deep_clone
    end
    # 根据是否受伤获取状态文本
    if hurt > 0
      percent = target.maxhp * 100 / target.full_hp
      text2 = $data_system.in_hurt[hp_index(percent)].deep_clone
    else
      percent = target.hp * 100 / target.full_hp
      text2 = $data_system.out_hurt[hp_index(percent)].deep_clone
    end
    text = text1 + text2
    text.gsub!("target",target_name)
    return text
  end
  #--------------------------------------------------------------------------
  # ● 获取伤害文本ID
  #--------------------------------------------------------------------------
  def damage_index(damage)
    case damage
    when 0...10
      return 0
    when 10...20
      return 1
    when 20...40
      return 2
    when 40...80
      return 3
    when 80...120
      return 4
    when 120...160
      return 5
    when 160...240
      return 6
    else
      return 7
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取法术伤害文本ID
  #--------------------------------------------------------------------------
  def magic_index(damage)
    case damage
    when 0...10
      return 0
    when 10...20
      return 1
    when 20...40
      return 2
    when 40...80
      return 3
    when 80...160
      return 4
    else
      return 5
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取HP状态文本ID
  #--------------------------------------------------------------------------
  def hp_index(percent)
    case percent
    when 100
      return 0
    when 95...100
      return 1
    when 90...95
      return 2
    when 80...90
      return 3
    when 60...80
      return 4
    when 40...60
      return 5
    when 30...40
      return 6
    when 20...30
      return 7
    when 10...20
      return 8
    when 5...10
      return 9
    when 0...5
      return 10
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
end
