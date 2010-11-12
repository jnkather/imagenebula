function [imagelist] = hsimagelist()
%HSIMAGELIST returns a structure containing a list of all images in the dataset
% directory.
%
% [IMAGELIST} = HSIMAGELIST()
%
% This function returns a structure containing a list of all images in the
% dataset directory.
%
% OUTPUT
%  IMAGELIST	- A structure containing a list of all images in the dataset
%  directory.
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

%% List benign and malignant image files 
datapath = hsdatapath();
tmplist = dir(strcat(datapath, '/*_ccd.tif'));

%% Get from cached file if exists
cachefile = strcat(datapath, '/imagelist.mat');
if exist(cachefile, 'file') == 2
	f = load(cachefile);
	imagelist = f.imagelist;
	return;
end

%% Construct image list
imagelist = struct;

for i = 1 : numel(tmplist)
	fnlength = length(tmplist(i).name);
	tmpfile = tmplist(i);
	if fnlength <= 30
		% benign
		imagelist(i, 1).id = i;
		imagelist(i, 1).name = tmpfile.name(1:21);
		imagelist(i, 1).fullpath = strcat(datapath, '/', imagelist(i, 1).name);
		imagelist(i, 1).sample = tmpfile.name(1:6);
		imagelist(i, 1).date = tmpfile.name(8:13);
		imagelist(i, 1).type = tmpfile.name(15:20);
		imagelist(i, 1).sid = tmpfile.name(21:21);
	else
		% malignant
		imagelist(i, 1).id = i;
		imagelist(i, 1).name = tmpfile.name(1:24);
		imagelist(i, 1).fullpath = strcat(datapath, '/', imagelist(i, 1).name);
		imagelist(i, 1).sample = tmpfile.name(1:6);
		imagelist(i, 1).date = tmpfile.name(8:13);
		imagelist(i, 1).type = tmpfile.name(15:23);
		imagelist(i, 1).sid = tmpfile.name(24:24);
	end % if fnlength <= 30
end % for i

save(cachefile, 'imagelist');
