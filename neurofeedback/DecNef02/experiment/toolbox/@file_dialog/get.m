function val = get(this, prop)
% file_dialogクラスのgetメソッド
% get指定したオブジェクトのプロパティ値を返す。
if isfield( this.public, lower(prop) )
  val = getfield(this.public, lower(prop));
else
  error('Invalid properties: ''%s''', prop);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function get()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
