function dirs = setupimagenebula(varargin);
%SETUPIMAGENEBULA - setup the image nebula toolbox
% DIRS = SETUPIMAGENEBULA(VARARGIN)
%
% SETUPIMAGENEBULA setups the image nebula toolbox by adding the toolbox 
% directories to MATLAB's search path.  By default, the directories are appended
% to the search path. Any input arguments will be passed to ADDPATH so, for 
% instance, ADDUTILS('begin') will prepend the directories rather than append 
% them.
%

	%% Options
	% default is to append directories
	if nargin <= 0
		varargin = {'-begin'};
	end

	varargin = lower(varargin);

	%% Get the path of current file
	% get location of this mfile
	[path] = fileparts(which([mfilename '.m']));
	
	% get all subdirs recursively
	dirs = addsubdirs(path);
	
	%%add directories to MATLAB's search path
	addpath(dirs{:}, varargin{:});
	savepath;
end

function subdirs = addsubdirs(path, subdirs)
	if nargin < 2
		subdirs = {};
	end
	
	files = dir(path);
	for i = 1 : length(files)
		if files(i).isdir && ~strcmpi(files(i).name, '.') && ...
				~strcmpi(files(i).name, '..')
			currentpath = fullfile(path, files(i).name);
			subdirs{end+1} = currentpath;
			subdirs = addsubdirs(currentpath, subdirs);
		end
	end
end
