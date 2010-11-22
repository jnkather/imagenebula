function [coords, strengths, rs, thetas, relcencart, relcenpol] = ...
	hsoextractedgels(edgemap, imstrength, imr, imtheta, centroids)
%HSOEXTRACTEDGELs extracts edgels (edge element) from the given map.
%
%[COORDS, STRENGTH, RS, THETAS, RELCENCART, RELCENPOL] = HSOEXTRACTEDGELS(
%	EDGEMAP, IMSTRENGTH, IMR, IMTHETA, CENTROIDS)
%
%... = HSOEXTRACTEDGELS(OPTIONS)
%	where OPTIONS is a struct whose fields are arguments
%
%[OUTPUTSTRUCT] = HSOEXTRACTEDGELS(OPTIONS)
%	when OPTIONS.outputstruct is set to true.
%
%
% INPUT
%	OPTIONS		- If only one struct argument is specified, all following
%	arguments are provided as the fields of OPTIONS.
%	Note: Add field 'outputstruct' to the OPTIONS and set it to true to output
%	struct.
%
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
%	[OUTPUTSTRUCT]	- Output a struct if this parameter is set to true.
%
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
%	[OUTPUTSTRUCT]	- Struct whose fields are above outputs. Only output struct
%		when OPTIONS.outputstruct is set to true.
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
if (nargin == 1) && isstruct(edgemap)
	inputstruct = true;
	options = edgemap;
	
	% Input through arguments
	if isfield(options, 'edgemap'), edgemap = options.edgemap;
	else edgemap = []; end;
	if isfield(options, 'imstrength'), imstrength = options.imstrength;
	else imstrength = []; end;
	if isfield(options, 'imr'), imr = options.imr;
	else imr = []; end;
	if isfield(options, 'imtheta'), imtheta = options.imtheta;
	else imtheta = []; end;
	if isfield(options, 'centroids'), centroids = options.centroids;
	else centroids = []; end;
else
	inputstruct = false;
	if nargin < 2, imstrength = []; end;
	if nargin < 3, imr = []; end;
	if nargin < 4, imtheta = []; end;
	if nargin < 5, centroids = []; end;
end

%% Argument processing
if nargin <= 0
	error('hsoextractedgels:InputArgumentError', ...
		'Input argument EDGEMAP or OPTIONS must be specified!');
end

% To get output STRENGTHS, input IMSTRENGTH must be specified
if nargout >= 2 && isempty(imstrength)
	error('hsoextractedgels:InputArgumentError', ...
		'Input argument IMSTRENGTH must be specified to get output STRENGTHS!');
end

% To get output RS, input IMR must be specified
if nargout >= 3 && isempty(imr)
	error('hsoextractedgels:InputArgumentError', ...
		'Input argument IMR must be specified to get output RS!');
end

% To get output THETAS, input IMR must be specified
if nargout >= 4 && isempty(imtheta)
	error('hsoextractedgels:InputArgumentError', ...
		'Input argument IMTHETA must be specified to get output THETAS!');
end

% To get output RELCENCART and RELCENRHO, input CENTROIDS must be specified
if nargout >= 5 && isempty(centroids)
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
if ~isempty(imstrength), strengths = imstrength(inds); end;
if ~isempty(imr), rs = imr(inds); end;
if ~isempty(imtheta), thetas = imtheta(inds); end;

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

%% Output struct
if inputstruct && isfield(options, 'outputstruct') 
	if nargout == 1 && options.outputstruct
		outputstruct = struct;
		outputstruct.coords = coords;
		outputstruct.strengths = strengths;
		outputstruct.rs = rs;
		outputstruct.thetas = thetas;
		outputstruct.relcencart = relcencart;
		outputstruct.relcenpol = relcenpol;
		coords = outputstruct;
	else
		error('hsoextractedgels:OutputStructError', ...
		'If output struct is desired, input must be struct and output count should be equal to 1!');
	end
end