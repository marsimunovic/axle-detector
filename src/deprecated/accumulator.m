function [accum, acc_image_bin] = accumulator(input_image, radii)
[height, width] = size(input_image);
Xsingle = zeros(height, width);
Xsingle(input_image > 0) = 153;
imgf = single(Xsingle);

% Compute the gradient and the magnitude of gradient
[grdx, grdy] = gradient(imgf);
grdmag = sqrt(grdx.^2 + grdy.^2);

%Get the linear indices, as well as the subscripts, of the pixels
% whose gradient magnitudes are larger than the given threshold
#unique(grdmag)
grdmasklin = find(grdmag > 100);
[grdmask_IdxI, grdmask_IdxJ] = ind2sub(size(grdmag), grdmasklin);

%Compute the linear indices (as well as the subscripts) of
% all the votings to the accumulation array.
% The Matlab function 'accumarray' accepts only double variable,
% so all indices are forced into double at this point.
% A row in matrix 'lin2accum_aJ' contains the J indices (into the
% accumulation array) of all the votings that are introduced by a
% same pixel in the image. Similarly with matrix 'lin2accum_aI'.

prm_r_range = radii;
rr_4linaccum = double( prm_r_range );
linaccum_dr = [ (-rr_4linaccum(2) + 0.5) : -rr_4linaccum(1) , ...
    (rr_4linaccum(1) + 0.5) : rr_4linaccum(2) ];
#disp('Size of linaccum_dr and grdmasklin')
#size(linaccum_dr)
#size(grdmag)
#size(grdmask_IdxJ)
#size(grdmask_IdxI)
#size(repmat( double(grdmask_IdxJ)+0.5 , [1,length(linaccum_dr)]))


lin2accum_aJ = floor( ...
	double(grdx(grdmasklin)./grdmag(grdmasklin)) * linaccum_dr + ...
	repmat( double(grdmask_IdxJ)+0.5 , [1,length(linaccum_dr)] ) ...
);



lin2accum_aI = floor( ...
	double(grdy(grdmasklin)./grdmag(grdmasklin)) * linaccum_dr + ...
	repmat( double(grdmask_IdxI)+0.5 , [1,length(linaccum_dr)] ) ...
);

% Clip the votings that are out of the accumulation array
mask_valid_aJaI = ...
    lin2accum_aJ > 0 & lin2accum_aJ < (size(grdmag,2) + 1) & ...
    lin2accum_aI > 0 & lin2accum_aI < (size(grdmag,1) + 1);
#disp('Size of mask')
#size(mask_valid_aJaI)#

mask_valid_aJaI_reverse = ~ mask_valid_aJaI;
lin2accum_aJ = lin2accum_aJ .* mask_valid_aJaI + mask_valid_aJaI_reverse;
lin2accum_aI = lin2accum_aI .* mask_valid_aJaI + mask_valid_aJaI_reverse;
clear mask_valid_aJaI_reverse;

#disp('Size of lin2accum_a_')
#size(lin2accum_aI)
#size(lin2accum_aJ)

% Linear indices (of the votings) into the accumulation array
lin2accum = sub2ind( size(grdmag), lin2accum_aI, lin2accum_aJ );
#size(lin2accum)

lin2accum_size = size( lin2accum );
lin2accum = reshape( lin2accum, [numel(lin2accum),1] );
clear lin2accum_aI lin2accum_aJ;

% Weights of the votings, currently using the gradient maginitudes
% but in fact any scheme can be used (application dependent)
weight4accum = ...
    repmat( double(grdmag(grdmasklin)) , [lin2accum_size(2),1] ) .* ...
    mask_valid_aJaI(:);
clear mask_valid_aJaI;

% Build the accumulation array using Matlab function 'accumarray'
accum = accumarray( lin2accum , weight4accum );
accum = [ accum ; zeros( numel(grdmag) - numel(accum) , 1 ) ];
accum = reshape( accum, size(grdmag) );
acc_image_bin = accum;


#M = median(unique(acc_image_bin));
M = 2;
acc_image_bin(acc_image_bin < M) = 1;
acc_image_bin(acc_image_bin >=M) = 0;
end