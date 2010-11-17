function [kernels] = filterbankoearccache(sigma, s, support, ntheta, ...
	derivative, hilbert)
%MAKEKERNELS creates kernels for filtering the histopathological images.
%
%[KERNELS] = MAKEKERNELS(SIGMA, S, SUPPORT, NTHETA, DERIVATIVE, HILBERT)
%
% INPUT
%	[SIGMA]		- The scale parameters in X and Y direction of the gaussian
%	filters. Scalar if SIGMA is the same in both directions, or 2-element vector
%	of [SIGMAX, SIGMAY].
%
%	[S]			- 1/R, where R indicating radius of the filter
%
%	[SUPPORT]	- The half size of the filter is determined by SUPPORT*SIGMA. In
%	fact, the half size of the filter is MAX(CEIL(SUPPORT * SIGMA)). Default is 
%	5, which means the half size of the filter is about 5 times the maximum of 
%	the sigmas in X and Y directions.
%
%	[NTHETA]	- Number of orientations
%
%	[DERIVATIVE]- Degree of derivative in Y direction, one of {0, 1, 2}. Default
%	is 0, which means that the filter in Y direction is the same as (or the
%	hilbert transform of, determined by the value of DOHILBERT) the filter in X
%	direction.
%
%	[DOHILBERT]	- Do Hilbert transform in y direction? Default is 0 (logical
%	false), which means do not perform Hilbert transformation in Y direction.
%
% MAKEKERNELS creates filter kernels for filtering the histopathological images.
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&&&&&&&&&&

%% Defaut arguments
if nargin < 1, sigma = [6, 1.5]; end;
if numel(sigma) <= 1; sigma = [sigma*3, sigma]; end;
if nargin < 2, s = (0.15 : -0.005 : 0); end;
if nargin < 3, support = 5; end;
if nargin < 4, ntheta = 24; end;
if nargin < 5, derivative = 2; end;
if nargin < 6, hilbert = 1; end;

%% Construct a struct
kernels = struct;

%% Parameters
kernels.ntheta = ntheta;
kernels.theta = ((1:ntheta) - 1) * 2 * pi / ntheta;
kernels.xsigma = sigma(1);
kernels.ysigma = sigma(2);
kernels.r = 1 ./ s;
kernels.nr = numel(kernels.r);
kernels.support = support;
kernels.derivative = derivative;
kernels.hilbert = hilbert;
kernels.f = cell(kernels.ntheta, kernels.nr);

%% Cache
cachefile = sprintf('OEARCFB-%.1f-%.1f-%.3f-%.3f-%d-%.1f-%d-%d-%d.mat', ...
	kernels.xsigma, kernels.ysigma, min(s), max(s), numel(s), ...
	kernels.support, kernels.ntheta, ...
	kernels.derivative, kernels.hilbert);
mfile = mfilename('fullpath');
cachepath = fileparts(mfile);
cachepath = [cachepath, '/cache/'];
if exist(cachepath, 'dir') ~= 7
	mkdir(cachepath);
end
cachepath = [cachepath, cachefile];

%% Read if cache file exists
if exist(cachepath, 'file') == 2
	f = load(cachepath);
	kernels = f.kernels;
	return;
end

%% Construct Filter Kernels
for itheta = 1 : kernels.ntheta
	theta = kernels.theta(itheta);
	for ir = 1 : kernels.nr
		fprintf('Connstruct filter kernel theta:%02d/%02d radius:%02d/%02d ...', ...
			itheta, kernels.ntheta, ir, kernels.nr);
		r = kernels.r(ir);
		kernels.f{itheta, ir} = filteroearccache([kernels.xsigma, kernels.ysigma], ...
			r, kernels.support, theta, kernels.derivative, kernels.hilbert);
		fprintf('Done\n');
	end
end

save(cachepath, 'kernels');
