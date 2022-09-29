#==============================================================================
# ■ Game_Temp
#------------------------------------------------------------------------------
# 　在没有存档的情况下，处理临时数据的类。这个类的实例请参考
# $game_temp 。
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor :map_bgm                  # 地图画面 BGM (战斗时记忆用)
  attr_accessor :message_text             # 信息文章
  attr_accessor :message_proc             # 信息 返回调用 (Proc)
  attr_accessor :choice_start             # 选择项 开始行
  attr_accessor :choice_max               # 选择项 项目数
  attr_accessor :choice_cancel_type       # 选择项 取消的情况
  attr_accessor :choice_proc              # 选择项 返回调用 (Proc)
  attr_accessor :num_input_start          # 输入数值 开始行
  attr_accessor :num_input_variable_id    # 输入数值 变量 ID
  attr_accessor :num_input_digits_max     # 输入数值 位数
  attr_accessor :message_window_showing   # 显示信息窗口
  attr_accessor :common_event_id          # 公共事件 ID
  attr_accessor :in_battle                # 战斗中的标志
  attr_accessor :battle_calling           # 调用战斗的标志
  attr_accessor :battle_troop_id          # 战斗 队伍 ID
  attr_accessor :battle_can_escape        # 战斗中 允许逃跑 ID
  attr_accessor :battle_can_lose          # 战斗中 允许失败 ID
  attr_accessor :battle_proc              # 战斗 返回调用 (Proc)
  attr_accessor :battle_turn              # 战斗 回合数
  attr_accessor :battle_event_flags       # 战斗 事件执行执行完毕的标志
  attr_accessor :battle_abort             # 战斗 中断标志
  attr_accessor :battle_main_phase        # 战斗 状态标志
  attr_accessor :battleback_name          # 战斗背景 文件名
  attr_accessor :forcing_battler          # 强制行动的战斗者
  attr_accessor :shop_calling             # 调用商店的标志
  attr_accessor :shop_goods               # 商店 商品列表
  attr_accessor :name_calling             # 输入名称 调用标志
  attr_accessor :name_actor_id            # 输入名称 角色 ID
  attr_accessor :name_max_char            # 输入名称 最大字数
  attr_accessor :menu_calling             # 菜单 调用标志
  attr_accessor :menu_beep                # 菜单 SE 演奏标志
  attr_accessor :save_calling             # 存档 调用标志
  attr_accessor :debug_calling            # 调试 调用标志
  attr_accessor :save_time                # 存档时间
  attr_accessor :player_transferring      # 主角 场所移动标志
  attr_accessor :player_new_map_id        # 主角 移动目标地图 ID
  attr_accessor :player_new_x             # 主角 移动目标 X 坐标
  attr_accessor :player_new_y             # 主角 移动目标 Y 坐标
  attr_accessor :player_new_direction     # 主角 移动目标 朝向
  attr_accessor :transition_processing    # 过渡处理中标志
  attr_accessor :transition_name          # 过渡 文件名
  attr_accessor :gameover                 # 游戏结束标志
  attr_accessor :dead_npc                 # 死亡NPC事件
  attr_accessor :bad_man                  # 恶人事件
  attr_accessor :badman_place             # 恶人地点
  attr_accessor :to_title                 # 返回标题画面标志
  attr_accessor :to_end                   # 返回结局画面标志
  attr_accessor :last_file_index          # 最后存档的文件编号
  attr_accessor :debug_top_row            # 调试画面 保存状态用
  attr_accessor :debug_index              # 调试画面 保存状态用
  attr_accessor :cheat_mode               # 作弊模式
  attr_accessor :boss_battle              # BOSS战
  attr_accessor :net_battle               # 联机对战标志
  attr_accessor :fly_calling              # 使用轻功标志
  attr_accessor :socket_msg               # 联机信息
  attr_accessor :net_sword                # 联机对战铸造武器
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    @map_bgm = nil
    @message_text = nil
    @message_proc = nil
    @choice_start = 99
    @choice_max = 0
    @choice_cancel_type = 0
    @choice_proc = nil
    @num_input_start = 99
    @num_input_variable_id = 0
    @num_input_digits_max = 0
    @message_window_showing = false
    @common_event_id = 0
    @in_battle = false
    @battle_calling = false
    @battle_troop_id = 0
    @battle_can_escape = false
    @battle_can_lose = false
    @battle_proc = nil
    @battle_turn = 0
    @battle_event_flags = {}
    @battle_abort = false
    @battle_main_phase = false
    @battleback_name = ''
    @forcing_battler = nil
    @shop_calling = false
    @shop_id = 0
    @name_calling = false
    @name_actor_id = 0
    @name_max_char = 0
    @menu_calling = false
    @menu_beep = false
    @save_calling = false
    @debug_calling = false
    @save_time = Graphics.frame_count / Graphics.frame_rate
    @player_transferring = false
    @player_new_map_id = 0
    @player_new_x = 0
    @player_new_y = 0
    @player_new_direction = 0
    @transition_processing = false
    @transition_name = ""
    @gameover = false
    @dead_npc = RPG::Event.new(0,0)
    @dead_npc.pages[0].graphic.tile_id = 508
    @bad_man = RPG::Event.new(0,0)
    @bad_man.pages[0].list[0].code = 355
    @bad_man.pages[0].list[0].parameters = ["$scene=Scene_Event.new(0,198)"]
    @bad_man.pages[0].list.push(RPG::EventCommand.new)
    @badman_place = 0
    @to_title = false
    @to_end = 0
    @last_file_index = 0
    @debug_top_row = 0
    @debug_index = 0
    @is_busy = false
    @cheat_mode = false
    @boss_battle = false
    @fly_calling = false
    @socket_msg = nil
    @net_sword = nil
  end
  #--------------------------------------------------------------------------
  # ● 保存游戏
  #--------------------------------------------------------------------------
  def write_save_data
    # 更新存档时间
    @save_time = Graphics.frame_count / Graphics.frame_rate
    file = File.open("Save/Gmud.sav","wb")
    # 生成描绘存档文件用的角色图形
    actor = $game_actor
    characters = []
    characters.push([actor.character_name, actor.character_hue])
    # 写入描绘存档文件用的角色数据
    Marshal.dump(characters, file)
    # 写入测量游戏时间用画面计数
    Marshal.dump(Graphics.frame_count, file)
    Marshal.dump($word, file)
    # 增加 1 次存档次数
    $game_system.save_count += 1
    # 保存魔法编号
    # (将编辑器保存的值以随机值替换)
    $game_system.magic_number = $data_system.magic_number
    # 写入游戏对象
    data = []
    data.push(Zlib::Deflate.deflate(Marshal.dump($game_system)))
    data.push(Zlib::Deflate.deflate(Marshal.dump($game_self_switches)))
    data.push(Zlib::Deflate.deflate(Marshal.dump($game_screen)))
    data.push(Zlib::Deflate.deflate(Marshal.dump($game_actor)))
    data.push(Zlib::Deflate.deflate(Marshal.dump($game_party)))
    data.push(Zlib::Deflate.deflate(Marshal.dump($game_troop)))
    data.push(Zlib::Deflate.deflate(Marshal.dump($game_map)))
    data.push(Zlib::Deflate.deflate(Marshal.dump($game_player)))
    key = 1313
    # 计算校验值
    crcs = []
    data.each do |i|
      key = Zlib.crc32(i,key)
      crcs.push(key)
    end
    # 写入文件
    Marshal.dump(data, file)
    Marshal.dump(crcs, file)
    file.close
  end
end
