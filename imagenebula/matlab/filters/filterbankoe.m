function [fb, thetas, scales] = filterbankoe(norients, startsigma, nscales, ...
	scalingstep, elong, thetarange)
% FILTERBANKOE: Create a filterbank containing NORIENTS even and odd-symmetric oriented energy
% filters. 
% [FB, THETAS, SCALES] = FILTERBANKOE(NORIENTS, STARTSIGMA, NSCALES, SCALINGSTEP,
%	ELONG, THETARANGE)
%
% Create a filterbank kernels containing even and odd-symmetric oriented energy
% filters, with NORENTS orientations, NSCALES scalings.
%
% The even-symmetric filter is a Gaussian second derivative.
% The odd-symmetric filter is its Hilbert transform.
%
% INPUTS
%	NORIENTS		- Number of orientations
%	STARTSIGMA		- Smallest scale of the filter.
%	Notes: The SIGMA is the scale in Y direction, while the (SIGMA*ELONG) is the
%		scale in X direction. STARTSIGMA is the smallest SIGMA, the rest of 
%		which are determined by the SCALINGSTEP parameter.
%	[NSCALES]		- Number of scales. Default is 1.
%	[SCALINGSTEP]	- Additive or multiplicative step of scales. In additive
%		case, the second scale is the first scale adding the scaling step (that 
%		is, (STARTSIGMA+SCALINGSTEP)). In multiplicative case, the second scale 
%		is the first scale multiplying the scaling step (that is 
%		(STARTSIGMA*SCALINGSTEP)). Multiplicative is the default scaling step 
%		settings. Default is SQRT(2).
%	ELONG			- Elongation factor of the filter. The scale in X direction
%		is (ELONG*SIGMA), while scale in Y direction is SIGMA. Default is 3.
%	THETARANGE		- Range of the orientations. Default is [0, pi], which means
%		orientations is obtained by splitting [0, pi] into NORIENTS parts.
%
% OUTPUTS
%	FB				- Filter bank containing filter kernels. FB is a 
%		3-dimensional cell of size (2 * NSCALES * NORIENTS), each elements is a
%		oriented energy kernel with the corresponding O/E setting, scale and 
%		orientation.
%	THETAS			- Filter orientatios. Vector of size NORIENTS, each element
%		of which is the orientation of the X axis of the filter.
%	SCALES			- Filter scales. (NORIENTS * 2) matrix, each row of which is
%		scale of the filter in X and Y directions.
%
% See also FILTEROE
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

%% Argument processing and default options
if nargin < 3, nscales = 1; end			% Default is only 1 scales
if nargin < 4, scalingstep = sqrt(2); end	% Default is a multiplicative SQRT(2)
% The scale in X direction is 3 times the scale in Y direction by default
if nargin < 5, elong = 3; end
% Theta range
if nargin < 6, thetarange = [0, pi]; end
% The size of the filter is 3 times the maximum of scales in X and Y directions
support = 3;

%% Calculate the filterbank kernels
fb = cell(2, nscales,  norients);
thetas = zeros(norients, 1);
scales = zeros(nscales, 2);
for iscale = 1 : nscales,
	% for each scale, calculate the scale SIGMA
	sigma = startsigma * scalingstep ^ (iscale - 1);
	% for each orientation, calculate the kernels of the odd/even filters
	for iorient = 1 : norients,
		% the angle of the X direction
		theta = (iorient - 1) / norients * abs(thetarange(2) - thetarange(1)) ...
			+ thetarange(1);
		thetas(iorient) = theta;
		
		% scales in X and Y directions
		scale = sigma * [elong 1];
		scales(iscale, :) = scale;
		
		% filter bank kernels
		fb{1, iscale, iorient} = oeFilter(scale, support, theta, 2, 0);	% even
		fb{2, iscale, iorient} = oeFilter(scale, support, theta, 2, 1);	% odd
	end
end
