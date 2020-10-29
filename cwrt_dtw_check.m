clear;

addpath(genpath('/data/RINI/Rini_bckp/timit_data')) ;

% 
tem = [43 44 48 49 50 56 57 101 113 114 119 120];
par=[52 53 54 55 58 59 60 61 62 63 64 72 77 78 79 85 86 91 92 95 96 99 100 107];
samp=[11 24 33 36 45 52 58 62 92 96 104 108 122 124];
tempar=[43 44 48 49 50 52 53 54 55 56 57 58 59 60 61 62 63 64 72 77 78 79 85 86 91 92 95 96 99 100 101 107 113 114 119 120];
all=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128];

top_c=1;

region=all;
%01D100069_timit_hear_only_eye_close_20180725_053253_band_0_60_notch50_fil
sa1_sub11 = split_data_using_marker( 'timit_data_matfiles/01D100069_timit_hear_only_eye_close_20180725_053253_band_0_60_notch50_fil.mat', '1S', '1E', 3750 );
sa2_sub11 = split_data_using_marker( 'timit_data_matfiles/01D100069_timit_hear_only_eye_close_20180725_053253_band_0_60_notch50_fil.mat', '2S', '2E', 3750 );

% 01D100066_timit_hear_only_19082018_1232_20180819_123258_band_0_60_notch50_fil

% calc STE in matlab
% strip column wise 

wintype = 'rectwin';
winlen = 250;
winamp = [0.5,1]*(1/winlen);
sa1_dsp=cell(25,1);


    for g=1:25
        A=sa1_sub11{g};
        B=zeros(length(region),size(A,2));
        for i = 1:length(region)
            indd=region(i);
            B(i,:)=A(indd,:);
        end
        sa1_sub1{g}=B;
    end

    for g=1:25
        A=sa2_sub11{g};
        B=zeros(length(region),size(A,2));
        for i = 1:length(region)
            indd=region(i);
            B(i,:)=A(indd,:);
        end
        sa2_sub1{g}=B;
    end


for n=1:25
    E=cell(length(region),1);
    T=sa1_sub1{n};
%     T=bandpass(T,[0.3 60],250);
    for col=1:length(region)
        E{col}= energy(T(col,:),wintype,winamp(2),winlen);
        %tmp=sum(buffer(T(col,:).^2, winLen));
    end
    Em=cell2mat(E);
%     sa1_dsp{n}=Em;
    sa1_dsp{n}=mean(Em);
end

sa2_dsp=cell(25,1);

for n=1:25
    E=cell(length(region),1);
    T=sa2_sub1{n};
    %T=bandpass(T_full,[0.3 60],250);
    for col=1:length(region)
        E{col}= energy(T(col,:),wintype,winamp(2),winlen);
        %tmp=sum(buffer(T(col,:).^2, winLen));
    end
    Em=cell2mat(E);
%     sa2_dsp{n}=Em;
   sa2_dsp{n}=mean(Em);
end

train_file_nos=25;
[ref_template_sa1_init, ref_template_sa2_init]=get_template_markers_from_labels_all_ch(sa1_dsp,sa2_dsp,train_file_nos);

[aligned_temp_init_sa1, ref_mean_template_sa1, template_ei_sa1]=align_all_templates_to_one(ref_template_sa1_init);
[aligned_temp_init_sa2, ref_mean_template_sa2, template_ei_sa2]=align_all_templates_to_one(ref_template_sa2_init);

tr=20;
te=5;

ref=[ref_template_sa1_init ref_template_sa2_init];
% ref=ref_template_sa1_init;

%top=10;
acc=[];
for top=1:20
    grd_truth=[];
    label=[];
    for k=1:size(ref,2)  
        for i=21:25
            dist=[];
            for syl=1:size(ref,2)        
                for j=1:20
                    dist(j,syl) =dtw(cell2mat(ref(j,syl)),cell2mat(ref(i,k)));
                end
            end
            [sortedX, sortedInds] = sort(dist(:),'ascend');
            topk = sortedInds(1:top); 
            [row_ind, col_ind] = ind2sub(size(dist), topk);
            [label(i-20,k), freq]=mode(col_ind);
            if freq==1
                [m,in]=min(dist);
                [f,label(i-20,k)]=min(m);
            end
% % % %         [B,I]=mink(dist,top);
% % % %         [m,in]=mink(dist);
%         [m,in]=min(dist);
%         [f,label(i-20,k)]=min(m);

        end
        grd_truth=[grd_truth; repelem(k,5)];
    end
    grd_truth=grd_truth';
    
    %replace for sil
    for len=1:length(grd_truth)
        for nos=1:size(grd_truth,1)
            if grd_truth(nos,len)==1 || grd_truth(nos,len)==15 || grd_truth(nos,len)==16 || grd_truth(nos,len)==29
                grd_truth(nos,len)==1;
            end
            if label(nos,len)==1 || label(nos,len)==15 || label(nos,len)==16 || label(nos,len)==29
                label(nos,len)==1;
            end
        end
    end
            

%calc accuracy
    hit=0;
    for i=1:5
        for j=1:size(ref,2) 
            if grd_truth(i,j)==label(i,j)
                hit=hit+1;
            end
        end
    end
    acc(top)=hit/(5*size(ref,2));
end

