function [Nf,fps,Nlines,Ncolumns,video] = read_video(file)
% reads video and outputs its parameters
video = VideoReader(file);
Nf = video.NumFrames;
fps = round(video.frameRate);
Nlines = video.Height;
Ncolumns = video.Width;
end