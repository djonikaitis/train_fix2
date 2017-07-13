% Prepare matrix with spiking rates

% plot_var1 = 'texture';
% plot_var1 = 'memory';

fig_color = [9,10]; % Colors used for the figure

% Select appropriate interval for plottings
time_step = 50;
bin_length = 100;

% Select time to plot relative to
if strcmp(plot_var1, 'texture')
    int_bins = [-100:time_step:500];
    dat1 = expsetup.stim.expmatrix(tid,em_data_texture_on);
elseif strcmp(plot_var1, 'memory')
    int_bins = [-250:time_step:1000];
    dat1 = expsetup.stim.expmatrix(tid,em_data_memory_on);
end

%===========
% Initialize data matrix
if tid == 1
    % Initialize empty matrix
    spikes_matrix_1 = NaN(1, length(int_bins), numel(sp_struct.spikes));
else
    % Copy matrix with appropriate name
    if strcmp(plot_var1, 'texture')
        spikes_matrix_1 = spikes_matrix_tx;
    elseif strcmp(plot_var1, 'memory')
        spikes_matrix_1 = spikes_matrix_me;
    end
    % Increase matrix size
    [a,b,c,d] = size(spikes_matrix_1);
    t1 = NaN(a+1, b, c, d);
    t1(1:a, 1:b, 1:c, 1:d) = spikes_matrix_1;
    spikes_matrix_1 = t1;
end

%==============
% Determine whether data was accepted
if expsetup.stim.expmatrix(tid,em_data_reject)==1
    cond1 = 1;
else
    cond1 = -1; % Rejected trial, not analysed
end

% Time in miliseconds;
if cond1>0
    cond1_t = (dat1 - expsetup.stim.expmatrix(tid,em_data_first_display)) * 1000;
end

% Take spikes and reset them relative to appropriate time
if cond1>0
    sp1 = cell(numel(sp_struct.spikes), 1);
    for i = 1:numel(sp_struct.spikes)
        sp1{i} = sp_struct.spikes{i} - sp_struct.trial_start;
        sp1{i} = sp1{i}/expsetup.general.plex_data_rate; % Convert from sampling rate to time
        sp1{i} = sp1{i}*1000; % Reset to miliseconds
        sp1{i} = sp1{i} - cond1_t; % Reset relative to condition time
    end
end

% Calculate spiking rates
if cond1>0
    for i = 1:numel(sp1)
        for j = 1:length(int_bins)
            
            % Index
            index = sp1{i} >= int_bins(j) & ...
                sp1{i} <= int_bins(j) + bin_length;
            % Save data
            if sum(index)==0
                spikes_matrix_1(tid,j,i)=0; % Save as zero spikes
            elseif sum(index)>0
                spikes_matrix_1(tid,j,i) = sum(index) * (1000/bin_length); % Save spikes converted to firing rate
            end
        end
    end
end

% Initialize pbins
pbins=int_bins+bin_length/2;

% Save matrix for use across trials
if strcmp(plot_var1, 'texture')
    spikes_matrix_tx = spikes_matrix_1;
elseif strcmp(plot_var1, 'memory')
    spikes_matrix_me = spikes_matrix_1;
end


%% Select conditions


if strcmp(plot_var1, 'texture')
    
    %=============
    % Plot texture
    %=============
    
    legend1_values = cell(1);
    
    % Create condition matrix
    expcond = NaN(1,numel(expsetup.stim.expmatrix(:,em_data_reject)));
    ind1 = expsetup.stim.expmatrix(:,em_data_reject)==1 & ...
        expsetup.stim.expmatrix(:,em_background_texture_on)==1;
    expcond(ind1) = 1;
    legend1_values{1} = sprintf('Texture');
    
    % Create condition matrix
    ind1 = expsetup.stim.expmatrix(:,em_data_reject)==1 & ...
        expsetup.stim.expmatrix(:,em_background_texture_on)==0;
    expcond(ind1) = 2;
    legend1_values{2} = sprintf('No texture');
    
elseif strcmp(plot_var1, 'memory')
    
    %==========
    % Plot locations
    %==========
    
    % Get all coordinates
    m0 = [expsetup.stim.expmatrix(:,em_target_coord1), expsetup.stim.expmatrix(:,em_target_coord2)];
    m1 = unique(m0, 'rows');
    
    % Create legend
    [th,radius1] = cart2pol(m1(:,1), m1(:,2));
    theta = (th*180)/pi;
    radius1_normalized = radius1./max(radius1);
    legend1_values = cell(1);
    for i = 1:numel(theta)
        legend1_values{i} = sprintf('arc %.0f, dist %.1f', theta(i), radius1(i));
    end
    
    % Create condition matrix
    expcond = NaN(1,numel(expsetup.stim.expmatrix(:,em_data_reject)));
    for i = 1:numel(theta)
        ind1 = expsetup.stim.expmatrix(:,em_data_reject)==1 & ...
            expsetup.stim.expmatrix(:,em_background_texture_on)==1 & ...
            expsetup.stim.expmatrix(:,em_blockcond) == expsetup.stim.expmatrix(tid,em_blockcond) & ...
            m0(:,1)==m1(i,1) & m0(:,2)==m1(i,2);
        expcond(ind1) = i;
    end
    
end

% In debugging mode important to take only trials up to current trial
expcond = expcond(1:tid);


%% Plot figure

%===========
% Calculate the colors

color1_line=[]; color1_error=[];

% Orientation colors are calculated as a range
col_min = color1(fig_color(1),:); % Orientation 0
col_max = color1(fig_color(2),:); % Orientation max
d1 = col_max-col_min;
stepsz = 1/(numel(legend1_values)-1);
for i=1:numel(legend1_values)
    color1_line(i,:)=col_min + (d1*stepsz)*(i-1);
end

% Color of the error bars
for i=1:size(color1_line,1)
    d1 = 1-color1_line(i,:);
    color1_error(i,:)=color1_line(i,:)+d1.*0.5;
end

%===============
% Plot error bars
for k = 1:max(expcond)
    
    % Select data
    ind = expcond==k;
    mat1 = spikes_matrix_1(ind,:,sp_struct.ch1);
    
    a1=[]; b1=[]; c1=[]; d1=[]; f1=[];
    for i=1:size(mat1,2)
        d1(:,i) = nanmean(mat1(:,i))-se(mat1(:,i)); % Standard error, lower bound (identical to upper one)
        f1(:,i) = nanmean(mat1(:,i))+se(mat1(:,i)); % Standard error, upper bound (identical to lower one)
    end
    
    if size(mat1,1)>1
        
        graphcond=k;
        
        xc1=pbins(1); % Min x, min y
        xc2=pbins(1); % Min x, max y
        xc3=pbins; % Upper bound of errors
        xc4=pbins(end); % Max x, max y
        xc5=pbins(end); % Max x, min y
        xc6=pbins;
        xc6=fliplr(xc6);
        
        yc1=d1(:,1); % Lower bound of errors
        yc2=f1(:,1); % upper bound of errors
        yc3=f1(:,:); % Upper bound of errors
        yc4=f1(:,end); % Upper bound of errors
        yc5=d1(:,end); % Lower bound of errors
        yc6=d1(:,:); % Lower bound of errors
        yc6=fliplr(yc6);
        
        
        h=fill([xc1,xc2,xc3,xc4, xc5, xc6],[yc1, yc2, yc3, yc4, yc5, yc6], [1 0.7 0.2],'linestyle','none');
        set (h(end), 'FaceColor', color1_error(graphcond,:,:),'linestyle', 'none', 'FaceAlpha', 1)
        
    end
end

%=============
% Plot means
for k = 1:max(expcond)
    
    % Select data
    ind = expcond==k;
    mat1 = spikes_matrix_1(ind,:,sp_struct.ch1);
    
    % Plot lines
    if size(mat1,1)>0
        if size(mat1,1)>1
            h=plot(pbins, nanmean(mat1(:,:,1)));
        elseif size(mat1,1)==1
            h=plot(pbins, mat1(1,:,1));
        end
        set (h(end), 'LineWidth', wlinegraph, 'Color', color1_line(k,:))
    end
    
end

%===============
% Figure setup

% Setup axis limits

if sum(isnan(expcond))<numel(expcond)
    
    h_1 = []; h_2 = [];
    
    for k = 1:max(expcond)
        
        % Select data
        ind = expcond==k;
        mat1 = spikes_matrix_1(ind,:,sp_struct.ch1);
        if size(mat1,1)>0
            h_1(k) = max(nanmean(mat1,1));
            h_2(k) = min(nanmean(mat1,1));
        elseif size(mat1,1)==1
            h_1(k) = max(mat1);
            h_2(k) = min(mat1);
        else
            h_1(k) = NaN;
            h_2(k) = NaN;
        end
        h_1 = removeNaN(max(h_1));
        h_2 = removeNaN(min(h_2));
        h_max=h_1+((h_1-h_2)*0.4); % Uper bound
        h_min=h_2-((h_1-h_2)*0.3); % Lower bound
    end
    
else
    h_max = 1;
    h_min = -1;
end

% Figure setup
set (gca,'FontSize', fontszlabel);

% X axis
set(gca,'XLim',[pbins(1)-49 pbins(end)+49]);
if strcmp(plot_var1, 'texture')
    xlabel ('Time from texture onset (ms)', 'FontSize', fontszlabel);
    set(gca,'XTick',[-200, 0, 100:100:500]);
elseif strcmp(plot_var1, 'memory')
    xlabel ('Time from memory onset (ms)', 'FontSize', fontszlabel);
    set(gca,'XTick',[-200, 0, 500:500:2000]);
end

% Y axis
if h_max>1
    
    % Set Y labels
    if h_max<50
        a=[0:10:50];
    elseif h_max<100
        a=[0:20:100];
    elseif h_max<250
        a=[0:50:250];
    elseif h_max<500
        a=[0:100:500];
    else
        a=[0:250:1500];
    end
    set(gca,'YTick', a);
    ylabel ('spikes/second', 'FontSize', fontszlabel);
    set(gca,'YLim', [h_min, h_max]);
    
else
    
    a = 0;
    set(gca,'YTick', a);
    ylabel ('spikes/second', 'FontSize', fontszlabel);
    
end


%============
% Add figure legend for texture condition

if strcmp(plot_var1, 'texture')
    
    d1 = h_max-h_min;
    x1 = [pbins(end), pbins(end)]; y1 = [h_max-d1*0.05, h_max-d1*0.15];
    % Plot legend text
    for k=1:length(legend1_values)
        text(x1(k), y1(k), legend1_values{k}, 'Color', color1_line(k,:),  'FontSize', fontszlabel, 'HorizontalAlignment', 'right')
    end
    
end

%===============
% Add exp condition name
if strcmp(plot_var1, 'memory')
    
    d1 = h_max-h_min;
    x1 = [pbins(end)]; y1 = [h_max-d1*0.05];
    k = 1;
    
    % Plot legend text
    if expsetup.stim.expmatrix(tid,em_blockcond) == 1
        l1 = sprintf('Look, channel %d', sp_struct.ch1);
    elseif expsetup.stim.expmatrix(tid,em_blockcond) == 2
        l1 = sprintf('Avoid, channel %d', sp_struct.ch1);
    elseif expsetup.stim.expmatrix(tid,em_blockcond) == 3
        l1 = sprintf('Control, channel %d', sp_struct.ch1);
    end
    text(x1(k), y1(k), l1, 'Color', color1_line(k,:),  'FontSize', fontszlabel, 'HorizontalAlignment', 'right')
    
end

%==================
% Add inset with locations

if strcmp(plot_var1, 'memory')
    
    axes('Position',[0.15,0.15,0.05,0.05])
    axis 'equal'
    set (gca, 'Visible', 'off')
    hold on;
    
    % Plot circle radius
    cpos1 = [0,0];
    ticks1 = [1];
    cl1=[0.5,0.5,0.5];
    for i=1:length(ticks1)
        h=rectangle('Position', [cpos1(1,1)-ticks1(i), cpos1(1,2)-ticks1(i), ticks1(i)*2, ticks1(i)*2],...
            'EdgeColor', cl1, 'FaceColor', 'none', 'Curvature', 1, 'LineWidth', 1, 'LineStyle', '-');
    end
    
    % Plot fixation dot
    cpos1 = [0,0];
    ticks1=[0.1];
    cl1=[0.5,0.5,0.5];
    for i=1:length(ticks1)
        h=rectangle('Position', [cpos1(1,1)-ticks1(i), cpos1(1,2)-ticks1(i), ticks1(i)*2, ticks1(i)*2],...
            'EdgeColor', cl1, 'FaceColor', cl1, 'Curvature', 1, 'LineWidth', 1, 'LineStyle', '-');
    end
    
    % Initialize data values for plotting
    for i=1:numel(theta)
        
        % Color
        graphcond = i;
        
        % Find coordinates of a line
        f_rad = radius1_normalized(i);
        f_arc = theta(i);
        [xc,yc] = pol2cart(f_arc*pi/180, f_rad);
        objsize = 0.5;
        
        % Plot cirlce
        h=rectangle('Position', [xc(1)-objsize(1)/2, yc(1)-objsize(1)/2, objsize(1), objsize(1)],...
            'EdgeColor', color1_line(i,:), 'FaceColor', color1_line(i,:),'Curvature', 1, 'LineWidth', 1);
        
        text(0, -2, 'Mem pos', 'Color', color1_line(1,:),  'FontSize', fontszlabel, 'HorizontalAlignment', 'center')
    end
end





