function this = subsasgn(this,index,val)
% file_dialogクラスのインデックスへの代入メソッド
% 実際の代入処理はsetメソッドをcallする。

switch index.type
  case '()'
    error('Structure array indexing not supported.')
    % switch index.subs{:}
    % case 1,	this.public.save_mode = val;
    % case 2,	this.public.file_extensions = val;
    % case 3,	this.public.current_extension = val;
    % case 4,	this.public.current_dir = val;
    % case 5,	this.public.hist_dir = val;
    % otherwise	error('Index out of range')
    % end
  case '.'
    if isfield( this.public, lower(index.subs) )
      this = set(this, index.subs, val);
    else	
      error('Invalid properties: ''%s''', index.subs);
    end
  case '{}'
    error('Cell array indexing not supported.');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function subsasgn()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
