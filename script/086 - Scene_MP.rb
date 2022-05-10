#==============================================================================
# ■ Scene_MP
#------------------------------------------------------------------------------
# 　处理法力画面的类。
#==============================================================================

class Scene_MP
  #--------------------------------------------------------------------------
  # ● 初始化
  #--------------------------------------------------------------------------
  def initialize
    @actor = $game_actor
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    @screen = Spriteset_Map.new
    # 生成对话窗口
    @talk_window = Window_Help.new(480,160)
    @talk_window.visible=false
    @talk_window.x=80
    @talk_window.y=304
    # 生成地图名活动块
    @map_name = Sprite_Text.new
    @map_name.set_up(0,0,$game_map.map_name)
    # 生成法力菜单
    @mp_menu = Window_Command.new(128,$data_system.mp_menu,1,1)
    @mp_menu.x,@mp_menu.y = 481,74
    # 生成面板窗口
    @info = Window_Base.new(160,10,352,64)
    @info.visible = false
    @phase = 1
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
      # 如果切换画面就中断循环
      if $scene != self
        break
      end
    end
    $eat_flag = true
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @talk_window.dispose
    @map_name.dispose
    @mp_menu.dispose
    @info.dispose
    @screen.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新命令窗口
    @mp_menu.update
    @talk_window.update
    @map_name.update
    @info.update
    case @phase
    when 1 # 刷新命令窗口
      $eat_flag = true
      update_command
    when 2 # 冥思
      get_maxmp
    when 3 # 法点
      set_mp_plus
    end
    @screen.update
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (命令窗口被激活的情况下)
  #--------------------------------------------------------------------------
  def update_command
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Map.new
      return
    end
    # 按下 C 键的情况
    if Input.trigger?(Input::C)
      # 没有装备法术
      if @actor.mp_kf_id < 12
        # 播放冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        draw_error($data_text.no_fashu)
        return
      end
      # 播放确认 SE
      $game_system.se_play($data_system.decision_se)
      case @mp_menu.index
      when 0 # 冥思
        $eat_flag = false
        @phase = 2
      when 1 # 法点
        # 生成法点窗口
        @mp_plus_menu = Window_InputNumber.new(3)
        @mp_plus_menu.x,@mp_plus_menu.y = 320,96
        @mp_plus_menu.opacity,@mp_plus_menu.back_opacity = 255,255
        @mp_plus_menu.number = @actor.mp_plus
        @mp_plus_menu.visible = false
        @phase = 3
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘出错信息
  #--------------------------------------------------------------------------
  def draw_error(text,time=Graphics.frame_rate)
    @talk_window.auto_text(text.dup)
    @talk_window.visible = true
    for i in 0..time
      # 刷新画面
      Graphics.update
    end
    @talk_window.visible=false
  end
  #--------------------------------------------------------------------------
  # ● 冥思
  #--------------------------------------------------------------------------
  def get_maxmp
    # 按下 B 的情况
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      return_mp_menu
      return
    end
    # 调整帧率
    Graphics.frame_rate = 120
    # 计算冥思速率
    speed = @actor.mp_kf_lv/10 +@actor.bon/5
    # 法力增加
    @actor.mp += speed
    mpmax = [[@actor.maxmp * 2,65535].min,1].max
    process = [200*@actor.mp/mpmax,200].min
    @info.visible = true
    # 描绘进度
    draw_process(process)
    # 法力满
    if @actor.mp > mpmax
      @actor.maxmp += 1
      # 法术等级不足
      if @actor.maxmp > @actor.full_mp
        @actor.maxmp -= 1
        @actor.mp = @actor.maxmp
        draw_error($data_text.no_fa_lv)
        return_mp_menu
        return
      end
      @actor.mp = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘进度
  #--------------------------------------------------------------------------
  def draw_process(process)
    # 根据显示内容调整宽度
    text = @actor.mp.to_s+"/"+@actor.maxmp.to_s
    @info.width = 248 + text.size * 12
    @info.contents = Bitmap.new(@info.width - 32,@info.height - 32)
    color = @info.normal_color
    @info.contents.font.color = color 
    @info.contents.clear
    #边框
    @info.contents.fill_rect(5,9,200,1,color)
    @info.contents.fill_rect(5,24,200,1,color)
    @info.contents.fill_rect(5,9,1,15,color)
    @info.contents.fill_rect(205,9,1,16,color)
    #进度条
    @info.contents.fill_rect(5,9,process,15,color)
    #点数/等级
    @info.contents.draw_text(216,0,@info.width-248,32,text)
  end
  #--------------------------------------------------------------------------
  # ● 法点
  #--------------------------------------------------------------------------
  def set_mp_plus
    @mp_plus_menu.visible = true
    @mp_plus_menu.active = true
    @mp_plus_menu.update
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @mp_plus_menu.dispose
      return_mp_menu
      return
    end
    # 按下 C 键的情况
    if Input.trigger?(Input::C)
      # 播放确认 SE
      $game_system.se_play($data_system.decision_se)
      @actor.mp_plus = @mp_plus_menu.number
      mpp_max = @actor.mp_kf_lv/2
      if @actor.mp_plus >= mpp_max
        @actor.mp_plus = mpp_max
        text = $data_text.mp_plus_max.dup
        text.gsub!("mp_plus",mpp_max.to_s)
        draw_error(text)
      end
      @mp_plus_menu.dispose
      return_mp_menu
    end
  end
  #--------------------------------------------------------------------------
  # ● 返回法力菜单
  #--------------------------------------------------------------------------
  def return_mp_menu
    @mp_menu.visible = true
    @mp_menu.active = true
    @info.visible = false
    @talk_window.visible=false
    # 恢复帧率
    Graphics.frame_rate = 40
    @phase = 1
  end
end