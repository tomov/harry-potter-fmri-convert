function [ subjdirs, goodRuns ] = harry_getSubjectsDirsAndRuns()

% Get the list of subjects, subject directories, and number of runs for the
% fMRI GLM code
%

% the names of the CORRESPONDING directories from CBS central
subjdirs = {'HARRY_001', 'HARRY_002', 'HARRY_003', 'HARRY_004', ...
            'HARRY_005', 'HARRY_006', 'HARRY_007', 'HARRY_008'};

% which runs to include/exclude for each subject
goodRuns = {logical([1 1 1 1]), logical([1 1 1 1]), logical([1 1 1 1]), logical([1 1 1 1]), ...
            logical([1 1 1 1]), logical([1 1 1 1]), logical([1 1 1 1]), logical([1 1 1 1])};

assert(numel(subjdirs) == numel(goodRuns));
