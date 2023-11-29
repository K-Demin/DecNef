function [para, data] = set_receiver_data(para, data, receiver)

num = size(receiver,2);

if num == 1
    scan = receiver.scan;				
    data.received_scan(scan) = true;		
    for ii=1:data.roi_num
      data.roi_vol{ii}(scan,:) = receiver.roi_vol{ii}; 
    end
    data.wm_signal(scan) = receiver.wm_signal;	
    data.gs_signal(scan) = receiver.gs_signal;	
    data.csf_signal(scan) = receiver.csf_signal;	
    data.realign_val(scan,:) = receiver.realign_val;	
    data.corr_roi_template(scan,:) = receiver.corr_roi_template;		
    para.files.nifti_fnames{scan} = receiver.nifti_fnames;	
else
    for i = 1:num
        scan = receiver{i}.scan;				% scan��?�
        data.received_scan(scan) = true;		% ��?M?ς�scan��?�
        for ii=1:data.roi_num
          data.roi_vol{ii}(scan,:) = receiver{i}.roi_vol{ii}; % ROI�̈�̑Svoxel��?M?�
        end
        data.wm_signal(scan) = receiver{i}.wm_signal;	% WM��?M?��l�̕���
        data.gs_signal(scan) = receiver{i}.gs_signal;	% GS��?M?��l�̕���
        data.csf_signal(scan) = receiver{i}.csf_signal;	% SCF��?M?��l�̕���
        data.realign_val(scan,:) = receiver{i}.realign_val;	% realignment parameter
        data.corr_roi_template(scan,:) = receiver{i}.corr_roi_template;		% ROI Template�f?[�^��ROI�̑��֌W?�
        para.files.nifti_fnames{scan} = receiver{i}.nifti_fnames;	% NIfTI file��
    end
end

