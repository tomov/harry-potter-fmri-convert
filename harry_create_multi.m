function multi = harry_create_multi(glmodel, subj, run, save_output)

    % Create multi structure, helper function for creating EXPT in
    % harry_expt.m
    %
    % USAGE: multi = harry_create_multi(model,subj,run)
    %
    % INPUTS:
    %   glmodel - positive integer indicating general linear model
    %   subj - integer specifying which subject is being analyzed
    %   run - integer specifying the run
    %
    % OUTPUTS:
    %   multi - a structure with the folloowing fields
    %        .names{i}
    %        .onsets{i}
    %        .durations{i}
    %        optional:
    %        .pmod(i).name
    %        .pmod(i).param
    %        .pmod(i).poly
    %
    % Momchil Tomov, July 2018

    if nargin < 4 || isempty(save_output)
        save_output = false;
    end

    fprintf('glm %d, subj %d, run %d\n', glmodel, subj, run);


    % load stuff
    filename = fullfile(EXPT.subject(subj).rawdir, sprintf('subject_%d.mat', subj_idx));
    load(filename);

    [subjdirs, goodRuns] = harry_getSubjectsDirsAndRuns();
  
    % skip bad runs
    runs = find(goodRuns{subj});
    run = runs(run);
    fprintf('run %d \n', run);
    

    % which rows from the data correspond to that run
    which_rows = time(:,2) == run;
    fprintf('which_rows = %s\n', sprintf('%d', which_rows));

    TR_times = time(which_rows,1);
    run_onset = TR_times(1); % we need to subtract it from the word times


    % get words and onsets for run
    onsets = [words(which_rows).start];
    onsets = onsets - run_onset; % b/c they count them for the whole session
    texts = [words(which_rows).text];


    % GLMs
    %
    switch glmodel

        % impulse regressor for every word
        %
        case 1 
            
            idx = 0;

            for t = 1:numel(onsets)
                idx = idx + 1;
                multi.names{idx} = sprintf('stim_onset_run_%d_word_%d', run, t); 
                multi.onsets{idx} = [onsets(t)];
                multi.durations{idx} = [0];
            end

        % impulse regressor for every 4 words
        %
        case 2 
            
            idx = 0;

            for t = 4:4:numel(onsets)
                idx = idx + 1;
                multi.names{idx} = sprintf('stim_onset_run_%d_word_%d', run, t); 
                multi.onsets{idx} = [onsets(t)];
                multi.durations{idx} = [0];
            end


        % boxcar regressor for every sentence
        %
        case 3 
            
            idx = 0;

            sentence_ends = find(endsWith(texts, '.')); % TODO hacky, e.g. "Mrs." fails, but whatevs it's a first pass
            sentence_starts = [1 sentence_starts(1:end-1)-1];

            for s = 1:numel(sentence_starts)
                idx = idx + 1;
                multi.names{idx} = sprintf('boxcar_run_%d_sentence%d', run, s); 
                multi.onsets{idx} = [onsets(sentence_starts(s))];
                multi.durations{idx} = [onsets(sentence_ends(s) - sentence_starts(s))];
            end


        % ramp regressor for every sentence
        %
        case 4 
            
            idx = 0;

            sentence_ends = find(endsWith(texts, '.')); % TODO hacky, e.g. "Mrs." fails, but whatevs it's a first pass
            sentence_starts = [1 sentence_starts(1:end-1)-1];

            for s = 1:numel(sentence_starts)
                idx = idx + 1;
                multi.names{idx} = sprintf('boxcar_run_%d_sentence%d', run, s); 
                multi.onsets{idx} = [onsets(sentence_starts(s))];
                multi.durations{idx} = [onsets(sentence_ends(s) - sentence_starts(s))];

                multi.tmod{idx} = 1; % linear effect of time
            end




        otherwise
            assert(false, 'invalid glmodel -- should be one of the above');

    end % end of switch statement

   if save_output
       save('harry_create_multi.mat'); % <-- DON'T DO IT! breaks on NCF... b/c of file permissions
   end
end



