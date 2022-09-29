#==============================================================================
# ■ Scene_Event (分割定义 2)
#------------------------------------------------------------------------------
# 　处理各类地图事件的类。
#==============================================================================

class Scene_Event
  #--------------------------------------------------------------------------
  # ● 刷新自杀
  #--------------------------------------------------------------------------
  def update_kill_self
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      # 回到地图
      $scene=Scene_Map.new
      return
    end
    # 按下 C 键的情况
    if Input.trigger?(Input::C)
      # 根据自杀步骤处理
      case @suicide_step
      when 1 # 按任意键显示询问
        show_text($data_text.suicide_ask)
        @confirm_window.visible = true
        @confirm_window.active = true
        @suicide_step = 2
      when 2 # 是否自杀
        case @confirm_window.index
        when 0 # 确定
          File.delete("Save/Gmud.sav")
          Audio.bgm_fade(800)
          Audio.bgs_fade(800)
          Audio.me_fade(800)
          $scene = nil
        when 1 # 放弃
          # 回到地图
          $scene=Scene_Map.new
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新连续文本
  #    type--0：返回地图，1：设置结束标志
  #--------------------------------------------------------------------------
  def update_text_gp(type = 0)
    case @text_gp[@gp_id]
    when 1 # 显示NPC名字
      @npc_name.set_up(80,280,@npc.name)
      @npc_name.update
    when 2 # 显示玩家名字
      @npc_name.set_up(80,280,@actor.name)
      @npc_name.update
    when 0 # 不显示名字
      @npc_name.visible = false
    end
    show_text(@text_gp[@gp_id + 1])
    # 道德和尚结局文本结束立即设置结束标志
    if type == 1 and @boss_id == 2 and (@gp_id+2 == @text_gp.size)
      @end_text_gp = true
      return
    end
    # 按下 B 键的情况或按下 C 键的情况
    if Input.trigger?(Input::B) or Input.trigger?(Input::C)
      # 设置@gp_id
      @gp_id += 2
      # 连续文本显示完毕
      if @gp_id == @text_gp.size
        case type
        when 0 # 返回地图
          $scene = Scene_Map.new
        when 1 # 设置结束标志
          @end_text_gp = true
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新BOSS事件
  #--------------------------------------------------------------------------
  def update_boss
    # 道德和尚结局选择
    if @boss_select
      # 按下 B 键的情况
      if Input.trigger?(Input::B)
        # 返回地图
        $scene = Scene_Map.new
        return
      end
      # 按下 C 键的情况
      if Input.trigger?(Input::C)
        case @confirm_window.index
        when 0 
          # 返回地图
          $scene = Scene_Map.new
        when 1
          # 进入战斗
          $game_temp.boss_battle = true
          call_battle(@npc.id)
        end
        return
      end
    end
    # 判断对话是否结束
    unless @end_text_gp
      update_text_gp(1)
    else # 已结束
      case @boss_id
      when 0,1 # 我是谁，东方求败
        # 进入战斗
        $game_temp.boss_battle = true
        call_battle(@npc.id)
      when 2 #道德和尚
        @confirm_window.x = 80
        @confirm_window.active = true
        @confirm_window.visible = true
        @boss_select = true
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新桃花源事件
  #--------------------------------------------------------------------------
  def update_new_home
    @black_window.update if @black_window != nil
    @step_menu.update if @step_menu != nil
    if @home_step == 1
      @confirm_window.visible=true
      @confirm_window.active=true
    end
    # 按下 B 键的情况下
    if Input.trigger?(Input::B) and @home_step = 1
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Map.new
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      @confirm_window.visible=false
      @confirm_window.active=false
      case @home_step
      when 1 # 爬山阶段
        @talk_window.visible = false
        case @confirm_window.index
        when 0
          # 判断是否成功到山顶
          home_result = rand(30 + @actor.luck)
          home_result += 30 if @actor.have_new_home
          # 设置黑屏
          @black_window = Window_Base.new(0,0,640,480)
          @black_window.z = 750
          $game_system.windowskin_name = "Black.png"
          if home_result < 30 # 攀登失败
            @home_step = 2
            text = $data_text.new_home_fail[0].deep_clone
          else
            @home_step = 4
            text = $data_text.new_home_top.dup
          end
          show_home_text(text)
        when 1
          # 返回地图
          $scene = Scene_Map.new
        end
      when 2 # 爬山失败
        @home_step = 3
        text = $data_text.new_home_fail[1].deep_clone
        show_home_text(text)
      when 3 # 黑屏
        @black_window.contents.clear
        black_time = (100 - @actor.bon) * 2
        for i in 1..black_time
          # 刷新画面
          Graphics.update
        end
        # 设置窗口样式
        $game_system.windowskin_name = "Window.png"
        @black_window.dispose
        @black_window = nil
        $scene = Scene_Map.new
      when 4 # 到达山顶
        # 判断是否已拥有桃花源
        if @actor.have_new_home
          @step_num = 5
          show_walk_step
        else # 生成方向选择
          @step_num = 0
          @step_menu = Window_Command.new(480,$data_system.direction_menu,4,6)
          @step_menu.x,@step_menu.y,@step_menu.z = 80,80,800
          show_direction_choose
        end
        @home_step = 5
      when 5 # 判断步序
        if @step_num == 5
          if @step_menu != nil
            @step_menu.dispose
            @step_menu = nil
          end
          text = $data_text.see_new_home.dup
          show_home_text(text)
          @home_step = 6
        else # 判断是否前进
          @step_menu.visible = false
          @step_menu.active = false
          @home_step = 9
          if rand(5) == 0
            text = $data_text.step_fail.dup
            show_home_text(text)
          else
            if rand(4) != @step_menu.index
              @step_num += 1
            end
            show_walk_step
          end
        end
      when 6 # 到达房屋
        if @actor.have_new_home
          text = $data_text.welcome_home[0].deep_clone
          @home_step = 7
        else
          text = $data_text.welcome_home[1].deep_clone
          @home_step = 8
        end
        show_home_text(text)
      when 7 # 进入桃花源
        # 恢复窗口样式
        $game_system.windowskin_name = "Window.png"
        @black_window.dispose
        @black_window = nil
        # 调整主角姿势
        $game_player.turn_up
        $game_player.straighten
        # 刷新主角
        $game_player.refresh
        move_to_map(57,9,13)
      when 8 # 山大王战斗
        # 恢复窗口样式
        $game_system.windowskin_name = "Window.png"
        @black_window.dispose
        @black_window = nil
        call_battle(162)
      when 9 # 返回步序判断
        @home_step = 5
        show_direction_choose
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新老管家事件
  #--------------------------------------------------------------------------
  def update_master
    # 刷新NPC窗口
    @npc_menu.update
    @npc_status.update
    @npc_name.update
    case @master_step
    when 1
      update_master_menu
    when 2
      update_room_upgrade
    when 3
      update_jiaju_menu
    when 4
      update_jiaju_num
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新老管家菜单
  #--------------------------------------------------------------------------
  def update_master_menu
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Map.new
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      @npc_menu.active = false
      @npc_menu.visible = false
      @npc_name.visible = false
      case @npc_menu.index
      when 0 # 翻盖
        # 已到最高级
        if @actor.room_level == 3
          show_text($data_text.room_max_lv)
          @phase = 1
          return
        end
        # 金钱不足
        if @actor.gold < 2000000
          show_text($data_text.room_no_gold)
          @phase = 1
          return
        end
        # 翻盖成功
        @actor.room_level += 1
        show_text($data_text.room_lv_up)
        @actor.lose_gold(2000000)
        @master_step = 2
      when 1 # 家具
        @npc_menu.dispose
        @npc_menu=Window_Command.new(104,$data_system.jiaju_menu,1,2,2)
        h = $data_system.jiaju_menu.size * 32 + 24
        set_npc_menu(h)
        @npc_menu.active = true
        @npc_menu.visible = true
        @npc_name.visible = true
        @master_step = 3
      when 2 # 销毁
        @actor.jiaju_list = [0,0,0,0,0]
        $game_map.refresh_map_events
        $scene = Scene_Map.new
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新翻盖房屋
  #--------------------------------------------------------------------------
  def update_room_upgrade
    # 按下 B 键或 C 键的情况下
    if Input.trigger?(Input::B) or Input.trigger?(Input::C)
      # 调整姿势
      $game_player.turn_up
      $game_player.straighten
      move_to_map(57,9,7)
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新家具菜单
  #--------------------------------------------------------------------------
  def update_jiaju_menu
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Map.new
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      @npc_menu.active = false
      # 判断金钱是否足够
      if @actor.gold < 60000
        @npc_menu.visible = false
        @npc_name.visible = false
        show_text($data_text.jiaju_no_gold)
        @phase = 1
        return
      end
      # 判断是否还能放下家具
      max_jiaju = @actor.room_level * 2 - 1
      n = @actor.jiaju_list
      n_sum = n[0] + n[1] + n[2] + n[3] + n[4]
      if n_sum == max_jiaju # 家具已满
        @npc_menu.visible = false
        @npc_name.visible = false
        text = $data_text.room_no_space.deep_clone
        text.gsub!("number",n_sum.to_s)
        show_text(text)
        @phase = 1
      else # 还有空间
        s_size = max_jiaju - n_sum
        max_num = [s_size,@actor.gold/60000].min
        @jiaju_num = Window_InputNumber.new(1,max_num)
        @jiaju_num.opacity,@jiaju_num.back_opacity = 255,255
        # 计算数字输入坐标
        y = @npc_menu.y + @npc_menu.index * 32
        x = @npc_menu.x > 492 ? @npc_menu.x - 44 : @npc_menu.x + 104
        @jiaju_num.x,@jiaju_num.y = x,y
        @jiaju_num.number = 0
        @master_step = 4
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新数字输入
  #--------------------------------------------------------------------------
  def update_jiaju_num
    @jiaju_num.update
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      @master_step = 3
      @jiaju_num.dispose
      @npc_menu.active = true
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 演奏确定 SE
      $game_system.se_play($data_system.shop_se)
      @actor.lose_gold(@jiaju_num.number * 60000)
      @actor.jiaju_list[@npc_menu.index] += @jiaju_num.number
      $game_map.refresh_map_events
      @master_step = 3
      @jiaju_num.dispose
      @npc_menu.active = true
    end
  end
end