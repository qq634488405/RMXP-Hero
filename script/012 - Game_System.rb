#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# 　处理系统附属数据的类。也可执行诸如 BGM 管理之类的功能。本类的实例请参考
# $game_system 。
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :map_interpreter          # 地图事件用解释程序
  attr_reader   :battle_interpreter       # 战斗事件用解释程序
  attr_accessor :timer                    # 计时器
  attr_accessor :timer_working            # 计时器执行中的标志
  attr_accessor :save_disabled            # 禁止存档
  attr_accessor :menu_disabled            # 禁止菜单
  attr_accessor :encounter_disabled       # 禁止遇敌
  attr_accessor :message_position         # 文章选项 显示位置
  attr_accessor :message_frame            # 文章选项 窗口外关
  attr_accessor :save_count               # 存档次数
  attr_accessor :magic_number             # 魔法编号
  attr_accessor :output_text              # 输出文本
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    @map_interpreter = Interpreter.new(0, true)
    @battle_interpreter = Interpreter.new(0, false)
    @timer = 0
    @timer_working = false
    @save_disabled = false
    @menu_disabled = false
    @encounter_disabled = false
    @message_position = 2
    @message_frame = 0
    @save_count = 0
    @magic_number = 0
    @output_text = ""
  end
  #--------------------------------------------------------------------------
  # ● 随机BGM/BGS/ME/SE
  #--------------------------------------------------------------------------
  def random_audio(audio_file,type)
    return nil if audio_file == nil or audio_file.name == ""
    # 设置路径
    dirs = ["BGM","BGS","ME","SE"]
    full_dir = "Audio/" + dirs[type]
    # 设置文件类型
    case type
    when 0,2 # BGM/ME
      file_type = ["mp3","mid","ogg","wav","wma"]
    when 1,3 # BGS/SE
      file_type = ["mp3","ogg","wav","wma"]
    end
    # 获取所有文件
    all_file = Dir::entries(full_dir)
    return nil if all_file.empty?
    file_list = []
    # 筛选包含该场景名的文件
    name = audio_file.name.dup.split(".")
    return nil if name == nil
    all_file.each do |i|
      i_data = i.dup.split(".")
      next if i_data[1] == nil
      if i[0,name[0].length] == name[0] and file_type.include?(i_data[1].downcase)
        file_list.push(i)
      end
    end
    # 列表为空返回nil
    return nil if file_list.empty?
    # 随机文件
    id = rand(file_list.size)
    file = RPG::AudioFile.new(file_list[id],100,100)
    return file
  end
  #--------------------------------------------------------------------------
  # ● 演奏 BGM
  #     bgm : 演奏的 BGM
  #--------------------------------------------------------------------------
  def bgm_play(bgm)
    new_bgm = random_audio(bgm,0)
    @playing_bgm = new_bgm
    if new_bgm != nil and new_bgm.name != ""
      Audio.bgm_play("Audio/BGM/" + new_bgm.name, new_bgm.volume, new_bgm.pitch)
    else
      Audio.bgm_stop
    end
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # ● 停止 BGM
  #--------------------------------------------------------------------------
  def bgm_stop
    Audio.bgm_stop
  end
  #--------------------------------------------------------------------------
  # ● BGM 的淡出
  #     time : 淡出时间 (秒)
  #--------------------------------------------------------------------------
  def bgm_fade(time)
    @playing_bgm = nil
    Audio.bgm_fade(time * 1000)
  end
  #--------------------------------------------------------------------------
  # ● 记忆 BGM
  #--------------------------------------------------------------------------
  def bgm_memorize
    @memorized_bgm = @playing_bgm
  end
  #--------------------------------------------------------------------------
  # ● 还原 BGM
  #--------------------------------------------------------------------------
  def bgm_restore
    bgm_play(@memorized_bgm)
  end
  #--------------------------------------------------------------------------
  # ● 演奏 BGS
  #     bgs : 演奏的 BGS
  #--------------------------------------------------------------------------
  def bgs_play(bgs)
    new_bgs = random_audio(bgs,1)
    @playing_bgs = new_bgs
    if new_bgs != nil and new_bgs.name != ""
      Audio.bgs_play("Audio/BGS/" + new_bgs.name, new_bgs.volume, new_bgs.pitch)
    else
      Audio.bgs_stop
    end
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # ● BGS 的淡出
  #     time : 淡出时间 (秒)
  #--------------------------------------------------------------------------
  def bgs_fade(time)
    @playing_bgs = nil
    Audio.bgs_fade(time * 1000)
  end
  #--------------------------------------------------------------------------
  # ● 记忆 BGS
  #--------------------------------------------------------------------------
  def bgs_memorize
    @memorized_bgs = @playing_bgs
  end
  #--------------------------------------------------------------------------
  # ● 还原 BGS
  #--------------------------------------------------------------------------
  def bgs_restore
    bgs_play(@memorized_bgs)
  end
  #--------------------------------------------------------------------------
  # ● ME 的演奏
  #     me : 演奏的 ME
  #--------------------------------------------------------------------------
  def me_play(me)
    new_me = random_audio(me,2)
    if new_me != nil and new_me.name != ""
      Audio.me_play("Audio/ME/" + new_me.name, new_me.volume, new_me.pitch)
    else
      Audio.me_stop
    end
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # ● SE 的演奏
  #     se : 演奏的 SE
  #--------------------------------------------------------------------------
  def se_play(se)
    new_se = random_audio(se,3)
    if new_se != nil and new_se.name != ""
      Audio.se_play("Audio/SE/" + new_se.name, new_se.volume, new_se.pitch)
    end
  end
  #--------------------------------------------------------------------------
  # ● 停止 SE 
  #--------------------------------------------------------------------------
  def se_stop
    Audio.se_stop
  end
  #--------------------------------------------------------------------------
  # ● 获取演奏中 BGM
  #--------------------------------------------------------------------------
  def playing_bgm
    return @playing_bgm
  end
  #--------------------------------------------------------------------------
  # ● 获取演奏中 BGS
  #--------------------------------------------------------------------------
  def playing_bgs
    return @playing_bgs
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口外观的文件名
  #--------------------------------------------------------------------------
  def windowskin_name
    if @windowskin_name == nil
      return $data_system.windowskin_name
    else
      return @windowskin_name
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置窗口外观的文件名
  #     windowskin_name : 新的窗口外观文件名
  #--------------------------------------------------------------------------
  def windowskin_name=(windowskin_name)
    @windowskin_name = windowskin_name
  end
  #--------------------------------------------------------------------------
  # ● 获取战斗 BGM
  #--------------------------------------------------------------------------
  def battle_bgm
    if @battle_bgm == nil
      return $data_system.battle_bgm
    else
      return @battle_bgm
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置战斗 BGM
  #     battle_bgm : 新的战斗 BGM
  #--------------------------------------------------------------------------
  def battle_bgm=(battle_bgm)
    @battle_bgm = battle_bgm
  end
  #--------------------------------------------------------------------------
  # ● 获取战斗结束的 BGM
  #--------------------------------------------------------------------------
  def battle_end_me
    if @battle_end_me == nil
      return $data_system.battle_end_me
    else
      return @battle_end_me
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置战斗结束的 BGM
  #     battle_end_me : 新的战斗结束 BGM
  #--------------------------------------------------------------------------
  def battle_end_me=(battle_end_me)
    @battle_end_me = battle_end_me
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 计时器减 1
    if @timer_working and @timer > 0
      @timer -= 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示RgssInputBox.dll中的输入角色名称的对话框
  #    作者：notexist
  # $NameInputBox = Win32API.new("InputSupport.dll", "NameInputBox", ['P'], 'P')
  # 创建对话框窗口，在调用NameInputBox之前必须调用这个函数
  # $CreateInputBox =  Win32API.new("InputSupport.dll", "CreateInputBox", [], '')
  # 设置窗口，参数分别为宽度，高度，和载入的skin图片是否拉伸
  # 在后面的LoadSkin调用中会根据图片情况自动设置窗口宽度高度
  # 所以不必手工调用这个函数
  # $InputBox_SetBox =  Win32API.new("InputSupport.dll", "SetBox", ['I','I','I'], '')
  # 载入背景图片，内容为图片的文件名（不包括路径）
  # 支持BMP和GIF，载入后会自动设置输入的窗口宽度和高度
  # $InputBox_LoadSkin =  Win32API.new("InputSupport.dll", "LoadSkin", ['P'], '')
  # 设置窗口中文本输入框的位置和大小
  # 参数分别为X偏移(偏移相对于窗口左上角)，Y偏移，宽度，高度
  # 以及输入框底色的蓝色，绿色，红色分量，颜色分量的范围是0～255
  # $InputBox_SetEdit =  Win32API.new("InputSupport.dll", "SetEdit", ['I','I','I','I','I','I','I'], '')
  # 设置文本输入框内输入文字的字体信息
  # 参数分别为字体名称（例如“宋体”），字体大小（五号字为11）
  # 字体颜色的蓝色，绿色，红色分量，颜色分量的范围是0～255
  # $InputBox_SetEditFont =  Win32API.new("InputSupport.dll", "SetEditFont", ['P','I','I','I','I'], '')
  # 释放对话框窗口，理论上创建之后就应该释放，不过游戏退出时应该能自动释放
  # 所以不必手工调用这个函数
  # $FreeInputBox =  Win32API.new("InputSupport.dll", "FreeInputBox", [], '')
  # 创建
  # $CreateInputBox.Call
  # 载入背景图fox.jpg，这时设定了窗口宽度高度
  # $InputBox_LoadSkin.Call('fox.jpg')
  # 设置文本输入框位置，并且设定底色为红色
  # $InputBox_SetEdit.Call(50,20,200,32,0,128,128)
  # 设定输入字体为黑体，字号为12(应该是“小四”)，颜色为白色
  # $InputBox_SetEditFont.Call('宋体',12,255,255,255)
  # 重新设置输入窗口宽度和高度
  # $InputBox_SetBox.Call(300,72,0)
  #--------------------------------------------------------------------------
  def input_text
    Win32API.new("Lib/InputSupport.dll", "CreateInputBox", [], '').call
    Win32API.new("Lib/InputSupport.dll", "SetEdit", ['I','I','I','I','I','I','I'], '').Call(50,20,200,32,87,176,144)
    Win32API.new("Lib/InputSupport.dll", "SetEditFont", ['P','I','I','I','I'], '').call('宋体',12,0,0,0)
    Win32API.new("Lib/InputSupport.dll", "SetBox", ['I','I','I'], '').Call(300,72,0)
    text = Win32API.new("InputSupport.dll", "NameInputBox", ['P'], 'P').call(text)
    @output_text = text
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def clear_input
    @output_text = ""
  end
end
