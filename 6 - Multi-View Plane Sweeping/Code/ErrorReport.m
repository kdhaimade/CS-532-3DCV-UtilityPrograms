function [] = ErrorReport(depth_map, sf)

load data.mat
bg3d = BackgroundPointCloudRGB(1:3,:);
fg3d = ForegroundPointCloudRGB(1:3,:);
p3d = [bg3d fg3d];
p3d(4,:) = 1;

k_ref = [[2759.48 0 1520.69;0 2764.16 1006.81;0 0 1] [0 0 0]'];
ext_ref = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1];
p_ref = k_ref*ext_ref;

uv = p_ref*p3d;
uv(1,:) = uv(1,:)./uv(3,:); 
uv(2,:) = uv(2,:)./uv(3,:);

GT_map = zeros(uv(1,end),uv(2,end));

for i = 1:length(uv)
    GT_map(round(uv(2,i)),round(uv(1,i))) = uv(3,i);
end

GT_map = im2double(imresize(GT_map,sf));
[rows, cols, color] = size(GT_map);

% figure;
% imshow(uint8(GT_map));
% figure;
% imagesc(GT_map);
% colormap jet;
% colorbar;

depth_map;

error_map = abs(GT_map - depth_map);
avg_pix_error = (sum(sum(error_map)))/(rows*cols);
disp(avg_pix_error);
figure;
imagesc(error_map);
colormap jet;

%er_fn = erf(error_map);
% y_p = 0.5*erfc(er_fn/sqrt(2));
% plot(error_map,y_p);
