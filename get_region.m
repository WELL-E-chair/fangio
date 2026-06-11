function [region,fig_cropped] = get_region(video,f,crop,regions,colors)

% lets user define where in the (cropped) frame the curves will be displayed.

Nregions = length(regions);

% draw region with the mouse
clf
% double are of no use: data is in 8 bit int
%frame = double(read(video,1));
frame = read(video,f);
cropped = frame(crop(2)+(1:crop(4)),crop(1)+(1:crop(3)),:);
imshow(cropped);

% add the polygons
for b=1:Nregions
    region = regions{b};
    x = region(:,1)-crop(1);
    y = region(:,2)-crop(2);
    display_polygon(x,y,2,[colors(b,1:3) 0.25])
end

xlabel(['Select with the mouse the region where curves will be displayed...'])

% draw regions to sample the image/mvt index
% sample region 1 (top)
tmp = drawrectangle('Color',[1 1 1]);
region = round(tmp.Position);

fig_cropped = get(gcf,'Position');

close all

end