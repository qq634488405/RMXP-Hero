#==============================================================================
# ■ Main
#------------------------------------------------------------------------------
# 　各定义结束后、从这里开始实际处理。
#==============================================================================

class Reset < Exception
end
# 检查文件
unless FileTest.exist?("Lib/InputSupport.dll")
  print("找不到InputSupport.dll，请尝试重新安装游戏！")
  exit
end
unless FileTest.exist?("Lib/Background.dll")
  print("找不到Background.dll，请尝试重新安装游戏！")
  exit
end
unless FileTest.exist?("Lib/NetworkSupport.dll")
  print("找不到NetworkSupport.dll，请尝试重新安装游戏！")
  exit
end
# 安装临时字体
font_file=["/Font/wqx-16.ttf","/Font/wqx-12.ttf"]
font_test=["Font/wqx-16.ttf","Font/wqx-12.ttf"]
font_name=["WQX16","WQX12"]
dll_name="RGSS103J"
for i in 0..1
  # 字体未安装且存在字体文件则进行安装
  if not Font.exist?(font_name[i]) and FileTest.exist?(font_test[i])
    m2w = Win32API.new("kernel32","MultiByteToWideChar","llplpl","l")
    w2m = Win32API.new("kernel32","WideCharToMultiByte","llplplll","l")
    effe = Win32API.new("gdi32","EnumFontFamiliesExA","lplll","v")
    wpm = Win32API.new("kernel32","WriteProcessMemory","lplll","l")
    dll = Win32API.new("kernel32","GetModuleHandle","p","l").call(dll_name)
    # add font resource
    path = Dir.pwd + font_file[i]
    len = m2w.call(0xFDE9, 0, path, -1, "", 0)
    pp = "  " * len
    m2w.call(0xFDE9, 0, path, -1, pp, len)
    Win32API.new("gdi32","AddFontResourceW","p","v").call(pp)
    # font name => ansi
    len = m2w.call(0xFDE9, 0, font_name[i], -1, "", 0)
    uname = "  " * len
    m2w.call(0xFDE9, 0, font_name[i], -1, uname, len)
    len = w2m.call(0, 0, uname, -1, "", 0, 0, 0)
    aname = " " * len
    w2m.call(0, 0, uname, -1, aname, len, 0, 0)
    # get addr of the original lParam
    tt = "    "
    wpm.call(-1, tt, dll + 0x12B6C4, 4, 0)
    wpm.call(-1, tt, tt.unpack("l")[0] + 0x150, 4, 0)
    lp = tt.unpack("l")[0] + 4
    # get dc
    dc = Win32API.new("user32","GetDC","l","l").call(0)
    # prepare logfont
    logfont = [0,0,0,0,0,0,0,0,1,0,0,0,0].pack("l5C*") + aname
    # call effe like RGSS did
    effe.call(dc, logfont, dll + 0x13D60, lp, 0)
    # done
    Win32API.new("user32","ReleaseDC","ll","v").call(0, dc)
  end
end
# 按行读取配置文件
file = File.open("Gmud.ini")
ini_info = file.readlines
file.close
# 设置色彩模式：0--黑白，1--灰度。默认黑白
$color_mode = 0
ini_info.each do |i|
  # 读取色彩设置
  if i["Color="] == "Color="
    $color_mode = i[/\d/].to_i
    break
  end
end
# 战斗BUFF显示，默认不显示
$battle_info = 0
ini_info.each do |i|
  # 读取BUFF效果显示
  if i["BuffEffect="] == "BuffEffect="
    $battle_info = i[/\d/].to_i
    break
  end
end
begin
  # 准备过渡
  # 设置系统默认字体
  Font.default_name = (["WQX16","宋体","黑体","楷体"])
  Font.default_size = 24
  Graphics.freeze
  # 生成场景对像 (标题画面)
  $scene = Scene_Title.new
  $eat_flag = false
  # $scene 为有效的情况下调用 main 过程
  while $scene != nil
    @digest = Thread.new{loop{digesting;sleep(15)}} if @digest.nil?
    $scene.main
  end
  # 淡入淡出
  Graphics.transition(20)
rescue Errno::ENOENT
  # 补充 Errno::ENOENT 以外错误
  # 无法打开文件的情况下、显示信息后结束
  filename = $!.message.sub("No such file or directory - ", "")
  print("找不到文件 #{filename}。 ")
end
