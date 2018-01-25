pm0 = [776.649963 -298.408539 -32.048386 993.1581875;132.852554 120.885834 -759.210876 1982.174000;0.744869 0.662592 -0.078377 4.629312012];
pm1 = [431.503540 586.251892 -137.094040 1982.053375;23.799522 1.964373 -657.832764 1725.253500;-0.321776 0.869462 -0.374826 5.538025391];
pm2 = [-153.607925 722.067139 -127.204468 2182.4950;141.564346 74.195686 -637.070984 1551.185125;-0.769772 0.354474 -0.530847 4.737782227];
pm3 = [-823.909119 55.557896 -82.577644 2498.20825;-31.429972 42.725830 -777.534546 2083.363250;-0.484634 -0.807611 -0.335998 4.934550781];
pm4 = [-715.434998 -351.073730 -147.460815 1978.534875;29.429260 -2.156084 -779.121704 2028.892750;0.030776 -0.941587 -0.335361 4.141203125];
pm5 = [-417.221649 -700.318726 -27.361042 1599.565000;111.925537 -169.101776 -752.020142 1982.983750;0.542421 -0.837170 -0.070180 3.929336426];
pm6 = [94.934860 -668.213623 -331.895508 769.8633125;-549.403137 -58.174614 -342.555359 1286.971000;0.196630 -0.136065 -0.970991 3.574729736];
pm7 = [452.159027 -658.943909 -279.703522 883.495000;-262.442566 1.231108 -751.532349 1884.149625;0.776201 0.215114 -0.592653 4.235517090];
s0 = imread('silh_cam00_00023_0000008550.pbm');
s1 = imread('silh_cam01_00023_0000008550.pbm');
s2 = imread('silh_cam02_00023_0000008550.pbm');
s3 = imread('silh_cam03_00023_0000008550.pbm');
s4 = imread('silh_cam04_00023_0000008550.pbm');
s5 = imread('silh_cam05_00023_0000008550.pbm');
s6 = imread('silh_cam06_00023_0000008550.pbm');
s7 = imread('silh_cam07_00023_0000008550.pbm');
i0 = imread('cam00_00023_0000008550.png');
i1 = imread('cam01_00023_0000008550.png');
i2 = imread('cam02_00023_0000008550.png');
i3 = imread('cam03_00023_0000008550.png');
i4 = imread('cam04_00023_0000008550.png');
i5 = imread('cam05_00023_0000008550.png');
i6 = imread('cam06_00023_0000008550.png');
i7 = imread('cam07_00023_0000008550.png');

pm = zeros(3,4,8);
s = zeros(582, 780, 8);
im = zeros(582, 780, 3, 8);
pm(:,:,1) = pm0; pm(:,:,2) = pm1; pm(:,:,3) = pm2; pm(:,:,4) = pm3; pm(:,:,5) = pm4; pm(:,:,6) = pm5; pm(:,:,7) = pm6; pm(:,:,8) = pm7;
s(:,:,1) = s0; s(:,:,2) = s1; s(:,:,3) = s2; s(:,:,4) = s3; s(:,:,5) = s4; s(:,:,6) = s5; s(:,:,7) = s6; s(:,:,8) = s7;
im(:,:,:,1) = i0; im(:,:,:,2) = i1; im(:,:,:,3) = i2; im(:,:,:,4) = i3; im(:,:,:,5) = i4; im(:,:,:,6) = i5; im(:,:,:,7) = i6; im(:,:,:,8) = i7;

x_grid = 5;
y_grid = 6;
z_grid = 2.5;
vol = x_grid * y_grid * z_grid;
no_voxs = 10000000;
vox_s = nthroot(vol/no_voxs,3);
true_no_voxs = 0;
total_no_voxs = 0;
vox_mat = [];
sur_vox_mat = [];
color_mat = [];
fl = 0;
prev_vec = [];

for x = -x_grid/2:vox_s:x_grid/2
    for y = -y_grid/2:vox_s:y_grid/2
        for z = 0:vox_s:z_grid
            dec_v = [0 0 0 0 0 0 0 0];
            total_no_voxs = total_no_voxs + 1;
            w_col = [x y z 1.0].';
            for i = 1:8
                uv_cor = pm(:,:,i)*w_col;
                uv_cor = round(uv_cor/uv_cor(3));
                if (1<=uv_cor(1)) && (uv_cor(1)<=780) && (1<=uv_cor(2)) && (uv_cor(2)<=582)
                    dec_v(i) = s(uv_cor(2),uv_cor(1),i);
                end
            end
            if all(dec_v) == 1
                true_no_voxs = true_no_voxs + 1;
                vox_mat = [vox_mat;[x y z]];
                r = im(uv_cor(2), uv_cor(1), 1, 8);
                g = im(uv_cor(2), uv_cor(1), 2, 8);
                b = im(uv_cor(2), uv_cor(1), 3, 8);
                color_mat = [color_mat;[r g b]];
                
                % The code below is for detecting surface voxels
                % and discarding non-surface voxels.
                if fl == 0
                    sur_vox_mat = [sur_vox_mat;[x y z]];
                    fl = fl+1;
                    prev_vec = [x y z];
                    continue;
                end
                if (prev_vec(1)==x) && (prev_vec(2)==y)
                    fl = fl+1;
                else
                    if fl > 1
                        sur_vox_mat = [sur_vox_mat;prev_vec;[x y z]];
                        f1=1;
                    else
                        sur_vox_mat = [sur_vox_mat;[x y z]];
                        f1=1;
                    end
                end
                if fl > 0
                    prev_vec = [x y z];
                end
            end
        end
    end
end

vox_mat_ptc = pointCloud(vox_mat);
vox_mat_ptc.Color = uint8(color_mat);
pcwrite(vox_mat_ptc,'dancer_full_colored_2','PLYFormat','ascii');
full_mod = pcread('dancer_full_colored_2.ply');
pcshow(full_mod);

%The code below is for creating a PLY file for the point cloud
%created by using only surface voxels.

sur_vox_mat_ptc = pointCloud(sur_vox_mat);
%sur_vox_mat_ptc.Color = uint8(color_mat);
pcwrite(sur_vox_mat_ptc,'dancer_surf_2','PLYFormat','ascii');
surf_mod = pcread('dancer_surf_2.ply');
pcshow(surf_mod);

