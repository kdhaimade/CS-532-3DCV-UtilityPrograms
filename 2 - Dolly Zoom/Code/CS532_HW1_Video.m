 writerObj = VideoWriter('Video.avi');
 writerObj.FrameRate = 15;
 open(writerObj);

 sourceFile = dir('D:\Study\MS\3rd Term - Fall 2017\3D Computer Vision\Homework\1\Dolly_Data_Code\Dolly_Data_Code\OP\1\*.jpg');
 for i = 1: length(sourceFile)
  filename = strcat('D:\Study\MS\3rd Term - Fall 2017\3D Computer Vision\Homework\1\Dolly_Data_Code\Dolly_Data_Code\OP\1\',sourceFile(i).name);
  images = imread(filename);
  frame = im2frame(images);
  writeVideo(writerObj, frame);
 end

 close(writerObj);