#==============================================================================
# ■ Window_ShopNumber
#------------------------------------------------------------------------------
# 　商店画面、输入买卖数量的窗口。
#==============================================================================

class Window_ShopNumber < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize(type)
    super(0, 128, 368, 96)
    @type = type
    @cursor_width = 14
    @max = 1
    @price = 0
    @number = 1
    @index = 2
    refresh
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # ● 设置物品、最大个数、价格
  #--------------------------------------------------------------------------
  def set(max, price)
    @max = max
    @price = price
    @number = 1
    # 重新设置窗口位置及大小
    t_size = @max * @price
    t_size = [t_size.to_s.length*12,@max.to_s.length*16+24].max
    self.width = 152 + t_size
    self.contents.dispose
    self.contents = Bitmap.new(width - 32, height - 32)
    self.x,self.y = (640-width)/2,(480-height)/2
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 被输入的件数设置
  #--------------------------------------------------------------------------
  def number
    return @number
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    info = $data_text.shop_number[@type].deep_clone
    num = sprintf("%03d",@number.to_s)
    total_gold = @number * @price
    info.gsub!("number",num)
    info.gsub!("total",total_gold.to_s)
    auto_text(info)
  end
  #--------------------------------------------------------------------------
  # ● 刷新光标位置
  #--------------------------------------------------------------------------
  def update_cursor_rect
    self.cursor_rect.set(@index*12+76,0,@cursor_width,32)
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
    if self.active
      # 按下方向键上与下的情况下
      if Input.repeat?(Input::UP) or Input.repeat?(Input::DOWN)
        $game_system.se_play($data_system.cursor_se)
        # 取得现在位置的数字位数
        place = 10 ** (2 - @index)
        n = @number / place % 10
        @number -= n * place
        # 上为 +1、下为 -1
        n = (n + 1) % 10 if Input.repeat?(Input::UP)
        n = (n + 9) % 10 if Input.repeat?(Input::DOWN)
        # 再次设置现在位的数字
        @number += n * place
        @number = [@number,@max].min
        refresh
      end
      # 光标右
      if Input.repeat?(Input::RIGHT)
        $game_system.se_play($data_system.cursor_se)
        @index = (@index + 1) % 3
      end
      # 光标左
      if Input.repeat?(Input::LEFT)
        $game_system.se_play($data_system.cursor_se)
        @index = (@index + 2) % 3
      end
      update_cursor_rect
    end
  end
end
