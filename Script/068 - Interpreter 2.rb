#==============================================================================
# ■ Interpreter (分割定义 2)
#------------------------------------------------------------------------------
# 　执行时间命令的解释器。本类在 Game_System 类
# 和 Game_Event 类的内部使用。
#==============================================================================

class Interpreter
  #--------------------------------------------------------------------------
  # ● 执行事件命令
  #--------------------------------------------------------------------------
  def execute_command
    # 到达执行内容列表末尾的情况下
    if @index >= @list.size - 1
      # 时间结束
      command_end
      # 继续
      return true
    end
    # 事件命令的功能可以参考 @parameters
    @parameters = @list[@index].parameters
    # 命令代码分支
    case @list[@index].code
    when 101  # 文章的显示
      return command_101
    when 102  # 显示选择项
      return command_102
    when 402  # [**] 的情况下
      return command_402
    when 403  # 取消的情况下
      return command_403
    when 103  # 处理数值输入
      return command_103
    when 104  # 更改文章选项
      return command_104
    when 105  # 处理按键输入
      return command_105
    when 106  # 等待
      return command_106
    when 111  # 条件分支
      return command_111
    when 411  # 这以外的情况
      return command_411
    when 112  # 循环
      return command_112
    when 413  # 重复上次
      return command_413
    when 113  # 中断循环
      return command_113
    when 115  # 中断时间处理
      return command_115
    when 116  # 暂时删除事件
      return command_116
    when 117  # 公共事件
      return command_117
    when 118  # 标签
      return command_118
    when 119  # 标签跳转
      return command_119
    when 121  # 操作开关
      return command_121
    when 122  # 操作变量
      return command_122
    when 123  # 操作独立开关
      return command_123
    when 124  # 操作计时器
      return command_124
    when 125  # 增减金钱
      return command_125
    when 126  # 增减物品
      return command_126
    when 127  # 增减武器
      return command_127
    when 128  # 增减防具
      return command_128
    when 129  # 替换角色
      return command_129
    when 131  # 更改窗口外关
      return command_131
    when 132  # 更改战斗 BGM
      return command_132
    when 133  # 更改战斗结束 BGS
      return command_133
    when 134  # 更改禁止保存
      return command_134
    when 135  # 更改禁止菜单
      return command_135
    when 136  # 更改禁止遇敌
      return command_136
    when 201  # 场所移动
      return command_201
    when 202  # 设置事件位置
      return command_202
    when 203  # 地图滚动
      return command_203
    when 204  # 更改地图设置
      return command_204
    when 205  # 更改雾的色调
      return command_205
    when 206  # 更改雾的不透明度
      return command_206
    when 207  # 显示动画
      return command_207
    when 208  # 更改透明状态
      return command_208
    when 209  # 设置移动路线
      return command_209
    when 210  # 移动结束后等待
      return command_210
    when 221  # 准备过渡
      return command_221
    when 222  # 执行过渡
      return command_222
    when 223  # 更改画面色调
      return command_223
    when 224  # 画面闪烁
      return command_224
    when 225  # 画面震动
      return command_225
    when 231  # 显示图片
      return command_231
    when 232  # 移动图片
      return command_232
    when 233  # 旋转图片
      return command_233
    when 234  # 更改色调
      return command_234
    when 235  # 删除图片
      return command_235
    when 236  # 设置天候
      return command_236
    when 241  # 演奏 BGM
      return command_241
    when 242  # BGM 的淡入淡出
      return command_242
    when 245  # 演奏 BGS
      return command_245
    when 246  # BGS 的淡入淡出
      return command_246
    when 247  # 记忆 BGM / BGS
      return command_247
    when 248  # 还原 BGM / BGS
      return command_248
    when 249  # 演奏 ME
      return command_249
    when 250  # 演奏 SE
      return command_250
    when 251  # 停止 SE
      return command_251
    when 301  # 战斗处理
      return command_301
    when 601  # 胜利的情况
      return command_601
    when 602  # 逃跑的情况
      return command_602
    when 603  # 失败的情况
      return command_603
    when 302  # 商店的处理
      return command_302
    when 303  # 名称输入的处理
      return command_303
    when 311  # 增减 HP
      return command_311
    when 312  # 增减 SP
      return command_312
    when 313  # 更改状态
      return command_313
    when 314  # 全回复
      return command_314
    when 315  # 增减 EXP
      return command_315
    when 316  # 増減 等级
      return command_316
    when 317  # 増減 能力值
      return command_317
    when 318  # 增减特技
      return command_318
    when 319  # 变更装备
      return command_319
    when 320  # 更改角色名字
      return command_320
    when 321  # 更改角色职业
      return command_321
    when 322  # 更改角色图形
      return command_322
    when 331  # 増減敌人的 HP
      return command_331
    when 332  # 増減敌人的 SP
      return command_332
    when 333  # 更改敌人的状态
      return command_333
    when 334  # 敌人出现
      return command_334
    when 335  # 敌人变身
      return command_335
    when 336  # 敌人全回复
      return command_336
    when 337  # 显示动画
      return command_337
    when 338  # 伤害处理
      return command_338
    when 339  # 强制行动
      return command_339
    when 340  # 战斗中断
      return command_340
    when 351  # 调用菜单画面
      return command_351
    when 352  # 调用存档画面
      return command_352
    when 353  # 游戏结束
      return command_353
    when 354  # 返回标题画面
      return command_354
    when 355  # 脚本
      return command_355
    else      # 其它
      return true
    end
  end
  #--------------------------------------------------------------------------
  # ● 事件结束
  #--------------------------------------------------------------------------
  def command_end
    # 清除执行内容列表
    @list = nil
    # 主地图事件与事件 ID 有效的情况下
    if @main and @event_id > 0
      # 解除事件锁定
      $game_map.events[@event_id].unlock
    end
  end
  #--------------------------------------------------------------------------
  # ● 指令跳转
  #--------------------------------------------------------------------------
  def command_skip
    # 获取缩进
    indent = @list[@index].indent
    # 循环
    loop do
      # 下一个事件命令是同等级的缩进的情况下
      if @list[@index+1].indent == indent
        # 继续
        return true
      end
      # 索引的下一个
      @index += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取角色
  #     parameter : 能力值
  #--------------------------------------------------------------------------
  def get_character(parameter)
    # 能力值分支
    case parameter
    when -1  # 角色
      return $game_player
    when 0  # 本事件
      events = $game_map.events
      return events == nil ? nil : events[@event_id]
    else  # 特定的事件
      events = $game_map.events
      return events == nil ? nil : events[parameter]
    end
  end
  #--------------------------------------------------------------------------
  # ● 计算操作的值
  #     operation    : 操作
  #     operand_type : 操作数类型 (0:恒量 1:变量)
  #     operand      : 操作数 (数值是变量 ID)
  #--------------------------------------------------------------------------
  def operate_value(operation, operand_type, operand)
    # 获取操作数
    if operand_type == 0
      value = operand
    else
      value = $game_variables[operand]
    end
    # 操作为 [减少] 的情况下反转实际符号
    if operation == 1
      value = -value
    end
    # 返回 value
    return value
  end
end
