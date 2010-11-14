function [fresult] = oearcfilterimage(imid, imtype, imregion, sigma, ...
	s, support, ntheta, derivative, hilbert)
%OEARCFILTERIMAGE filter the image using the arc OE kernel.
%
%[FIM] = OEARCFILTERIMAGE(IMID, IMTYPE, IMREGION)
%
% INPUT
%	[IMID]		- Image ID
%
%	[IMTYPE]	- Image type, 'ccd', 'h', 'e', 'r', 'g', 'b', etc.
%
%	[IMREGION]	- Image region, 'full', 'region' or padding
%
%	[SIGMA]		- Scale parameters of filter
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
% OUTPUT
%	FRESULT		- A structure of filtered images and filter kernels
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
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&&&&&&&&&&

%% Default argument 
if nargin < 1, imid = 1; end;
if nargin < 2, imtype = 'h'; end;
if nargin < 3, imregion = 'region'; end;
if nargin < 4, sigma = [6, 1.5]; end;
if nargin < 5, s = (0.15 : -0.005 : 0); end;
if nargin < 6, support = 5; end;
if nargin < 7, ntheta = 24; end;
if nargin < 8, derivative = 2; end;
if nargin < 9, hilbert = 1; end;

%% Cache directory
mfile = mfilename('fullpath');
cachepath = fileparts(mfile);
cachepath = [cachepath, '\cache\'];
if exist(cachepath, 'dir') ~= 7
	mkdir(cachepath);
end

%% Cache File
cachefile = sprintf('FIM%d%s%s-%.1f-%.1f-%.3f-%.3f-%d-%.1f-%d-%d-%d.mat', ...
	imid, upper(imtype), upper(imregion), ...
	sigma(1), sigma(2), max(s), min(s), numel(s), ...
	support, ntheta, derivative, hilbert);
cachefile = strcat(cachepath, cachefile);

if exist(cachefile, 'file') == 2
	fprintf('Found cached file, retrieving ... ');
	f = load(cachefile);
	fresult = f.fresult;
	fprintf('Cache retrieved!\n');
	return;
end

%% Read image
im = hsreadimage(imid, imtype, imregion);

%% Construct filter kernels
kernels = filterbankoearccache(sigma, s, support, ntheta, derivative, hilbert);

%% Filter image
nr = numel(s);
fim = cell(ntheta, nr);
for itheta = 1 : ntheta
	for ir = 1 : nr
		fprintf('Filter image theta:%02d/%02d radius:%02d/%02d ... ', ...
			itheta, ntheta, ir, nr);
		
		filteredimage = filterapply(im, -kernels.f{itheta, ir});
		fim{itheta, ir} = filteredimage;
		fprintf('Done!\n');
	end
end

% Result structure
fresult = struct;
fresult.fim = fim;

%% Find maximum and minimum
% max and min 
[fresult.maxfim, imaxfim] = cellmax(fim, 'row');
[fresult.imaxtheta, fresult.imaxr] = ind2sub(size(fim), imaxfim);
fresult.immaxtheta = kernels.theta(fresult.imaxtheta);
fresult.immaxr = kernels.r(fresult.imaxr);

[fresult.minfim, iminfim] = cellmin(fim, 'row');
[fresult.imintheta, fresult.iminr] = ind2sub(size(fim), iminfim);
fresult.immintheta = kernels.theta(fresult.imintheta);
fresult.imminr = kernels.r(fresult.iminr);

% kernels used to filter the image
fresult.kernels = kernels;

%% Cache the result 
save(cachefile, 'fresult');
