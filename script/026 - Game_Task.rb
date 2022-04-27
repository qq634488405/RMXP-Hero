#==============================================================================
# ■ Game_Task
#------------------------------------------------------------------------------
# 　处理游戏中任务的类。
#==============================================================================
class Game_Task
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor :free_work                  # 义工任务ID
  attr_accessor :kill_id                    # 杀人任务ID
  attr_accessor :kill_name                  # 杀人任务名字
  attr_accessor :kill_time                  # 杀人任务开始时间
  attr_accessor :kill_reward                # 杀人任务奖励系数
  attr_accessor :visit_id                   # 拜访任务ID
  attr_accessor :visit_name                 # 拜访任务姓名
  attr_accessor :visit_time                 # 拜访任务开始时间
  attr_accessor :visit_reward               # 拜访任务奖励系数
  attr_accessor :find_type                  # 中年妇人任务物品类型
  attr_accessor :find_id                    # 寻物任务ID
  attr_accessor :find_name                  # 寻物名称
  attr_accessor :find_time                  # 寻物任务开始时间
  attr_accessor :find_reward                # 杀人任务奖励系数
  attr_accessor :finish_flag                # 三大任务完成标志
  attr_accessor :wanted_count               # 捕快任务个数
  attr_accessor :wanted_turn                # 捕快任务轮数
  attr_accessor :wanted_time                # 捕快任务开始时间
  attr_accessor :wanted_reward              # 捕快任务奖励系数
  attr_accessor :wanted_name                # 捕快任务姓名
  attr_accessor :wanted_data                # 捕快任务数据
  attr_accessor :wanted_place               # 捕快任务地点
  attr_accessor :gu_reward                  # 顾炎武领奖奖励
  attr_accessor :stone_start                # 石料任务开始标志
  attr_accessor :stone_time                 # 石料任务接取时间
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    @actor = $game_actor
    @free_work = 0
    @kill_id = 0
    @kill_name = ""
    @kill_time = 0
    @kill_reward = 0
    @visit_id = 0
    @visit_name = ""
    @visit_time = 0
    @visit_reward = 0
    @find_type = 0
    @find_id = 0
    @find_name = ""
    @find_time = 0
    @find_reward = 0
    @wanted_count = 0
    @wanted_turn = 1
    @wanted_time = Graphics.frame_count/Graphics.frame_rate-300
    @wanted_reward = 0
    @wanted_name = ""
    @wanted_data = $data_enemies[198]
    @wanted_place = 0
    @finish_flag = false
    @gu_reward = 0
    @stone_start = false
    @stone_time = Graphics.frame_count/Graphics.frame_rate-180
  end
  #--------------------------------------------------------------------------
  # ● 获得经验
  #--------------------------------------------------------------------------
  def gain_exp(number)
    @actor.exp+=number
  end
  #--------------------------------------------------------------------------
  # ● 获得潜能
  #--------------------------------------------------------------------------
  def gain_pot(number)
    @actor.pot+=number
  end
  #--------------------------------------------------------------------------
  # ● 生成义工任务
  #--------------------------------------------------------------------------
  def give_work
    @free_work = rand(3)+1
  end
  #--------------------------------------------------------------------------
  # ● 检查体力
  #--------------------------------------------------------------------------
  def check_work_hp
    # 体力足够的情况
    if $game_actor.hp>20+10*@free_work
      $game_actor.hp-=20+10*@free_work
      return true
    else
      # 清除义工任务
      @free_work=0
      return false
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置石料任务
  #--------------------------------------------------------------------------
  def set_stone
    @stone_start=true
    @actor.gain_item(1,29)
    @stone_time=Graphics.frame_count/Graphics.frame_rate
  end
  #--------------------------------------------------------------------------
  # ● 完成石料任务
  #--------------------------------------------------------------------------
  def finish_stone
    @actor.lose_item(1,29)
    @stone_start=false
    exp = @actor.exp/1500+40
    pot = exp/2
    return give_reward(exp,pot,-1)
  end
  #--------------------------------------------------------------------------
  # ● 生成三大任务，1--拜访，2--寻物，3--杀人，返回任务目标名字
  #--------------------------------------------------------------------------
  def set_task(type)
    task_list = make_task_list(type)
    return nil if task_list.empty?
    task = []
    # 将所有经验低于玩家的目标加入列表
    task_list.each do |i|
      task.push i if @actor.exp>=i[2]
    end
    a,b = task_list.size,task.size
    index = Integer(rand(task.size))
    # 计算任务允许时间，完成时超出允许时间20分钟将无奖励
    time = Graphics.frame_count/Graphics.frame_rate
    offset_time = 80*index/a+35+time
    task_type = task_list[index][0]
    task_id,task_exp = task_list[index][1],task_list[index][2]
    # 计算奖励
    reward = 200*(index+1)/a
    reward *= (1+cal_log10(@actor.exp/10000))
    reward *= (@actor.exp*task_exp)/((@actor.exp+task_exp)**2)
    reward = [reward+rand(@actor.int)+rand(@actor.luck),200].min
    # 保存任务信息
    case type
    when 1 # 拜访
      @visit_id = task_id
      @visit_name = $data_enemies[@visit_id].name
      name = @visit_name
      @visit_time = offset_time
      @visit_reward = reward*3
    when 2 # 寻物
      @find_type = task_type
      @find_id = task_id
      case @find_type
      when 1 # 物品
        @find_name = $data_items[@find_id].name
      when 2 # 武器
        @find_name = $data_weapons[@find_id].name
      when 3 # 防具
        @find_name = $data_armors[@find_id].name
      end
      name = @find_name
      @find_time = offset_time
      @find_reward = reward*3
    when 3 # 杀人
      @kill_id = task_id
      @kill_name = $data_enemies[@visit_id].name
      name = @kill_name
      @kill_time = offset_time
      @kill_reward = reward*3
    end
    return name
  end
  #--------------------------------------------------------------------------
  # ● 估算log10
  #-------------------------------------------------------------------------- 
  def cal_log10(number)
    result = 0
    number /= 10
    while number > 0
      number /= 10
      result += 1
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ● 生成任务列表
  #-------------------------------------------------------------------------- 
  def make_task_list(type)
    return $data_tasks.find_list if type == 2
    task = $data_tasks.npc_list
    task.each_index do |i|
      # 去除被杀死的NPC
      task.delete_at(i) if @actor.kill_list.include?(task[i][1])
    end
    return task
  end
  #--------------------------------------------------------------------------
  # ● 生成捕快任务
  #--------------------------------------------------------------------------
  def set_badman
    # 生成地点
    index = rand($data_tasks.bad_map.size)
    @wanted_place=$data_tasks.bad_map[index]
    $game_temp.badman_place=@wanted_place
    @wanted_time = Graphics.frame_count/Graphics.frame_rate
    # 生成姓名
    name1=rand(8)
    name2=rand(8)
    gender= name2>3 ? 0 : 1
    @wanted_name=$data_text.bad_name1[name1]+$data_text.bad_name2[name2]
    # 更新恶人计数
    @wanted_count += 1
    if @wanted_count > 10
      @wanted_turn += 1
      @wanted_count = 1
    end
    # 生成奖励数据
    @wanted_reward = (80 + rand(80))*(@wanted_count+@wanted_turn-1)
    # 生成恶人数据
    class_id=rand(8)+1
    # 姓名,类型,性别,年龄,命中,闪避,攻击,防御,经验,加力,法点,道德,膂力,敏捷,
    # 悟性,根骨,外貌,福源,HP,MHP,FP,MFP,MP,MMP,FHP,武器,物品1,物品2,物品3,
    # 物品4,金钱,[拳脚,兵刃,轻功,内功,招架,法术],技能数,[技能列表],出售数,
    # [出售列表],[描述1-5]
    @wanted_data.name = @wanted_name
    @wanted_data.gender = gender
    # 命中，闪避，攻击，防御，经验，加力，先天膂力，先天敏捷，先天悟性，
    # 先天根骨，先天相貌，先天福源，生命上限，内力上限，法力上限，法点
    # 复制玩家属性，经验，生命，内力，法力进行折算
    percent = 70+5*@wanted_count+5*@wanted_turn
    @wanted_data.base_hit = @actor.hit
    @wanted_data.base_eva = @actor.eva
    @wanted_data.base_atk = @actor.atk
    @wanted_data.base_def = @actor.bon
    @wanted_data.exp = @actor.exp*percent/100
    @wanted_data.base_str = @actor.base_str
    @wanted_data.base_agi = @actor.base_agi
    @wanted_data.base_int = @actor.base_int
    @wanted_data.base_bon = @actor.base_bon
    @wanted_data.base_fac = @actor.base_fac
    @wanted_data.base_luc = @actor.base_luc
    @wanted_data.maxhp = @actor.maxhp*percent/100
    @wanted_data.maxfp = @actor.maxfp*percent/100
    if class_id == 8
      @wanted_data.maxmp = @actor.maxfp*percent/100
      @wanted_data.mp_plus = @wanted_data.maxmp/40
    else
      @wanted_data.maxmp = 0
      @wanted_data.mp_plus = 0
    end
    @wanted_data.fp_plus = @wanted_data.maxfp/40
    @wanted_data.hp = @wanted_data.maxhp
    @wanted_data.fp = @wanted_data.maxfp
    @wanted_data.mp = @wanted_data.maxmp
    @wanted_data.morals,@wanted_data.full_hp = 0,@wanted_data.maxhp
    bad_data = $data_tasks.bad_data[class_id]
    @wanted_data.weapon_id = bad_data[0]
    @wanted_data.skill_use = [bad_data[1],bad_data[2],bad_data[3],bad_data[4],
                              bad_data[5],bad_data[6]]
    @wanted_data.skill_count = bad_data[7]
    level = @actor.get_max_level*percent/100
    # 生成恶人技能列表，等级取玩家技能最高等级*轮次系数
    @wanted_data.skill_list = []
    bad_data[8].each do |i|
      @wanted_data.skill_list.push([i,level])
    end
    # 生成恶人事件
    create_badman(index,gender)
  end
  #--------------------------------------------------------------------------
  # ● 顾炎武给奖励
  #--------------------------------------------------------------------------
  def task_reward
    @finish_flag = false
    # 70%给经验，30%给潜能
    if rand(100)<70
      return give_reward(@gu_reward,-1,-1)
    else
      return give_reward(-1,@gu_reward/2,-1)
    end
  end
  #--------------------------------------------------------------------------
  # ● 给奖励，参数<0不显示对应文本
  #--------------------------------------------------------------------------
  def give_reward(exp,pot,money)
    # 生成奖励文本 
    reward = $data_text.reward_text.dup
    reward += $data_text.reward_exp_text if exp>=0
    reward += $data_text.reward_pot_text if pot>=0
    reward += $data_text.reward_money_text if money>=0
    reward.gsub!("exp",exp.to_s)
    reward.gsub!("pot",pot.to_s)
    reward.gsub!("money",money.to_s)
    # 获得奖励
    $game_task.gain_exp([exp,0].max)
    $game_task.gain_pot([pot,0].max)
    $game_actor.gain_gold([money,0].max)
    return reward
  end
  #--------------------------------------------------------------------------
  # ● 检查隐藏任务是否可完成
  #--------------------------------------------------------------------------
  def check_quest(quest)
    # 获取任务需求及奖励
    quest_type = quest[0][0]
    type1,id1,num1 = quest[0][1],quest[0][2],quest[0][3]
    type2,id2,num2 = quest[1][0],quest[1][1],quest[1][2]
    # 数量不足，不可完成
    return false if @actor.item_number(type1,id1)<num1
    # 数量足够，背包未满，可完成
    return true if not @actor.full_item_bag?
    # 任务类型为交换物品
    if quest_type == 1
      # 需求物品为武器或防具，可完成
      return true if type1 != 1
      # 需求物品为物品，且不可叠加，可完成
      return true if not $data_items[id1].can_add
      # 物品可叠加且数量与需求相等，可完成
      return true if @actor.item_number(type1,id1) == num1
      return false
    else # 任务为展示物品
      # 奖励物品为物品，可叠加且已经拥有，可完成，其余不可完成
      return false if type2 !=1
      return ($data_items[id2].can_add and @actor.item_number(type2,id2)>0)
      return false
    end
  end
  #--------------------------------------------------------------------------
  # ● 捕快奖励
  #--------------------------------------------------------------------------
  def give_wanted_reward
    return give_reward(@wanted_reward,@wanted_reward/4,-1)
  end
  #--------------------------------------------------------------------------
  # ● 生成恶人事件
  #--------------------------------------------------------------------------
  def create_badman(index,gender)
    # 获取所在地图有效坐标
    area=$data_tasks.bad_area[index]
    # 开始循环
    loop do
      # 生成随机坐标
      x_y=area[rand(area.size)]
      x,y=x_y
      # 重置恶人事件坐标
      $game_temp.bad_man.x=x
      $game_temp.bad_man.y=y
      # 地点非玩家所在位置则跳出循环
      break unless (@wanted_place==10 and x_y==[$game_player.x,$game_player.y])
    end
    # 生成恶人
    $game_temp.bad_man.name=@wanted_name
    # 设定角色图
    if gender == 0
      character_name = "Bad_Man"
      $data_enemies[198].battler_name = "NPC_Tile_11"
    else
      character_name = "Bad_Woman"
      $data_enemies[198].battler_name = "NPC_Tile_03"
    end
    $game_temp.bad_man.pages[0].graphic.character_name=character_name
  end
end