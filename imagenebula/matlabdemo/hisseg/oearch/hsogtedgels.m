function [coords, strengths, rs, thetas, relcencart, relcenpol] = hsogtedgels( ...
	options)
%HSOGTEDGELs extracts edgels (edge element) from the ground truth images.
%
%[COORDS, STRENGTH, RS, THETAS, RELCENCART, RELCENPOL] = HSOGTEDGELS(
%	OPTIONS)
%	where OPTIONS is a struct whose fields are arguments
%
%[OUTPUTSTRUCT] = HSOGTEDGELS(OPTIONS)
%	when OPTIONS.outputstruct is set to true.
%
%
% INPUT
%	OPTIONS		- All following arguments are provided as the fields of OPTIONS.
%	Note: In order to output a struct, add field 'outputstruct' to the OPTIONS 
%	and set it to true.
%	Note: All following fields should be named in lower case.
%
%	[IMID]		- Image ID
%
%	[IMTYPE]	- Image type, 'ccd', 'h', 'e', 'r', 'g', 'b', etc.
%	Default is 'h'.
%
%	[IMREGION]	- Image region, 'full', 'region' or padding, default is (50,50).
%
%	[SIGMA]		- Scale parameters of filter. Default value is 5.
%
%	[S]			- 1/R, where R indicating radius of the filter. 
%	Default is (0.15 : -0.005 : 0).
%
%	[SUPPORT]	- The half size of the filter is determined by SUPPORT*SIGMA. In
%	fact, the half size of the filter is MAX(CEIL(SUPPORT * SIGMA)). 
%	Default is 5, which means the half size of the filter is about 5 times the 
%	maximum of the sigmas in X and Y directions.
%
%	[NTHETA]	- Number of orientations.
%	Default is 24.
%
%	[DERIVATIVE]- Degree of derivative in Y direction, one of {0, 1, 2}. 
%	Default is 0, which means that the filter in Y direction is the same as (or 
%	the hilbert transform of, determined by the value of DOHILBERT) the filter 
%	in X direction.
%
%	[HILBERT]	- Do Hilbert transform in y direction? 
%	Default is 0 (logical false), which means do not perform Hilbert 
%	transformation in Y direction.
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

%% Default arguments
if nargin <= 0, options = struct; end;

if isfield(options, 'outputstruct'), outputstruct = options.outputstruct; 
else outputstruct = false; end;

if isfield(options, 'imid'), imid = options.imid; 
else imid = 1; end;

if isfield(options, 'imtype'), imtype = options.imtype; 
else imtype = 'h'; end;

if isfield(options, 'imregion'), imregion = options.imregion;
else imregion = [50,50]; end;

if isfield(options, 'sigma'), sigma = options.sigma;
else sigma = [6, 1.5]; end;

if isfield(options, 's'), s = options.s;
else s = (0.15 : -0.005 : 0); end;

if isfield(options, 'support'), support = options.support;
else support = 5; end;

if isfield(options, 'ntheta'), ntheta = options.ntheta;
else ntheta = 24; end;

if isfield(options, 'derivative'), derivative = options.derivative;
else derivative = 2; end;

if isfield(options, 'hilbert'), hilbert = options.hilbert;
else hilbert = 1; end;

if outputstruct && nargout > 1
	error('hsogtedgels:OutputArgumentError',...
		'You should only specify one output if struct output is desired!');
end

%% Edge map extraction
% Prepare outputs
coords = [];
strengths = [];
rs = int32([]);
thetas = [];
relcencart = [];
relcenpol = [];
% Extract
for id = imid
	% Prepare input options
	options = struct;
	options.outputstruct = true;
	
	% Edge map
	options.edgemap = hsreadimage(id, 'edges', imregion);
	fresult = hsoreadfresult(id, imtype, imregion, sigma, s, support, ntheta, ...
		derivative, hilbert, false);
	
	% Masks
	masks = hsreadimage(id, 'masks', imregion);
	options.centroids = bwcentroid(masks);
	clear masks;
	
	% Strenght, radius and theta
	options.imstrength = fresult.maxfim;
	options.imr = int32(fresult.imaxr);
	options.imtheta = fresult.immaxtheta;
	r = fresult.kernels.r;
	clear fresult;
	
	% Extract Edgels
	edgels = hsoextractedgels(options);

	% Add to outputs
	coords = [coords; edgels.coords]; %#ok<AGROW>
	strengths = [strengths; edgels.strengths]; %#ok<AGROW>
	rs = [rs; edgels.rs]; %#ok<AGROW>
	thetas = [thetas; edgels.thetas]; %#ok<AGROW>
	relcencart = [relcencart; edgels.relcencart]; %#ok<AGROW>
	relcenpol = [relcenpol; edgels.relcenpol]; %#ok<AGROW>
end

%% Output struct if desired
if outputstruct
	output.coords = coords;
	output.strengths = strengths;
	output.rs = rs;
	output.thetas = thetas;
	output.relcencart = relcencart;
	output.relcenpol = relcenpol;
	output.r = r;
	coords = output;
end