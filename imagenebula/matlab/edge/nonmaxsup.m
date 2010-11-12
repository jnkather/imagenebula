function [edgeim] = nonmaxsup(im, orim, radius)
% NONMAXSUP - Non-maxima suppression
%
% Usage:
%          [im,location] = nonmaxsup(inimage, orient, radius);
%
% Function for performing non-maxima suppression on an image using an
% orientation image.  It is assumed that the orientation image gives 
% feature normal orientation angles in degrees (0-180).
%
% Input:
%   inimage - Image to be non-maxima suppressed.
% 
%   orient  - Image containing feature normal orientation angles in radians, 
%			angles positive anti-clockwise.
% 
%   radius  - Distance in pixel units to be looked at on each side of each
%             pixel when determining whether it is a local maxima or not.
%             This value cannot be less than 1.
%             (Suggested value about 1.2 - 1.5)
%
% Returns:
%   im        - Non maximally suppressed image.
%
% Notes:
%
% The suggested radius value is 1.2 - 1.5 for the following reason. If the
% radius parameter is set to 1 there is a chance that a maxima will not be
% identified on a broad peak where adjacent pixels have the same value.  To
% overcome this one typically uses a radius value of 1.2 to 1.5.  However
% under these conditions there will be cases where two adjacent pixels will
% both be marked as maxima.  Accordingly there is a final morphological
% thinning step to correct this.
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
% This file is adapted from the code provided by Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% http://www.csse.uwa.edu.au/
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&&&&&&&&&&

%% Input argument check
% check image size
if any(size(im) ~= size(orim))
	error('NonMaxSup:ImageSizeError', ...
		'image and orientation image are of different sizes');
end

% radius should be no less than 1
if radius < 1
	error('NonMaxSup:RadiusError', ...
		'radius must be >= 1');
end

% Check octave
% Octave = exist('OCTAVE_VERSION') ~= 0;  % Are we running under Octave?

%% Parameters
% Size of the image
[nr, nc] = size(im);

%% Interpolate
% Now run through the image interpolating grey values on each side
% of the centre pixel to be used for the non-maximal suppression.
xoff = radius .* cos(orim);
yoff = radius .* sin(orim);

[x, y] = meshgrid(1:nc, 1:nr);
x1 = x + xoff;
y1 = y - yoff;
x2 = x - xoff;
y2 = y + yoff;
im1 = interp2(x, y, im, x1, y1);
im2 = interp2(x, y, im, x2, y2);

%% Mon-maximum Suppression
mask = (im > im1) & (im > im2);

% Non-maximum suppressed edge image
edgeim = zeros(nr, nc);
edgeim(mask) = im(mask);

%% Thinning
% Finally thin the 'nonmaximally suppressed' image by pointwise
% multiplying itself with a morphological skeletonization of itself.
%
% I know it is oxymoronic to thin a nonmaximally supressed image but 
% fixes the multiple adjacent peaks that can arise from using a radius
% value > 1.
skel = bwmorph(edgeim, 'skel', Inf);
edgeim = edgeim .* skel;
