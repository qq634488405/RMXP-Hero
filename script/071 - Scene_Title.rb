#==============================================================================
# ■ Scene_Title
#------------------------------------------------------------------------------
# 　处理标题画面的类。
#==============================================================================

class Scene_Title
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
    if FileTest.exist?("Data/GmudData.dat")
      load_gmud_data
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
      print("数据库丢失，请重新安装游戏。")
      $scene = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 读取数据库文件
  #--------------------------------------------------------------------------
  def load_gmud_data
    file = File.open("Data/GmudData.dat","rb")
    # 读取数据字串
    data = Marshal.load(file)
    crcs = Marshal.load(file)
    # 数据校验
    key = 9527
    data.each_index do |i|
      key = Zlib.crc32(data[i],key)
      unless crcs[i] == key
        file.close
        print("数据库损坏，请重新安装！")
        $scene = nil
      end
    end
    file.close
    # 解压数据
    $data_kungfus = Marshal.load(Zlib::Inflate.inflate(data[0]))
    $data_skills  = Marshal.load(Zlib::Inflate.inflate(data[1]))
    $data_system  = Marshal.load(Zlib::Inflate.inflate(data[2]))
    $data_items   = Marshal.load(Zlib::Inflate.inflate(data[3]))
    $data_weapons = Marshal.load(Zlib::Inflate.inflate(data[4]))
    $data_armors  = Marshal.load(Zlib::Inflate.inflate(data[5]))
    $data_enemies = Marshal.load(Zlib::Inflate.inflate(data[6]))
    $data_tasks   = Marshal.load(Zlib::Inflate.inflate(data[7]))
    $data_text    = Marshal.load(Zlib::Inflate.inflate(data[8]))
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
      @next_step=true
      # 作弊模式开启
      @cheat_mode=true if @password==$data_system.cheat_code
      return
    end
    print($data_system.error_pas)
    @next_step=false
  end
  #--------------------------------------------------------------------------
  # ● 读取存档文件
  #--------------------------------------------------------------------------
  def load_gmud_save
    file = File.open("Save/Gmud.sav","rb")
    # 读取描绘存档文件用的角色数据
    characters = Marshal.load(file)
    # 读取测量游戏时间用画面计数
    Graphics.frame_count = Marshal.load(file)
    # 读取密码
    $word = Marshal.load(file)
    @password = ""
    # 播放密码输入BGM
    $game_system.bgm_play($data_system.password_bgm)
    # 创建输入密码窗口
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.picture("BG.png")
    @pass_window=Window_Command.new(320,$data_system.input_pas,1)
    @pass_window.x = 320 - @pass_window.width / 2
    @pass_window.y = 240 - @pass_window.height / 2
    @next_step=false
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
      if @next_step or $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放密码窗口
    @pass_window.dispose
    # 释放密码窗口图形
    @sprite.bitmap.dispose
    @sprite.dispose
    # 读取数据字串
    data = Marshal.load(file)
    crcs = Marshal.load(file)
    # 数据校验
    key = 1313
    data.each_index do |i|
      key = Zlib.crc32(data[i],key)
      unless crcs[i] == key
        file.close
        # 删除异常存档
        File.delete("Save/Gmud.sav")
        print($data_system.error_save)
        $scene=Scene_Scroll.new(1)
      end
    end
    file.close
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
    $game_actor.unequip_all
    $game_actor.check_item_bag
    $game_actor.check_stone_list
    # 设置系统默认字体
    Font.default_name = (["WQX12","宋体","黑体","楷体"])
    # 设置铸造武器属性
    $game_actor.set_sword
    # 初始化任务
    $game_task = Game_Task.new
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
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
  end
end
