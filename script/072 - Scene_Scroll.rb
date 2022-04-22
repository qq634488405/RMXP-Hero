#==============================================================================
# ■ Scene_Scroll
#------------------------------------------------------------------------------
# 　处理开始滚动字幕的类。
#==============================================================================

class Scene_Scroll
  #--------------------------------------------------------------------------
  # ● 初始化
  #     type  :   1--开局，2--我是谁结局，3--东方求败结局，4--道德和尚结局
  #--------------------------------------------------------------------------
  def initialize(type)
    $eat_flag = false
    # 生成窗口
    @type = type
    if @type == 1
      # 根据type设置对应文本及跳转
      @all_text = $data_text.scroll_start
      @next_step = "new_game"
      head_name=$data_text.scroll_name[0]
      @audio_file=$data_system.begin_bgm
    else
      @all_text = $data_text.scroll_end[@type-2]
      @next_step = "$scene = Scene_End.new"
      head_name=$data_text.scroll_name[1]
      @audio_file=$data_system.end_bgm
    end
    @sprite = Sprite.new
    @sprite.bitmap = Bitmap.new("Graphics/Pictures/BG.png")
    @sprite.x = 0
    @sprite.y = 0
    # 生成标题栏
    @head=Sprite.new
    @head.bitmap=Bitmap.new(640,24)
    color=Color.new(144,176,87)
    temp_rect=@head.bitmap.rect
    @head.bitmap.fill_rect(temp_rect,color)
    @head.bitmap.font.color.set(0,0,0)
    @head.bitmap.font.size=24
    @head.bitmap.draw_text(0,0,640,24,head_name,1)
  end
  #--------------------------------------------------------------------------
  # ● 字幕开始
  #--------------------------------------------------------------------------
  def scene_start
    # 将文本分行
    text_lines = @all_text.split(/\n/)
    @scroll_bitmap = Bitmap.new(640,32 * text_lines.size)
    @scroll_bitmap.font.color.set(0,0,0)
    @scroll_bitmap.font.size=24
    # 逐行描绘文本
    text_lines.each_index do |i|
      line = text_lines[i]
      @scroll_bitmap.draw_text(0,i * 32,640,32,line,1)
    end
    @scroll_sprite = Sprite.new(Viewport.new(0,50,640,380))
    @scroll_sprite.bitmap = @scroll_bitmap
    @scroll_sprite.oy = -430
    @frame_index = 0
    @last_flag = false
  end
  #--------------------------------------------------------------------------
  # ● 字幕结束
  #--------------------------------------------------------------------------
  def scene_end
    # 释放
    @scroll_bitmap.clear
    @scroll_sprite.dispose
    @scroll_bitmap.dispose
    @head.bitmap.clear
    @head.bitmap.dispose
    @head.dispose
    @sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 判断字幕是否结束
  #--------------------------------------------------------------------------
  def last?
    return (@frame_index >= @scroll_sprite.bitmap.height + 480)
  end
  #--------------------------------------------------------------------------
  # ● 字幕到末尾
  #--------------------------------------------------------------------------
  def last
    if not @last_flag
      Audio.bgm_fade(3000)
      @last_flag = true
      @last_count = 0
    else
      @last_count += 1
    end
    if @last_count >= 15
      eval(@next_step)
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    @frame_index += 1
    return if cancel?
    last if last?
    @scroll_sprite.oy += 1
  end
  #--------------------------------------------------------------------------
  # ● 取消字幕
  #--------------------------------------------------------------------------
  def cancel?
    # 按下取消
    if Input.trigger?(Input::B)
      eval(@next_step)
      return true
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    scene_start
    # 播放BGM
    $game_system.bgm_play(@audio_file) 
    # 开始过渡
    Graphics.transition
    # 主循环
    loop do
      # 刷新画面
      Graphics.update
      # 刷新输入信息
      Input.update
      update
      if $scene != self
        break
      end
    end
    # 冻结
    Graphics.freeze
    scene_end
  end
  #--------------------------------------------------------------------------
  # ● 开始新游戏
  #--------------------------------------------------------------------------
  def new_game
    # 停止背景音乐
    Audio.bgm_stop
    # 画面帧数清0
    Graphics.frame_count = 0
    # 设置游戏对象
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actor         = Game_Actor.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    # 切换创建角色画面
    $scene = Scene_Create.new
  end
end