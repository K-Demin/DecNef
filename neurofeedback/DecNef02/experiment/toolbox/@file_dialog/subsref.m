function val = subsref(this, index)
% file_dialogクラス用のインデックス付きのフィールドメソッド

switch index.type
  case '()'
    error('Structure array indexing not supported.')
    % switch index.subs{:}
    % case 1,	val = this.public.save_mode;
    % case 2,	val = this.public.file_extensions;
    % case 3,	val = this.public.current_extension;
    % case 4,	val = this.public.current_dir;
    % case 5,	val = this.public.current_file;
    % case 6,	val = this.public.hist_dir;
    % otherwise,	error('Index out of range')
    % end
  case '.'
    if isfield( this.public, lower(index.subs) )
      val = getfield(this.public, lower(index.subs));
    else
      error('Invalid properties: ''%s''', index.subs);
    end
  case '{}'
    error('Cell array indexing not supported.');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function subsref()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
