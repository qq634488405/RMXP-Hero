#==============================================================================
# ■ Scene_Battle (分割定义 1)
#------------------------------------------------------------------------------
# 　处理战斗画面的类。
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # ● 初始化，id为NPC ID，type：0--常规战斗，1--铸剑挑战
  #--------------------------------------------------------------------------
  def initialize(id,type = 0)
    @id = id
    @type = type
    $eat_flag = false
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    # 初始化战斗用的各种暂时数据
    $game_temp.in_battle = true
    $game_temp.battle_turn = 0
    $game_temp.battle_event_flags.clear
    $game_temp.battle_abort = false
    $game_temp.battle_main_phase = false
    $game_temp.battleback_name = "BG.png"
    $game_temp.forcing_battler = nil
    # 初始化战斗用事件解释器
    $game_system.battle_interpreter.setup(nil, 0)
    # 准备队伍
    @actor = $game_actor
    @actor.clear_temp_data
    @enemy = Game_Enemy.new(@id)
    @enemy.clear_temp_data
    @escape_factor = 20
    # 生成角色命令窗口
    @battle_commands = $data_system.battle_menu
    @battle_menu = Sprite.new
    @battle_menu.bitmap = Bitmap.new(20*@battle_commands.size,24)
    @battle_index = 0
    @battle_menu.x = (640-@battle_menu.bitmap.width)/2
    @battle_menu.y,@battle_menu.z = 300,300
    @battle_menu.visible = false
    @battle_main = false
    @battle_name = Sprite_Text.new
    @battle_name.visible = false
    # 生成其它窗口
    @msg_window = Window_Help.new(640,128)
    @msg_window.visible = false
    @msg_window.y = 352
    @status_window = Window_BattleStatus.new(@enemy)
    # 生成活动块
    @spriteset = Spriteset_Battle.new(@enemy)
    # 初始化等待计数
    @wait_count = 0
    # 初始化状态刷新标志
    @actor_states_refresh,@enemy_states_refresh = false,false
    # 执行过渡
    if $data_system.battle_transition == ""
      Graphics.transition(20)
    else
      Graphics.transition(40, "Graphics/Transitions/" +
        $data_system.battle_transition)
    end
    # 附加铸造武器状态
    add_sword_state
    # 随机出手
    rand(100) > 50 ? start_phase1 : start_phase2
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果画面切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 刷新地图
    $game_map.refresh
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @battle_menu.dispose
    @battle_name.dispose
    @msg_window.dispose
    @status_window.dispose
    if @skill_window != nil
      @skill_window.dispose
    end
    if @type_window != nil
      @type_window.dispose
    end
    if @kf_window != nil
      @kf_window.dispose
    end
    if @item_window != nil
      @item_window.dispose
    end
    if @fp_window != nil
      @fp_window.dispose
    end
    if @num_window != nil
      @num_window.dispose
    end
    if @confirm_window != nil
      @result_window.dispose
    end
    if @result_window != nil
      @result_window.dispose
    end
    # 释放活动块
    @spriteset.dispose
    # 标题画面切换中的情况
    if $scene.is_a?(Scene_Title)
      # 淡入淡出画面
      Graphics.transition
      Graphics.freeze
    end
    # 战斗测试或者游戏结束以外的画面切换中的情况
    if $BTEST and not $scene.is_a?(Scene_Gameover)
      $scene = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 胜负判定
  #--------------------------------------------------------------------------
  def judge
    # 已进入胜负判断则返回
    return false if @phase == 4 or @phase == 5
    case @type
    when 0 # 普通战斗
      end_hp1,end_hp2 = 0,0
    when 1 # 铸剑挑战
      end_hp1,end_hp2 = @actor.full_hp/2,@enemy.full_hp/2
    end
    # 任意一方HP≤结束战斗HP值则战斗结束
    if @actor.hp <= end_hp1
      start_phase4
      return true
    end
    if @enemy.hp <= end_hp2
      start_phase5
      return true
    end
    # 双方HP>0则继续战斗
    return false
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 系统 (计时器)、刷新画面
    $game_system.update
    $game_screen.update
    # 计时器为 0 的情况下
    if $game_system.timer_working and $game_system.timer == 0
      # 中断战斗
      $game_temp.battle_abort = true
    end
    # 刷新窗口
    @msg_window.update
    @battle_menu.update
    @battle_name.update
    @status_window.update
    # 刷新活动块
    @spriteset.update
    # 处理过渡中的情况下
    if $game_temp.transition_processing
      # 清除处理过渡中标志
      $game_temp.transition_processing = false
      # 执行过渡
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" +
          $game_temp.transition_name)
      end
    end
    # 显示效果中的情况下
    if @spriteset.effect?
      return
    end
    # 返回标题画面的情况下
    if $game_temp.to_end > 0
      # 切换到标题画面
      $scene = Scene_Scroll.new($game_temp.to_end)
      return
    end
    # 中断战斗的情况下
    if $game_temp.battle_abort
      # 还原为战斗前的 BGM
      $game_system.bgm_play($game_temp.map_bgm)
      # 战斗结束
      battle_end(1)
      return
    end
    # 等待中的情况下
    if @wait_count > 0
      # 减少等待计数
      @wait_count -= 1
      return
    end
    # 刷新玩家战斗状态
    if @actor_states_refresh
      states_change(@actor)
      @actor_states_refresh = false
    end
    # 刷新敌人战斗状态
    if @enemy_states_refresh
      states_change(@enemy)
      @enemy_states_refresh = false
    end
    # 分出胜负则返回
    return if judge
    # 回合分支
    case @phase
    when 1  # 角色回合
      update_phase1
    when 2  # 敌方回合
      update_phase2
    when 3  # 角色命令回合
      update_phase3
    when 4  # 胜负判断
      update_phase4
    when 5  # 战斗结束
      update_phase5
    end
  end
  #--------------------------------------------------------------------------
  # ● 玩家回合
  #--------------------------------------------------------------------------
  def start_phase1(menu_id = 0)
    # 转移到回合 1
    @phase = 1
    # 玩家状态改变
    @actor_states_refresh = true
    # 激活选项窗口
    @battle_menu.bitmap.clear
    @battle_menu.visible = true
    @battle_main = true
    @battle_index = menu_id
    update_battle_position
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (角色命令回合)
  #--------------------------------------------------------------------------
  def update_phase1
    # 类型窗口有效的情况下
    if @type_window != nil and @type_window.active
      update_phase1_type_select
    # 绝招窗口有效的情况下
    elsif @skill_window != nil and @skill_window.active
      update_phase1_skill_select
    # 物品窗口有效的情况下
    elsif @item_window != nil and @item_window.active
      update_phase1_item_select
    # 技能窗口有效的情况下
    elsif @kf_window != nil and @kf_window.active
      update_phase1_kf_select
    # 内力窗口有效的情况下
    elsif @fp_window != nil and @fp_window.active
      update_phase1_fp_select
    # 加力窗口有效的情况下
    elsif @num_window != nil and @num_window.active
      update_phase1_num_input
    # 角色指令窗口有效的情况下
    elsif @battle_menu.visible and @battle_main
      update_phase1_basic_command
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (角色命令回合 : 基本命令)
  #--------------------------------------------------------------------------
  def update_phase1_basic_command
    @msg_window.visible = false
    # 描绘命令窗口
    bitmap = [RPG::Cache.picture("Rect_Unselected.png"),
              RPG::Cache.picture("Rect_Selected.png")]
    @battle_menu.bitmap.clear
    color=Color.new(144,176,87)
    temp_rect=@battle_menu.bitmap.rect
    @battle_menu.bitmap.fill_rect(temp_rect,color)
    @battle_commands.each_index do |i|
      if @battle_index == i
        @battle_menu.bitmap.blt(i*20,0,bitmap[1],Rect.new(0,0,20,24),255)
        @battle_name.set_text(@battle_commands[i])
      else
        @battle_menu.bitmap.blt(i*20,0,bitmap[0],Rect.new(0,0,20,24),255)
      end
    end
    @battle_name.visible = true
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      start_phase1
      return
    end
    # 按下 左 的情况
    if Input.trigger?(Input::LEFT)
      # 演奏光标 SE
      $game_system.se_play($data_system.cursor_se)
      @battle_index = (@battle_index + 5) % 6
      update_battle_position
      return
    end
    # 按下 右 的情况
    if Input.trigger?(Input::RIGHT)
      # 演奏光标 SE
      $game_system.se_play($data_system.cursor_se)
      @battle_index = (@battle_index + 1) % 6
      update_battle_position
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 角色指令窗口光标位置分之
      case @battle_index
      when 0 # 普通攻击
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        hide_main_menu
        # 设置行动
        if @actor.movable?
          common_attack(@actor)
        else
          text = $data_text.cannot_move.dup
          text.gsub!("user","你")
          show_text(text)
        end
        # 进入敌方行动
        start_phase2
      when 1 # 使用绝招
        # 没有绝招的情况
        if @actor.skills.empty?
          # 演奏确定 SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 设置行动
        @battle_main = false
        # 开始选择绝招
        start_skill_select
      when 2 # 使用内力
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        @battle_main = false
        # 开始选择内力选项
        start_fp_select
      when 3 # 使用物品
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        hide_main_menu
        start_item_select
      when 4 # 调整招式
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        hide_main_menu
        start_kf_select
      when 5 # 逃跑
        hide_main_menu
        if @actor.movable?
          escape
        else
          text = $data_text.run_fail_text[0].deep_clone
          text.gsub!("user","你")
          show_text(text)
          # 开始敌方行动
          start_phase2
        end
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新战斗菜单位置
  #--------------------------------------------------------------------------
  def update_battle_position
    @battle_name.visible = false
    x = @battle_menu.bitmap.width - @battle_commands[@battle_index].length * 8
    x = @battle_menu.x + x / 2
    @battle_name.set_up(x,324,@battle_commands[@battle_index],24,false)
  end
  #--------------------------------------------------------------------------
  # ● 开始选择物品
  #--------------------------------------------------------------------------
  def start_item_select
    # 生成物品窗口
    @item_window = Window_Item.new
    @item_window.active = false
    # 生成分类窗口
    @type_window=Window_Command.new(96,$data_system.item_menu,1,5)
    @type_window.x,@type_window.y = @item_window.x-96,@item_window.y
    @type_window.index,@type_window.z = 0,500
  end
  #--------------------------------------------------------------------------
  # ● 结束选择物品
  #--------------------------------------------------------------------------
  def end_item_select
    # 释放物品窗口
    @item_window.dispose
    @item_window = nil
    @type_window.dispose
    @type_window = nil
    start_phase1(3)
  end
  #--------------------------------------------------------------------------
  # ● 描绘文本
  #--------------------------------------------------------------------------
  def show_text(text,time=40)
    @msg_window.auto_text(text.dup)
    @msg_window.visible = true
    for i in 0..time
      # 刷新画面
      Graphics.update
    end
    @msg_window.visible=false
  end
  #--------------------------------------------------------------------------
  # ● 逃跑
  #--------------------------------------------------------------------------
  def escape
    # 开启作弊的情况
    if $game_temp.cheat_mode
      @enemy.hp = 0
      judge
      return
    end
    # 计算逃跑系数
    escape_num = rand(@actor.agi+@escape_factor)
    # BOSS战斗系数强制归零
    escape_num = 0 if $game_temp.boss_battle
    # 系数≥敌人敏捷逃跑成功
    if escape_num >= @enemy.agi
      show_text($data_text.run_suc_text)
      $game_system.se_play($data_system.escape_se)
      # 还原为战斗开始前的 BGM
      $game_system.bgm_play($game_temp.map_bgm)
      # 清除战斗中标志
      $game_temp.in_battle = false
      # 清除临时数据
      @actor.clear_temp_data
      @enemy.clear_temp_data
      # 回到地图画面
      $scene = Scene_Map.new
    else # 逃跑失败
      @escape_factor += 10
      text = $data_text.run_fail_text[1].deep_clone
      text.gsub!("user","你")
      text.gsub!("target",@enemy.name)
      show_text(text)
      # 开始敌方行动
      start_phase2
    end
  end
  #--------------------------------------------------------------------------
  # ● 隐藏命令选项
  #--------------------------------------------------------------------------
  def hide_main_menu
    @battle_main = false
    @battle_menu.visible = false
    @battle_name.visible = false
  end
end
