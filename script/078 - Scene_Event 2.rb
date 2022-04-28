#==============================================================================
# ■ Scene_Event (分割定义 2)
#------------------------------------------------------------------------------
# 　处理各类地图事件的类。
#==============================================================================

class Scene_Event
  #--------------------------------------------------------------------------
  # ● 刷新文本显示(任意键返回)
  #--------------------------------------------------------------------------
  def update_text
    # 按下 B 键的情况或按下 C 键的情况
    if Input.trigger?(Input::B) or Input.trigger?(Input::C)
      # 回到地图
      $scene=Scene_Map.new
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新游戏厅画面
  #--------------------------------------------------------------------------
  def update_hall
    @confirm_game.update
    case @game_step
    when 1
      # 按下 B 键的情况下
      if Input.trigger?(Input::B)
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        $scene = Scene_Map.new
      end
      # 按下 C 键的情况下
      if Input.trigger?(Input::C)
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        case @confirm_game.index
        when 0 # 确定的情况
          @game_step=2
          @confirm_game.visible=false
          @confirm_game.active=false
          show_text($data_text.play_what_text)
          @confirm_window.x = 80
          @confirm_window.active=true
          @confirm_window.visible=true
        when 1 # 取消的情况
          $scene = Scene_Map.new
        end
      end
    when 2
      # 按下 B 键的情况下
      if Input.trigger?(Input::B)
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        $scene = Scene_Map.new
      end
      # 按下 C 键的情况下
      if Input.trigger?(Input::C)
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 记忆地图 BGM 、停止 BGM
        $game_temp.map_bgm = $game_system.playing_bgm
        $game_system.bgm_stop
        case @confirm_window.index
        when 0
          # 演奏跳舞 BGM
          $game_system.bgm_play($data_system.dance_bgm)
          $scene=Scene_Dance.new
        when 1
          # 演奏投篮 BGM
          $game_system.bgm_play($data_system.throw_ball_bgm)
          $scene=Scene_ThrowBall.new
        when 2
          $scene=Scene_Map.new
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新钓鱼
  #--------------------------------------------------------------------------
  def update_fish
    # 按下 B 键的情况或按下 C 键的情况
    if Input.trigger?(Input::B) or Input.trigger?(Input::C)
      case @fish_step
      when 1 # 上钩的情况
        show_text($data_text.fish_suc[0])
        # 没带鱼篓
        if @actor.item_number(1,18) == 0
          @fish_step=3
        else
          @fish_step=4
        end
        return
      when 2 # 没上钩
        show_text($data_text.fish_fail)
        @phase=1
      when 3 # 没带鱼篓
        show_text($data_text.fish_no_item[1])
        @phase=1
      when 4 # 成功钓鱼
        # 播放奖励音效
        $game_system.se_play($data_system.actor_collapse_se)
        show_text($data_text.fish_suc[1])
        @actor.gain_item(1,17)
        @phase=1
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新NPC事件
  #--------------------------------------------------------------------------
  def update_npc
    # 刷新NPC窗口
    @npc_menu.update
    @npc_status.update
    @npc_name.update
    case @npc_step
    when 0 # 刷新NPC菜单
      update_npc_menu
    when 1 # 刷新NPC对话
      update_npc_talk
    when 2 # 刷新NPC查看
      update_text
    when 3 # 刷新商人/师父
      update_shop_teacher
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新NPC菜单
  #--------------------------------------------------------------------------
  def update_npc_menu
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
      when 0
        # 交谈
        start_talk
      when 1
        # 隐藏NPC姓名
        @npc_name.visible=false
        # 查看
        look_status
      when 2
        # 隐藏NPC姓名
        @npc_name.visible=false
        # 进入战斗
        call_battle(@id)
      when 3
        case @menu
        # 交易
        when 1
          # 当铺且玩家没有可出售物品则返回
          if @npc.sell_count == 0 and @actor.sell_list == nil
            # 演奏冻结 SE
            $game_system.se_play($data_system.buzzer_se)
          else
            # 商店处理
            $scene = Scene_Shop.new(@id)
          end
        # 拜师
        when 2
          @phase = 1
          # 自创门派的情况
          if @actor.class_id == 9
            talk = $data_text.have_school[0]
          # 已加入其他门派的情况
          elsif @actor.class_id !=0 and @actor.class_id != @npc.type
            talk = $data_text.have_school[1]
          else
            talk = set_teacher
            @text_gp = []
            # 拜师成功的情况
            if talk[0]
              @phase = 7
              @actor.teacher_id = @id
              @actor.class_id = @npc.type
              suc_txt = $data_text.baishi_suc.dup
              suc_txt.gsub!("name",@npc.name)
              @end_text_gp = false
              @text_gp = [0,talk[1],0,suc_txt]
              @gp_id = 0
            end
          end
          text = talk.is_a?(Array) ? talk[1] : talk
          show_text(text) if @phase != 7
        # 请教
        when 3
          # 如果不是独行大侠
          if @id !=7
            $scene=Scene_Study.new(@id)
          else
            # 判断经验
            if @actor.exp >= 200000
              $scene=Scene_Study.new(@id)
            else
              @phase = 1
              show_text($data_text.daxia_exp)
            end
          end
        end
      end
      @confirm_window.visible=false
      @confirm_window.active=false
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新NPC对话
  #--------------------------------------------------------------------------
  def update_npc_talk
    case @talk_step
    when 1 # 检查隐藏任务
      update_npc_quest
    when 2 # 是否完成隐藏任务
      update_quest_choice
    when 3 # 按任意键返回地图
      update_text
    when 4 # 是否完成中年妇人任务
      update_old_woman
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新NPC隐藏任务
  #--------------------------------------------------------------------------
  def update_npc_quest
    # 按下 B 键的情况或按下 C 键的情况
    if Input.trigger?(Input::B) or Input.trigger?(Input::C)
      quest=$data_tasks.quest_list[@id]
      # 目标NPC不存在隐藏任务
      if quest == nil
        $scene=Scene_Map.new
        return
      else
        # 检查是否可完成隐藏任务
        if $game_task.check_quest(quest)
          talk=$data_text.quest_talk[@id]
          show_text(talk[0])
          @confirm_window.visible=true
          @confirm_window.active=true
          @talk_step=2
        else # 不满足则返回地图
          $scene=Scene_Map.new
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新NPC隐藏任务选单
  #--------------------------------------------------------------------------
  def update_quest_choice
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
      case @confirm_window.index
      when 0
        quest=$data_tasks.quest_list[@id]
        # 根据任务类型处理物品
        case quest[0][0]
        when 1 # 交换物品
          @actor.lose_item(quest[0][1],quest[0][2],quest[0][3])
          @actor.gain_item(quest[1][0],quest[1][1],quest[1][2])
        when 2 # 展示物品
          @actor.gain_item(quest[1][0],quest[1][1],quest[1][2])
        end
        @talk_step = 3
        talk = $data_text.quest_talk[@id]
        show_text(talk[1])
        @confirm_window.visible = false
        @confirm_window.active = false
      when 1
        $scene=Scene_Map.new
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新是否完成中年妇人任务
  #--------------------------------------------------------------------------
  def update_old_woman
    @confirm_window.visible=true
    @confirm_window.active=true
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
      case @confirm_window.index
      when 0 # 给予物品完成任务
        item=[$game_task.find_type,$game_task.find_id]
        @actor.lose_item(item[0],item[1],1)
        @confirm_window.visible=false
        @confirm_window.active=false
        $game_task.find_type=0
        $game_task.find_id=0
        $game_task.gu_reward = $game_task.find_reward
        show_text(task_finish(2))
        @talk_step=3
      when 1
        $scene=Scene_Map.new
      end
    end
  end
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
end