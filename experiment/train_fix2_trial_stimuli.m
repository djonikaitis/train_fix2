% Prepare all the rectangles for the trial

%% Fixation converted to pixels


% Fixation stimulus
pos1 = expsetup.stim.esetup_fix_arc(tid,1);
rad1 = expsetup.stim.esetup_fix_radius(tid,1);
[xc, yc] = pol2cart(pos1*pi/180, rad1); % Convert to cartesian
coord1=[];
coord1(1,:)=xc; coord1(2,:)=yc; % One column, one object

% Fixation size: One row - one set of coordinates (psychtoolbox requirement)

% Fixation stimulus
sz1 = expsetup.stim.esetup_fix_size(tid,1:4);
fixation_rect = runexp_convert_deg2pix_rect_v10(coord1, sz1); % One column - one object;

% Fixation for eyelink drift
sz1 = expsetup.stim.esetup_fix_size_dirft(tid,1:4);
fixation_rect_eyelink_drift = runexp_convert_deg2pix_rect_v10(coord1, sz1); % One column - one object;

% Fixation for eyelink tracking
sz1 = expsetup.stim.esetup_fix_size_eyetrack(tid,1:4);
fixation_rect_eyelink = runexp_convert_deg2pix_rect_v10(coord1, sz1); % One column - one object;


%% Flash for photodiode

if expsetup.general.record_plexon==1
    sz1 = 110;
    d1_rect = [expsetup.screen.screen_rect(3)-sz1, 1, expsetup.screen.screen_rect(3), sz1]';
    % Rename
    ph_rect=d1_rect;
end
