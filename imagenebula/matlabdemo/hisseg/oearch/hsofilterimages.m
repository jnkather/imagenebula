function hsofilterimages(imid, imtype, imregion, sigma, ...
	s, support, ntheta, derivative, hilbert, savefim)
%HSOFILTERIMAGES filter all images using the arc OE kernel and save them to
% cache files.
%
% HSOFILTERIMAGES(IMID, IMTYPE, IMREGION, SIGMA, S, SUPPORT, NTHETA,
%	DERIVATIVE, HILBERT)
%
% HSOFILTERIMAGES(OPTIONS)
%	where OPTIONS is a struct whose fileds are above arguments.
%
% INPUT
%	[OPTIONS]	- If only one struct argument is specified, all following
%	arguments are provided as the fields of OPTIONS.
%
%	[IMID]		- Image id, could be a single IDs or vector of IDs.
%
%	[IMTYPE]	- Image type, 'ccd', 'h', 'e', 'r', 'g', 'b', etc.
%				Could be a single string, or a cell of strings.
%
%	[IMREGION]	- Image region, 'full', 'region' or padding [rows, cols]
%				Could be a single variable, or a cell.
%
%	[SIGMA]		- Scale parameters of filter, [sigmax, sigmay]
%				Could be a single matrix, or a cell of matrics.
%
%	[S]			- 1/R, where R indicating radius of the filter
%				Could be a vector, or a cell of vectors.
%
%	[SUPPORT]	- The half size of the filter is determined by SUPPORT*SIGMA. In
%	fact, the half size of the filter is MAX(CEIL(SUPPORT * SIGMA)). Default is 
%	5, which means the half size of the filter is about 5 times the maximum of 
%	the sigmas in X and Y directions.
%	If a vector is provided, each value in the SUPPORT vector will be used to
%	calcualte the filter kernels, all corresponding filter responses will be
%	calculated and cached.
%
%	[NTHETA]	- Number of orientations.
%	If a vector is provided, each value in the NTHETA vector will be used to
%	calculate the filter kernel banks, all corresponding filter responses will be
%	calculated and cached.
%
%	[DERIVATIVE]- Degree of derivative in Y direction, one of {0, 1, 2}. Default
%	is 0, which means that the filter in Y direction is the same as (or the
%	hilbert transform of, determined by the value of DOHILBERT) the filter in X
%	direction.
%	If a vector is provided, each value in the DERIVATIVE vector will be used to
%	calculate the filter kernel banks, all corresponding filter reponses will be
%	calcualted and cached.
%
%	[HILBERT]	- Do Hilbert transform in y direction? Default is 0 (logical
%	false), which means do not perform Hilbert transformation in Y direction.
%	If a vector is provided, each value in the HILBERT vector will be used to
%	calculate the filter kernel banks, all corresponding filter responses will
%	be calculated and cached.
%
%	[SAVEFIM]	- Save intermediate filter results in the final result file?
%	Default is 0 (logical false), which means do not save filter results in the
%	final result file.
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
if (nargin == 1) && isstruct(imid)
	options = imid;
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
	else hilbert = (0:1); end;
	if isfield(options, 'savefim'), savefim = options.savefim;
	else savefim = false; end;
else
	if (nargin < 1) || (numel(imid) <= 0), imid = 1; end;
	if (nargin < 2) || (numel(imtype) <= 0), imtype = 'h'; end;
	if (nargin < 3) || (numel(imregion) <= 0), imregion = [50, 50]; end;
	if (nargin < 4) || (numel(sigma) <= 0), sigma = [6, 1.5]; end;
	if (nargin < 5) || (numel(s) <= 0), s = (0.15 : -0.005 : 0); end;
	if (nargin < 6) || (numel(support) <= 0), support = 5; end;
	if (nargin < 7) || (numel(ntheta) <= 0), ntheta = 24; end;
	if (nargin < 8) || (numel(derivative) <= 0), derivative = 2; end;
	if (nargin < 9) || (numel(hilbert) <= 0), hilbert = (0:1); end;
	if (nargin < 10) || isempty(savefim), savefim = false; end;	
end

%% Paramter conversion
if ~iscell(imtype), imtype = {imtype}; end;
if ~iscell(imregion), imregion = {imregion}; end;
if ~iscell(sigma), sigma = {sigma}; end;
if ~iscell(s), s = {s}; end;
if ~iscell(savefim), savefim = {savefim}; end;

%% Counts
nim = numel(imid);
nimtype = numel(imtype);
nimregion = numel(imregion);
nsigma = numel(sigma);
ns = numel(s);
nsupport = numel(support);
nntheta = numel(ntheta);
nderivative = numel(derivative);
nhilbert = numel(hilbert);
nsavefim = numel(savefim);
n = nim * nimtype * nimregion * nsigma * ns * nsupport * nntheta * ...
	nderivative * nhilbert * nsavefim;

if n <= 0
	error('oearcfilterimages:CountError', ...
		'Paramters error!');
elseif n > 100
	fprintf('Count of sets of parameters is %d, ', n);
	reply = input('Do you want more? Y/N [Y]: ', 's');
	if isempty(reply) || numel(strfind(reply, 'n')) > 0 || ...
			numel(strfind(reply, 'N')) > 0
		return;
	end
end
	

%% Iterate filter all images using all sets of parameters
fprintf('Found %d sets of parameters, this may take a while ...\n', n);
i = 0;
for iim = 1 : nim
for iimtype = 1 : nimtype
for iimregion = 1 : nimregion
for isigma = 1 : nsigma
for is = 1 : ns
for isupport = 1 : nsupport
for intheta = 1 : nntheta
for iderivative = 1 : nderivative
for ihilbert = 1 : nhilbert
for isavefim = 1 : nsavefim
	i = i + 1;
	fprintf('Beginning iteration %d / %d ...\n', i, n);
	hsofilterimage(imid(iim), imtype{iimtype}, imregion{iimregion}, ...
		sigma{isigma}, s{is}, support(isupport), ntheta(intheta), ...
		derivative(iderivative), hilbert(ihilbert), savefim{isavefim});
	fprintf('Iteration %d / %d Done!\n', i, n);
end
end
end
end
end
end
end
end
end
end
