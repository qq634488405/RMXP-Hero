#==============================================================================
# ■ RPG::Enemy
#------------------------------------------------------------------------------
# 　增加Enemy模块属性
#   菜单类型type：0-常规，大于0为各门派师父，-1为商人
#   道德标记morals：战胜后选择砍头主角道德变化
#   技能列表skill_list：[[技能,等级],[技能,等级]...]
#   装备技能skill_use：[拳脚,兵刃,轻功,内功,招架,法术]
#   物品列表itemx：[种类,ID]
#   ·种类：1-物品，2-武器，3-防具
#   ·隐藏：ID为负数在查看中不显示，ID为正数在查看中显示
#   卖出物品sell_item：[[物品种类,ID]...]
#   ·交易类型：商人且卖出物品为空为当铺，否则商店
#==============================================================================

module RPG
  class Enemy
    #--------------------------------------------------------------------------
    # ● 定义实例变量
    #--------------------------------------------------------------------------
    attr_accessor :type                     # 类型
    attr_accessor :gender                   # 性别
    attr_accessor :age                      # 年龄
    attr_accessor :base_hit                 # 先天命中
    attr_accessor :base_eva                 # 先天闪避
    attr_accessor :base_atk                 # 先天攻击
    attr_accessor :base_def                 # 先天防御
    attr_accessor :fp_plus                  # 加力
    attr_accessor :mp_plus                  # 法点
    attr_accessor :morals                   # 道德标记
    attr_accessor :base_str                 # 先天膂力
    attr_accessor :base_agi                 # 先天敏捷
    attr_accessor :base_int                 # 先天悟性
    attr_accessor :base_bon                 # 先天根骨
    attr_accessor :base_fac                 # 外貌
    attr_accessor :base_luc                 # 福源
    attr_accessor :hp                       # 生命
    attr_accessor :fp                       # 内力
    attr_accessor :maxfp                    # 内力上限
    attr_accessor :mp                       # 法力
    attr_accessor :maxmp                    # 法力上限
    attr_accessor :full_hp                  # 生命满上限
    attr_accessor :item1                    # 物品1
    attr_accessor :item2                    # 物品2
    attr_accessor :item3                    # 物品3
    attr_accessor :item4                    # 物品4
    attr_accessor :skill_use                # 装备技能
    attr_accessor :skill_count              # 技能数量
    attr_accessor :skill_list               # 技能列表
    attr_accessor :sell_count               # 出售数量
    attr_accessor :sell_item                # 卖出物品
    attr_accessor :des_text                 # 查看描述
    #--------------------------------------------------------------------------
    # ● 初始化对像
    #--------------------------------------------------------------------------
    def initialize
      super
      @type = 0
      @gender = 0
      @age = 0
      @base_hit = 0
      @base_eva = 0
      @base_atk = 0
      @base_def = 0
      @fp_plus = 0
      @mp_plus = 0
      @morals = 0
      @base_str = 0
      @base_agi = 0
      @base_int = 0
      @base_bon = 0
      @base_fac = 0
      @base_luc = 0
      @hp = 0
      @fp = 0
      @maxfp = 0
      @mp = 0 
      @maxmp = 0
      @full_hp = 0
      @item1 = [0,0]
      @item2 = [0,0]
      @item3 = [0,0]
      @item4 = [0,0]
      @skill_use = [0,0,0,0,0,0]
      @skill_count = 0
      @skill_list = []
      @sell_count = 0
      @sell_item = []
      @des_text = ["","","","",""]
    end
  end
end