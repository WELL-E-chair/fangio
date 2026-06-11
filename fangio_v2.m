clear;

% Fangio version 2, written on 22 nov 2024, includes multiple sampling
% regions, mvt index computation, video cropping, region for timeseries 
% display, confirmation by user, and generation of augmented videos.

% path to the video (no "/" at the end)
folder = 'path\to\fangio';
file = 'video_name.mp4';

% folder where results will be stored (no "/" at the end)
results_folder = 'path\to\fangio\results';

% -------------------------------------------------------------------------
% Display Parameters

% colors to display the sampling boxes, with 0.25 transparency
colors = [0 0 1 0.25;...
    1 0 0 0.25;...
    0 1 0 0.25;...
    1 0 1 0.25;...
    0 1 1 0.25;...
    1 1 0 0.25];

% threshold to remove camera artefacts.
threshold = 50;

% window boundaries (all in seconds)
before = 10;
after = 50;

% Temporal resolution for the time axis (= difference
% in seconds between consecutive tick marks)
resolution = 10;

% font size for text on the video
font_size = 12;


% -------------------------------------------------------------------------
% Load the video(s)

% read original video
disp(' ')
disp(['Reading source video....' file])
[Nf,fps,Nlines,Ncolumns,video] = read_video([folder '/' file]);

% make output folder
disp('Creating output folder.')
results_folder  = [results_folder '\' file(1:end-4)];
mkdir(results_folder);

disp('Done')
disp(' ')

% close all image
close all

% -------------------------------------------------------------------------
disp(' ');
disp('Step 1: Trace the sampling regions.')
disp('-------------------------------------------------------------')

not_enough = 1;
box_counter = 0;
frame = read(video,1);
imshow(frame);
xlabel('Use the mouse to select regions where movement indices will be extracted...')

% for now, user will use boxes to select frame regions (might be converted
% to polygons in the future).
sampling_regions = [];

while not_enough
    % draw a region
    box_counter = box_counter + 1;

    % trying region that is not a rectangle
    %tmp = drawrectangle('Color',colors(box_counter,1:3));
    tmp = drawpolygon('Color',colors(box_counter,1:3));
    % store it
    sampling_regions{end+1} = tmp.Position;
    % ask if the user wants more
    answer = questdlg('Would you like to add another region?', ...
	'Drawing regions of interest', ...
	'Yes','No','No');
    % quit when the user has enough
    if strcmp(answer,'No')
        not_enough = 0;
    end
end
save([results_folder '\sampling_regions.mat'],'sampling_regions');

load([results_folder '\sampling_regions.mat'],'sampling_regions');
Nsampling_regions = length(sampling_regions);

close all


% -------------------------------------------------------------------------
disp(' ');
disp('Step 2: Extract the movement indices.')
disp('-----------------------------------------------')

disp(['Starting computation of the ' num2str(Nsampling_regions) ' movement indices...'])

% compute movement indices over 3 regions above
% boxes for 3 signals
ts = compute_mvt_indices_multiple_regions(Nf,video,sampling_regions,frame,threshold);

disp('Done!')

save([results_folder '\ts.mat'],'ts');
load([results_folder '\ts.mat'],'ts');

% -------------------------------------------------------------------------
disp(' ');
disp('Step 3: crop the video.')
disp('------------------------------------------------------------------------------')
disp(' ');

imshow(frame);
xlabel('Crop the video frame with the mouse to remove unecessary information.')

% add the polygons
for b=1:Nsampling_regions
    region = sampling_regions{b};
    x = region(:,1);
    y = region(:,2);
    display_polygon(x,y,2,[colors(b,1:3) 0.25])
end

% now crop with a box
tmp = drawrectangle('Color',[1 1 1]);
crop = round(tmp.Position);

close all

save([results_folder '/crop.mat'],'crop');
load([results_folder '/crop.mat'],'crop');

% new dimensions of the frame
nlines = crop(4);
ncolumns = crop(3);

% -------------------------------------------------------------------------
disp(' ');
disp('Step 4: Draw the region where curves will be displayed on the video.')
disp('------------------------------------------------------------------------------')
disp(' ');

[plot_region,fig_cropped] = get_region(video,1,crop,sampling_regions,colors);
save([results_folder '/plot_region.mat'],'plot_region');

load([results_folder '/plot_region.mat'],'plot_region');

% extract the values for the display region
Left = plot_region(1);
Top = plot_region(2);
Width = plot_region(3);
Height = plot_region(4);
% other stuff that we will need
Bottom = Top+Height;
Right = Left+Width;

% -------------------------------------------------------------------------
disp(' ');
disp('Step 5: Inspection of the augmented video format and presentation.')
disp('------------------------------------------------------------------------------')
disp(' ');

% temporal resolution for videos
dt = 1/fps;

% y-axis (function values)
f_range = [min(ts(:)) max(ts(:))];

% normalize all f values in [0,1] (so we can easily map it to the display
% region).
A = 1/(max(ts(:))-min(ts(:)));
B = -min(ts(:))/(max(ts(:))-min(ts(:)));

% sampling times
t = ((1:Nf)-1)*dt;

scr_size = get(0,'screensize');
figure('Position',[-50+scr_size(3)-ncolumns -100+scr_size(4)-nlines ncolumns nlines]);

display_single_frame(1,t,before,after,ts,Left,Width,Bottom,Height,Right,Top,...
    video,crop,sampling_regions,colors,A,B,plot_region,resolution,font_size);

answer = questdlg('Proceed with augmented video generation?', ...
    'Continue or start over.', ...
    'Yes','No','No');

if strcmp(answer,'Yes')

    close all

    % -------------------------------------------------------------------------
    disp(' ');
    disp('Step 6: Create the augmented video.')
    disp('------------------------------------------------------------------------------')
    disp(' ');

    % make video
    augm_video = VideoWriter([results_folder '/' file(1:end-4) '_augm.mp4'],'MPEG-4');
    augm_video.FrameRate = 1/dt;
    open(augm_video);

    % time the computation
    tmp = datetime("now");
    time_start = tmp.Hour*3600+tmp.Minute*60+tmp.Second;

    scr_size = get(0,'screensize');

    % make figure the same size as the crop
    figure('Position',[-50+scr_size(3)-ncolumns -100+scr_size(4)-nlines ncolumns nlines]);

    % loop on video frames
    for f=1:Nf

        % display progress and time remaining...
        if mod(f,100)==0
            % compute approx to remaining time
            tmp = datetime("now");
            time = tmp.Hour*3600+tmp.Minute*60+tmp.Second;
            time_diff = time-time_start;

            % time per frame
            tpf = time_diff/f;
            % expected remaining time
            ert = tpf*(Nf-f);
            m = floor(ert/60);
            s = round(ert)-m*60;
            % print result
            disp(['Processed ' num2str(f) ' frames of ' num2str(Nf) ...
                '. Processing time remaining: about ' num2str(m) 'mins and ' num2str(s) 'secs']);
        end

        % in seconds.
        time = t(f);

        % Window will decrease the number of points in the plot.
        pos = (t>=(time-before)).*(t<(time+after))>0;
        twindow = t(pos);
        fwindow = ts(pos,:);

        % x axis
        % coefficients to normalize time values.
        a = 1/(max(twindow)-min(twindow));
        b = -min(twindow)/(max(twindow)-min(twindow));
        t_norm = a*twindow+b;
        % columns going from left to right of display region (t_norm used to keep
        % the same number of points as in f).
        columns = Left+t_norm*Width;

        % y axis
        % Convert function values so they fit in the display region.
        % scale f between 0 and 1 (using global coefficients)
        f_norm = A*fwindow+B;
        % translate and scale (- = curve in upside down in line coordinate system)
        gwindow = Bottom-f_norm*Height;

        % read current frame
        frame = read(video,f);

        % crop it
        img = frame(crop(2)+(1:crop(4)),crop(1)+(1:crop(3)),:);

        clf
        image(img);
        set(gca,'position',[0 0 1 1],'units','normalized')
        hold on
        % display the polygons (sampling regions)
        for ii=1:Nsampling_regions
            region = sampling_regions{ii};
            x = region(:,1)-crop(1);
            y = region(:,2)-crop(2);
            display_polygon(x,y,2,[colors(ii,1:3) 0.25])
        end

        % display plot region
        my_box(plot_region(1),plot_region(2),plot_region(3),plot_region(4),2,[1 1 1])
        % movt indices
        for ii=1:width(gwindow)
            plot(columns,gwindow(:,ii),'-','Color',colors(ii,1:3),'LineWidth',2)
        end

        % red line to show where the center is (compute the normalized version of time, and
        % then the corresponding column).
        column_center = Left+(a*time+b)*(Right-Left);
        line(column_center*[1 1],[Bottom Top],'Color',[1 0 0]);

        % compute displayed tick marks (in time) - we use floor instead of
        % round to remove tick marks outside of the display region.
        tround_right = unique(floor(twindow/resolution)*resolution);
        tround_left = unique(ceil(twindow/resolution)*resolution);
        tround = intersect(tround_left,tround_right);

        % convert time tick to columns.
        tick_columns = Left+(a*tround+b)*(Right-Left);
        % and add the tick labels and the tick marks
        for ii=1:length(tick_columns)
            % tick marks
            line(tick_columns(ii)*[1 1],Bottom+[0 -1]*10,'Color',[1 1 1],'LineWidth',2)
            % tick labels
            text(tick_columns(ii),Bottom-20,[time_msf(tround(ii))],'Color',[1 1 1],...
                'HorizontalAlignment','center')
        end

        % add the current time and frame to the right of red line
        hpos = Left+Width*before/(before+after);
        text(hpos,Top+font_size,['time: ' time_msf(time)],...
            'HorizontalAlignment','left','Color',[1 1 1],'FontSize',12);
        text(hpos,Top+2*font_size,['frame: ' num2str(f)],...
            'HorizontalAlignment','left','Color',[1 1 1],'FontSize',12);

        drawnow

        frame = getframe(gcf);
        writeVideo(augm_video,frame);

    end

    close(augm_video);

    tmp = datetime("now");
    time_end = tmp.Hour*3600+tmp.Minute*60+tmp.Second;
    time_diff = time_end-time_start;
    disp(['Time taken for video lasting ' num2str(Nf/(fps*60)) ' minutes: ' num2str(time_diff/60) ' minutes']);

else
    disp('Script terminated. Rerun to start over.')

end



% =========================================================================
