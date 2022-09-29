=begin
网络函数：（传输的信息均加密后发送）
  服务端：
    创建服务端Socket套接字
    返回Socket套接字
    @server_sock=Win32API.new('NetworkSupport','create_server','v','L').call if @server_sock.nil?
    
    服务端等待函数，返回形如： IP：Port 的客户端信息字符串
    @clientmsg=Win32API.new('NetworkSupport','server_accept','p','p').call(@server_sock)
    
    服务端向客户端发送纯数字信息
    Win32API.new('NetworkSupport','srv_item_send','pipp','v').call(@server_sock,123,@clientmsg.split(':')[0],@clientmsg.split(':')[1])
    
    服务端从客户端接收纯数字信息
    number=Win32API.new('NetworkSupport','srv_item_recv','ppp','i').call(@server_sock,@clientmsg.split(':')[0],@clientmsg.split(':')[1])
    
    服务端向客户端发送字符串信息
    string=Win32API.new('NetworkSupport','srv_merry_recv','ppp','p').call(@server_sock,@clientmsg.split(':')[0],@clientmsg.split(':')[1])
    
    服务端从客户端接收字符串信息
    Win32API.new('NetworkSupport','srv_merry_send','pppp','v').call(@server_sock,"Message",@clientmsg.split(':')[0],@clientmsg.split(':')[1])
    
  客户端：
    创建客户端Socket套接字
    返回Socket套接字
    @client_sock=Win32API.new('NetworkSupport','create_client','v','L').call
    
    客户端连接服务端
    返回连接状态
    c_success=Win32API.new('NetworkSupport','client_connect','pp','i').call(@client_sock,@serverip)
  
    客户端向服务端发送纯数字信息
    Win32API.new('NetworkSupport','cli_item_send','pip','v').call(@client_sock,123,@serverip)
  
    客户端从服务端接收纯数字信息
    number=Win32API.new('NetworkSupport','cli_item_recv','pp','i').call(@client_sock,@serverip)
  
    客户端从服务端接收字符串信息
    string=Win32API.new('NetworkSupport','cli_merry_recv','pp','p').call(@client_sock,@serverip)
  
    客户端向服务端发送字符串信息
    Win32API.new('NetworkSupport','cli_merry_send','ppp','v').call(@client_sock,"Message",@serverip)
  
  公共使用：
    关闭Socket套接字连接
    Win32API.new('ws2_32','closesocket','p','v').call(@sock)
    
    获取本机IP地址，返回十进制形式字符串IP地址
    self_ip=Win32API.new('NetworkSupport','get_host_ip_string','v','p').call
    
    检查本机内外网状态
    Win32API.new('NetworkSupport','check_InternalIP','v','i').call

辅助函数：
返回Windows安装路径
Win32API.new('NetworkSupport','get_windows_path','p','p').call(" ")
=end