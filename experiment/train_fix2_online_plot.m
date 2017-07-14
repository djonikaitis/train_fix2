% Plot figures for visualising the data

save_plots=1;

% Graph properties
wlinegraph = 1; % Width of line for the graph
fontsz = 8; fontszlabel = 10;

color1(1,:,:) = [0.2, 0.8, 0.2]; 
color1(2,:,:) = [0.5, 0.5, 0.5]; 
color1(3,:,:) = [0.2, 0.2, 1]; 
color1(4,:,:) = [0.9, 0.8, 0.2]; 
color1(5,:,:) = [1, 0.3, 0.3]; 
color1(6,:,:) = [1, 0.7, 0.7];
color1(7,:,:) = [1, 0.7, 0.7]; 
color1(8,:,:) = [0.5, 0.5, 0.5];

color1(9,:,:) = [0.1, 0.1, 0.1]; % Spatial location
color1(10,:,:) = [0.8, 0.8, 0.8]; % Spatial location

close all
hfig = figure;

if expsetup.general.plexon_online_spikes == 1
    set(hfig, 'units', 'normalized', 'position', [0.1, 0.1, 0.7, 0.7]);
    fig_size = [0,0,9,9];
elseif expsetup.general.plexon_online_spikes == 0
    set(hfig, 'units', 'normalized', 'position', [0.1, 0.4, 0.7, 0.5]);
    fig_size = [0,0,7,5];
end


%% FIGURE 1
% Correct/error rates

hfig = subplot(2,3,1); hold on
train_fix2_online_plot_fig1


%% FIGURE 2
% Correct/errors over time

hfig = subplot(2,3,4); hold on
train_fix2_online_plot_fig2


%% FIGURE 3
% Eye position

if expsetup.general.recordeyes==1
    hfig = subplot(2,3,[2,3]); hold on
    train_fix2_online_plot_fig3
end

%% Figure 4
% Fixation durations

hfig = subplot(2,3,5); hold on
train_fix2_online_plot_fig4


%% Make sure figures are plotted

drawnow;


%% Save data for inspection


if save_plots == 0
    
    dir1 = [expsetup.general.directory_baseline_data, expsetup.general.expname, '/figures_online/', expsetup.general.subject_id, '/', expsetup.general.subject_filename, '/'];
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


