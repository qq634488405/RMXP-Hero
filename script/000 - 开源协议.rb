#由于本作参考部分脚本源自PC黄金版，故引用黄金版作者开源协议

#---------------------------------------------------------------------------
#                         ●● 开源协议 ●●
#---------------------------------------------------------------------------
#本游戏之脚本代码的学习者或浏览者（以下简称“用户”或“User”）须遵守以下条
#款方可继续阅读以下脚本代码，如果您不能遵守条款和此协议中的限制。请立即从您
#的计算机中删除这个游戏的工程的所有文件，否则将视为严格遵守本协议。
#
#1、浏览：脚本代码仅供个人用户学习Ruby或RPG Maker XP（以下简称“RMXP”）以
#         及参考、交流、研究之用，不得用于任何商业、盈利用途或作弊欺骗等不
#         正当用途，也不得用作参加任何性质的竞赛作品或设计作品。未经授权任
#         何人不得在公元2011年1月1日前公开本游戏工程文件以及脚本代码。
#
#2、修改：用户可以修改原来的脚本代码，用来学习Ruby/RMXP，但不得开发针对性的
#         修改器等恶意程序，也不得去除本协议，对于修改后有二次发布需求的，
#         参见本协议第4条。
#
#3、添加：用户可以为游戏新增功能用来进一步完善游戏，但应尽量以尊重文曲星上
#         面的《英雄坛说》黄金版为标准，且不得添加有破坏游戏性的功能，如加
#         入后门等，对于添加功能后有二次发布需求的，参见本协议第4条。       
#
#4、二次发布：用户可以将修改、完善的游戏进行再次发布，但不得违背本协议的所
#             有内容，也不得在游戏脚本中删除本协议，发布的游戏可以采取RMXP
#             的默认加密格式，但必须在游戏中用文本文档另附详细注明所有改动
#             的地方，每条改动的说明格式为“脚本名/类名/方法名/行数/用途”
#             对于添加的类的说明格式为“类名/类的作用”，添加的类中包含的
#             方法说明格式为“方法名：用途”，添加的类中包含的对象的属性的
#             说明为“属性：用途”。发布的游戏可以小规模（分享人数小于20人）
#             的进行传播，但若有需要进行大规模的传播、发行的，需事先联系作
#             者，并提交原始工程给原作者审核，通过后方可发布提交给原作者的
#             版本，并且必须在发布之后的2年内开放源码。
#
#5、传播方式：用户不得随意转载上传到其他的任何网络媒体中，除非意外因素，源
#             工程不会从网盘中删除，用户若要分享本工程的，直接发布下载地址
#             即可，随意转载工程者将视为侵权。
#
#6、有限担保与承诺：作者不对任何间接,偶然,特殊,惩罚所产生的损害,或由于利益
#                   的损失造成的损害，数据或使用导致的损失负责，仅向用户提
#                   供对原脚本系统的解释服务。对于游戏被用户的改版所造成的
#                   玩家利益的损失一律由该用户承担。本工程中使用到其他人员
#                   所写之代码，均已有注明，故不对其做任何解释。
#
#7、关于NetworkSupport.dll网络库：该网络库源码恕不公开，但是可以提供给用户
#                                 免费使用，使用方法请用户自行参见脚本中的
#                                 相关模块自行学习，作者不对用户使用该DLL 
#                                 文件所造成的任何后果负责，该责任由用户承
#                                 担。
#
#8、关于素材：游戏采用的素材因牵扯到相关问题，故不单独发布，用户若有需要，
#             可以自行采取相关手段进行提取，对于用户这一行为造成的后果，作
#             者概不负任何责任。
#
#9、未尽事宜：用户若对本协议存有疑虑，可以电邮到Gold_gmud@163.com询问，作者
#             对本协议以及本游戏工程拥有最终解释权。
#
#
#                                             绝爱仙剑ㄝ宝宝(QQ:156692474)
#                                                   开源日期：2011年1月1日


#==============================================================================
# ■  Hangup 异常根除
#    Hangup Exception Eradication
#----------------------------------------------------------------------------
#
#    Hangup 异常是 RMXP 底层引擎内置的一个异常类，游戏进程会在 Graphics.update
#    没有调用超过 10 秒时抛出这个异常。这个脚本使用了 Windows API 暴力地解除
#    了这个限制。
#    使用方法：Hangup 异常根除脚本必须插入到脚本编辑器的最顶端，所有脚本之前，无
#    例外。
#
#----------------------------------------------------------------------------
#
#    更新作者： 紫苏
#    许可协议： FSL -MEE
#    项目版本： 1.2.0827
#    引用网址：
#    http://bbs.66rpg.com/forum.php?mod=viewthread&tid=134316
#    http://szsu.wordpress.com/2010/08/09/hangup_eradication
#
#----------------------------------------------------------------------------
#
#    - 1.2.0827 By 紫苏
#      * 更改了配置模块名
#      * 更改了 FSL 注释信息
#
#    - 1.2.0805 By 紫苏
#      * 脚本开始遵循 FSL
#      * 全局范围内改变了脚本结构
#
#    - 1.1.1101 By 紫苏
#      * 修正了脚本在 Windows XP 平台下失效的问题
#
#    - 1.0.0927 By 紫苏
#      * 初始版本完成
#
#==============================================================================
=begin
$__jmp_here.call if $__jmp_here

#----------------------------------------------------------------------------
# ● 登记 FSL。
#----------------------------------------------------------------------------
$fscript = {} if !$fscript
$fscript['HangupEradication'] = '1.2.0827'

#==============================================================================
# ■ FSL
#------------------------------------------------------------------------------
# 　自由RGSS脚本通用公开协议的功能模块。
#==============================================================================

module FSL
  module HangupEradication
    #------------------------------------------------------------------------
    # ● 定义需要的 Windows API。
    #------------------------------------------------------------------------
    OpenThread = Win32API.new('kernel32', 'OpenThread', 'LIL', 'L')
    CloseHandle = Win32API.new('kernel32', 'CloseHandle', 'L', 'I')
    Thread32Next = Win32API.new('kernel32', 'Thread32Next', 'LP', 'I')
    ResumeThread = Win32API.new('kernel32', 'ResumeThread', 'L', 'L')
    SuspendThread = Win32API.new('kernel32', 'SuspendThread', 'L', 'L')
    Thread32First = Win32API.new('kernel32', 'Thread32First', 'LP', 'I')
    GetCurrentProcessId = Win32API.new('kernel32', 'GetCurrentProcessId', 'V', 'L')
    CreateToolhelp32Snapshot = Win32API.new('kernel32', 'CreateToolhelp32Snapshot', 'LL', 'L')
  end
end

#==============================================================================
# ■ HangupEradication
#------------------------------------------------------------------------------
# 　处理根除 Hangup 异常的类。
#==============================================================================

class HangupEradication
  include FSL::HangupEradication
  #--------------------------------------------------------------------------
  # ● 初始化对像。
  #--------------------------------------------------------------------------
  def initialize
    @hSnapShot = CreateToolhelp32Snapshot.call(4, 0)
    @hLastThread = OpenThread.call(2, 0, self.getLastThreadId)
    #@hLastThread = OpenThread.call(2097151, 0, threadID)
    ObjectSpace.define_finalizer(self, self.method(:finalize))
  end
  #--------------------------------------------------------------------------
  # ● 获取当前进程创建的最后一个线程的标识。
  #--------------------------------------------------------------------------
  def getLastThreadId
    threadEntry = [28, 0, 0, 0, 0, 0, 0].pack("L*")
    threadId = 0                                          # 线程标识
    found = Thread32First.call(@hSnapShot, threadEntry)   # 准备枚举线程
    while found != 0
      arrThreadEntry = threadEntry.unpack("L*")           # 线程数据解包
      if arrThreadEntry[3] == GetCurrentProcessId.call    # 匹配进程标识
        threadId = arrThreadEntry[2]                      # 记录线程标识
      end
      found = Thread32Next.call(@hSnapShot, threadEntry)  # 下一个线程
    end
    return threadId
  end
  #--------------------------------------------------------------------------
  # ● 根除 Hangup 异常。
  #     2       : “暂停和恢复线程访问权限”代码；
  #     2097151 : “所有可能的访问权限”代码（Windows XP 平台下无效）。
  #--------------------------------------------------------------------------
  def eradicate
    SuspendThread.call(@hLastThread)
  end
  #--------------------------------------------------------------------------
  # ● 恢复 Hangup 异常。
  #--------------------------------------------------------------------------
  def resume
    while ResumeThread.call(@hLastThread) > 1; end        # 恢复最后一个线程
  end
  #--------------------------------------------------------------------------
  # ● 最终化对像。
  #--------------------------------------------------------------------------
  def finalize
    CloseHandle.call(@hSnapShot)
    CloseHandle.call(@hLastThread)
  end
end

hangupEradication = HangupEradication.new
hangupEradication.eradicate

callcc { |$__jmp_here| }                                  # F12 后的跳转标记

#==============================================================================
# ■ 游戏主过程
#------------------------------------------------------------------------------
# 　游戏脚本的解释从这个外壳开始。
#==============================================================================

for subscript in 1...$RGSS_SCRIPTS.size
  begin
    eval(Zlib::Inflate.inflate($RGSS_SCRIPTS[subscript][2]))
  rescue Exception => ex
    # 异常发生并抛出给解释器时恢复线程。
    hangupEradication.resume unless defined?(Reset) and ex.class == Reset
    raise ex
  end
end

hangupEradication.resume
exit
=end