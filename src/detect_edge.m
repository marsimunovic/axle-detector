function [ bottom_edge ] = detect_edge( input_image )
%DETEC_EDGE detects lower boundary of the vehicle
%   
% input_image - matrix represantation of an image
% bottom_edge - height at which first black pixel is found

[height, width] = size(input_image);
norm_image = input_image;
bottom_edge = zeros(1, width);
bottom_edge_filt = zeros(1, width);

for n=1:width
    updated = 0;
    for m=height:-1:4
        if(norm_image(m, n) == 0)
            if(updated == 0)
                bottom_edge(1,n) = height - m;
                updated = 1;
            end
            if(sum(norm_image(m-3:m,n)) < 3)
                bottom_edge_filt(1,n) = height - m;                
                break; 
            end
        end
    end
end


for n=1:width
    if(bottom_edge(n) + 5 <= bottom_edge_filt(n))
        bottom_edge_filt(n) = bottom_edge(n);
    end
end

#plot(bottom_edge_filt)
#figure
#plot(bottom_edge)
#hold on
#plot(bottom_edge_filt, 'r')

bottom_edge = bottom_edge_filt;

#shrinked_edge = bottom_edge;
#m = 2;
#count = 0;
#for n = 2 : width
#    if bottom_edge(n - 1) == bottom_edge(n)
#        count = count + 1;
#        if(count == 3)
#            count = 0;
#            continue # skip assignment
#        end
#    else
#        count = 0;
#    end
#    m = m + 1;
#    shrinked_edge(m) = bottom_edge(n);
#end
##disp('shrinking signal from')
##width
##disp('to')
##m
#bottom_edge = shrinked_edge;

end