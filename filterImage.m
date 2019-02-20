%Function used to filter an image using a switching median filter.
%Reference: Pei-Eng Ng, Kai-Kuang Ma, “A switching median filter with boundary discriminative noise
%detection for extremely corrupted images”, IEEE Journals & Magazines, vol. 15, 2006, pp. 1506-1516.
%@version 1.0
%@author Veinstin Furtado <vrfurtado@mun.ca>

function [filteredImage] = filterImage(noisyImage)
input = noisyImage;
output = input;
[row col] = size(input);
input_padded = padarray(input,[2 2],'replicate','both');
[row_padded col_padded] = size(input_padded);
predicate_matrix = zeros(size(input,1),size(input,2));
%iterating through elements in the padded matrix
for i = 3:row_padded-2
    for j = 3:col_padded-2
        % Create a temporary 5X5 submatrix
        a = i-2;
        b = j-2;
        win1 = input_padded(a:a+4,b:b+4);
        v0 = sort(reshape(win1',[],1));
        med =  median(v0);
        vD  = diff(v0);
        %idx_med = find(v0 == med, 1, 'first');
        % computing boundary 1
        idx_med = ceil(size(v0,1)/2);
        [maxVal_f,maxVal_idx_f] = max(vD(1:idx_med-1));
        b1 = v0(maxVal_idx_f);
        % computing boundary 2
        [maxVal_s,maxVal_idx_s] = max(vD(idx_med:size(v0,1)-1));
        b2 = v0(idx_med + maxVal_idx_s - 1);
        % first set of clusters
        cluster_one = v0(1:maxVal_idx_f,:);
        cluster_two = v0(maxVal_idx_f+1:idx_med + maxVal_idx_s - 1,:);
        cluster_three = v0(idx_med + maxVal_idx_s:size(v0,1),:);
        
        if(ismember(win1(3,3),cluster_three)|| ismember(win1(3,3),cluster_one))
            %invoke the second iteration again with a 3X3 window
            c = i-1;
            d = j-1;
            win2 = input_padded(c:c+2,d:d+2);
            v0_2 = sort(reshape(win2',[],1));
            med_2 =  median(v0_2);
            vD_2  = diff(v0_2);
            % for second boundary 1
            idx_med_2 = ceil(size(v0_2,1)/2);
            [maxVal_f_2,maxVal_idx_f_2] = max(vD_2(1:idx_med_2-1));
            b1_2 = v0_2(maxVal_idx_f_2);
            % for second boundary 2
            [maxVal_s_2,maxVal_idx_s_2] = max(vD_2(idx_med_2:size(v0_2,1)-1));
            b2_2 = v0_2(idx_med_2 + maxVal_idx_s_2 - 1);
            % second set of clusters
            cluster_one_2 = v0_2(1:maxVal_idx_f_2,:);
            cluster_two_2 = v0_2(maxVal_idx_f_2+1:idx_med_2 + maxVal_idx_s_2 - 1,:);
            cluster_three_2 = v0_2(idx_med_2 + maxVal_idx_s_2:size(v0_2,1),:);
            if(ismember(win2(2,2),cluster_three_2)||ismember(win2(2,2),cluster_one_2))
                predicate_matrix(i-2,j-2) = 1;
            else
                predicate_matrix(i-2,j-2) = 0;
            end
        else
            predicate_matrix(i-2,j-2) = 0;
        end
        
    end
end

%Filtering operation
for x = 3:row_padded-2
    for y = 3:col_padded-2
          if(predicate_matrix(x-2,y-2) == 1)
          window_filter = input_padded(x-1:x-1+2,y-1:y-1+2);
          asc = sort(reshape(window_filter',[],1));
          median_filter_output = median(asc);
          %median_filter_output = (window_filter(2,1) + window_filter(2,3))/2;
          input_padded(x,y) = median_filter_output;
          output(x-2,y-2) =  input_padded(x,y);
          end
     end
end
filteredImage=output;
end
