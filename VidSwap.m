clc
clear all

addpath 'C:\Users\Pireate Ship\Desktop\ACK\mmread'
addpath 'C:\Users\Pireate Ship\Desktop\ACK\mmwrite'

%File Structure
fn = '200um_0_5uL_min_2uL_min_out';
wd = 'C:\Users\Pireate Ship\Desktop\ACK\Data\Video Capture\';
wrd = [wd,fn,'\'];
mfn = [wd,fn,'.wmv'];
mfn_tif = [wd,fn,'.tif'];

%Read Number of Frames
[x, y] = mmread(mfn,[ ],[ ],false,true);
frames = length(getfield(x,'frames'));

%Create TIF Bin
width = (getfield(x,'width'));
height = (getfield(x,'height'));
tif_bin = zeros(height,width);

% Convert .WMV to .TIF
n = 0;
for k =1:1:frames
    n = n+1;
    [x, y] = mmread(mfn,n,[ ],false,true);
    v = getfield(x,'frames');
    b = getfield(v,'cdata');
    b = rgb2gray(b);
    
    tif_bin = b;
    if(n==1)
        imwrite(tif_bin,mfn_tif,'WriteMode','overwrite');
    else
        imwrite(tif_bin,mfn_tif,'WriteMode','append');
    end
end