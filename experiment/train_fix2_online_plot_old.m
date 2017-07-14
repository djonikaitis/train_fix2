


%% FIGURE 3

% Eye position

if expsetup.general.recordeyes==1
    hfig = subplot(2,3,[2,3]);
    hold on;
    
    % Data to be used
    sx2=trialmat(:, 1:3); % Reset time to 0
    sx2(:,1)=sx2(:,1)-sx2(1,1);
    
    %================
    % Plot fixation BEFORE drift correction
    %===============
    
    % Amplitude vector
    x1=fix_xc-dispcenter(1); y1=fix_yc-dispcenter(2);
    x1=x1/deg2pix; y1=y1/deg2pix; % Convert to degrees
    eyecoord1 = sqrt(x1.^2 + y1.^2); % Calculate amplitude of the eye position
    if x1<0 % Leftward stimuli
        radius1 = eyecoord1*-1;
    elseif x1>=0 % Rightward stimuli
        radius1 = eyecoord1;
    end
    if expsetup.stim.fixation_drift_correction_on==1
        saccwindow = expsetup.stim.fixation_accuracy_drift;
    else
        saccwindow = expsetup.stim.expmatrix(tid,em_fixation_accuracy);
    end
    
    %====================
    % Plot fixation before it was acquired
    starttime1 = 0;
    if ~isnan(expsetup.stim.expmatrix(tid,em_data_fixation_acquired))
        trialdur = expsetup.stim.expmatrix(tid,em_data_fixation_acquired) - expsetup.stim.expmatrix(tid,em_data_fixation_on);
        trialdur = trialdur*1000;
    else
        trialdur = expsetup.stim.expmatrix(tid,em_data_fixation_off)-expsetup.stim.expmatrix(tid,em_data_fixation_on); % Convert to seconds
        trialdur = trialdur*1000;
    end
    h=rectangle('Position', [starttime1, radius1-saccwindow, trialdur, saccwindow*2],...
        'EdgeColor', [0.8, 0.8, 0.8],  'FaceColor', [0.8, 0.8, 0.8], 'Curvature', 0, 'LineWidth', 1);
    
    %====================
    % Plot fixation after it was acquired but before drift correction is done
    if ~isnan(expsetup.stim.expmatrix(tid,em_data_drift_maintained))
        starttime1 = expsetup.stim.expmatrix(tid,em_data_fixation_acquired) - expsetup.stim.expmatrix(tid,em_data_fixation_on);
        starttime1 = starttime1*1000;
        trialdur = expsetup.stim.expmatrix(tid,em_data_drift_maintained) - expsetup.stim.expmatrix(tid,em_data_fixation_acquired);
        trialdur = trialdur*1000;
        h=rectangle('Position', [starttime1, radius1-saccwindow, trialdur, saccwindow*2],...
            'EdgeColor', [0.65, 0.65, 0.65],  'FaceColor', [0.65, 0.65, 0.65], 'Curvature', 0, 'LineWidth', 1);
    end
    
    
    %================
    % Plot fixation AFTER drift correction
    %===============
    
    % Amplitude vector
    x1=fix_xc; y1=fix_yc;
    % x1=x1+expsetup.stim.expmatrix(tid,em_data_drift_x1); % Add drift error
    % y1=y1+expsetup.stim.expmatrix(tid,em_data_drift_y1); % Add drift error
    x1=x1-dispcenter(1); y1=y1-dispcenter(2);
    x1=x1/deg2pix; y1=y1/deg2pix;
    eyecoord1 = sqrt(x1.^2 + y1.^2); % Calculate amplitude of the eye position
    if x1<0 % Leftward stimuli
        radius1 = eyecoord1*-1;
    elseif x1>=0 % Rightward stimuli
        radius1 = eyecoord1;
    end
    saccwindow = expsetup.stim.expmatrix(tid,em_fixation_accuracy);
    
    
    %======================
    % Plot fixation target before fixation is broken
    starttime1 = expsetup.stim.expmatrix(tid,em_data_fixation_acquired) - expsetup.stim.expmatrix(tid,em_data_fixation_on);
    starttime1 = starttime1*1000;
    if expsetup.stim.expmatrix(tid,em_data_reject)==4
        trialdur = expsetup.stim.expmatrix(tid,em_data_fixation_off) - expsetup.stim.expmatrix(tid,em_data_fixation_acquired);
        trialdur = trialdur*1000;
        h=rectangle('Position', [starttime1, radius1-saccwindow, trialdur, saccwindow*2],...
            'EdgeColor', [1, 0.8, 0.8],  'FaceColor', [1, 0.8, 0.8], 'Curvature', 0, 'LineWidth', 1);
    elseif expsetup.stim.expmatrix(tid,em_data_reject)==1
        trialdur = expsetup.stim.expmatrix(tid,em_data_fixation_off) - expsetup.stim.expmatrix(tid,em_data_fixation_acquired);
        trialdur = trialdur*1000;
        h=rectangle('Position', [starttime1, radius1-saccwindow, trialdur, saccwindow*2],...
            'EdgeColor', [1, 0.8, 0.8],  'FaceColor', [1, 0.8, 0.8], 'Curvature', 0, 'LineWidth', 1);
    end
    
    
    % Plot reward timing
    if ~isnan(expsetup.stim.expmatrix(tid,em_data_reward_on))
        yc = 0;
        saccwindow = 1;
        starttime1 = (expsetup.stim.expmatrix(tid,em_data_reward_on) - expsetup.stim.expmatrix(tid,em_data_fixation_on));
        starttime1 = starttime1*1000;
        trialdur = expsetup.stim.expmatrix(tid,em_reward_size_ms);
        h=rectangle('Position', [starttime1, yc-saccwindow, trialdur, saccwindow],...
            'EdgeColor', [0.2, 0.2, 0.5], 'FaceColor', 'none', 'Curvature', 0, 'LineWidth', 1);
        text(starttime1, 2, 'Reward', 'Color', [0.2, 0.2, 0.5],  'FontSize', fontszlabel, 'HorizontalAlignment', 'left')
    end
    
    %==============
    % Plot eye position data
    if length(sx2)>1
        ind=sx2(:,2)==0;
        sx2(ind,2)=NaN; sx2(ind,3)=NaN;
        x1=sx2(:,2)-dispcenter(1); y1=sx2(:,3)-dispcenter(2);
        x1=x1./deg2pix; y1=y1./deg2pix;
        index=x1<0;
        eyecoord1 = sqrt(x1.^2 + y1.^2); % Calculate amplitude of the eye position
        eyecoord1(index)=-eyecoord1(index);
        h=plot(sx2(:,1)*1000, eyecoord1, 'k', 'LineWidth', 1); % Plot eye position in space and time
    end
    
    
    %=================
    % Fig settings
    
    if expsetup.stim.expmatrix(tid, em_data_reject)==1
        title('OK', 'FontSize', fontszlabel);
    elseif  expsetup.stim.expmatrix(tid, em_data_reject)==5
        title('Unknown', 'FontSize', fontszlabel);
    else
        try
            title(error_message, 'FontSize', fontszlabel);
        end
    end
    
    set (gca,'FontSize', fontsz);
    set(gca,'XLim',[-250,(expsetup.stim.expmatrix(tid,em_data_last_display) - expsetup.stim.expmatrix(tid,em_data_first_display))*1000+250]);
    
    % Y labels
    x1=fix_xc-dispcenter(1); y1=fix_yc-dispcenter(2);
    x1=x1./deg2pix; y1=y1./deg2pix;
    eyecoord1 = sqrt(x1.^2 + y1.^2); % Calculate amplitude of the eye position
    eyecoord1=round(eyecoord1);
    if eyecoord1~=0 % For peripheral targets
        set(gca,'YTick',[-eyecoord1, 0, eyecoord1]);
    else % For central targets
        set(gca,'YTick',[eyecoord1-expsetup.stim.expmatrix(tid,em_fixation_accuracy), 0, eyecoord1+expsetup.stim.expmatrix(tid,em_fixation_accuracy)]);
    end
    set(gca,'YLim',[-eyecoord1-expsetup.stim.expmatrix(tid,em_fixation_accuracy)-2, eyecoord1+expsetup.stim.expmatrix(tid,em_fixation_accuracy)+2]);
    
    % X-tick labels
    if ~isnan(expsetup.stim.expmatrix(tid,em_data_fixation_acquired)) && ...
            (expsetup.stim.expmatrix(tid,em_data_fixation_acquired) - expsetup.stim.expmatrix(tid,em_data_fixation_on))>0
        set(gca,'XTick', [0, ...
            round((expsetup.stim.expmatrix(tid,em_data_fixation_acquired) - expsetup.stim.expmatrix(tid,em_data_fixation_on))*1000), ...
            round((expsetup.stim.expmatrix(tid,em_data_fixation_off) - expsetup.stim.expmatrix(tid,em_data_fixation_on))*1000)])
    elseif ~isnan(expsetup.stim.expmatrix(tid,em_data_fixation_off)) && ...
            ~isnan(expsetup.stim.expmatrix(tid,em_data_fixation_on))
        set(gca,'XTick', [0, ...
            round((expsetup.stim.expmatrix(tid,em_data_fixation_off) - expsetup.stim.expmatrix(tid,em_data_fixation_on))*1000)])
    end
    xlabel ('Time', 'FontSize', fontszlabel)
    ylabel ('Gaze position', 'FontSize', fontszlabel)
end



%% Make sure figures are plotted

drawnow;
