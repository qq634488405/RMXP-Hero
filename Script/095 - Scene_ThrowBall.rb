#==============================================================================
# ■ Scene_ThrowBall
#------------------------------------------------------------------------------
# 　处理小游戏投篮。
#==============================================================================

class Scene_ThrowBall
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    $eat_flag = true
    @actor = $game_actor
    @score,@dir,@step = 0,1,1
    # 设置球坐标
    @ball1_x,@ball2_x,@ball2_y = 119,155,215
    # 获取角色图
    @char_pic = Bitmap.new("Graphics/Characters/"+@actor.character_name)
    ch = @char_pic.rect.height / 4
    cw = @char_pic.rect.width / 4
    @right_char = Rect.new(3*cw,2*ch,cw,ch)
    # 获取球图片
    @ball_pic = RPG::Cache.picture("Basketball.png")
    @ball_rect = Rect.new(0,0,12,12)
    @main_window = Window_Base.new(0,0,640,480)
    # 失败次数
    @fail = 0
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
    @main_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    @main_window.contents.clear
    update_main
    # 按下B键的情况
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 还原 BGM
      $game_system.bgm_play($game_temp.map_bgm)
      $scene = Scene_Map.new
      return
    end
    # 按下C键的情况
    if Input.trigger?(Input::C)
      case @step
      when 1 # 初始状态
        @step = 2
      when 2 # 上方球开始移动
        if @ball1_x > 110 and @ball1_x < 128
          @step = 3
          @score += 10
        else
          @step = 1
          @ball1_x = 119
          @fail += 1
          for i in 0..10
            # 刷新画面
            Graphics.update
          end
          # 出错次数满7次
          if @fail == 7
            # 还原 BGM
            $game_system.bgm_play($game_temp.map_bgm)
            $scene = Scene_Map.new
            return
          end
        end
      end
    end
    @actor.ball = @score if @score > @actor.ball
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面(主界面)
  #--------------------------------------------------------------------------
  def update_main
    # 描绘篮筐
    draw_frame
    # 更新球位置
    update_ball
    draw_score
  end
  #--------------------------------------------------------------------------
  # ● 描绘得分
  #--------------------------------------------------------------------------
  def draw_score
    # 描绘得分
    max_length = [[@score.to_s.size,@actor.ball.to_s.size].max,5].min
    str_format = "%0" + max_length.to_s + "d"
    now_score = sprintf(str_format,@score)
    now_top = sprintf(str_format,@actor.ball)
    text1 = $data_text.game_score[0] + now_score
    text2 = $data_text.game_score[1] + now_top
    @main_window.contents.draw_text(0,0,608,32,text1,1)
    @main_window.contents.draw_text(0,32,608,32,text2,1)
  end
  #--------------------------------------------------------------------------
  # ● 描绘篮筐
  #--------------------------------------------------------------------------
  def draw_frame
    color = @main_window.normal_color
    @main_window.contents.fill_rect(450, 100, 2, 210,color)
    @main_window.contents.fill_rect(400, 85, 2, 60,color)
    @main_window.contents.fill_rect(400, 105, 50, 1,color)
    @main_window.contents.fill_rect(400, 135, 50, 1,color)
    @main_window.contents.fill_rect(370, 125, 30, 1,color)
    @main_window.contents.fill_rect(375, 135, 20, 1,color)
    @main_window.contents.fill_rect(375, 125, 1, 17,color)
    @main_window.contents.fill_rect(395, 125, 1, 17,color)
    @main_window.contents.fill_rect(20, 310, 568, 1,color)
    @main_window.contents.blt(125,265,@char_pic,@right_char)
    @main_window.contents.fill_rect(50, 60, 150, 1,color)
    @main_window.contents.fill_rect(50, 83, 150, 1,color)
    @main_window.contents.fill_rect(50, 60, 1, 23,color)
    @main_window.contents.fill_rect(200, 60, 1, 24,color)
    @main_window.contents.fill_rect(115, 83, 1, 5,color)
    @main_window.contents.fill_rect(135, 83, 1, 5,color)
  end
  #--------------------------------------------------------------------------
  # ● 更新球位置
  #--------------------------------------------------------------------------
  def update_ball
    case @step
    when 1 # 初始位置
      @ball1_x,@ball2_x=119,155
      @main_window.contents.blt(@ball1_x,66,@ball_pic,@ball_rect)
      @main_window.contents.blt(@ball2_x,290,@ball_pic,@ball_rect)
    when 2 # 上部左右移动
      case @dir
      when 1 # 向右
        @ball1_x += rand(4) + 1
        @dir = 2 if @ball1_x >= 186
      when 2 # 向左
        @ball1_x -= rand(4) + 1
        @dir = 1 if @ball1_x <= 52
      end
      @main_window.contents.blt(@ball1_x,66,@ball_pic,@ball_rect)
      @main_window.contents.blt(@ball2_x,290,@ball_pic,@ball_rect)
    when 3 # 进球
      @main_window.contents.blt(@ball1_x,66,@ball_pic,@ball_rect)
      y = get_ball_y
      @main_window.contents.blt(@ball2_x,y,@ball_pic,@ball_rect)
      @ball2_x += 2 if @ball2_x < 379
      @ball2_x = [@ball2_x,379].min
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取球的Y坐标
  #--------------------------------------------------------------------------
  def get_ball_y
    # 初始位置
    if @ball2_x == 155
      @ball2_y = 113
      return 290
    end
    # 篮筐正上方
    if @ball2_x == 379
      @ball2_y += 2
      @step = 1 if @ball2_y>=290
      return @ball2_y
    end
    y =(379-@ball2_x)**2
    y *= 0.004162330905
    return Integer(y+105)
  end
end