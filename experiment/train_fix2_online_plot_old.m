% Plot figures for visualising the data

% Graph properties
wlinegraph = 1; % Width of line for the graph
fontsz = 8; fontszlabel = 10;

color1(1,:,:) = [0.2, 0.2, 0.2]; % Correct trial
color1(2,:,:) = [0.6, 0.6, 1]; % Error 1 (fix not acquired)
color1(3,:,:) = [1, 0.7, 0.7]; % Error 2 (fix not maintained - drift)
color1(4,:,:) = [1, 0.55, 0.55]; % Error 3 (fix not maintained - minimum)
color1(5,:,:) = [1, 0.3, 0.3]; % Error 4 (fix broken)
color1(6,:,:) = [0.2, 1, 1]; % Error 5 (unknown)
color1(7,:,:) = [0.6, 0.6, 1]; % Error 6

close all
hfig = figure;
set(hfig, 'units', 'normalized', 'position', [0.2, 0.4, 0.6, 0.5]);

%===========================


%% FIGURE 1

% Error rates

trials_to_plot = 50; % How many trials to use for evaluation of errors/corrects

hfig = subplot(2,3,1);
hold on;

if tid<=trials_to_plot
    var1 = expsetup.stim.expmatrix(1:tid, em_data_reject);
elseif tid>trials_to_plot
    var1 = expsetup.stim.expmatrix(tid-(trials_to_plot-1):tid, em_data_reject);
end

% Bar positions
bnum = 5; % How many bars
barwdh = 0.05; spacewidth=0.3;
rngbar = [barwdh*bnum+barwdh*(bnum-1)*spacewidth]; % Bars plus spaces between them take that much space in total
rngbar = rngbar/2; % Position to both sides of the unit
xcoord = [1-rngbar:barwdh+barwdh*spacewidth:1+rngbar];

plotbins=xcoord;
set(gca,'XLim',[plotbins(1)-0.1 plotbins(end)+0.1]);

% Plot each bar
for i = 1:bnum
    
    % Plot bars
    if tid<=trials_to_plot-1
        h=bar(plotbins(i), sum(var1==i), barwdh); % Plot all trials
    else
        h=bar(plotbins(i), sum(var1==i)/trials_to_plot*100, barwdh); % Plot proportion
    end
    graphcond=i;
    set (h(end), 'LineWidth', wlinegraph, 'EdgeColor', color1(graphcond,:), 'FaceColor', color1(graphcond,:));
    
    % Legend, plotted on each bar
    if i==1
        text(plotbins(i), 3, 'Correct', 'Color', [1,0.6,0.6], 'FontSize', fontsz, 'HorizontalAlignment', 'left', 'Rotation', 90)
    elseif i==2
        text(plotbins(i), 3, 'No fix', 'Color', [0.2,0.2,0.2], 'FontSize', fontsz, 'HorizontalAlignment', 'left', 'Rotation', 90)
    elseif i==3
        text(plotbins(i), 3, 'Drift min missing', 'Color', [0.2,0.2,0.2], 'FontSize', fontsz, 'HorizontalAlignment', 'left', 'Rotation', 90)
    elseif i==4
        text(plotbins(i), 3, 'Fix broken', 'Color', [0.2,0.2,0.2], 'FontSize', fontsz, 'HorizontalAlignment', 'left', 'Rotation', 90)
    elseif i==5
        text(plotbins(i), 3, 'Unknown', 'Color', [0.2,0.2,0.2], 'FontSize', fontsz, 'HorizontalAlignment', 'left', 'Rotation', 90)
    end
end

% Figure settings
set(gca,'FontSize', fontsz);
if tid<=trials_to_plot/2
    set(gca,'YLim',[0,trials_to_plot/2+trials_to_plot*0.1]);
    ylabel ('Occurences (number)', 'FontSize', fontszlabel);
    set(gca,'YTick',0:5:trials_to_plot);
elseif tid > trials_to_plot/2 && tid<=trials_to_plot-1
    set(gca,'YLim',[0,tid+trials_to_plot*0.1]);
    ylabel ('Occurences (number)', 'FontSize', fontszlabel);
    set(gca,'YTick',0:10:trials_to_plot);
elseif tid>trials_to_plot
    set(gca,'YLim',[0,115]) % Max percent
    ylabel ('Occurences (%)', 'FontSize', fontszlabel);
    set(gca,'YTick',25:25:100);
end
xlabel ('Trial type', 'FontSize', fontszlabel);
set(gca,'XTickLabel', ' ', 'FontSize', fontszlabel)

% Add total amount of reward and trials correct
if tid>trials_to_plot
    if expsetup.general.reward_on>0
        reward_given = nansum(expsetup.stim.expmatrix(:, em_data_reward_size_ml));
        a =  sprintf ('\nTotal reward: %i ml\n', round(reward_given));
        text(plotbins(end),110, a, 'Color', [0.2,0.2,0.2], 'FontSize', fontsz, 'HorizontalAlignment', 'right');
    end
    index1 = expsetup.stim.expmatrix(:, em_data_reject) == 1;
    a = sprintf ('\nCorrect trials: %i \n', sum(index1));
    text(plotbins(end), 100, a, 'Color', [0.2,0.2, 0.2], 'FontSize', fontsz, 'HorizontalAlignment', 'right');
end

% =============================

%% FIGURE 2

% Time analysis of errors

trials_to_plot = 25; % Window size of the moving average

if tid<=trials_to_plot
    
    hfig = subplot(2,3,4);
    hold on;
    
    set(gca,'FontSize', fontsz);
    text(0, 0, ['Min. trials needed - ', num2str(trials_to_plot)],...
        'Color', [0.1,0.1,0.1], 'FontSize', fontsz, 'HorizontalAlignment', 'center')
    set(gca,'YLim',[-5,5]);
    set(gca,'XLim', [-19, 19]);
    set(gca,'YTick', [-10,10]);
    set(gca,'XTick', [-20,20]);
    
    
elseif tid>trials_to_plot% Plot data
    
    hfig = subplot(2,3,4);
    hold on;
    
    intervalbins = [trials_to_plot+1:1:tid];
    temp1=NaN(4,length(intervalbins));
    
    for j=1:length(intervalbins)
        
        % Correct trials
        index1 = expsetup.stim.expmatrix(intervalbins(j)-trials_to_plot:intervalbins(j),em_data_reject)==1;
        temp1(1,j)= sum(index1);
        % Aborted trials
        index1 = expsetup.stim.expmatrix(intervalbins(j)-trials_to_plot:intervalbins(j),em_data_reject)==2;
        temp1(2,j)= sum(index1);
        % Fixation not maintained
        index1 = expsetup.stim.expmatrix(intervalbins(j)-trials_to_plot:intervalbins(j),em_data_reject)==3 | ...
            expsetup.stim.expmatrix(intervalbins(j)-trials_to_plot:intervalbins(j),em_data_reject)==4;
        temp1(3,j)= sum(index1);
        % Other errors
        index1 = expsetup.stim.expmatrix(intervalbins(j)-trials_to_plot:intervalbins(j),em_data_reject)==5;
        temp1(4,j)= sum(index1);
        
    end
    
    temp1=temp1./trials_to_plot*100;
    
    % Calculate plotbins
    plot_bins = (intervalbins-intervalbins(end)-1).*-1;
    plot_bins = log((plot_bins)); % Calculate to log
    plot_bins = -1*plot_bins; % Revert the plotting direction (most recent trials to the right)
    
    % Plot each error as a line
    for i=1:4
        h = plot(plot_bins(:), temp1(i,:));
        if i==1
            graphcond=1;
        elseif i==2
            graphcond=2;
        elseif i==3
            graphcond=4;
        elseif i==4
            graphcond=6;
        end
        set (h(end), 'LineWidth', wlinegraph, 'Color', color1(graphcond,:))
    end
    
    % Legend
    text(-log(1), 145, 'Correct', 'Color', color1(1,:), 'FontSize', fontsz, 'HorizontalAlignment', 'right')
    text(-log(1), 130, 'Target not acquired', 'Color', color1(2,:), 'FontSize', fontsz, 'HorizontalAlignment', 'right')
    text(-log(1), 115, 'Fixation break', 'Color', color1(4,:), 'FontSize', fontsz, 'HorizontalAlignment', 'right')
    text(-log(1), 100, 'Other', 'Color', color1(6,:), 'FontSize', fontsz, 'HorizontalAlignment', 'right')
    
    % Figure settings
    set(gca,'FontSize', fontsz);
    set(gca,'YLim',[0,155])
    ylabel ('Occurences (%)', 'FontSize', fontszlabel);
    set(gca,'YTick',25:25:100);
    
    xlabel ('Trials', 'FontSize', fontszlabel);
    if tid<100
        a=[50,25,10,1];
    elseif tid<500
        a=[250,100,50,10,1];
    elseif tid<1000
        a=[500,100,10,1];
    else
        a=[1000,500,100,10,1];
    end
    set(gca,'XTick', -log(a));
    set(gca,'XTickLabel', -1*a, 'FontSize', fontszlabel)
    set(gca,'XLim', [-log(max((intervalbins-intervalbins(end)-2).*-2)), -log(0.5)])
    
end


% ==============================


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

%% Figure 4 - fixation durations

trials_to_plot = 5; % How many trials to use for evaluation of errors/corrects

if tid<=trials_to_plot
    
    hfig = subplot(2,3,5);
    hold on;
    
    set(gca,'FontSize', fontsz);
    text(0, 0, ['Min. trials needed - ', num2str(trials_to_plot)],...
        'Color', [0.1,0.1,0.1], 'FontSize', fontsz, 'HorizontalAlignment', 'center')
    set(gca,'YLim',[-5,5]);
    set(gca,'XLim', [-19, 19]);
    set(gca,'YTick', [-10,10]);
    set(gca,'XTick', [-20,20]);
    
    
elseif tid>trials_to_plot% Plot data
    
    hfig = subplot(2,3,5);
    hold on;
    
    plotbins = [-0.25:0.25:5];
    mat1 = zeros(1, length(plotbins)-1);
    mat2 = zeros(1, length(plotbins)-1);

    
    h=rectangle('Position', [-1, 0, 3, 105],...
            'EdgeColor', [0.95, 0.85, 0.85], 'FaceColor', [0.95, 0.85, 0.85], 'Curvature', 0, 'LineWidth', 1);
    
    % Select data
    index = expsetup.stim.expmatrix(:, em_data_reject)==1;
    duration1 = expsetup.stim.expmatrix(index, em_data_fixation_off) - expsetup.stim.expmatrix(index, em_data_fixation_acquired);
    
    for i=1:length(plotbins)-1
        index = duration1>=plotbins(i) & duration1<plotbins(i+1);
        mat1(1,i) = sum(index);
        pbins(1,i) = (plotbins(i) + plotbins(i+1))/2;
    end
    
    
    % Select data
    index = expsetup.stim.expmatrix(:, em_data_reject)==3 | ...
        expsetup.stim.expmatrix(:, em_data_reject)==4;
    duration1 = expsetup.stim.expmatrix(index, em_data_fixation_off) - expsetup.stim.expmatrix(index, em_data_fixation_acquired);
    
    for i=1:length(plotbins)-1
        index = duration1>=plotbins(i) & duration1<plotbins(i+1);
        mat2(1,i) = sum(index);
        pbins(1,i) = (plotbins(i) + plotbins(i+1))/2;
    end
    
   total1 = sum(mat1) + sum(mat2);
    if total1>0
        mat1 = mat1./total1;
        mat1 = mat1*100;
        h=plot(pbins, mat1, 'Color', color1(1,:), 'LineWidth', 1); % Plot eye position in space and time
    end
    
    if total1>0
        mat2 = mat2./total1;
        mat2 = mat2*100;
        h=plot(pbins, mat2, 'Color', color1(5,:), 'LineWidth', 1); % Plot eye position in space and time
    end
    
    
    % Figure settings
    set(gca,'FontSize', fontsz);
    set(gca,'YLim',[0, 70])
    ylabel ('Occurences (%)', 'FontSize', fontszlabel);
    set(gca,'YTick',[0:25:75]);
    
    xlabel ('Fixation duration, seconds', 'FontSize', fontszlabel);
    set(gca,'XTick', [0, 1, 2, 3, 4], 'FontSize', fontszlabel);
    set(gca,'XLim', [-0.5, 5]);
    
    % Legend
    text(0, 65, 'Correct', 'Color', color1(1,:), 'FontSize', fontsz, 'HorizontalAlignment', 'left')
    text(0, 58, 'Fixation break', 'Color', color1(5,:), 'FontSize', fontsz, 'HorizontalAlignment', 'left')
    
end

%% Make sure figures are plotted

drawnow;
