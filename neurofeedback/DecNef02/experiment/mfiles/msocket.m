function [ret] = msocket(define, status, para, send_data, timeout)
% function [ret] = msocket(define, status, para, send_data, timeout)
% status��?ݒ�l��?]��?Aneurofeedback�v�?�O����(Server) �� 
% receiver�v�?�O����(Client) �̊ԂŒ�?M?��?(msocket)��?s�Ȃ�?B
% 
% [input argument]
% define    : define��?����Ǘ?����?\����
% status    : socket��?M?��?���Ǘ?
% parae     : �����p���??[�^���Ǘ?����?\����
% send_data : ��?M�f?[�^
% timeout   : timeout���� (sec)
% 
% [output argument]
% ret : ��?M�l��?ݒ肷��?B
%       status��?ݒ�l�ɂ��?A��?M�l�͈ȉ��̈Ӗ����?��?B
%       define.msocket.INITIALIZE_SERVER (?�����?��? (Server))
%         -> msocket ID��Ԃ�?B
%       define.msocket.INITIALIZE_CLIENT (?�����?��? (Client))
%         -> msocket ID��Ԃ�?B
%       define.msocket.SEND_DATA (��?M?��?)
%         -> mssend()�̕Ԃ�l(0��?�:?���/0����:���s)
%       define.msocket.RECEIVE_DATA (��?M?��?)
%         -> ��?M?���:��?M�f?[�^/ ��?M���s:send_data
%       define.msocket.FINISH (?I��?��?)
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
