#==============================================================================
# ■ Scene_Dance
#------------------------------------------------------------------------------
# 　处理小游戏跳舞毯。
#==============================================================================

class Scene_Dance
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    $eat_flag = true
    @actor = $game_actor
    @count,@score = 0,0
    # 左侧PAD窗口
    @left_window = Window_Base.new(0,0,320,480)
    # 右上箭头窗口
    @arrow_window = Window_Base.new(320,0,320,96)
    # 右侧人物窗口
    @right_window = Window_Base.new(320,96,320,384)
    # 设置四个方向人物图
    @char_pic = RPG::Cache.character(@actor.character_name,@actor.character_hue)
    cw = @char_pic.rect.width / 4
    ch = @char_pic.rect.height / 4
    @up_char = Rect.new(3*cw,3*ch,cw,ch)
    @left_char = Rect.new(cw,ch,cw,ch)
    @right_char = Rect.new(cw,2*ch,cw,ch)
    @down_char = Rect.new(0,0,cw,ch)
    @last_char = @down_char
    # 方向箭头
    @dir_pic = RPG::Cache.picture("Dir.png")
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入情报
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
    @left_window.dispose
    @arrow_window.dispose
    @right_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面(左侧画面)
  #--------------------------------------------------------------------------
  def update_left_window(x,y)
    @left_window.contents.clear
    # 描绘四方向
    bitmap = RPG::Cache.picture("PAD")
    @left_window.contents.blt(96, 208, bitmap, Rect.new(0, 0, 96, 96),255)
    if x > -1 and y > -1
      arrow_pic = Rect.new((@dir - 1) * 32,0,32,32)
      @left_window.contents.blt(x+96,y+208,@dir_pic,arrow_pic)
    end
    # 描绘得分
    max_length = [[@score.to_s.size,@actor.dance.to_s.size].max,5].min
    str_format = "%0" + max_length.to_s + "d"
    now_score = sprintf(str_format,@score)
    now_top = sprintf(str_format,@actor.dance)
    text1 = $data_text.game_score[0] + now_score
    text2 = $data_text.game_score[1] + now_top
    @left_window.contents.draw_text(0,0,288,32,text1,1)
    @left_window.contents.draw_text(0,32,288,32,text2,1)
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 计数为0则重新生成方向
    @count == 0 ? make_new_dir : @count -= 1
    # 按下B键的情况
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 还原 BGM
      $game_system.bgm_play($game_temp.map_bgm)
      $scene = Scene_Map.new
      return
    end
    # 刷新箭头窗口
    update_arrow_window
    char_dir,x,y = 0,-1,-1
    # 按下 上 键的情况
    if Input.repeat?(Input::UP)
      char_dir,x,y = 1,32,0
    # 按下 左 键的情况
    elsif Input.repeat?(Input::LEFT)
      char_dir,x,y = 2,0,32
    # 按下 下 键的情况
    elsif Input.repeat?(Input::DOWN)
      char_dir,x,y = 3,32,64
    # 按下 右 键的情况
    elsif Input.repeat?(Input::RIGHT)
      char_dir,x,y = 4,64,32
    end
    # 判断方向是否正确
    if @char_status == 0 and @count > 4 and char_dir > 0
      @char_status_count = 40
      if @dir == char_dir
        @score += 3
        @char_status = char_dir
      else
        # 恢复地图BGM
        $game_system.bgm_play($game_temp.map_bgm)
        $scene = Scene_Map.new
        return
      end
    end
    @actor.dance = @score if @score > @actor.dance
    # 刷新左右窗口
    update_left_window(x,y)
    update_right_window
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面(右上箭头窗口)
  #--------------------------------------------------------------------------
  def update_arrow_window
    @arrow_window.contents.clear
    # 计算箭头坐标
    x = 72 * (@dir - 1) + 20
    arrow_pic = Rect.new((@dir - 1) * 32,0,32,32)
    @arrow_window.contents.blt(x,10,@dir_pic,arrow_pic)
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面(右侧画面)
  #--------------------------------------------------------------------------
  def update_right_window
    color = @right_window.normal_color
    @right_window.contents.clear
    @right_window.contents.fill_rect(20, 220, 288, 1,color)
    if @char_status_count > 0
      @char_status_count -= 1
    end
    # 描绘角色状态
    char_list = [@last_char,@up_char,@left_char,@down_char,@right_char]
    @right_window.contents.blt(144,175,@char_pic,char_list[@char_status])
  end
  #--------------------------------------------------------------------------
  # ● 产生随机方向
  #--------------------------------------------------------------------------
  def make_new_dir
    # 随机生成方向，若和上次相同则重新生成
    new_dir = @dir
    while new_dir == @dir
      new_dir = rand(4)+1
    end
    @dir = new_dir
    @count = 40
    @char_status = 0
    @char_status_count=0
  end
end