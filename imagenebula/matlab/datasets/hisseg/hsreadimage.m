function [im] = hsreadimage(imid, imtype, varargin)
%HSREADIMAGE reads the image specified by IMID and IMTYPE into memory.
%
% [IM] = HSREADIMAGE(IMID, IMTYPE, OPTIONS);
%
% INPUT
%	IMID	- ID of the image, integer value indicating the index of the image;
%		or string indicating the name of the image.
%	IMTYPE	- Type of the image, value should be:
%		'ccd'			image of the original CCD
%		'r' 'g' 'b'		for intensity in individual color channel
%		'ri' 'gi' 'bi'	for intensity in individual color channel
%		'rd' 'gd' 'bd'	for density of individual color channel
%		'mmask'			multiple-valued mask, each integer indicating a cell
%		'smask'			single-valued mask, 1 indicating the foreground, while 0
%			indicates the background
%		'masks'			a cell of mask images, each image of which is a mask for a
%			single cell
%		'edge' 'edge4'	an edge mask, 1 indicating the edge pixel, 0 otherwise
%		'edge8'			a mask of 8-connected edges
%		'edges'	'edges4'a cell of edge maps, each of which corresponds to a
%			single cell.
%		'edges8'		a cell of 8-connected edge maps, each of which 
%			corresponds to a single cell.
%		'exedge' 'exedge4'	an external edge mask, 1 indicating the edge pixel,
%			0 otherwise.
%		'exedge8'		an external 8 connected edge mask, 1 indicating the edge
%			pixel, 0 otherwise.
%		'exedges' ¡¯exedges4'	a cell of external edge maps, each of which 
%			corresponds to a single cell.
%		'exedges8'		a cell of external edge maps, each of which corresponds 
%			to a single cell.
%		'h' 'hi'		for intensity in H channel (hematoxylin)
%		'e'	'ei'		for intensity in E channel (eosin)
%		'hc' 'ec'		for color image in H or E channel
%		'hd'			for density in H channel 
%		'ed'			for density in E channel
%	OPTIONS	- Options, including:
%		'full'		default, full image
%		'region'	only the marked region
%		(ROWS, COLS) enlarged region of the marked region, where the ROWS and
%		COLS indicating the number of rows and columns that should be enlarged
%		in each side of the region.
%
% OUTPUT
%  IM		- Image or cell of images read from the data directory
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
if nargin < 2, imtype = 'ccd'; end;
if nargin < 3, varargin = {'full'}; end;

%% Load image list
imagelist = hsimagelist();

%% Find the file id
if ischar(imid)
	for i = 1 : numel(imagelist)
		if strcmpi(imid, imagelist(i).name)
			imid = i;
			break;
		end
	end
	
	if ~isnumeric(imid)
		error('HSREADIMAGE:FileNotFoundError', 'Find not found!');
	end
end

%% Check file id
if (imid < 1) || (imid > numel(imagelist))
	error('HSREADIMAGE:FileIdOutOfRangeError', 'File ID out of range!');
end

%% Load image
imagelist(imid).fullpath = fullfile(hsdatapath(), imagelist(imid).name);

if strcmpi(imtype, 'ccd')
	% original image
	filename = strcat(imagelist(imid).fullpath, '_ccd.tif');
	im = double(imread(filename)) / 255;

elseif strcmpi(imtype, 'r') || strcmpi(imtype, 'ri')
	% intensity in red channel
	filename = strcat(imagelist(imid).fullpath, '_ccd.tif');
	im = double(imread(filename)) / 255;
	im = im(:, :, 1);

elseif strcmpi(imtype, 'g') || strcmpi(imtype, 'gi')
	% intensity in green channel
	filename = strcat(imagelist(imid).fullpath, '_ccd.tif');
	im = double(imread(filename)) / 255;
	im = im(:, :, 2);

elseif strcmpi(imtype, 'b')	|| strcmpi(imtype, 'bi')
	% intensity in blue channel
	filename = strcat(imagelist(imid).fullpath, '_ccd.tif');
	im = double(imread(filename)) / 255;
	im = im(:, :, 3);
	
elseif strcmpi(imtype, 'rd')
	% density in red channel
	filename = strcat(imagelist(imid).fullpath, '_ccd.tif');
	im = double(imread(filename)) / 255;
	im = -log(im(:, :, 1));

elseif strcmpi(imtype, 'gd')
	% density in green channel
	filename = strcat(imagelist(imid).fullpath, '_ccd.tif');
	im = double(imread(filename)) / 255;
	im = -log(im(:, :, 2));

elseif strcmpi(imtype, 'bd')
	% density in blue channel
	filename = strcat(imagelist(imid).fullpath, '_ccd.tif');
	im = double(imread(filename)) / 255;
	im = -log(im(:, :, 3));
	
elseif strcmpi(imtype, 'h') || strcmpi(imtype, 'hi')
	% intensity in H (hematoxylin) Channel
	filename = strcat(imagelist(imid).fullpath, '_h.tif');
	im = double(imread(filename)) / 255;
	
elseif strcmpi(imtype, 'e') || strcmpi(imtype, 'ei')
	% intensity in E (eosin) Channel
	filename = strcat(imagelist(imid).fullpath, '_e.tif');
	im = double(imread(filename)) / 255;
	
elseif strcmpi(imtype, 'hd')
	% density in H (hematoxylin) Channel
	filename = strcat(imagelist(imid).fullpath, '_hd.tif');
	im = double(imread(filename)) / 255;

elseif strcmpi(imtype, 'ed')
	% density in H (hematoxylin) Channel
	filename = strcat(imagelist(imid).fullpath, '_ed.tif');
	im = double(imread(filename)) / 255;
	
elseif strcmpi(imtype, 'hc')
	% color image in H (hematoxylin) Channel
	filename = strcat(imagelist(imid).fullpath, '_hc.tif');
	im = double(imread(filename)) ./ 255;

elseif strcmpi(imtype, 'ec')
	% color image in E (hematoxylin) Channel
	filename = strcat(imagelist(imid).fullpath, '_ec.tif');
	im = double(imread(filename)) ./ 255;
	
elseif strcmpi(imtype, 'masks')
	% cell of masks, each image of which is a binary mask for a single cell
	filename = strcat(imagelist(imid).fullpath, '.mat');
	data = load(filename);
	nim = numel(data.tmp);
	im = cell(1, nim);
	for i = 1 : nim
		im{i} = data.tmp(i).BW;
	end
	
elseif strcmpi(imtype, 'mmask')
	% multiple-valued masks, each integer corresponds to a single cell, 0
	% indicating the background and the unmarked region
	filename = strcat(imagelist(imid).fullpath, '.mat');
	data = load(filename);
	nim = numel(data.tmp);
	im = uint16(zeros(size(data.tmp(1).BW)));
	for i = 1 : nim
		im(data.tmp(i).BW) = i;
	end
	
elseif strcmpi(imtype, 'smask')
	% multiple-valued masks, each integer corresponds to a single cell, 0
	% indicating the background and the unmarked region
	filename = strcat(imagelist(imid).fullpath, '.mat');
	data = load(filename);
	nim = numel(data.tmp);
	im = false(size(data.tmp(1).BW));
	for i = 1 : nim
		im(data.tmp(i).BW) = true;
	end

elseif strcmpi(imtype, 'edge') || strcmpi(imtype, 'edge4')
	% edge map
	filename = strcat(imagelist(imid).fullpath, '.mat');
	data = load(filename);
	nim = numel(data.tmp);
	im = false(size(data.tmp(1).BW));
	for i = 1 : nim
		b = bwperim(data.tmp(i).BW);
		im(b) = true;
	end
	
elseif strcmpi(imtype, 'edge8')
	% 8-connected edge map
	filename = strcat(imagelist(imid).fullpath, '.mat');
	data = load(filename);
	nim = numel(data.tmp);
	im = false(size(data.tmp(1).BW));
	for i = 1 : nim
		b = bwperim(data.tmp(i).BW, 8);
		im(b) = true;
	end
	
elseif strcmpi(imtype, 'edges') || strcmpi(imtype, 'edges4')
	% cell of edge maps, each of which corresponds to a single cell
	filename = strcat(imagelist(imid).fullpath, '.mat');
	data = load(filename);
	nim = numel(data.tmp);
	im = cell(1, nim);	
	for i = 1 : nim
		im{i} = bwperim(data.tmp(i).BW);
	end

elseif strcmpi(imtype, 'edges8')
	% cell of 8-connected edge maps, each of which corresponds to a single cell
	filename = strcat(imagelist(imid).fullpath, '.mat');
	data = load(filename);
	nim = numel(data.tmp);
	im = cell(1, nim);	
	for i = 1 : nim
		im{i} = bwperim(data.tmp(i).BW, 8);
	end
	
elseif strcmpi(imtype, 'exedge') || strcmpi(imtype, 'exedge4')
	% external edge map
	filename = strcat(imagelist(imid).fullpath, '.mat');
	data = load(filename);
	nim = numel(data.tmp);
	im = false(size(data.tmp(1).BW));
	for i = 1 : nim
		b = bwperim(~data.tmp(i).BW);
		im(b) = true;
	end
	
elseif strcmpi(imtype, 'exedge8')
	% external 8-connected edge map
	filename = strcat(imagelist(imid).fullpath, '.mat');
	data = load(filename);
	nim = numel(data.tmp);
	im = false(size(data.tmp(1).BW));
	for i = 1 : nim
		b = bwperim(~data.tmp(i).BW, 8);
		im(b) = true;
	end
	
elseif strcmpi(imtype, 'exedges')
	% cell of external edge maps, each of which corresponds to a single cell
	filename = strcat(imagelist(imid).fullpath, '.mat');
	data = load(filename);
	nim = numel(data.tmp);
	im = cell(1, nim);
	
	for i = 1 : nim
		im{i} = bwperim(~data.tmp(i).BW);
	end
	
elseif strcmpi(imtype, 'exedges8')
	% cell of external 8-connected edge maps, each of which corresponds to a 
	% single cell
	filename = strcat(imagelist(imid).fullpath, '.mat');
	data = load(filename);
	nim = numel(data.tmp);
	im = cell(1, nim);
	
	for i = 1 : nim
		im{i} = bwperim(~data.tmp(i).BW, 8);
	end
	
else
	% Error
	error('hsreadimage:ImageTypeError', 'Image Type should not be ''%s''', ...
		imtype);
end


%% Regions
varargin = varargin{1};
if isnumeric(varargin)
	if numel(varargin) ~= 2 && numel(varargin) ~= 1
		error('HSREADIMAGE:SizeError', 'The enlarge size should be 1-D or 2-D!');
	end
	
	if numel(varargin) == 1
		padr = varargin;
		padc = varargin;
	else
		padr = varargin(1);
		padc = varargin(2);
	end
	
	filename = strcat(imagelist(imid).fullpath, '.mat');
	data = load(filename);
	mask = data.TM;
	[nr, nc] = size(data.TM);
	[rs, cs] = find(mask > 0);
	minr = min(rs); maxr = max(rs);
	minc = min(cs); maxc = max(cs);
	minr = max(1, minr - padr); maxr = min(nr, maxr + padr);
	minc = max(1, minc - padc); maxc = min(nc, maxc + padc);

	if iscell(im)
		for i = 1 : numel(im)
			im{i} = im{i}(minr : maxr, minc : maxc, :);
		end
	else
		im = im(minr : maxr, minc : maxc, :);
	end
elseif ischar(varargin) && strcmpi(varargin, 'region')
	filename = strcat(imagelist(imid).fullpath, '.mat');
	data = load(filename);
	mask = data.TM;
	[rs, cs] = find(mask > 0);
	minr = min(rs); maxr = max(rs);
	minc = min(cs); maxc = max(cs);
	
	if iscell(im)
		for i = 1 : numel(im)
			im{i} = im{i}(minr : maxr, minc : maxc, :);
		end
	else
		im = im(minr : maxr, minc : maxc, :);
	end
end
