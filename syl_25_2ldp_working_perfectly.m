clear;

addpath(genpath('/data/RINI/Rini_bckp/timit_data')) ;

% 
tem = [43 44 48 49 50 56 57 101 113 114 119 120];
par=[52 53 54 55 58 59 60 61 62 63 64 72 77 78 79 85 86 91 92 95 96 99 100 107];
samp=[11 24 33 36 45 52 58 62 92 96 104 108 122 124];
tempar=[43 44 48 49 50 52 53 54 55 56 57 58 59 60 61 62 63 64 72 77 78 79 85 86 91 92 95 96 99 100 101 107 113 114 119 120];
all=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128];

top_c=1;

region=tempar;
%01D100069_timit_hear_only_eye_close_20180725_053253_band_0_60_notch50_fil
sa1_sub1 = split_data_using_marker( 'timit_data_matfiles/01D100069_timit_hear_only_eye_close_20180725_053253_band_0_60_notch50_fil.mat', '1S', '1E', 3750 );
sa2_sub1 = split_data_using_marker( 'timit_data_matfiles/01D100069_timit_hear_only_eye_close_20180725_053253_band_0_60_notch50_fil.mat', '2S', '2E', 3750 );

% 01D100066_timit_hear_only_19082018_1232_20180819_123258_band_0_60_notch50_fil

% calc STE in matlab
% strip column wise 

wintype = 'rectwin';
winlen = 250;
winamp = [0.5,1]*(1/winlen);
sa1_dsp=cell(25,1);

for n=1:25
    E=cell(128,1);
    T=sa1_sub1{n};
%     T=bandpass(T,[0.3 60],250);
    for col=1:128
        E{col}= energy(T(col,:),wintype,winamp(2),winlen);
        %tmp=sum(buffer(T(col,:).^2, winLen));
    end
    Em=cell2mat(E);
    sa1_dsp{n}=mean(Em);
end

sa2_dsp=cell(25,1);

for n=1:25
    E=cell(128,1);
    T=sa2_sub1{n};
    %T=bandpass(T_full,[0.3 60],250);
    for col=1:128
        E{col}= energy(T(col,:),wintype,winamp(2),winlen);
        %tmp=sum(buffer(T(col,:).^2, winLen));
    end
    Em=cell2mat(E);
    sa2_dsp{n}=mean(Em);
end

train_file_nos=25;
[ref_template_sa1_init, ref_template_sa2_init]=get_template_markers_from_labels(sa1_dsp,sa2_dsp,train_file_nos);

[aligned_temp_init_sa1, ref_mean_template_sa1, template_ei_sa1]=align_all_templates_to_one(ref_template_sa1_init);
[aligned_temp_init_sa2, ref_mean_template_sa2, template_ei_sa2]=align_all_templates_to_one(ref_template_sa2_init);

for iter=1:1
        if iter==1
            ref_mean=ref_mean_template_sa1;
            temp_ei=template_ei_sa1;
        else
            ref_mean=new_ref_mean_sa1;   
            temp_ei=new_template_ei_sa1;
        end   
    
        sa1_new_alseg=cell(train_file_nos,15);    
        %Perform dtw using reference vector
        for h=1:train_file_nos
            D=sa1_dsp{h};
            [dist, wp_ref_init, wp_utt] =dtw(ref_mean,D);
            wp_ref=[];
            for i=1:length(template_ei_sa1)
                seg_end=template_ei_sa1(i);
                %change wp_ref
                if i==1
                    start_id=1;
                end
                for j=start_id:length(wp_ref_init)
                    if wp_ref_init(j)<=seg_end
                        wp_ref(j)=i;
                    else
                        start_id=j;
                        break
                    end
                end               
            end              
            for t=1:length(template_ei_sa1)
                t_start=find(wp_ref==t,1);                 
                t_end=find(wp_ref==t,1,'last');
                if t_end > length(wp_utt)
                    t_end=length(wp_utt);
                end
                ts=wp_utt(t_start);
                te=wp_utt(t_end);
               
                value=D(:,ts:te);
%                 value=(value_unn-mean(value_unn))/std(value_unn);
                sa1_new_alseg{h,t}=value;                
            end
        end
        [aligned_temp_sa1, new_ref_mean_sa1, new_template_ei_sa1]=align_all_templates_to_one(sa1_new_alseg);
end

aligned_temp=horzcat(aligned_temp_init_sa1, aligned_temp_init_sa2);

junk=[];
for u=1:size(aligned_temp,2)
    for y=1:size(aligned_temp,1)
        junk(:,y)=aligned_temp{y,u};
    end
    best_template{u}=mean(junk,2)';
    junk=[];
end


% % train_file_nos_sa1=22;
% % syl_nos_sa1=15;
% % train_op=cell(train_file_nos_sa1,1);
% % for iter=1:10
% %     if iter==1
% %         sa1_alseg=cell(train_file_nos_sa1,syl_nos_sa1);
% %         sa1_alseg_mean=cell(train_file_nos_sa1,syl_nos_sa1);
% %         for h=1:train_file_nos_sa1
% %             D=sa1_dsp{h};
% %             time=length(D);
% %             fl_st=floor(time/syl_nos_sa1);
% %             for t=1:syl_nos_sa1
% %                 al_time=fl_st*t;
% %                 sa1_alseg{h,t}=D(:,(al_time-(fl_st-1)):al_time);
% %                 sa1_alseg_mean{h,t}=mean(D(:,(al_time-(fl_st-1)):al_time));
% %             end        
% %         end
% %         Z = cell2mat(sa1_alseg_mean);
% %         ref_mean=mean(Z);
% %         
% % %         for h=1:22
% % %             D=sa1_dsp{h};
% % %             train_op{h}=mean_to_label(D,ref_mean, 1);       
% % %         end
% %         
% %     else
% %         ref_mean=new_ref_mean_sa1;
% %     end
% %     
% %     
% %     sa1_new_alseg=cell(train_file_nos_sa1,syl_nos_sa1);
% %     sa1_new_alseg_mean=cell(train_file_nos_sa1,syl_nos_sa1);
% %     
% %     %Perform dtw using reference vector
% %     for h=1:train_file_nos_sa1
% %         D=sa1_dsp{h};
% %         [dist, wp_ref, wp_utt] =dtw(ref_mean,D);
% %         for t=1:syl_nos_sa1
% %             t_start=find(wp_ref==t,1);                 
% %             t_end=find(wp_ref==t,1,'last');
% %             if t_end > length(D)
% % %                 diff_len=t_end-length(D);
% % %                 wp_ref=wp_ref(diff_len+1:t_end);
% % %                 t_start=find(wp_ref==t,1);
% %                 t_end=length(D);
% %             end
% %             sa1_new_alseg{h,t}=D(:,t_start:t_end);
% %             sa1_new_alseg_mean{h,t}=mean(D(:,t_start:t_end));
% %         end
% % %         train_op{h}=mean_to_label(D,ref_mean, 1);
% %     end
% % 
% %     new_Z = cell2mat(sa1_new_alseg_mean);
% %     new_ref_mean_sa1=mean(new_Z);
% % end
% % 
% % % sa1_new_alseg is template cell array
% % 
% % 
% % 
% % train_file_nos_sa2=22;
% % syl_nos_sa2=14;
% % train_op=cell(train_file_nos_sa2,1);
% % for iter=1:1
% %     if iter==1
% %         sa2_alseg=cell(train_file_nos_sa2,syl_nos_sa2);
% %         sa2_alseg_mean=cell(train_file_nos_sa2,syl_nos_sa2);
% %         for h=1:train_file_nos_sa2
% %             D=sa2_dsp{h};
% %             time=length(D);
% %             fl_st=floor(time/syl_nos_sa2);
% %             for t=1:syl_nos_sa2
% %                 al_time=fl_st*t;
% %                 sa2_alseg{h,t}=D(:,(al_time-(fl_st-1)):al_time);
% %                 sa2_alseg_mean{h,t}=mean(D(:,(al_time-(fl_st-1)):al_time));
% %             end        
% %         end
% %         Z = cell2mat(sa2_alseg_mean);
% %         ref_mean=mean(Z);
% %         
% % %         for h=1:22
% % %             D=sa1_dsp{h};
% % %             train_op{h}=mean_to_label(D,ref_mean, 1);       
% % %         end
% %         
% %     else
% %         ref_mean=new_ref_mean_sa2;
% %     end
% %     
% %     
% %     sa2_new_alseg=cell(train_file_nos_sa2,syl_nos_sa2);
% %     sa2_new_alseg_mean=cell(train_file_nos_sa2,syl_nos_sa2);
% %     
% %     %Perform dtw using reference vector
% %     for h=1:train_file_nos_sa2
% %         D=sa2_dsp{h};
% %         [dist, wp_ref, wp_utt] =dtw(ref_mean,D);
% %         for t=1:syl_nos_sa2
% %             t_start=find(wp_ref==t,1);                 
% %             t_end=find(wp_ref==t,1,'last');
% %             if t_end > length(D)
% % %                 diff_len=t_end-length(D);
% % %                 wp_ref=wp_ref(diff_len+1:t_end);
% % %                 t_start=find(wp_ref==t,1);
% %                 t_end=length(D);
% %             end
% %             sa2_new_alseg{h,t}=D(:,t_start:t_end);
% %             sa2_new_alseg_mean{h,t}=mean(D(:,t_start:t_end));
% %         end
% % %         train_op{h}=mean_to_label(D,ref_mean, 1);
% %     end
% % 
% %     new_Z = cell2mat(sa2_new_alseg_mean);
% %     new_ref_mean_sa2=mean(new_Z);
% % end
% % 
% % train_file_nos=min(train_file_nos_sa2,train_file_nos_sa1);


% % %decoding using 2 level dp
% % template_matrix_full=[sa1_new_alseg sa2_new_alseg];
% % template_matrix=reshape(template_matrix_full,[],1) ;
% % D_cap=cell(3,1);
% % for h=train_file_nos+1:25
% %     T_sa1=sa1_dsp{h};    
% %     D_cap_int=cell(length(template_matrix),length(T_sa1));
% %     for b=1:length(T_sa1)        
% %         for class=1:length(template_matrix)
% %                 template=template_matrix{class};
% %                 temp_len=length(template);
% %                 dist_measure=zeros(1);
% %                 for e=b+floor(temp_len/2):b+2*temp_len
% %                     if e>2048
% %                         e=2048;
% %                     end
% %                     chunk=T_sa1(:,b:e);                                             
% %                     dist_measure(b,e) =dtw(chunk,template);
% %                 end
% %                 D_cap_int{class,b}=dist_measure;
% % %                 [minMatrix, e_ind] = min(dist_measure(dist_measure>0)); 
% % %                 D_cap(b,e_ind)=minMatrix;                         
% %         end         
% %     end
% %     D_cap{h-train_file_nos}=D_cap_int;
% % end
% % 
% % %create D_tilda matrix
% % D_tilda=cell(3,1);
% % sig_len=2048;
% % ref_len=638;
% % for h=1:25-train_file_nos
% %     D_cap_tmp=D_cap{h};    
% %     D_tilda_int(1:sig_len,1:sig_len)=1000;
% % %     minMatrix=zeros(2048,1);
% % %     e_ind=zeros(2048,1);    
% %     for b=1:sig_len  
% %         for ref=1:ref_len
% %             tmp_chk=D_cap_tmp{ref,b};
% %             [minMatrix(ref,b), e_ind(ref,b)] = min(tmp_chk(tmp_chk>0));        
% %         end
% %         [M,I]=min(minMatrix);
% %         end_ind=e_ind(I(b),b);
% %         %ref_template_assigned(h,b)=I(b);        
% %         D_tilda_int(b,end_ind)=M(b);
% %     end
% %     D_tilda{h}=D_tilda_int;
% % end

%best path



% % 
% % %Create one template per word using crosswords reference template
% % template_matrix_full=[sa1_new_alseg sa2_new_alseg];
% % ref_temps_length=zeros(size(template_matrix_full));
% % for k=1:size(template_matrix_full,2)
% %     for j=1:size(template_matrix_full,1)
% %         ref_temps_length(j,k)=length(template_matrix_full{j,k});
% %     end
% % end
% % avg_ref_len=mean(ref_temps_length);
% % repmat_avg=repmat(avg_ref_len,[size(template_matrix_full,1) 1]);
% % %find mnimum distance template
% % A=abs(ref_temps_length-repmat_avg);
% % [c, index] = min(A);
% % 
% % %find 5 min dist templates
% % best_five_temp=zeros(5,length(A));
% % for d=1:length(A)
% %    tmp=A(:,d);
% %    [B,In]=sort(tmp);
% %    best_five_temp(1:5,d)=In(1:5,:);
% % end
% % best_templates=cell(1,length(best_five_temp));
% % for u=1:length(best_five_temp)   
% %    min_dis_temp_no=best_five_temp(1,u);
% %    best_template{1,u}=template_matrix_full{min_dis_temp_no,u};
% % end

% % 
% % %Allign all other templates using the best template
% % wp_ref_best_5=cell(5,length(best_five_temp));
% % for u=1:length(best_five_temp)   
% %    min_dis_temp_no=best_five_temp(1,u);
% %    min_dis_template=template_matrix_full{min_dis_temp_no,u};
% %    %dtw for rest of the templates
% %    wp_ref_best_5{1,u}=min_dis_template;
% %    for d=2:5
% %        temp_to_match=template_matrix_full{best_five_temp(d,u),u};
% %        %[dist, wp_ref_best_5{d,u}, wp_utt] =dtw(min_dis_template,temp_to_match);
% %        [dist, wp_ref, wp_utt] =dtw(min_dis_template,temp_to_match,1);
% %        %make the template match the reference template length
% %        %first average out the horizontal lines
% %        
% %        %replace wp_ref with the values from the reference
% %        wp_ref_value=zeros(length(wp_ref),1);
% %        for y=1:length(wp_ref)
% %            wp_ref_value(y)=min_dis_template(wp_ref(y));
% %        end
% %        
% %        data=[wp_utt wp_ref_value];
% %        newData=[unique( data(:,1) ),accumarray( data(:,1), data(:,2), [], @mean )];
% %        
% %    end
% % end
% % 
% % 
% % %allign other templates 


% % %COncatenate the best min dist template
% % concat_template_sa1=[];
% % for u=1:15
% %     min_dis_temp_no=best_five_temp(1,u);
% %     min_dis_template=template_matrix_full{min_dis_temp_no,u};
% %     concat_template_sa1=[concat_template_sa1, min_dis_template];
% % end
% % concat_template_sa2=[];
% % for u=16:29
% %     min_dis_temp_no=best_five_temp(1,u);
% %     min_dis_template=template_matrix_full{min_dis_temp_no,u};
% %     concat_template_sa2=[concat_template_sa2, min_dis_template];
% % end
% % 
% % for h=train_file_nos+1:25
% %         D1=sa1_dsp{h};
% %         D2=sa2_dsp{h};
% %         [dist, wp_ref, wp_utt] =dtw(concat_template_sa1,D1);
% %         dist
% %         %grnd_op_sa1{h-train_file_nos}=wp_ref; %mean_to_label(D,new_ref_mean, 1);
% %         [dist2, wp_ref2, wp_utt2] =dtw(concat_template_sa2,D2);
% %         dist2
% %         %grnd_op_sa2{h-train_file_nos}=wp_ref2+syl_nos_sa1; %mean_to_label(D,new_ref_mean, 1);
% % end

% % %decoding using 2 level dp - my way

% [ref_template_sa1_init, ref_template_sa2_init]=get_template_markers_from_labels(sa1_dsp,sa2_dsp,train_file_nos);

% % % % % % % % %template_matrix=reshape(template_matrix_full,[],1) ;
% % % % % % % max_len_of_template_in_each_class=max(ref_temps_length);
% % % % % % min_b=1; %floor(mean(max_len_of_template_in_each_class));
% % % % % % D_cap=cell(3,1);
% % % % % % for h=train_file_nos+1:25
% % % % % %     T_sa1=sa1_dsp{h};    
% % % % % %     D_cap_int1=cell(length(best_template),ceil(length(T_sa1)/min_b));
% % % % % %     i=1;
% % % % % %     for b=1:min_b:length(T_sa1)        
% % % % % %         for class=1:length(best_template)
% % % % % %                 Didp=[h b class];
% % % % % %                 disp(Didp)
% % % % % %                 template=best_template{class};
% % % % % %                 temp_len=length(template);
% % % % % %                 dist_measure=zeros(1);
% % % % % %                 for e=b+floor(temp_len/2):b+2*temp_len
% % % % % %                     if e>2048
% % % % % %                         e=2048;
% % % % % %                     end
% % % % % %                     chunk=T_sa1(:,b:e);                                             
% % % % % %                     dist_measure(1,e) =dtw(chunk,template);
% % % % % %                 end
% % % % % %                 D_cap_int{class,b}=dist_measure;
% % % % % % %                 [minMatrix, e_ind] = min(dist_measure(dist_measure>0)); 
% % % % % % %                 D_cap(b,e_ind)=minMatrix;                         
% % % % % %         end      
% % % % % % %         D_cap_int1(:,i)=D_cap_int(:,b);
% % % % % % %         b_value(i)=b;
% % % % % % %         i=i+1;
% % % % % %     end
% % % % % %     D_cap{h-train_file_nos}=D_cap_int;
% % % % % % end

D_cap_struct=load('D_cap_mit.mat');
D_cap=D_cap_struct.D_cap;

%make a 3d matrix from D_cap
% mat(29,2048,2048)=inf;
mat(29,2048,2048)=inf;
for h=3:3
    tmp=D_cap{h};
    for v=1:size(tmp,1)
        for b=1:2048
            eb_dist=cell2mat(tmp(v,b));
            for e=1:length(eb_dist)
                if eb_dist(e)==0
                    mat(v,b,e)=inf;
                else
                    mat(v,b,e)=eb_dist(e);
                end
            end 
            if length(eb_dist)~=2048
                for e=length(eb_dist)+1:2048
                    mat(v,b,e)=inf;
                end
            end
        end
    end
    mat_3d{h}=mat;
end

%Create D_tilda
for h=3:3
    mat=mat_3d{h};
    for b=1:2048
        for e=1:2048
            tmp=mat(:,b,e);
            [D_tilda5(b,e), N_tilda5(b,e)]=min(tmp);
        end
    end
    D_tilda{h}=D_tilda5;
    N_tilda{h}=N_tilda5;
end

% % D_tilda=[inf inf 9 10 13 17 22 25 29 33 37 41 45 50 60; 
% %          inf inf inf 7 10 14 17 21 25 29 32 36 40 45 53;
% %          inf inf inf inf 9 13 16 19 23 26 28 32 35 40 47;
% %          inf inf inf inf inf 6 8 9 11 12 14 19 23 28 33;
% %          inf inf inf inf inf inf 4 6 8 10 12 15 19 23 30;
% %          inf inf inf inf inf inf inf 9 12 16 19 23 27 30 33;
% %          inf inf inf inf inf inf inf inf 15 18 22 27 32 37 45;
% %          inf inf inf inf inf inf inf inf inf 12 16 21 25 29 33;
% %          inf inf inf inf inf inf inf inf inf inf 6 8 10 13 16;
% %          inf inf inf inf inf inf inf inf inf inf inf 5 7 9 12;
% %          inf inf inf inf inf inf inf inf inf inf inf inf 4 6 8;
% %          inf inf inf inf inf inf inf inf inf inf inf inf inf 2 4;
% %          inf inf inf inf inf inf inf inf inf inf inf inf inf inf 2;
% %          inf inf inf inf inf inf inf inf inf inf inf inf inf inf inf;
% %          inf inf inf inf inf inf inf inf inf inf inf inf inf inf inf];

%%Create D_bar matrix
for h=3:3
    D_tilda2=D_tilda{h};
    D_bar5(1,1)=inf;
    for e=2:2048
        D_bar5(1,e)=D_tilda2(1,e);
    end

    for l=2:15
        for e=l+1:2048
            tmpr=[];
%             tmpr_ind=[];
            for b=2:e
                tmpr(b)=D_tilda2(b,e)+D_bar5(l-1,b-1);
%                 tmpr_ind(b)=b-1;
                %tmpr(b)
            end
            [D_bar5(l,e), ind5(l,e)]=min(tmpr(2:end));            
        end        
        for e=1:l
            D_bar5(l,e)=inf;
        end
    end
    D_bar{h}=D_bar5;
    ind5=ind5-1;
    ind5(ind5<0)=1;
    ind{h}=ind5;
end

%decode output
% for v=2:2
for h=3:3
    D_bar5=D_bar{h};
    ind5=ind{h};
    N_tilda5=N_tilda{h};
    [~,v]=min(D_bar5(:,2048));
%     v=15;
    for k=v:-1:1
        if k==v
            curr_bound=2048;
        end
        prev_boundary=ind5(k,curr_bound);
        prev_label=N_tilda5(prev_boundary,curr_bound);
        dec_op_dp(prev_boundary:curr_bound)=prev_label;
        curr_bound=prev_boundary;
    end
        
%     for b=2048:2048
%             e=ind5(v,b);
%             if e==0
%                 e=1;
%             end
%             dec_op_dp(b)=N_tilda5(b,e);
%     end
    decode_op_sa1{h}=dec_op_dp;
end
% end
                


% [N_tilda, D_tilda]=create_D_tilda(D_cap,train_file_nos);

% % %%create D_tilda matrix
% % D_tilda=cell(3,1);
% % sig_len=2048;
% % ref_len=29;
% % for h=1:25-train_file_nos
% %     D_cap_tmp=D_cap{h};    
% %     D_tilda_int(1:sig_len,1:sig_len)=inf;
% % %     minMatrix=zeros(2048,1);
% % %     e_ind=zeros(2048,1);    
% %     for b=1:sig_len  
% %         for ref=1:ref_len
% %             tmp_chk=D_cap_tmp{ref,b};
% %             tmp_chk(tmp_chk==0) = inf;
% %             [minMatrix(ref,b), e_ind(ref,b)] = min(tmp_chk);        
% %         end
% %         [M,I]=min(minMatrix);
% %         end_ind=e_ind(I,b);
% %         %ref_template_assigned(h,b)=I(b);        
% %         D_tilda_int(b,end_ind)=M;
% %     end
% %     D_tilda{h}=D_tilda_int;
% % end

% D_tilda_struct=load('D_tilda.mat');
% D_tilda=D_tilda_struct.D_tilda;

%calc of D_bar
% [D_bar]=create_D_bar(D_tilda,train_file_nos);


% % Decode using concatenation
% for i=1:size(sa1_new_alseg,1)
%     concat_temp(i)={horzcat(sa1_new_alseg{i,:})};
% %     concat_tempa{i,1}=reshape(a{i,1},2080,1);
% end
% a(:,2:size(a,2))=[];

    
%     decode_op_sa1{h-train_file_nos}=mean_to_label(T_sa1,test_ref_vector, top_c); 
%     T_sa2=sa2_dsp{h};
%     decode_op_sa2{h-train_file_nos}=mean_to_label(T_sa2,test_ref_vector, top_c);
% end



% % 
% % %decoding
% % test_ref_vector=horzcat(new_ref_mean_sa1,new_ref_mean_sa2) ;
% % decode_op_sa1=cell(3,1);
% % decode_op_sa2=cell(3,1);
% % for h=train_file_nos+1:25
% %     T_sa1=sa1_dsp{h};
% %     decode_op_sa1{h-train_file_nos}=mean_to_label(T_sa1,test_ref_vector, top_c); 
% %     T_sa2=sa2_dsp{h};
% %     decode_op_sa2{h-train_file_nos}=mean_to_label(T_sa2,test_ref_vector, top_c);
% % end

%Accuracy calculation
%ground truth
train_file_nos=22;
grnd_op_sa1=cell(25-train_file_nos,1);
% grnd_op_sa2=cell(25-train_file_nos,1);

% % ref_mean=[];
% % for j=1:length(best_template)
% %     f=best_template{j};
% %     mu=mean(f);
% %     ref_mean(j)=mu;
% % end
% % for h=23:25 %train_file_nos+1:25
% %         D1=sa1_dsp{h};
% % %         D2=sa2_dsp{h};
% %         [dist, wp_ref, wp_utt] =dtw(ref_mean,D1);
% %         grnd_op_sa1{h-train_file_nos}=wp_ref; %mean_to_label(D,new_ref_mean, 1);
% % %         [dist2, wp_ref2, wp_utt2] =dtw(new_ref_mean_sa2,D2);
% % %         grnd_op_sa2{h-train_file_nos}=wp_ref2+syl_nos_sa1; %mean_to_label(D,new_ref_mean, 1);
% % end

grnd_op_sa1=cell(25-train_file_nos,1);
for h=train_file_nos+1:25
            D1=sa1_dsp{h};

            [dist, wp_ref_init, wp_utt] =dtw(new_ref_mean_sa1,D1);  
            wp_utt_ei=[];
            g=horzcat(wp_ref_init,wp_utt);
            for i=1:length(new_template_ei_sa1)
                seg_end=new_template_ei_sa1(i);
                %change wp_ref
                if i==1
                    start_id=1;
                end
                for j=start_id:length(wp_ref_init)
                    if g(j,1)<=seg_end
%                         wp_ref(j)=i;
                        %do nothing
                        o=1;
                    else
                        val=g(j-1,2);
                        start_id=j;
                        break
                    end
                end  
                wp_utt_ei(i)=val;
            end   
            wp_utt_ei(length(new_template_ei_sa1))=2048;
            wp_gt=[];
            for hl=1:length(wp_utt_ei)
                if hl==1
                    l=wp_utt_ei(hl);
                else
                    l=wp_utt_ei(hl)-wp_utt_ei(hl-1);
                end
                wp_gt=[wp_gt repelem(hl,l)];
            end
            
            
            grnd_op_sa1{h-train_file_nos}=wp_gt; %mean_to_label(D,new_ref_mean, 1);            
           
end

%Replace same value for sil 
% let sil value be 77
for i=3:3 %1:25-train_file_nos
    grnd_op_sa1{i}=replace_for_sil(grnd_op_sa1{i});
%     grnd_op_sa2{i}=replace_for_sil(grnd_op_sa2{i});
    decode_op_sa1{i}=replace_for_sil(decode_op_sa1{i});
%     decode_op_sa2{i}=replace_for_sil(decode_op_sa2{i});
end
    

Acc1=zeros(25-train_file_nos,1);
Acc2=zeros(25-train_file_nos,1);
for i=3:3 %1:25-train_file_nos
    A=grnd_op_sa1{i}';
    B=decode_op_sa1{i}';
    time=length(A);
    pos=0;
    for t=1:time
        for j=1:top_c
            if B(t,j)==A(t,1)
                pos=pos+1;
            end
        end
    end
    Acc1(i)=pos/time;
end

% % for i=1:25-train_file_nos
% %     A=grnd_op_sa2{i};
% %     B=decode_op_sa2{i};
% %     time=length(A);
% %     pos=0;
% %     for t=1:time
% %         for j=1:top_c
% %             if B(t,j)==A(t,1)
% %                 pos=pos+1;
% %             end
% %         end
% %     end
% %     Acc2(i)=pos/time;
% % end
 
%Acc*100
    


