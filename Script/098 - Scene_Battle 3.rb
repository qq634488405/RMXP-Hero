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
    action = make_enemy_action
    # 执行行动
    case action
    when 4 # 普通攻击
      common_attack(@enemy)
    when 5 # 呆若木鸡
      text = $data_text.cannot_move.dup
      text.gsub!("user",@enemy.name)
      show_text(text)
    else # 使用绝招
      @skill_id = action - 300
      start_phase3(@enemy)
      return
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
      t = user.weapon_id <= 0 ? $data_system.hand_def : $data_system.weapon_def
      text = t[rand(t.size)].deep_clone
      text.gsub!("user",user_name)
    when 3 # 影分身
      text = $data_system.sp_def.dup
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
end
