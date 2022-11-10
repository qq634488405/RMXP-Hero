#==============================================================================
# ■ Scene_Practice
#------------------------------------------------------------------------------
# 　处理练功画面的类。
#==============================================================================

class Scene_Practice
  #--------------------------------------------------------------------------
  # ● 初始化
  #--------------------------------------------------------------------------
  def initialize
    @actor = $game_actor
    @list = @actor.practice_list
    @pra_list = []
    # 生成练功列表选项
    @list.each do |i|
      kf_name = $data_kungfus[i].name
      @pra_list.push(kf_name)
    end
    @pra_list.fill_space_to_max
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    @screen = Spriteset_Map.new
    # 生成对话窗口
    @talk_window = Window_Help.new(480,160)
    @talk_window.visible,@talk_window.x = false,80
    @talk_window.y,@talk_window.z = 304,500
    # 生成练功窗口
    max_size = @pra_list.max_length
    @skill_window = Window_Command.new(max_size*12+80,@pra_list,1,3)
    @skill_window.x,@skill_window.y = 620-@skill_window.width,74
    # 生成进度条背景窗口
    @info = Window_Base.new(160,10,352,64)
    @info.z = 600
    @info.visible = false
    @phase = 1
    # 执行过度
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果画面切换就中断循环
      if $scene != self
        break
      end
    end
    $eat_flag = true
    # 装备过渡
    Graphics.freeze
    # 释放窗口
    @talk_window.dispose
    @skill_window.dispose
    @info.dispose
    @screen.dispose
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
  # ● 选择的技能ID
  #--------------------------------------------------------------------------
  def kf_id
    return @list[@skill_window.index]
  end
  #--------------------------------------------------------------------------
  # ● 刷新信息
  #--------------------------------------------------------------------------
  def update
    @skill_window.update
    @talk_window.update
    @info.update
    case @phase
    when 1 # 刷新命令
      $eat_flag = true
      update_command
    when 2 # 练功
      $eat_flag = false
      update_practice
    end
    @screen.update
  end
  #--------------------------------------------------------------------------
  # ● 返回练功菜单
  #--------------------------------------------------------------------------
  def return_menu
    @skill_window.visible = true
    @skill_window.active = true
    @info.visible = false
    @talk_window.visible=false
    # 恢复帧率
    Graphics.frame_rate = 40
    @phase = 1
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
      # 受伤的情况
      if @actor.maxhp < @actor.full_hp
        draw_error($data_text.pra_hurt)
        return_menu
        return
      end
      # 所选技能不为轻功
      unless $data_kungfus[kf_id].type == 9
        # 佩戴武器的情况
        if @actor.weapon_id > 0
          # 武器与所选技能不匹配
          if $data_kungfus[kf_id].type != @actor.weapon_basic_kf
            draw_error($data_text.pra_no_weapon)
            return_menu
            return
          end
        else # 空手的情况
          # 所选技能非拳脚类
          if $data_kungfus[kf_id].type != 2
            draw_error($data_text.pra_no_weapon)
            return_menu
            return
          end
        end
      end
      basic_id = @actor.get_basic_id(kf_id)
      # 基本功夫没学会的情况
      if @actor.get_kf_level(basic_id) == 0
        draw_error($data_text.pra_no_base)
        return_menu
        return
      end
      return unless check_lv_exp_fp
      @phase = 2
    end
  end
  #--------------------------------------------------------------------------
  # ● 检查等级、经验、内力
  #--------------------------------------------------------------------------
  def check_lv_exp_fp
    lv = @actor.get_kf_level(kf_id)
    basic_id = @actor.get_basic_id(kf_id)
    # 基本功夫等级低的情况
    if @actor.get_kf_level(basic_id) < lv or lv == 255
      draw_error($data_text.no_pra)
      return_menu
      return false
    end
    # 检查经验是否充足
    unless @actor.check_kf_exp(kf_id)
      draw_error($data_text.learn_no_exp)
      return_menu
      return false
    end
    # 判断内力上限是否足够
    if @actor.maxfp < @actor.get_kf_efflv(kf_id)*10
      draw_error($data_text.pra_no_fp)
      return_menu
      return false
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● 刷新练功画面
  #--------------------------------------------------------------------------
  def update_practice
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      return_menu
      return
    end
    # 调整帧率
    Graphics.frame_rate = 120
    lv = @actor.get_kf_level(kf_id)
    kf_pos = @actor.get_kf_index(kf_id)
    point_max = (lv + 1)**2
    basic_id = @actor.get_basic_id(kf_id)
    speed = @actor.get_kf_level(basic_id)/5+1
    # 描绘进度
    @info.visible = true
    @actor.skill_list[kf_pos][2] += speed
    process = [200*@actor.skill_list[kf_pos][2]/point_max,200].min
    draw_process(process,lv,kf_pos)
    # 你的功夫进步了
    if @actor.skill_list[kf_pos][2] >= point_max
      @actor.skill_list[kf_pos][1] += 1
      @actor.skill_list[kf_pos][2] = 0
      draw_error($data_text.sk_lv_up)
      check_lv_exp_fp
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘进度条
  #--------------------------------------------------------------------------
  def draw_process(process,lv,kf_pos)
    kf_point = @actor.skill_list[kf_pos][2].to_s
    # 根据显示内容调整宽度
    text = kf_point + "/"+lv.to_s
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
end