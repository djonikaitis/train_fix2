% Plot figures for visualising the data

debug1=0;

% Graph properties
wlinegraph = 1; % Width of line for the graph
fontsz = 8; fontszlabel = 10;

color1(1,:,:) = [0.2, 0.2, 0.2]; % Correct trial
color1(2,:,:) = [0.2, 0.2, 1]; % Error 1 - fix not acquired
color1(3,:,:) = [0.2, 0.2, 1]; % Error 2 - drift not maintained
color1(4,:,:) = [0.9, 0.8, 0.2]; % Error 3 - fix broken
color1(5,:,:) = [1, 0.3, 0.3]; % Error 4 - Looked at wrong target
color1(6,:,:) = [1, 0.7, 0.7]; % Error 5 - Saccade not initiated error
color1(7,:,:) = [1, 0.7, 0.7]; % Error 6 - left saccade target
color1(8,:,:) = [0.5, 0.5, 0.5]; % Error 99 - Unknown error

color1(9,:,:) = [0.1, 0.1, 0.1]; % Spatial location
color1(10,:,:) = [0.8, 0.8, 0.8]; % Spatial location

close all
hfig = figure;

if expsetup.general.plexon_online_spikes == 1
    set(hfig, 'units', 'normalized', 'position', [0.1, 0.1, 0.7, 0.7]);
    fig_size = [0,0,9,9];
elseif expsetup.general.plexon_online_spikes == 0
    set(hfig, 'units', 'normalized', 'position', [0.1, 0.4, 0.8, 0.25]);
    fig_size = [0,0,10,3];
end


%% For debugging purposes

if debug1==1
    
    % Get spikes for current trial
    sp_struct = struct;
    f1 = fieldnames(spike_online_save);
    for i = 1:numel(f1)
        sp_struct.(f1{i}) = spike_online_save(tid).(f1{i});
    end
    
    % Get trial matrix for current trial
    trialmat = expsetup.stim.trialmatrix{tid};
end

%% Determine channel to be plotted in this analysis

if expsetup.general.plexon_online_spikes == 1
    num_ch1 = expsetup.general.plex_num_act_channels;
    % Determine which channel to plot
    if num_ch1==1
        sp_struct.ch1 = 1;
    elseif num_ch1>1
        a = randperm(numel(num_ch1));
        sp_struct.ch1 = a(1);
    end
end

%% FIGURE 1

% Correct/error rates

if expsetup.general.plexon_online_spikes == 1
    hfig = subplot(3,4,1); hold on
elseif expsetup.general.plexon_online_spikes == 0
    hfig = subplot(1,4,1); hold on
end

look5_online_plot_fig1


%% FIGURE 2

% Correct/errors over time

if expsetup.general.plexon_online_spikes == 1
    hfig = subplot(3,4,2); hold on
elseif expsetup.general.plexon_online_spikes == 0
    hfig = subplot(1,4,2); hold on
end

look5_online_plot_fig2


%% FIGURE 3

% Eye position

if expsetup.general.recordeyes==1
    
    if expsetup.general.plexon_online_spikes == 1
        hfig = subplot(3,4,[3,4]); hold on
    elseif expsetup.general.plexon_online_spikes == 0
        hfig = subplot(1,4,[3,4]); hold on
    end
    
    look5_online_plot_fig3
end

%% Figure 4

% Raw firing rate relative to texture onset

if expsetup.general.plexon_online_spikes==1
    hfig = subplot(3,4,[5,6]); hold on
    plot_var1 = 'texture';
    look5_online_plot_fig4
end

%% FIGURE 6

% Firing rate relative to memory onset

if expsetup.general.plexon_online_spikes==1
    hfig = subplot(3,4,[9,10]); hold on
    plot_var1 = 'memory';
    look5_online_plot_fig4
end


%% Figure 5

% Raw firing rate

if expsetup.general.plexon_online_spikes==1
    hfig = subplot(3,4,[7,8]); hold on
    look5_online_plot_fig5
end




%% Make sure figures are plotted

drawnow;

%% Save data for inspection


if debug1 == 0
    if expsetup.general.plexon_online_spikes==1
        
        dir1 = [expsetup.general.directory_baseline_data, expsetup.general.expname, '/figures_plex_online/', expsetup.general.subject_id, '/', expsetup.general.subject_filename, '/'];
        if ~isdir (dir1)
            mkdir(dir1)
        end
        file_name = [dir1, 'trial_' num2str(tid), '_channel_', num2str(sp_struct.ch1)];
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'inches');
        set(gcf, 'PaperPosition', fig_size);
        set(gcf, 'PaperSize', [fig_size(3), fig_size(4)])
        print(file_name, '-dpdf');
        
    end
end


