function [edgels] = hsogroupedgels(edgels)
%HSOGROUPEDGELS group edgels according to its corresponding radius.
%
%[EDGELS] = HSOGROUPEDGELS(EDGELS)
%
% This function will group edgels according to its corresponding radius.
%
% INPUT
%	EDGELS		- Struct representing edgels, output of HSOGTEDGELS.
%
% OUTPUT
%	EDGELS		- Struct representing grouped edgels, all fields of input struct
%		are also contained in this output struct, as long as they are converted
%		to cell of vectors or matrices, each element vector or matrix of which
%		corresponds to a single value of R.
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

%% Number of Radius values
nr = numel(edgels.r);

%% Prepare the output
ri = cell(1, nr);
coords = cell(1, nr);
strengths = cell(1, nr);
rs = cell(1, nr);
thetas = cell(1, nr);
relcencart = cell(1, nr);
relcenpol = cell(1, nr);
imids = cell(1, nr);
cellids = cell(1, nr);
edgetypes = cell(1, nr);

%% Group
for ir = 1 : nr
	ri{ir} = find(edgels.rs == ir);
	coords{ir} = edgels.coords(ri{ir}, :);
	strengths{ir} = edgels.strengths(ri{ir}, :);
	rs{ir} = edgels.rs(ri{ir}, :);
	thetas{ir} = edgels.thetas(ri{ir}, :);
	relcencart{ir} = edgels.relcencart(ri{ir}, :);
	relcenpol{ir} = edgels.relcenpol(ri{ir}, :);
	imids{ir} = edgels.imids(ri{ir}, :);
	cellids{ir} = edgels.cellids(ri{ir}, :);
	edgetypes{ir} = edgels.edgetypes(ri{ir}, :);
end

%% Output 
edgels.coords = coords;
edgels.strengths = strengths;
edgels.rs = rs;
edgels.thetas = thetas;
edgels.relcencart = relcencart;
edgels.relcenpol = relcenpol;
edgels.imids = imids;
edgels.cellids = cellids;
edgels.edgetypes = edgetypes;
