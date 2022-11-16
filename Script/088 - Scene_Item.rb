#==============================================================================
# ■ Scene_Item
#------------------------------------------------------------------------------
# 　处理物品画面的类。
#==============================================================================

class Scene_Item
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    $eat_flag = true
    @actor = $game_actor
    @main_menu = Window_BackMenu.new(1)
    @screen = Spriteset_Map.new
    # 生成分类窗口
    @category_window=Window_Command.new(96,$data_system.item_menu,1,5)
    @category_window.x,@category_window.y = 20,74
    @category_window.index = 0
    # 生成帮助窗口、物品窗口
    @help_window = Window_Help.new(600)
    @help_window.x,@help_window.y = 20,396
    @item_window = Window_Item.new
    # 关联帮助窗口
    @item_window.help_window = @help_window
    @help_window.visible=false
    @item_window.active=false
    # 生成对话窗口
    @talk_window = Window_Help.new(480,160)
    @talk_window.visible=false
    @talk_window.x,@talk_window.y = 80,304
    @talk_window.z = @help_window.z + 100
    # 生成选择窗口
    @confirm_window=Window_Command.new(240,$data_system.confirm_choice,2,3)
    @confirm_window.x,@confirm_window.y,@confirm_window.z = 200,416,800
    @confirm_window.visible,@confirm_window.active=false,false
    @category_window.active=true
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
    # 装备过渡
    Graphics.freeze
    # 释放窗口
    @help_window.dispose
    @item_window.dispose
    @category_window.dispose
    @talk_window.dispose
    @confirm_window.dispose
    @main_menu.dispose
    @screen.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新窗口
    @help_window.update
    @main_menu.update
    @help_window.visible=false
    @category_window.update
    @item_window.set_item_type(@category_window.index)
    @item_window.update
    @talk_window.update
    @confirm_window.update
    update_item
    @screen.update
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update_item
    # 在目录窗口激活的情况下
    if @category_window.active
      @item_window.set_item_type(@category_window.index)
      # 按下 B 键的情况下
      if Input.trigger?(Input::B)
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        # 切换到菜单画面
        $scene = Scene_Menu.new(1)
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
        @category_window.active=false
        @item_window.active=true
        @item_window.index=0
        $game_system.se_play($data_system.decision_se)
        @help_window.visible=true
        @item_window.refresh
      end
    elsif @item_window.active
      # 按下 B 键的情况下
      if Input.trigger?(Input::B)
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        # 切换到分类
        return_category
        return
      end
      # 按下 C 键的情况下
      if Input.trigger?(Input::C)
        # 获取物品窗口当前选中的物品数据
        item = @item_window.item
        # 武器窗口处理
        unless @category_window.index !=2
          equip_item(1)
          return
        end
        # 装备窗口处理
        unless @category_window.index !=3
          equip_item(2)
          return
        end
        # 丢弃窗口处理
        unless @category_window.index !=5
          drop_item
          return
        end
        # 不能使用的情况下
        unless @actor.item_can_use?(item[1])
          # 演奏冻结 SE
          $game_system.se_play($data_system.buzzer_se)
          # 切换到分类
          return_category
          return
        end
        # 如果物品是书籍
        if $data_items[item[1]].is_book
          read_book
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
        return_category
      end
      # 按下 左 键的情况下
      if Input.trigger?(Input::LEFT)
        # 刷新描述文本
        @item_window.set_page(0)
        @item_window.update_help
        return
      end
      # 按下 右 键的情况下
      if Input.trigger?(Input::RIGHT)
        # 刷新描述文本
        @item_window.set_page(1)
        @item_window.update_help
      end
    elsif @confirm_window.active
      # 按下 B 键的情况下
      if Input.trigger?(Input::B)
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        # 切换到分类
        return_item
        return
      end
      # 按下 C 键的情况下
      if Input.trigger?(Input::C)
        # 自宫询问
        case @confirm_window.index
        when 0 # 确认
          case @ask_step
          when 1 # 再次询问
            talk = $data_text.caihua_ask2.dup
            @talk_window.auto_text(talk)
            @ask_step = 2
          when 2 # 性别变更
            @actor.gender = 2
            return_item
          end
          return
        when 1 # 放弃
          return_item
          return
        end
      end
    else
      # 按下 B 键或 C 键的情况下
      if Input.trigger?(Input::B) or Input.trigger?(Input::C)
        @talk_window.visible = false
        @item_window.active = true
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 返回分类
  #--------------------------------------------------------------------------
  def return_category
    # 冻结物品窗口，激活目录窗口
    @item_window.refresh
    @item_window.active=false
    @item_window.index=-1
    @item_window.set_page(0)
    @category_window.active=true
    @help_window.visible=false
    @talk_window.visible=false
    @confirm_window.visible=false
  end
  #--------------------------------------------------------------------------
  # ● 返回物品列表
  #--------------------------------------------------------------------------
  def return_item
    @talk_window.visible=false
    @confirm_window.active=false
    @confirm_window.visible=false
    @item_window.active=true
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
    return_category
  end
  #--------------------------------------------------------------------------
  # ● 读书
  #--------------------------------------------------------------------------
  def read_book
    # 获取物品窗口当前选中的物品数据
    item = @item_window.item
    book_id = item[1]
    # 菜花宝典
    if book_id == 20
      if @actor.gender == 1 # 女性
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        # 切换到物品列表
        return_item
        return
      elsif @actor.gender == 0 # 男性
        text = $data_text.caihua_ask1.dup
        draw_error(text)
        @confirm_window.visible = true
        @confirm_window.active = true
        @confirm_window.index = 0
        @ask_step = 1
        return
      end
    end
    # 读书识字等级为0
    if @actor.get_kf_level(11) == 0
      text = $data_text.no_int_text.dup
      # 演奏冻结 SE
      $game_system.se_play($data_system.buzzer_se)
      draw_error(text)
      show_delay
      return
    end
    # 门派非逍遥派且已有门派
    if @actor.class_id != 9 and @actor.class_id != 0
      text = $data_text.not_read_text.dup
      # 演奏冻结 SE
      $game_system.se_play($data_system.buzzer_se)
      draw_error(text)
      show_delay
      return
    end
    @actor.class_id = 9
    $scene = Scene_Study.new(book_id,1)
  end
  #--------------------------------------------------------------------------
  # ● 丢弃物品
  #--------------------------------------------------------------------------
  def drop_item
    # 获取物品窗口当前选中的物品数据
    item = @item_window.item
    bag_id = @item_window.bag_index
    flag = @actor.lose_bag_id(bag_id)
    return_category if flag
  end
  #--------------------------------------------------------------------------
  # ● 描绘错误信息
  #--------------------------------------------------------------------------
  def draw_error(text)
    @item_window.active = false
    @talk_window.auto_text(text)
    @talk_window.visible = true
  end
  #--------------------------------------------------------------------------
  # ● 消息显示
  #--------------------------------------------------------------------------
  def show_delay
    # 刷新画面
    for i in 1..40
      Graphics.update
    end
    @talk_window.visible = false
    @item_window.active = true
  end
end
