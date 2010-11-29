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
%	arguments can be provided as the fields of OPTIONS.
%	Note: 
%	1. Add field 'outputstruct' to the OPTIONS and set it to true to output
%	struct.
%	2. All field names of OPTIONS should be in lower case. Upper case are only
%	used for demonstration in documents. 
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
%		Note: this argument can only be specified as a field of OPTIONS.
%
%	[THETARANGE]	- 2-element vector, specifying the maximum and minimum theta 
%		value of valid edgels. There is no order restriction on the elements of
%		the vector, that is, the maximum will be the upper bound and the minimum
%		element will be the lower bound.
%		Note: this argument can only be specified as a field of OPTIONS.
%
%	[RHORANGE]		- 2-element vector, specifying the maximum and minimum rho
%		value of valid edgels. See notes on THETARANGE.
%
%	[XRANGE]		- 2-element vector, specifying the maximum and minimum x
%		value of valid edgels. See notes on THETARANGE.
%
%	[YRANGE]		- 2-element vector, specifying the maximum and minimum y
%		value of valid edgels. See notes on THETARANGE.
%
%	[ONLYSALIENT]	- Extract only salient edgels. Salient edgels are groundtruth 
%		edge points which passed the non-maximum suppression step.
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
%	CELLIDS		- ID vector of the cell which the edgels belong to.
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
	% Struct input
	
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
	
	if isfield(options, 'checkedgels'), checkedgels = options.checkedgels;
	else checkedgels = false; end;
	
	if isfield(options, 'thetarange'), thetarange = options.thetarange;
	else thetarange = []; end;
	
	if isfield(options, 'rhorange'), rhorange = options.rhorange;
	else rhorange = []; end;
	
	if isfield(options, 'xrange'), xrange = options.xrange;
	else xrange = []; end;
	
	if isfield(options, 'yrange'), yrange = options.yrange;
	else yrange = []; end;
	
	if isfield(options, 'onlysalient'), onlysalient = options.onlysalient;
	else onlysalient = true; end;
else
	% Arugment input
	inputstruct = false;
	if nargin < 2, imstrength = []; end;
	if nargin < 3, imr = []; end;
	if nargin < 4, imtheta = []; end;
	if nargin < 5, centroids = []; end;
	checkedgels = false;
	thetarange = [];
	rhorange = [];
	xrange = [];
	yrange = [];
	onlysalient = false;
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
% If input edgemap is not a cell of edgemaps, convert it to a cell of single
% edgemap
if ~iscell(edgemap), edgemap = {edgemap}; end;
% Prepare output containers
rows = uint16([]);		% Row index of the edgel
cols = uint16([]);		% Col index of the edgel
inds = uint32([]);		% Index of the edgel
cencoords = [];			% Centroid coordinates corresponding to the edgel
cellids = uint16([]);	% Index of the cell which the edgel belongs to 
% Extract edgels from edgemaps
for i = 1 : numel(edgemap)
	% Extract edgels from a single cell
	[row, col] = find(edgemap{i} > 0);
	n = numel(row);
	cencoord = ones(n, 1) * centroids(i, :);
	cencoords = [cencoords; cencoord]; %#ok<AGROW>
	rows = [rows; row]; %#ok<AGROW>
	cols = [cols; col]; %#ok<AGROW>
	inds = [inds; sub2ind(size(edgemap{i}), row, col)]; %#ok<AGROW>
	cellids = [cellids; ones(n, 1) * i]; %#ok<AGROW>
end
coords = [rows, cols];


%% Extract strength, radius and thetas
if ~isempty(imstrength), strengths = imstrength(inds); end;
if ~isempty(imr), rs = imr(inds); end;
if ~isempty(imtheta), thetas = imtheta(inds); end;


%% Calculate centroid coordinate relative to the edgel
relceny = double(coords(:, 1)) - cencoords(:, 1);
relcenx = cencoords(:, 2) - double(coords(:, 2));
[relcentheta, relcenrho] = cart2pol(relcenx, relceny);
relcentheta = relcentheta - thetas;
[relcenx, relceny] = pol2cart(relcentheta, relcenrho);
[relcentheta, relcenrho] = cart2pol(relcenx, relceny);

% Centroid coordinates relative to the edgels in Cartesian
relcencart = [relcenx, relceny];
% Centroid coordinates relative to the edgels in Polar
relcenpol = [relcentheta, relcenrho];


%% Check and remove edgels violating range rules
nedgels = size(coords, 1);

% Check and remove edgels vialating theta range rules
thetavi = false(nedgels, 1);
if ~isempty(thetarange)
	mintheta = min(thetarange(:));
	maxtheta = max(thetarange(:));
	thetavi = (relcentheta > maxtheta) | (relcentheta < mintheta);
	% Check and output
	if checkedgels && sum(thetavi) > 0
		for jj = 1 : numel(thetavi)
			j = thetavi(jj);
			fprintf('THETA Error: cellid=%03d, r=%03d, c=%03d, cr=%03d, cc=%03d, rho=%3.1f, theta=%1.3f, strength=%f\n', ...
				cellids(j), row(j), col(j), cencoord(j, 1), cencoord(j, 2), ...
				relcenrho(j), relcentheta(j), imstrength(row(j), col(j)));
		end
	end
end

% Check and remove edgels vialating rho range rules
rhovi = false(nedgels, 1);
if ~isempty(rhorange)
	minrho = min(rhorange(:));
	maxrho = max(rhorange(:));
	rhovi = (relcenrho > maxrho) | (relcenrho < minrho);
	% Check and output
	if checkedgels && sum(rhovi) > 0
		for jj = 1 : numel(rhovi)
			j = rhovi(jj);
			fprintf('RHO Error: cellid=%03d, r=%03d, c=%03d, cr=%03d, cc=%03d, rho=%3.1f, theta=%1.3f, strength=%f\n', ...
				cellids(j), row(j), col(j), cencoord(j, 1), cencoord(j, 2), ...
				relcenrho(j), relcentheta(j), imstrength(row(j), col(j)));
		end
	end
end

% Check and remove edgels vialating X range rules
xvi = false(nedgels, 1);
if ~isempty(xrange)
	minx = min(xrange(:));
	maxx = max(xrange(:));
	xvi = (relcenx > maxx) | (relcenx < minx);
	% Check and output
	if checkedgels && sum(xvi) > 0
		for jj = 1 : numel(xvi)
			j = xvi(jj);
			fprintf('RHO Error: cellid=%03d, r=%03d, c=%03d, cr=%03d, cc=%03d, rho=%3.1f, theta=%1.3f, strength=%f\n', ...
				cellids(j), row(j), col(j), cencoord(j, 1), cencoord(j, 2), ...
				relcenrho(j), relcentheta(j), imstrength(row(j), col(j)));
		end
	end
end

% Check and remove edgels vialating X range rules
yvi = false(nedgels, 1);
if ~isempty(yrange)
	miny = min(yrange(:));
	maxy = max(yrange(:));
	yvi = (relceny > maxy) | (relceny < miny);
	% Check and output
	if checkedgels && sum(yvi) > 0
		for jj = 1 : numel(yvi)
			j = yvi(jj);
			fprintf('RHO Error: cellid=%03d, r=%03d, c=%03d, cr=%03d, cc=%03d, rho=%3.1f, theta=%1.3f, strength=%f\n', ...
				cellids(j), row(j), col(j), cencoord(j, 1), cencoord(j, 2), ...
				relcenrho(j), relcentheta(j), imstrength(row(j), col(j)));
		end
	end
end

% Remove non-salient edgels
if onlysalient
	meanstrength = mean(imstrength(:));
	nmsstrength = nonmaxsup(imstrength, imtheta, 1.5);
	svi = (nmsstrength(inds) < meanstrength);
end

% Index of edgels violating range rules
vi = thetavi | rhovi | xvi | yvi | svi;

% Remove edgels violating range rules
coords(vi, :) = [];
strengths(vi, :) = [];
rs(vi, :) = [];
thetas(vi, :) = [];
relcencart(vi, :) = [];
relcenpol(vi, :) = [];
cellids(vi, :) = [];

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
		outputstruct.cellids = cellids;
		coords = outputstruct;
	else
		error('hsoextractedgels:OutputStructError', ...
		'If output struct is desired, input must be struct and output count should be equal to 1!');
	end
end