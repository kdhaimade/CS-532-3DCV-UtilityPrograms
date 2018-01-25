function [depth_map] = NCC_gray(i_ref, p_right, p_left, depth_range, n_plane, k_ref, win_size)

f = floor(win_size/2);

[rows, cols, color] = size(i_ref);
depth_map = zeros(rows, cols);
%i_ref = padarray(i_ref,[f f]);
ref_u = (1/(win_size^2))*imfilter(i_ref,ones(win_size));
ref_std = zeros(rows, cols);
r_u = cell(1,length(p_right));
l_u = cell(1,length(p_left));
r_std = cell(1,length(p_right));
l_std = cell(1,length(p_left));

for x = 1:length(p_right)
    r_std{x} = zeros(rows,cols);
    l_std{x} = zeros(rows,cols);
end

for d = 1:length(p_right)
    r_u{d} = (1/(win_size^2))*imfilter(p_right{d},ones(win_size));
    l_u{d} = (1/(win_size^2))*imfilter(p_left{d},ones(win_size));
end

for j = 1:cols
    for i = 1:rows
        for d = 1:length(p_right)
            std_sum_ref = 0;
            std_sum_r = 0;
            std_sum_l = 0;
            for l = j-f:j+f
                for k = i-f:i+f
                    if k>0 && l>0 && k<=rows && l<=cols
                        std_sum_ref = std_sum_ref + ((i_ref(k,l)-ref_u(i,j))^2);
                        std_sum_r = std_sum_r + ((p_right{d}(k,l)-r_u{d}(i,j))^2);
                        std_sum_l = std_sum_l + ((p_left{d}(k,l)-l_u{d}(i,j))^2);
                    end
                end
            end
            ref_std(i,j) = sqrt((1/(win_size^2))*std_sum_ref);
            r_std{d}(i,j) = sqrt((1/(win_size^2))*std_sum_r);
            l_std{d}(i,j) = sqrt((1/(win_size^2))*std_sum_l);
        end
    end
end

for j = 1:cols
    for i = 1:rows
        dec_vec = zeros(1, length(p_right));
        for d = 1:length(p_right)
            ncc_sum_r = 0;
            ncc_sum_l = 0;
            for l = j-f:j+f
                for k = i-f:i+f
                    if k>0 && l>0 && k<=rows && l<=cols
                        ncc_sum_r = ncc_sum_r + ((i_ref(k,l)-ref_u(i,j))*(p_right{d}(k,l)-r_u{d}(i,j)));
                        ncc_sum_l = ncc_sum_l + ((i_ref(k,l)-ref_u(i,j))*(p_left{d}(k,l)-l_u{d}(i,j)));
                    end
                end
            end
            ncc_r = ncc_sum_r/(ref_std(i,j)*r_std{d}(i,j));
            ncc_l = ncc_sum_l/(ref_std(i,j)*l_std{d}(i,j));
            c = (ncc_r+ncc_l)/2;
            dec_vec(d) = c;
        end
        [val, index] = max(dec_vec);
        depth_map(i,j) = -depth_range(index) / ([j i 1.0]*inv(k_ref')*n_plane);
    end
end
