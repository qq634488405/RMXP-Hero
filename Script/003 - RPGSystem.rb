#==============================================================================
# ■ RPG::System
#------------------------------------------------------------------------------
# 　增加System模块属性
#   命中描述hit_word：[[伤害,描述]...]...]
#   外伤描述out_hurt：[[百分比,描述]...]
#   内伤描述in_hurt：[[百分比,描述]...]
#==============================================================================

module RPG
  class System
    #--------------------------------------------------------------------------
    # ● 定义实例变量
    #--------------------------------------------------------------------------
    attr_accessor :falv_factor              # 法术等级系数
    attr_accessor :sword_hurt               # 铸剑毒伤
    attr_accessor :fire_hurt                # 法术火伤
    attr_accessor :thunder_hurt             # 法术雷伤
    attr_accessor :levels                   # 等级描述
    attr_accessor :attack_lv                # 出手等级
    attr_accessor :school                   # 门派
    attr_accessor :marry_text               # 结婚描述
    attr_accessor :young_face               # 外貌描述(16岁前)
    attr_accessor :boy_face                 # 外貌描述(男)
    attr_accessor :girl_face                # 外貌描述(女)
    attr_accessor :hit_place                # 攻击部位
    attr_accessor :sword_name1              # 武器前缀
    attr_accessor :sword_name2              # 武器中缀
    attr_accessor :sword_name3              # 武器后缀
    attr_accessor :no_damage                # 无伤害描述
    attr_accessor :hit_word                 # 命中描述
    attr_accessor :fa_damage                # 法术伤害描述
    attr_accessor :out_hurt                 # 外伤描述
    attr_accessor :in_hurt                  # 内伤描述
    attr_accessor :hand_def                 # 拳脚招架描述
    attr_accessor :weapon_def               # 兵刃招架描述
    attr_accessor :sp_def                   # 特殊格挡描述
    attr_accessor :menu_type                # 菜单样式
    attr_accessor :game_choice              # 游戏厅选择菜单
    attr_accessor :boss3_choice             # BOSS选择菜单
    attr_accessor :net_battle_choice        # 联机对战菜单
    attr_accessor :confirm_choice           # 确认菜单
    attr_accessor :main_menu                # 主菜单
    attr_accessor :look_menu                # 查看菜单
    attr_accessor :item_menu                # 物品菜单
    attr_accessor :skill_menu               # 技能菜单
    attr_accessor :sys_menu                 # 功能菜单
    attr_accessor :fp_menu                  # 内力菜单
    attr_accessor :mp_menu                  # 法力菜单
    attr_accessor :battle_menu              # 战斗菜单
    attr_accessor :battle_fp                # 战斗内力菜单
    attr_accessor :sword_menu               # 铸剑类别
    attr_accessor :cheat_main               # 作弊主菜单
    attr_accessor :cheat_status             # 作弊查看菜单
    attr_accessor :cheat_skill              # 作弊技能菜单
    attr_accessor :fly_menu                 # 轻功菜单
    attr_accessor :fly_position             # 轻功地点
    attr_accessor :direction_menu           # 方向菜单
    attr_accessor :master_menu              # 老管家菜单
    attr_accessor :jiaju_menu               # 家具菜单
    attr_accessor :couple_menu              # 夫妻菜单
    attr_accessor :marry_menu               # 婚姻菜单
    attr_accessor :home_position            # 房屋传送位置
    attr_accessor :chara_set                # 设定人物
    attr_accessor :input_pas                # 输入密码
    attr_accessor :weapon_title             # 输入武器名字提示
    attr_accessor :set_weapon_name          # 设置自制武器名字
    attr_accessor :have_pas                 # 已输入密码
    attr_accessor :no_pas                   # 未输入密码
    attr_accessor :long_pas                 # 密码过长
    attr_accessor :error_pas                # 密码错误
    attr_accessor :name_error               # 密码错误
    attr_accessor :cheat_code               # 作弊密码
    attr_accessor :error_save               # 无效存档
    attr_accessor :attr_name                # 属性名称
    attr_accessor :npc_status_text          # NPC查看
    attr_accessor :player_status            # 玩家查看
    attr_accessor :end_status               # 结局状态
    attr_accessor :password_bgm             # 密码BGM
    attr_accessor :normal_bgm               # 普通战斗BGM
    attr_accessor :boss_bgm                 # BOSS战斗BGM
    attr_accessor :net_bgm                  # 联机战斗BGM
    attr_accessor :begin_bgm                # 开场BGM
    attr_accessor :end_bgm                  # 结局BGM
    attr_accessor :dance_bgm                # 跳舞BGM
    attr_accessor :throw_ball_bgm           # 投篮BGM
    attr_accessor :create_bgm               # 创建人物BGM
    attr_accessor :move_se                  # 切换地图SE
    #--------------------------------------------------------------------------
    # ● 初始化对像
    #--------------------------------------------------------------------------
    def initialize
      super
      @sword_hurt = ""
      @fire_hurt = ""
      @thunder_hurt = ""
      @levels = []
      @attack_lv = []
      @school = []
      @marry_text = []
      @young_face = ""
      @boy_face = []
      @girl_face = []
      @other_face = []
      @hit_place = []
      @sword_name1 = []
      @sword_name2 = []
      @sword_name3 = []
      @no_damage = ""
      @hit_word = []
      @fa_damage = []
      @out_hurt = []
      @in_hurt = []
      @hand_def = []
      @weapon_def = []
      @sp_def = ""
      @menu_type = []
      @game_choice = []
      @boss3_choice = []
      @net_battle_choice = []
      @confirm_choice = []
      @main_menu = []
      @look_menu = []
      @item_menu = []
      @skill_menu = []
      @sys_menu = []
      @fp_menu = []
      @mp_menu = []
      @battle_menu = []
      @battle_fp = []
      @sword_menu = []
      @cheat_main = []
      @cheat_status = []
      @cheat_skill = []
      @fly_menu = []
      @fly_position = []
      @direction_menu = []
      @master_menu = []
      @jiaju_menu = []
      @couple_menu = []
      @marry_menu = []
      @home_position = []
      @chara_set = []
      @input_pas = []
      @have_pas = ""
      @weapon_title = ""
      @set_weapon_name = []
      @no_pas = ""
      @long_pas = ""
      @error_pas = ""
      @name_error = ""
      @cheat_code = ""
      @error_save = ""
      @attr_name = []
      @npc_status_text = []
      @player_status = []
      @end_status = []
      @password_bgm = RPG::AudioFile.new
      @begin_bgm = RPG::AudioFile.new
      @boss_bgm = []
      @normal_bgm = []
      @net_bgm = RPG::AudioFile.new
      @end_bgm = RPG::AudioFile.new
      @dance_bgm = RPG::AudioFile.new
      @throw_ball_bgm = RPG::AudioFile.new
      @create_bgm = RPG::AudioFile.new
      @move_se = RPG::AudioFile.new
    end
  end
end
