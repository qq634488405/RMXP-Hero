#==============================================================================
# ■ RPG::Item
#------------------------------------------------------------------------------
# 　增加Item模块属性
#   类型type：0-食物，1-药物，2-其他
#   增加属性add_xxx：[类型(0-实际数值，1-百分比)，数值]
#   丢弃can_drop：true-可丢弃，false-不可丢弃
#   出售can_sell：true-可出售，false-不可出售
#   叠加can_add：true-物品栏可叠加，false-物品栏不可叠加
#   秘籍is_book：true-秘籍，false-非秘籍
#   技能skill_list：秘籍属性，[[技能ID,技能等级],[技能ID,技能等级]...]
#   经验exp：中年妇女任务所需经验，-1则表示不会成为寻物任务目标
#   使用场合occasion(内建定义)：0-平时，1-战斗中，2-菜单，3-使用，4-任意
#==============================================================================

module RPG
  class Item
    #--------------------------------------------------------------------------
    # ● 定义实例变量
    #--------------------------------------------------------------------------
    attr_accessor :type                     # 类型
    attr_accessor :add_food                 # 增加食物
    attr_accessor :add_water                # 增加饮水
    attr_accessor :add_hp                   # 增加生命
    attr_accessor :add_mhp                  # 增加生命上限
    attr_accessor :add_fp                   # 增加内力
    attr_accessor :add_mfp                  # 增加内力上限
    attr_accessor :add_mp                   # 增加法力
    attr_accessor :add_mmp                  # 增加法力上限
    attr_accessor :can_drop                 # 是否可丢弃
    attr_accessor :can_sell                 # 是否可出售
    attr_accessor :can_add                  # 是否可叠加
    attr_accessor :is_book                  # 是否为秘籍
    attr_accessor :skill_list               # 秘籍技能表
    attr_accessor :exp                      # 经验
    #--------------------------------------------------------------------------
    # ● 初始化对像
    #--------------------------------------------------------------------------
    def initialize
      super
      @type = 0
      @add_food = []
      @add_water = []
      @add_hp = []
      @add_mhp = []
      @add_fp = []
      @add_mfp = []
      @add_mp = []
      @add_mmp = []
      @can_drop = true
      @can_sell = true
      @can_add = true
      @is_book = false
      @skill_list = []
      @exp = 0
    end
  end
end