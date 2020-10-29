function [t_new]=compress_expand_algo_for_cwrt(temp1,temp2)



    [dist, wp_ref, wp_utt] =dtw(temp1,temp2);

%check vectors
% wp_ref=[1 2 3 3 3 3 3 3 3 4 5 6 7 8 9 9 10 11 12];
% wp_utt=[1 2 3 4 5 6 7 8 9 10 10 10 10 10 11 12 12 12 12];


%
    ref=0;
    utt=0;
    frame=temp2(:,wp_utt(1));
    count=1;
    k=1;

    for l=1:(length(wp_ref)-1)
        ref=wp_ref(l);
        utt=wp_utt(l);
        ref_next=wp_ref(l+1);
        utt_next=wp_utt(l+1);
        if ref_next~=ref && utt_next~=utt
            t_new(:,k)=frame./count;
            k=k+1;
            frame=temp2(:,utt_next);
            count=1;
        elseif ref_next==ref
            %op=frame/count;
            frame=frame+temp2(:,utt);
            count=count+1;
        elseif utt_next==utt
            t_new(:,k)=frame./count;
            k=k+1;
            count=1;
            frame=temp2(:,utt);
        end
    
    %     t_new(k)=op;
    %     k=k+1;
    end
 
    t_new(:,k)=temp2(:,wp_utt(length(wp_utt)));
    
end
        
        
    
    

% % iterations_to_skip = 0;
% % k=length(temp1);
% % for l=length(wp_ref):-1:2    
% %     if iterations_to_skip > 0
% %         iterations_to_skip = iterations_to_skip - 1;
% %         continue;
% %     end
% %     if wp_ref(l)==wp_utt(l) && wp_ref(l-1)==wp_utt(l-1)
% % %         slope(l)=1;
% %         temp2_new(k)=temp2(wp_utt(l));
% % %         wp(k)=wp_utt(l);
% %         k=k-1;
% %     elseif wp_ref(l)==wp_ref(l-1) && wp_utt(l)~=wp_utt(l-1)
% % %         slope(l)=0;
% %             count=0;
% %             for c=1:2048
% %                 if wp_ref(l-c)==wp_ref(l)
% %                     count=count+1;
% %                 else
% %                     break
% %                 end
% %             end
% %             temp2_new(k)=mean(temp2((wp_utt(l-count+1):wp_utt(l))));
% %             k=k-1; 
% %             iterations_to_skip=count;
% %     elseif wp_ref(l)~=wp_ref(l-1) && wp_utt(l)==wp_utt(l-1)
% %         count_u=0;
% %         for c=1:2048
% %             if wp_utt(l-c)==wp_utt(l)
% %                 count_u=count_u+1;
% %             else
% %                 break
% %             end
% %         end
% %         for j=1:count_u+1
% %             temp2_new(k)=temp2(wp_utt(l));
% %             k=k-1;
% %         end
% %         iterations_to_skip=count_u;
% %     end
% % end
% % 
% % iterations_to_skip

    