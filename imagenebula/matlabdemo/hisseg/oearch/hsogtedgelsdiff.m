function [thetadiff, rdiff, ithetadiff, irdiff] = hsogtedgelsdiff(...
	edgecoords, cellids, thetas, rs, masks, kernels)
%HSOGTEDGELSDIFF calculate the difference of thetas and radius between intensity
% image filter response and cell mask filter response.
%
% [THETADIFF, RDIFF, ITHETADIFF, IRDIFF] = HSOGTEDGELSDIFF(...
%	EDGECOORDS, CELLIDS, THETAS, RS, MASKS, KERNELS)
%
% INPUT
%	EDGECOORDS	- Coordinates of the edgels. This can be a column vector, each 
%		row of which represents a edgel index into the image; or a n-by-2
%		matrix, each row of which reprensents edgel coordinates into the image.
%
%	CELLIDS		- The column vector of ids of cells which the edgels belong to.
%
%	THETAS		- The column vector of orientations of edgels, calculated from
%		the intensity image.
%
%	RS			- The column vector of radius of edgels, calculated from the
%		intensity image.
%	
%	MASKS		- Cell of masks, each element of which is a mask for a single
%		cell.
%
%	KERNELS		- Struct containing information about the filter kernel.
%
%
% OUTPUT
%	THETADIFF	- The column vector of differences between the theta of the
%		intensity filter response and the mask filter response.
%
%	RDIFF		- The column vector of differences between the radius of the 
%		intensity filter response and the mask filter response.
%
%	ITHETADIFF	- The column vector of indices differences between the thetas of
%		the intensity filter response and the mask filter response.
%
%	IRDIFF		- The volumn vector of indices differences between the radius of
%		the intensity filter response and the mask filter response.
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
ithetadiff = uint16(zeros(nedgels, 1));
irdiff = uint16(zeros(nedgels, 1));
fprintf('Check Diff %d: ', nmasks);
for imask = 1 : nmasks
	fprintf('%d ', imask);
	mmask = (cellids == imask);
	mthetas = thetas(mmask);
	mrs = rs(mmask);
	mcoords = edgecoords(mmask);
	[mthetadiff, mrdiff, mithetadiff, mirdiff] = edgeldiff(...
		mcoords, masks{imask}, mthetas, mrs, kernels);
	thetadiff(mmask) = mthetadiff;
	rdiff(mmask) = mrdiff;
	ithetadiff(mmask) = mithetadiff;
	irdiff(mmask) = mirdiff;
end
fprintf('Done\n');



%%******************************************************************************
function [thetadiff, rdiff, ithetadiff, irdiff] = edgeldiff(...
	coords, mask, thetas, rs, kernels)
%Calculate the theta and radius difference for a single cell.
	% Convert to pseudo-intensity image
	im = mask2intensity(mask);

	% Check each edgels
	v = filterapplysp(-im, kernels.f, coords);
	
	% Find maximum response of mask filter response
	[~, imaxv] = cellmax(v, 'mat');
	[imaxtheta, imaxr] = ind2sub(size(v), imaxv);
	maxthetas = kernels.theta(imaxtheta);
	maxrs = kernels.r(imaxr); 

	% Maximum response of intensity filter response
	calithetadiff = false;
	if isa(thetas, 'integer')
		calithetadiff = true;
		ithetas = thetas;
		thetas = kernels.theta(ithetas);
	end
	
	calirdiff = false;
	if isa(rs, 'integer')
		calirdiff = true;
		irs = rs;
		rs = kernels.r(irs);
	end
	
	% Differences of theta
	thetadiff = abs(maxthetas(:) - thetas(:));
	thetadiff = min(thetadiff, abs(2*pi-thetadiff));
	ithetadiff = uint16(zeros(numel(thetas), 1));
	if calithetadiff
		ithetadiff = abs(int16(imaxtheta(:)) - int16(ithetas));
		ithetadiff = min(ithetadiff, abs(kernels.ntheta - ithetadiff));
	end
	
	% Differences of r
	rdiff = abs(maxrs(:) - rs(:));
	irdiff = uint16(zeros(numel(thetas), 1));
	if calirdiff
		irdiff = abs(int16(imaxr) - int16(irs));
	end
	


%%******************************************************************************
function [im] = mask2intensity(mask)
%Return pseudo-intensity corresponds to the given mask, where values of internal
% cell pixels are 0.5, background 1 and cell edge 0.
	im = ones(size(mask));
	im(mask) = 0.5;
	edgemask = bwperim(mask, 8);
	im(edgemask) = 0;
	