function r = time_msf(t)

% convert t into string of the format 00:00:00 (m,s,fraction)

% minutes
mins = floor(t/60);
% seconds
secs = floor(t-60*mins);
% fraction
fraction = round(100*(t-60*mins-secs));

% pad with zeros if necessary
% minutes
if mins<10
    min_str = ['0' num2str(mins)];
else
    min_str = num2str(mins);
end
% seconds
if secs<10
    sec_str = ['0' num2str(secs)];
else
    sec_str = num2str(secs);
end
% fraction
if fraction<10
    frac_str = ['0' num2str(fraction)];
else
    frac_str = num2str(fraction);
end

r = [min_str ':' sec_str ':' frac_str];


end