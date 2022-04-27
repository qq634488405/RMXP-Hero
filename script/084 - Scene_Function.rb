#==============================================================================
# ■ Scene_Function
#------------------------------------------------------------------------------
# 　处理游戏结束画面的类。
#==============================================================================

class Scene_Function
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     index : 命令光标的初期位置
  #--------------------------------------------------------------------------
  def initialize(index = 0)
    $eat_flag = true
    @actor = $game_actor
    @index = index
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    @screen = Spriteset_Map.new
    @main_menu = Window_BackMenu.new(3)
    # 信息窗口
    @info_window = Window_Help.new(320,96)
    @info_window.x,@info_window.y,@info_window.z = 160,160,300
    @info_window.visible = false
    # 提示窗口
    @msg_window = Window_Help.new(152,64)
    @msg_window.x,@msg_window.y,@msg_window.z = 376,128,300
    @msg_window.contents.draw_text(0,0,120,32,$data_text.save_ok,1)
    @msg_window.visible = false
    # 确认窗口
    @confirm = Window_Command.new(240,$data_system.confirm_choice,2,3)
    @confirm.x,@confirm.y,@confirm.z = 200,240,800
    @confirm.visible,@confirm.active = false,false
    # 功能菜单
    @func_window = Window_Command.new(128,$data_system.sys_menu,1,1)
    @func_window.x,@func_window.y = 481,74
    @func_window.index = @index
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
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @main_menu.dispose
    @info_window.dispose
    @msg_window.dispose
    @confirm.dispose
    @func_window.dispose
    @screen.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新命令窗口
    @main_menu.update
    @info_window.update
    @msg_window.update
    @confirm.update
    @func_window.update
    case @phase
    when 1 # 刷新菜单命令
      update_command
    when 2 # 刷新存档
      update_save
    when 3 # 刷新退出确认
      update_exit
    when 4 # 刷新存档确认
      update_confirm
    end
    @screen.update
  end
  #--------------------------------------------------------------------------
  # ● 刷新命令窗口
  #--------------------------------------------------------------------------
  def update_command
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到菜单画面
      $scene = Scene_Menu.new(3)
      return
    end
    # 按下 C 键的场合下
    if Input.trigger?(Input::C)
      # 命令窗口光标位置分支
      case @func_window.index
      when 0 # 内力
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 切换到内力画面
        $scene = Scene_FP.new
      when 1 # 法力
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 切换到法力画面
        $scene = Scene_MP.new
      when 2 # 练功
        # 判断是否存在可以练功的武功
        if @actor.practice_list.size > 0
          # 演奏确定 SE
          $game_system.se_play($data_system.decision_se)
          # 切换到练功画面
          $scene = Scene_Practice.new
        else
          # 演奏无效 SE
          $game_system.se_play($data_system.buzzer_se)
        end
      when 3 # 存档
        # 禁止存档的情况下
        if $game_system.save_disabled
          # 演奏冻结 SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 存档
        $game_temp.write_save_data
        @phase = 2
        @msg_window.visible=true
        # 演奏存档 SE
        $game_system.se_play($data_system.save_se)
      when 4 # 结束
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        text = $data_text.quit_ask.dup
        @info_window.auto_text(text)
        @info_window.visible=true
        @func_window.active=false
        @confirm.visible=true
        @confirm.active=true
        @phase = 3
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新存档成功
  #--------------------------------------------------------------------------
  def update_save
    # 按下 C 键的情况
    if Input.trigger?(Input::C) or Input.trigger?(Input::B)
      # 返回菜单
      $scene=Scene_Menu.new(3)
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新退出
  #--------------------------------------------------------------------------
  def update_exit
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到菜单画面
      @info_window.visible=false
      @func_window.active=true
      @confirm.visible=false
      @confirm.active=false
      @phase = 1
      return
    end
    # 按下 C 键的场合下
    if Input.trigger?(Input::C)
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      case @confirm.index
      when 0
        time=Graphics.frame_count/Graphics.frame_rate
        # 存档间隔超过5分钟的情况
        if time-$game_temp.save_time>300
          text = $data_text.save_ask.dup
          @info_window.auto_text(text)
          @confirm.visible=true
          @confirm.active=true
          @confirm.index=0
          @phase = 4
          return
        end
        end_game
      when 1
        @info_window.visible=false
        @confirm.visible=false
        @confirm.active=false
        # 切换到菜单画面
        $scene = Scene_Menu.new(3)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 确认保存
  #--------------------------------------------------------------------------
  def update_confirm
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      @phase = 1
      # 切换到菜单画面
      @info_window.visible=false
      @func_window.active=true
      @confirm.visible=false
      @confirm.active=false
      return
    end
    # 按下 C 键的场合下
    if Input.trigger?(Input::C)
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 确定则保存
      $game_temp.write_save_data if @confirm.index == 0
      end_game
    end
  end
  #--------------------------------------------------------------------------
  # ● 结束游戏
  #--------------------------------------------------------------------------
  def end_game
    # 演奏确定 SE
    $game_system.se_play($data_system.decision_se)
    # 淡入淡出 BGM、BGS、ME
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # 退出
    $scene = nil
  end
end