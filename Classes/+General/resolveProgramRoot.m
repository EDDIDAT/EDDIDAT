function r = resolveProgramRoot()
persistent cachedPath
if isempty(cachedPath)
    if isdeployed
        [~, exeInfo] = system(['wmic process where processid="' ...
            num2str(feature('getpid')) ...
            '" get ExecutablePath /format:value']);
        exePath = strtrim(regexprep(exeInfo, 'ExecutablePath=', ''));
        cachedPath = [fileparts(exePath) filesep];
    else
        % Diese Datei liegt in Classes/+General/
        cachedPath = [fileparts(fileparts(fileparts( ...
            mfilename('fullpath')))) filesep];
    end
end
r = cachedPath;
end
