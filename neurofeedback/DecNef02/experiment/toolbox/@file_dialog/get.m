function val = get(this, prop)
% file_dialog���饹��get�᥽�å�
% get���ꤷ�����֥������ȤΥץ�ѥƥ��ͤ��֤���
if isfield( this.public, lower(prop) )
  val = getfield(this.public, lower(prop));
else
  error('Invalid properties: ''%s''', prop);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function get()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
