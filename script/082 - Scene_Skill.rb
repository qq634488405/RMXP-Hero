#==============================================================================
# ■ Scene_Skill
#------------------------------------------------------------------------------
# 　处理特技画面的类。
#==============================================================================

class Scene_Skill
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    $eat_flag = true
    @actor = $game_actor
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    @main_menu = Window_BackMenu.new(2)
    @screen = Spriteset_Map.new
    # 生成分类窗口
    @category_window=Window_Command.new(96,$data_system.skill_menu,1,5)
    @category_window.x,@category_window.y = 20,74
    @category_window.index = 0
    # 生成帮助窗口、物品窗口
    @help_window = Window_Help.new(504)
    @help_window.x,@help_window.y = 116,396
    @skill_window = Window_Skill.new
    # 关联帮助窗口
    @skill_window.help_window = @help_window
    @help_window.visible=false
    @skill_window.active=false
    @category_window.active=true
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
    @help_window.dispose
    @skill_window.dispose
    @category_window.dispose
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
    @skill_window.set_kf_type(@category_window.index)
    @skill_window.update
    update_skill
    @screen.update
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update_skill
    # 在目录窗口激活的情况下
    if @category_window.active
      @skill_window.set_kf_type(@category_window.index)
      # 按下 B 键的情况下
      if Input.trigger?(Input::B)
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        # 切换到菜单画面
        $scene = Scene_Menu.new(2)
        return
      end
      # 按下 C 键的情况下
      if Input.trigger?(Input::C)
        # 物品为空返回
        if @skill_window.skill==nil
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 激活技能菜单
        @category_window.active=false
        @skill_window.active=true
        @skill_window.index=0
        $game_system.se_play($data_system.decision_se)
        @help_window.visible=true
        @skill_window.refresh
      end
    else
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
        # 获取技能窗口当前选中的物品数据
        skill = @skill_window.skill
        id,equip = skill[0],skill[3]
        # 基本功夫和知识的情况
        if id < 12 or @category_window.index == 6
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 演奏装备 SE
        $game_system.se_play($data_system.equip_se)
        # 装备功夫
        kf_list_id = @skill_window.kf_list_index
        @actor.equip_kf(@category_window.index,kf_list_id)
        return_category
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 返回分类
  #--------------------------------------------------------------------------
  def return_category
    # 冻结物品窗口，激活目录窗口
    @skill_window.refresh
    @skill_window.active=false
    @skill_window.index=-1
    @category_window.active=true
    @help_window.visible=false
  end
end
