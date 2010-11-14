function [fim, f] = oearcfilterimage(imid)
%OEARCFILTERIMAGE filter the image using the arc OE kernel.
%
%[FIM] = OEARCFILTERIMAGE(IMID)
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
imtype = 'h';
imregion = 'region';
sigma = [6, 1.5];
s = (0.15 : -0.005 : 0);
support = 5;
ntheta = 24;
derivative = 2;
hilbert = 1;

%% Read image
im = hsreadimage(imid, imtype, imregion);

%% Construct filter kernels
kernels = makekernels(sigma, s, support, ntheta, derivative, hilbert);

%% Cache directory
mfile = mfilename('fullpath');
cachepath = fileparts(mfile);
cachepath = [cachepath, '\cache\'];
if exist(cachepath, 'dir') ~= 7
	mkdir(cachepath);
end

%% Filter image
nr = numel(s);
fim = cell(ntheta, nr);
for itheta = 1 : ntheta
	for ir = 1 : nr
		fprintf('Filter image theta:%02d/%02d radius:%02d/%02d ... ', ...
			itheta, ntheta, ir, nr);
		
		% Cache filename
		cachefile = sprintf('FIM%d%s%s-%.1f-%.1f-%.3f-%.1f-%3f-%d-%d.mat', ...
			imid, upper(imtype), upper(imregion), ...
			kernels.xsigma, kernels.ysigma, kernels.r(ir), ...
			kernels.support, kernels.theta(itheta), ...
			kernels.derivative, kernels.hilbert);
		cachefile = strcat(cachepath, cachefile);
		
		if exist(cachepath, 'file') == 2
			f = load(cachefile);
			fim{itheta, ir} = f.filteredimage;
			fprintf('Cache retrieved!\n');
		else
			filteredimage = filterapply(im, -kernels.f{itheta, ir});
			save(cachefile, 'filteredimage');
			fim{itheta, ir} = filteredimage;
			fprintf('Done!\n');
		end
	end
end

%% Find maximum and minimum
% max and min 
[maxfim, imaxfim] = cellmax(fim);
[imaxtheta, imaxr] = ind2sub(size(fim), imaxfim);
immaxtheta = f.theta(imaxtheta);
immaxr = f.r(imaxr);

[minfim, iminfim] = cellmin(fim);
[imintheta, iminr] = ind2sub(size(fim), iminfim);
immintheta = f.theta(imintheta);
imminr = f.r(iminr);

