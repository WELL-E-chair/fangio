function display_polygon(x,y,www,color)

% display polygon defined by x and y

% close the region
x = [x; x(1)];
y = [y; y(1)];
line(x,y,'LineWidth',www,'Color',color)
end