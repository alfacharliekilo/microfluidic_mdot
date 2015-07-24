clear all;
clc;

%File Structure
fn = '200um_0_5uL_min_2uL_min_out';
wd = 'C:\Users\Pireate Ship\Desktop\ACK\Data\Tif Files\';
wrd = [wd,fn];
Det_name = 'Duty_Cycle.tif';

%Extract Mask from Data
masque = imread([wrd,'.tif']);
imwrite(masque,[wd,Det_name]);
