#==============================================================================
# ■ Scene_Battle (分割定义 3)
#------------------------------------------------------------------------------
# 　处理战斗画面的类。
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # ● 刷新绝招选择
  #--------------------------------------------------------------------------
  def update_phase1_skill_select
    @skill_window.update
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 返回玩家回合
      end_skill_select(0)
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 获取绝招ID，判断能否使用
      @skill_id = @sp_list[@skill_window.index]
      result = @actor.skill_can_use?(@skill_id,@enemy)
      # 可以使用的情况
      if result[0]
        # 开始使用绝招
        end_skill_select(3)
      else
        # 显示错误文本
        show_text(result[1])
        # 返回玩家回合
        end_skill_select(0)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 使用绝招
  #--------------------------------------------------------------------------
  def use_skill(user,id)
    # 设置目标
    t_arr = set_target(user)
    target,user_name,target_name,n_phase = t_arr[0],t_arr[1],t_arr[2],t_arr[3]
    # 扣除绝招消耗
    skill_cost(user,id)
    sp_skill = $data_skills[id]
    # 显示使用文本
    text = sp_skill.use_text[0].deep_clone
    text = replace_text(text,user,user_name,target_name)
    show_text(text)
    # 应用绝招效果
    skill_result = user.skill_effect(target,id)
    case skill_result[0]
    when 0 # 显示文本跳转至下一回合
      if skill_result[1] != nil
        text = skill_result[1]
        text = replace_text(text,user,user_name,target_name)
        if user.damage.is_a?(String)
          # 播放闪避音效
          $game_system.se_play($data_system.enemy_collapse_se)
          show_text(text)
        elsif user.damage == nil
          show_text(text)
        else
          @msg_window.auto_text(text)
          @msg_window.visible = true
          target.hp = [target.hp-user.damage,0].max
          # 播放击中动画
          target.animation_id = 1
          target.animation_hit = true
          @wait_count = 18
        end
      end
      @phase3_step = [1,n_phase]
    when 1 # 连招
      combo = []
      @combo_times = []
      for i in 1...skill_result.size
        combo.push(skill_result[i])
        @combo_times.push(0)
      end
      @combo_id = 0
      @phase3_step = [2,n_phase,combo]
    when 2 # 法术
      # 获取法术返回结果
      aim,d_type,damage = skill_result[1],skill_result[2],skill_result[3]
      text = skill_result[4]
      case aim
      when 0 # 法术失败
        # 播放闪避音效
        $game_system.se_play($data_system.enemy_collapse_se)
        text.each do |i|
          i = replace_text(i,user,user_name,target_name)
          show_text(i)
        end
        @phase3_step = [1,n_phase]
      when 1 # 法术命中目标
        @text_id = 0
        text.each_index do |i|
          if text[i] == "damage"
            text[i] += get_magic_damage(damage,d_type,target)
          end
          text[i] = replace_text(text[i],user,user_name,target_name)
        end
        @phase3_step = [4,n_phase,text,target]
      when 2 # 法术被反弹
        @text_id = 0
        text.each_index do |i|
          if text[i] == "damage"
            text[i] += get_magic_damage(damage,d_type,user)
          end
          text[i] = replace_text(text[i],user,user_name,target_name)
        end
        @phase3_step = [4,n_phase,text,user]
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取伤害文本
  #--------------------------------------------------------------------------
  def get_magic_damage(damage,type,target)
    # 设置目标
    if target.is_a?(Game_Actor)
      target_name = "你"
    else
      target_name = target.name
    end
    # 获取伤害文本
    text = $data_system.fa_damage[type-1][magic_index(damage)].deep_clone
    text.gsub!("target",target_name)
    return text
  end
  #--------------------------------------------------------------------------
  # ● 使用法术
  #--------------------------------------------------------------------------
  def use_magic(user,id)
    # 设置目标
    t_arr = set_target(user)
    target,user_name,target_name,n_phase = t_arr[0],t_arr[1],t_arr[2],t_arr[3]
    sp_skill = $data_skills[id]
    m_data = sp_skill.magic_data
    # 扣除绝招消耗
    skill_cost(user,id)
    # 获取三连法术ID
    @id_gp = [m_data[2],m_data[3],m_data[4]]
    @combo_id = 0
    @phase3_step = [3,n_phase,@id_gp]
  end
  #--------------------------------------------------------------------------
  # ● 绝招消耗
  #--------------------------------------------------------------------------
  def skill_cost(user,id)
    # 扣除HP/FP/MP消耗
    sp_skill = $data_skills[id]
    user.hp -= sp_skill.hp_cost
    user.fp -= user.get_fp_cost(id)
    user.mp -= user.get_mp_cost(id)
    # 获取攻击位置
    pos_id = rand($data_system.hit_place.size)
    @atk_pos = $data_system.hit_place[pos_id].deep_clone
  end
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
  # ● 文本替换
  #--------------------------------------------------------------------------
  def replace_text(text,user,user_name,target_name)
    weapon_name = user.weapon_id > 0 ? $data_weapons[user.weapon_id].name : ""
    text.gsub!("user",user_name)
    text.gsub!("target",target_name)
    text.gsub!("position",@atk_pos)
    text.gsub!("weapon",weapon_name)
    return text
  end
  #--------------------------------------------------------------------------
  # ● 设置目标
  #--------------------------------------------------------------------------
  def set_target(user)
    # 设置目标
    if user.is_a?(Game_Actor)
      user_name = "你"
      target = @enemy
      target_name = target.name
      n_phase = 2
    else
      user_name = user.name
      target = @actor
      target_name = "你"
      n_phase = 1
    end
    return [target,user_name,target_name,n_phase]
  end
  #--------------------------------------------------------------------------
  # ● 改变铸造武器BUFF
  #--------------------------------------------------------------------------
  def change_sword_state
    state_id = -1 * (@actor.sword2 / 100 + 3)
    return unless [-4,-5].include?(state_id)
    user = state_id == -4 ? @enemy : @actor
    if @actor.weapon_id == 31
      user.add_state(state_id,100)
    else
      user.remove_state(state_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 状态更新
  #--------------------------------------------------------------------------
  def states_change(user)
    # 设置目标
    t_arr = set_target(user)
    target,user_name,target_name,n_phase = t_arr[0],t_arr[1],t_arr[2],t_arr[3]
    # 应用状态效果
    state_result = user.states_effect(target)
    unless state_result.empty?
      state_result.each do |i|
        show_text(i[0]) if i[0] != nil
        user.hp = [user.hp-i[1],0].max if i[1] != nil
      end
    end
    # 刷新状态持续回合
    removed = user.remove_states_auto
    # 有被解除的状态则获取状态解除文本
    unless removed.empty?
      removed.each do |i|
        sp_skill = $data_skills[i]
        next if sp_skill.end_text.empty?
        text = sp_skill.end_text[0].deep_clone
        text = replace_text(text,user,user_name,target_name)
        show_text(text)
      end
    end
    # 刷新CD回合
    user.remove_cd_auto
    # 刷新状态窗口
    @status_window.update
  end
  #--------------------------------------------------------------------------
  # ● 开始战斗
  #--------------------------------------------------------------------------
  def start_battle
    # 随机出手
    rand(100) > 50 ? start_phase1 : start_phase2
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