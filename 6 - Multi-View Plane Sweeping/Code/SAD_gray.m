function [depth_map] = SAD_gray(i_ref, p_right, p_left, depth_range, n_plane, k_ref, win_size)

f = floor(win_size/2);

[rows, cols, color] = size(i_ref);
depth_map = zeros(rows, cols);
i_ref = padarray(i_ref,[f f]);
dr = cell(1,length(p_right));
dl = cell(1,length(p_left));

for d = 1:length(p_right)
    dr{d} = abs(i_ref-padarray(p_right{d},[f f]));
    dl{d} = abs(i_ref-padarray(p_left{d},[f f]));
end

for j = 1:cols
    for i = 1:rows
        dec_vec = zeros(1, length(p_right));
        for d = 1:length(p_right)
            sr = sum(sum(dr{d}(i:i+(win_size-1),j:j+(win_size-1))));
            sl = sum(sum(dl{d}(i:i+(win_size-1),j:j+(win_size-1))));
            c = (sr+sl)/2;
            dec_vec(d) = c;
        end
        [val, index] = min(dec_vec);
        depth_map(i,j) = -depth_range(index) / ([j i 1.0]*inv(k_ref')*n_plane);
    end
end
