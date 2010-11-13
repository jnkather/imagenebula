function [f] = filteroearc(...
	sigma, r, support, theta, derivative, dohilbert, visual)
%FILTEROE compute the oriented energy filter kernel with the specified scale and
%angle
%[F] = FILTEROEARC(SIGMA, R, SUPPORT, THETA, DERIVATIVE, DOHILBERT, VISUAL)
%
% compute the oriented energy (OE) filter kernel with the specified scaling
% parameter SIGMA and rotation orientations (THETA).
% The filter is a Gaussian in the x direction, and a Gaussian derivative with 
% optional Hilbert transform in the y direction.
% 
% The filter is zero-meaned if deriv > 0.
%
% INPUTS
%	SIGMA		- The scale parameters in X and Y direction of the gaussian
%	filters. Scalar if SIGMA is the same in both directions, or 2-element vector
%	of [SIGMAX, SIGMAY].
%	R			- Radius of the filter
%	[SUPPORT]	- The half size of the filter is determined by SUPPORT*SIGMA. In
%	fact, the half size of the filter is MAX(CEIL(SUPPORT * SIGMA)). Default is 
%	3, which means the half size of the filter is about 3 times the maximum of 
%	the sigmas in X and Y directions.
%	[THETA]		- Orientation of x axis, in radians. Default is 0.
%	[DERIVATIVE]- Degree of derivative in Y direction, one of {0, 1, 2}. Default
%	is 0, which means that the filter in Y direction is the same as (or the
%	hilbert transform of, determined by the value of DOHILBERT) the filter in X
%	direction.
%	[DOHILBERT]	- Do Hilbert transform in y direction? Default is 0 (logical
%	false), which means do not perform Hilbert transformation in Y direction.
%	[VISUAL]	- Visualization for debugging? This is useful when debugging the
%	code or designing the filters. Default is 0 (logical false), which means do 
%	not show the figure of the filter kernel. 
%
% OUTPUTS
%	F	Square filter kernel.
%
% See also FILTERBANKOE
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
%       Feature Detection in Human Vision: A Phase Dependent Energy Model,
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

%% Arguments and option processing
error(nargchk(1, 7, nargin));

% default option
if nargin<2, r=0; end
if nargin<3, support=5; end
if nargin<4, theta=0; end
if nargin<5, derivative=0; end
if nargin<6, dohilbert=0; end
if nargin<7, visual=0; end

% scalar sigma indicating the equal scale in X and Y
if numel(sigma) == 1,
	sigma = [sigma sigma];
end

% degree of derivative in Y direction
if derivative<0 || derivative>2,
	error('filteroe:DerivativeError', ...
		'Derivative in Y direction must be in [0, 2]');
end

%% Make the filter kernel 
% Calculate half size of the filter, and make sure the size of the filter is
% odd.
halfsize = max(ceil(support * sigma));
filtersize = halfsize * 2 + 1;

% Sampling limits.
maxsamples = 2000;	% Max samples in each dimension. 1000
maxrate = 50;		% Max sampling rate. 10

% Calculate sampling rate and number of samples.
rate = min(maxrate, max(1, floor(maxsamples/filtersize)));
nsamples = filtersize * rate;

% The 2D samping grid.
%r = floor(filtersize/2) + 0.5 * (1 - 1/rate);
gap = filtersize / nsamples;
radius = gap * (nsamples-1) / 2;
dom = linspace(-radius, radius, nsamples);
[sx, sy] = meshgrid(dom, dom);

% Bin membership for 2D grid points.
% mx = round(sx) + halfsize + 1;
% my = round(sy) + halfsize + 1;
% membership = (mx) + (my - 1) * filtersize;

% Rotate the 2D sampling grid by theta.
rv = (sy + r) .* sin(sx ./ (sy + r + eps));
ru = (sy + r) .* cos(sx ./ (sy + r + eps)) - r;
if ~visual, clear sx sy; end;
su = ru * sin(pi-theta) + rv * cos(pi-theta);
sv = ru * cos(pi-theta) - rv * sin(pi-theta);
if ~visual, clear rv ru; end;

% Bin membership for 2D grid points.
mx = round(su) + halfsize + 1;
my = round(sv) + halfsize + 1;
if ~visual, clear sv su; end;
membership = (mx) + (my - 1) * filtersize;
mask = (mx >= 1) & (my >= 1) & (mx <= filtersize) & (my <= filtersize);
membership(mask) = (mx(mask)) + (my(mask) - 1) * filtersize;
if ~visual, clear mx my; end;

% Visualization for debugging
if visual,
	figure(1); clf; hold on;
	plot(sx, sy, '.');	% plot '.' as the original mesh grid
	%plot(mx, my, 'o');	% plot 'o' as the rounded mesh grid (membership)
	% original mesh grid and its association with the rounded mesh grid
  	% plot([sx(:) mx(:)]', [sy(:) my(:)]', 'k-');	
	plot(su, sv, 'x');	% plot 'x' as the rotated mesh grid
	% plot([su(:) mx(:)]', [sv(:) my(:)]', 'k-');	
	axis equal;
	[x, y] = ginput(1);
	disp([x, y]);
end

% The function is a Gaussian in the x direction...
fx = exp(- dom.^2 / (2 * sigma(1)^2));

% .. and a Gaussian derivative in the y direction...
fy = exp(- dom.^2 / (2 * sigma(2)^2));
switch derivative,
	case 1,
		% 1-order derivative
		fy = fy .* (-dom / (sigma(2)^2));
	case 2,
		% 2-order derivative
		fy = fy .* (dom.^2 / (sigma(2)^2) - 1);
end

% ...with an optional Hilbert transform.
% why take the imaginary part?
if dohilbert,
	fy = imag(hilbert(fy));
end

% Evaluate the function with NN interpolation.
[sx, sy] = meshgrid(dom, dom);
ix = floor(sx/gap + (halfsize+0.5)*rate + 1);
iy = floor(sy/gap + (halfsize+0.5)*rate + 1);
clear sx sy;
f = fx(ix) .* fy(iy);
clear ix iy;

% Accumulate the samples into each bin.
f = indexedsum(f, membership, filtersize*filtersize);
clear membership;
f = reshape(f, filtersize, filtersize);

% zero mean
if derivative>0,
  f = f - mean(f(:));
end

% unit L1-norm
sumf = sum(abs(f(:)));
if sumf > 0,
	f = f / sumf;
end

