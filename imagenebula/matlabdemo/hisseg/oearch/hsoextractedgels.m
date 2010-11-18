function [coords, strengths, rs, thetas, relcencart, relcenpol] = ...
	hsoextractedgels(edgemap, imstrength, imr, imtheta, centroids)
%HSOEXTRACTEDGELs extracts edgels (edge element) from the given map.
%
%[COORDS, STRENGTH, RS, THETAS, RELCENCART, RELCENPOL] = HSOEXTRACTEDGELS(
%	EDGEMAP, IMSTRENGTH, IMR, IMTHETA, CENTROIDS)
%
% INPUT
%	EDGEMAP		- Edge map or maps from which we want to extract the edgel.
%		EDGEMAP can be a single BW image, where 1 indicates a edge pixel.
%		EDGEMAP can also be a cell of multiple BW images, each of which is a
%		edge map for a single object.
%
%	[IMSTRENGTH]- Edge strength image, the value of each pixel represents the
%		edge strength or edge probability.
%
%	[IMR]		- Radius image, the value of each pixel represents the radius of
%		the maximal response filter.
%
%	[IMTHETA]	- Theta image, the value of each pixel reprensets the
%		orientation of the maximal response filter.
%
%	[CENTROIDS]	- Centroid coordinate, or coordinates. Each row represents a
%		centroid, and the two columns represent R and C of the centroids
%		respectively.
%		The row number (number of centroids) should be equal to the number of
%		edge maps.
%	
% OUTPUT
%	COORDS		- Cartesian coordinates of the edgels. Each row represents a
%		edgel.
%
%	STRENGTHS	- Column vector represents strengths of each edgel.
%
%	RS			- Column vector represents radius of each edgel.
%
%	THETAS		- Column vector represents orientation of each edgel.
%
%	RELCENCART	- Cartesian coordinates of each corresponding centroids 
%		relatively to the edgels. Each row represents a edgel.
%
%	RELCENPOL	- Polar coordiantes of each correspondings centroids relatively
%		to the edgels. Each row represents a edgel.
%
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

%% Argument processing
if nargin <= 0
	error('hsoextractedgels:InputArgumentError', ...
		'Input argument EDGEMAP must be specified!');
end

% To get output STRENGTHS, input IMSTRENGTH must be specified
if nargout >= 2 && nargin < 2
	error('hsoextractedgels:InputArgumentError', ...
		'Input argument IMSTRENGTH must be specified to get output STRENGTHS!');
end

% To get output RS, input IMR must be specified
if nargout >= 3 && nargin < 3
	error('hsoextractedgels:InputArgumentError', ...
		'Input argument IMR must be specified to get output RS!');
end

% To get output THETAS, input IMR must be specified
if nargout >= 4 && nargin < 4
	error('hsoextractedgels:InputArgumentError', ...
		'Input argument IMTHETA must be specified to get output THETAS!');
end

% To get output RELCENCART and RELCENRHO, input CENTROIDS must be specified
if nargout >= 5 && nargin < 5
	error('hsoextractedgels:InputArgumentError', ...
		'Input argument CENTROIDS must be specified to get output RELCENCART and RELCENRHO!');
end

% Number of centroids should be equal to the number edge maps
if nargin >= 5
	if ~iscell(edgemap) && size(centroids, 1) > 1
		error('hsoextractedgels:CentroidsNumberError', ...
			'Centroids number does not equal to the number of edges!');
	end
	
	if iscell(edgemap) && size(centroids, 1) ~= numel(edgemap)
		error('hsoextractedgels:CentroidsNumberError', ...
			'Centroids number does not equal to the number of edges!');		
	end
end

%% Extract all edgel coordinates
if iscell(edgemap)
	% a cell of edge maps
	rows = []; cols = []; inds = [];
	cencoords = [];
	for i = 1 : numel(edgemap)
		[row, col] = find(edgemap{i} > 0);
		n = numel(row);
		cencoords = [cencoords; ones(n, 1) * centroids(i, :)]; %#ok<AGROW>
		rows = [rows; row]; %#ok<AGROW>
		cols = [cols; col]; %#ok<AGROW>
		inds = [inds; sub2ind(size(edgemap{i}), row, col)]; %#ok<AGROW>
	end
	coords = [rows, cols];
else
	% a single edge map
	[rows, cols] = find(edgemap > 0);
	n = numel(rows);
	cencoords = ones(n, 1) * centroids;
	inds = sub2ind(size(edgemap), rows, cols);
	coords = [rows, cols];
end

%% Extract strength, radius and thetas
if nargout >= 2, strengths = imstrength(inds); end;
if nargout >= 3, rs = imr(inds); end;
if nargout >= 4, thetas = imtheta(inds); end;

%% Centroid relative to the edgel
relceny = coords(:, 1) - cencoords(:, 1);
relcenx = cencoords(:, 2) - coords(:, 2);
[relcentheta, relcenrho] = cart2pol(relcenx, relceny);
relcentheta = relcentheta - thetas;
%relcentheta(relcentheta > pi) = relcentheta(relcentheta > pi) - 2*pi;
[relcenx, relceny] = pol2cart(relcentheta, relcenrho);
[relcentheta, relcenrho] = cart2pol(relcenx, relceny);

relcencart = [relcenx, relceny];
relcenpol = [relcentheta, relcenrho];
