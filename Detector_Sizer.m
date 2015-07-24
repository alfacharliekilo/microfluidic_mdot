function [ Detector_Width ] = Detector_Sizer( Detector )
%Detector_Sizer: Used to detect the width of the detector window
%Passes detector size to mr_imagesort
%Function "bwboundaries" is a function from the image processing toolbox
%See help file for specifics, perimeter of detected shapes is output
%clockwise

B = bwboundaries(Detector);
Window = B{1,1};

n = 1;
while Window(n,1) == Window(1,1)
    n = n+1;
    Detector_Width = n;

end


