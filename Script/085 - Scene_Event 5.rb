#==============================================================================
# ■ Scene_Event (分割定义 5)
#------------------------------------------------------------------------------
# 　处理各类地图事件的类。
#==============================================================================

class Scene_Event
  #--------------------------------------------------------------------------
  # ● 月下老人交谈
  #--------------------------------------------------------------------------
  def marry_talk
    @talk_step = 3
    # 玩家为茅山派
    if @actor.class_id == 8
      return $data_text.maoshan_marry
    end
    # 玩家不满20岁
    if @actor.age < 20
      return $data_text.marry_no_age
    end
    # 玩家没有桃花源
    unless @actor.have_new_home
      return $data_text.marry_no_home
    end
    @phase = 12
    @marry_step = 1
    @connected = false
    @npc_menu.dispose
    @npc_menu = nil
    @npc_menu = Window_Command.new(280,$data_system.marry_menu,2,3)
    @npc_menu.x,@npc_menu.y,@npc_menu.z = 160,336,800
    @npc_menu.opacity = 0
    return $data_text.marry_ask
  end
  #--------------------------------------------------------------------------
  # ● 刷新结婚
  #--------------------------------------------------------------------------
  def update_marry
    @npc_menu.update
    @npc_status.update
    @npc_name.update
    case @marry_step
    when 1 # 刷新菜单
      update_marry_menu
    when 2 # 建立联机(客户端)
      update_client_connect
      if @connected # 求婚4，分道8
        @marry_step = @npc_menu.index * 2 + 4
      end
    when 3 # 结束联机
      close_connect
      @phase = 1
    when 4 # 发送求婚
      show_text($data_text.send_marry)
      update_wait_marry
    when 5 # 建立联机(服务端)
      update_server_connect
      if @connected # 允婚6，扬镳9
        @player_info = nil
        @marry_step = @npc_menu.index / 3 * 3 + 6
      end
    when 6 # 接收求婚
      update_get_marry_info
    when 7 # 确认求婚请求
      update_marry_decision
    when 8 # 发送离婚
      text = $data_text.send_divorce.dup
      text.gsub!("name",@actor.marry_name)
      show_text(text)
      update_wait_divorce
    when 9 # 接收离婚
      update_get_divorce_info
    when 10 # 确认离婚请求
      update_divorce_decision
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新结婚菜单
  #--------------------------------------------------------------------------
  def update_marry_menu
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      # 回到地图
      $scene=Scene_Map.new
      return
    end
    # 按下 C 键的情况
    if Input.trigger?(Input::C)
      @npc_menu.visible = false
      @npc_menu.active = false
      @npc_name.visible = false
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      case @npc_menu.index
      when 0 # 求婚
        if @actor.marry > 0
          show_text($data_text.already_married)
          @phase = 1
          return
        end
        show_text($data_text.net_info[3])
        @marry_step = 2
      when 1 # 允婚
        if @actor.marry > 0
          show_text($data_text.already_married)
          @phase = 1
          return
        end
        @marry_step = 5
      when 2 # 分道
        if @actor.marry == 0
          show_text($data_text.unmarry_divorce)
          @phase = 1
          return
        end
        show_text($data_text.net_info[3])
        @marry_step = 2
      when 3 # 扬镳
        if @actor.marry == 0
          show_text($data_text.unmarry_divorce)
          @phase = 1
          return
        end
        @marry_step = 5
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新联机(客户端)
  #--------------------------------------------------------------------------
  def update_client_connect
    # 未建立连接
    if @client_sock.nil?
      # 输入目标IP地址
      input_text
      unless check_ip(@i_text)
        print($data_text.net_error[5])
        return
      end
      @talk_window.visible = false
      # 创建客户端
      @client_sock=Win32API.new("Lib/NetworkSupport.dll","create_client","v","L").call
      @wait_count = 1200
    else
      # 等待超时
      if @wait_count == -1
        show_text($data_text.net_error[3])
        @marry_step = 3
        return
      end
      # 按下 B 键的情况
      if Input.trigger?(Input::B)
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        show_text($data_text.net_error[4])
        @marry_step = 3
        return
      end
      @wait_count -= 1
      # 连接成功
      if 1==Win32API.new("Lib/NetworkSupport.dll","client_connect","pp","i").call(@client_sock,@i_text)
        @connected = true
        @wait_count=400
        show_text($data_text.net_error[6])
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新联机(服务端)
  #--------------------------------------------------------------------------
  def update_server_connect
    if @server_sock.nil?
      # 创建服务端
      @server_sock=Win32API.new("Lib/NetworkSupport.dll","create_server","v","L").call
      self_ip=Win32API.new("Lib/NetworkSupport.dll","get_host_ip_string","v","p").call
      # 获取本机IP
      i = Win32API.new("Lib/NetworkSupport.dll","check_InternalIP","v","i").call
      net_i = i == 1 ? 0 : 1
      text = $data_text.net_info[2] + $data_text.net_info[net_i]
      text.gsub!("my_ip",self_ip)
      show_text(text)
      @wait_count=1200
    else
      # 等待超时
      if @wait_count == -1
        show_text($data_text.net_error[3])
        @marry_step = 3
        return
      end
      # 按下 B 键的情况
      if Input.trigger?(Input::B)
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        show_text($data_text.net_error[4])
        @marry_step = 3
        return
      end
      @wait_count -= 1
      @clientmsg=Win32API.new("Lib/NetworkSupport.dll","server_accept","p","p").call(@server_sock)
      # 建立完成
      if @clientmsg != "0"
        @connected = true
        @wait_count=400
        show_text($data_text.net_error[6])
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 等待对方求婚回应
  #--------------------------------------------------------------------------
  def update_wait_marry
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      show_text($data_text.net_error[4])
      @marry_step = 3
      return
    end
    request = recieve_from_server
    # 获取玩家信息
    if request == "request_player_info"
      # 获取姓名，年龄，性别，外貌，时间并发送
      name,age,gender = @actor.name,@actor.age,@actor.gender
      face,time = @actor.face_level,Graphics.frame_count/Graphics.frame_rate
      player_info="info|"+name+"|"+age.to_s+"|"+gender.to_s+"|"+face.to_s+"|"+time.to_s
      send_to_server(player_info)
      return
    # 拒绝请求
    elsif request == "disagree"
      show_text($data_text.disagree_marry)
      @marry_step = 3
      return
    # 同意请求
    elsif request["user_agree"] == "user_agree"
      marry_info = request.split("|")
      @actor.marry_name = marry_info[1]
      @actor.marry = marry_info[5].to_i + 1
      @actor.marry_crc = [marry_info[1],marry_info[2].to_i,marry_info[3].to_i,
                          marry_info[4].to_i]
      text = $data_text.agree_marry[0].deep_clone
      text.gsub!("name",marry_info[1])
      show_text(text)
      @marry_step = 3
      send_to_server("success")
      $game_temp.write_save_data
      return
    # 性别相同
    elsif request == "same_gender"
      @marry_step = 3
      show_text($data_text.gender_error)
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新求婚信息
  #--------------------------------------------------------------------------
  def update_get_marry_info
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      show_text($data_text.net_error[4])
      @marry_step = 3
      return
    end
    # 检查求婚方信息
    if @player_info.nil?
      request_player_info
    else
      name = @player_info[1]
      age = @player_info[2]
      gender = @player_info[3]
      face_arr = [$data_system.boy_face,$data_system.girl_face]
      face_id = gender.to_i
      # 求婚方是？性，根据自身性别获取异性描述
      if face_id == 2
        face_id = (@actor.gender + 1) % 2
      end
      face = face_arr[face_id][@player_info[4].to_i]
      text = $data_text.recieve_marry.dup
      text.gsub!("name",name)
      text.gsub!("age",age)
      text.gsub!("gender",$data_text.gender[gender.to_i])
      text.gsub!("face",face)
      show_text(text)
      @confirm_window.visible = true
      @confirm_window.active = true
      @marry_step = 7
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新求婚确认信息
  #--------------------------------------------------------------------------
  def update_marry_decision
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      @confirm_window.visible = false
      @confirm_window.active = false
      send_disagree
      return
    end
    # 按下 C 键的情况
    if Input.trigger?(Input::C)
      @confirm_window.visible = false
      @confirm_window.active = false
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      case @confirm_window.index
      when 0
        calc_crc32
        msg="user_agree|"+@p_marry[0]+"|"+@p_marry[1].to_s+"|"+
            @p_marry[2].to_s+"|"+@p_marry[3].to_s+"|"+@actor.gender.to_s
        send_to_client(msg)
        # 收到成功信息
        if wait_success_msg
          # 保存对象信息并存档
          @actor.marry = @player_info[3].to_i + 1
          @actor.marry_name = @self_marry[0]
          @actor.marry_crc = @self_marry
          $game_temp.write_save_data
          show_text($data_text.agree_marry[1])
          @marry_step = 3
        else
          show_text($data_text.net_error[3])
          @marry_step = 3
        end
      when 1
        send_disagree
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 等待对方离婚回应
  #--------------------------------------------------------------------------
  def update_wait_divorce
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
    when "agree_divorce" # 同意离婚
      @actor.marry_crc = nil
      @actor.marry = 0
      @actor.marry_name = ""
      $game_temp.write_save_data
      send_to_server("success")
      show_text($data_text.agree_divorce)
      @marry_step = 3
    when "disagree" # 不同意离婚
      show_text($data_text.disagree_divorce)
      @marry_step = 3
    when "error_player" # 联机双方非夫妻
      show_text($data_text.couple_no_match)
      @marry_step = 3
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新离婚信息
  #--------------------------------------------------------------------------
  def update_get_divorce_info
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      show_text($data_text.net_error[4])
      @marry_step = 3
      return
    end
    if @player_crc.nil?
      request_player_crc
    else
      show_text($data_text.recieve_divorce)
      @confirm_window.visible = true
      @confirm_window.active = true
      @marry_step = 10
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新离婚确认信息
  #--------------------------------------------------------------------------
  def update_divorce_decision
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      @confirm_window.visible = false
      @confirm_window.active = false
      send_disagree
      return
    end
    # 按下 C 键的情况
    if Input.trigger?(Input::C)
      @confirm_window.visible = false
      @confirm_window.active = false
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      case @confirm_window.index
      when 0
        send_to_client("agree_divorce")
        if wait_success_msg # 成功离婚
          @actor.marry_crc = nil
          @actor.marry = 0
          @actor.marry_name = ""
          $game_temp.write_save_data
          show_text($data_text.agree_divorce)
          @marry_step = 3
        else
          show_text($data_text.net_error[3])
          @marry_step = 3
        end
      when 1
        send_disagree
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 等待成功信息
  #--------------------------------------------------------------------------
  def wait_success_msg
    n = false
    for i in 0..800
      Graphics.update
      if recieve_from_client == "success"
        n = true
        break
      end
    end
    return n
  end
  #--------------------------------------------------------------------------
  # ● 验证联机双方是否未夫妻
  #--------------------------------------------------------------------------
  def request_player_crc
    # 接收crc加密信息
    msg = recieve_from_client
    if msg["player_crc"] == "player_crc"
      # 验证是否夫妻
      @player_crc=msg.split("|")
      crc=Zlib.crc32(@player_crc[1],@player_crc[2].to_i)
      if crc != @actor.marry_crc[1]
        show_text($data_text.couple_no_match)
        @marry_step = 3
        send_to_client("error_player")
        return
      end
    else
      @player_crc = nil
      send_to_client("request_player_crc")
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成加密信息
  #--------------------------------------------------------------------------
  def calc_crc32
    self_key=Graphics.frame_count/Graphics.frame_rate+634488405
    name_crc=Zlib.crc32(@actor.name,1277298667)
    self_crc=Zlib.crc32(name_crc.to_s,self_key)
    pname_crc=Zlib.crc32(@player_info[1],1277298667)
    p_crc=Zlib.crc32(pname_crc.to_s,@player_info[5].to_i+634488405)
    @self_marry=[@player_info[1],p_crc,name_crc,self_key]
    @p_marry=[@actor.name,self_crc,pname_crc,@player_info[5].to_i+634488405]
  end
  #--------------------------------------------------------------------------
  # ● 发送拒绝信息
  #--------------------------------------------------------------------------
  def send_disagree
    @marry_step = 3
    send_to_client("disagree")
    show_text($data_text.disagree_quest)
  end
  #--------------------------------------------------------------------------
  # ● 获取求婚信息
  #--------------------------------------------------------------------------
  def request_player_info
    msg = recieve_from_client
    if msg["info"] == "info"
      @player_info = msg.split("|")
      gender = @player_info[3]
      # 性别相同的情况
      if gender.to_i == @actor.gender
        @marry_step = 3
        show_text($data_text.gender_error)
        send_to_client("same_gender")
        return
      end
    else # 发送获取信息需求
      @player_info = nil
      send_to_client("request_player_info")
    end
  end
  #--------------------------------------------------------------------------
  # ● 结束联机
  #--------------------------------------------------------------------------
  def close_connect
    # 若为客户端
    unless @client_sock.nil?
      Win32API.new("ws2_32","closesocket","p","v").call(@client_sock)
      @client_sock=nil
    end
    # 若为服务端
    unless @server_sock.nil?
      Win32API.new("ws2_32","closesocket","p","v").call(@server_sock)
      @server_sock=nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 检查IP地址格式
  #--------------------------------------------------------------------------
  def check_ip(str_ip)
    check_char = "0123456789.".scan(/./)
    dot_num = 0
    n = true
    for char in str_ip.scan(/./)
      dot_num += 1 if char == "."
      # 检查是否包含非数字及小数点
      if !check_char.include?(char)
        n = false
        break
      end
    end
    return n if not n
    # 是否包含三个点
    if dot_num != 3
      return false
    end
    # 按.分割，是否包含四组
    g_char = str_ip.split(/\./)
    if g_char.size != 4
      return false
    end
    # 检查每组数字范围
    for i in g_char
      if i.to_i < 0 or i.to_i > 255
        n = false
        break
      end
    end
    return n
  end
  #--------------------------------------------------------------------------
  # ● 输入文本
  #--------------------------------------------------------------------------
  def input_text
    # 输入文本
    text_thread = Thread.new{$game_system.input_text}
    text_thread.exit
    @i_text = $game_system.output_text
    $game_system.clear_input
  end
end