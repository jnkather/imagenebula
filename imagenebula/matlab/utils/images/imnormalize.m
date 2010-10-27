function I = imnormalize(I, flag)
%IMNORMALIZE Various ways to normalize a (multi-channel and multi-dimensional) 
% image.
% I = IMNORMALIZE(X, FLAG)
%
% This function performs the normalization procedure on the input image I. 
% I may have arbitrary dimension (ie an image or video, etc).  I is treated
% as a vector of pixel values.  Hence, the mean of X is the average pixel
% value, and likewise the standard deviation is the std of the pixels from
% the mean pixel.
%
% INPUTS
%  I		- n dimensional array to normalize
%  FLAG		- Determines normalization method. default is 'range'
%			'range':		range in [0,1]
%			'mean':			zero mean
%			'meanvariance':	zero mean and unit variance
%
% OUTPUTS
%  I       - The image after normalization.
%
% EXAMPLE
%  I = double(imread('cameraman.tif'));
%  N = imNormalize(I,1);
%  [mean(I(:)), std(I(:)), mean(N(:)), std(N(:))]
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING, USING OR
% MODIFYING.
%
% By downloading, copying, installing, using or modifying this
% software you agree to this license.  If you do not agree to this
% license, do not download, install, copy, use or modifying this
% software.
% 
% Copyright (C) 2010-2010 Baochuan Pang <babypbc@gmail.com>
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
% General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public License
% along with this program.  If not, see
% <http://www.gnu.org/licenses/>.
%
% This file is adapted from the code in Piotr's Image&Video Toolbox.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&&&&&&&&&&

%% Input Preparation
% if the input image is of class uint8, convert it to the class of double
if (isa(I, 'uint8')), I = double(I); end

% default normalization method
if (nargin < 2 || isempty(flag)); flag = 'range'; end

% determine the size of the input image
sizeI = size(I);

% Dimension of the input image should not exceed 3
nDims = ndims(I);
if (nDims > 3)
	error('imnormalize:InputImageDimensionError',...
		'The dimension of the input image (current is %d) should not exceed 3.',...
		nDims);
end

%% Perform the normalization
% for multi-channel image, perform the normalization on each channel
% respectively 
if nDims == 3
	nChannels = sizeI(3);
	for iChannels = 1 : nChannels
		I(:, :, iChannels) = imnormalize(I(:, :, iChannels), flag);
	end
end

% for 1-D or 2-D input, normalize directly
switch flag
	case 'range'
		% set X to range in [0,1]
		minI = min(I(:));
		maxI = max(I(:));
		I = (I - minI) / (maxI - minI);
	case 'mean'
		meanI = mean(I(:));
		I = I - meanI;
	case 'meanvariance'
		meanI = mean(I(:));
		stdI = std(I(:), 2);
		I = (I - meanI) / stdI;
	otherwise
		error('imnormalize:InputImageDimensionError',...
			'The FLAG should not be %s', flag);
end
