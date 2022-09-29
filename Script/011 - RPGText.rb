#==============================================================================
# ■ RPG::Text
#------------------------------------------------------------------------------
# 　定义Text模块属性
#==============================================================================

module RPG
  class Text
    #--------------------------------------------------------------------------
    # ● 定义实例变量
    #--------------------------------------------------------------------------
    attr_accessor :bad_name1                # 通缉犯姓氏
    attr_accessor :bad_name2                # 通缉犯名字
    attr_accessor :end_com                  # 结局评价
    attr_accessor :scroll_name              # 滚屏标题
    attr_accessor :scroll_start             # 开局滚屏文本
    attr_accessor :scroll_end               # 结局滚屏文本
    attr_accessor :end_text                 # 结局文本
    attr_accessor :boss_text                # BOSS对话文本
    attr_accessor :all_work                 # 义工内容
    attr_accessor :give_work_text           # 发布义工
    attr_accessor :finish_work_text         # 义工完成
    attr_accessor :work_undo_text           # 义工未完成文本
    attr_accessor :work_tired_text          # 生命不足文本
    attr_accessor :not_work_text            # 不能接取义工文本(经验高)
    attr_accessor :work_text                # 义工任务文本
    attr_accessor :has_reward_text          # 红光满面领赏
    attr_accessor :finish_task_text         # 三大任务完成
    attr_accessor :woman_ask                # 是否完成中年妇人任务
    attr_accessor :gu_no_reward             # 顾炎武无奖励
    attr_accessor :task_undo_text           # 三大任务未完成
    attr_accessor :tan_start                # 坛任务开始对话
    attr_accessor :give_task_text           # 发布三大任务
    attr_accessor :no_npc_live              # NPC杀光
    attr_accessor :no_kill_task             # 平一指不给任务
    attr_accessor :i_know_text              # 拜访对话
    attr_accessor :you_bad_text             # 玩家被通缉
    attr_accessor :bad_undo_text            # 通缉犯未杀死
    attr_accessor :no_bad_task              # 暂无通缉犯
    attr_accessor :give_bad_text            # 发布通缉
    attr_accessor :stone_undo_text          # 石料未完成
    attr_accessor :stone_less_exp           # 石料经验不足
    attr_accessor :stone_more_exp           # 石料经验过高
    attr_accessor :no_stone_task            # 石料管事无任务
    attr_accessor :stone_full_bag           # 石料背包已满
    attr_accessor :give_stone_text          # 发布石料任务
    attr_accessor :finish_stone_text        # 完成石料任务
    attr_accessor :lose_stone_text          # 石料丢失
    attr_accessor :no_stone_task2           # 工地管事无任务
    attr_accessor :reward_text              # 奖励文本
    attr_accessor :reward_money_text        # 奖励金钱
    attr_accessor :reward_exp_text          # 奖励经验
    attr_accessor :reward_pot_text          # 奖励潜能
    attr_accessor :sp_talk_text             # 特殊对话文本
    attr_accessor :quest_talk               # 隐藏任务
    attr_accessor :normal_talk              # 常规对话
    attr_accessor :shop_buy_text            # 商店购买对话
    attr_accessor :shop_sell_text           # 商店卖出对话
    attr_accessor :daxia_exp                # 独行大侠经验不足
    attr_accessor :have_school              # 已有门派
    attr_accessor :baishi_suc               # 拜师成功
    attr_accessor :baishi_text              # 拜师文本
    attr_accessor :drink_water_text         # 喝水
    attr_accessor :not_drink_text           # 饮水已满
    attr_accessor :find_item_text           # 发现物品
    attr_accessor :fish_no_hp               # 钓鱼生命不足
    attr_accessor :fish_no_item             # 钓鱼无钓竿鱼篓
    attr_accessor :start_fish               # 开始钓鱼
    attr_accessor :fish_fail                # 钓鱼失败
    attr_accessor :fish_suc                 # 钓鱼成功
    attr_accessor :wanted_text              # 通缉告示
    attr_accessor :no_wanted_text           # 无通缉犯
    attr_accessor :suicide_text             # 歪脖树
    attr_accessor :suicide_ask              # 确认上吊
    attr_accessor :game_hall_text           # 游戏厅
    attr_accessor :play_what_text           # 玩哪个
    attr_accessor :no_int_text              # 读书识字0
    attr_accessor :caihua_ask1              # 菜花宝典询问
    attr_accessor :caihua_ask2              # 菜花宝典询问
    attr_accessor :not_read_text            # 先练本门武功
    attr_accessor :drink_wine_text          # 喝女儿红
    attr_accessor :run_fail_text            # 逃跑失败文本
    attr_accessor :run_suc_text             # 逃跑成功文本
    attr_accessor :kill_text                # 是否杀死文本
    attr_accessor :no_die_text              # 战斗未死文本
    attr_accessor :go_die_text              # 战斗被杀文本
    attr_accessor :die_text                 # 战斗杀死文本
    attr_accessor :live_text                # 战斗不杀文本
    attr_accessor :save_ok                  # 存档成功
    attr_accessor :quit_ask                 # 退出询问
    attr_accessor :save_ask                 # 存档询问
    attr_accessor :no_neigong               # 没装备内功
    attr_accessor :no_nei_lv                # 内功等级不足
    attr_accessor :fp_plus_max              # 加力上限
    attr_accessor :no_fp                    # 内力不足
    attr_accessor :hp_full                  # 体力充沛
    attr_accessor :hp_recover               # 吸气
    attr_accessor :no_maxfp                 # 内力上限不足
    attr_accessor :bad_hurt                 # 重伤
    attr_accessor :liao_fail                # 疗伤失败(内功等级不足)
    attr_accessor :no_hurt                  # 没有受伤
    attr_accessor :liao_suc                 # 疗伤成功
    attr_accessor :liao_finish              # 疗伤结束
    attr_accessor :no_fashu                 # 没装备法术
    attr_accessor :no_fa_lv                 # 法术等级不足
    attr_accessor :mp_plus_max              # 法点上限
    attr_accessor :learn_what               # 学什么
    attr_accessor :learn_no_exp             # 请教经验不足
    attr_accessor :learn_no_gold            # 读书没钱
    attr_accessor :learn_no_pot             # 请教潜能不足
    attr_accessor :no_learn                 # 等级高于师傅
    attr_accessor :sk_lv_up                 # 功夫进步
    attr_accessor :continue_learn           # 继续学习
    attr_accessor :pra_hurt                 # 练功受伤
    attr_accessor :pra_no_weapon            # 练功无武器
    attr_accessor :pra_no_base              # 练功没基础功夫
    attr_accessor :no_pra                   # 练功不能提高了
    attr_accessor :pra_no_fp                # 练功内力上限不足
    attr_accessor :gender                   # 性别
    attr_accessor :sp_no_maxfp              # 绝招内力上限不足
    attr_accessor :sp_no_fa                 # 绝招法术等级不够
    attr_accessor :sp_no_hp                 # 绝招生命不足
    attr_accessor :sp_no_fp                 # 绝招内力不足
    attr_accessor :sp_no_mp                 # 绝招生命不足
    attr_accessor :sp_used                  # 已经在使用绝招
    attr_accessor :sp_no_lv                 # 绝招等级不足
    attr_accessor :sp_no_match              # 绝招武功不匹配
    attr_accessor :sp_no_fp2                # 绝招内力不足
    attr_accessor :sp_is_cd                 # 绝招冷却中
    attr_accessor :self_is_busy             # 自己呆若木鸡
    attr_accessor :aim_is_busy              # 目标呆若木鸡
    attr_accessor :aim_is_busy2             # 目标呆若木鸡
    attr_accessor :sp_no_attr               # 绝招属性不足
    attr_accessor :magic_net                # 联机不允许用绝招
    attr_accessor :fly_no_fp                # 轻功内力不足
    attr_accessor :shop_info                # 商店信息
    attr_accessor :shop_info2               # 商店信息持有数量
    attr_accessor :shop_number              # 商店输入数量
    attr_accessor :cannot_move              # 呆若木鸡
    attr_accessor :battle_item              # 战利品
    attr_accessor :die_msg                  # 玩家死亡文本
    attr_accessor :game_score               # 小游戏得分
    attr_accessor :enter_sword              # 进入铸剑谷
    attr_accessor :sword_ask                # 是否开启铸剑挑战
    attr_accessor :sword_no_bag             # 铸剑挑战物品满
    attr_accessor :sword_battle             # 铸剑挑战给武器
    attr_accessor :sword_pass               # 通过铸剑挑战
    attr_accessor :sword_fail               # 铸剑挑战失败
    attr_accessor :sword_win                # 铸剑挑战胜利
    attr_accessor :sword_no_match           # 铸剑挑战武器不符
    attr_accessor :have_sword               # 已有铸造武器
    attr_accessor :welcome_sword            # 欢迎铸剑谷
    attr_accessor :choose_type              # 选择武器类别
    attr_accessor :sword_unequip            # 武器需卸下
    attr_accessor :sword_no_exp             # 铸造经验不足
    attr_accessor :sword_no_gold            # 铸造金钱不足
    attr_accessor :rename_sword             # 武器重命名
    attr_accessor :sword_is_making          # 武器铸造中
    attr_accessor :sword_status             # 武器状态
    attr_accessor :new_home_ask             # 桃花源询问
    attr_accessor :new_home_fail            # 桃花源摔下
    attr_accessor :new_home_top             # 桃花源到山顶
    attr_accessor :step_ask                 # 询问方向
    attr_accessor :step_fail                # 山顶摔倒
    attr_accessor :step_success             # 迈出一步
    attr_accessor :see_new_home             # 发现房屋
    attr_accessor :welcome_home             # 山大王/老管家问候
    attr_accessor :win_shan_king            # 战胜山大王
    attr_accessor :room_lv_up               # 房屋翻盖成功
    attr_accessor :room_no_gold             # 翻盖没钱
    attr_accessor :room_max_lv              # 翻盖至最高级
    attr_accessor :room_no_space            # 没空间放家具
    attr_accessor :jiaju_no_gold            # 没钱买家具
    attr_accessor :net_error                # 联机错误
    attr_accessor :net_info                 # 网络信息
    attr_accessor :net_item                 # 联机使用物品
    attr_accessor :net_kungfu               # 联机调整招式
    attr_accessor :maoshan_marry            # 茅山不结婚
    attr_accessor :marry_no_age             # 没到结婚年龄
    attr_accessor :marry_no_home            # 没有婚房
    attr_accessor :marry_ask                # 询问婚姻操作
    attr_accessor :already_married          # 已婚来结婚
    attr_accessor :unmarry_divorce          # 未婚来离婚
    attr_accessor :send_marry               # 发送求婚
    attr_accessor :gender_error             # 性别相同
    attr_accessor :recieve_marry            # 接收求婚
    attr_accessor :disagree_quest           # 拒绝请求
    attr_accessor :agree_marry              # 同意结婚
    attr_accessor :disagree_marry           # 不同意结婚
    attr_accessor :send_divorce             # 发送离婚
    attr_accessor :couple_no_match          # 不是配偶
    attr_accessor :recieve_divorce          # 接收离婚
    attr_accessor :agree_divorce            # 同意离婚
    attr_accessor :disagree_divorce         # 不同意离婚
    #--------------------------------------------------------------------------
    # ● 初始化对像
    #--------------------------------------------------------------------------
    def initialize
      @bad_name1 = []
      @bad_name2 = []
      @end_com = []
      @scroll_name = []
      @scroll_start = ""
      @scroll_end = []
      @end_text = []
      @boss_text = []
      @all_work = []
      @give_work_text = ""
      @finish_work_text = ""
      @work_undo_text = ""
      @work_tired_text = ""
      @not_work_text = ""
      @work_text = []
      @has_reward_text = ""
      @finish_task_text = ""
      @woman_ask = ""
      @gu_no_reward = ""
      @task_undo_text = []
      @tan_start = ""
      @give_task_text = []
      @no_npc_live = ""
      @no_kill_task = ""
      @i_know_text = ""
      @you_bad_text = ""
      @bad_undo_text = ""
      @no_bad_task = ""
      @give_bad_text = ""
      @stone_undo_text = ""
      @stone_less_exp = ""
      @stone_more_exp = ""
      @no_stone_task = ""
      @stone_full_bag = ""
      @give_stone_text = ""
      @finish_stone_text = ""
      @lose_stone_text = ""
      @no_stone_task2 = ""
      @reward_text = ""
      @reward_money_text = ""
      @reward_exp_text = ""
      @reward_pot_text = ""
      @sp_talk_text = {}
      @quest_talk = {}
      @normal_talk = []
      @shop_buy_text = ""
      @shop_sell_text = ""
      @daxia_exp = ""
      @have_school = ""
      @baishi_suc = ""
      @baishi_text = {}
      @drink_water_text = ""
      @not_drink_text = ""
      @find_item_text = ""
      @fish_no_hp = ""
      @fish_no_item = []
      @start_fish = ""
      @fish_fail = ""
      @fish_suc = []
      @wanted_text = ""
      @no_wanted_text = ""
      @suicide_text = ""
      @suicide_ask = ""
      @game_hall_text = ""
      @play_what_text = ""
      @no_int_text = ""
      @caihua_ask1 = ""
      @caihua_ask2 = ""
      @not_read_text = ""
      @drink_wine_text = ""
      @run_fail_text = []
      @run_suc_text = ""
      @kill_text = ""
      @no_die_text = ""
      @go_die_text = ""
      @die_text = []
      @live_text = []
      @save_ok = ""
      @quit_ask = ""
      @save_ask = ""
      @no_neigong = ""
      @no_nei_lv = ""
      @fp_plus_max = ""
      @no_fp = ""
      @hp_full = ""
      @hp_recover = ""
      @no_maxfp = ""
      @bad_hurt = ""
      @liao_fail = ""
      @no_hurt = ""
      @liao_suc = []
      @liao_finish = []
      @no_fashu = ""
      @no_fa_lv = ""
      @mp_plus_max = ""
      @learn_what = ""
      @learn_no_exp = ""
      @learn_no_gold = ""
      @learn_no_pot = ""
      @no_learn = []
      @sk_lv_up = ""
      @continue_learn = ""
      @pra_hurt = ""
      @pra_no_weapon = ""
      @pra_no_base = ""
      @no_pra = ""
      @pra_no_fp = ""
      @gender = []
      @sp_no_maxfp = ""
      @sp_no_fa = ""
      @sp_no_hp = ""
      @sp_no_fp = ""
      @sp_no_mp = ""
      @sp_used = ""
      @sp_no_lv = ""
      @sp_no_match = ""
      @sp_no_fp2 = ""
      @sp_is_cd = ""
      @self_is_busy = ""
      @aim_is_busy = ""
      @aim_is_busy2 = ""
      @sp_no_attr = ""
      @magic_net = ""
      @fly_no_fp = ""
      @shop_info = ""
      @shop_info2 = ""
      @shop_number = []
      @cannot_move = ""
      @battle_item = ""
      @die_msg = []
      @game_score = []
      @enter_sword = ""
      @sword_ask = ""
      @sword_no_bag = ""
      @sword_battle = []
      @sword_pass = ""
      @sword_fail = ""
      @sword_win = ""
      @sword_no_match = []
      @have_sword = ""
      @welcome_sword = ""
      @choose_type = ""
      @sword_unequip = ""
      @sword_no_exp = ""
      @sword_no_gold = ""
      @rename_sword = ""
      @sword_is_making = ""
      @sword_status = ""
      @new_home_ask = ""
      @new_home_fail = []
      @new_home_top = ""
      @step_ask = ""
      @step_fail = ""
      @step_success = ""
      @see_new_home = ""
      @welcome_home = []
      @win_shan_king = ""
      @room_lv_up = ""
      @room_no_gold = ""
      @room_max_lv = ""
      @room_no_space = ""
      @jiaju_no_gold = ""
      @net_error = []
      @net_info = []
      @net_item = ""
      @net_kungfu = ""
      @maoshan_marry = ""
      @marry_no_age = ""
      @marry_no_home = ""
      @marry_ask = ""
      @already_married = ""
      @unmarry_divorce = ""
      @send_marry = ""
      @gender_error = ""
      @recieve_marry = ""
      @disagree_quest = ""
      @agree_marry = []
      @disagree_marry = ""
      @send_divorce = ""
      @couple_no_match = ""
      @recieve_divorce = ""
      @agree_divorce = ""
      @disagree_divorce = ""
    end
  end
end