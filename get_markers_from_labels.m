%function X_unified_sil_cell = replace_for_sil(X_cell)
%data_cell_sa1=vertcat(sa1_f1, sa1_m1, sa1_m2, sa1_m3, sa1_m4);
function [ref_mean_sa1_init, ref_mean_sa2_init]=get_markers_from_labels(sa1_dsp,sa2_dsp,train_file_nos)

%import label files
A11 = importdata('labels/f1_sa1_labels.txt');
A12 = importdata('labels/m1_sa1_labels.txt');
A13 = importdata('labels/m2_sa1_labels.txt');
A14 = importdata('labels/m3_sa1_labels.txt');
A15 = importdata('labels/m4_sa1_labels.txt');
A21 = importdata('labels/f1_sa2_labels.txt');
A22 = importdata('labels/m1_sa2_labels.txt');
A23 = importdata('labels/m2_sa2_labels.txt');
A24 = importdata('labels/m3_sa2_labels.txt');
A25 = importdata('labels/m4_sa2_labels.txt');

%normalize the label values to scale to 2048
sa1_lab_tmp=cell(5,1);
sa2_lab_tmp=cell(5,1);
for l=1:5
    lab=eval(sprintf('A1%d', l));
    max_time=max(max(lab));
    for i=1:size(lab,2)
        for j=1:size(lab,1)
            lab(j,i)=round((lab(j,i)*2048)/max_time);
        end
    end
    sa1_lab_tmp{l}=lab;
end
for l=1:5
    lab=eval(sprintf('A2%d', l));
    max_time=max(max(lab));
    for i=1:size(lab,2)
        for j=1:size(lab,1)
            lab(j,i)=round((lab(j,i)*2048)/max_time);
        end
    end
    sa2_lab_tmp{l}=lab;
end

for e=1:5
    tmp1=sa1_lab_tmp{e};
    tmp2=sa2_lab_tmp{e};
    for r=1:5
        sa1_lab{r}=tmp1;
        sa2_lab{r}=tmp2;
    end
end

sa1_dsp_init_seg=cell(train_file_nos,length(A11));
for i=1:train_file_nos
    g=mod(i,5);
    if g==0
        g=5;
    end
    tmp_data=sa1_dsp{i};
    tmp_lab=sa1_lab{g};
    for k=1:length(A11)
        segment=tmp_data(:,(tmp_lab(k,1)+1):tmp_lab(k,2));
%         segment_norm=(segment-mean(segment))/std(segment);
        sa1_dsp_init_seg{i,k}=mean(segment,2);
        
    end
end

% casmatrix = permute(reshape([sa1_dsp_init_seg{:}], [], size(sa1_dsp_init_seg, 1), size(sa1_dsp_init_seg, 2)), [2 3 1]);
% ref_mean_sa1_init=squeeze(mean(casmatrix,1))';
chu = cell2mat(sa1_dsp_init_seg);
ref_mean_sa1_init=mean(chu);

sa2_dsp_init_seg=cell(train_file_nos,length(A21));
for i=1:train_file_nos
    g=mod(i,5);
    if g==0
        g=5;
    end
    tmp_data=sa2_dsp{i};
    tmp_lab=sa2_lab{g};
    for k=1:length(A21)
        segment=tmp_data(:,(tmp_lab(k,1)+1):tmp_lab(k,2));
%         segment_norm=(segment-mean(segment))/std(segment);
        sa2_dsp_init_seg{i,k}=mean(segment,2);
    end
end        

% casmatrix2 = permute(reshape([sa2_dsp_init_seg{:}], [], size(sa2_dsp_init_seg, 1), size(sa2_dsp_init_seg, 2)), [2 3 1]);
% ref_mean_sa2_init=squeeze(mean(casmatrix2,1))';
chu2 = cell2mat(sa2_dsp_init_seg);
ref_mean_sa2_init=mean(chu2);


end