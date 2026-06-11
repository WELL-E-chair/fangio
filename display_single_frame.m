function display_single_frame(f,t,before,after,ts,...
    Left,Width,Bottom,Height,Right,Top,...
    video,crop,sampling_regions,colors,A,B,plot_region,resolution,font_size)

Nsampling_regions = width(ts);

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

end