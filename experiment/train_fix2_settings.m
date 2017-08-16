% All possible experimental settings within this file;
%
% Produces stim structure which contains all stimuli settings and trial
% definitions


%% Different training stages have different stim durations

stim.training_stage_matrix = [1]; % Different levels of task difficulty. Select to use one.

% Training stage 1.0
% Is final stage. No changes to the code

% Training stage 2.0
% Increase fixation duration.
stim.fixation_maintain_duration = [2];
stim.fixation_maintain_duration_ini = 1.6;
stim.fixation_maintain_duration_ini_step = 0.1;


%%  Reward

% stim.reward_coeff1 = [460.0749   64.8784]; % Mount rack reward, measure as of 03.08.2016
stim.reward_coeff1 = [881.4887   -3.3301]; % Pump reward measure as of 10.19.2016

if isfield(expsetup.general, 'subject_id') && strcmp(expsetup.general.subject_id, 'aq')
    stim.reward_size_ml = 0.25; % Typical reward to start with
elseif isfield(expsetup.general, 'subject_id') && strcmp(expsetup.general.subject_id, 'hb')
    stim.reward_size_ml = 0.16; % Typical reward to start with
elseif isfield(expsetup.general, 'subject_id') && strcmp(expsetup.general.subject_id, 'jw')
    stim.reward_size_ml = 0.25; % Typical reward to start with
else
    stim.reward_size_ml = 0.18;
end
stim.reward_size_ms = round(polyval(stim.reward_coeff1, stim.reward_size_ml));
stim.reward_feedback = 2; % If 1 - show feedback;  2 - play audio feedback; 3 - audio feedback via arduino
stim.reward_feedback_audio_dur = 0.2; % How long to wait to give reward feedback



%% Stimuli

%==============
% Fixation

% Fix size & color
stim.fixation_size = [0.5]; % Size of fixation (degrees)
stim.fixation_color_baseline = [20,20,200]; % Color of fixation or text on the screen
stim.fixation_shape_baseline = 'circle';
stim.fixation_pen = 4; % Fixation outline thickness (pixels)
stim.fixation_blink_frequency = 2; % How many time blinks per second;

% Fix position
stim.fixation_arc = [0, 0:45:270]; % Fixation position in degrees from center
rad=8; % Center-fixation distance
stim.fixation_radius = [0 repmat(rad, 1, length(stim.fixation_arc))]; % Center-fixation distance

% Fixation duration
stim.fixation_acquire_duration = [5]; % How long to show fixation before it is acquired


%===============
% Drif correction

stim.fixation_drift_correction_on = 1; % 1 - drift correction initiated
stim.fixation_size_drift = 5; % Larger fixation window for drift correction
stim.fixation_drift_maintain_maximum = 0.3; % After that much time drift correction starts
stim.fixation_drift_maintain_minimum = 0.2; % That long duration is used for determining drift position
if isfield(expsetup.general, 'subject_id') && strcmp(expsetup.general.subject_id(1:2), 'aq')
    stim.fixation_size_eyetrack = 2.5; % Window within which to maintain fixation
elseif isfield(expsetup.general, 'subject_id') && strcmp(expsetup.general.subject_id(1:2), 'hb')
    stim.fixation_size_eyetrack = 3; % Window within which to maintain fixation
else
    stim.fixation_size_eyetrack = 10; % Window within which to maintain fixation
end


%==============
% Screen colors
stim.background_color = [127, 127, 127];

% foreground_color is used for random color generation
stim.foreground_color(1,:) = [200, 20, 20];
stim.foreground_color(2,:)=[200, 255, 20];
stim.foreground_color(3,:)=[70, 70, 200];
stim.foreground_color(4,:)=[200, 20, 200];
stim.foreground_color(5,:)=[20, 200, 20];
stim.foreground_color(6,:)=[255, 255, 200];
stim.foreground_color(7,:)=[70, 0, 0];
stim.foreground_color(8,:)=[0, 0, 70];
stim.foreground_color(9,:)=[0, 70, 0];
stim.foreground_color(10,:)=[70, 70, 0];

%===============
% Duration of trials
stim.trial_dur_intertrial = 0.5; % Blank screen at the end
stim.trial_dur_intertrial_error = 2; % Blank screen at the end

%===============
% Other

% Staircase
stim.trial_online_counter = 3; % How many trials to count for updating task difficulty
stim.trial_correct_goal_up = 3; % What is accuracy to make task harder
stim.trial_correct_goal_down = 2; % What is accuracy to make task harder

% Other
stim.trial_error_repeat = 1; % 1 - repeats same trial if error occured immediatelly; 0 - no repeat
stim.trial_abort_counter = 20; % Quit experiment if trials in a row are aborted
stim.plot_every_x_trial = 1; % Every which trial to plot (every 1, 2nd, 10th etc trial)
 
% Picture file used for instruction
stim.instrpic{1}='image_condition1';
stim.instrpic{2}='image_condition2';


%% Settings that change on each trial (matrix; one trial = one row)

% Specify column names for expmatrix
stim.esetup_exp_version = NaN; % Which task participant is doing
stim.edata_first_display = NaN;
stim.edata_loop_over = NaN;

stim.esetup_fix_arc = NaN;  % Fixation x position
stim.esetup_fix_radius = NaN;  % Fixation x position
stim.esetup_fix_color(1,1:3) = NaN; % Color of the fixation
stim.esetup_fix_size(1,1:4) = NaN; % Fixation size
stim.esetup_fix_size_drift(1,1:4) = NaN; % Fixation size
stim.esetup_fix_size_eyetrack(1,1:4) = NaN; % Fixation size

% Timing
stim.esetup_fixation_acquire_duration = NaN;
stim.esetup_fixation_maintain_duration = NaN;

% Drift parameters
stim.esetup_fixation_drift_correction_on = NaN; % Do drift correction or not?
stim.esetup_fixation_drift_offset(1,1:2) = NaN; % X-Y offset for the drift;

% Stim timing recorded
stim.edata_fixation_on = NaN; 
stim.edata_fixation_acquired = NaN; 
stim.edata_fixation_maintained = NaN; 
stim.edata_fixation_drift_maintained = NaN;
stim.edata_fixation_drift_calculated = NaN; % Moment when calculations of the drift are done
stim.edata_fixation_off = NaN; 
stim.edata_reward_on = NaN;

% Reward
stim.edata_reward_size_ms = NaN; % How much reward animal was given
stim.edata_reward_size_ml = NaN; % How much reward animal was given

% Variables for eyetracking plotting
stim.edata_eyelinkscreen_drift_on = NaN; % Drift stimulus window drawn on eyelink screen
stim.edata_eyelinkscreen_fixation = NaN; % Fixation after drift correction is done

% Monitoring performance
stim.edata_error_code = cell(1); % Error codes
stim.edata_error_code{1} = NaN;

stim.edata_trial_abort_counter = NaN;
stim.edata_trial_online_counter = NaN; % Error code


%% Settings that change on each frame (one trial = one cell; within cell - one row = one frame onscreen)

% Timingn and eye position
stim.eframes_time{1}(1) = NaN;
stim.eframes_eye_x{1}(1) = NaN;
stim.eframes_eye_y{1}(1) = NaN;
stim.eframes_eye_target{1}(1) = NaN;

% Other variables
stim.eframes_fix_blink{1}(1) = NaN;


%% Save into expsetup

expsetup.stim=stim;


