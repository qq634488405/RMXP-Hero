#==============================================================================
# ■ Game_Map
#------------------------------------------------------------------------------
# 　处理地图的类。包含卷动以及可以通行的判断功能。
# 本类的实例请参考 $game_map 。
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor :tileset_name             # 元件 文件名
  attr_accessor :autotile_names           # 自动元件 文件名
  attr_accessor :panorama_name            # 全景 文件名
  attr_accessor :panorama_hue             # 全景 色相
  attr_accessor :fog_name                 # 雾 文件名
  attr_accessor :fog_hue                  # 雾 色相
  attr_accessor :fog_opacity              # 雾 不透明度
  attr_accessor :fog_blend_type           # 雾 混合方式
  attr_accessor :fog_zoom                 # 雾 放大率
  attr_accessor :fog_sx                   # 雾 SX
  attr_accessor :fog_sy                   # 雾 SY
  attr_accessor :battleback_name          # 战斗背景 文件名
  attr_accessor :display_x                # 显示 X 坐标 * 128
  attr_accessor :display_y                # 显示 Y 坐标 * 128
  attr_accessor :need_refresh             # 刷新要求标志
  attr_reader   :passages                 # 通行表
  attr_reader   :priorities               # 优先表
  attr_reader   :terrain_tags             # 地形标记表
  attr_reader   :events                   # 事件
  attr_reader   :fog_ox                   # 雾 原点 X 坐标
  attr_reader   :fog_oy                   # 雾 原点 Y 坐标
  attr_reader   :fog_tone                 # 雾 色调
  #--------------------------------------------------------------------------
  # ● 初始化条件
  #--------------------------------------------------------------------------
  def initialize
    @map_id = 0
    @display_x = 0
    @display_y = 0
  end
  #--------------------------------------------------------------------------
  # ● 设置
  #     map_id : 地图 ID
  #--------------------------------------------------------------------------
  def setup(map_id)
    # 地图 ID 记录到 @map_id 
    @map_id = map_id
    # 地图文件装载后、设置到 @map 
    @map = load_data(sprintf("Data/Map%03d.rxdata", @map_id))
    # 定义实例变量设置地图元件信息
    tileset = $data_tilesets[@map.tileset_id]
    @tileset_name = tileset.tileset_name
    @autotile_names = tileset.autotile_names
    @panorama_name = tileset.panorama_name
    @panorama_hue = tileset.panorama_hue
    @fog_name = tileset.fog_name
    @fog_hue = tileset.fog_hue
    @fog_opacity = tileset.fog_opacity
    @fog_blend_type = tileset.fog_blend_type
    @fog_zoom = tileset.fog_zoom
    @fog_sx = tileset.fog_sx
    @fog_sy = tileset.fog_sy
    @battleback_name = tileset.battleback_name
    @passages = tileset.passages
    @priorities = tileset.priorities
    @terrain_tags = tileset.terrain_tags
    # 初始化显示坐标
    @display_x = 0
    @display_y = 0
    # 清除刷新要求标志
    @need_refresh = false
    # 设置地图事件数据
    refresh_map_events
    # 初始化雾的各种信息
    @fog_ox = 0
    @fog_oy = 0
    @fog_tone = Tone.new(0, 0, 0, 0)
    @fog_tone_target = Tone.new(0, 0, 0, 0)
    @fog_tone_duration = 0
    @fog_opacity_duration = 0
    @fog_opacity_target = 0
    # 初始化滚动信息
    @scroll_direction = 2
    @scroll_rest = 0
    @scroll_speed = 4
  end
  #--------------------------------------------------------------------------
  # ● 获取地图 ID
  #--------------------------------------------------------------------------
  def map_id
    return @map_id
  end
  #--------------------------------------------------------------------------
  # ● 获取宽度
  #--------------------------------------------------------------------------
  def width
    return @map.width
  end
  #--------------------------------------------------------------------------
  # ● 获取高度
  #--------------------------------------------------------------------------
  def height
    return @map.height
  end
  #--------------------------------------------------------------------------
  # ● 获取遇敌列表
  #--------------------------------------------------------------------------
  def encounter_list
    return @map.encounter_list
  end
  #--------------------------------------------------------------------------
  # ● 获取遇敌步数
  #--------------------------------------------------------------------------
  def encounter_step
    return @map.encounter_step
  end
  #--------------------------------------------------------------------------
  # ● 获取地图数据
  #--------------------------------------------------------------------------
  def data
    return @map.data
  end
  #--------------------------------------------------------------------------
  # ● 获取地图名称
  #--------------------------------------------------------------------------
  def map_name
    return $data_mapinfos[@map_id].name
  end
  #--------------------------------------------------------------------------
  # ● 更新地图事件
  #--------------------------------------------------------------------------
  def refresh_map_events
    # 设置地图事件数据
    @events = {}
    for i in @map.events.keys
      # 桃花源室内地图
      if [58,68,69].include?(map_id)
        n = $game_actor.jiaju_list
        e = @map.events[i].name
        # 老管家及传送事件
        if e.to_i == 172 or e.to_i == 0
          @events[i] = Game_Event.new(@map_id, @map.events[i])
          next
        end
        # 配偶事件
        if e.to_i == 100000
          if $game_actor.marry > 0
            # 根据配偶性别设置行走图
            case $game_actor.marry
            when 1,3 # 男性，？性
              c_name = "MainChar_Boy"
            when 2 # 女性
              c_name = "MainChar_Girl"
            end
            @map.events[i].pages[0].graphic.character_name = c_name
            @events[i] = Game_Event.new(@map_id, @map.events[i])
          end
          next
        end
        jiaju_id = 5 - e.size
        if n[jiaju_id] >= e[0,1].to_i # 取首位对比
          @events[i] = Game_Event.new(@map_id, @map.events[i])
        end
        next
      end
      # 普通NPC被杀的情况，替换为骷髅头，喽啰则消失
      if $game_actor.kill_list.include?(@map.events[i].name.to_i)
        if (173..194).include?(@map.events[i].name.to_i)
          next
        end
        npc = $game_temp.dead_npc
        npc.id,npc.name = @map.events[i].id,@map.events[i].name
        npc.x,npc.y = @map.events[i].x,@map.events[i].y
        @events[i] = Game_Event.new(@map_id, npc.deep_clone)
      else
        # NPC为娜可露且无兽王令牌
        if @map.events[i].name.to_i==132 and $game_actor.item_number(1,31)==0
          next
        end
        # NPC为茅盈且无茅山令牌
        if @map.events[i].name.to_i==144 and $game_actor.item_number(1,32)==0
          next
        end
        @events[i] = Game_Event.new(@map_id, @map.events[i])
      end
    end
    # 地图序号和恶人所在地图相等，添加恶人事件
    if @map_id == $game_temp.badman_place and $game_temp.bad_man !=nil
      $game_temp.bad_man.id = @events.size+1
      @events[@events.size+1] = Game_Event.new(@map_id,$game_temp.bad_man)
    end
    # 设置公共事件数据
    @common_events = {}
    for i in 1...$data_common_events.size
      @common_events[i] = Game_CommonEvent.new(i)
    end
  end
  #--------------------------------------------------------------------------
  # ● BGM / BGS 自动切换
  #--------------------------------------------------------------------------
  def autoplay
    if @map.autoplay_bgm
      $game_system.bgm_play(@map.bgm)
    end
    if @map.autoplay_bgs
      $game_system.bgs_play(@map.bgs)
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    # 地图 ID 有效
    if @map_id > 0
      # 更新地图事件
      refresh_map_events
      # 刷新全部的地图事件
      for event in @events.values
        event.refresh
      end
      # 刷新全部的公共事件
      for common_event in @common_events.values
        common_event.refresh
      end
    end
    # 清除刷新要求标志
    @need_refresh = false
  end
  #--------------------------------------------------------------------------
  # ● 向下滚动
  #     distance : 滚动距离
  #--------------------------------------------------------------------------
  def scroll_down(distance)
    @display_y = [@display_y + distance, (self.height - 15) * 128].min
  end
  #--------------------------------------------------------------------------
  # ● 向左滚动
  #     distance : 滚动距离
  #--------------------------------------------------------------------------
  def scroll_left(distance)
    @display_x = [@display_x - distance, 0].max
  end
  #--------------------------------------------------------------------------
  # ● 向右滚动
  #     distance : 滚动距离
  #--------------------------------------------------------------------------
  def scroll_right(distance)
    @display_x = [@display_x + distance, (self.width - 20) * 128].min
  end
  #--------------------------------------------------------------------------
  # ● 向上滚动
  #     distance : 滚动距离
  #--------------------------------------------------------------------------
  def scroll_up(distance)
    @display_y = [@display_y - distance, 0].max
  end
  #--------------------------------------------------------------------------
  # ● 有效坐标判定
  #     x          : X 坐标
  #     y          : Y 坐标
  #--------------------------------------------------------------------------
  def valid?(x, y)
    return (x >= 0 and x < width and y >= 0 and y < height)
  end
  #--------------------------------------------------------------------------
  # ● 可以通行判定
  #     x          : X 坐标
  #     y          : Y 坐标
  #     d          : 方向 (0,2,4,6,8,10)
  #                  ※ 0,10 = 全方向不能通行的情况的判定 (跳跃等)
  #     self_event : 自己 (判定事件可以通行的情况下)
  #--------------------------------------------------------------------------
  def passable?(x, y, d, self_event = nil)
    # 被给予的坐标地图外的情况下
    unless valid?(x, y)
      # 不能通行
      return false
    end
    # 方向 (0,2,4,6,8,10) 与障碍物接触 (0,1,2,4,8,0) 后变换
    bit = (1 << (d / 2 - 1)) & 0x0f
    # 循环全部的事件
    for event in events.values
      # 自己以外的元件与坐标相同的情况
      if event.tile_id >= 0 and event != self_event and
         event.x == x and event.y == y and not event.through
        # 如果障碍物的接触被设置的情况下
        if @passages[event.tile_id] & bit != 0
          # 不能通行
          return false
        # 如果全方向的障碍物的接触被设置的情况下
        elsif @passages[event.tile_id] & 0x0f == 0x0f
          # 不能通行
          return false
        # 这以外的优先度为 0 的情况下
        elsif @priorities[event.tile_id] == 0
          # 可以通行
          return true
        end
      end
    end
    # 从层按从上到下的顺序调查循环
    for i in [2, 1, 0]
      # 取得元件 ID
      tile_id = data[x, y, i]
      # 取得元件 ID 失败
      if tile_id == nil
        # 不能通行
        return false
      # 如果障碍物的接触被设置的情况下
      elsif @passages[tile_id] & bit != 0
        # 不能通行
        return false
      # 如果全方向的障碍物的接触被设置的情况下
      elsif @passages[tile_id] & 0x0f == 0x0f
        # 不能通行
        return false
      # 这以外的优先度为 0 的情况下
      elsif @priorities[tile_id] == 0
        # 可以通行
        return true
      end
    end
    # 可以通行
    return true
  end
  #--------------------------------------------------------------------------
  # ● 茂密判定
  #     x          : X 坐标
  #     y          : Y 坐标
  #--------------------------------------------------------------------------
  def bush?(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return false
        elsif @passages[tile_id] & 0x40 == 0x40
          return true
        end
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 柜台判定
  #     x          : X 坐标
  #     y          : Y 坐标
  #--------------------------------------------------------------------------
  def counter?(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return false
        elsif @passages[tile_id] & 0x80 == 0x80
          return true
        end
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 获取地形标志
  #     x          : X 坐标
  #     y          : Y 坐标
  #--------------------------------------------------------------------------
  def terrain_tag(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return 0
        elsif @terrain_tags[tile_id] > 0
          return @terrain_tags[tile_id]
        end
      end
    end
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 获取指定位置的事件 ID
  #     x          : X 坐标
  #     y          : Y 坐标
  #--------------------------------------------------------------------------
  def check_event(x, y)
    for event in $game_map.events.values
      if event.x == x and event.y == y
        return event.id
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 滚动开始
  #     direction : 滚动方向
  #     distance  : 滚动距离
  #     speed     : 滚动速度
  #--------------------------------------------------------------------------
  def start_scroll(direction, distance, speed)
    @scroll_direction = direction
    @scroll_rest = distance * 128
    @scroll_speed = speed
  end
  #--------------------------------------------------------------------------
  # ● 滚动中判定
  #--------------------------------------------------------------------------
  def scrolling?
    return @scroll_rest > 0
  end
  #--------------------------------------------------------------------------
  # ● 开始变更雾的色调
  #     tone     : 色调
  #     duration : 时间
  #--------------------------------------------------------------------------
  def start_fog_tone_change(tone, duration)
    @fog_tone_target = tone.clone
    @fog_tone_duration = duration
    if @fog_tone_duration == 0
      @fog_tone = @fog_tone_target.clone
    end
  end
  #--------------------------------------------------------------------------
  # ● 开始变更雾的不透明度
  #     opacity  : 不透明度
  #     duration : 时间
  #--------------------------------------------------------------------------
  def start_fog_opacity_change(opacity, duration)
    @fog_opacity_target = opacity * 1.0
    @fog_opacity_duration = duration
    if @fog_opacity_duration == 0
      @fog_opacity = @fog_opacity_target
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 还原必要的地图
    if $game_map.need_refresh
      refresh
    end
    # 滚动中的情况下
    if @scroll_rest > 0
      # 滚动速度变化为地图坐标系的距离
      distance = 2 ** @scroll_speed
      # 执行滚动
      case @scroll_direction
      when 2  # 下
        scroll_down(distance)
      when 4  # 左
        scroll_left(distance)
      when 6  # 右
        scroll_right(distance)
      when 8  # 上
        scroll_up(distance)
      end
      # 滚动距离的减法运算
      @scroll_rest -= distance
    end
    # 更新地图事件
    for event in @events.values
      event.update
    end
    # 更新公共事件
    for common_event in @common_events.values
      common_event.update
    end
    # 处理雾的滚动
    @fog_ox -= @fog_sx / 8.0
    @fog_oy -= @fog_sy / 8.0
    # 处理雾的色调变更
    if @fog_tone_duration >= 1
      d = @fog_tone_duration
      target = @fog_tone_target
      @fog_tone.red = (@fog_tone.red * (d - 1) + target.red) / d
      @fog_tone.green = (@fog_tone.green * (d - 1) + target.green) / d
      @fog_tone.blue = (@fog_tone.blue * (d - 1) + target.blue) / d
      @fog_tone.gray = (@fog_tone.gray * (d - 1) + target.gray) / d
      @fog_tone_duration -= 1
    end
    # 处理雾的不透明度变更
    if @fog_opacity_duration >= 1
      d = @fog_opacity_duration
      @fog_opacity = (@fog_opacity * (d - 1) + @fog_opacity_target) / d
      @fog_opacity_duration -= 1
    end
  end
end
