function [aligned_temp, ref_mean_template, template_ei]=align_all_templates_to_one(template_matrix_full)

%Create one template per word using crosswords reference template
% template_matrix_full=[ref_template_sa1_init ref_template_sa2_init];
ref_temps_length=zeros(size(template_matrix_full));
for k=1:size(template_matrix_full,2)
    for j=1:size(template_matrix_full,1)
        ref_temps_length(j,k)=length(template_matrix_full{j,k});
    end
end
avg_ref_len=mean(ref_temps_length);
repmat_avg=repmat(avg_ref_len,[size(template_matrix_full,1) 1]);
%find mnimum distance template
A=abs(ref_temps_length-repmat_avg);
[c, index] = min(A);

for i=1:size(template_matrix_full,2)
    best_temp=template_matrix_full{index(i),i};
    for j=1:size(template_matrix_full,1)
        aligned_temp{j,i}= compress_expand_algo_for_cwrt(best_temp,template_matrix_full{j,i});
    end
end

ref_mean_template=[];
for i=1:size(template_matrix_full,2)
    for j=1:size(aligned_temp,1)
        tmp{j}=aligned_temp{j,i};
    end
    init=cat(3,tmp{:});
    mn=mean(init,3);
    
    template_ei(i)=size(cell2mat(tmp'),2);
    ref_mean_template=[ref_mean_template, mn];
%    ref_mean_template=[ref_mean_template, mean(cell2mat(tmp'))];
end

template_ei=cumsum(template_ei);
