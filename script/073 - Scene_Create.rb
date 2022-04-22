#==============================================================================
# ■ Scene_Create
#------------------------------------------------------------------------------
# 　自定义创建一个新角色
#==============================================================================
class Scene_Create
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    # 生成索引
    @index = 0
    @phase = 1
    $word=""
    @actor=$game_actor
    # 生成窗口
    @sprite = Sprite.new
    @sprite.bitmap = Bitmap.new("Graphics/Pictures/BG.png")
    @sprite.x = 0
    @sprite.y = 0
    @create_window = Window_Create.new
    @create_window.index = 0
    $game_system.bgm_play($data_system.create_bgm) 
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      Graphics.frame_reset
      # 刷新游戏画面
      Graphics.update
      # 刷新输入情报
      Input.update
      # 刷新画面
      update
      # 如果画面被切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @create_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 选择退出
  #--------------------------------------------------------------------------
  def on_cancel
    # 播放取消SE
    $game_system.se_play($data_system.cancel_se)
    # 淡入淡出 BGM、BGS、ME
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    $scene = nil
  end
  #--------------------------------------------------------------------------
  # ● 改变角色名称
  #--------------------------------------------------------------------------
  def change_name
    # 按下确定的情况
    if Input.trigger?(Input::C)
      # 播放决定SE
      $game_system.se_play($data_system.decision_se)
      # 打开输入框
      text_thread=Thread.new{$game_system.input_text}
      text_thread.exit
      @actor.name=$game_system.output_text
      # 检查名字长度
      check_name_size
      $game_system.clear_input
    end
  end
  #--------------------------------------------------------------------------
  # ● 检查姓名长度
  #--------------------------------------------------------------------------
  def check_name_size
    if @actor.name.size>10 or @actor.name==""
      $game_system.se_play($data_system.buzzer_se)
      p $data_system.name_error
      @actor.name=""
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置密码
  #--------------------------------------------------------------------------
  def set_password
    # 按下确定的情况
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      # 输入框
      text_thread=Thread.new{$game_system.input_text}
      text_thread.exit
      $word=$game_system.output_text
      $game_system.clear_input
    end
  end
  #--------------------------------------------------------------------------
  # ● 改变角色性别
  #--------------------------------------------------------------------------
  def change_gender
    # 按下左或右的情况
    if Input.trigger?(Input::LEFT) or Input.trigger?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      @create_window.gender = (@create_window.gender + 1) % 2
    # 按下确定的情况
    elsif Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      @index = (@index + 1) % 4
      @create_window.index = @index
    end
  end
  #--------------------------------------------------------------------------
  # ● 改变角色属性
  #--------------------------------------------------------------------------
  def change_ability
    # 按下左的情况
    if Input.trigger?(Input::LEFT)
      @create_window.base_attr[@index] -= 1
      # 属性小于10的情况
      if @create_window.base_attr[@index]<10
        @create_window.base_attr[@index]=10
        $game_system.se_play($data_system.buzzer_se)
      else
        $game_system.se_play($data_system.cursor_se)
      end
      return
    end
    # 按下右的情况
    if Input.trigger?(Input::RIGHT)
      # 总属性点不能超过80
      if @create_window.attr_sum<80
        @create_window.base_attr[@index] += 1
        # 属性超过30的情况
        if @create_window.base_attr[@index]>30
          @create_window.base_attr[@index]=30
          $game_system.se_play($data_system.buzzer_se)
        else
          $game_system.se_play($data_system.cursor_se)
        end
      else
        $game_system.se_play($data_system.buzzer_se)
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 进入下一步
  #--------------------------------------------------------------------------
  def next_phase
    # 按下确定的情况
    if Input.trigger?(Input::C)
      # 出错退出标志
      quit_flag=false
      quit_flag=true if @actor.name.size>10 or @actor.name==""
      # 检查密码长度
      if $word.size>18
        p $data_system.long_pas
        quit_flag=true
      end
      # 检查玩家姓名与NPC是否重名
      $data_enemies.each do |i|
        if i !=nil
          quit_flag=true if @actor.name == i.name
        end
        break if quit_flag
      end
      # 检查玩家姓名与恶人是否重名
      $data_text.bad_name1.each do |i|
        $data_text.bad_name2.each do |j|
          quit_flag=true if i+j==@actor.name
          break if quit_flag
        end
      end
      # 标志为真则创建失败
      if quit_flag
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 设置性别
      @actor.gender=@create_window.gender
      # 根据性别设置战斗图及行走图
      if @actor.gender==0
        @actor.character_name="MainChar_Boy"
        @actor.battler_name="Player_Boy"
      else
        @actor.character_name="MainChar_Girl"
        @actor.battler_name="Player_Girl"
      end
      # 进入步序2，索引归零
      @phase,@index=2,0
      @create_window.phase,@create_window.index=2,0
      $game_system.se_play($data_system.decision_se)
    end
  end
  #--------------------------------------------------------------------------
  # ● 创建完成
  #--------------------------------------------------------------------------
  def create
    # 按下确定的情况
    if Input.trigger?(Input::C)
      if @create_window.attr_sum==80
        # 设置玩家先天属性
        $game_system.se_play($data_system.decision_se)
        @actor.base_str=@create_window.base_attr[0]
        @actor.base_agi=@create_window.base_attr[1]
        @actor.base_int=@create_window.base_attr[2]
        @actor.base_bon=@create_window.base_attr[3]
        @actor.base_fac=rand(20)+30-@actor.base_str
        @actor.base_luc=rand(20)+10
        @actor.gain_item(3,4)
        # 初始化任务
        $game_task = Game_Task.new
        # 设置初期位置的地图
        $game_map.setup($data_system.start_map_id)
        # 主角向初期位置移动
        $game_player.moveto($data_system.start_x, $data_system.start_y)
        # 刷新主角
        $game_player.refresh
        # 执行地图设置的 BGM 与 BGS 的自动切换
        $game_map.autoplay
        # 刷新地图 (执行并行事件)
        $game_map.update
        # 设置系统默认字体
        Font.default_name = (["WQX12","宋体","黑体","楷体"])
        # 保存存档
        $game_temp.write_save_data
        $scene = Scene_Map.new
      else
        $game_system.se_play($data_system.buzzer_se)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 控制处理
  #--------------------------------------------------------------------------
  def update_commands
    index_num = @phase ==1 ? 4 : 5
    # 按下取消的情况
    if Input.trigger?(Input::B)
      on_cancel
    # 按下上的情况
    elsif Input.trigger?(Input::UP)
      $game_system.se_play($data_system.cursor_se)
      @index = (@index + index_num -1) % index_num
      @create_window.index = @index
    # 按下下的情况
    elsif Input.trigger?(Input::DOWN)
      $game_system.se_play($data_system.cursor_se)        
      @index = (@index + 1) % index_num
      @create_window.index = @index
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def update
    @phase ==1 ? update_phase1 : update_phase2
  end
  #--------------------------------------------------------------------------
  # ● 刷新阶段一
  #--------------------------------------------------------------------------
  def update_phase1
    case @index    
    when 0 # 选择角色图
      change_gender
    when 1 # 修改姓名
      change_name
    when 2 # 设置密码
      set_password
    when 3 # 下一步
      next_phase
    end
    update_commands    
    @create_window.update
  end
  #--------------------------------------------------------------------------
  # ● 刷新阶段二
  #--------------------------------------------------------------------------
  def update_phase2
    case @index    
    when 0,1,2,3 # 调整属性
      change_ability
    when 4 # 确认
      create
    end
    update_commands    
    @create_window.update
  end
end