load('utt_id.mat');
fileID = fopen('utt_train.txt','a');
ix=1;
for p=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47] 
    for ch=1:36
        formatSpec = '%s_%d \n';
        fprintf(fileID,formatSpec,tmp_utt{p,ch},ix);
        ix=ix+1;
    end
end

fileID = fopen('utt_test.txt','a');
for p=[23,24,25,48,49,50]
    for ch=1:36
        formatSpec = '%s_%d \n';
        fprintf(fileID,formatSpec,tmp_utt{p,ch},ix);
        ix=ix+1;
    end
end

sp=load('spk_id.txt');
fileID = fopen('spk2gender_train.txt','a');
ix=1;
for p=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47] 
    s_id=sp(p);
    if s_id==1 || s_id==2 || s_id==3 || s_id==4
        cr='m';
    else
        cr='f';
    end
    for ch=1:36
        formatSpec = '%s_%d \t %s \n';
        fprintf(fileID,formatSpec,tmp_utt{p,ch},ix,cr);
        ix=ix+1;
    end
end

fileID = fopen('spk2gender_test.txt','a');
for p=[23,24,25,48,49,50]
    s_id=sp(p);
    if s_id==1 || s_id==2 || s_id==3 || s_id==4
        cr='m';
    else
        cr='f';
    end
    for ch=1:36
        formatSpec = '%s_%d \t %s \n';
        fprintf(fileID,formatSpec,tmp_utt{p,ch},ix,cr);
        ix=ix+1;
    end
end