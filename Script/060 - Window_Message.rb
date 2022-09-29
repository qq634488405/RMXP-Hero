#==============================================================================
# ■ Window_Message
#------------------------------------------------------------------------------
# 　显示文章的信息窗口。
#==============================================================================

class Window_Message < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化状态
  #--------------------------------------------------------------------------
  def initialize
    super(80, 304, 480, 160)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.visible = false
    self.z = 9998
    @fade_in = false
    @fade_out = false
    @contents_showing = false
    @cursor_width = 0
    self.active = false
    self.index = -1
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    terminate_message
    $game_temp.message_window_showing = false
    if @input_number_window != nil
      @input_number_window.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 处理信息结束
  #--------------------------------------------------------------------------
  def terminate_message
    self.active = false
    self.pause = false
    self.index = -1
    self.contents.clear
    # 清除显示中标志
    @contents_showing = false
    # 呼叫信息调用
    if $game_temp.message_proc != nil
      $game_temp.message_proc.call
    end
    # 清除文章、选择项、输入数值的相关变量
    $game_temp.message_text = nil
    $game_temp.message_proc = nil
    $game_temp.choice_start = 99
    $game_temp.choice_max = 0
    $game_temp.choice_cancel_type = 0
    $game_temp.choice_proc = nil
    $game_temp.num_input_start = 99
    $game_temp.num_input_variable_id = 0
    $game_temp.num_input_digits_max = 0
    # 开放金钱窗口
    if @gold_window != nil
      @gold_window.dispose
      @gold_window = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    x = y = 0
    @cursor_width = 0
    # 到选择项的下一行字
    if $game_temp.choice_start == 0
      x = 8
    end
    # 有等待显示的文字的情况下
    if $game_temp.message_text != nil
      text = $game_temp.message_text
      # 限制文字处理
      begin
        last_text = text.clone
        text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
      end until text == last_text
      text.gsub!(/\\[Nn]\[([0-9]+)\]/) do
        $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
      end
      # 为了方便、将 "\\\\" 变换为 "\000" 
      text.gsub!(/\\\\/) { "\000" }
      # "\\C" 变为 "\001" 、"\\G" 变为 "\002"
      text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
      text.gsub!(/\\[Gg]/) { "\002" }
      # c 获取 1 个字 (如果不能取得文字就循环)
      while ((c = text.slice!(/./m)) != nil)
        # \\ 的情况下
        if c == "\000"
          # 还原为本来的文字
          c = "\\"
        end
        # \C[n] 的情况下
        if c == "\001"
          # 更改文字色
          text.sub!(/\[([0-9]+)\]/, "")
          color = $1.to_i
          if color >= 0 and color <= 7
            self.contents.font.color = text_color(color)
          end
          # 下面的文字
          next
        end
        # \G 的情况下
        if c == "\002"
          # 生成金钱窗口
          if @gold_window == nil
            @gold_window = Window_Gold.new
            @gold_window.x = 560 - @gold_window.width
            if $game_temp.in_battle
              @gold_window.y = 192
            else
              @gold_window.y = self.y >= 128 ? 32 : 384
            end
            @gold_window.opacity = self.opacity
            @gold_window.back_opacity = self.back_opacity
          end
          # 下面的文字
          next
        end
        # 另起一行文字的情况下
        if c == "\n"
          # 刷新选择项及光标的高
          if y >= $game_temp.choice_start
            @cursor_width = [@cursor_width, x].max
          end
          # y 加 1
          y += 1
          x = 0
          # 移动到选择项的下一行
          if y >= $game_temp.choice_start
            x = 8
          end
          # 下面的文字
          next
        end
        # 描绘文字
        self.contents.draw_text(4 + x, 32 * y, 40, 32, c)
        # x 为要描绘文字的加法运算
        x += self.contents.text_size(c).width
      end
    end
    # 选择项的情况
    if $game_temp.choice_max > 0
      @item_max = $game_temp.choice_max
      self.active = true
      self.index = 0
    end
    # 输入数值的情况
    if $game_temp.num_input_variable_id > 0
      digits_max = $game_temp.num_input_digits_max
      number = $game_variables[$game_temp.num_input_variable_id]
      @input_number_window = Window_InputNumber.new(digits_max)
      @input_number_window.number = number
      @input_number_window.x = self.x + 8
      @input_number_window.y = self.y + $game_temp.num_input_start * 32
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置窗口位置与不透明度
  #--------------------------------------------------------------------------
  def reset_window
    if $game_temp.in_battle
      self.y = 16
    else
      case $game_system.message_position
      when 0  # 上
        self.y = 16
      when 1  # 中
        self.y = 160
      when 2  # 下
        self.y = 304
      end
    end
    if $game_system.message_frame == 0
      self.opacity = 255
    else
      self.opacity = 0
    end
    self.back_opacity = 160
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
    # 渐变的情况下
    if @fade_in
      self.contents_opacity += 24
      if @input_number_window != nil
        @input_number_window.contents_opacity += 24
      end
      if self.contents_opacity == 255
        @fade_in = false
      end
      return
    end
    # 输入数值的情况下
    if @input_number_window != nil
      @input_number_window.update
      # 确定
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        $game_variables[$game_temp.num_input_variable_id] =
          @input_number_window.number
        $game_map.need_refresh = true
        # 释放输入数值窗口
        @input_number_window.dispose
        @input_number_window = nil
        terminate_message
      end
      return
    end
    # 显示信息中的情况下
    if @contents_showing
      # 如果不是在显示选择项中就显示暂停标志
      if $game_temp.choice_max == 0
        self.pause = true
      end
      # 取消
      if Input.trigger?(Input::B)
        if $game_temp.choice_max > 0 and $game_temp.choice_cancel_type > 0
          $game_system.se_play($data_system.cancel_se)
          $game_temp.choice_proc.call($game_temp.choice_cancel_type - 1)
          terminate_message
        end
      end
      # 确定
      if Input.trigger?(Input::C)
        if $game_temp.choice_max > 0
          $game_system.se_play($data_system.decision_se)
          $game_temp.choice_proc.call(self.index)
        end
        terminate_message
      end
      return
    end
    # 在渐变以外的状态下有等待显示的信息与选择项的场合
    if @fade_out == false and $game_temp.message_text != nil
      @contents_showing = true
      $game_temp.message_window_showing = true
      reset_window
      refresh
      Graphics.frame_reset
      self.visible = true
      self.contents_opacity = 0
      if @input_number_window != nil
        @input_number_window.contents_opacity = 0
      end
      @fade_in = true
      return
    end
    # 没有可以显示的信息、但是窗口为可见的情况下
    if self.visible
      @fade_out = true
      self.opacity -= 48
      if self.opacity == 0
        self.visible = false
        @fade_out = false
        $game_temp.message_window_showing = false
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新光标矩形
  #--------------------------------------------------------------------------
  def update_cursor_rect
    if @index >= 0
      n = $game_temp.choice_start + @index
      self.cursor_rect.set(8, n * 32, @cursor_width, 32)
    else
      self.cursor_rect.empty
    end
  end
end
