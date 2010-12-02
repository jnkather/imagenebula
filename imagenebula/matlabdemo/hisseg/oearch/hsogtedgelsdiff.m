function [thetadiff, rdiff, ithetadiff, irdiff] = hsogtedgelsdiff(...
	edgecoords, cellids, thetas, rs, masks, kernels)
%HSOGTEDGELSDIFF calculate the difference of thetas and radius between intensity
% image filter response and cell mask filter response.
%
% [THETADIFF, RDIFF] = HSOGTEDGELSDIFF(EDGECOORDS, CELLIDS, THETAS, RS, MASKS, KERNELS)
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING, USING OR
% MODIFYING.
%
% By downloading, copying, installing, using or modifying this
% software you agree to this license.  If you do not agree to this
% license, do not download, install, copy, use or modify this
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

%% Check Argument
if size(edgecoords, 1) ~= numel(cellids)
	error('hsogtedgelsdiff:InputArgumentError', ...
		'EDGECOORDS and CELLIDS should have equal rows!');
end

if size(edgecoords, 1) ~= numel(thetas)
	error('hsogtedgelsdiff:InputArgumentError', ...
		'EDGECOORDS and THETAS should have equal rows!');	
end

if size(edgecoords, 1) ~= numel(rs)
	error('hsogtedgelsdiff:InputArgumentError', ...
		'EDGECOORDS and RS should have equal rows!');	
end

if max(cellids(:)) > numel(masks)
	error('hsogtedgelsdiff:InputArgumentError', ...
		'Element of CELLIDS should not exceed number of MASKS!');
end


%% Prepare parameters
nedgels = size(edgecoords, 1);
sizeim = size(masks{1});
% convert coords from sub to index
if size(edgecoords, 2) > 1
	edgecoords = sub2ind(sizeim, edgecoords(:, 1), edgecoords(:, 2));
end
nmasks = numel(masks);

%% Calculate the difference
thetadiff = zeros(nedgels, 1);
rdiff = zeros(nedgels, 1);
for imask = 1 : nmasks
	mmask = (cellids == imask);
	mthetas = thetas(mmask);
	mrs = rs(mmask);
	mcoords = edgecoords(mmask);
	[mthetadiff, mrdiff] = edgeldiff(...
		mcoords, masks{imask}, mthetas, mrs, kernels);
	thetadiff(mmask) = mthetadiff;
	rdiff(mmask) = mrdiff;
end



%%******************************************************************************
function [thetadiff, rdiff] = edgeldiff(coords, mask, thetas, rs, kernels)
%Calculate the theta and radius difference for a single cell.
	% Convert to pseudo-intensity image
	im = mask2intensity(mask);

	% Check each edgels
	v = filterapplysp(-im, kernels.f, coords);
	
	% Find maximum response
	[maxv, imaxv] = cellmax(v, 'mat');
	[imaxtheta, imaxr] = ind2sub(size(v), imaxv);
	maxthetas = kernels.theta(imaxtheta);
	maxrs = kernels.r(imaxr); 

	% Differences of theta
	thetadiff = abs(maxthetas(:) - thetas(:));
	thetadiff = min(thetadiff, abs(2*pi-thetadiff));
	
	% Differences of r
	nrs = kernels.r(rs(:));
	rdiff = abs(maxrs(:) - nrs(:));
	


%%******************************************************************************
function [im] = mask2intensity(mask)
%Return pseudo-intensity corresponds to the given mask, where values of internal
% cell pixels are 0.5, background 1 and cell edge 0.
	im = ones(size(mask));
	im(mask) = 0.5;
	edgemask = bwperim(mask, 8);
	im(edgemask) = 0;
	