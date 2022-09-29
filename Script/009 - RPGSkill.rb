#==============================================================================
# ■ RPG::Skill
#------------------------------------------------------------------------------
# 　增加Skill模块属性
#   type  : 0--BUFF/DEBUFF，1--控制，2--伤害，3--其他(包含多种结果)
#   type,target主要方便绝招使用判定
#==============================================================================

module RPG
  class Skill
    #--------------------------------------------------------------------------
    # ● 定义实例变量
    #--------------------------------------------------------------------------
    attr_accessor :type                     # 绝招类型
    attr_accessor :target                   # 绝招目标
    attr_accessor :hp_cost                  # 生命消耗
    attr_accessor :fp_cost                  # 内力消耗
    attr_accessor :mp_cost                  # 法力消耗
    attr_accessor :require                  # 使用要求
    attr_accessor :use_text                 # 使用描述
    attr_accessor :success_text             # 成功描述
    attr_accessor :equal_text               # 平局描述
    attr_accessor :fail_text                # 失败描述
    attr_accessor :end_text                 # 效果结束描述
    attr_accessor :crash_skill              # 绝招冲突
    attr_accessor :magic_data               # 法术数据
    #--------------------------------------------------------------------------
    # ● 初始化对像
    #--------------------------------------------------------------------------
    def initialize
      super
      @type = 0
      @target = 0
      @hp_cost = 0
      @fp_cost = 0
      @mp_cost = 0
      @require = []
      @use_text = []
      @success_text = []
      @equal_text = []
      @fail_text = []
      @end_text = []
      @crash_skill = []
      @magic_data = []
    end
  end
end