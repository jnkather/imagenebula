function [tim, perm] = textonsvisualize(textons, fb)
% TEXTONSVISUALIZE Reconstruct the images of the textons
% [TIM, PERM] = TEXTONSVISUALIZE(TEXTONS, FB)
%
% Reconstruct the images of the textons from the centers of the texton
% groups and the filter bank kernels.
%
% INPUTS
%	TEXTONS	- K-means centers of the group, indicating the
%       representative feature vector of the texton feature.
%   FB      - Filter bank kernels
%
% OUTPUTS
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

%% Determine the size and dimension of the input
dimtextons = ndims(textons);
dimfb = ndims(fb);
sizetextons = size(textons);
sizefb = size(fb);
nfb = numel(fb);

if (dimtextons - dimfb == 1),
    ismultichannel = false;
elseif (dimtextons - dimfb == 2),
    ismultichannel = true;
else
    % error
    error('textonsvisualize:InputDimensionError', ...
        'Dimension of TEXTTONS should exceed the dimension of FB by 1 or 2!');
end

ntextons = sizetextons(1);
if ismultichannel,
    nchannels = sizetextons(2);
end

if ismultichannel
    % for multi-channel image    
    sizeft = sizetextons(3:end);
else
    % for single-channel image
    sizeft = sizetextons(2:end);
end

if sizefb ~= sizeft
    error('textonsvisualize:InputSizeError', ...
        'Sizes of the TEXTONS and FB do not match!');
end

%% Reconstruct
maxsize = [1 1];
for i = 1 : numel(fb),
	maxsize = max(size(fb{i}), maxsize);
end

% compute the linear combinations of filters
tim = cell(ntextons, 1);
fb = reshape(fb, [nfb, 1]);
if ismultichannel
	textons = reshape(textons, [ntextons, nchannels, nfb]);
else
	textons = reshape(textons, [ntextons, nfb]);
end

for i = 1: ntextons
	% for each texton
	if ~ismultichannel
		tim{i} = zeros(maxsize);
		for j = 1 : nfb
			% for each filter bank
			f = fb{j} * textons(i, j);
			off = (maxsize - size(f,1)) / 2;
			tim{i}(1+off:end-off, 1+off:end-off) = ...
				tim{i}(1+off:end-off, 1+off:end-off) + f;
		end
	else
		tim{i} = zeros([maxsize, nchannels]);
		for j = 1 : nfb
			% for each filter bank
			for k = 1 : nchannels
				f = fb{j} * textons(i, k, j);
				off = (maxsize - size(f,1)) / 2;
				tim{i}(1+off:end-off, 1+off:end-off, k) = ...
					tim{i}(1+off:end-off, 1+off:end-off, k) + f;
			end
		end
	end
	
end

% computer permutation order for decreasing L1 norm
norms = zeros(ntextons, 1);
for i = 1 : k,
	norms(i) = sum(abs(tim{i}(:)));
end

[y, perm] = sort(norms);
perm = flipud(perm);
