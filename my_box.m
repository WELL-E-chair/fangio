function my_box(x,y,w,h,www,color)

    line(x+[0 w w 0 0],y+[0 0 h h 0],...
        'LineWidth',www,'Color',color)
end