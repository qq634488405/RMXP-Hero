#==============================================================================
# ■ Module::Task
#------------------------------------------------------------------------------
# 　定义Task模块属性
#==============================================================================

module RPG
  class Task
    #--------------------------------------------------------------------------
    # ● 定义实例变量
    #--------------------------------------------------------------------------
    attr_accessor :npc_list                 # 拜访/追杀任务列表
    attr_accessor :find_list                # 寻物任务列表
    attr_accessor :bad_map                  # 恶人刷新地图ID
    attr_accessor :bad_area                 # 恶人刷新坐标列表
    attr_accessor :bad_data                 # 恶人数据设定
    attr_accessor :quest_list               # 隐藏任务列表
    attr_accessor :teacher_need             # 拜师要求
    attr_accessor :tan_reward               # XX坛结束奖励
    attr_accessor :tan_finish               # 所有坛结束
    attr_accessor :tan_map_xy               # XX坛传送点
    attr_accessor :sword_weapon             # 铸剑挑战武器
    #--------------------------------------------------------------------------
    # ● 初始化对像
    #--------------------------------------------------------------------------
    def initialize
      @npc_list = []
      @find_list = []
      @bad_map = []
      @bad_area = []
      @bad_data = []
      @quest_list = {}
      @teacher_need = {}
      @tan_reward = []
      @tan_finish = ""
      @tan_map_xy = {}
      @sword_weapon = []
    end
  end
end