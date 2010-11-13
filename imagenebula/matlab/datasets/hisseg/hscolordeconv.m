function hscolordeconv(id, target)
%HSCOLORDECONV performs color deconvolution on all images and save the results
%
% HSCOLORDECONV(ID, TARGET)
%
% INPUT
%	ID		- ID of the image to perform color deconvolution
%	TARGET	- Target directory
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

%% Target directory
if nargin < 1, id = (1:58); end
if nargin < 1, target = hsdatapath(); end;

if exist(target, 'dir') ~= 7
	error('HSCOLORDECONV:TargetDirectoryNotExistError', ...
		'Target directory does not exist!');
end

%% Load image list
imagelist = hsimagelist();

for i = id
	% Start color deconvolution
	fprintf('Start Color Deconvolution: %02d...', i);
	
	% If files exist, skipped this round and continue
	filename = imagelist(i).name;	
	if exist(sprintf('%s/%s_ecd.tif', target, filename), 'file')
		fprintf('Skipped\n');
		continue;
	end
	
	% Perform color deconvolution
	im = hsreadimage(i, 'ccd');
	[ia, is, ias, ir, da, ds, das, dr] = colordeconv(im, 2);
	if is(1, 1) < is(2, 1)
		hi = 1; ei = 2; 
	else
		hi = 2; ei = 1;
	end;
	
	% Save color deconvolution
	imwrite(ia(:, :, hi), sprintf('%s/%s_h.tif', target, filename));
	imwrite(ia(:, :, ei), sprintf('%s/%s_e.tif', target, filename));
	hintensity = is(hi, :);
	eintensity = is(ei, :);
	hdensity = ds(hi, :);
	edensity = ds(ei, :);
	save(sprintf('%s/%s_stains.mat', target, filename), ...
		'hintensity', 'eintensity', 'hdensity', 'edensity');
	imwrite(ias{hi}, sprintf('%s/%s_hc.tif', target, filename));
	imwrite(ias{ei}, sprintf('%s/%s_ec.tif', target, filename));
	imwrite(da(:, :, hi), sprintf('%s/%s_hd.tif', target, filename));
	imwrite(da(:, :, ei), sprintf('%s/%s_ed.tif', target, filename));
	imwrite(das{hi}, sprintf('%s/%s_hcd.tif', target, filename));
	imwrite(das{ei}, sprintf('%s/%s_ecd.tif', target, filename));
	
	% Done 
	fprintf('Done\n');
end

