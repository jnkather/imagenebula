function [cr, cc] = bwcentroid(bw)
%BWCENTROID returns the centroid coordinate of the region(s) specified by BW.
%
% [CR, CC] = BWCENTROID(BW)
%
% This function calculate the centroid coordinate of the region(s) specified by 
% BW. The region is specified by BW>1.
%
% INPUTS
%  BW		- Region mask or masks(cell of images), region is specified by BW>1.
%
% OUTPUTS
%	CR      - Centroid row index
%	CC		- Centroid column index
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

if iscell(bw)
	% cell of masks
	cr = zeros(numel(bw), 1);
	cc = zeros(numel(bw), 1);
	
	for i = 1 : numel(bw)
		[rs, cs] = find(bw{i} > 0);
		cr(i) = mean(rs);
		cc(i) = mean(cs);
	end
else
	% single mask
	[rs, cs] = find(bw > 0);
	
	cr = mean(rs);
	cc = mean(cs);	
end

% If only one output is required, return centroids coordinates as row vectors of
% a maxtrix, where the first column indicates the row coordinates and the second
% column represents the column coordinates
if nargout == 1
	cr = [cr, cc];
end
