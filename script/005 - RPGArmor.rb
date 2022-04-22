#==============================================================================
# ■ RPG::Armor
#------------------------------------------------------------------------------
# 　增加Armor模块属性
#   类型kind(内建定义)：0-衣服，1-背心，2-饰品，3-鞋子，4-腰带，5-披风，6-钓竿
#   丢弃can_drop：true-可丢弃，false-不可丢弃
#   出售can_sell：true-可出售，false-不可出售
#   经验exp：中年妇女任务所需经验，-1则表示不会成为寻物任务目标
#==============================================================================

module RPG
  class Armor
    #--------------------------------------------------------------------------
    # ● 定义实例变量
    #--------------------------------------------------------------------------
    attr_accessor :can_drop                 # 是否可丢弃
    attr_accessor :can_sell                 # 是否可出售
    attr_accessor :add_hit                  # 增加命中
    attr_accessor :add_eva                  # 增加闪避
    attr_accessor :add_atk                  # 增加攻击
    attr_accessor :add_def                  # 增加防御
    attr_accessor :add_str                  # 增加膂力
    attr_accessor :add_agi                  # 增加敏捷
    attr_accessor :add_int                  # 增加悟性
    attr_accessor :add_bon                  # 增加根骨
    attr_accessor :exp                      # 经验
    #--------------------------------------------------------------------------
    # ● 初始化对像
    #--------------------------------------------------------------------------
    def initialize
      super
      @can_drop = true
      @can_sell = true
      @add_hit = 0
      @add_eva = 0
      @add_atk = 0
      @add_def = 0
      @add_str = 0
      @add_agi = 0
      @add_int = 0
      @add_bon = 0
      @exp = 0
    end
  end
end