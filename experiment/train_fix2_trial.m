% Here all displays presented

window = expsetup.screen.window;


%% Exp stage (either keep the same or change the task)

if tid==1
    expsetup.stim.exp_version_temp = 1; % Version to start with on the first trial
    expsetup.stim.exp_version_update_next_trial = 0;
    fprintf('Task level is %.2f\n', expsetup.stim.exp_version_temp)
elseif tid>1
    if expsetup.stim.exp_version_update_next_trial == 0 % Keep the same
        b = expsetup.stim.esetup_exp_version(tid-1,1);
        expsetup.stim.exp_version_temp = b;
    elseif expsetup.stim.exp_version_update_next_trial == 1 % Change the task
        a = expsetup.stim.esetup_exp_version(tid-1,1); % Take previous trial exp version
        b = expsetup.stim.training_stage_matrix (expsetup.stim.training_stage_matrix<a); % Other available exp versions
        b = b(end);
        expsetup.stim.exp_version_temp = b; % Take largest available number (smallest number is end of training)
    end
    fprintf('Task level is %.2f\n', b)
end


%% PREPARE ALL OBJECTS AND FRAMES TO BE DRAWN:

% In this case, randomization is done on each trial. Alternatively, all exp
% mat could be preset on first trial.
if tid == 1
    train_fix2_trial_randomize;
elseif tid>1
    train_fix2_trial_randomize;
end

% Initialize all rectangles for the task
train_fix2_trial_stimuli;

% Initialize all frames for the task
train_fix2_trial_frames;


%% EYETRACKER INITIALIZE

% Start recording
if expsetup.general.recordeyes==1
    Eyelink('StartRecording');
    msg1=['TrialStart ', num2str(tid)];
    Eyelink('Message', msg1);
    WaitSecs(0.1);  % Record a few samples before we actually start displaying
end

% SEND MESSAGE WITH TRIAL ID TO EYELINK
if expsetup.general.recordeyes==1
    trial_current=tid; % Which trial of the current block it is?
    msg1 = sprintf('Trial %i', trial_current);
    Eyelink('Command', 'record_status_message ''%s'' ', msg1);
end


%% ================

% FIRST DISPLAY - BLANK

Screen('FillRect', window, expsetup.stim.background_color);
if expsetup.general.record_plexon==1
    Screen('FillRect', window, [255, 255, 255], ph_rect, 1); % Photodiode
end
[~, time_current, ~]=Screen('Flip', window);

% Save plexon event
if expsetup.general.record_plexon==1
    a1 = zeros(1,expsetup.ni_daq.digital_channel_total);
    a1_s = expsetup.general.plex_event_start; % Channel number used for events
    a1(a1_s)=1;
    outputSingleScan(ni.session_plexon_events,a1);
    a1 = zeros(1,expsetup.ni_daq.digital_channel_total);
    outputSingleScan(ni.session_plexon_events,a1);
end

% Save eyelink and psychtoolbox events
if expsetup.general.recordeyes==1
    Eyelink('Message', 'first_display');
end
expsetup.stim.edata_first_display(tid,1) = time_current;

% Save frame onset event
c1_frame_index1 = 1;
expsetup.stim.eframes_time{tid}(c1_frame_index1, 1) = time_current; % Save in the first row during presentation of first dislapy


%%  TRIAL LOOP

loop_over = 0;
while loop_over==0
    
    
    % ================
    % Initialize new frame index
    c1_frame_index1 = c1_frame_index1+1;
    
    
    %% Update frames dependent on acquiring fixation
    
    % Changes in fixation (stop blinking)
    if ~isnan(expsetup.stim.edata_fixation_acquired(tid,1))
        expsetup.stim.eframes_fix_blink{tid}(c1_frame_index1:end, 1) = 1;
    end
    
    %% Draw stimuli
    
    % Fixation
    if expsetup.stim.eframes_fix_blink{tid}(c1_frame_index1,1)==1
        % Show stimulus
        fcolor1 = expsetup.stim.esetup_fix_color(tid,1:3);
        if strcmp(expsetup.stim.fixation_shape_baseline,'circle')
            Screen('FillArc', window,  fcolor1, fixation_rect, 0, 360);
        elseif strcmp(expsetup.stim.fixation_shape_baseline,'square')
            Screen('FillRect', window, fcolor1, fixation_rect, expsetup.stim.fixation_pen);
        end
    end

    
    %% FLIP AND RECORD TIME
    
    [~, time_current, ~]=Screen('Flip', window);
    
    % Save flip time into trialmat
    expsetup.stim.eframes_time{tid}(c1_frame_index1, 1) = time_current; % Add row to each refresh
    
    % Record fixation onset
    if expsetup.stim.eframes_fix_blink{tid}(c1_frame_index1,1)==1 && isnan(expsetup.stim.edata_fixation_on(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'fixation_on');
        end
        expsetup.stim.edata_fixation_on(tid,1) = time_current;
    end
    
    
    %%  Get eyelink data sample
    
    try
        [mx,my] = runexp_eyelink_get_v10;
        expsetup.stim.eframes_eye_x{tid}(c1_frame_index1, 1)=mx;
        expsetup.stim.eframes_eye_y{tid}(c1_frame_index1, 1)=my;
    catch
        expsetup.stim.eframes_eye_x{tid}(c1_frame_index1, 1)=999999;
        expsetup.stim.eframes_eye_y{tid}(c1_frame_index1, 1)=999999;
    end
    
    
    
    %% Plot eyelink targets

    %===========================
    % Draw eyelink fixation area BEFORE drift correction
    %===========================
    if expsetup.general.recordeyes == 1 && ~isnan(expsetup.stim.edata_fixation_on(tid,1)) && isnan(expsetup.stim.edata_eyelinkscreen_drift_on(tid,1))
        if expsetup.stim.esetup_fixation_drift_correction_on(tid,1)==1
            a = round(fixation_rect_eyelink_drift);
            Eyelink('Command', 'draw_box %d %d %d %d 15', a(1),a(2),a(3),a(4));
        else
            a=round(fixation_rect_eyelink);
            Eyelink('Command', 'draw_box %d %d %d %d 15', a(1),a(2),a(3),a(4));
        end
        a=round(fixation_rect);
        Eyelink('Command', 'draw_filled_box %d %d %d %d 15', a(1),a(2),a(3),a(4));
        expsetup.stim.edata_eyelinkscreen_drift_on(tid,1) = 1;
    end
    
     
    %===========================
    % Draw eyelink fixation area AFTER before drift correction
    %===========================
    if expsetup.general.recordeyes == 1 && isnan(expsetup.stim.edata_eyelinkscreen_fixation(tid,1)) && ~isnan(expsetup.stim.edata_fixation_drift_maintained(tid,1))
        % Clear earlier screen
        Eyelink('command','clear_screen 0');
        x1_error = expsetup.stim.esetup_fixation_drift_offset(tid,1);
        y1_error = expsetup.stim.esetup_fixation_drift_offset(tid,1);
        
        % Recalculate eye-link rectangle
        eyepos=[];
        eyepos(1)=fixation_rect_eyelink(1)+x1_error;
        eyepos(3)=fixation_rect_eyelink(3)+x1_error;
        eyepos(2)=fixation_rect_eyelink(2)+y1_error;
        eyepos(4)=fixation_rect_eyelink(4)+y1_error;
        a=round(eyepos);
        Eyelink('Command', 'draw_box %d %d %d %d 15', a(1),a(2),a(3),a(4));
        % Recalculate eye-link rectangle
        eyepos=[];
        eyepos(1)=fixation_rect(1)+x1_error;
        eyepos(3)=fixation_rect(3)+x1_error;
        eyepos(2)=fixation_rect(2)+y1_error;
        eyepos(4)=fixation_rect(4)+y1_error;
        a=round(eyepos);
        Eyelink('Command', 'draw_filled_box %d %d %d %d 15', a(1),a(2),a(3),a(4));
        
        expsetup.stim.edata_eyelinkscreen_fixation(tid,1) = 1;
        
    end

    
    
    %% Check for eye position
    
    %===========================
    % Part 0: Determine which target participant looked at
    %===========================
    
    if expsetup.general.recordeyes==1
        
        % Target coordinates
        x1_target = []; y1_target = []; error1=[];
        
        % Initialize which targets to check for at which periods
        
        if expsetup.stim.esetup_fixation_drift_correction_on(tid,1)==1 && isnan(expsetup.stim.edata_fixation_drift_maintained(tid,1)) % Before drift correction
            % Target 1 - fixation position
            [x,y] = RectCenter(fixation_rect);
            x1_target(1) = x + expsetup.stim.esetup_fixation_drift_offset(tid,1); % Fixation coordinates x (with potential error)
            y1_target(1) = y + expsetup.stim.esetup_fixation_drift_offset(tid,2); % Fixation coordinates y (with potential error)
            error1(1) = expsetup.stim.esetup_fix_size_drift(tid,4) * expsetup.screen.deg2pix;
        else % After drift correction or if no drift correction is done
            % Target 1 - fixation position
            [x,y]=RectCenter(fixation_rect);
            x1_target(1) = x + expsetup.stim.esetup_fixation_drift_offset(tid,1); % Fixation coordinates x (with potential error)
            y1_target(1) = y + expsetup.stim.esetup_fixation_drift_offset(tid,2); % Fixation coordinates y (with potential error)
            error1(1) = expsetup.stim.esetup_fix_size_eyetrack(tid,4) * expsetup.screen.deg2pix;
        end
        
        % Data points with recorded saccade position
        x1_recorded = expsetup.stim.eframes_eye_x{tid}(c1_frame_index1, 1);
        y1_recorded = expsetup.stim.eframes_eye_y{tid}(c1_frame_index1, 1);
        
        % Which target eye went to?
        tsel1 = runexp_check_eye_target_v11 (x1_recorded, y1_recorded, x1_target, y1_target, error1);
        
        % Save it into matrix
        if length(tsel1)==1
            expsetup.stim.eframes_eye_target{tid}(c1_frame_index1, 1) = tsel1;
        end
    end
    
    
    %============================
    % Part 1: determine whether fixation was acquired at all
    %===========================
    
    if isnan(expsetup.stim.edata_fixation_acquired(tid,1))
        
        % Time
        timer1_now = expsetup.stim.eframes_time{tid}(c1_frame_index1, 1);
        %
        timer1_start = expsetup.stim.edata_fixation_on(tid,1);
        %
        timer1_duration = expsetup.stim.esetup_fixation_acquire_duration(tid,1);
        
        if expsetup.general.recordeyes==1
            if timer1_now - timer1_start < timer1_duration % Record an error
                if expsetup.stim.eframes_eye_target{tid}(c1_frame_index1, 1) == 1
                    expsetup.stim.edata_fixation_acquired(tid,1) = timer1_now;
                    Eyelink('Message', 'fixation_acquired');
                end
            elseif timer1_now - timer1_start >= timer1_duration % Record an error
                expsetup.stim.edata_error_code{tid} = 'fixation not acquired in time';
            end
        elseif expsetup.general.recordeyes==0
            if timer1_now - timer1_start >= timer1_duration % Record an error
                expsetup.stim.edata_fixation_acquired(tid,1) = timer1_now;
            end
        end
          
    end
    
        
    %============================
    % Part 2: determine whether drift fixation was maintained
    %===========================
    
    if expsetup.stim.esetup_fixation_drift_correction_on(tid,1)==1 && ~isnan(expsetup.stim.edata_fixation_acquired(tid,1)) && isnan(expsetup.stim.edata_fixation_drift_maintained(tid,1))
        
        % Time
        timer1_now = expsetup.stim.eframes_time{tid}(c1_frame_index1, 1);
        %
        timer1_start = expsetup.stim.edata_fixation_acquired(tid,1) + expsetup.stim.fixation_drift_maintain_minimum;
        %
        timer1_duration = expsetup.stim.edata_fixation_acquired(tid,1) + expsetup.stim.fixation_drift_maintain_maximum;
        
        if expsetup.general.recordeyes==1
            if timer1_now - timer1_start < timer1_duration % Record an error
                if expsetup.stim.eframes_eye_target{tid}(c1_frame_index1, 1) ~= 1
                    expsetup.stim.edata_error_code{tid} = 'broke fixation before drift';
                end
            elseif timer1_now - timer1_start >= timer1_duration % Record an error
                expsetup.stim.edata_fixation_drift_maintained(tid,1) = timer1_now;
                Eyelink('Message', 'fixation_drift_maintained');
            end
        elseif expsetup.general.recordeyes==0
            if timer1_now - timer1_start >= timer1_duration % Record an error
                expsetup.stim.edata_fixation_drift_maintained(tid,1) = timer1_now;
            end
        end
        
    end
    
    % Deterine the error to be updated for drift correction
    if expsetup.general.recordeyes == 1 && ~isnan(expsetup.stim.edata_fixation_drift_maintained(tid,1)) && isnan(expsetup.stim.edata_fixation_drift_calculated(tid,1))
        a = expsetup.stim.fixation_drift_maintain_maximum - expsetup.stim.fixation_drift_maintain_minimum;
        t1 = a/expsetup.screen.ifi;
        ind1 = (c1_frame_index1 - t1 + 1 : 1 : c1_frame_index1);
        if numel(ind1)>1
            % Data points with recorded saccade position
            x1 = expsetup.stim.eframes_eye_x(ind1,1);
            y1 = expsetup.stim.eframes_eye_y(ind1,1);
            % Determine average position
            x1 = mean(x1);
            y1 = mean(y1);
            [fix_xc,fix_yc]=RectCenter(fixation_rect);
            expsetup.stim.esetup_fixation_drift_offset(tid,1) =  x1 - fix_xc;
            expsetup.stim.esetup_fixation_drift_offset(tid,2) =  y1 - fix_yc;
            expsetup.stim.edata_fixation_drift_calculated(tid,1) = 1;
        else
            expsetup.stim.esetup_fixation_drift_offset(tid,1) =  0;
            expsetup.stim.esetup_fixation_drift_offset(tid,2) =  0;
            expsetup.stim.edata_fixation_drift_calculated(tid,1) = 1;
        end
    end
    
   
    %===================
    % Part 3: Determine whether fixation was maintained
    %===================
    
    if ~isnan(expsetup.stim.edata_fixation_acquired(tid,1)) && isnan(expsetup.stim.edata_fixation_maintained(tid,1))
        
        % Time
        timer1_now = expsetup.stim.eframes_time{tid}(c1_frame_index1, 1);
        %
        timer1_start = expsetup.stim.edata_fixation_acquired(tid,1);
        %
        timer1_duration = expsetup.stim.esetup_fixation_maintain_duration(tid,1);
        
        if expsetup.general.recordeyes==1
            if timer1_now - timer1_start < timer1_duration % Record an error
                if expsetup.stim.eframes_eye_target{tid}(c1_frame_index1, 1) ~= 1
                    expsetup.stim.edata_error_code{tid} = 'broke fixation';
                end
            elseif timer1_now - timer1_start >= timer1_duration % Record an error
                expsetup.stim.edata_fixation_maintained(tid,1) = timer1_now;
                Eyelink('Message', 'fixation_maintained');
            end
        elseif expsetup.general.recordeyes==0
            if timer1_now - timer1_start >= timer1_duration % Record an error
                expsetup.stim.edata_fixation_maintained(tid,1) = timer1_now;
            end
        end
    end
    
    %% Check button presses
    
    [keyIsDown, keyTime, keyCode] = KbCheck;
    char = KbName(keyCode);
    % Catch potential press of two buttons
    if iscell(char)
        char=char{1};
    end
    
    % Record what kind of button was pressed
    if strcmp(char,'c') || strcmp(char,'p') || strcmp(char,'r') || strcmp(char, expsetup.general.quit_key)
        expsetup.stim.edata_error_code{tid} = 'experimenter terminated the trial';
    end

    
    %% Correct trial?
    
    % Determine whether trial loop is to be finished
    if ~isnan(expsetup.stim.edata_fixation_maintained(tid,1))
        expsetup.stim.edata_error_code{tid} = 'correct';
    end
    
    %% If its the last frame, save few missing parameters & terminate
    
    % If run out of frames  - end trial (should never happen)
    if c1_frame_index1==size(expsetup.stim.eframes_time{tid},1)
        loop_over = 1;
    end
    
    % If error - end trial
    if ~isnan(expsetup.stim.edata_error_code{tid})
        loop_over = 1;
    end
    
    
end

% Reduce trialmat in size (save only frames that are used)
if c1_frame_index1+1<size(expsetup.stim.eframes_time{tid},1)
    f1 = fieldnames(expsetup.stim);
    ind = strncmp(f1,'eframes', 7);
    for i=1:numel(ind)
        if ind(i)==1
            if iscell(expsetup.stim.(f1{i}))
                expsetup.stim.(f1{i}){tid}(c1_frame_index1+1:end,:,:) = [];
            end
        end
    end
end

% Clear off all the screens
Screen('FillRect', window, expsetup.stim.background_color);
if expsetup.general.record_plexon==1
    Screen('FillRect', window, [0, 0, 0], ph_rect, 1);
end
[~, time_current, ~]=Screen('Flip', window);

% Plexon message that display is cleared
% Individual event mode (EVENT 2)
if expsetup.general.record_plexon==1
    a1 = zeros(1,expsetup.ni_daq.digital_channel_total);
    a1_s = expsetup.general.plex_event_end; % Channel number used for events
    a1(a1_s)=1;
    outputSingleScan(ni.session_plexon_events,a1);
    a1 = zeros(1,expsetup.ni_daq.digital_channel_total);
    outputSingleScan(ni.session_plexon_events,a1);
end

% Save eyelink and psychtoolbox events
if expsetup.general.recordeyes==1
    Eyelink('Message', 'fixation_off');
end
expsetup.stim.edata_fixation_off(tid,1) = time_current;

% Save eyelink and psychtoolbox events
if expsetup.general.recordeyes==1
    Eyelink('Message', 'loop_over');
end
expsetup.stim.edata_loop_over(tid,1) = time_current;

% Clear eyelink screen
if expsetup.general.recordeyes==1
    Eyelink('command','clear_screen 0');
end

% Print trial duration
t1 = expsetup.stim.edata_loop_over(tid,1);
t0 = expsetup.stim.edata_first_display(tid,1);
fprintf('Trial duration (from first display to reward) was %i ms \n', round((t1-t0)*1000))
fprintf('Trial evaluation: %s\n', expsetup.stim.edata_error_code{tid})


%% Online performance tracking

% Check whether trial is counted towards online performance tracking. In
% some cases correct trials can be discounted.

if expsetup.stim.esetup_exp_version(tid,1) ==1
    if strcmp(expsetup.stim.edata_error_code{tid}, 'correct')
        expsetup.stim.edata_trial_online_counter(tid,1) = 1;
    elseif strcmp(expsetup.stim.edata_error_code{tid}, 'broke fixation') || strcmp(expsetup.stim.edata_error_code{tid}, 'broke fixation before drift')
        expsetup.stim.edata_trial_online_counter(tid,1) = 2;
    end
end


%% If fixation was maintained, start reward

% Prepare reward signal
if expsetup.general.reward_on==1
    if strcmp(expsetup.stim.edata_error_code{tid}, 'correct') || strcmp(char, 'space') || strcmp(char, 'r')
        % Continous reward
        reward_duration = expsetup.stim.reward_size_ms;
        signal1 = linspace(expsetup.ni_daq.reward_voltage, expsetup.ni_daq.reward_voltage, reward_duration)';
        signal1 = [0; signal1; 0; 0; 0; 0; 0];
        queueOutputData(ni.session_reward, signal1);        
    end
end

if expsetup.general.reward_on == 1
    if strcmp(expsetup.stim.edata_error_code{tid}, 'correct') || strcmp(char, 'space') || strcmp(char, 'r')
        ni.session_reward.startForeground;
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'reward_on');
        end
        expsetup.stim.edata_reward_on(tid) = GetSecs;
        % Save how much reward was given
        expsetup.stim.edata_reward_size_ms(tid,1)=expsetup.stim.reward_size_ms;
        expsetup.stim.edata_reward_size_ml(tid,1)=expsetup.stim.reward_size_ml;
    else
        % Save how much reward was given
        expsetup.stim.edata_reward_size_ms(tid,1)=0;
        expsetup.stim.edata_reward_size_ml(tid,1)=0;
    end
end


%% Inter-trial interval & possibility to add extra reward

timer1_now = GetSecs;
time_start = GetSecs;
if ~isnan(expsetup.stim.edata_reward_on(tid)) 
    trial_duration = expsetup.stim.trial_dur_intertrial;
else % Error trials
    trial_duration = expsetup.stim.trial_dur_intertrial_error;
end

if strcmp(char,'x') || strcmp(char,'r')
    endloop_skip = 1;
else
    endloop_skip = 0;
end

while endloop_skip == 0;
    
    % Record what kind of button was pressed
    [keyIsDown,timeSecs,keyCode] = KbCheck;
    char = KbName(keyCode);
    % Catch potential press of two buttons
    if iscell(char)
        char=char{1};
    end
    
    % Give reward
    if (strcmp(char,'space') || strcmp(char,'r'))
        
        % Prepare reward signal
        if expsetup.general.reward_on==1
            % Continous reward
            reward_duration = expsetup.stim.reward_size_ms;
            signal1 = linspace(expsetup.ni_daq.reward_voltage, expsetup.ni_daq.reward_voltage, reward_duration)';
            signal1 = [0; signal1; 0; 0; 0; 0; 0];
            queueOutputData(ni.session_reward, signal1);
        end
        
        if expsetup.general.reward_on == 1
            ni.session_reward.startForeground;
            if expsetup.general.recordeyes==1
                Eyelink('Message', 'reward_on');
            end
            expsetup.stim.edata_reward_on(tid) = GetSecs;
            % Save how much reward was given
            expsetup.stim.edata_reward_size_ms(tid,1)=expsetup.stim.reward_size_ms;
            expsetup.stim.edata_reward_size_ml(tid,1)=expsetup.stim.reward_size_ml;
        end
        
        % End loop
        endloop_skip=1;
        
    end
    
    % Check time & quit loop
    timer1_now = GetSecs;
    if timer1_now - time_start >= trial_duration
        endloop_skip=1;
    end
    
end


%% Trigger new trial

Screen('FillRect', window, expsetup.stim.background_color);
Screen('Flip', window);


if expsetup.general.record_plexon == 0
    if ~strcmp(expsetup.stim.edata_error_code{tid}, 'correct') || sum(tid==1:expsetup.stim.plot_every_x_trial:10000)==1
        train_fix2_online_plot;
    end
end;


%% Stop experiment if too many errors in a row

if strcmp(expsetup.stim.edata_error_code{tid}, 'fixation not acquired in time') % Trial failed
    expsetup.stim.edata_trial_abort_counter(tid,1) = 1;
end

% Add pause if trials are not accurate
if tid>=expsetup.stim.trial_abort_counter
    ind1 = tid-expsetup.stim.trial_abort_counter+1:tid;
    s1 = expsetup.stim.edata_trial_abort_counter(ind1, 1)==1;
    if sum(s1) == expsetup.stim.trial_abort_counter
        if ~strcmp(char,expsetup.general.quit_key')
            char='x';
            % Over-write older trials
            expsetup.stim.edata_trial_abort_counter(ind1, q) = 2000;
        end
    end
end


%% STOP EYELINK RECORDING

if expsetup.general.recordeyes==1
    msg1=['TrialEnd ',num2str(tid)];
    Eyelink('Message', msg1);
    Eyelink('StopRecording');
end

fprintf('  \n')
