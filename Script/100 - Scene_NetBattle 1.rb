#==============================================================================
# ■ Scene_NetBattle (分割定义 1)
#------------------------------------------------------------------------------
# 　处理联机战斗画面的类。
#==============================================================================

class Scene_NetBattle < Scene_Battle
  #--------------------------------------------------------------------------
  # ● 初始化，0--客户端，1--服务端
  #--------------------------------------------------------------------------
  def initialize(type,socket)
    @is_server = type == 0 ? false : true
    @socket = socket
    @id,@type = 199,0
    $eat_flag = false
    @action_count = 600
    # 设置目标IP地址
    if @is_server
      @clientmsg = $game_temp.msg_for_socket
    else
      @serverip = $game_temp.msg_for_socket
    end
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    # 初始化战斗用的各种暂时数据
    $game_temp.net_battle = true
    super
    Win32API.new("ws2_32","closesocket","p","v").call(@socket)
  end
  #--------------------------------------------------------------------------
  # ● 设置目标
  #--------------------------------------------------------------------------
  def set_target(user_type)
    case user_type
    when 0
      # 设置目标
      user_name = "你"
      target = @enemy
      target_name = target.name
      n_phase = 6
    when 1
      user_name = user.name
      target = @actor
      target_name = "你"
      n_phase = 1
    end
    return [target,user_name,target_name,n_phase]
  end
  #--------------------------------------------------------------------------
  # ● 开始战斗
  #--------------------------------------------------------------------------
  def start_battle
    if @is_server
      # 随机出手
      rand(100) > 50 ? start_phase1 : start_phase6
    else
      start_phase6
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (角色命令回合)
  #--------------------------------------------------------------------------
  def update_phase1
    @action_count -= 1
    # 操作超时自动进行普通攻击
    if @action_count == 0
      hide_main_menu
      # 设置行动
      if @actor.movable?
        common_attack(@actor)
      else
        text = $data_text.cannot_move.dup
        text.gsub!("user","你")
        show_text(text)
      end
      # 进入敌方行动
      send("next")
      start_phase6
      return
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 改变铸造武器BUFF
  #--------------------------------------------------------------------------
  def change_sword_state
    super
    sword2 = $game_temp.net_sword[1]
    state_id = -1 * (sword2 / 100 + 3)
    return unless [-4,-5].include?(state_id)
    user = state_id == -4 ? @actor : @enemy
    if @enemy.weapon_id == 32
      user.add_state(state_id,100)
    else
      user.remove_state(state_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 开始阶段6（等待对手操作）
  #--------------------------------------------------------------------------
  def start_phase6
    @phase = 6
    @enemy_states_refresh = true
  end
  #--------------------------------------------------------------------------
  # ● 刷新阶段6（等待对手操作）
  #--------------------------------------------------------------------------
  def update_phase6
    # 收取信息
    msg = recieve
    # 更新数据
    if msg["_data"] == "_data"
      set_new_data(msg)
    # 对手吸气
    elsif msg["recover"] == "text"
      text = $data_text.hp_recover.dup
      text.gsub!("你",@enemy.name)
      show_text(text)
    # 对手使用物品
    elsif msg["item"] == "item"
      text = $data_text.net_item.dup
      text.gsub!("target",@enemy.name)
      show_text(text)
    # 对手调整招式
    elsif msg["kungfu"] == "kungfu"
      text = $data_text.net_item.dup
      text.gsub!("target",@enemy.name)
      show_text(text)
    # 对手逃跑认输
    elsif msg["you_win"] == "you_win"
      @phase = 5
      @phase5_step = 5
    # 你的回合
    elsif msg["next"] == "next"
      start_phase1
    else
      text = $data_text.net_info[7].deep_clone
      @msg_window.auto_text(text)
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
    s_text = "text"
    unless state_result.empty?
      state_result.each do |i|
        if i[0] != nil
          show_text(i[0])
          s_text += "|" + i[0]
        end
        # HP发生变化
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
        s_text += "|" + text
      end
    end
    # 刷新CD回合
    user.remove_cd_auto
    # 刷新状态窗口
    @status_window.update
    # 发送文本显示并更新角色数据
    send(s_text)
    send_new_data
  end
  #--------------------------------------------------------------------------
  # ● 收取数据
  #--------------------------------------------------------------------------
  def recieve
    if @is_server
      c_info = @clientmsg.split(":")
      msg=Win32API.new("NetworkSupport","srv_merry_recv","ppp","p").call(@socket,c_info[0],c_info[1])
    else
      msg=Win32API.new("NetworkSupport","cli_merry_recv","pp","p").call(@socket,@serverip)
    end
    return msg
  end
  #--------------------------------------------------------------------------
  # ● 发送数据
  #--------------------------------------------------------------------------
  def send(msg)
    if @is_server
      c_info = @clientmsg.split(":")
      Win32API.new("NetworkSupport","srv_merry_send","pppp","v").call(@socket,msg,c_info[0],c_info[1])
    else
      Win32API.new("NetworkSupport","cli_merry_send","ppp","v").call(@socket,msg,@serverip)
    end
    # 等待接收反馈
    n = false
    for i in 900
      Graphics.update
      if recieve == "success"
        n = true
        break
      end
    end
    # 未收到成功反馈
    unless n
      @phase = 5
      @phase4_step = 3
    end
  end
  #--------------------------------------------------------------------------
  # ● 逃跑（认输）
  #--------------------------------------------------------------------------
  def escape
    send("you_win")
    @phase = 5
    @phase5_step = 4
  end
  #--------------------------------------------------------------------------
  # ● 发送新属性
  #--------------------------------------------------------------------------
  def send_new_data
    # 发送属性变更
    type = @is_server ? 0 : 1
    msg = @actor.make_net_data(type)
    send(msg)
  end
  #--------------------------------------------------------------------------
  # ● 设置新属性
  #--------------------------------------------------------------------------
  def set_new_data(net_data)
    data = net_data.split("|")
    data.delete_at(0)
    @enemy.base_hit = data[3].to_i
    @enemy.base_eva = data[4].to_i
    @enemy.base_atk = data[5].to_i
    @enemy.base_def = data[6].to_i
    @enemy.exp = data[7].to_i
    @enemy.fp_plus = data[8].to_i
    @enemy.mp_plus = data[9].to_i
    @enemy.base_str = data[10].to_i
    @enemy.base_agi = data[11].to_i
    @enemy.base_int = data[12].to_i
    @enemy.base_bon = data[13].to_i
    @enemy.base_fac = data[14].to_i
    @enemy.base_luc = data[15].to_i
    @enemy.hp = data[16].to_i
    @enemy.maxhp = data[17].to_i
    @enemy.fp = data[18].to_i
    @enemy.maxfp = data[19].to_i
    @enemy.mp = data[20].to_i
    @enemy.maxmp = data[21].to_i
    @enemy.full_hp = data[22].to_i
    @enemy.weapon_id = data[23].to_i == 31 ? 32 : data[23].to_i    
    @enemy.skill_use = [data[24].to_i,data[25].to_i,data[26].to_i,
                        data[27].to_i,data[28].to_i,data[29].to_i]
  end
  #--------------------------------------------------------------------------
  # ● 吸气恢复
  #--------------------------------------------------------------------------
  def recover
    old_fp = @actor.fp
    super
    if old_fp != @actor.fp
      send("recover")
    end
  end
  #--------------------------------------------------------------------------
  # ● 结束选择物品
  #--------------------------------------------------------------------------
  def end_item_select
    send("item")
    send_new_data
    super
  end
  #--------------------------------------------------------------------------
  # ● 结束选择功夫
  #--------------------------------------------------------------------------
  def end_kf_select
    send("kungfu")
    send_new_data
    super
  end
  #--------------------------------------------------------------------------
  # ● 结束使用内力
  #--------------------------------------------------------------------------
  def end_fp_select
    send_new_data
    super
  end
end