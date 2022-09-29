#==============================================================================
# ■ Scene_Battle (分割定义 2)
#------------------------------------------------------------------------------
# 　处理战斗画面的类。
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # ● 开始选择功夫
  #--------------------------------------------------------------------------
  def start_kf_select
    # 生成物品窗口
    @kf_window = Window_Skill.new
    @kf_window.active=false    
    # 生成分类窗口
    @type_window=Window_Command.new(96,$data_system.skill_menu,1,5)
    @type_window.x,@type_window.y = @kf_window.x-96,@kf_window.y
    @type_window.index,@type_window.z = 0,500
  end
  #--------------------------------------------------------------------------
  # ● 结束选择功夫
  #--------------------------------------------------------------------------
  def end_kf_select
    # 释放物品窗口
    @kf_window.dispose
    @kf_window = nil
    @type_window.dispose
    @type_window = nil
    return_main_menu(4)
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (类型选择)
  #--------------------------------------------------------------------------
  def update_phase1_type_select
    # 设置窗口可见状态
    @type_window.visible = true
    # 刷新类型选择窗口
    @type_window.update
    case @battle_index
    when 3 # 使用物品
      @item_window.visible = true
      @item_window.set_item_type(@type_window.index)
      # 刷新物品窗口
      @item_window.update
      # 按下 B 键的情况下
      if Input.trigger?(Input::B)
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        # 选择物品结束
        end_item_select
        return
      end
      # 按下 C 键的情况下
      if Input.trigger?(Input::C)
        # 物品为空返回
        if @item_window.item==nil
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 激活物品菜单
        @type_window.active=false
        @item_window.active=true
        @item_window.index=0
        $game_system.se_play($data_system.decision_se)
        @item_window.refresh
      end
    when 4 # 调整招式
      @kf_window.visible = true
      @kf_window.set_kf_type(@type_window.index)
      @kf_window.update
      # 按下 B 键的情况下
      if Input.trigger?(Input::B)
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        # 选择物品结束
        end_kf_select
        return
      end
      # 按下 C 键的情况下
      if Input.trigger?(Input::C)
        # 功夫为空返回
        if @kf_window.skill == nil
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 激活功夫菜单
        @type_window.active=false
        @kf_window.active=true
        @kf_window.index=0
        $game_system.se_play($data_system.decision_se)
        @kf_window.refresh
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (物品选择)
  #--------------------------------------------------------------------------
  def update_phase1_item_select
    @item_window.update
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到分类
      # 冻结物品窗口，激活目录窗口
      phase1_return_type(@item_window)
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 获取物品窗口当前选中的物品数据
      item = @item_window.item
      # 武器窗口处理
      unless @type_window.index !=2
        equip_item(1)
        change_sword_state
        return
      end
      # 装备窗口处理
      unless @type_window.index !=3
        equip_item(2)
        return
      end
      # 丢弃窗口处理
      unless @type_window.index !=5
        drop_item
        return
      end
      # 不能使用的情况下
      unless @actor.item_can_use?(item[1])
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        # 切换到分类
        phase1_return_type(@item_window)
        return
      end
      # 如果物品是书籍
      if $data_items[item[1]].is_book
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        # 切换到分类
        phase1_return_type(@item_window)
        return
      end
      # 如果物品用完的情况下
      if @actor.item_number(1,item[1]) == 0
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 如果角色状态满的情况下
      if full_state?
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏物品使用时的 SE
      $game_system.se_play($data_system.actor_collapse_se)
      # 对目标角色应用物品的使用效果
      @actor.item_effect(item[1])
      # 消耗品的情况下
      if $data_items[item[1]].consumable
        # 使用的物品数减 1
        @actor.lose_item(1,item[1], 1)
        # 再描绘物品窗口的项目
        @item_window.draw_item(@item_window.index)
        @item_window.update_cursor_rect
      end
      phase1_return_type(@item_window)
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (返回类别)
  #--------------------------------------------------------------------------
  def phase1_return_type(window)
    # 冻结窗口，激活目录窗口
    window.refresh
    window.active=false
    window.index=-1
    @type_window.active=true
  end
  #--------------------------------------------------------------------------
  # ● 检查状态是否满
  #--------------------------------------------------------------------------
  def full_state?
    item = $data_items[@item_window.item[1]]
    flag = false
    # 检查各项属性是否为满且物品可恢复该属性
    flag = (flag or (@actor.food<@actor.max_food and item.add_food[1]>0))
    flag = (flag or (@actor.water<@actor.max_water and item.add_water[1]>0))
    flag = (flag or (@actor.hp<@actor.maxhp and item.add_hp[1]>0))
    flag = (flag or (@actor.maxhp<@actor.full_hp and item.add_mhp[1]>0))
    flag = (flag or (@actor.fp<@actor.maxfp and item.add_fp[1]>0))
    flag = (flag or (@actor.mp<@actor.maxmp and item.add_mp[1]>0))
    flag = (flag or item.add_mfp[1]>0 or item.add_mmp[1]>0)
    return (not flag)
  end
  #--------------------------------------------------------------------------
  # ● 装备物品
  #--------------------------------------------------------------------------
  def equip_item(type)
    # 获取物品窗口当前选中的物品数据
    item = @item_window.item
    bag_id = @item_window.bag_index
    @actor.equip(type,bag_id)
    # 播放装备SE
    $game_system.se_play($data_system.equip_se)
    phase1_return_type(@item_window)
  end
  #--------------------------------------------------------------------------
  # ● 丢弃物品
  #--------------------------------------------------------------------------
  def drop_item
    # 获取物品窗口当前选中的物品数据
    item = @item_window.item
    bag_id = @item_window.bag_index
    flag = @actor.lose_bag_id(bag_id)
    phase1_return_type(@item_window) if flag
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (功夫选择)
  #--------------------------------------------------------------------------
  def update_phase1_kf_select
    @kf_window.update
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到分类
      # 冻结物品窗口，激活目录窗口
      phase1_return_type(@kf_window)
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 获取技能窗口当前选中的物品数据
      skill = @kf_window.skill
      id,equip = skill[0],skill[3]
      # 基本功夫和知识的情况
      if id < 12 or @type_window.index == 6
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏装备 SE
      $game_system.se_play($data_system.equip_se)
      # 装备功夫
      kf_list_id = @kf_window.kf_list_index
      @actor.equip_kf(@type_window.index,kf_list_id)
      phase1_return_type(@kf_window)
    end
  end
  #--------------------------------------------------------------------------
  # ● 开始使用内力
  #--------------------------------------------------------------------------
  def start_fp_select
    # 生成内力窗口
    @fp_window=Window_Command.new(128,$data_system.battle_fp,1,1)
    @fp_window.x,@fp_window.y,@fp_window.z = 256,320,600
    @fp_window.index = 0
  end
  #--------------------------------------------------------------------------
  # ● 结束使用内力
  #--------------------------------------------------------------------------
  def end_fp_select
    # 释放内力窗口
    @fp_window.dispose
    @fp_window = nil
    return_main_menu(2)
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (内力选择)
  #--------------------------------------------------------------------------
  def update_phase1_fp_select
    @fp_window.visible = true
    # 刷新物品窗口
    @fp_window.update
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 选择物品结束
      end_fp_select
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 没有装备内功
      if @actor.fp_kf_id < 12
        # 播放冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        show_text($data_text.no_neigong)
        return
      end
      # 播放确认 SE
      $game_system.se_play($data_system.decision_se)
      @fp_window.active = false
      case @fp_window.index
      when 0 # 加力
        # 生成加力窗口
        @num_window = Window_InputNumber.new(3)
        @num_window.x,@num_window.y = 384,320
        @num_window.opacity,@num_window.back_opacity = 255,255
        @num_window.number = @actor.fp_plus
      when 1 # 吸气
        recover
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 吸气恢复
  #--------------------------------------------------------------------------
  def recover
    # 内力不足20
    if @actor.fp < 20
      show_text($data_text.no_fp)
      @fp_window.active = true
      return
    end
    # 生命已满
    if @actor.hp == @actor.maxhp
      show_text($data_text.hp_full)
      @fp_window.active = true
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
      show_text($data_text.hp_recover)
      @fp_window.active = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (加力输入)
  #--------------------------------------------------------------------------
  def update_phase1_num_input
    @num_window.active = true
    @num_window.update
    # 按下 B 键的情况
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @num_window.dispose
      @num_window = nil
      @fp_window.active = true
      return
    end
    # 按下 C 键的情况
    if Input.trigger?(Input::C)
      # 播放确认 SE
      $game_system.se_play($data_system.decision_se)
      @actor.fp_plus = @num_window.number
      fpp_max = @actor.fp_kf_lv/2
      if @actor.fp_plus >= fpp_max
        @actor.fp_plus = fpp_max
        text = $data_text.fp_plus_max.dup
        text.gsub!("fp_plus",fpp_max.to_s)
        @num_window.visible = false
        show_text(text)
      end
      @num_window.dispose
      @num_window = nil
      @fp_window.active = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 开始使用绝招
  #--------------------------------------------------------------------------
  def start_skill_select
    @sp_list = @actor.skills
    list = []
    # 调整绝招命令长度
    @sp_list.each do |i|
      name = $data_skills[i].name
      list.push(name)
    end
    list.fill_space_to_max
    # 生成绝招窗口
    @skill_window=Window_Command.new(list.max_length*12+80,list,1,1,1,0,0,320)
    @skill_window.x = (640 - @skill_window.width)/2
    @skill_window.z,@skill_window.index = 600,0
  end
  #--------------------------------------------------------------------------
  # ● 结束选择绝招
  #--------------------------------------------------------------------------
  def end_skill_select(n_phase)
    # 释放物品窗口
    @skill_window.dispose
    @skill_window = nil
    case n_phase
    when 0
      @phase = 1
      return_main_menu
    when 1
      start_phase1(1)
    when 2
      start_phase2
    when 3
      start_phase3(@actor)
    end
  end
end  