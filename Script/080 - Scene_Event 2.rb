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
    when 5 # 铸剑谷
      update_sword
    when 6 # 铸剑挑战
      update_sword_battle
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
  # ● 刷新进入铸剑谷
  #--------------------------------------------------------------------------
  def update_sword
    # 按下 B 键的情况或按下 C 键的情况
    if Input.trigger?(Input::B) or Input.trigger?(Input::C)
      # 播放移动SE
      $game_system.se_play($data_system.move_se)
      $scene = Scene_Map.new
      # 设置主角的移动目标
      $game_map.setup(67)
      $game_player.moveto(9,11)
      $game_player.turn_up
      $game_player.straighten
      $game_map.autoplay
      # 准备过渡
      Graphics.freeze
      # 设置过渡处理中标志
      $game_temp.transition_processing = true
      $game_temp.transition_name = ""
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新NPC隐藏任务选单
  #--------------------------------------------------------------------------
  def update_sword_battle
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
      when 0
        # 背包已满无法挑战
        if @actor.full_item_bag?
          @confirm_window.visible = false
          @confirm_window.active = false
          show_text($data_text.sword_no_bag)
          @talk_step = 3
        else
          call_battle(149,1)
        end
      when 1
        $scene=Scene_Map.new
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新铸剑
  #--------------------------------------------------------------------------
  def update_make_sword
    if @name_input != nil
      if @new_name != ""
        text = $data_system.set_weapon_name[0].deep_clone
        text.gsub!("------",@new_name)
        @name_input.change_item(0,text)
      else
        @name_input.change_item(0,$data_system.set_weapon_name[0])
      end
      @name_input.update 
    end
    if @sword_step != 3
      @confirm_window.visible = true
      @confirm_window.active = true
      @confirm_window.x = @actor.sword_type == -1 ? 80 : 200
    end
    # 按下 B 键的情况
    if Input.trigger?(Input::B) and @sword_step != 3
      # 回到地图
      @name_input.dispose if @name_input != nil
      $scene=Scene_Map.new
      return
    end
    # 按下 C 键的情况
    if Input.trigger?(Input::C)
      @confirm_window.visible = false
      @confirm_window.active = false
      @talk_window.visible = false
      case @sword_step
      when 1 # 选择类别或确认重铸
        if @actor.sword_type == -1
          # 选择武器类别后保存
          @actor.sword_type = @confirm_window.index
          @actor.input_name = true
          show_text($data_text.sword_is_making.dup)
          $game_temp.write_save_data
          @phase = 1
          return
        else
          case @confirm_window.index
          when 0
            # 获取经验和金钱要求
            need_exp = (@actor.sword_times + 1) * 100000
            need_gold = @actor.exp / 2
            # 经验不足
            if @actor.exp < need_exp
              show_text($data_text.sword_no_exp.dup)
              @phase = 1
              return
            end
            # 金钱不足
            if @actor.gold < need_gold
              show_text($data_text.sword_no_gold.dup)
              @phase = 1
              return
            end
            # 装备自制武器的情况
            if @actor.weapon_id == 31
              show_text($data_text.sword_unequip.dup)
              @phase = 1
              return
            end
            @actor.lose_gold(need_gold)
            # 刷新武器属性
            refresh_sword_data
            # 询问是否重新命名
            show_text($data_text.rename_sword.dup)
            @sword_step = 2
          when 1
            # 回到地图
            $scene=Scene_Map.new
          end
        end
      when 2 # 重新命名
        case @confirm_window.index
        when 0
          @name_input = Window_Command.new(320,$data_system.set_weapon_name,1)
          @name_input.x = 320 - @name_input.width / 2
          @name_input.y = 240 - @name_input.height / 2
          @new_name = ""
          @name_input.active = true
          @name_input.visible = true
          @sword_step = 3
        when 1
          # 设置铸造武器属性
          @actor.set_sword
          $game_temp.write_save_data
          # 回到地图
          $scene=Scene_Map.new
        end
      when 3 # 输入名称窗口
        # 命令窗口的光标位置的分支
        case @name_input.index
        when 0  # 输入武器名字
          input_sword_name
        when 1  # 确认
          check_sword_name
        end
      end
    end
  end
end