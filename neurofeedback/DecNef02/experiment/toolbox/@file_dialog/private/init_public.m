function public = init_public()
% public$B%a%s%P$r=i4|2=$9$k!#(B

public = struct(...
    'save_mode', 0,...		% 0:Load mode, 1:Save mode
    'multi_select_mode', 1,...	% 0:Single select mode, 1:Multi select mode
    'file_extensions', [],...	% $B8!:wBP>]$N%U%!%$%k3HD%;R(B(cell$BG[Ns(B) (*)
    'default_extension', 1,...	% $B8!:wBP>]$N%U%!%$%k3HD%;R$N=i4|CM(B
    'current_dir', pwd,...	% current$B8!:w(Bdirectory
    'hist_dir', [],...		% $B8!:w(Bdirectory$B$NMzNr(B(cell$BG[Ns(B)
    'title', '',...		% Dialog window$B$N%?%$%H%k(B
    ...	% GUI$B$N?'$r;XDj$9$k!#(B
    'dialog_color', [0.9, 0.9, 0.9],...	% dialog$B$N(Bbackground color
    'bgcol_panel', [0.8, 0.8, 0.8],...	% panel$B$N(Bbackground color
    'fgcol_panel', [0.1, 0.1, 0.4],...	% panel$B$N(Bforeground color
    'fgcol_text', [0.1, 0.1, 0.4],...	% static text label$B$N(Bforeground color
    'bgcol_popup', [1.0, 1.0, 1.0],...	% pop-up menu$B$N(Bbackground color
    'fgcol_popup', [0.0, 0.0, 0.0],...	% pop-up menu$B$N(Bforeground color
    'bgcol_listbox', [1.0, 1.0, 1.0],...	% list box$B$N(Bbackground color
    'fgcol_listbox', [0.0, 0.0, 0.0],...	% list box$B$N(Bforeground color
    'bgcol_edit', [1.0, 1.0, 1.0],...	% edit text$B$N(Bbackground color
    'fgcol_edit', [0.0, 0.0, 0.0],...	% edit text$B$N(Bforeground color
    'bgcol_push', [0.8, 0.8, 0.9],...	% push button$B$N(Bbackground color
    'fgcol_push', [0.0, 0.0, 0.0]...	% push button$B$N(Bforeground color
    );
public.file_extensions = {'.*'};
public.hist_dir = {};

% (*) (2013.12.03)
% public.file_extensions($B8!:wBP>]$N%U%!%$%k3HD%;R(B)$B$,(B
% ''(NULL$BJ8;zNs(B)$B$N>l9g!"8!:wBP>]$r(B($B%U%!%$%k$G$O$J$/(B)
% $B%G%#%l%/%H%j$H$9$k!#(B

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function init_public()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
