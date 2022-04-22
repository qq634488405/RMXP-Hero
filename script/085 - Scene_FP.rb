#==============================================================================
# ■ Scene_FP
#------------------------------------------------------------------------------
# 　处理内力画面的类。
#==============================================================================

class Scene_FP
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
    # 生成内力菜单
    @fp_menu = Window_Command.new(128,$data_system.fp_menu,1,1)
    @fp_menu.x,@fp_menu.y = 481,74
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
    @fp_menu.dispose
    @info.dispose
    @screen.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新命令窗口
    @fp_menu.update
    @talk_window.update
    @map_name.update
    @info.update
    case @phase
    when 1 # 刷新命令窗口
      $eat_flag = true
      update_command
    when 2 # 打坐
      $eat_flag = false
      get_maxfp
    when 3 # 加力
      set_fp_plus
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
      # 没有装备内功
      if @actor.fp_kf_id < 12
        # 播放冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        draw_error($data_text.no_neigong)
        return
      end
      # 播放确认 SE
      $game_system.se_play($data_system.decision_se)
      @fp_menu.active = false
      case @fp_menu.index
      when 0 # 打坐
        @phase = 2
      when 1 # 加力
        # 生成加力窗口
        @fp_plus_menu = Window_InputNumber.new(3)
        @fp_plus_menu.x,@fp_plus_menu.y = 320,96
        @fp_plus_menu.opacity,@fp_plus_menu.back_opacity = 255,255
        @fp_plus_menu.number = @actor.fp_plus
        @phase = 3
      when 2 # 吸气
        recover
      when 3 # 疗伤
        heal
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘出错信息
  #--------------------------------------------------------------------------
  def draw_error(text,time=40)
    @talk_window.auto_text(text.dup)
    @talk_window.visible = true
    for i in 0..time
      # 刷新画面
      Graphics.update
    end
    @talk_window.visible=false
  end
  #--------------------------------------------------------------------------
  # ● 打坐
  #--------------------------------------------------------------------------
  def get_maxfp
    # 按下 B 的情况
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      return_fp_menu
      return
    end
    # 计算打坐速率
    speed = @actor.fp_kf_lv/10+@actor.bon/5
    # 内力增加
    @actor.fp += speed
    fpmax = [[@actor.maxfp * 2,65535].min,1].max
    process = [200*@actor.fp/fpmax,200].min
    @info.visible = true
    # 描绘进度
    draw_process(process)
    # 内力满
    if @actor.fp > fpmax
      @actor.maxfp += 1
      # 内功等级不足
      if @actor.maxfp > @actor.full_fp
        @actor.maxfp -= 1
        @actor.fp = @actor.maxfp
        draw_error($data_text.no_nei_lv)
        return_fp_menu
        return
      end
      @actor.fp = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘进度
  #--------------------------------------------------------------------------
  def draw_process(process)
    # 根据显示内容调整宽度
    text = @actor.fp.to_s+"/"+@actor.maxfp.to_s
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
  # ● 加力
  #--------------------------------------------------------------------------
  def set_fp_plus
    @fp_plus_menu.visible = true
    @fp_plus_menu.active = true
    @fp_plus_menu.update
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @fp_plus_menu.dispose
      return_fp_menu
      return
    end
    # 按下 C 键的情况
    if Input.trigger?(Input::C)
      # 播放确认 SE
      $game_system.se_play($data_system.decision_se)
      @actor.fp_plus = @fp_plus_menu.number
      fpp_max = @actor.fp_kf_lv/2
      if @actor.fp_plus >= fpp_max
        @actor.fp_plus = fpp_max
        text = $data_text.fp_plus_max.dup
        text.gsub!("fp_plus",fpp_max.to_s)
        draw_error(text)
      end
      @fp_plus_menu.dispose
      return_fp_menu
    end
  end
  #--------------------------------------------------------------------------
  # ● 吸气
  #--------------------------------------------------------------------------
  def recover
    # 内力不足20
    if @actor.fp < 20
      draw_error($data_text.no_fp)
      return_fp_menu
      return
    end
    # 生命已满
    if @actor.hp == @actor.maxhp
      draw_error($data_text.hp_full)
      return_fp_menu
      return
    else # 生命未满
      # 计算内力消耗
      hp_num = @actor.maxhp - @actor.hp
      fp_cost = hp_num*20/(10+@actor.fp_kf_lv/15)+1
      if fp_cost > @actor.fp # 内力不足以恢复满
        fp_cost = @actor.fp
        @actor.hp += fp_cost*(10+@actor.fp_kf_lv/15)/20
      else # 恢复满
        @actor.hp = @actor.maxhp
      end
      # 扣除内力消耗
      @actor.fp -= fp_cost
      draw_error($data_text.hp_recover)
      return_fp_menu
    end
  end
  #--------------------------------------------------------------------------
  # ● 疗伤
  #--------------------------------------------------------------------------
  def heal
    # 内功有效等级<45
    if @actor.fp_kf_lv < 45
      draw_error($data_text.liao_fail)
      return_fp_menu
      return
    end
    # 内力上限不足
    if @actor.maxfp < 150
      draw_error($data_text.no_maxfp)
      return_fp_menu
      return
    end
    # 当前内力不足
    if @actor.fp < 100
      draw_error($data_text.no_fp)
      return_fp_menu
      return
    end
    # 当前没有受伤
    if @actor.maxhp == @actor.full_hp
      draw_error($data_text.no_hurt)
      return_fp_menu
      return
    end
    # 当前受伤过重
    if @actor.maxhp < @actor.full_hp/3
      draw_error($data_text.bad_hurt)
      return_fp_menu
      return
    end
    # 恢复生命上限
    @actor.maxhp += 10+@actor.fp_kf_lv/5
    @actor.maxhp = [@actor.maxhp,@actor.full_hp].min
    @actor.fp -= 50
    # 显示疗伤文本
    $data_text.liao_suc.each do |i|
      draw_error(i)
    end
    # 完全恢复文本
    if @actor.maxhp == @actor.full_hp
      $data_text.liao_finish.each do |i|
        draw_error(i)
      end
    end
    return_fp_menu
  end
  #--------------------------------------------------------------------------
  # ● 返回内力菜单
  #--------------------------------------------------------------------------
  def return_fp_menu
    @fp_menu.visible = true
    @fp_menu.active = true
    @info.visible = false
    @talk_window.visible=false
    @phase = 1
  end
end