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
    # 检查配置文件是否存在
    unless FileTest.exist?("GmudConfig")
      create_config
    end
    # 检查配置说明文件是否存在
    unless FileTest.exist?("Data/GmudConfig.dat")
      print("数据库丢失，请重新下载游戏。")
      $scene = nil
    end
    # 读取配置文件及核心数据库文件
    load_config
    load_core_data
    $game_system=Game_System.new
    # 生成标题图形
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.title(@title_name)
    # 生成选项窗口
    @command_window = Window_Command.new(192,@title_menu,1,7)
    @command_window.x = 320 - @command_window.width / 2
    @command_window.y = 288
    @command_window.active = true
    @phase = 1
    # 演奏标题 BGM
    $game_system.bgm_play(@title_bgm)
    # 停止演奏 ME、BGS
    Audio.me_stop
    Audio.bgs_stop
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
      if $scene != self
        break
      end
    end
    # 装备过渡
    Graphics.freeze
    # 释放命令窗口
    @command_window.dispose
    # 释放标题图形
    @sprite.bitmap.dispose
    @sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新窗口
    case @phase
    when 1 # 刷新命令窗口
      update_command_window
    when 2 # 刷新设置窗口
      update_config_window
    when 3 # 刷新关于窗口
      update_about_window
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新命令窗口
  #--------------------------------------------------------------------------
  def update_command_window
    # 刷新命令窗口
    @command_window.visible = true
    @command_window.active = true
    @command_window.update
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 命令窗口的光标位置的分支
      case @command_window.index
      when 0  # 开始游戏
        $scene = Scene_Begin.new
      when 1  # 游戏设置
        command_config
      when 2  # 关于游戏
        command_about
      when 3  # 退出游戏
        command_exit
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新配置窗口
  #--------------------------------------------------------------------------
  def update_config_window
    # 刷新配置窗口
    @config_window.update
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      @help_window.dispose
      @config_window.dispose
      @phase = 1
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      case @config_window.index
      when 6 # 恢复默认
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        @config_window.set_data = [0,0,0,0,0,0,0,0]
      when 7 # 保存设定
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 读取选项设定并设置变量
        set_data = @config_window.get_set_data
        $color_mode,$battle_info = set_data[0],set_data[1]
        $keep_equip,$fly_in = set_data[2],set_data[3]
        $npc_plus,$fast_mode = set_data[4],set_data[5]
        @help_window.dispose
        @config_window.dispose
        @phase = 1
        # 保存设置
        save_config
      else
        # 演奏光标移动 SE，变更设定
        $game_system.se_play($data_system.cursor_se)
        @config_window.update_set_data(1)
      end
    end
    # 按下 左 键且非恢复默认和保存的情况下
    if Input.trigger?(Input::LEFT) and @config_window.index < @config_set.size-2
      # 演奏光标移动 SE，变更设定
      $game_system.se_play($data_system.cursor_se)
      @config_window.update_set_data(2)
    end
    # 按下 左 键且非恢复默认和保存的情况下
    if Input.trigger?(Input::RIGHT) and @config_window.index < @config_set.size-2
      # 演奏光标移动 SE，变更设定
      $game_system.se_play($data_system.cursor_se)
      @config_window.update_set_data(1)
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新关于窗口
  #--------------------------------------------------------------------------
  def update_about_window
    @about_window.update
    # 按下 B 或 C 键的情况下
    if Input.trigger?(Input::B) or Input.trigger?(Input::C)
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 释放窗口，激活命令窗口
      @about_window.dispose
      @phase = 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 命令 : 设置
  #--------------------------------------------------------------------------
  def command_config
    @phase = 2
    @set_data = [$color_mode,$battle_info,$keep_equip,$fly_in,$npc_plus,$fast_mode,0,0]
    # 隐藏命令窗口
    @command_window.visible = false
    @command_window.active = false
    @config_window = Window_Config.new(@title_menu[1],@config_set,@config_data,@config_help,@set_data)
    @help_window = Window_Help.new(480,96)
    @help_window.x,@help_window.y = 80,352
    @config_window.help_window = @help_window
  end
  #--------------------------------------------------------------------------
  # ● 命令 : 退出
  #--------------------------------------------------------------------------
  def command_about
    @phase = 3
    # 隐藏命令窗口
    @command_window.visible = false
    @command_window.active = false
    @about_window = Window_Base.new(32,48,576,384)
    @about_window.auto_text(@credit_text.dup)
  end
  #--------------------------------------------------------------------------
  # ● 命令 : 退出
  #--------------------------------------------------------------------------
  def command_exit
    # 演奏确定 SE
    $game_system.se_play($data_system.decision_se)
    # BGM、BGS、ME 的淡入淡出
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # 退出
    $scene = nil
  end
  #--------------------------------------------------------------------------
  # ● 创建配置文件
  #--------------------------------------------------------------------------
  def create_config
    # 新建配置文件并写入初始设定
    $color_mode,$battle_info,$keep_equip = 0,0,0
    $fly_in,$npc_plus,$fast_mode = 0,0,0
    save_config
  end
  #--------------------------------------------------------------------------
  # ● 保存配置文件
  #--------------------------------------------------------------------------
  def save_config
    file = File.open("GmudConfig","wb")
    Marshal.dump($color_mode, file)
    Marshal.dump($battle_info, file)
    Marshal.dump($keep_equip, file)
    Marshal.dump($fly_in, file)
    Marshal.dump($npc_plus, file)
    Marshal.dump($fast_mode, file)
    file.close
  end
  #--------------------------------------------------------------------------
  # ● 读取配置文件
  #--------------------------------------------------------------------------
  def load_config
    # 读取设置选项
    file = File.open("GmudConfig","rb")
    $color_mode  = Marshal.load(file)
    $battle_info = Marshal.load(file)
    $keep_equip  = Marshal.load(file)
    $fly_in      = Marshal.load(file)
    $npc_plus    = Marshal.load(file)
    $fast_mode   = Marshal.load(file)
    file.close
    # 读取选项说明
    file = File.open("Data/GmudConfig.dat","rb")
    @title_menu  = Marshal.load(file)
    @title_name  = Marshal.load(file)
    @title_bgm   = Marshal.load(file)
    @config_set  = Marshal.load(file)
    @config_data = Marshal.load(file)
    @config_help = Marshal.load(file)
    @credit_text = Marshal.load(file)
    file.close
  end
  #--------------------------------------------------------------------------
  # ● 读取数据库文件
  #--------------------------------------------------------------------------
  def load_core_data
    # 检查核心数据库是否存在
    unless FileTest.exist?("Data/GmudCore.dat")
      print("数据库丢失，请重新下载游戏。")
      $scene = nil
      return
    end
    file = File.open("Data/GmudCore.dat","rb")
    # 读取数据字串
    data = Marshal.load(file)
    crcs = Marshal.load(file)
    # 数据校验
    key = 9527
    data.each_index do |i|
      unless crcs[i] == Zlib.crc32(data[i],key)
        file.close
        print("数据库损坏，请重新安装！")
        $scene = nil
      end
    end
    file.close
    # 解压数据
    $data_system  = Marshal.load(Zlib::Inflate.inflate(data[0]))
    $data_text    = Marshal.load(Zlib::Inflate.inflate(data[1]))
  end
end