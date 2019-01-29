function subj_to_nii(subj_idx)

    % convert data for given subject to 4D nifti format (x, y, z, TR)
    %

    % load stuff
    filename = fullfile('subjects', sprintf('subject_%d.mat', subj_idx));
    load(filename);

    % create output directory
    subj_dirname = fullfile('subjects', sprintf('HARRY_%03d', subj_idx));
    preproc_dirname = fullfile(subj_dirname, 'preproc');
    mkdir(subj_dirname);
    mkdir(preproc_dirname);
    
    % transform colToCoord to linear indexing instead of 3D indexing
    vox_ind = sub2ind([meta.dimx meta.dimy meta.dimz], meta.colToCoord(:,1),  meta.colToCoord(:,2),  meta.colToCoord(:,3));

    runs = unique(time(:,2));

    % for each run
    for r = 1:length(runs)
        run = runs(r);

        % which rows from the data correspond to that run
        which_rows = time(:,2) == run;

        % get the activation data for the corresponding run only
        run_data = data(which_rows,:);
        runTRs = size(run_data, 1);

        % initialize run 4D (x,y,z,TR) data structure that we will write out to .nii file
        run_nii = nan(meta.dimx, meta.dimy, meta.dimz, runTRs);

        % initialize temporary 3D volume that we use for each TR
        volume = zeros(meta.dimx, meta.dimy, meta.dimz);

        for t = 1:size(run_data, 1)
            % assign voxels in volume to activations from TR t
            volume(vox_ind) = run_data(t, :);

            % save to corresponding TR in run data
            run_nii(:, :, :, t) = volume;
        end

        niftiwrite(run_nii, fullfile(preproc_dirname, sprintf('run%03d.nii', r)));
    end
