#==============================================================================
# ■ Scene_Shop
#------------------------------------------------------------------------------
# 　处理商店画面的类。
#==============================================================================

class Scene_Shop
  #--------------------------------------------------------------------------
  # ● 初始化
  #--------------------------------------------------------------------------
  def initialize(id)
    @actor = $game_actor
    @id = id
    @sell_count = $data_enemies[@id].sell_count
    @type = @sell_count == 0 ? 0 : 1
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    @screen = Spriteset_Map.new
    # 对话窗口
    @shop_dialog = Window_ShopDialog.new(@type)
    # 生成信息窗口
    @info_window = Window_Help.new(640,160)
    @info_window.x,@info_window.y = 0,320
    case @type
    when 0
      # 生成卖出窗口
      @shop_window = Window_ShopSell.new
      @shop_window.active = true
      @shop_window.visible = true
      @shop_window.index = 0
      @shop_window.help_window = @info_window
    when 1
      @sell_list = $data_enemies[@id].sell_item
      @list,max_size = [],0
      @sell_list.each do |i|
        case i[0]
        when 1 # 物品
          name = $data_items[i[1]].name
        when 2 # 武器
          name = $data_weapons[i[1]].name
        when 3 # 装备
          name = $data_armors[i[1]].name
        end
        max_size = name.size/3 if name.size/3 > max_size
        @list.push(name)
      end
      @list.each_index do |i|
        # 调整物品名称长度
        @list[i] = @list[i] + "  "*(max_size - @list[i].size/3)
      end
      width = max_size * 24 + 80
      # 生成购买窗口
      @shop_window = Window_ShopBuy.new(width,@list,@sell_list,1,3)
      @shop_window.active = true
      @shop_window.visible = true
      @shop_window.help_window = @info_window
    end
    # 生成数量输入窗口
    @number_window = Window_ShopNumber.new(@type)
    @number_window.active = false
    @number_window.visible = false
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
      # 如果画面切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @info_window.dispose
    @shop_dialog.dispose
    @shop_window.dispose
    @screen.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新窗口
    @info_window.update
    @shop_dialog.update
    @shop_window.update
    @number_window.update
    @screen.update
    # 买卖窗口激活的情况，根据商店类型执行
    if @shop_window.active
      case @type
      when 0 # 当铺
        update_sell
      when 1 # 购买
        update_buy
      end
      return
    end
    # 数字输入窗口激活的情况
    if @number_window.active
      update_number
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (购买窗口激活的情况下)
  #--------------------------------------------------------------------------
  def update_buy
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 返回地图
      $scene = Scene_Map.new
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 获取物品
      @item = @shop_window.sell_item
      # 物品无效的情况下、或者价格在所持金以上的情况下
      if @item == nil or @shop_window.price > @actor.gold
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 判断是否可以获得物品
      unless @actor.can_get_item?(@item[0],@item[1])
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 如果种类是物品则激活数字输入
      if @item[0] == 1
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        @shop_window.active = false
        # 计算最大买入个数
        max = @shop_window.price == 0 ? 255 : @actor.gold / @shop_window.price
        own_number = @actor.item_number(@item[0],@item[1])
        max = [max-own_number,255].min
        @number_window.set(max, @shop_window.price)
        @number_window.active = true
        @number_window.visible = true
      else # 不是物品则交易成功
        # 获得物品
        @actor.gain_item(@item[0],@item[1])
        @actor.lose_gold(@shop_window.price)
        # 演奏商店 SE
        $game_system.se_play($data_system.shop_se)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 画面更新 (卖出窗口激活的情况下)
  #--------------------------------------------------------------------------
  def update_sell
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 返回地图
      $scene = Scene_Map.new
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 获取物品
      @item = @shop_window.item
      # 物品无效的情况下
      if @item == nil
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 如果种类为物品，且持有数量大于1则激活数字输入
      if @item[0] == 1 and @item[2] > 1
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        @shop_window.active = false
        @number_window.set(@item, max, @item.price)
        @number_window.active = true
        @number_window.visible = true
      else # 数量为1则直接交易
        # 演奏商店 SE
        $game_system.se_play($data_system.shop_se)
        bag_id = @shop_window.bag_position
        @actor.gain_gold(@shop_window.price)
        # 物品减少同时判断是否该背包位置被清除
        if @actor.lose_bag_id(bag_id)
          # 无货可卖则返回地图
          if @actor.sell_list == nil
            $scene = Scene_Map.new
          else
            @shop_window.index = 0
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (个数输入窗口激活的情况下)
  #--------------------------------------------------------------------------
  def update_number
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 设置个数输入窗口为不活动·非可视状态
      @number_window.active = false
      @number_window.visible = false
      # 激活买卖窗口
      @shop_window.active = true
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 演奏商店 SE
      $game_system.se_play($data_system.shop_se)
      # 设置个数输入窗口为不活动·非可视状态
      @number_window.active = false
      @number_window.visible = false
      # 返回商品菜单
      @shop_window.active = true
      # 根据商店类型处理
      case @type
      when 0 # 当铺
        bag_id = @shop_window.bag_position
        # 获得金钱并移除物品
        @actot.gain_gold(@shop_window.price*@number_window.number)
        # 物品减少同时判断是否该背包位置被清除
        if @actor.lose_bag_id(bag_id,@number_window.number)
          # 无货可卖则返回地图
          if @actor.sell_list.empty?
            $scene = Scene_Map.new
          else
            @shop_window.index = 0
          end
        end
      when 1 # 买入
        # 获得物品并扣除金钱
        @actor.lose_gold(@shop_window.price*@number_window.number)
        item_type,item_id = @shop_window.sell_item[0],@shop_window.sell_item[1]
        @actor.gain_item(item_type,item_id,@number_window.number)
      end
    end
  end
end
