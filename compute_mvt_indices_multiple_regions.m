function ts = compute_mvt_indices_multiple_regions(Nf,video,regions,frame,threshold)

% time the computation
tmp = datetime("now");
time_start = tmp.Hour*3600+tmp.Minute*60+tmp.Second;

% compute movement indices over multiple polygonal regions. 
Nregions = length(regions);
ts = zeros(Nf,Nregions);

for f=1:Nf
    if mod(f,1000)==0
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
            '. Processing time remaining about ' num2str(m) 'mins and ' num2str(s) 'secs']);
    end
    old_frame = frame;
    
    % double are of no use: data is in 8 bit int, and we go 2x faster this
    % way.
    %frame = double(read(video,f));
    frame = read(video,f);

    % compute diff between consecutive frames
    dframe = abs(frame-old_frame);

    % average over color
    tmp = mean(dframe,3);
    tmp = tmp.*(tmp>threshold);

    % sample all movt indices
    for b = 1:Nregions

        region = regions{b};
        % convert to integer values (lines and columns).
        region = round(region);
        
        % compute mask for region
        x = region(:,1);
        y = region(:,2);
        mask = roipoly(tmp,x,y);

        % extract values in mask
        value = tmp(mask>0);

        % average values inside the sampling region
        ts(f,b) = mean(value(:));
    end
end

% end time
tmp = datetime("now");
time_end = tmp.Hour*3600+tmp.Minute*60+tmp.Second;
time_diff = time_end-time_start;
disp(' ')
disp(['Time taken for video lasting ' num2str(Nf/(video.FrameRate*60)) ' minutes: ' num2str(time_diff/60) ' minutes']);
disp(' ');

end