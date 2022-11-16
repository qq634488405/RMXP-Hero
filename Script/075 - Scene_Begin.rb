#==============================================================================
# ■ Scene_Begin
#------------------------------------------------------------------------------
# 　处理标题画面的类。
#==============================================================================

class Scene_Begin
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    # 战斗测试的情况下（退出）
    if $BTEST
      exit
      return
    end
    # 载入数据库
    $data_actors        = load_data("Data/Actors.rxdata")
    $data_classes       = load_data("Data/Classes.rxdata")
    $data_troops        = load_data("Data/Troops.rxdata")
    $data_states        = load_data("Data/States.rxdata")
    $data_animations    = load_data("Data/Animations.rxdata")
    $data_tilesets      = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")
    $data_mapinfos      = load_data("Data/MapInfos.rxdata")
    # 载入数据库
    result = load_gmud_data
    if result[0]
      $game_system=Game_System.new
      # 载入存档
      if FileTest.exist?("Save/Gmud.sav")
        # 读取存档
        load_gmud_save
        # 还原 BGM、BGS
        $game_map.autoplay
        # 刷新地图 (执行并行事件)
        $game_map.update
        $eat_flag = true
        $scene=Scene_Map.new
      else
        # 存档不存在则新游戏
        $scene=Scene_Scroll.new(1)
      end
    else
      print(result[1])
      $scene = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 读取数据库文件
  #--------------------------------------------------------------------------
  def load_gmud_data
    # 设置数据库文件列表
    file_list = $data_system.file_list
    npc_file = ["Data/GmudEnemy.dat","Data/GmudEnemyPlus.dat"]
    file_list[5] = npc_file[$npc_plus]
    # 检查文件是否存在，存在则读取
    data,crcs,result = [],[],[true]
    file_list.each do |i|
      if FileTest.exist?(i)
        file = File.open(i,"rb")
        # 读取数据字串
        data.push(Marshal.load(file))
        crcs.push(Marshal.load(file))
        file.close
      else
        result = [false,"数据库丢失，请重新下载游戏。"]
        break
      end
    end
    # 检查文件存在标志
    return result unless result[0]
    # 数据校验
    key = 9527
    data.each_index do |i|
      unless crcs[i] == Zlib.crc32(data[i],key)
        result=[false,"数据库损坏，请重新下载！"]
        break
      end
    end
    # 检查数据校验结果
    return result unless result[0]
    # 解压数据
    $data_kungfus = Marshal.load(Zlib::Inflate.inflate(data[0]))
    $data_skills  = Marshal.load(Zlib::Inflate.inflate(data[1]))
    $data_items   = Marshal.load(Zlib::Inflate.inflate(data[2]))
    $data_weapons = Marshal.load(Zlib::Inflate.inflate(data[3]))
    $data_armors  = Marshal.load(Zlib::Inflate.inflate(data[4]))
    $data_enemies = Marshal.load(Zlib::Inflate.inflate(data[5]))
    $data_tasks   = Marshal.load(Zlib::Inflate.inflate(data[6]))
    return [true]
  end
  #--------------------------------------------------------------------------
  # ● 输入密码
  #--------------------------------------------------------------------------
  def input_password
    # 输入密码
    text_thread=Thread.new{$game_system.input_text}
    text_thread.exit
    @password = $game_system.output_text
    $game_system.clear_input
  end
  #--------------------------------------------------------------------------
  # ● 检查密码
  #--------------------------------------------------------------------------
  def check_password
    @cheat_mode = false
    # 密码正确或为作弊密码则进入下一步
    if @password==$word or @password==$data_system.cheat_code or ($word==nil and @password=="")
      @start_step = 2
      # 作弊模式开启
      @cheat_mode=true if @password==$data_system.cheat_code
      # 读取数据字串
      data = Marshal.load(@file)
      crcs = Marshal.load(@file)
      # 数据校验
      key = 1313
      data.each_index do |i|
        key = Zlib.crc32(data[i],key)
        unless crcs[i] == key
          @file.close
          # 删除异常存档
          File.delete("Save/Gmud.sav")
          print($data_system.error_save)
          $scene=Scene_Scroll.new(1)
          return
        end
      end
      @file.close
      init_save_data(data)
      return
    end
    print($data_system.error_pas)
    @start_step = 0
  end
  #--------------------------------------------------------------------------
  # ● 检查武器名字
  #--------------------------------------------------------------------------
  def check_sword_name
    # 检查武器名长度
    if @password == "" or @password.new_size > 8
      print($data_system.name_error)
      return
    end
    # 检查是否与现有武器重名
    next_step = true
    for i in 1..30
      if @password == $data_weapons[i].name
        next_step = false
        break
      end
    end
    # 没有重名
    if next_step
      @start_step = 2
      $game_actor.sword_name = @password
      $game_actor.input_name = false
      $game_actor.gain_item(2,31)
      # 设置铸造武器属性
      $game_actor.set_sword
      $game_temp.write_save_data
    else
      print($data_system.name_error)
    end
  end
  #--------------------------------------------------------------------------
  # ● 读取存档文件
  #--------------------------------------------------------------------------
  def load_gmud_save
    @file = File.open("Save/Gmud.sav","rb")
    # 读取描绘存档文件用的角色数据
    characters = Marshal.load(@file)
    # 读取测量游戏时间用画面计数
    Graphics.frame_count = Marshal.load(@file)
    # 读取密码
    $word = Marshal.load(@file)
    @password = ""
    # 播放密码输入BGM
    $game_system.bgm_play($data_system.password_bgm)
    # 创建输入密码窗口
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.picture("BG.png")
    @pass_window=Window_Command.new(320,$data_system.input_pas,1)
    @pass_window.x = 320 - @pass_window.width / 2
    @pass_window.y = 240 - @pass_window.height / 2
    @start_step = 0
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果画面被切换就中断循环
      if @start_step == 2 or $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放密码窗口
    @pass_window.dispose
    @weapon_title.dispose if @weapon_title != nil
    # 释放密码窗口图形
    @sprite.bitmap.dispose
    @sprite.dispose
    # 设置系统默认字体
    Font.default_name = (["WQX12","宋体","黑体","楷体"])
    # 初始化任务
    $game_task = Game_Task.new
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    case @start_step
    when 0 # 输入密码
      # 根据密码内容更改显示
      if @password != ""
        @pass_window.change_item(0,$data_system.have_pas)
      else
        @pass_window.change_item(0,$data_system.no_pas)
      end
      # 刷新命令窗口
      @pass_window.update
      # 按下 C 键的情况下
      if Input.trigger?(Input::C)
        # 播放决定SE
        $game_system.se_play($data_system.decision_se)
        # 命令窗口的光标位置的分支
        case @pass_window.index
        when 0  # 输入密码
          input_password
        when 1  # 确认
          check_password
        end
      end
    when 1 # 输入武器名字
      # 刷新命令窗口
      @pass_window.update
      @weapon_title.update
      if @password != ""
        text = $data_system.set_weapon_name[0].deep_clone
        text.gsub!("------",@password)
        @pass_window.change_item(0,text)
      else
        @pass_window.change_item(0,$data_system.set_weapon_name[0])
      end
      if Input.trigger?(Input::C)
        # 播放决定SE
        $game_system.se_play($data_system.decision_se)
        # 命令窗口的光标位置的分支
        case @pass_window.index
        when 0  # 输入武器名字
          input_password
        when 1  # 确认
          check_sword_name
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 初始化游戏
  #--------------------------------------------------------------------------
  def init_save_data(data)
    # 读取各种游戏对象
    $game_system        = Marshal.load(Zlib::Inflate.inflate(data[0]))
    $game_self_switches = Marshal.load(Zlib::Inflate.inflate(data[1]))
    $game_screen        = Marshal.load(Zlib::Inflate.inflate(data[2]))
    $game_actor         = Marshal.load(Zlib::Inflate.inflate(data[3]))
    $game_party         = Marshal.load(Zlib::Inflate.inflate(data[4]))
    $game_troop         = Marshal.load(Zlib::Inflate.inflate(data[5]))
    $game_map           = Marshal.load(Zlib::Inflate.inflate(data[6]))
    $game_player        = Marshal.load(Zlib::Inflate.inflate(data[7]))
    # 设置游戏对象
    $game_temp          = Game_Temp.new
    $game_temp.cheat_mode = @cheat_mode
    # 设置玩家位置到家中
    $game_map.setup($data_system.start_map_id)
    # 主角向初期位置移动
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    # 设定主角朝下站立
    $game_player.turn_down
    $game_player.straighten
    # 卸下所有装备
    $game_actor.unequip_all if $keep_equip == 0
    $game_actor.check_item_bag
    $game_actor.check_stone_list
    # 兼容旧版存档
    if $game_actor.jiaju_list == nil
      $game_actor.jiaju_list = [0,0,0,0,0]
    end
    if $game_actor.couple_kf_list == nil
      $game_actor.couple_kf_list = []
    end
    if $game_actor.room_level == nil
      $game_actor.room_level = $game_actor.have_new_home ? 1 : 0
    end
    # 需要输入武器名字的情况且背包可获得武器
    if $game_actor.input_name and $game_actor.can_get_item?(2,31)
      @start_step = 1
      @password = ""
      @weapon_title = Sprite_Text.new
      x = @pass_window.x + (320 - $data_system.weapon_title.new_size * 12)/2
      y = @pass_window.y - 32
      @weapon_title.set_up(x,y,$data_system.weapon_title)
      # 更新窗口命令
      @pass_window.change_item(0,$data_system.set_weapon_name[0])
      @pass_window.change_item(1,$data_system.set_weapon_name[1])
      @pass_window.index = 0
    else
      # 设置铸造武器属性
      $game_actor.set_sword
    end
  end
end
