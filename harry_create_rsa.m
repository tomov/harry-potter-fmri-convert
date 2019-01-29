function rsa = harry_create_rsa(rsa_idx, subj)

    % Create rsa structure, helper function for creating EXPT in
    % harry_expt.m
    %
    % USAGE: rsa = harry_create_rsa(model,subj)
    %
    % INPUTS:
    %   rsa_idx - positive integer indicating which RSA we're doing
    %   subj - integer specifying which subject is being analyzed
    %
    % OUTPUTS:
    %   rsa - a structure with the following fields:
    %     .glmodel - which GLM to use to get the trial-by-trial betas; make sure to have a unique regressor for each trial, e.g. 'trial_onset_1', 'trial_onset_2', etc.
    %     .event - which within-trial event to use for neural activity; used to pick the right betas (needs to be substring of the regressor name), e.g. 'trial_onset'
    %     .mask - path to .nii file, or 3D binary vector of voxels to consider
    %     .radius - searchlight radius in voxels
    %     .which_betas - logical mask for which betas (trials) front the GLM to include (e.g. not timeouts)
    %     .model - struct array describing the models used for behavioral RDMs (see Kriegeskorte et al. 2008) with the fields:
    %         .name - model name
    %         .features - [nTrials x D] feature vector
    %         .distance_measure - name (e.g. 'cosine') or function handler to be used as a distance measure for the RDMs (passed to pdist, see MATLAB documentation)
    %         .is_control - whether this is a control model (e.g. time)
    %
    % Momchil Tomov, Sep 2018


    fprintf('rsa %d, subj %d\n', rsa_idx, subj);

    % TODO dedupe with harry_create_multi

    % load stuff
    filename = fullfile(sprintf('subject_%d.mat', subj));
    load(filename);

    [subjdirs, goodRuns] = harry_getSubjectsDirsAndRuns();
  
    % which rows from the data correspond to good runs
    runs = find(goodRuns{subj});

    which_rows = logical(zeros(1, numel(words)));

    % get all words from good runs
    for r = 1:length(runs)
        run = runs(r);

        % which rows from the data correspond to that run
        which_TRs = time(:,2) == run;
        fprintf('which_TRs = %s\n', sprintf('%d', which_TRs));

        % get run start and end times
        TRs = time(which_TRs,1);
        run_onset = TRs(1); % we also need to subtract it from the word times
        run_offset = TRs(end); 

        % figure out which words were shown in this run and include them
        which_rows = which_rows | ([words.start] >= run_onset & [words.start] <= run_offset);
    end

    % get words for subject 
    texts = [words(which_rows).text];

    % which words correspond to sentence starts and ends
    sentence_ends = find(endsWith(texts, '.')); % TODO hacky, e.g. "Mrs." fails, but whatevs it's a first pass
    sentence_starts = [1 sentence_ends(1:end-1)-1];


    % RSAs
    %
    switch rsa_idx

        % every word
        %
        case 1
            rsa.event = 'stim_onset';
            rsa.glmodel = 1;
            rsa.radius = 10 / 1.5;
            rsa.mask = 'masks/mask.nii';
            rsa.which_betas = logical(ones(numel(texts), 1));

            rsa.model(1).name = 'length_diff';
            rsa.model(1).features = cellfun(@(str) length(str), texts);
            rsa.model(1).distance_measure = @(x1, x2) abs(x1 - x2); 
            rsa.model(1).is_control = false;


        % every 4 words 
        %
        case 2
            rsa.event = 'stim_onset';
            rsa.glmodel = 2;
            rsa.radius = 10 / 1.5;
            rsa.mask = 'masks/mask.nii';
            rsa.which_betas = logical(ones(floor(numel(texts) / 4), 1));

            rsa.model(1).name = 'length_diff';
            rsa.model(1).features = cellfun(@(str) length(str), texts(4:4:end));
            rsa.model(1).distance_measure = @(x1, x2) abs(x1 - x2);
            rsa.model(1).is_control = false;


        % every 8 words 
        %
        case 3
            rsa.event = 'stim_onset';
            rsa.glmodel = 3;
            rsa.radius = 10 / 1.5;
            rsa.mask = 'masks/mask.nii';
            rsa.which_betas = logical(ones(floor(numel(texts) / 8), 1));

            rsa.model(1).name = 'length_diff';
            rsa.model(1).features = cellfun(@(str) length(str), texts(8:8:end));
            rsa.model(1).distance_measure = @(x1, x2) abs(x1 - x2);
            rsa.model(1).is_control = false;


        % every sentence boxcar
        %
        case 4
            ra.event = 'boxcar';
            rsa.glmodel = 4;
            rsa.radius = 10 / 1.5;
            rsa.mask = 'masks/mask.nii';
            rsa.which_betas = logical(ones(numel(sentence_starts), 1));

            rsa.model(1).name = 'length_diff';
            rsa.model(1).features = sentence_ends - sentence_starts;
            rsa.model(1).distance_measure = @(x1, x2) abs(x1 - x2);
            rsa.model(1).is_control = false;


        % every sentence ramp
        %
        case 5
            ra.event = 'ramp';
            rsa.glmodel = 4;
            rsa.radius = 10 / 1.5;
            rsa.mask = 'masks/mask.nii';
            rsa.which_betas = logical(ones(numel(sentence_starts), 1));

            rsa.model(1).name = 'length_diff';
            rsa.model(1).features = sentence_ends - sentence_starts;
            rsa.model(1).distance_measure = @(x1, x2) abs(x1 - x2);
            rsa.model(1).is_control = false;



        otherwise
            assert(false, 'invalid rsa_idx -- should be one of the above');

    end % end of switch statement

end
