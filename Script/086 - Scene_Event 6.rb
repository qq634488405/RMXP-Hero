#==============================================================================
# ■ Scene_Event (分割定义 6)
#------------------------------------------------------------------------------
# 　处理各类地图事件的类。
#==============================================================================

class Scene_Event
  #--------------------------------------------------------------------------
  # ● 刷新夫妻事件
  #--------------------------------------------------------------------------
  def update_couple
    # 刷新NPC窗口
    @npc_menu.update
    @npc_status.update
    @npc_name.update
    case @marry_step
    when 1 # 夫妻菜单选择
      update_couple_menu
    when 2 # 建立联机(客户端)
      update_client_connect
      if @connected
        @marry_step = 4
      end
    when 3 # 结束联机
      close_connect
      @phase = 1
    when 4 # 联机结果
      update_check_result
    when 5 # 建立联机(服务端)
      update_server_connect
      if @connected
        @marry_step = 6
      end
    when 6 # 等待收取信息
      update_wait_msg
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新夫妻菜单
  #--------------------------------------------------------------------------
  def update_couple_menu
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Map.new
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      @npc_menu.active = false
      @npc_menu.visible = false
      @npc_name.visible = false
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      case @npc_menu.index
      when 0 # 请教
        # 如果功夫列表为空，则跳至接受
        if @actor.couple_kf_list.empty? or @actor.couple_kf_list.nil?
          @marry_step = 5
        else # 不为空则转到请教界面
          $scene = Scene_Study.new(0,2)
        end
      when 1 # 传授(客户端)
        show_text($data_text.net_info[3])
        @marry_step = 2
      when 2 # 接受(服务端)
        @marry_step = 5
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新检查联机结果
  #--------------------------------------------------------------------------
  def update_check_result
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      show_text($data_text.net_error[4])
      @marry_step = 3
      return
    end
    request = recieve_from_server
    case request
    when "request_player_crc" # 验证是否未夫妻联机
      crc_info="player_crc|"+@actor.marry_crc[2].to_s+"|"+@actor.marry_crc[3].to_s
      send_to_server(crc_info)
    when "error_player" # 双方不为夫妻
      show_text($data_text.couple_no_match)
      @marry_step = 3
    when "kf_list" # 发送技能列表
      # 没有技能可传授
      if @actor.skill_list.empty?
        text = $data_text.net_info[6]
        text.gsub!("name","你")
        @marry_step = 3
        send_to_server("kf_list0")
        return
      end
      ckf_list = "kf_list"
      @actor.skill_list.each do |i|
        # 发送ID*1000+等级
        kf_data = i[0] * 1000 + i[1]
        ckf_list += "|" + kf_data.to_s
      end
      send_to_server(ckf_list)
    when "success"
      show_text($data_text.net_info[4])
      @marry_step = 3
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新等待传授方数据
  #--------------------------------------------------------------------------
  def update_wait_msg
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      show_text($data_text.net_error[4])
      @marry_step = 3
      return
    end
    # 未收到crc验证信息
    if @player_crc.nil?
      request_player_crc
      return
    else
      send_to_client("kf_list")
    end
    # 未收到技能列表
    if @ckf_list.nil?
      request_player_kf
      return
    else
      marry_kf = []
      @ckf_list.each do |i|
        kf_id = i.to_i / 1000
        kf_lv = i.to_i % 1000
        marry_kf.push([kf_id,kf_lv])
      end
      @actor.couple_kf_list = marry_kf
      send_to_client("success")
      show_text($data_text.net_info[5])
      @marry_step = 3
    end
  end
  #--------------------------------------------------------------------------
  # ● 收取技能列表
  #--------------------------------------------------------------------------
  def request_player_kf
    # 接收信息
    msg = recieve_from_client
    if msg["kf_list"] == "kf_list"
      # 如果没有技能数据
      if msg == "kf_list0"
        text = $data_text.net_info[6]
        text.gsub!("name",@actor.marry_name)
        @marry_step = 3
        return
      end
      # 获取技能数据
      @ckf_list = msg.split("|")
      @ckf_list.delete_at(0)
    else
      @ckf_list = nil
      send_to_client("kf_list")
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新联机事件
  #--------------------------------------------------------------------------
  def update_net
    case @marry_step
    when 1 # 联机菜单选择
      update_net_menu
    when 2 # 建立联机(客户端)
      update_client_connect
      if @connected
        @marry_step = 4
      end
    when 3 # 结束联机
      close_connect
      @phase = 1
    when 4 # 联机结果
      update_net_result
    when 5 # 建立联机(服务端)
      update_server_connect
      if @connected
        @marry_step = 6
      end
    when 6 # 等待收取信息
      update_net_msg
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新联机对战菜单
  #--------------------------------------------------------------------------
  def update_net_menu
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Map.new
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      @confirm_window.visible = false
      @confitm_window.active = false
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      case @confirm_window.index
      when 0
        @marry_step = 5
      when 1
        @marry_step = 2
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新检查联机结果(客户端)
  #--------------------------------------------------------------------------
  def update_net_result
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      show_text($data_text.net_error[4])
      @marry_step = 3
      return
    end
    msg = recieve_from_server
    # 发送己方数据
    if msg["request_actor_data"] == "request_actor_data"
      s_msg = @actor.make_net_data(1)
      send_to_server(s_msg)
    # 收到对方数据
    elsif msg["server_data"] == "server_data"
      net_player = msg.split("|")
      net_player.delete_at(0)
      set_net_player(net_player)
      send_to_server("success")
      $game_temp.socket_msg = @i_text
      call_net_battle(0,@client_sock)
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新检查联机结果(服务端)
  #--------------------------------------------------------------------------
  def update_net_msg
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      show_text($data_text.net_error[4])
      @marry_step = 3
      return
    end
    # 未收到客户端玩家信息
    if @net_player.nil?
      request_player_data
      return
    else
      msg = recieve_from_client
      if msg["success"] = "success"
        $game_temp.socket_msg = @clientmsg
        call_net_battle(1,@server_sock)
      else
        s_msg = @actor.make_net_data(0)
        send_to_client(s_msg)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 收取技能列表
  #--------------------------------------------------------------------------
  def request_player_data
    # 接收信息
    msg = recieve_from_client
    if msg["client_data"] == "client_data"
      @net_player = msg.split("|")
      @net_player.delete_at(0)
      set_net_player(@net_player)
    else
      @net_player = nil
      send_to_client("request_actor_data")
    end
  end
  #--------------------------------------------------------------------------
  # ● 进入联机对战
  #--------------------------------------------------------------------------
  def call_net_battle(type,socket)
    # 清除菜单调用标志
    $game_temp.menu_calling = false
    $game_temp.menu_beep = false
    # 记忆地图 BGM 、停止 BGM
    $game_temp.map_bgm = $game_system.playing_bgm
    $game_system.bgm_stop
    # 演奏战斗 BGM
    $game_system.bgm_play($data_system.net_bgm)
    $scene = Scene_NetBattle.new(type,socket)
  end
  #--------------------------------------------------------------------------
  # ● 设置联机对战角色属性
  #--------------------------------------------------------------------------
  def set_net_player(data)
    # 玩家信息存入199号敌人
    $data_enemies[199] = RPG::Enemy.new
    $data_enemies[199].name = data[0]
    $data_enemies[199].gender = data[1].to_i
    battler_name = ["Player_Boy","Player_Girl"]
    $data_enemies[199].battler_name = battler_name[data[1].to_i % 2]
    $data_enemies[199].age = data[2].to_i
    $data_enemies[199].base_hit = data[3].to_i
    $data_enemies[199].base_eva = data[4].to_i
    $data_enemies[199].base_atk = data[5].to_i
    $data_enemies[199].base_def = data[6].to_i
    $data_enemies[199].exp = data[7].to_i
    $data_enemies[199].fp_plus = data[8].to_i
    $data_enemies[199].mp_plus = data[9].to_i
    $data_enemies[199].base_str = data[10].to_i
    $data_enemies[199].base_agi = data[11].to_i
    $data_enemies[199].base_int = data[12].to_i
    $data_enemies[199].base_bon = data[13].to_i
    $data_enemies[199].base_fac = data[14].to_i
    $data_enemies[199].base_luc = data[15].to_i
    $data_enemies[199].hp = data[16].to_i
    $data_enemies[199].maxhp = data[17].to_i
    $data_enemies[199].fp = data[18].to_i
    $data_enemies[199].maxfp = data[19].to_i
    $data_enemies[199].mp = data[20].to_i
    $data_enemies[199].maxmp = data[21].to_i
    $data_enemies[199].full_hp = data[22].to_i
    $data_enemies[199].weapon_id = data[23].to_i == 31 ? 32 : data[23].to_i    
    $data_enemies[199].skill_use = [data[24].to_i,data[25].to_i,data[26].to_i,
                                    data[27].to_i,data[28].to_i,data[29].to_i]
    $data_enemies[199].skill_list = []
    if data[30].to_i > 0
      for i in 1..data[30].to_i
        kf_id = data[30 + i].to_i / 1000
        kf_lv = data[30 + i].to_i % 1000
        $data_enemies[199].skill_list.push([kf_id,kf_lv])
      end
    end
    s_id = 31 + data[30].to_i
    if data[s_id + 1] > -1
      # 设置铸造武器属性
      $data_weapons[32] = RPG::Weapons.new
      $data_weapons[32].name = data[s_id]
      $data_weapons[32].type = data[s_id + 1].to_i
      $game_temp.net_sword = []
      for i in 2..4
        $game_temp.net_sword.push(data[s_id + i].to_i)
      end
      # 攻击为前缀参数
      $data_weapons[32].add_atk = $game_temp.net_sword[0]
      # 中缀、后缀参数/100为类型
      sword2_type = $game_temp.net_sword[1] / 100
      sword3_type = $game_temp.net_sword[2] / 100
      # 中缀、后缀参数%100为数值
      sword2_data = $game_temp.net_sword[1] % 100
      sword3_data = $game_temp.net_sword[2] % 100
      # 设置中缀属性
      if sword2_type > 2
        # 中缀1，2为战斗中状态效果
        case sword2_type
        when 3 # 增加闪避
          $data_weapons[32].add_eva = sword2_data
        when 4 # 增加命中
          $data_weapons[32].add_hit = sword2_data
        end
      end
      # 设置后缀名和属性
      if sword3_type > 0
        case sword3_type
        when 1 # 增加膂力
          $data_weapons[32].add_str = sword3_data
        when 2 # 增加敏捷
          $data_weapons[32].add_agi = sword3_data
        when 3 # 增加悟性
          $data_weapons[32].add_int = sword3_data
        when 4 # 增加根骨
          $data_weapons[32].add_bon = sword3_data
        when 5 # 增加外貌
          $data_weapons[32].add_fac = sword3_data
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 发送至服务端
  #--------------------------------------------------------------------------
  def send_to_server(msg)
    Win32API.new("Lib/NetworkSupport.dll","cli_merry_send","ppp","v").call(@client_sock,msg,@i_text)
  end
  #--------------------------------------------------------------------------
  # ● 发送至客户端
  #--------------------------------------------------------------------------
  def send_to_client(msg)
    c_info = @clientmsg.split(":")
    Win32API.new("Lib/NetworkSupport.dll","srv_merry_send","pppp","v").call(@server_sock,msg,c_info[0],c_info[1])
  end
  #--------------------------------------------------------------------------
  # ● 从服务端接收
  #--------------------------------------------------------------------------
  def recieve_from_server
    msg=Win32API.new("Lib/NetworkSupport.dll","cli_merry_recv","pp","p").call(@client_sock,@i_text)
    return msg
  end
  #--------------------------------------------------------------------------
  # ● 从客户端接收
  #--------------------------------------------------------------------------
  def recieve_from_client
    c_info = @clientmsg.split(":")
    msg=Win32API.new("Lib/NetworkSupport.dll","srv_merry_recv","ppp","p").call(@server_sock,c_info[0],c_info[1])
    return msg
  end
end