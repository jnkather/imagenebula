function [v] = filterapplysp(im, f, location, varargin)
% FILTERAPPLY apply the specified filter or filter bank to a single pixel.
% [V] = FILTERAPPLY(IM, F, LOCALTION, VARARGIN)
% 
% Apply the specified filter F to the given image IM.
%
%
% INPUTS
%	IM		- Image
%	F		- Filter kernel
%	LOCALTION - 2-element or 3-element vector, indicating the location of
%		image to apply the filter
%   VARARGIN- Options when applying the filter, the same as the options in
%       IMFILTER
%
% OUTPUTS
%	V		- Filtered value
%
% See also FILTERAPPLY, IMFILTER, FILTEROE, FILTERBANKOE
%

%
% References:
%   * Malik2001CTA@IJCV
%       Jitendra Malik, Serge Belongie, Thomas Leung and Jianbo Shi.
%       Contour and Texture Analysis for Image Segmentation,
%       International Journal of Computer Vision, vol, 43, no. 1, pp. 7-27,
%       2001.
%   * Malik1990PTD@JOSA
%       J. Malik, P. Perona.
%       Preattentive Texture Discrimination with Early Vision Mechanisms,
%       J. Optical Society of America, vol.7, no.2, pp.923-932, 1990.
%   * Perona1990DLE@ICCV
%       P. Perona, J. Malik
%       Detecting and Localizing Edges Composed of Steps, Peaks and Roofs.
%       in: Proc. 3rd Int. Conf. Computer Vision (ICCV), Osaka, Japan, pp.52-57,
%       1990.
%   * Knutsson1983TAT@CAPAIDM
%       H. Knutsson, G. Granlund
%       Texture Analysis using Two-dimensional Quadrature Filters.
%       In: Workshop on Computer Architecture for Pattern Analysis and Image
%       Database Management, pp. 206-213. 1983.
%   * Morrone1987FDL@PRL
%       M. Morrone, R. Owens
%       Feature Detection from Local Energy.
%       Pattern Recognition Letters vol. 6, pp. 303-313, 1987.
%   * Morrone1988
%       M. Morrone, D. Burr
%       Feature Dection in Human Vision: A Phase Dependent Energy Model,
%       In: Proc. R. Soc. Lond. B vol.235, pp.212-245.
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
% This file is adapted from the code provided by David R. Martin
% <dmartin@eecs.berkeley.edu>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&&&&&&&&&&

%% Parse options
[boundary, output, do_fcn] = parse_options(varargin);

%% Filtering the image
if (iscell(f))
    v = zeros(size(f));
    for i = 1 : numel(f)
        v(i) = filterapplysp(im, f{i}, location, boundary, output, do_fcn);
    end
else
    %fim = imfilter(im, f, boundary, output, do_fcn);
	
	sizef = size(f);
	sizeim = size(im);
	halfsizef = floor(sizef / 2);
	startimloc = location - halfsizef;
	startpatchloc = -min(startimloc, [1,1]) + 2;
	startimloc = max(startimloc, [1,1]);
	endimloc = location + halfsizef;
	endimloc = min(endimloc, sizeim);
	endpatchloc = startpatchloc + (endimloc - startimloc);
	impatch = zeros(sizef);
	impatch(startpatchloc(1):endpatchloc(1), startpatchloc(2):endpatchloc(2)) = ...
		im(startimloc(1):endimloc(1), startimloc(2):endimloc(2));
	fim = impatch .* f;
	v = sum(fim(:));
end


% End of Fucntion FILTERAPPLY


% ------------------------------------------------------------------------
function [boundary, output, do_fcn] = parse_options(varargin)
% default options
boundary = 0;  %Scalar value of zero
output = 'same';
do_fcn = 'corr';

% Parse options
if numel(varargin) > 0 && iscell(varargin{1}),
    varargin = varargin{1};
end

for k = 1:length(varargin),
    if ischar(varargin{k}),
        string = varargin{k};
        switch string
            case {'replicate', 'symmetric', 'circular'}
                boundary = string;
            case {'full','same'}
                output = string;
            case {'conv','corr'}
                do_fcn = string;
        end
    end
end