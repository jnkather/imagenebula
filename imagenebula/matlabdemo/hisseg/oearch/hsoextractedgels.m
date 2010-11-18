function [coords, strengths, rs, thetas] = hsoextractedgels(edgemap, ...
	imstrength, imr, imtheta)
%HSOEXTRACTEDGELs extracts edgels (edge element) from the given map.
%
%[FIM] = HSOEXTRACTEDGELS(EDGEMAP)
%
% INPUT
%	EDGEMAP		- Edge map or maps (cell of edge map) to extract
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

%% Extract all edgel coordinates
if iscell(edgemap)
	% a cell of edge maps
	rows = []; cols = []; inds = [];
	for i = 1 : numel(edgemap)
		[row, col] = find(edgemap{i} > 0);
		rows = [rows; row];
		cols = [cols; col];
		inds = [inds; sub2ind(size(edgemap{i}), row, col)];
	end
	coords = [rows, cols];
else
	% a single edge map
	[rows, cols] = find(edgemap > 0);
	inds = sub2ind(size(edgemap), rows, cols);
	coords = [rows, cols];
end

%% Extract strength, radius and thetas
if nargout >= 2, strengths = imstrength(inds); end;
if nargout >= 3, rs = imr(inds); end;
if nargout >= 4, thetas = imtheta(inds); end;

