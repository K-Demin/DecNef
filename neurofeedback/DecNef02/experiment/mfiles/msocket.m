function [ret] = msocket(define, status, para, send_data, timeout)
% function [ret] = msocket(define, status, para, send_data, timeout)
% statusの?ﾝ定値に?]い?Aneurofeedbackプ�?グラム(Server) と 
% receiverプ�?グラム(Client) の間で通?M?��?(msocket)を?sなう?B
% 
% [input argument]
% define    : define変?狽�管�?する?\造体
% status    : socket通?M?��?を管�?
% parae     : 実験パラ�??[タを管�?する?\造体
% send_data : 送?Mデ?[タ
% timeout   : timeout時間 (sec)
% 
% [output argument]
% ret : 返?M値を?ﾝ定する?B
%       statusの?ﾝ定値により?A返?M値は以下の意味を�?つ?B
%       define.msocket.INITIALIZE_SERVER (?炎�化?��? (Server))
%         -> msocket IDを返す?B
%       define.msocket.INITIALIZE_CLIENT (?炎�化?��? (Client))
%         -> msocket IDを返す?B
%       define.msocket.SEND_DATA (送?M?��?)
%         -> mssend()の返り値(0以?�:?ｬ功/0未満:失敗)
%       define.msocket.RECEIVE_DATA (受?M?��?)
%         -> 受?M?ｬ功:受?Mデ?[タ/ 受?M失敗:send_data
%       define.msocket.FINISH (?I了?��?)
%         -> true

switch status
  case define.msocket.INITIALIZE_SERVER

    port = para.msocket.port; % TCP/IP port
    fprintf('initialize mSocket server (port:%d) ... ', port);
    srvsock = mslisten(port);
    if srvsock == -1
      fprintf('Error : Connection refused\n');
      ret = srvsock;
    else
      [sock, hostip, hostname] = msaccept(srvsock);
      msclose(srvsock);
      fprintf('done.\n');
      ret = sock;				% msocket ID
    end
    
  case define.msocket.INITIALIZE_SERVER_DISP

    port = para.msocket.port_Disp; % TCP/IP port
    fprintf('initialize mSocket server with Display (port:%d) ... ', port);
    srvsock = mslisten(port);
    if srvsock == -1
      fprintf('Error : Connection refused\n');
      ret = srvsock;
    else
      [sock, hostip, hostname] = msaccept(srvsock);
      msclose(srvsock);
      fprintf('done.\n');
      ret = sock;				% msocket ID
    end

  case define.msocket.INITIALIZE_CLIENT
    port = para.msocket.port;			% TCP/IP port
    hostname = para.msocket.server_name;	% server
    fprintf('initialize mSocket client (serve:''%s'', port:%d) ... ',...
	hostname, port);
    sock = msconnect(hostname, port);
    fprintf('done.\n');
    ret = sock;	
    
  case define.msocket.INITIALIZE_CLIENT_DISP
    port = para.msocket.port_Disp;			% TCP/IP port
    hostname = para.msocket.server_name;	% server
    fprintf('initialize mSocket client (serve:''%s'', port:%d) ... ',...
	hostname, port);
    sock = msconnect(hostname, port);
    fprintf('done.\n');
    ret = sock;		
    
    
  case define.msocket.SEND_DATA

    ret = zeros(length(para.msocket.sock), 1);
    for ii=1:length(para.msocket.sock)
      ret(ii) = mssend(para.msocket.sock(ii), send_data);
    end
    
  case define.msocket.SEND_DATA_DISP
      
    ret = mssend(para.msocket.sock_Disp, send_data);

    
  case define.msocket.RECEIVE_DATA

    ret = cell(length(para.msocket.sock), 1);
    for ii=1:length(para.msocket.sock)
      if timeout > 0.0	% timeout
        [ret{ii}, success] = msrecv(para.msocket.sock(ii), timeout);
      else		% timeout
        [ret{ii}, success] = msrecv(para.msocket.sock(ii));
      end
      if success < 0,	ret{ii} = send_data;	end
    end
    
  case define.msocket.RECEIVE_DATA_DISP

      if timeout > 0.0	% timeout
        [ret, success] = msrecv(para.msocket.sock_Disp, timeout);
      else		% timeout
        [ret, success] = msrecv(para.msocket.sock_Disp);
      end
      if success < 0,	ret = send_data;	end
    
  case define.msocket.FINISH
    for ii=1:length(para.msocket.sock)
      msclose(para.msocket.sock(ii));
    end
    msclose(para.msocket.sock_Disp);
    ret = true;
    
  otherwise,
    fprintf('msocket(%d:??????)\n', status);
    
end
