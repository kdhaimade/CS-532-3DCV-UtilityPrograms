
tic

clear all;
close all;

og_w = 3072;
og_h = 2048;
sf = 0.25;

i_ref = imread('data/0005.png');
i1 = imread('data/0004.png');
i2 = imread('data/0006.png');
i_ref = imresize(i_ref,sf);
i1 = imresize(i1,sf);
i2 = imresize(i2,sf);
i_ref = im2double(i_ref);
i1 = im2double(i1);
i2 = im2double(i2);

k_ref = [2759.48 0 1520.69;0 2764.16 1006.81;0 0 1];
r_ref = [0.962742 -0.0160548 -0.269944 ;-0.270399 -0.0444283 -0.961723 ;0.00344709 0.998884 -0.0471142];
t_ref = [-14.1604 -3.32084 0.0862032 ]';

a_x = 2*atan(1520.69/2759.48);
a_y = 2*atan(1006.81/2764.16);
f_x = ((og_w*sf)/2)/(tan(a_x/2));
f_y = ((og_h*sf)/2)/(tan(a_y/2));
k_ref = [f_x 0 ((og_w*sf)/2);0 f_y ((og_h*sf)/2);0 0 1];

r1 = [0.890856 -0.0211638 -0.453793; -0.454283 -0.0449857 -0.889721; -0.00158434 0.998763 -0.0496901 ];
t1 = [-12.404 -3.81315 0.110559]';
r2 = [0.994915 -0.00462005 -0.100616; -0.100715 -0.0339759 -0.994335; 0.00117536 0.999412 -0.0342684];
t2 = [-15.8818 -3.15083 0.0592619]';
k1 = k_ref;
k2 = k_ref;

ext_ref = inv([r_ref t_ref; [0 0 0 1]]);
ext_r1 = inv([r1 t1 ; [0 0 0 1]]);
ext_r2 = inv([r2 t2 ; [0 0 0 1]]);

ext_refi = inv(ext_ref);
r1_ref = ext_r1*ext_refi;
r2_ref = ext_r2*ext_refi;

r01 = r1_ref(1:3,1:3);
t01 = r1_ref(1:3,4);
r02 = r2_ref(1:3,1:3);
t02 = r2_ref(1:3,4);

n = [0 0 -1]';
%n = r01*n;
n = r02*n;

znear = 4.75;
zfar = 9.75;
no_planes = 50;
win_size = 15;

zstep = (zfar-znear)/no_planes;

[rows, cols, color] = size(i_ref);
i1_warped = cell(1,no_planes+1);
for x = 1:length(i1_warped)
    i1_warped{x} = zeros(rows,cols);
end
i2_warped = i1_warped;
depth_range = znear:zstep:zfar;

x1 = repmat(1:cols,rows,1);
y1 = repmat((1:rows)',1,cols);

di = 0;
for d = znear:zstep:zfar
    di = di + 1;
    h1 = k1*(r01-((t01*n')/d))*inv(k_ref);
    h1 = h1/h1(3,3);
    h2 = k2*(r02-((t02*n')/d))*inv(k_ref);
    h2 = h2/h2(3,3);
    x2 = bsxfun(@plus, bsxfun(@plus, bsxfun(@times, h1(1,1), x1), bsxfun(@times, h1(1,2), y1)), h1(1,3));
    y2 = bsxfun(@plus, bsxfun(@plus, bsxfun(@times, h1(2,2), y1), bsxfun(@times, h1(2,1), x1)), h1(2,3));
    w  = bsxfun(@plus, bsxfun(@plus, bsxfun(@times, h1(3,1), x1), bsxfun(@times, h1(3,2), y1)), h1(3,3));
    x2 = bsxfun(@rdivide, x2, w);
    y2 = bsxfun(@rdivide, y2, w);
    i1_warped{di} = interp2(x1, y1, 255*rgb2gray(i1), x2, y2, 'linear', 0);
%     for j = 1:cols
%         for i = 1:rows
%             if round(x2(i, j))>0 && round(x2(i, j))<=cols && round(y2(i, j))>0 && round(y2(i, j))<=rows
%                 i1_warped{di}(i, j, 1) = i1(round(y2(i, j)), round(x2(i, j)), 1);
%                 i1_warped{di}(i, j, 2) = i1(round(y2(i, j)), round(x2(i, j)), 2);
%                 i1_warped{di}(i, j, 3) = i1(round(y2(i, j)), round(x2(i, j)), 3);
%             end
%         end
%     end
    x2 = bsxfun(@plus, bsxfun(@plus, bsxfun(@times, h2(1,1), x1), bsxfun(@times, h2(1,2), y1)), h2(1,3));
    y2 = bsxfun(@plus, bsxfun(@plus, bsxfun(@times, h2(2,2), y1), bsxfun(@times, h2(2,1), x1)), h2(2,3));
    w  = bsxfun(@plus, bsxfun(@plus, bsxfun(@times, h2(3,1), x1), bsxfun(@times, h2(3,2), y1)), h2(3,3));
    x2 = bsxfun(@rdivide, x2, w);
    y2 = bsxfun(@rdivide, y2, w);
    i2_warped{di} = interp2(x1, y1, 255*rgb2gray(i2), x2, y2, 'linear', 0);      
end

[depth_map] = NCC_gray(255*rgb2gray(i_ref), i1_warped, i2_warped, depth_range, n, k_ref, win_size);
%[op] = test2(255*rgb2gray(i_ref), i1_warped, i2_warped, depth_range, n, k_ref, win_size);

figure;
title('Depth Map');
imshow(uint8(depth_map*16));
imwrite(uint8((depth_map*16)),strcat('left_',num2str(znear),'to',num2str(zfar),'_',num2str(no_planes),'p_','ncc',num2str(win_size),'_depthmap.jpg'));

figure;
title('Color Map');
cim = imagesc(depth_map,[znear, zfar]);
colormap(jet);

ErrorReport(depth_map, sf);

toc
