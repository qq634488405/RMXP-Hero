#==============================================================================
# ■ Scene_Cheat
#------------------------------------------------------------------------------
# 　处理调试画面的类。
#==============================================================================

class Scene_Cheat
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    $eat_flag = false
    @actor = $game_actor
    # 生成命令窗口
    @screen = Spriteset_Map.new
    @main_menu = Window_Command.new(300,$data_system.cheat_main,2,1,1)
    @main_menu.x,@main_menu.y = 20,10
    @back_menu = Window_BackMenu.new(0,1)
    @back_menu.visible = false
    # 生成状态修改视图
    @status_command = $data_system.cheat_status
    @status_menu = Sprite.new
    @status_menu.bitmap = Bitmap.new(20*@status_command.size,24)
    @status_index = 0
    @status_menu.x,@status_menu.y = 20,74
    @status_menu.visible = false
    @status_name = Sprite_Text.new
    @status_name.set_up(20,98,@status_command[@status_index])
    @status_name.visible = false
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
    @back_menu.dispose
    @status_menu.dispose
    @status_name.dispose
    @screen.dispose
  end
  #--------------------------------------------------------------------------
  # ● 返回分类
  #--------------------------------------------------------------------------
  def return_category
    @skill_window.refresh
    @skill_window.active = false
    @skill_window.index = -1
    @category_window.active=true
    @help_window.visible=false
    @phase = 3
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新窗口
    @main_menu.update
    @back_menu.index = @main_menu.index
    @back_menu.update
    @status_menu.update
    @status_name.update if @phase == 2
    case @phase
    when 1 # 主菜单
      @main_menu.active=true
      update_main
    when 2 # 修改状态
      @status_menu.visible = true
      update_status
    when 3 # 技能类别
      @category_window.update
      @help_window.update
      @skill_window.update
      update_type
    when 4 # 修改技能
      @category_window.update
      @help_window.update
      update_skill
    when 5 # 设置数字
      update_num
    end
    @screen.update
  end
  #--------------------------------------------------------------------------
  # ● 刷新主窗口
  #--------------------------------------------------------------------------
  def update_main
    # 按下 B 的情况
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到菜单画面
      $scene = Scene_Map.new
      return
    end
    # 按下 C 的情况
    if Input.trigger?(Input::C)
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      @main_menu.active,@main_menu.visible = false,false
      @back_menu.index = @main_menu.index
      @back_menu.visible = true
      case @main_menu.index
      when 0 # 状态
        # 进入状态修改
        @status_menu.visible = true
        @status_name.visible = true
        @status_index = 0
        @phase = 2
      when 1 # 技能
        # 生成技能窗口
        @category_window=Window_Command.new(96,$data_system.cheat_skill,1,5)
        @category_window.x,@category_window.y = 20,74
        # 生成帮助窗口、技能窗口
        @help_window = Window_Help.new(204)
        @help_window.x,@help_window.y = 116,298
        @skill_window = Window_CheatSkill.new
        # 关联帮助窗口
        @skill_window.help_window = @help_window
        @help_window.visible = false
        @skill_window.active = false
        @category_window.active=true
        @category_window.index=0
        @phase = 3
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新查看窗口
  #--------------------------------------------------------------------------
  def update_status
    # 描绘选择窗口
    bitmap = [RPG::Cache.picture("Rect_Unselected.png"),
              RPG::Cache.picture("Rect_Selected.png")]
    @status_menu.bitmap.clear
    color=Color.new(144,176,87)
    temp_rect=@status_menu.bitmap.rect
    @status_menu.bitmap.fill_rect(temp_rect,color)
    @status_command.each_index do |i|
      if @status_index == i
        @status_menu.bitmap.blt(i*20,0,bitmap[1],Rect.new(0,0,20,24),255)
        @status_name.set_text(@status_command[i])
      else
        @status_menu.bitmap.blt(i*20,0,bitmap[0],Rect.new(0,0,20,24),255)
      end
    end
    # 按下 B 的情况
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到主窗口
      @status_menu.visible = false
      @status_name.visible = false
      @back_menu.visible = false
      @main_menu.active = true
      @main_menu.visible = true
      @phase = 1
      return
    end
    # 按下 C 的情况
    if Input.trigger?(Input::C)
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      case @status_index
      when 0,1,2,6,7,13,14,15
        digits_max=10
        @max=4294967295
      when 5,8,10,11,12
        digits_max=3
        @max=255
      when 3,4
        digits_max=5
        @max=65535
      when 9
        digits_max=1
        @max=2
      end
      type=@status_index
      # 生成数值输入窗口
      @number=Window_InputNumber.new(digits_max)
      @number.x=@status_name.x
      @number.y=@status_name.y+32
      @number.z=1300
      @number.opacity=255
      @number.back_opacity=255
      @number.number=@actor.get_status(type)
      @phase = 5
      return
    end
    # 按下 左 的情况
    if Input.trigger?(Input::LEFT)
      # 演奏光标 SE
      $game_system.se_play($data_system.cursor_se)
      @status_index = (@status_index + 15) % 16
      return
    end
    # 按下 右 的情况
    if Input.trigger?(Input::RIGHT)
      # 演奏光标 SE
      $game_system.se_play($data_system.cursor_se)
      @status_index = (@status_index + 1) % 16
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新技能目录窗口
  #--------------------------------------------------------------------------
  def update_type
    # 设置技能窗口功夫类别
    @skill_window.set_kf_type(@category_window.index)
    @skill_window.update
    # 按下 B 的情况
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到主窗口
      @help_window.dispose
      @skill_window.dispose
      @category_window.dispose
      @back_menu.visible = false
      @main_menu.active=true
      @main_menu.visible=true
      @phase = 1
    end
    # 按下 C 的情况
    if Input.trigger?(Input::C)
      # 技能为空则返回
      if @skill_window.skill == nil
        $game_system.se_play($data_system.buzzer_se)
        return_category
        return
      end
      @category_window.active=false
      @skill_window.active=true
      @skill_window.index=0
      @phase = 4
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      @help_window.visible=true
      @skill_window.refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新技能窗口
  #--------------------------------------------------------------------------
  def update_skill
    @skill_window.update
    # 按下 B 的情况
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到技能目录窗口
      return_category
      return
    end
    # 按下 C 的情况
    if Input.trigger?(Input::C)
      @skill=@skill_window.skill
      id,lv = @skill[0],@skill[1]
      kf_list_id = @skill_window.kf_list_index
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 遗忘技能
      if @category_window.index == 7
        # 如果在最后一个技能则光标前移
        @skill_window.index -= 1 if kf_list_id == @actor.skill_list.size-1
        @actor.skill_list.delete_at(kf_list_id)
        # 列表为空则切换到技能目录窗口
        return_category if @actor.skill_list.empty?
      else
        lv = [lv+5,255].min
        @actor.skill_list[kf_list_id][1] = lv
      end
      @skill_window.refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新数字输入窗口
  #--------------------------------------------------------------------------
  def update_num
    @number.update
    # 按下 B 的情况
    if Input.trigger?(Input::B)
      # 演奏放弃 SE
      $game_system.se_play($data_system.cancel_se)
      @phase = 2
      @number.dispose
    end
    # 按下 C 的情况
    if Input.trigger?(Input::C)
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      @actor.cheat_status(@status_index,[@number.number,@max].min)
      @phase = 2
      @number.dispose
    end
  end
end