function [fim, f] = oearcfilterimage(...
	imid)
%OEARCFILTERIMAGE filter the image using the arc OE kernel.
%
%[F] = OEARCFILTERIMAGE(IMID)
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
	
%% Read image
im = hsreadimage(imid, 'h', 'region');

%% Construct filter kernels
f = makekernels();

%% Filter image
ntheta = f.ntheta;
nr = f.nr;
fim = cell(ntheta, nr);

for itheta = 1 : ntheta
	for ir = 1 : nr
		fprintf('Filter image theta:%02d/%02d radius:%02d/%02d ... ', ...
			itheta, ntheta, ir, nr);
		fim{itheta, ir} = filterapply(im, -f.f{itheta, ir});
		fprintf('Done\n');
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

