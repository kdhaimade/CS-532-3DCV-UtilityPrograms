% Sample use of PointCloud2Image(...)
% 
% The following variables are contained in the provided data file:
%       BackgroundPointCloudRGB,ForegroundPointCloudRGB,K,crop_region,filter_size
% None of these variables needs to be modified


clc
clear all
% load variables: BackgroundPointCloudRGB,ForegroundPointCloudRGB,K,crop_region,filter_size)
load data.mat

data3DC = {BackgroundPointCloudRGB,ForegroundPointCloudRGB};
R       = eye(3);
move    = [0 0 -0.025]';

for step=0:74
    tic
    fname       = sprintf('CS532_HW1_Dolly_OP%03d.jpg',step);
    display(sprintf('\nGenerating %s',fname));
    t           = step * move;
    z = 3.4087 + t(3)
    
    fx = 400/(0.3287 + 0.05) * z
    fy = 640/(0.0529 + 0.55) * z
    K(2,2) = fx
    K(1,1) = fy
    
    M           = K*[R t];
    im          = PointCloud2Image(M,data3DC,crop_region,filter_size);
    imwrite(im,fname);
    toc    
end
