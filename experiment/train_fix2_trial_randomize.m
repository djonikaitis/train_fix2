% Randomized all parameters for the trial


%% Initialize NaN fields of all settings

% New trial initialized
if tid == 1
    % Do nothing
else
    f1 = fieldnames(expsetup.stim);
    ind = strncmp(f1,'esetup', 6) |...
        strncmp(f1,'edata', 5);
    for i=1:numel(ind)
        if ind(i)==1
            if ~iscell(expsetup.stim.(f1{i}))
                [m,n,o]=size(expsetup.stim.(f1{i}));
                expsetup.stim.(f1{i})(tid,1:n,1:o) = NaN;
            elseif iscell(expsetup.stim.(f1{i}))
                expsetup.stim.(f1{i}){tid} = NaN;
            end
        end
    end
end

%% Which exp version is running?

expsetup.stim.esetup_exp_version(tid,1) = expsetup.stim.exp_version_temp;


%%  Fix

% Fixation color
if ischar(stim.fixation_color_baseline)
    a=randperm(numel(expsetup.stim.foreground_color));
    temp1 = expsetup.stim.foreground_color(a(1),:);
    expsetup.stim.esetup_fix_color(tid,1:3) = temp1;
else
    temp1 = expsetup.stim.fixation_color_baseline;
    expsetup.stim.esetup_fix_color(tid,1:3) = temp1;
end
    
% Fixation position
ind1=randperm(numel(expsetup.stim.fixation_arc));
expsetup.stim.esetup_fix_arc(tid,1) = expsetup.stim.fixation_arc(ind1(1));
expsetup.stim.esetup_fix_radius(tid,1) = expsetup.stim.fixation_radius(ind1(1));

% Fixation size
temp1=Shuffle(expsetup.stim.fixation_size);
expsetup.stim.esetup_fix_size(tid,1:2) = 0;
expsetup.stim.esetup_fix_size(tid,3) = temp1(1);
expsetup.stim.esetup_fix_size(tid,4) = temp1(1);

% Fixation size drift
temp1=Shuffle(expsetup.stim.fixation_size_drift);
expsetup.stim.esetup_fix_size_drift(tid,1:2) = 0;
expsetup.stim.esetup_fix_size_drift(tid,3) = temp1(1);
expsetup.stim.esetup_fix_size_drift(tid,4) = temp1(1);

% Fixation size eyetrack
temp1=Shuffle(expsetup.stim.fixation_size_eyetrack);
expsetup.stim.esetup_fix_size_eyetrack(tid,1:2) = 0;
expsetup.stim.esetup_fix_size_eyetrack(tid,3) = temp1(1);
expsetup.stim.esetup_fix_size_eyetrack(tid,4) = temp1(1);

% Fixation acquire duration
temp1=Shuffle(expsetup.stim.fixation_acquire_duration);
expsetup.stim.esetup_fixation_acquire_duration(tid,1) = temp1(1);
 
% Fixation maintain duration
if expsetup.stim.esetup_exp_version(tid, 1) ==1
    temp1 = Shuffle(expsetup.stim.fixation_maintain_duration);
elseif expsetup.stim.esetup_exp_version(tid, 1) == 2
    temp1 = Shuffle(tv1(1).temp_var_current);
end
expsetup.stim.esetup_fixation_maintain_duration(tid,1) = temp1(1);

% Do drift correction or not?
expsetup.stim.esetup_fixation_drift_correction_on(tid,1) = expsetup.stim.fixation_drift_correction_on;

% What is starting drift error? 0 by default
expsetup.stim.esetup_fixation_drift_error (tid,1:2) = 0;

%% If previous trial was an error, then copy settings of the previous trial

if tid>1
    if expsetup.stim.trial_error_repeat == 1 % Repeat error trial immediately
        if  ~strcmp(expsetup.stim.edata_error_code{tid-1}, 'correct')
            f1 = fieldnames(expsetup.stim);
            ind = strncmp(f1,'esetup', 6);
            for i=1:numel(ind)
                if ind(i)==1
                    if ~iscell(expsetup.stim.(f1{i}))
                        [m,n,o]=size(expsetup.stim.(f1{i}));
                        expsetup.stim.(f1{i})(tid,1:n,1:o) = expsetup.stim.(f1{i})(tid-1,1:n,1:o);
                    elseif iscell(expsetup.stim.(f1{i}))
                        expsetup.stim.(f1{i}){tid} = NaN;
                    end
                end
            end
        end
    end
end

