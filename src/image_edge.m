function [ im_edge, im_half ] = image_edge( im_name )
%IMAGE_EDGE detects edges in image 

%   Edge detection is performed substracting
%   original image and image shifted down by one
%   
%   im_name - input image name, eg. 'image1.gif'
%   im_edge - detected edge in image
%   im_half - lower half of im_edge
close all
LQ = imread(im_name);
[h, w] = size(LQ);
LQ((LQ > 0)) = 255;
Empty = 255*ones(1, w);
LQshift = [Empty; LQ(1:h, :)];
ExtendLQ = [LQ; Empty];
[height, width] = size(ExtendLQ);
im_edge = zeros(height, width);
for m=1:height
    for n=1:width
        if(ExtendLQ(m,n) ~= LQshift(m,n))
            im_edge(m,n) = 0;
        else
            im_edge(m,n) = 255;
        end
    end
end
start = int32(height/2)+1;
im_half = im_edge(start:end, :);
filled_h = image_fill(im_half);
filled = image_fill(filled_h);
#figure
#subplot(3,1,1), imshow(LQ(start:end, :))
#subplot(3,1,2), imshow(im_half)
#subplot(3,1,3), imshow(imsharpen(filled_h))

end