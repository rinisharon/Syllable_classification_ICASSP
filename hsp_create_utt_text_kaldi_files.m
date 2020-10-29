% give new directory name for feats to be stored in %%%%%%% featDir %%%%%%%
% give what transcription to use in load command whether for - vowel, syll,
% phrase or sentence

featDir = '/data/RINI/Rini_bckp/timit_data/hsp_feats_files/hear_tempar_fullband_250_prdgrm/';
load('hsp_feats_files/transcription_sentence.mat');

mkdir (sprintf('%s',featDir));
load(fullfile(featDir,'utt_id.mat'));
fileID = fopen(fullfile(featDir,'utt_train.txt'),'a');
ix=1;
% for p=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47] 
for p=[1:75]   %1:44
    if mod(p,3)==0
        continue;
    end
    for ch=1:36
        formatSpec = '%s_%d \n';
        fprintf(fileID,formatSpec,tmp_utt{p,ch},ix);
        ix=ix+1;
    end
end

fileID = fopen(fullfile(featDir,'utt_test.txt'),'a');
% for p=[23,24,25,48,49,50]
for q=[1:25]
     p=test_nos(q);
    for ch=1:36
        formatSpec = '%s_%d \n';
        fprintf(fileID,formatSpec,tmp_utt{p,ch},ix);
        ix=ix+1;
    end
end



fileID = fopen(fullfile(featDir,'text_train.txt'),'a');
ix=1;
% for p=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47] 
for p=[1:75]   %1:44
    if mod(p,3)==0
        continue;
    end
    for ch=1:36
        ut_na=tmp_utt{p,ch};
%         phh= strrep(ut_na,'ph*_','ph0*_0');
        ph_no=ut_na(13:14);
%         ph_no=ut_na(12:13);
        
        if contains(ph_no,'_')
            ph_no = strcat('0',ut_na(13));
        end
        for k=1:25
            if ph_no==t{k,1}
                text=t{k,2};
                break;
            end
        end    
        formatSpec = '%s_%d \t %s \n';
        fprintf(fileID,formatSpec,tmp_utt{p,ch},ix,text);
        ix=ix+1;
    end
%     ph_no
end

fileID = fopen(fullfile(featDir,'text_test.txt'),'a');
% ix=1;
% for p=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47] 
for q=[1:25]
     p=test_nos(q);
    for ch=1:36
        ut_na=tmp_utt{p,ch};
%         phh= strrep(ut_na,'ph*_','ph0*_0');
%         ph_no=ut_na(12:13); %(13:14);
        ph_no=ut_na(13:14);
        
        if contains(ph_no,'_')
            ph_no = strcat('0',ut_na(13));
        end
        for k=1:25
            if ph_no==t{k,1}
                text=t{k,2};
                break;
            end
        end    
        formatSpec = '%s_%d \t %s \n';
        fprintf(fileID,formatSpec,tmp_utt{p,ch},ix,text);
        ix=ix+1;
    end
%     ph_no
end

