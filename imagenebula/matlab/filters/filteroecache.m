function [f] = filteroecache(...
	sigma, support, theta, derivative, dohilbert, visual)
%FILTEROECACHE get the cached FILTEROE filter kernel from the cache file, or compute one and save it to cache if no corresponding cache file is found.
%[F] = FILTEROECACHE(SIGMA, SUPPORT, THETA, DERIVATIVE, DOHILBERT, VISUAL)
%
% Get the oriented energy (OEARC) filter kernel from the cache file, or
% compute one and save it to the cache fle if no corresponding cache file is
% found.
% All parameters are the same with FILTEROE
%
% See also FILTEROEARC, FILTEROE, FILTERBANKOE, FILTEROEARCCACHE
%

% References:
%   * Malik2001CTA@IJCV
%       Jitendra Malik, Serge Belongie, Thomas Leung and Jianbo Shi.
%       Contour and Texture Analysis for Image Segmentation,
%       International Journal of Computer Vision, vol, 43, no. 1, pp. 7-27,
%       2001.
%   * Malik1990PTD@JOSA
%       J. Malik, P. Perona.
%       Preattentive Texture Discrimination with Early Vision Mechanisms,
%       J. Optical Society of America, vol.7, no.2, pp.923-932, 1990.
%   * Perona1990DLE@ICCV
%       P. Perona, J. Malik
%       Detecting and Localizing Edges Composed of Steps, Peaks and Roofs.
%       in: Proc. 3rd Int. Conf. Computer Vision (ICCV), Osaka, Japan, pp.52-57,
%       1990.
%   * Knutsson1983TAT@CAPAIDM
%       H. Knutsson, G. Granlund
%       Texture Analysis using Two-dimensional Quadrature Filters.
%       In: Workshop on Computer Architecture for Pattern Analysis and Image
%       Database Management, pp. 206-213. 1983.
%   * Morrone1987FDL@PRL
%       M. Morrone, R. Owens
%       Feature Detection from Local Energy.
%       Pattern Recognition Letters vol. 6, pp. 303-313, 1987.
%   * Morrone1988
%       M. Morrone, D. Burr
%       Feature Detection in Human Vision: A Phase Dependent Energy Model,
%       In: Proc. R. Soc. Lond. B vol.235, pp.212-245.
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
% This file is adapted from the code provided by David R. Martin
% <dmartin@eecs.berkeley.edu>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&&&&&&&&&&

%% Arguments and option processing
error(nargchk(1, 6, nargin));

% default option
if nargin<2, support=3; end
if nargin<3, theta=0; end
if nargin<4, derivative=0; end
if nargin<5, dohilbert=0; end
if nargin<6, visual=0; end

% scalar sigma indicating the equal scale in X and Y
if numel(sigma) == 1,
	sigma = [sigma sigma];
end

% degree of derivative in Y direction
if derivative<0 || derivative>2,
	error('filteroe:DerivativeError', ...
		'Derivative in Y direction must be in [0, 2]');
end

cachefile = sprintf('OE-%.1f-%.1f-%.1f-%.3f-%d-%d.mat', ...
	sigma(1), sigma(2), support, theta, derivative, dohilbert);
mfile = mfilename('fullpath');
cachepath = fileparts(mfile);
cachepath = [cachepath, '/cache/'];
if exist(cachepath, 'dir') ~= 7
	mkdir(cachepath);
end
cachepath = [cachepath, cachefile];

% cache file exist
if exist(cachepath, 'file') ~= 2
	f = filteroe(sigma, support, theta, derivative, dohilbert, visual);
	save(cachepath, 'f');
else
	f = load(cachepath);
	f = f.f;
end